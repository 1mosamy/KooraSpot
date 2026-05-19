using System.ComponentModel.DataAnnotations;

namespace KooraSpot.DTOs
{
    public class RegisterRequest
    {
        [Required]
        [RegularExpression(@"^[A-Za-z\u0600-\u06FF]+(\s[A-Za-z\u0600-\u06FF]+)+$",
    ErrorMessage = "Full name must contain at least first and last name and no symbols.")]
        public string FullName { get; set; }
        [Required]
        [Phone]
        public string PhoneNumber { get; set; } = string.Empty;
        [Required]
        public string Email { get; set; } = string.Empty;
        [Required]
        public string Password { get; set; } = string.Empty;
        [Required]
        public string ConfirmPassword { get; set; } = string.Empty;
        [Required]
        public string Role { get; set; } = string.Empty;
        [Required]
        public string? City { get; set; }
    }
}
