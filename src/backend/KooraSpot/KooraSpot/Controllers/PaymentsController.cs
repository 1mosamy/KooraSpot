using KooraSpot.Constants;
using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Stripe;
using Stripe.Checkout;
using System.Security.Claims;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class PaymentsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public PaymentsController(AppDbContext context)
        {
            _context = context;
            StripeConfiguration.ApiKey = StripeSettings.SecretKey;
        }

        [Authorize(Roles = "Player")]
        [HttpPost("create-checkout-session")]
        public async Task<IActionResult> CreateCheckoutSession(CreateCheckoutSessionRequest request)
        {
            var playerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            if (request.BookingIds == null || !request.BookingIds.Any())
                return BadRequest(new { message = "No bookings selected" });

            var bookings = await _context.Bookings
                .Include(b => b.Field)
                .Where(b =>
                    request.BookingIds.Contains(b.Id) &&
                    b.PlayerId == playerId &&
                    b.Status == "Pending")
                .ToListAsync();

            if (bookings.Count != request.BookingIds.Count)
                return BadRequest(new { message = "Invalid or non-pending bookings" });

            var fieldIds = bookings.Select(b => b.FieldId).Distinct().ToList();

            if (fieldIds.Count > 1)
                return BadRequest(new { message = "All bookings must be for the same field" });

            var totalAmount = bookings.Sum(b => b.TotalPrice);

            var options = new SessionCreateOptions
            {
                Mode = "payment",

                PaymentMethodTypes = new List<string>
                {
                    "card"
                },

                LineItems = new List<SessionLineItemOptions>
                {
                    new SessionLineItemOptions
                    {
                        Quantity = 1,
                        PriceData = new SessionLineItemPriceDataOptions
                        {
                            Currency = StripeSettings.Currency,
                            UnitAmount = (long)(totalAmount * 100),
                            ProductData = new SessionLineItemPriceDataProductDataOptions
                            {
                                Name = $"KooraSpot Booking - {bookings.First().Field.Name}"
                            }
                        }
                    }
                },

                SuccessUrl = StripeSettings.SuccessUrl + "?session_id={CHECKOUT_SESSION_ID}",
                CancelUrl = StripeSettings.CancelUrl,

                Metadata = new Dictionary<string, string>
                {
                    { "bookingIds", string.Join(",", request.BookingIds) },
                    { "playerId", playerId.ToString() },
                    { "fieldId", fieldIds.First().ToString() }
                }
            };

            var service = new SessionService();
            var session = await service.CreateAsync(options);

            foreach (var booking in bookings)
            {
                var existingPayment = await _context.Payments
                    .FirstOrDefaultAsync(p => p.BookingId == booking.Id);

                if (existingPayment == null)
                {
                    _context.Payments.Add(new Payment
                    {
                        BookingId = booking.Id,
                        Amount = booking.TotalPrice,
                        PaymentMethod = "Stripe Checkout",
                        Status = "Pending",
                        StripeSessionId = session.Id
                    });
                }
                else
                {
                    existingPayment.Amount = booking.TotalPrice;
                    existingPayment.PaymentMethod = "Stripe Checkout";
                    existingPayment.Status = "Pending";
                    existingPayment.StripeSessionId = session.Id;
                    existingPayment.PaidAt = null;
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                paymentUrl = session.Url,
                sessionId = session.Id,
                totalAmount
            });
        }

        [HttpPost("stripe-webhook")]
        public async Task<IActionResult> StripeWebhook()
        {
            var json = await new StreamReader(HttpContext.Request.Body).ReadToEndAsync();

            Event stripeEvent;

            try
            {
                stripeEvent = EventUtility.ConstructEvent(
                    json,
                    Request.Headers["Stripe-Signature"],
                    StripeSettings.WebhookSecret
                );
            }
            catch
            {
                return BadRequest();
            }

            if (stripeEvent.Type == "checkout.session.completed")
            {
                var session = stripeEvent.Data.Object as Session;

                if (session == null)
                    return BadRequest();

                var payments = await _context.Payments
                    .Include(p => p.Booking)
                    .Where(p =>
                        p.StripeSessionId == session.Id &&
                        p.Status == "Pending")
                    .ToListAsync();

                foreach (var payment in payments)
                {
                    payment.Status = "Paid";
                    payment.PaidAt = DateTime.Now;

                    payment.Booking.Status = "Confirmed";
                }

                await _context.SaveChangesAsync();
            }

            return Ok();
        }
    }
}