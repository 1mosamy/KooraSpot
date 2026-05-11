using KooraSpot.Data;
using KooraSpot.DTOs;
using KooraSpot.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace KooraSpot.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    [Authorize(Roles = "Owner")]
    public class OwnerWalletController : ControllerBase
    {
        private readonly AppDbContext _context;

        public OwnerWalletController(AppDbContext context)
        {
            _context = context;
        }

        [HttpGet("summary")]
        public async Task<IActionResult> GetWalletSummary()
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var totalBookingsAmount = await _context.Payments
                .Where(p =>
                    p.Status == "Paid" &&
                    p.Booking.Field.OwnerId == ownerId)
                .SumAsync(p => p.Amount);

            var platformCommission = totalBookingsAmount * 0.10m;

            var ownerBalanceBeforeWithdraw = totalBookingsAmount - platformCommission;

            var totalWithdrawn = await _context.Withdrawals
                .Where(w =>
                    w.OwnerId == ownerId &&
                    w.Status == "Completed")
                .SumAsync(w => w.Amount);

            var availableBalance = ownerBalanceBeforeWithdraw - totalWithdrawn;

            return Ok(new
            {
                totalBookingsAmount,
                platformCommission,
                commissionPercentage = 10,
                ownerBalanceBeforeWithdraw,
                totalWithdrawn,
                availableBalance
            });
        }

        [HttpPost("withdraw")]
        public async Task<IActionResult> Withdraw(CreateWithdrawalRequest request)
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            if (request.Amount <= 0)
            {
                return BadRequest(new
                {
                    message = "Amount must be greater than zero"
                });
            }

            if (string.IsNullOrWhiteSpace(request.WalletNumber))
            {
                return BadRequest(new
                {
                    message = "Wallet number is required"
                });
            }

            var totalBookingsAmount = await _context.Payments
                .Where(p =>
                    p.Status == "Paid" &&
                    p.Booking.Field.OwnerId == ownerId)
                .SumAsync(p => p.Amount);

            var platformCommission = totalBookingsAmount * 0.10m;

            var ownerBalanceBeforeWithdraw = totalBookingsAmount - platformCommission;

            var totalWithdrawn = await _context.Withdrawals
                .Where(w =>
                    w.OwnerId == ownerId &&
                    w.Status == "Completed")
                .SumAsync(w => w.Amount);

            var availableBalance = ownerBalanceBeforeWithdraw - totalWithdrawn;

            if (request.Amount > availableBalance)
            {
                return BadRequest(new
                {
                    message = "Insufficient balance",
                    availableBalance,
                    platformCommission
                });
            }

            var withdrawal = new Withdrawal
            {
                OwnerId = ownerId,
                Amount = request.Amount,
                WalletNumber = request.WalletNumber,
                Status = "Completed",
                CreatedAt = DateTime.Now
            };

            _context.Withdrawals.Add(withdrawal);

            await _context.SaveChangesAsync();

            return Ok(new
            {
                message = "Withdrawal completed successfully",
                withdrawalId = withdrawal.Id,
                withdrawnAmount = withdrawal.Amount,
                walletNumber = withdrawal.WalletNumber,
                remainingBalance = availableBalance - request.Amount,
                platformCommission
            });
        }

        [HttpGet("withdrawals")]
        public async Task<IActionResult> GetMyWithdrawals()
        {
            var ownerId = int.Parse(User.FindFirst(ClaimTypes.NameIdentifier)!.Value);

            var withdrawals = await _context.Withdrawals
                .Where(w => w.OwnerId == ownerId)
                .OrderByDescending(w => w.CreatedAt)
                .Select(w => new
                {
                    w.Id,
                    w.Amount,
                    w.WalletNumber,
                    w.Status,
                    createdAt = w.CreatedAt.ToString("yyyy-MM-dd HH:mm")
                })
                .ToListAsync();

            return Ok(withdrawals);
        }
    }
}