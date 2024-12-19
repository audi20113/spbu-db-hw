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
CREATE INDEX idx_movies_release_date ON movies(release_date);
CREATE INDEX idx_halls_name ON halls(name);
CREATE INDEX idx_showtimes_movie_hall_date ON showtimes(movie_id, hall_id, show_date);
CREATE INDEX idx_showtimes_available_seats ON showtimes(available_seats);
CREATE UNIQUE INDEX idx_tickets_showtime_seat ON tickets(showtime_id, seat_number);
CREATE INDEX idx_tickets_customer_name ON tickets(customer_name);
CREATE INDEX idx_tickets_booking_time ON tickets(booking_time);

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
-- 1.1 Функция проверки доступных мест перед добавлением записи
CREATE OR REPLACE FUNCTION check_available_seats()
RETURNS TRIGGER AS $$
BEGIN
    IF (SELECT available_seats FROM showtimes WHERE showtime_id = NEW.showtime_id) <= 0 THEN
        RAISE EXCEPTION 'Нет доступных мест для данного сеанса';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Создание триггера
CREATE TRIGGER before_insert_ticket_check
BEFORE INSERT ON tickets
FOR EACH ROW
EXECUTE FUNCTION check_available_seats();

-- 1.2 Пример триггера AFTER UPDATE
CREATE OR REPLACE FUNCTION after_update_available_seats_log()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Количество доступных мест изменилось с % на % для сеанса с ID: %',
                 OLD.available_seats, NEW.available_seats, NEW.showtime_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_update_available_seats_trigger
AFTER UPDATE ON showtimes
FOR EACH ROW
WHEN (OLD.available_seats IS DISTINCT FROM NEW.available_seats)
EXECUTE FUNCTION after_update_available_seats_log();

-- 1.3 Создание таблицы архива
CREATE TABLE showtimes_archive (
    archive_id SERIAL PRIMARY KEY,
    showtime_id INT NOT NULL,
    movie_id INT NOT NULL,
    hall_id INT NOT NULL,
    show_date TIMESTAMP NOT NULL,
    available_seats SMALLINT NOT NULL,
    archived_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Создание функции для архивации данных вместо удаления
CREATE OR REPLACE FUNCTION archive_showtime_instead_of_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO showtimes_archive (showtime_id, movie_id, hall_id, show_date, available_seats)
    VALUES (OLD.showtime_id, OLD.movie_id, OLD.hall_id, OLD.show_date, OLD.available_seats);

    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

-- Создание представления для работы с таблицей showtimes
CREATE VIEW showtimes_view AS
SELECT showtime_id, movie_id, hall_id, show_date, available_seats
FROM showtimes;

-- Создание триггера на представление
CREATE TRIGGER instead_of_delete_showtime
INSTEAD OF DELETE ON showtimes_view
FOR EACH ROW
EXECUTE FUNCTION archive_showtime_instead_of_delete();

-- 1.4 Пример триггера FOR EACH STATEMENT
CREATE OR REPLACE FUNCTION after_delete_showtimes_statement()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Удаление записей из таблицы showtimes произведено';
    RETURN NULL;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_delete_showtimes_trigger
AFTER DELETE ON showtimes
FOR EACH STATEMENT
EXECUTE FUNCTION after_delete_showtimes_statement();


-- 2. Операционные триггеры
-- Before Delete
CREATE OR REPLACE FUNCTION archive_showtime_before_delete()
RETURNS TRIGGER AS $$
BEGIN
    INSERT INTO showtimes_archive (showtime_id, movie_id, hall_id, show_date, available_seats)
    VALUES (OLD.showtime_id, OLD.movie_id, OLD.hall_id, OLD.show_date, OLD.available_seats);

    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER before_delete_showtime_trigger
BEFORE DELETE ON showtimes
FOR EACH ROW
EXECUTE FUNCTION archive_showtime_before_delete();

-- 2.2 Логирование добавления нового сеанса
CREATE OR REPLACE FUNCTION after_insert_showtime_log()
RETURNS TRIGGER AS $$
BEGIN
    RAISE NOTICE 'Добавлен новый сеанс: Movie ID = %, Hall ID = %, Show Date = %, Available Seats = %',
                 NEW.movie_id, NEW.hall_id, NEW.show_date, NEW.available_seats;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER after_insert_showtime_trigger
AFTER INSERT ON showtimes
FOR EACH ROW
EXECUTE FUNCTION after_insert_showtime_log();

-- 3. Транзакции 
-- Успешная транзакция
BEGIN;
-- Добавляем новый фильм
INSERT INTO movies (title, genre, duration, release_date)
VALUES ('Avatar: The Way of Water', 'Sci-Fi', 192, '2022-12-16');

-- Добавляем новый зал
INSERT INTO halls (name, total_seats)
VALUES ('VIP Hall', 50);

-- Добавляем новый сеанс для добавленного фильма и зала
INSERT INTO showtimes (movie_id, hall_id, show_date, available_seats)
VALUES (
    (SELECT movie_id FROM movies WHERE title = 'Avatar: The Way of Water'),
    (SELECT hall_id FROM halls WHERE name = 'VIP Hall'),
    '2024-12-20 18:00:00',
    50
);

COMMIT;

-- Неуспешная транзакция
BEGIN;
-- Добавляем новый фильм
INSERT INTO movies (title, genre, duration, release_date)
VALUES ('Interstellar', 'Sci-Fi', 169, '2014-11-07');

-- Добавляем новый зал
INSERT INTO halls (name, total_seats)
VALUES ('Deluxe Hall', 100);

-- Попытка добавить сеанс с ошибкой
INSERT INTO showtimes (movie_id, hall_id, show_date, available_seats)
VALUES (9999, 9999, '2024-12-25 18:00:00', 100);

COMMIT;

-- Откат транзакции в случае ошибки
ROLLBACK;
