namespace KooraSpot.Models
{
    public class Payment
    {
        public int Id { get; set; }

        public int BookingId { get; set; }
        public Booking Booking { get; set; }

        public decimal Amount { get; set; }

        public string PaymentMethod { get; set; } = "Stripe Checkout";

        public string Status { get; set; } = "Pending";

        public string? StripeSessionId { get; set; }

        public DateTime? PaidAt { get; set; }
    }
}