using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
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

        [HttpGet]
        public async Task<IActionResult> GetSlots(int fieldId)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            var slots = await _context.TimeSlots
                .Where(s => s.FieldId == fieldId)
                .Select(s => new
                {
                    s.Id,
                    s.SlotTime,
                    s.IsActive
                })
                .ToListAsync();

            return Ok(slots);
        }

        [HttpPut]
        public async Task<IActionResult> UpdateSlots(
            int fieldId,
            [FromBody] List<UpdateTimeSlotRequest> requests)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == fieldId && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            foreach (var request in requests)
            {
                var slot = await _context.TimeSlots
                    .FirstOrDefaultAsync(s => s.FieldId == fieldId && s.SlotTime == request.SlotTime);

                if (slot == null)
                {
                    slot = new TimeSlot
                    {
                        FieldId = fieldId,
                        SlotTime = request.SlotTime,
                        IsActive = request.IsActive
                    };

                    _context.TimeSlots.Add(slot);
                }
                else
                {
                    slot.IsActive = request.IsActive;
                }
            }

            await _context.SaveChangesAsync();

            return Ok("Slots updated successfully");
        }
    }
}