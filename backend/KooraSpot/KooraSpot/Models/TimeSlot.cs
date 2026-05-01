namespace KooraSpot.Models
{
    public class TimeSlot
    {
        public int Id { get; set; }
        public int FieldId { get; set; }
        public Field Field { get; set; }
        public string SlotTime { get; set; } 
        public bool IsActive { get; set; }
    }
}
