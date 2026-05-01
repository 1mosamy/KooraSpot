using System.ComponentModel.DataAnnotations;

namespace KooraSpot.Models
{
    public class Field
    {
        public int Id { get; set; }

        public int OwnerId { get; set; }

        [Required]
        [MaxLength(100)]
        public string Name { get; set; }

        [Required]
        [MaxLength(250)]
        public string Address { get; set; }

        [Required]
        [MaxLength(100)]
        public string City { get; set; }

        [Required]
        public decimal PricePerHour { get; set; }

        public string? Description { get; set; }

        public bool IsActive { get; set; } = true;

        public DateTime CreatedAt { get; set; } = DateTime.Now;

        public User Owner { get; set; }
        public ICollection<FieldImage> Images { get; set; } = new List<FieldImage>();
    }
}
