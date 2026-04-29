USE KooraSpotDb;
GO
CREATE TABLE Users (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FullName NVARCHAR(100) NOT NULL,
    PhoneNumber NVARCHAR(20) NULL,
    Email NVARCHAR(100) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(MAX) NOT NULL,
    Role NVARCHAR(20) NOT NULL, 
    City NVARCHAR(100) NULL, 
    ProfileImageUrl NVARCHAR(MAX) NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE()
);

CREATE TABLE Fields (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    OwnerId INT NOT NULL,
    Name NVARCHAR(100) NOT NULL,
    Address NVARCHAR(250) NOT NULL,
    City NVARCHAR(100) NULL,
    PricePerHour DECIMAL(10,2) NOT NULL,
    Description NVARCHAR(MAX) NULL,
    IsActive BIT DEFAULT 1,
    CreatedAt DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Fields_Users
        FOREIGN KEY (OwnerId) REFERENCES Users(Id)
);

CREATE TABLE FieldImages (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FieldId INT NOT NULL,
    ImageUrl NVARCHAR(MAX) NOT NULL,
    IsMain BIT DEFAULT 0,

    CONSTRAINT FK_FieldImages_Fields
        FOREIGN KEY (FieldId) REFERENCES Fields(Id)
);

CREATE TABLE TimeSlots (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    FieldId INT NOT NULL,
    SlotTime NVARCHAR(20) NOT NULL,
    IsActive BIT DEFAULT 1,

    CONSTRAINT FK_TimeSlots_Fields
        FOREIGN KEY (FieldId) REFERENCES Fields(Id)
);

CREATE TABLE Bookings (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    PlayerId INT NOT NULL,
    FieldId INT NOT NULL,
    BookingDate DATE NOT NULL,
    DayName NVARCHAR(20) NOT NULL, 
    SlotTime NVARCHAR(20) NOT NULL, 
    TotalPrice DECIMAL(10,2) NOT NULL,
    Status NVARCHAR(30) DEFAULT 'Pending',
    CreatedAt DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_Bookings_Users
        FOREIGN KEY (PlayerId) REFERENCES Users(Id),

    CONSTRAINT FK_Bookings_Fields
        FOREIGN KEY (FieldId) REFERENCES Fields(Id)
);
CREATE TABLE FavoriteFields (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    UserId INT NOT NULL,
    FieldId INT NOT NULL,
    CreatedAt DATETIME2 DEFAULT GETDATE(),

    CONSTRAINT FK_FavoriteFields_Users
        FOREIGN KEY (UserId) REFERENCES Users(Id),

    CONSTRAINT FK_FavoriteFields_Fields
        FOREIGN KEY (FieldId) REFERENCES Fields(Id),

    CONSTRAINT UQ_FavoriteFields_User_Field
        UNIQUE (UserId, FieldId)
);
CREATE TABLE Payments (
    Id INT IDENTITY(1,1) PRIMARY KEY,
    BookingId INT NOT NULL UNIQUE,
    Amount DECIMAL(10,2) NOT NULL,
    PaymentMethod NVARCHAR(50) NOT NULL,
    Status NVARCHAR(30) DEFAULT 'Pending',
    PaidAt DATETIME2 NULL,

    CONSTRAINT FK_Payments_Bookings
        FOREIGN KEY (BookingId) REFERENCES Bookings(Id)
);

