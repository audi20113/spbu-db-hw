CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(100) NOT NULL,
    genre VARCHAR(100),
    duration INT NOT NULL,
    release_date DATE
);

CREATE TABLE halls (
    hall_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    total_seats SMALLINT NOT NULL
);

CREATE TABLE showtimes (
    showtime_id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES movies(movie_id),
    hall_id INT REFERENCES halls(hall_id),
    show_date TIMESTAMP NOT NULL,
    available_seats SMALLINT NOT NULL,
    CONSTRAINT fk_showtimes_movies FOREIGN KEY (movie_id) REFERENCES movies(movie_id),
    CONSTRAINT fk_showtimes_halls FOREIGN KEY (hall_id) REFERENCES halls(hall_id)
);

CREATE TABLE tickets (
    ticket_id SERIAL PRIMARY KEY,
    showtime_id INT NOT NULL REFERENCES showtimes(showtime_id),
    customer_name VARCHAR(255),
    seat_number INT NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT unique_ticket UNIQUE (showtime_id, seat_number),
    CONSTRAINT fk_ticket_showtime FOREIGN KEY (showtime_id) REFERENCES showtimes(showtime_id)
);

CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_showtimes_movie_id ON showtimes(movie_id);
CREATE INDEX idx_showtimes_hall_id ON showtimes(hall_id);
CREATE INDEX idx_showtimes_show_date ON showtimes(show_date);
CREATE INDEX idx_tickets_showtime_id ON tickets(showtime_id);
CREATE INDEX idx_tickets_customer_name ON tickets(customer_name);

INSERT INTO movies (title, genre, duration, release_date)
VALUES
    ('The Shawshank Redemption', 'Drama', 142, '1994-09-22'),
    ('The Dark Knight', 'Action', 152, '2008-07-18'),
    ('Pulp Fiction', 'Crime', 154, '1994-10-14'),
    ('Forrest Gump', 'Drama', 142, '1994-07-06'),
    ('Inception', 'Sci-Fi', 148, '2010-07-16'),
    ('The Matrix', 'Sci-Fi', 136, '1999-03-31'),
    ('Titanic', 'Romance', 195, '1997-12-19'),
    ('The Godfather', 'Crime', 175, '1972-03-24'),
    ('The Lord of the Rings: The Fellowship of the Ring', 'Fantasy', 178, '2001-12-19'),
    ('Gladiator', 'Action', 155, '2000-05-05');

INSERT INTO halls (name, total_seats)
VALUES
    ('Hall 1', 150),
    ('Hall 2', 120),
    ('Hall 3', 80),
    ('Hall 4', 200),
    ('Hall 5', 100),
    ('Hall 6', 110),
    ('Hall 7', 130),
    ('Hall 8', 140),
    ('Hall 9', 160),
    ('Hall 10', 90);

INSERT INTO showtimes (movie_id, hall_id, show_date, available_seats)
VALUES
    (1, 1, '2024-12-01 18:00:00', 150),
    (2, 2, '2024-12-01 20:30:00', 120),
    (3, 3, '2024-12-02 19:00:00', 80),
    (4, 4, '2024-12-02 21:00:00', 200),
    (5, 5, '2024-12-03 17:00:00', 100),
    (6, 6, '2024-12-03 19:30:00', 110),
    (7, 7, '2024-12-04 18:00:00', 130),
    (8, 8, '2024-12-04 20:30:00', 140),
    (9, 9, '2024-12-05 18:00:00', 160),
    (10, 10, '2024-12-05 21:00:00', 90);

