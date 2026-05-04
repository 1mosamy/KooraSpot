using System.ComponentModel.DataAnnotations;

namespace KooraSpot.DTOs
{
    public class CreateBookingRequest
    {
        [Required]
        public int FieldId { get; set; }

        [Required]
        public DateTime BookingDate { get; set; }

        [Required]
        public List<string> SlotTime { get; set; }
    }
}