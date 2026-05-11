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
    [Route("api/Fields/{fieldId}/slots")]
    [ApiController]
    public class TimeSlotsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TimeSlotsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Fields/1/slots?date=2026-04-12
        [Authorize(Roles = "Owner,Player")]
        [HttpGet]
        public async Task<IActionResult> GetSlots(int fieldId, [FromQuery] DateTime date)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var role = User.FindFirst(ClaimTypes.Role)?.Value;

            if (date == default)
                date = DateTime.Today;

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.IsActive);

            if (field == null)
                return NotFound("Field not found");

            if (role == "Owner" && field.OwnerId != userId)
                return Forbid();

            var baseSlots = await _context.TimeSlots
                .Where(s => s.FieldId == fieldId)
                .OrderBy(s => s.Id)
                .ToListAsync();

            var dayAvailabilities = await _context.FieldSlotAvailabilities
                .Where(a => a.FieldId == fieldId && a.Date == date.Date)
                .ToListAsync();

            var bookings = await _context.Bookings
                .Include(b => b.Player)
                .Where(b =>
                    b.FieldId == fieldId &&
                    b.BookingDate == date.Date &&
                    b.Status != "Cancelled")
                .ToListAsync();

            var result = baseSlots.Select(slot =>
            {
                var daySlot = dayAvailabilities
                    .FirstOrDefault(a => a.SlotTime == slot.SlotTime);

                var booking = bookings
                    .FirstOrDefault(b => b.SlotTime == slot.SlotTime);

                var isBooked = booking != null;

                return new
                {
                    slot.Id,
                    slotTime = slot.SlotTime,
                    date = date.Date.ToString("yyyy-MM-dd"),
                    dayName = date.ToString("dddd", new CultureInfo("ar-EG")),
                    isActive = daySlot?.IsActive ?? slot.IsActive,
                    isBooked,
                    playerName = role == "Owner" && isBooked
                        ? booking!.Player.FullName
                        : null
                };
            }).ToList();

            return Ok(result);
        }

        // PUT: api/Fields/1/slots?date=2026-04-12
        [Authorize(Roles = "Owner")]
        [HttpPut]
        public async Task<IActionResult> UpdateSlots(
            int fieldId,
            [FromQuery] DateTime date,
            [FromBody] List<UpdateTimeSlotRequest> requests)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            if (date == default)
                return BadRequest("Date is required");

            if (requests == null || !requests.Any())
                return BadRequest("No slots provided");

            var field = await _context.Fields
                .FirstOrDefaultAsync(f =>
                    f.Id == fieldId &&
                    f.OwnerId == ownerId &&
                    f.IsActive);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            foreach (var request in requests)
            {
                var bookingExists = await _context.Bookings.AnyAsync(b =>
                    b.FieldId == fieldId &&
                    b.BookingDate == date.Date &&
                    b.SlotTime == request.SlotTime &&
                    b.Status != "Cancelled");

                if (bookingExists)
                    continue;

                var availability = await _context.FieldSlotAvailabilities
                    .FirstOrDefaultAsync(a =>
                        a.FieldId == fieldId &&
                        a.Date == date.Date &&
                        a.SlotTime == request.SlotTime);

                if (availability == null)
                {
                    availability = new FieldSlotAvailability
                    {
                        FieldId = fieldId,
                        Date = date.Date,
                        SlotTime = request.SlotTime,
                        IsActive = request.IsActive
                    };

                    _context.FieldSlotAvailabilities.Add(availability);
                }
                else
                {
                    availability.IsActive = request.IsActive;
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Slots updated successfully",
                date = date.Date.ToString("yyyy-MM-dd"),
                dayName = date.ToString("dddd", new CultureInfo("en-US"))
            });
        }
    }
}