INSERT INTO tickets (showtime_id, customer_name, seat_number)
VALUES
    (1, 'Boris Zakatov', 1),
    (1, 'Alex Ivanov', 2),
    (2, 'Alice Bolgar', 3),
    (3, 'Ivan Borisov', 4),
    (4, 'Vadim Karpov', 5),
    (5, 'Vera Romanova', 6),
    (6, 'Dmitry Denisov', 7),
    (7, 'David Goncharov', 8),
    (8, 'Konstantin Kolesnikov', 9),
    (9, 'Vladimir Nazarov', 10),
    (1, 'Maria Petrova', 15),
    (1, 'Igor Vasiliev', 16),
    (1, 'Olga Tarasova', 17),
    (10, 'Denis Sokolov', 18),
    (9, 'Sergei Smirnov', 19),
    (2, 'Natalia Ivanova', 20),
    (10, 'Pavel Rudenko', 21),
    (2, 'Viktor Lysenko', 22),
    (6, 'Elena Kuznetsova', 23),
    (2, 'Anastasia Baranova', 24),
    (8, 'Roman Karpov', 25),
    (3, 'Svetlana Pavlova', 26),
    (3, 'Mikhail Sushchenko', 27),
    (7, 'Vadim Belov', 28),
    (3, 'Anna Orlova', 29),
    (4, 'Tatyana Grigorieva', 30),
    (9, 'Alexandr Morozov', 31),
    (9, 'Ksenia Fedorova', 32),
    (4, 'Ilya Sergeev', 33),
    (10, 'Oleg Antonov', 34),
    (9, 'Vera Dovgan', 35),
    (5, 'Denis Krutov', 36),
    (5, 'Ekaterina Makarova', 37),
    (10, 'Sergey Pakhomov', 38),
    (5, 'Nikita Likhachev', 39),
    (6, 'Vladimir Ryzhov', 40),
    (8, 'Daria Frolova', 41),
    (6, 'Elena Vinnichenko', 42),
    (6, 'Vladislav Melnikov', 43),
    (8, 'Irina Karpova', 44),
    (7, 'Dmitry Sokolov', 45),
    (10, 'Yulia Kazakova', 46),
    (7, 'Maxim Sorokin', 47),
    (9, 'Natalia Ponomarenko', 48),
    (8, 'Anastasia Zheltukhina', 49),
    (8, 'Svetlana Guseva', 50);
    
-- 1. Временные структуры
-- 1.1 Создание временной таблицы для фильмов в определённый день
CREATE TEMP TABLE temp_showing_movies AS
SELECT
    m.movie_id,
    m.title,
    m.genre,
    m.duration,
    m.release_date,
    s.show_date,
    s.available_seats
FROM
    movies m
JOIN
    showtimes s ON m.movie_id = s.movie_id
WHERE
    s.show_date::DATE = '2024-12-01'  -- Пример для фильмов на 1 декабря
LIMIT 10;

-- Создание индекса для ускорения поиска по `show_date`
CREATE INDEX idx_temp_showing_movies_show_date ON temp_showing_movies (show_date);

-- 1.2 Создание временной таблицы для клиентов и их билетов
CREATE TEMP TABLE temp_customers_tickets AS
SELECT
    t.ticket_id,
    t.customer_name,
    t.seat_number,
    s.show_date,
    m.title AS movie_title
FROM
    tickets t
JOIN
    showtimes s ON t.showtime_id = s.showtime_id
JOIN
    movies m ON s.movie_id = m.movie_id
WHERE
    s.show_date::DATE = '2024-12-01'  -- Пример для билетов на 1 декабря
LIMIT 10;

-- Создание индекса для ускорения поиска по `ticket_id`
CREATE INDEX idx_temp_customers_tickets_ticket_id ON temp_customers_tickets (ticket_id);

-- 2. Временные представления
-- 2.1 Представление для статистики по проданным билетам (по дням)
CREATE VIEW daily_ticket_sales AS
SELECT
    DATE(st.show_date) AS show_date,
    COUNT(t.ticket_id) AS tickets_sold
FROM tickets t
JOIN showtimes st ON t.showtime_id = st.showtime_id
GROUP BY DATE(st.show_date)
ORDER BY show_date
LIMIT 10;

-- 2.2 Представление для самых популярных фильмов по количеству проданных билетов
CREATE VIEW popular_movies AS
SELECT
    m.title AS movie_title,
    COUNT(t.ticket_id) AS tickets_sold
