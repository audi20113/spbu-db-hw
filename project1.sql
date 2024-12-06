-- Таблица для фильмов
CREATE TABLE movies (
    movie_id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    genre VARCHAR(100),
    duration INT NOT NULL,
    release_date DATE
);

-- Таблица для залов
CREATE TABLE halls (
    hall_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    total_seats INT NOT NULL
);

-- Таблица для сеансов
CREATE TABLE showtimes (
    showtime_id SERIAL PRIMARY KEY,
    movie_id INT REFERENCES movies(movie_id),
    hall_id INT REFERENCES halls(hall_id),
    show_date TIMESTAMP NOT NULL,
    available_seats INT NOT NULL
);

-- Таблица для билетов
CREATE TABLE tickets (
    ticket_id SERIAL PRIMARY KEY,
    showtime_id INT REFERENCES showtimes(showtime_id),
    customer_name VARCHAR(255),
    seat_number INT NOT NULL,
    booking_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Добавление индексов для улучшения производительности
CREATE INDEX idx_movies_title ON movies(title);
CREATE INDEX idx_showtimes_movie_id ON showtimes(movie_id);
CREATE INDEX idx_showtimes_hall_id ON showtimes(hall_id);
CREATE INDEX idx_tickets_showtime_id ON tickets(showtime_id);

-- Добавление ограничений для целостности данных
-- Ограничение на уникальность имени клиента и номера места (на случай повторных бронирований для одного сеанса и места)
ALTER TABLE tickets ADD CONSTRAINT unique_ticket UNIQUE (showtime_id, seat_number);
-- Ограничение на непустое имя фильма
ALTER TABLE movies ADD CONSTRAINT non_empty_title CHECK (title IS NOT NULL AND title <> '');

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
    (7, 'Anna Stepanova', 48),
    (7, 'Maksim Kolesnikov', 49);
    
-- 1. Простые запросы
-- 1.1 Выбрать все фильмы, которые идут в кинотеатре (выводя название фильма и жанр)
SELECT title, genre FROM movies;

-- 1.2 Выбрать все сеансы для фильма "The Dark Knight":
SELECT s.show_date, h.name AS hall_name, s.available_seats
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
WHERE m.title = 'The Dark Knight';

-- 1.3 Выбрать все билеты, забронированные для фильма "Inception", с указанием имени покупателя и номера места:
SELECT t.customer_name, t.seat_number
FROM tickets t
JOIN showtimes s ON t.showtime_id = s.showtime_id
JOIN movies m ON s.movie_id = m.movie_id
WHERE m.title = 'Inception';


-- 2. Агрегации
-- 2.1 Подсчитать количество билетов, проданных для каждого фильма (по каждому сеансу):
SELECT m.title AS movie_title, s.show_date, COUNT(t.ticket_id) AS tickets_sold
FROM tickets t
JOIN showtimes s ON t.showtime_id = s.showtime_id
JOIN movies m ON s.movie_id = m.movie_id
GROUP BY m.title, s.show_date
ORDER BY s.show_date;

-- 2.2 Подсчитать общее количество проданных билетов по каждому залу:
SELECT h.name AS hall_name, COUNT(t.ticket_id) AS tickets_sold
FROM tickets t
JOIN showtimes s ON t.showtime_id = s.showtime_id
JOIN halls h ON s.hall_id = h.hall_id
GROUP BY h.name
ORDER BY tickets_sold DESC;


-- 3. Усложненные запросы
-- 3.1 Найти фильмы, которые были показаны в зале с самым большим количеством мест:
WITH max_hall AS (
    SELECT MAX(total_seats) AS max_seats
    FROM halls
)
SELECT m.title, h.name AS hall_name, s.show_date
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
WHERE h.total_seats = (SELECT max_seats FROM max_hall);

-- 3.2 Доступные места на сеансе для фильма 'The Matrix
SELECT
    m.title AS movie_title,
    h.name AS hall_name,
    s.show_date,
    h.total_seats - COUNT(t.ticket_id) AS available_seats
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
LEFT JOIN tickets t ON s.showtime_id = t.showtime_id
WHERE m.title = 'The Matrix'
GROUP BY m.title, h.name, s.show_date, h.total_seats;


-- 4. Дополнительные запросы
-- 4.1 Выбрать все фильмы, которые идут в зале с определенным количеством мест (например, 90):
SELECT m.title, h.name AS hall_name, s.show_date
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
WHERE h.total_seats = 90;

-- 4.2 Найти, какие фильмы и в какие залы были показаны в определенное время (например, 2024-12-01 18:00:00):
SELECT m.title, h.name AS hall_name, s.show_date
FROM showtimes s
JOIN movies m ON s.movie_id = m.movie_id
JOIN halls h ON s.hall_id = h.hall_id
WHERE s.show_date = '2024-12-01 18:00:00';




