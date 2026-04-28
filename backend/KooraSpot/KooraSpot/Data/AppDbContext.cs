using KooraSpot.Models;
using Microsoft.AspNetCore.Mvc.ViewEngines;
using Microsoft.EntityFrameworkCore;
using static System.Net.WebRequestMethods;

namespace KooraSpot.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options)
            : base(options)
        {
        }

        public DbSet<User> Users { get; set; }
        //public DbSet<Field> Fields { get; set; }
        //public DbSet<FieldImage> FieldImages { get; set; }
        //public DbSet<TimeSlot> TimeSlots { get; set; }
        //public DbSet<Booking> Bookings { get; set; }
        //public DbSet<Payment> Payments { get; set; }
      
    }
}
