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
    [Authorize(Roles = "Owner")]
    public class TimeSlotsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public TimeSlotsController(AppDbContext context)
        {
            _context = context;
        }

        // GET: api/Fields/1/slots?date=2026-04-12
        [HttpGet]
        public async Task<IActionResult> GetSlots(int fieldId, [FromQuery] DateTime date)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            if (date == default)
                date = DateTime.Today;

            var baseSlots = await _context.TimeSlots
                .Where(s => s.FieldId == fieldId)
                .ToListAsync();

            var dayAvailabilities = await _context.FieldSlotAvailabilities
                .Where(a => a.FieldId == fieldId && a.Date.Date == date.Date)
                .ToListAsync();

            var result = baseSlots.Select(slot =>
            {
                var daySlot = dayAvailabilities
                    .FirstOrDefault(a => a.SlotTime == slot.SlotTime);

                return new
                {
                    slot.Id,
                    slot.SlotTime,
                    Date = date.Date.ToString("yyyy-MM-dd"),
                    DayName = date.ToString("dddd", new CultureInfo("ar-EG")),
                    IsActive = daySlot?.IsActive ?? slot.IsActive
                };
            }).ToList();

            return Ok(result);
        }

        // PUT: api/Fields/1/slots?date=2026-04-12
        [HttpPut]
        public async Task<IActionResult> UpdateSlots(
            int fieldId,
            [FromQuery] DateTime date,
            [FromBody] List<UpdateTimeSlotRequest> requests)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            if (date == default)
                return BadRequest("Date is required");

            foreach (var request in requests)
            {
                var availability = await _context.FieldSlotAvailabilities
                    .FirstOrDefaultAsync(a =>
                        a.FieldId == fieldId &&
                        a.Date.Date == date.Date &&
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