using KooraSpot.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Player")]
    public class FavoritesController : ControllerBase
    {
        private readonly AppDbContext _context;

        public FavoritesController(AppDbContext context)
        {
            _context = context;
        }

        private int GetUserId()
        {
            return int.Parse(User.FindFirstValue(ClaimTypes.NameIdentifier)!);
        }

        [HttpPost("{fieldId}")]
        public async Task<IActionResult> AddToFavorites(int fieldId)
        {
            var userId = GetUserId();

            var fieldExists = await _context.Fields
                .AnyAsync(f => f.Id == fieldId && f.IsActive);

            if (!fieldExists)
            {
                return NotFound(new
                {
                    message = "Field not found"
                });
            }

            var alreadyExists = await _context.FavoriteFields
                .AnyAsync(f => f.UserId == userId && f.FieldId == fieldId);

            if (alreadyExists)
            {
                return BadRequest(new
                {
                    message = "Field already in favorites"
                });
            }

            var favorite = new FavoriteField
            {
                UserId = userId,
                FieldId = fieldId
            };

            _context.FavoriteFields.Add(favorite);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Field added to favorites"
            });
        }

        [HttpDelete("{fieldId}")]
        public async Task<IActionResult> RemoveFromFavorites(int fieldId)
        {
            var userId = GetUserId();

            var favorite = await _context.FavoriteFields
                .FirstOrDefaultAsync(f =>
                    f.UserId == userId &&
                    f.FieldId == fieldId);

            if (favorite == null)
            {
                return NotFound(new
                {
                    message = "Favorite not found"
                });
            }

            _context.FavoriteFields.Remove(favorite);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Field removed from favorites"
            });
        }

        [HttpGet]
        public async Task<IActionResult> GetMyFavorites()
        {
            var userId = GetUserId();

            var favorites = await _context.FavoriteFields
                .Where(f => f.UserId == userId)
                .Include(f => f.Field)
                .ThenInclude(field => field.Images)
                .Select(f => new
                {
                    f.Field.Id,
                    f.Field.Name,
                    f.Field.Address,
                    f.Field.City,
                    f.Field.PricePerHour,
                    f.Field.Description,

                    MainImage = f.Field.Images
                        .Where(i => i.IsMain)
                        .Select(i => i.ImageUrl)
                        .FirstOrDefault()
                })
                .ToListAsync();

            return Ok(favorites);
        }
    }
}