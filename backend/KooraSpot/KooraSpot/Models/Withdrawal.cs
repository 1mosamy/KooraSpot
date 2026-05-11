namespace KooraSpot.Models
{
    public class Withdrawal
    {
        public int Id { get; set; }

        public int OwnerId { get; set; }
        public User Owner { get; set; }

        public decimal Amount { get; set; }

        public string WalletNumber { get; set; }

        public string Status { get; set; } = "Completed";

        public DateTime CreatedAt { get; set; } = DateTime.Now;
    }
}