using Microsoft.AspNetCore.Http;
using System.ComponentModel.DataAnnotations;

namespace KooraSpot.DTOs
{
    public class CreateFieldRequest
    {
        [Required]
        public string Name { get; set; }

        [Required]
        public string Address { get; set; }

        [Required]
        public string City { get; set; }

        [Required]
        public decimal PricePerHour { get; set; }

        public string? Description { get; set; }

        
        public List<IFormFile>? Images { get; set; }
    }
}