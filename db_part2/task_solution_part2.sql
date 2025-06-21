/*
Задача 1
*/
SELECT car_name, car_class, ROUND(average_position,4) AS average_position, race_count
FROM (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        RANK() OVER (PARTITION BY c.class ORDER BY AVG(r.position), c.name) AS rnk
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
) sub
WHERE rnk = 1
ORDER BY average_position, car_name;

/*
Задача 2
*/
SELECT car_name, car_class,ROUND(average_position,4) AS average_position, race_count, car_country
FROM (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count,
        cl.country AS car_country,
        RANK() OVER (ORDER BY AVG(r.position), c.name) AS rnk
    FROM Cars c
    JOIN Results r ON c.name = r.car
    JOIN Classes cl ON c.class = cl.class
    GROUP BY c.name, c.class, cl.country
) sub
WHERE rnk = 1
ORDER BY average_position, car_name;

/*
Задача 3
*/
SELECT
    c.name AS car_name,
    c.class AS car_class,
    ROUND(AVG(r.position), 4) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country,
    total_races.total_races
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
JOIN (
    SELECT
        c.class,
        AVG(r.position) AS class_avg_position,
        COUNT(r.race) AS total_races
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
) total_races ON c.class = total_races.class
WHERE total_races.class_avg_position = (
    SELECT MIN(class_avg)
    FROM (
        SELECT AVG(r.position) AS class_avg
        FROM Cars c
        JOIN Results r ON c.name = r.car
        GROUP BY c.class
    ) AS min_class_avg
)
GROUP BY
    c.name,
    c.class,
    cl.country,
    total_races.total_races
ORDER BY
    c.name;

/*
Задача 4
*/
SELECT
    c.name AS car_name,
    c.class AS car_class,
    ROUND(AVG(r.position), 4) AS average_position,
    COUNT(r.race) AS race_count,
    cl.country AS car_country
FROM Cars c
JOIN Results r ON c.name = r.car
JOIN Classes cl ON c.class = cl.class
JOIN (
    SELECT
        c.class,
        AVG(r.position) AS class_avg,
        COUNT(DISTINCT c.name) AS car_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
    HAVING COUNT(DISTINCT c.name) >= 2
) class_stats ON c.class = class_stats.class
GROUP BY
    c.name,
    c.class,
    cl.country,
    class_stats.class_avg,
    class_stats.car_count
HAVING AVG(r.position) < class_stats.class_avg
ORDER BY
    c.class,
    average_position;

/*
Задача 5
*/
WITH CarAverages AS (
    SELECT
        c.name AS car_name,
        c.class AS car_class,
        AVG(r.position) AS average_position,
        COUNT(r.race) AS race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.name, c.class
),
LowPositionCars AS (
    SELECT
        ca.car_name,
        ca.car_class,
        ca.average_position,
        ca.race_count
    FROM CarAverages ca
    WHERE ca.average_position > 3.0
),
ClassRaceCounts AS (
    SELECT
        c.class AS car_class,
        COUNT(r.race) AS total_race_count
    FROM Cars c
    JOIN Results r ON c.name = r.car
    GROUP BY c.class
),
ClassLowPositionCounts AS (
    SELECT
        lpc.car_class,
        COUNT(lpc.car_name) AS low_position_count
    FROM LowPositionCars lpc
    GROUP BY lpc.car_class
)
SELECT
    lpc.car_name,
    lpc.car_class,
    ROUND(lpc.average_position, 4) AS average_position,
    lpc.race_count,
    cl.country,
    crc.total_race_count,
    clpc.low_position_count
FROM LowPositionCars lpc
JOIN ClassLowPositionCounts clpc ON lpc.car_class = clpc.car_class
JOIN Classes cl ON lpc.car_class = cl.class
JOIN ClassRaceCounts crc ON lpc.car_class = crc.car_class
ORDER BY clpc.low_position_count DESC, lpc.average_position DESC;