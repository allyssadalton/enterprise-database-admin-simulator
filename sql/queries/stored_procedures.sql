-- Enterprise Database Admin Simulator: Stored Procedures
-- Handles bag management, notifications, and flight operations

DELIMITER //

-- 1. Add a New Bag and Add to Manifest
CREATE PROCEDURE AddBag(
    IN p_passenger_id INT,
    IN p_flight_id INT,
    IN p_bag_type ENUM('checked', 'carry-on'),
    IN p_weight DECIMAL(5,2)
)
BEGIN
    INSERT INTO Bags(passenger_id, flight_id, type, weight, status, location)
    VALUES (p_passenger_id, p_flight_id, p_bag_type, p_weight, 'checked-in', 'Check-in Desk');

    SET @last_bag_id = LAST_INSERT_ID();

    INSERT INTO FlightManifest(flight_id, passenger_id, bag_id)
    VALUES (p_flight_id, p_passenger_id, @last_bag_id);
END //

-- 2. Update Bag Status and Location
CREATE PROCEDURE UpdateBagStatus(
    IN p_bag_id INT,
    IN p_new_status ENUM('checked-in', 'security', 'loaded', 'in-transit', 'at-carousel', 'unclaimed', 'picked-up'),
    IN p_new_location VARCHAR(50)
)
BEGIN
    UPDATE Bags
    SET status = p_new_status,
        location = p_new_location
    WHERE bag_id = p_bag_id;
END //

-- 3. Retrieve All Bags for a Passenger
CREATE PROCEDURE GetPassengerBags(
    IN p_passenger_id INT
)
BEGIN
    SELECT b.bag_id, b.type, b.status, b.location, f.flight_number, f.departure_time, f.arrival_time
    FROM Bags b
    JOIN Flights f ON b.flight_id = f.flight_id
    WHERE b.passenger_id = p_passenger_id;
END //

-- 4. Send Notification to User
CREATE PROCEDURE SendBagNotification(
    IN p_user_id INT,
    IN p_bag_id INT,
    IN p_message TEXT
)
BEGIN
    INSERT INTO Notifications(user_id, bag_id, message)
    VALUES (p_user_id, p_bag_id, p_message);
END //

-- 5. Retrieve All Notifications for a User
CREATE PROCEDURE GetUserNotifications(
    IN p_user_id INT
)
BEGIN
    SELECT notification_id, bag_id, message, sent_at, read
    FROM Notifications
    WHERE user_id = p_user_id
    ORDER BY sent_at DESC;
END //

-- 6. Mark Notification as Read
CREATE PROCEDURE MarkNotificationRead(
    IN p_notification_id INT
)
BEGIN
    UPDATE Notifications
    SET read = TRUE
    WHERE notification_id = p_notification_id;
END //

-- 7. Get Unclaimed Bags (at carousel or past pick-up)
CREATE PROCEDURE GetUnclaimedBags()
BEGIN
    SELECT b.bag_id, u.username AS passenger, f.flight_number, b.location, b.status
    FROM Bags b
    JOIN Users u ON b.passenger_id = u.user_id
    JOIN Flights f ON b.flight_id = f.flight_id
    WHERE b.status = 'at-carousel' OR b.status = 'unclaimed';
END //

-- 8. Load Bag onto Plane (change status to loaded)
CREATE PROCEDURE LoadBagOntoPlane(
    IN p_bag_id INT
)
BEGIN
    UPDATE Bags
    SET status = 'loaded',
        location = 'In Plane Cargo Hold'
    WHERE bag_id = p_bag_id;
END //

-- 9. Unload Bag from Plane (change status to at-carousel)
CREATE PROCEDURE UnloadBagFromPlane(
    IN p_bag_id INT
)
BEGIN
    UPDATE Bags
    SET status = 'at-carousel',
        location = 'Baggage Carousel'
    WHERE bag_id = p_bag_id;
END //

-- 10. Pick Up Bag (passenger collects bag)
CREATE PROCEDURE PickUpBag(
    IN p_bag_id INT
)
BEGIN
    UPDATE Bags
    SET status = 'picked-up',
        location = 'Collected by Passenger'
    WHERE bag_id = p_bag_id;
END //

-- 11. Assign Flight to Bag (if changing flights)
CREATE PROCEDURE AssignBagToFlight(
    IN p_bag_id INT,
    IN p_flight_id INT
)
BEGIN
    UPDATE Bags
    SET flight_id = p_flight_id
    WHERE bag_id = p_bag_id;

    -- Update manifest
    UPDATE FlightManifest
    SET flight_id = p_flight_id
    WHERE bag_id = p_bag_id;
END //

-- 12. Retrieve Flight Manifest
CREATE PROCEDURE GetFlightManifest(
    IN p_flight_id INT
)
BEGIN
    SELECT fm.manifest_id, u.username AS passenger, b.bag_id, b.type, b.status
    FROM FlightManifest fm
    JOIN Users u ON fm.passenger_id = u.user_id
    JOIN Bags b ON fm.bag_id = b.bag_id
    WHERE fm.flight_id = p_flight_id;
END //

DELIMITER ;
