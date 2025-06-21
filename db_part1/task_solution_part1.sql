/*Задача 1
*/

SELECT v.maker, v.model
FROM Vehicle v
JOIN Motorcycle m ON v.model = m.model
WHERE v.type = 'Motorcycle'
  AND m.horsepower > 150
  AND m.price < 20000
  AND m.type = 'Sport'
ORDER BY m.horsepower DESC;

/*Задача 2
*/
(
    SELECT v.maker, c.model, c.horsepower, c.engine_capacity, 'Car' AS type
    FROM Vehicle v
    JOIN Car c ON v.model = c.model
    WHERE v.type = 'Car'
      AND c.horsepower > 150
      AND c.engine_capacity < 3
      AND c.price < 35000
)
UNION ALL
(
    SELECT v.maker, m.model, m.horsepower, m.engine_capacity, 'Motorcycle' AS type
    FROM Vehicle v
    JOIN Motorcycle m ON v.model = m.model
    WHERE v.type = 'Motorcycle'
      AND m.horsepower > 150
      AND m.engine_capacity < 1.5
      AND m.price < 20000
)
UNION ALL
(
    SELECT v.maker, b.model, NULL AS horsepower, NULL AS engine_capacity, 'Bicycle' AS type
    FROM Vehicle v
    JOIN Bicycle b ON v.model = b.model
    WHERE v.type = 'Bicycle'
      AND b.gear_count > 18
      AND b.price < 4000
)
ORDER BY horsepower DESC;