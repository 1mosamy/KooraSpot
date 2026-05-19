using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Globalization;
using System.Security.Claims;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class BookingsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public BookingsController(AppDbContext context)
        {
            _context = context;
        }

        private async Task CancelExpiredBookings()
        {
            var expiredBookings = await _context.Bookings
                .Where(b =>
                    b.Status == "Pending" &&
                    b.CreatedAt < DateTime.Now.AddMinutes(-10))
                .ToListAsync();

            foreach (var booking in expiredBookings)
            {
                booking.Status = "Cancelled";

                var payment = await _context.Payments
                    .FirstOrDefaultAsync(p => p.BookingId == booking.Id);

                if (payment != null)
                {
                    payment.Status = "Cancelled";
                }
            }

            await _context.SaveChangesAsync();
        }

        [Authorize(Roles = "Player")]
        [HttpPost]
        public async Task<IActionResult> CreateBooking(CreateBookingRequest request)
        {
            await CancelExpiredBookings();

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields.FindAsync(request.FieldId);

            if (field == null)
                return NotFound("Field not found");

            if (request.SlotTime == null || !request.SlotTime.Any())
                return BadRequest("No slots selected");

            foreach (var slot in request.SlotTime)
            {
                var availability = await _context.FieldSlotAvailabilities
                    .FirstOrDefaultAsync(a =>
                        a.FieldId == request.FieldId &&
                        a.Date == request.BookingDate.Date &&
                        a.SlotTime == slot);

                var baseSlot = await _context.TimeSlots
                    .FirstOrDefaultAsync(s =>
                        s.FieldId == request.FieldId &&
                        s.SlotTime == slot);

                var isActive = availability?.IsActive ?? baseSlot?.IsActive ?? false;

                if (!isActive)
                    return BadRequest($"Slot {slot} is not available");

          
            }

            var dayName = request.BookingDate
                .ToString("dddd", new CultureInfo("en-US"));

            var totalPrice = field.PricePerHour * request.SlotTime.Count;

            var bookings = new List<Booking>();
            var existingBookings = await _context.Bookings
    .Where(b =>
        b.FieldId == request.FieldId &&
        b.BookingDate == request.BookingDate.Date &&
        request.SlotTime.Contains(b.SlotTime) &&
        (
            b.Status == "Confirmed"
            ||
            (
                b.Status == "Pending" &&
                b.CreatedAt > DateTime.Now.AddMinutes(-10)
            )
        )
    )
    .ToListAsync();

            if (existingBookings.Any())
            {
                return BadRequest(new
                {
                    message = "Some slots are already booked"
                });
            }
            foreach (var slot in request.SlotTime)
            {
                bookings.Add(new Booking
                {
                    PlayerId = userId,
                    FieldId = request.FieldId,
                    BookingDate = request.BookingDate.Date,
                    DayName = dayName,
                    SlotTime = slot,
                    TotalPrice = field.PricePerHour,
                    Status = "Pending",
                    CreatedAt = DateTime.Now
                });
            }

            _context.Bookings.AddRange(bookings);
            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Booking created successfully",
                bookingIds = bookings.Select(b => b.Id).ToList(),
                totalSlots = request.SlotTime.Count,
                totalPrice = totalPrice
            });
        }

        [Authorize(Roles = "Player")]
        [HttpGet("my")]
        public async Task<IActionResult> GetMyBookings()
        {
            await CancelExpiredBookings();

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var bookings = await _context.Bookings
                .Where(b => b.PlayerId == userId)
                .Include(b => b.Field)
                .ThenInclude(f => f.Images)
                .OrderByDescending(b => b.BookingDate)
                .Select(b => new
                {
                    b.Id,

                    fieldId = b.FieldId,
                    fieldName = b.Field.Name,
                    fieldCity = b.Field.City,
                    fieldAddress = b.Field.Address,

                    fieldImage = b.Field.Images
                        .Where(i => i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault(),

                    slotTime = b.SlotTime,
                    bookingDate = b.BookingDate.ToString("yyyy-MM-dd"),
                    dayName = b.DayName,
                    totalPrice = b.TotalPrice,
                    status = b.Status
                })
                .ToListAsync();

            return Ok(bookings);
        }

        //[Authorize(Roles = "Owner")]
        //[HttpGet("field/{fieldId}")]
        //public async Task<IActionResult> GetFieldBookings(int fieldId)
        //{
        //    await CancelExpiredBookings();

        //    var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

        //    var field = await _context.Fields
        //        .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

        //    if (field == null)
        //        return NotFound("Field not found or you are not the owner");

        //    var bookings = await _context.Bookings
        //        .Where(b => b.FieldId == fieldId && _context.Payments.Any(p => p.BookingId == b.Id && p.Status == "Paid"))
        //        .Include(b => b.Player)
        //        .Include(b => b.Field)
        //        .ThenInclude(f => f.Images)
        //        .OrderByDescending(b => b.BookingDate)
        //        .Select(b => new
        //        {
        //            b.Id,

        //            playerName = b.Player.FullName,
        //            playerId = b.PlayerId,

        //            fieldId = b.FieldId,
        //            fieldName = b.Field.Name,
        //            fieldCity = b.Field.City,
        //            fieldAddress = b.Field.Address,

        //            fieldImage = b.Field.Images
        //                .Where(i => i.IsMain)
        //                .Select(i => i.ImageUrl)
        //                .FirstOrDefault(),

        //            slotTime = b.SlotTime,
        //            bookingDate = b.BookingDate.ToString("yyyy-MM-dd"),
        //            dayName = b.DayName,
        //            totalPrice = b.TotalPrice,
        //            status = b.Status
        //        })
        //        .ToListAsync();

        //    return Ok(bookings);
        //}
        [Authorize(Roles = "Owner")]
        [HttpGet("field/{fieldId}")]
        public async Task<IActionResult> GetFieldBookings(int fieldId)
        {
            await CancelExpiredBookings();

            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            var payments = await _context.Payments
                .Include(p => p.Booking)
                    .ThenInclude(b => b.Player)
                .Include(p => p.Booking)
                    .ThenInclude(b => b.Field)
                        .ThenInclude(f => f.Images)
                .Where(p =>
                    p.Status == "Paid" &&
                    p.Booking.FieldId == fieldId &&
                    p.Booking.Field.OwnerId == ownerId)
                .ToListAsync();

            var bookings = payments
                .GroupBy(p => p.StripeSessionId)
                .Select(g => new
                {
                    Id = g.First().Booking.Id,

                    playerName = g.First().Booking.Player.FullName,
                    playerId = g.First().Booking.PlayerId,

                    fieldId = g.First().Booking.FieldId,
                    fieldName = g.First().Booking.Field.Name,
                    fieldCity = g.First().Booking.Field.City,
                    fieldAddress = g.First().Booking.Field.Address,

                    fieldImage = g.First().Booking.Field.Images
                        .Where(i => i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault(),

                    slotTime = string.Join(
                        " , ",
                        g.Select(p => p.Booking.SlotTime)
                    ),

                    bookingDate = g.First().Booking.BookingDate
                        .ToString("yyyy-MM-dd"),

                    dayName = g.First().Booking.DayName,

                    totalPrice = g.Sum(p => p.Amount),

                    status = g.First().Booking.Status
                })
                .OrderByDescending(b => b.bookingDate)
                .ToList();

            return Ok(bookings);
        }
    }
}