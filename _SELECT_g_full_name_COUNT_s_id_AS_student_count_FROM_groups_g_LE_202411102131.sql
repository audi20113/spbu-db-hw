INSERT INTO "SELECT g.full_name, COUNT(s.id) AS student_count
FROM groups g
LEFT JOIN students s ON g.id = s.group_id
GROUP BY g.full_name
" (full_name,student_count) VALUES
	 ('Группа А',3),
	 ('Группа Б',2);
