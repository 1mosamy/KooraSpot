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
                    b.CreatedAt <= DateTime.Now.AddMinutes(-10))
                .ToListAsync();

            foreach (var booking in expiredBookings)
            {
                booking.Status = "Cancelled";
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

                var exists = await _context.Bookings.AnyAsync(b =>
                    b.FieldId == request.FieldId &&
                    b.BookingDate == request.BookingDate.Date &&
                    b.SlotTime == slot &&
                    b.Status != "Cancelled");

                if (exists)
                    return BadRequest($"Slot {slot} already booked");
            }

            var dayName = request.BookingDate
                .ToString("dddd", new CultureInfo("en-US"));

            var totalPrice = field.PricePerHour * request.SlotTime.Count;

            var bookings = new List<Booking>();

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
                .Select(b => new
                {
                    b.Id,
                    fieldId = b.FieldId,
                    fieldName = b.Field.Name,
                    b.SlotTime,
                    bookingDate = b.BookingDate.ToString("yyyy-MM-dd"),
                    b.DayName,
                    b.TotalPrice,
                    b.Status
                })
                .ToListAsync();

            return Ok(bookings);
        }

       
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

            var bookings = await _context.Bookings
                .Where(b => b.FieldId == fieldId)
                .Include(b => b.Player)
                .Select(b => new
                {
                    b.Id,
                    playerName = b.Player.FullName,
                    playerId = b.PlayerId,
                    b.SlotTime,
                    bookingDate = b.BookingDate.ToString("yyyy-MM-dd"),
                    b.DayName,
                    b.TotalPrice,
                    b.Status
                })
                .ToListAsync();

            return Ok(bookings);
        }
    }
}