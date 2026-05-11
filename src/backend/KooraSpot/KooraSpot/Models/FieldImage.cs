namespace KooraSpot.Models
{
    public class FieldImage
    {
        public int Id { get; set; }

        public int FieldId { get; set; }
        public string ImageUrl { get; set; }

        public bool IsMain { get; set; }

        public Field Field { get; set; }
    }
}