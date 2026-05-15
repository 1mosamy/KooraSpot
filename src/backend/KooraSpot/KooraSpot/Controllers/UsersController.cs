using KooraSpot.Constants;
using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;
using RestSharp;
using System.IdentityModel.Tokens.Jwt;
using System.Net;
using System.Net.Mail;
using System.Security.Claims;
using System.Text;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class UsersController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;

        public UsersController(AppDbContext context, IConfiguration configuration)
        {
            _context = context;
            _configuration = configuration;
        }

        [HttpPost("register")]
        public async Task<IActionResult> Register(RegisterRequest request)
        {
            if (request.Password != request.ConfirmPassword)
                return BadRequest("Passwords do not match");

            var existingUser = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (existingUser != null)
                return BadRequest("Email already exists");

            string passwordHash = BCrypt.Net.BCrypt.HashPassword(request.Password);

            var user = new User
            {
                FullName = request.FullName,
                Email = request.Email,
                PasswordHash = passwordHash,
                Role = string.IsNullOrEmpty(request.Role) ? "Player" : request.Role,
                City = request.City,
                CreatedAt = DateTime.Now,
                IsEmailVerified = false
            };

            _context.Users.Add(user);

            await _context.SaveChangesAsync();

            var otpCode = new Random()
                .Next(100000, 999999)
                .ToString();

            var otp = new PasswordResetOtp
            {
                UserId = user.Id,
                OtpCode = otpCode,
                ExpiresAt = DateTime.Now.AddMinutes(5)
            };

            _context.PasswordResetOtps.Add(otp);

            await _context.SaveChangesAsync();

            await SendOtpEmail(user.Email, otpCode, "KooraSpot Email Verification",
    "Verify Your Email");

            return Ok(new
            {
                message = "OTP sent successfully. Please verify your email."
            });
        }

        [HttpPost("login")]
        public async Task<IActionResult> Login(LoginRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest("Invalid email or password");

            bool isPasswordValid = BCrypt.Net.BCrypt.Verify(
                request.Password,
                user.PasswordHash
            );

            if (!isPasswordValid)
                return BadRequest("Invalid email or password");

            if (!user.IsEmailVerified)
            {
                return BadRequest(new
                {
                    message = "No account found with this email address."
                });
            }

            var claims = new List<Claim>
    {
        new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
        new Claim(ClaimTypes.Name, user.FullName),
        new Claim(ClaimTypes.Email, user.Email),
        new Claim(ClaimTypes.Role, user.Role)
    };

            var key = new SymmetricSecurityKey(
                Encoding.UTF8.GetBytes(_configuration["Jwt:Key"]!)
            );

            var credentials = new SigningCredentials(
                key,
                SecurityAlgorithms.HmacSha256
            );

            var durationInMinutes = double.Parse(
                _configuration["Jwt:DurationInMinutes"]!
            );

            var token = new JwtSecurityToken(
                issuer: _configuration["Jwt:Issuer"],
                audience: _configuration["Jwt:Audience"],
                claims: claims,
                expires: DateTime.Now.AddMinutes(durationInMinutes),
                signingCredentials: credentials
            );

            var tokenString = new JwtSecurityTokenHandler()
                .WriteToken(token);

            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            return Ok(new
            {
                token = tokenString,

                expiresIn = (int)(durationInMinutes * 60),

                user = new
                {
                    id = user.Id,

                    name = user.FullName,

                    email = user.Email,

                    city = user.City,

                    phoneNumber = user.PhoneNumber,

                    role = user.Role,

                    profileImageUrl = string.IsNullOrEmpty(user.ProfileImageUrl)
                        ? null
                        : baseUrl + user.ProfileImageUrl,

                    firstLetter = string.IsNullOrEmpty(user.FullName)
                        ? null
                        : user.FullName.Substring(0, 1).ToUpper()
                }
            });
        }

        [Authorize]
        [HttpPut("profile")]
        public async Task<IActionResult> UpdateProfile(UpdateProfileRequest request)
        {
            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return NotFound("User not found");

            user.FullName = request.FullName;
            user.PhoneNumber = request.PhoneNumber;
            user.City = request.City;

            if (!string.IsNullOrEmpty(request.ProfileImageUrl))
            {
                user.ProfileImageUrl = request.ProfileImageUrl;
            }

            await _context.SaveChangesAsync();

            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            return Ok(new
            {
                message = "Profile updated successfully",
                user = new
                {
                    id = user.Id,
                    fullName = user.FullName,
                    phoneNumber = user.PhoneNumber,
                    city = user.City,
                    profileImageUrl = string.IsNullOrEmpty(user.ProfileImageUrl)
                        ? null
                        : baseUrl + user.ProfileImageUrl,
                    firstLetter = string.IsNullOrEmpty(user.FullName)
                        ? null
                        : user.FullName.Substring(0, 1).ToUpper()
                }
            });
        }

        [DisableRequestSizeLimit]
        [RequestFormLimits(MultipartHeadersLengthLimit = 65536)]
        [Authorize]
        [HttpPost("upload-profile-image")]
        public async Task<IActionResult> UploadProfileImage(IFormFile image)
        {
            if (image == null || image.Length == 0)
                return BadRequest("No image uploaded");

            var allowedExtensions = new[] { ".jpg", ".jpeg", ".png", ".webp" };
            var extension = Path.GetExtension(image.FileName).ToLower();

            if (!allowedExtensions.Contains(extension))
                return BadRequest("Invalid file type");

            var userId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var user = await _context.Users.FindAsync(userId);

            if (user == null)
                return NotFound("User not found");

            var folderPath = Path.Combine(
                Directory.GetCurrentDirectory(),
                "wwwroot",
                "images",
                "users"
            );

            if (!Directory.Exists(folderPath))
                Directory.CreateDirectory(folderPath);

            var fileName = $"{Guid.NewGuid()}{extension}";
            var filePath = Path.Combine(folderPath, fileName);

            using (var stream = new FileStream(filePath, FileMode.Create))
            {
                await image.CopyToAsync(stream);
            }

            var imageUrl = $"/images/users/{fileName}";

            user.ProfileImageUrl = imageUrl;
            await _context.SaveChangesAsync();

            var baseUrl = $"{Request.Scheme}://{Request.Host}";

            return Ok(new
            {
                imageUrl = baseUrl + imageUrl
            });
        }

     
        private async Task SendOtpEmail(string toEmail, string otpCode , string subject, string messageTitle)
        {
            var client = new RestClient("https://api.brevo.com/v3/smtp/email");

            var request = new RestRequest("", Method.Post);

            request.AddHeader("accept", "application/json");

            request.AddHeader("api-key", "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");

            request.AddHeader("content-type", "application/json");

            var body = new
            {
                sender = new
                {
                    name = "KooraSpot",
                    email = "mohamedsamyt69@gmail.com"
                },

                to = new[]
                {
            new { email = toEmail }
        },

                subject = subject,

                htmlContent = $@"
              <h2>{messageTitle}</h2>
            <p>Your OTP code is:</p>
            <h1>{otpCode}</h1>
            <p>This code will expire in 5 minutes.</p>

        "
            };

            request.AddJsonBody(body);

            var response = await client.ExecuteAsync(request);

            if (!response.IsSuccessful)
            {
                throw new Exception(
                    "Failed to send OTP email: " + response.Content
                );
            }
        }
        [HttpPost("forgot-password")]
        public async Task<IActionResult> ForgotPassword(ForgotPasswordRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
            {
                return Ok(new
                {
                    message = "If this email exists, an OTP has been sent"
                });
            }

            var oldOtps = await _context.PasswordResetOtps
                .Where(o => o.UserId == user.Id)
                .ToListAsync();

            _context.PasswordResetOtps.RemoveRange(oldOtps);

            var otpCode = new Random()
                .Next(100000, 999999)
                .ToString();

            var otp = new PasswordResetOtp
            {
                UserId = user.Id,
                OtpCode = otpCode,
                ExpiresAt = DateTime.Now.AddMinutes(5)
            };

            _context.PasswordResetOtps.Add(otp);
            await _context.SaveChangesAsync();

            await SendOtpEmail(user.Email, otpCode, "KooraSpot Password Reset OTP", "KooraSpot Password Reset");

            return Ok(new
            {
                message = "OTP sent successfully"
            });
        }

        [HttpPost("verify-email")]
        public async Task<IActionResult> VerifyEmail(VerifyOtpRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest(new { message = "Invalid email or OTP" });

            var otp = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o =>
                    o.UserId == user.Id &&
                    o.OtpCode == request.OtpCode);

            if (otp == null)
                return BadRequest(new { message = "Invalid OTP" });

            if (otp.ExpiresAt < DateTime.Now)
            {
                _context.PasswordResetOtps.Remove(otp);
                await _context.SaveChangesAsync();

                return BadRequest(new { message = "OTP expired" });
            }

            user.IsEmailVerified = true;

            _context.PasswordResetOtps.Remove(otp);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Email verified successfully"
            });
        }

        [HttpPost("verify-reset-otp")]
        public async Task<IActionResult> VerifyResetOtp(VerifyOtpRequest request)
        {
            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest(new { message = "Invalid email or OTP" });

            var otp = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o =>
                    o.UserId == user.Id &&
                    o.OtpCode == request.OtpCode);

            if (otp == null)
                return BadRequest(new { message = "Invalid OTP" });

            if (otp.ExpiresAt < DateTime.Now)
            {
                _context.PasswordResetOtps.Remove(otp);
                await _context.SaveChangesAsync();

                return BadRequest(new { message = "OTP expired" });
            }

            return Ok(new
            {
                message = "OTP verified successfully"
            });
        }

        [HttpPost("reset-password")]
        public async Task<IActionResult> ResetPassword(ResetPasswordRequest request)
        {
            if (request.NewPassword != request.ConfirmPassword)
            {
                return BadRequest(new
                {
                    message = "Passwords do not match"
                });
            }

            var user = await _context.Users
                .FirstOrDefaultAsync(u => u.Email == request.Email);

            if (user == null)
                return BadRequest(new { message = "Invalid email or OTP" });

            var otp = await _context.PasswordResetOtps
                .FirstOrDefaultAsync(o =>
                    o.UserId == user.Id &&
                    o.OtpCode == request.OtpCode);

            if (otp == null)
                return BadRequest(new { message = "Invalid OTP" });

            if (otp.ExpiresAt < DateTime.Now)
            {
                _context.PasswordResetOtps.Remove(otp);
                await _context.SaveChangesAsync();

                return BadRequest(new { message = "OTP expired" });
            }

            user.PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.NewPassword);

            _context.PasswordResetOtps.Remove(otp);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Password reset successfully"
            });
        }
    }
}