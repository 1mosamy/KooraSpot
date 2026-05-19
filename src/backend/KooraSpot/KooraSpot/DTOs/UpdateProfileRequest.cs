using System.ComponentModel.DataAnnotations;

namespace KooraSpot.DTOs
{
    public class UpdateProfileRequest
    {
        [RegularExpression(@"^[A-Za-z\u0600-\u06FF]+(\s[A-Za-z\u0600-\u06FF]+)+$",
  ErrorMessage = "Full name must contain at least first and last name and no symbols.")]
        public string? FullName { get; set; } 

        public string? PhoneNumber { get; set; }

        public string? City { get; set; }

        public string? ProfileImageUrl { get; set; }
    }
}
