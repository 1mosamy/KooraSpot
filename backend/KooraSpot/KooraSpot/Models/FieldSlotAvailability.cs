namespace KooraSpot.Models
{
    public class FieldSlotAvailability
    {
        public int Id { get; set; }

        public int FieldId { get; set; }
        public Field Field { get; set; }

        public DateTime Date { get; set; }

        public string SlotTime { get; set; }

        public bool IsActive { get; set; }
    }
}