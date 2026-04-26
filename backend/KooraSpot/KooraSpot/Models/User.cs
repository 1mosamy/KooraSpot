
namespace KooraSpot.Models
{
    public class User
    {
       public int Id { get; set; }
        // Register and login
       public string Email { get; set; } = string.Empty;
       public string PasswordHash { get; set; } = string.Empty;
       public string Role { get; set; } = ""; 

         // Profile information
        public string? Name { get; set; }
       public string? PhoneNumber { get; set; }
        public string? City { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
