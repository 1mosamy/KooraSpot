using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class FieldsController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FieldsController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        public async Task<IActionResult> GetAllFields()
        {
            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            var fields = await _context.Fields
                .Where(f => f.IsActive)
                .Include(f => f.Images)
                .Select(f => new
                {
                    f.Id,
                    f.Name,
                    f.Address,
                    f.City,
                    f.PricePerHour,
                    f.Description,
                    f.OwnerId,
                    Images = f.Images.Select(i => new
                    {
                        i.Id,
                        ImageUrl = baseUrl + i.ImageUrl,
                        i.IsMain
                    }).ToList()
                })
                .ToListAsync();

            return Ok(fields);
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> GetFieldById(int id)
        {
            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            var field = await _context.Fields
                .Where(f => f.Id == id && f.IsActive)
                .Include(f => f.Images)
                .Select(f => new
                {
                    f.Id,
                    f.Name,
                    f.Address,
                    f.City,
                    f.PricePerHour,
                    f.Description,
                    f.OwnerId,
                    Images = f.Images.Select(i => new
                    {
                        i.Id,
                        ImageUrl = baseUrl + i.ImageUrl,
                        i.IsMain
                    }).ToList()
                })
                .FirstOrDefaultAsync();

            if (field == null)
                return NotFound("Field not found");

            return Ok(field);
        }

        [Authorize(Roles = "Owner")]
        [HttpPost]
        public async Task<IActionResult> CreateField([FromForm] CreateFieldRequest request)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = new Field
            {
                Name = request.Name,
                Address = request.Address,
                City = request.City,
                PricePerHour = request.PricePerHour,
                Description = request.Description,
                OwnerId = ownerId,
                IsActive = true,
                CreatedAt = DateTime.Now
            };

            _context.Fields.Add(field);
            await _context.SaveChangesAsync();

            var defaultSlots = GenerateDefaultSlots(field.Id);
            _context.TimeSlots.AddRange(defaultSlots);
            await _context.SaveChangesAsync();

            var uploadedImages = new List<object>();
            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            if (request.Images != null && request.Images.Count > 0)
            {
                var folderPath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot",
                    "images",
                    "fields"
                );

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                for (int i = 0; i < request.Images.Count; i++)
                {
                    var image = request.Images[i];

                    if (image.Length == 0)
                        continue;

                    var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
                    var extension = Path.GetExtension(image.FileName).ToLower();

                    if (!allowedExtensions.Contains(extension))
                        return BadRequest("Invalid image type. Allowed types: jpg, jpeg, png, webp");

                    var fileName = $"{Guid.NewGuid()}{extension}";
                    var filePath = Path.Combine(folderPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var imageUrl = $"/images/fields/{fileName}";

                    var fieldImage = new FieldImage
                    {
                        FieldId = field.Id,
                        ImageUrl = imageUrl,
                        IsMain = i == 0
                    };

                    _context.FieldImages.Add(fieldImage);

                    uploadedImages.Add(new
                    {
                        ImageUrl = baseUrl + imageUrl,
                        IsMain = fieldImage.IsMain
                    });
                }

                await _context.SaveChangesAsync();
            }

            return Ok(new
            {
                message = "Field created successfully",
                field = new
                {
                    field.Id,
                    field.Name,
                    field.Address,
                    field.City,
                    field.PricePerHour,
                    field.Description,
                    field.OwnerId,
                    Images = uploadedImages
                }
            });
        }

        private List<TimeSlot> GenerateDefaultSlots(int fieldId)
        {
            var slots = new List<TimeSlot>();

            for (int hour = 6; hour < 24; hour++)
            {
                var start = DateTime.Today.AddHours(hour);
                var end = DateTime.Today.AddHours(hour + 1);

                slots.Add(new TimeSlot
                {
                    FieldId = fieldId,
                    SlotTime = $"{start:hh:mm tt} - {end:hh:mm tt}",
                    IsActive = true
                });
            }

            return slots;
        }

      

        [Authorize(Roles = "Owner")]
        [HttpPut("{id}")]
        public async Task<IActionResult> UpdateField(int id, [FromForm] CreateFieldRequest request)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .Include(f => f.Images)
                .FirstOrDefaultAsync(f => f.Id == id && f.OwnerId == ownerId && f.IsActive);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            field.Name = request.Name;
            field.Address = request.Address;
            field.City = request.City;
            field.PricePerHour = request.PricePerHour;
            field.Description = request.Description;

            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            if (request.Images != null && request.Images.Count > 0)
            {
                var folderPath = Path.Combine(
                    Directory.GetCurrentDirectory(),
                    "wwwroot",
                    "images",
                    "fields"
                );

                if (!Directory.Exists(folderPath))
                    Directory.CreateDirectory(folderPath);

                foreach (var image in request.Images)
                {
                    if (image.Length == 0)
                        continue;

                    var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
                    var extension = Path.GetExtension(image.FileName).ToLower();

                    if (!allowedExtensions.Contains(extension))
                        return BadRequest("Invalid image type");

                    var fileName = $"{Guid.NewGuid()}{extension}";
                    var filePath = Path.Combine(folderPath, fileName);

                    using (var stream = new FileStream(filePath, FileMode.Create))
                    {
                        await image.CopyToAsync(stream);
                    }

                    var imageUrl = $"/images/fields/{fileName}";

                    _context.FieldImages.Add(new FieldImage
                    {
                        FieldId = field.Id,
                        ImageUrl = imageUrl,
                        IsMain = !field.Images.Any()
                    });
                }
            }

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Field updated successfully",
                field = new
                {
                    field.Id,
                    field.Name,
                    field.Address,
                    field.City,
                    field.PricePerHour,
                    field.Description,
                    images = field.Images.Select(i => new
                    {
                        i.Id,
                        imageUrl = baseUrl + i.ImageUrl,
                        i.IsMain
                    }).ToList()
                }
            });
        }

        [Authorize(Roles = "Owner")]
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteField(int id)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == id && f.OwnerId == ownerId && f.IsActive);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            field.IsActive = false;
            await _context.SaveChangesAsync();

            return Ok("Field deleted successfully");
        }

        [Authorize(Roles = "Owner")]
        [HttpGet("my-fields")]
        public async Task<IActionResult> GetMyFields()
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);
            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            var fields = await _context.Fields
                .Where(f => f.OwnerId == ownerId )
                .Include(f => f.Images)
                .Select(f => new
                {
                    f.Id,
                    f.Name,
                    f.Address,
                    f.City,
                    f.PricePerHour,
                    f.Description,
                    f.IsActive,
                    Images = f.Images.Select(i => new
                    {
                        i.Id,
                        ImageUrl = baseUrl + i.ImageUrl,
                        i.IsMain
                    }).ToList()
                })
                .ToListAsync();

            return Ok(fields);
        }

        [Authorize(Roles = "Owner")]
        [HttpPut("{id}/toggle-active")]
        public async Task<IActionResult> ToggleFieldActive(int id)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var field = await _context.Fields
                .FirstOrDefaultAsync(f => f.Id == id && f.OwnerId == ownerId);

            if (field == null)
                return NotFound("Field not found or you are not the owner");

            field.IsActive = !field.IsActive;

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = field.IsActive ? "Field activated" : "Field deactivated",
                field.Id,
                field.IsActive
            });
        }
    }
}