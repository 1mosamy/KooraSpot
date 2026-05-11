namespace KooraSpot.Models
{
    public class Booking
    {
        public int Id { get; set; }

        public int PlayerId { get; set; }
        public User Player { get; set; }

        public int FieldId { get; set; }
        public Field Field { get; set; }

        public DateTime BookingDate { get; set; }

        public string DayName { get; set; }

        public string SlotTime { get; set; }

        public decimal TotalPrice { get; set; }

        public string Status { get; set; } = "Pending";

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}