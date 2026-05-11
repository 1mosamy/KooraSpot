
using Microsoft.Extensions.Primitives;

namespace KooraSpot.Models
{
    public class User
    {
       public int Id { get; set; }
        public string FullName { get; set; } = string.Empty;  // Register and login
        public string Email { get; set; } = string.Empty;
       public string PasswordHash { get; set; } = string.Empty;
       public string Role { get; set; } = "";
        public bool IsEmailVerified { get; set; } = false;
        // Profile information
        public string? ProfileImageUrl { get; set; } 
        public string? PhoneNumber { get; set; }
        public string? City { get; set; }
        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}
