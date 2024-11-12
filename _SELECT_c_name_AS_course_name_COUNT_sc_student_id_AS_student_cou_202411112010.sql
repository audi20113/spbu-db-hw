INSERT INTO "SELECT c.name AS course_name, COUNT(sc.student_id) AS student_count
FROM courses c
LEFT JOIN student_courses sc ON c.id = sc.course_id
GROUP BY c.id" (course_name,student_count) VALUES
	 ('Математика',3),
	 ('История',2),
	 ('Информатика',3),
	 ('Физика',3);
