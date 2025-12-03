-- Airline Baggage Management Database Schema

-- Users Table (Employees & Passengers)
CREATE TABLE Users (
    user_id SERIAL PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE,
    role ENUM('employee', 'passenger') NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Flights Table
CREATE TABLE Flights (
    flight_id SERIAL PRIMARY KEY,
    flight_number VARCHAR(10) NOT NULL,
    departure_place VARCHAR(100) NOT NULL,
    arrival_place VARCHAR(100) NOT NULL,
    departure_time TIMESTAMP NOT NULL,
    arrival_time TIMESTAMP NOT NULL,
    plane_type VARCHAR(50),
    capacity INT,
    status ENUM('on-time', 'delayed', 'cancelled') DEFAULT 'on-time'
);

-- Bags Table
CREATE TABLE Bags (
    bag_id SERIAL PRIMARY KEY,
    passenger_id INT REFERENCES Users(user_id),
    flight_id INT REFERENCES Flights(flight_id),
    weight DECIMAL(5,2),
    type ENUM('checked', 'carry-on') NOT NULL,
    status ENUM('checked-in', 'security', 'loaded', 'in-transit', 'at-carousel', 'unclaimed', 'picked-up') DEFAULT 'checked-in',
    location VARCHAR(50),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Flight Manifest Table
CREATE TABLE FlightManifest (
    manifest_id SERIAL PRIMARY KEY,
    flight_id INT REFERENCES Flights(flight_id),
    passenger_id INT REFERENCES Users(user_id),
    bag_id INT REFERENCES Bags(bag_id)
);

-- Notifications Table
CREATE TABLE Notifications (
    notification_id SERIAL PRIMARY KEY,
    user_id INT REFERENCES Users(user_id),
    bag_id INT REFERENCES Bags(bag_id),
    message TEXT NOT NULL,
    sent_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    read BOOLEAN DEFAULT FALSE
);