FROM tickets t
JOIN showtimes st ON t.showtime_id = st.showtime_id
JOIN movies m ON st.movie_id = m.movie_id
GROUP BY m.title
ORDER BY tickets_sold DESC
LIMIT 5;

-- 3. Способ валидации запросов (логирование)
-- Таблица для логирования
CREATE TABLE logs (
    log_id SERIAL PRIMARY KEY,
    query_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,  -- Время запроса
    query_text TEXT NOT NULL,                        -- SQL-запрос
    user_id INT,                                    -- Идентификатор пользователя (если нужно)
    session_id UUID DEFAULT gen_random_uuid(),       -- Идентификатор сессии (если нужно)
    success BOOLEAN,                                 -- Успешность выполнения
    error_message TEXT,                              -- Сообщение об ошибке (если запрос не успешен)
    execution_time FLOAT                             -- Время выполнения запроса (в миллисекундах)
);

-- 3.1 Логирование успешных запросов
INSERT INTO logs (query_text, success, execution_time)
VALUES 
    ('INSERT INTO movies (title, genre, duration, release_date) VALUES (''Inception'', ''Sci-Fi'', 148, ''2010-07-16'')', TRUE, 5.12);

-- 3.2 Логирование запросов с EXPLAIN ANALYZE
DO $$ 
DECLARE
    explain_result TEXT;
BEGIN
    EXECUTE 'EXPLAIN ANALYZE SELECT * FROM movies WHERE genre = ''Action''' INTO explain_result;

    INSERT INTO logs (query_text, success, error_message, execution_time)
    VALUES 
        ('EXPLAIN ANALYZE SELECT * FROM movies WHERE genre = ''Action''', TRUE, explain_result, 0.45);
END;
$$;

-- 4. Способ валидации запросов (трассировка)
-- 4.1 Трассировка запросов с использованием EXPLAIN и EXPLAIN ANALYZE
EXPLAIN ANALYZE
SELECT 
    s.showtime_id,
    m.title,
    h.name AS hall_name,
    s.show_date,
    s.available_seats
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
WHERE m.title = 'The Dark Knight'
  AND s.show_date BETWEEN '2024-12-01' AND '2024-12-31'
ORDER BY s.show_date
LIMIT 10;

-- Пример для запроса с агрегацией по фильмам:
EXPLAIN ANALYZE
SELECT 
    m.title, 
    COUNT(t.ticket_id) AS total_tickets
FROM movies m
JOIN showtimes s ON m.movie_id = s.movie_id
JOIN tickets t ON s.showtime_id = t.showtime_id
GROUP BY m.title
ORDER BY total_tickets DESC
LIMIT 10;

-- 4.2 Использование индексов для оптимизации запросов
EXPLAIN ANALYZE
SELECT 
    t.ticket_id, 
    t.seat_number, 
    t.booking_time
FROM tickets t
WHERE t.customer_name = 'Boris Zakatov'
LIMIT 10;

-- 4.3 Использование EXPLAIN для анализа выполнения JOIN операций
EXPLAIN ANALYZE
SELECT 
    m.title, 
    h.name AS hall_name, 
    COUNT(t.ticket_id) AS total_tickets
FROM movies m
JOIN showtimes s ON m.movie_id = s.movie_id
JOIN halls h ON s.hall_id = h.hall_id
JOIN tickets t ON s.showtime_id = t.showtime_id
GROUP BY m.title, h.name
ORDER BY total_tickets DESC
LIMIT 10;

-- 4.4 Пример трассировки с использованием EXPLAIN для подсчета количества сеансов
EXPLAIN ANALYZE
SELECT 
    m.title,
    COUNT(s.showtime_id) AS total_showtimes,
    h.name AS hall_name
FROM movies m
JOIN showtimes s ON m.movie_id = s.movie_id
JOIN halls h ON s.hall_id = h.hall_id
GROUP BY m.title, h.name
ORDER BY total_showtimes DESC
LIMIT 10;
