-- 1) Создать триггеры со всеми возможными ключевыми словами, а также рассмотреть операционные триггеры

-- 1. Создание триггеров с разными ключевыми словами
-- 1.1 BEFORE INSERT: проверка минимальной зарплаты
CREATE OR REPLACE FUNCTION before_insert_salary_check()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.salary < 25000 THEN
        RAISE EXCEPTION 'Зарплата должна быть больше минимальной';
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_insert_salary_check_trigger
BEFORE INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION before_insert_salary_check();


-- 1.2. AFTER UPDATE: логирование изменений зарплаты
CREATE OR REPLACE FUNCTION after_update_salary_log()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Зарплата обновлена с % на % для сотрудника: %',
                 OLD.salary, NEW.salary, NEW.name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_salary_log_trigger
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION after_update_salary_log();


-- 1.3. INSTEAD OF DELETE: замена операции удаления
-- Сначала создадим представление
CREATE VIEW employees_view AS
SELECT employee_id, name, position, department, salary
FROM employees;

-- Функция для архивации данных
CREATE OR REPLACE FUNCTION instead_of_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employees_archive (employee_id, name, position, department, salary)
    VALUES (OLD.employee_id, OLD.name, OLD.position, OLD.department, OLD.salary);
    RETURN NULL;  -- Не выполняем DELETE, вместо этого делаем вставку в архив
END;
$$ LANGUAGE plpgsql;

-- Триггер на представление
CREATE TRIGGER instead_of_delete_trigger
INSTEAD OF DELETE ON employees_view
FOR EACH ROW
EXECUTE FUNCTION instead_of_delete();


--1.4. Пример триггера с FOR EACH STATEMENT
CREATE OR REPLACE FUNCTION statement_trigger_example()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Произведено удаление сотрудников';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER statement_trigger
AFTER DELETE ON employees
FOR EACH STATEMENT
EXECUTE FUNCTION statement_trigger_example();



-- 2. Операционные триггеры

--2.1. BEFORE DELETE: архивирование данных перед удалением
CREATE OR REPLACE FUNCTION archive_employee()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO employees_archive (employee_id, name, position, department, salary)
    VALUES (OLD.employee_id, OLD.name, OLD.position, OLD.department, OLD.salary);
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_archive_employee
BEFORE DELETE ON employees
FOR EACH ROW
EXECUTE FUNCTION archive_employee();


--2.2. AFTER INSERT: логирование добавленных сотрудников
CREATE OR REPLACE FUNCTION after_insert_log()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Новый сотрудник добавлен: %', NEW.name;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_employee_log
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION after_insert_log();



-- 2) Попрактиковаться в созданиях транзакций (привести пример успешной и фейл транзакции, объяснить в комментариях почему она зафейлилась)
-- Пример успешной транзакции
-- Начинаем транзакцию
BEGIN;
-- Выполняем несколько операций внутри транзакции
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('John Doe', 'Developer', 'IT', 70000, NULL);
-- Увеличиваем зарплату уже существующему сотруднику
UPDATE employees
SET salary = salary + 5000
WHERE employee_id = 2;  -- Предположим, что employee_id = 2 существует в таблице employees
-- Подтверждаем транзакцию, все изменения сохраняются
COMMIT;



-- Пример фейловой транзакции
-- Начинаем транзакцию
BEGIN;
-- Выполняем несколько операций внутри транзакции
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('John Doe', 'Developer', 'IT', 70000, NULL);
-- Попытка вставить сотрудника с уже существующим ID
-- Предположим, что employee_id = 1 уже существует в таблице employees
INSERT INTO employees (employee_id, name, position, department, salary, manager_id)
VALUES (1, 'Jane Doe', 'Manager', 'Sales', 90000, NULL);
-- Ошибка на второй вставке: нарушение ограничения уникальности на поле employee_id
-- Откатываем транзакцию, так как произошла ошибка
ROLLBACK;


-- Вывод
-- Успешная транзакция: Все операции выполняются корректно, и результаты сохраняются с помощью команды COMMIT.
-- Фейловая транзакция: Ошибка возникает из-за нарушения ограничения уникальности (вставка с уже существующим employee_id). В результате вся транзакция откатывается с помощью команды ROLLBACK, и никакие изменения не сохраняются в базе.



-- 3) Попробовать использовать RAISE внутри триггеров для логирования
-- 3.1: Создание функции для логирования
-- Пример функции для логирования вставки данных:
CREATE OR REPLACE FUNCTION log_insert_employee()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Вставлен новый сотрудник: ID = %, Name = %, Position = %, Salary = %',
                 NEW.employee_id, NEW.name, NEW.position, NEW.salary;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Пример функции для логирования обновления данных:
CREATE OR REPLACE FUNCTION log_update_employee()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Обновлены данные сотрудника: ID = %, старое значение зарплаты = %, новое значение зарплаты = %',
                 OLD.employee_id, OLD.salary, NEW.salary;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;


-- 3.2: Создание триггеров
-- Триггер для вставки:
CREATE TRIGGER trigger_log_insert_employee
AFTER INSERT ON employees
FOR EACH ROW
EXECUTE FUNCTION log_insert_employee();

-- Триггер для обновления:
CREATE TRIGGER trigger_log_update_employee
AFTER UPDATE ON employees
FOR EACH ROW
WHEN (OLD.salary IS DISTINCT FROM NEW.salary)
EXECUTE FUNCTION log_update_employee();


-- 3.3: Пример работы с триггерами
-- Вставка нового сотрудника:
INSERT INTO employees (name, position, department, salary, manager_id)
VALUES ('John Doe', 'Developer', 'IT', 70000, NULL);

-- Обновление зарплаты сотрудника:
UPDATE employees
SET salary = 75000
WHERE name = 'John Doe';

