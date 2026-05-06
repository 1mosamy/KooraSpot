using KooraSpot.Models;

public class FavoriteField
{
    public int Id { get; set; }

    public int UserId { get; set; }
    public User User { get; set; }

    public int FieldId { get; set; }
    public Field Field { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}