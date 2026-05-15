/// Centralized UI strings for future Arabic localization.
class AppStrings {
  AppStrings._();

  // ── App ──────────────────────────────────────────────────
  static const String appName = 'KooraSpot';
  static const String tagline = 'Your Ultimate Football Hub';
  static const String joinNetwork = 'Join the ultimate stadium network.';

  // ── Auth ─────────────────────────────────────────────────
  static const String login = 'Login';
  static const String register = 'Register';
  static const String player = 'Player';
  static const String owner = 'Owner';
  static const String email = 'Email Address';
  static const String emailHint = 'email@example.com';
  static const String password = 'Password';
  static const String passwordHint = 'Create a strong password';
  static const String confirmPassword = 'Confirm Password';
  static const String confirmPasswordHint = 'Repeat your password';
  static const String fullName = 'Full Name';
  static const String fullNameHint = 'Enter your full name';
  static const String city = 'City';
  static const String selectCity = 'Select your city';
  static const String forgotPassword = 'Forgot Password?';
  static const String noAccount = "Don't have an account?";
  static const String registerHere = 'Register here';
  static const String hasAccount = 'Already have an account?';
  static const String loginHere = 'Login here';
  static const String logout = 'Logout';

  // ── Splash ───────────────────────────────────────────────
  static const String preparingData = 'Preparing match data...';

  // ── Player Home ──────────────────────────────────────────
  static const String welcomeBack = 'Welcome back,';
  static const String searchStadiums = 'Search for stadiums...';
  static const String nearbyStadiums = 'Nearby Stadiums';
  static const String seeAll = 'See All';
  static const String details = 'Details';
  static const String perHour = '/hr';

  // ── Navigation ───────────────────────────────────────────
  static const String home = 'Home';
  static const String bookings = 'Bookings';
  static const String saved = 'Saved';
  static const String profile = 'Profile';
  static const String dashboard = 'Dashboard';
  static const String courts = 'Courts';

  // ── Stadium Details ──────────────────────────────────────
  static const String bookSlot = 'Book a Slot';
  static const String bookNow = 'Book Now';
  static const String totalPrice = 'Total Price';
  static const String available = 'Available';
  static const String selected = 'Selected';
  static const String booked = 'Booked';
  static const String openNow = 'Open Now';

  // ── Booking ──────────────────────────────────────────────
  static const String bookingConfirmation = 'Booking Confirmation';
  static const String confirmAndPay = 'Confirm & Pay';
  static const String paymentMethod = 'Payment Method';
  static const String upcoming = 'Upcoming';
  static const String past = 'Past';
  static const String bookingHistory = 'Booking History';

  // ── Saved Courts ─────────────────────────────────────────
  static const String savedCourts = 'Saved Courts';
  static const String noSavedCourts = 'No saved courts yet';
  static const String noSavedCourtsDesc =
      'Tap the heart icon on any stadium to save it here.';

  // ── Profile ──────────────────────────────────────────────
  static const String editProfile = 'Edit Profile';
  static const String saveChanges = 'Save Changes';
  static const String profileUpdated = 'Profile updated successfully';
  static const String changePhoto = 'Change Photo';

  // ── Owner Dashboard ──────────────────────────────────────
  static const String todayBooking = 'Today Booking';
  static const String thisWeek = 'This Week';
  static const String yourFields = 'Your Fields';

  // ── Owner Fields ─────────────────────────────────────────
  static const String myFields = 'My Fields';
  static const String addCourt = 'Add Court';
  static const String editField = 'Edit Field';
  static const String courtName = 'Court Name';
  static const String location = 'Location';
  static const String pricePerHour = 'Price Per Hour';
  static const String activeListing = 'Active Listing';
  static const String manageSlots = 'Manage Slots';
  static const String noFieldsYet = 'No fields yet';
  static const String noFieldsDesc =
      'Add your first court to start receiving bookings.';

  // ── Slots ────────────────────────────────────────────────
  static const String unavailable = 'Unavailable';

  // ── Errors ───────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String networkError =
      'No internet connection. Please check your network.';
  static const String retry = 'Retry';

  // ── Validation ───────────────────────────────────────────
  static const String requiredField = 'This field is required';
  static const String invalidEmail = 'Please enter a valid email';
  static const String passwordTooShort =
      'Password must be at least 6 characters';
  static const String passwordsDoNotMatch = 'Passwords do not match';
  static const String selectCityError = 'Please select a city';

  // ── Cities ───────────────────────────────────────────────
  static const List<String> cities = [
    'Cairo',
    'Alexandria',
    'Giza',
    'Tanta',
    'Mansoura',
    'Ismailia',
    'Port Said',
    'Suez',
    'Luxor',
    'Aswan',
    'Hurghada',
    'Sharm El Sheikh',
    'Damietta',
    'Zagazig',
    'Beni Suef',
  ];
}
