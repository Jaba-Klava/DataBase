/*
Задача 1
*/
SELECT
    c.name,
    c.email,
    c.phone,
    COUNT(b.ID_booking) AS total_bookings,
    STRING_AGG(DISTINCT h.name, ', ') AS hotel_list,
    ROUND(AVG(b.check_out_date - b.check_in_date), 4) AS avg_stay_duration
FROM Booking b
JOIN Customer c ON b.ID_customer = c.ID_customer
JOIN Room r ON b.ID_room = r.ID_room
JOIN Hotel h ON r.ID_hotel = h.ID_hotel
GROUP BY c.ID_customer
HAVING COUNT(DISTINCT h.ID_hotel) > 1  AND COUNT(b.ID_booking) >= 3
ORDER BY total_bookings DESC;

/*
Задача 2
*/
WITH ClientBookings AS (
    SELECT
        c.ID_customer,
        c.name,
        COUNT(b.ID_booking) AS total_bookings,
        COUNT(DISTINCT h.ID_hotel) AS unique_hotels,
        SUM(r.price) AS total_spent
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    GROUP BY c.ID_customer, c.name
    HAVING COUNT(b.ID_booking) > 2 AND COUNT(DISTINCT h.ID_hotel) > 1
),
ClientSpentMoreThan500 AS (
    SELECT
        c.ID_customer,
        c.name,
        SUM(r.price) AS total_spent,
        COUNT(b.ID_booking) AS total_bookings
    FROM Booking b
    JOIN Customer c ON b.ID_customer = c.ID_customer
    JOIN Room r ON b.ID_room = r.ID_room
    GROUP BY c.ID_customer, c.name
    HAVING SUM(r.price) > 500
)

SELECT
    cb.ID_customer,
    cb.name,
    cb.total_bookings,
    cb.total_spent,
    cb.unique_hotels
FROM ClientBookings cb
JOIN ClientSpentMoreThan500 csm ON cb.ID_customer = csm.ID_customer
ORDER BY cb.total_spent ASC;

/*
Задача 3
*/
WITH HotelCategories AS (
    SELECT
        h.ID_hotel,
        CASE
            WHEN AVG(r.price) < 175 THEN 'Дешевый'
            WHEN AVG(r.price) BETWEEN 175 AND 300 THEN 'Средний'
            WHEN AVG(r.price) > 300 THEN 'Дорогой'
        END AS hotel_category
    FROM Hotel h
    JOIN Room r ON h.ID_hotel = r.ID_hotel
    GROUP BY h.ID_hotel
),
CustomerPreferences AS (
    SELECT
        b.ID_customer,
        MAX(CASE
            WHEN hc.hotel_category = 'Дорогой' THEN 'Дорогой'
            WHEN hc.hotel_category = 'Средний' THEN 'Средний'
            WHEN hc.hotel_category = 'Дешевый' THEN 'Дешевый'
            ELSE NULL
        END) AS preferred_hotel_type,
        STRING_AGG(DISTINCT h.name, ', ') AS visited_hotels
    FROM Booking b
    JOIN Room r ON b.ID_room = r.ID_room
    JOIN Hotel h ON r.ID_hotel = h.ID_hotel
    JOIN HotelCategories hc ON h.ID_hotel = hc.ID_hotel
    GROUP BY b.ID_customer
)

SELECT
    cp.ID_customer,
	c.name,
    cp.preferred_hotel_type,
    cp.visited_hotels
FROM CustomerPreferences cp
JOIN Customer c ON cp.ID_customer = c.ID_customer
ORDER BY
    CASE cp.preferred_hotel_type
        WHEN 'Дешевый' THEN 1
        WHEN 'Средний' THEN 2
        WHEN 'Дорогой' THEN 3
    END;

