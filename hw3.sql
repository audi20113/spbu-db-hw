CREATE TABLE IF NOT EXISTS employees (
    employee_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    position VARCHAR(50) NOT NULL,
    department VARCHAR(50) NOT NULL,
    salary NUMERIC(10, 2) NOT NULL,
    manager_id INT REFERENCES employees(employee_id)
);

INSERT INTO employees (name, position, department, salary, manager_id)
VALUES
    ('Alice Johnson', 'Manager', 'Sales', 85000, NULL),
    ('Bob Smith', 'Sales Associate', 'Sales', 50000, 1),
    ('Carol Lee', 'Sales Associate', 'Sales', 48000, 1),
    ('David Brown', 'Sales Intern', 'Sales', 30000, 2),
    ('Eve Davis', 'Developer', 'IT', 75000, NULL),
    ('Frank Miller', 'Intern', 'IT', 35000, 5);

CREATE TABLE IF NOT EXISTS sales (
    sale_id SERIAL PRIMARY KEY,
    employee_id INT REFERENCES employees(employee_id),
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    sale_date DATE NOT NULL
);

INSERT INTO sales (employee_id, product_id, quantity, sale_date)
VALUES
    (2, 1, 20, '2024-11-10'),
    (2, 2, 15, '2024-11-11'),
    (3, 1, 12, '2024-11-12'),
    (4, 3, 8, '2024-11-14'),
    (2, 1, 18, '2024-11-15'),
    (3, 2, 5, '2024-11-16');

CREATE TABLE IF NOT EXISTS products (
    product_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL,
    price NUMERIC(10, 2) NOT NULL
);

INSERT INTO products (name, price)
VALUES
    ('Product A', 150.00),
    ('Product B', 200.00),
    ('Product C', 100.00);
   
   
   
-- ДЗ 3 Пункт 1
CREATE TEMP TABLE high_sales_products AS
SELECT 
    s.product_id, 
    p.name AS product_name, 
    SUM(s.quantity) AS total_quantity
FROM sales s
JOIN products p ON s.product_id = p.product_id
WHERE s.sale_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY s.product_id, p.name
HAVING SUM(s.quantity) > 10;



-- ДЗ 3 Пункт 2
WITH employee_sales_stats AS (
    SELECT 
        e.employee_id, 
        e.name, 
        SUM(s.quantity) AS total_sales,
        AVG(s.quantity) AS avg_sales
    FROM employees e
    JOIN sales s ON e.employee_id = s.employee_id
    WHERE s.sale_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY e.employee_id, e.name
)
SELECT 
    employee_id, 
    name, 
    total_sales
FROM employee_sales_stats
WHERE total_sales > (
    SELECT AVG(total_sales) FROM employee_sales_stats
);



-- ДЗ 3 Пункт 3
-- Иерархическая структура сотрудников с помощью рекурсивного CTE
WITH RECURSIVE employee_hierarchy AS (
    -- Выбираем всех менеджеров, начиная с конкретного менеджера
    SELECT 
        employee_id,
        name,
        position,
        manager_id,
        1 AS level
    FROM employees
    WHERE name = 'Alice Johnson'

    UNION ALL

    -- Выбираем сотрудников, подчиненных найденным выше сотрудникам
    SELECT 
        e.employee_id,
        e.name,
        e.position,
        e.manager_id,
        eh.level + 1 AS level
    FROM employees e
    JOIN employee_hierarchy eh ON e.manager_id = eh.employee_id
)
-- Вывод
SELECT 
    employee_id, 
    name, 
    position, 
    manager_id, 
    level
FROM employee_hierarchy
ORDER BY level, name;



-- ДЗ 3 Пункт 4 
-- Используем CTE для вычисления топ-3 продуктов по продажам за текущий и прошлый месяцы
WITH monthly_sales AS (
    SELECT 
        product_id, 
        SUM(quantity) AS total_sales,
        CASE 
            WHEN date_part('month', sale_date) = date_part('month', CURRENT_DATE) 
                 AND date_part('year', sale_date) = date_part('year', CURRENT_DATE) 
            THEN 'Current Month'
            WHEN date_part('month', sale_date) = date_part('month', CURRENT_DATE - INTERVAL '1 month')
                 AND date_part('year', sale_date) = date_part('year', CURRENT_DATE - INTERVAL '1 month')
            THEN 'Previous Month'
        END AS sales_month
    FROM sales
    WHERE date_part('month', sale_date) = date_part('month', CURRENT_DATE) 
          OR date_part('month', sale_date) = date_part('month', CURRENT_DATE - INTERVAL '1 month')
    GROUP BY product_id, sales_month
)
-- Теперь выбираем топ-3 продуктов по продажам для каждого месяца
SELECT 
    ms.product_id, 
    p.name AS product_name, 
    ms.total_sales, 
    ms.sales_month
FROM monthly_sales ms
JOIN products p ON ms.product_id = p.product_id
ORDER BY ms.sales_month, ms.total_sales DESC
LIMIT 6;



--ДЗ 3 Пункт 5
-- Создание составного индекса по полям employee_id и sale_date
CREATE INDEX idx_employee_sale_date ON sales(employee_id, sale_date);

EXPLAIN ANALYZE
SELECT 
    employee_id, 
    product_id, 
    quantity, 
    sale_date 
FROM sales
WHERE employee_id = 2 
  AND sale_date BETWEEN '2024-11-01' AND '2024-11-30';
--Вывод: Запрос использует последовательное сканирование, так как таблица мала и индекс не дал бы прироста скорости. Планирование заняло больше времени, чем выполнение.

 
 
 --ДЗ 3 Пункт 6
EXPLAIN ANALYZE
SELECT 
    product_id, 
    SUM(quantity) AS total_quantity
FROM sales
GROUP BY product_id;
--Вывод: Запрос использует HashAggregate для группировки, что эффективно при небольших объемах данных. Последовательное сканирование (Seq Scan) быстро находит строки. Планирование и выполнение заняли очень мало времени (0.041 мс), что говорит о высокой производительности для текущего объема данных.