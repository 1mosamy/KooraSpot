namespace KooraSpot.DTOs
{
    public class CreateWithdrawalRequest
    {
        public decimal Amount { get; set; }

        public string WalletNumber { get; set; }
    }
}