/*
Задача 1
*/
WITH RECURSIVE Subordinates AS (
    SELECT
        EmployeeID,
        Name,
        ManagerID,
        DepartmentID,
        RoleID
    FROM
        Employees
    WHERE
        ManagerID = 1
    UNION ALL
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM
        Employees e
    INNER JOIN
        Subordinates s ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name,
    s.ManagerID,
    COALESCE(d.DepartmentName, 'NULL') AS Department,
    COALESCE(r.RoleName, 'NULL') AS Role,
    COALESCE((
        SELECT STRING_AGG(p.ProjectName, ', ')
        FROM Projects p
        WHERE p.DepartmentID = s.DepartmentID
    ), 'NULL') AS Projects,
    COALESCE((
        SELECT STRING_AGG(t.TaskName, ', ')
        FROM Tasks t
        WHERE t.AssignedTo = s.EmployeeID
    ), 'NULL') AS Tasks
FROM
    Subordinates s
LEFT JOIN
    Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN
    Roles r ON s.RoleID = r.RoleID
ORDER BY
    s.Name;

/*
Задача 2
*/
WITH RECURSIVE Subordinates AS (
    SELECT
        EmployeeID,
        Name as EmployeeName,
        ManagerID,
        DepartmentID,
        RoleID
    FROM Employees
    WHERE ManagerID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    INNER JOIN Subordinates s
        ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    COALESCE(
        (SELECT STRING_AGG(p.ProjectName, ', ')
         FROM Projects p
         WHERE p.DepartmentID = s.DepartmentID),
        'NULL'
    ) AS ProjectNames,
    COALESCE(
        (SELECT STRING_AGG(t.TaskName, ', ')
         FROM Tasks t
         WHERE t.AssignedTo = s.EmployeeID),
        'NULL'
    ) AS TaskNames,
    (SELECT COUNT(*)
     FROM Tasks t
     WHERE t.AssignedTo = s.EmployeeID) AS TotalTasks,

    (SELECT COUNT(*)
     FROM Employees e
     WHERE e.ManagerID = s.EmployeeID) AS TotalSubordinates
FROM Subordinates s
LEFT JOIN Departments d
    ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r
    ON s.RoleID = r.RoleID
ORDER BY s.EmployeeName;

/*
Задача 3
*/
WITH RECURSIVE ManagerHierarchy AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID,
        e.EmployeeID AS RootManagerID
    FROM
        Employees e
    INNER JOIN
        Roles r ON e.RoleID = r.RoleID
    WHERE
        r.RoleName = 'Менеджер'
        AND EXISTS (
            SELECT 1
            FROM Employees sub
            WHERE sub.ManagerID = e.EmployeeID
        )

    UNION ALL

    SELECT
        sub.EmployeeID,
        sub.Name,
        sub.ManagerID,
        sub.DepartmentID,
        sub.RoleID,
        mh.RootManagerID
    FROM
        Employees sub
    INNER JOIN
        ManagerHierarchy mh
        ON sub.ManagerID = mh.EmployeeID
)
SELECT
    m.RootManagerID AS EmployeeID,
    emp.Name AS EmployeeName,
    emp.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (SELECT STRING_AGG(p.ProjectName, ', ')
     FROM Projects p
     WHERE p.DepartmentID = emp.DepartmentID) AS ProjectNames,
    (SELECT STRING_AGG(t.TaskName, ', ')
     FROM Tasks t
     WHERE t.AssignedTo = emp.EmployeeID) AS TaskNames,
    (SELECT COUNT(*) - 1
     FROM ManagerHierarchy mh_count
     WHERE mh_count.RootManagerID = emp.EmployeeID) AS TotalSubordinates
FROM
    (SELECT DISTINCT RootManagerID FROM ManagerHierarchy) m
INNER JOIN
    Employees emp
    ON m.RootManagerID = emp.EmployeeID
LEFT JOIN
    Departments d
    ON emp.DepartmentID = d.DepartmentID
LEFT JOIN
    Roles r
    ON emp.RoleID = r.RoleID
WHERE
    r.RoleName = 'Менеджер'
ORDER BY
    emp.Name;