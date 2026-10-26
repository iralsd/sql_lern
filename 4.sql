create database per_6;
go
use per_6
go
CREATE TABLE Отделы (
    Номер_отдела INT PRIMARY KEY,
    Название_отдела VARCHAR(50) NOT NULL,
    Количество_сотрудников INT DEFAULT 0
);

CREATE TABLE Сотрудники (
    Табельный_номер INT PRIMARY KEY,
    ФИО VARCHAR(20) NOT NULL,
    Пол CHAR(1) DEFAULT 'М' CHECK (Пол IN ('М', 'Ж')),
    Дата_рождения DATE,
    Образование VARCHAR(20) CHECK (Образование IN ('высшее', 'среднее', 'начальное')),
    Номер_отдела INT,
    Должность VARCHAR(20) NOT NULL,
    Дата_поступления DATE NOT NULL,
    Дата_увольнения DATE,
    FOREIGN KEY (Номер_отдела) REFERENCES Отделы(Номер_отдела)
);

CREATE TABLE Дети (
    ID_ребенка INT PRIMARY KEY identity(1,1),
    Табельный_номер_сотрудника INT,
    Имя_ребенка VARCHAR(30) NOT NULL,
    Дата_рождения_ребенка DATE NOT NULL,
    FOREIGN KEY (Табельный_номер_сотрудника) REFERENCES Сотрудники(Табельный_номер)
);

INSERT INTO Отделы (Номер_отдела, Название_отдела, Количество_сотрудников) VALUES
(1, 'Отдел кадров', 5),
(2, 'IT отдел', 8),
(3, 'Бухгалтерия', 4);

INSERT INTO Сотрудники (Табельный_номер, ФИО, Пол, Дата_рождения, Образование, Номер_отдела, Должность, Дата_поступления) VALUES
(100001, 'Иванов И.И.', 'М', '1980-05-15', 'высшее', 1, 'Менеджер', '2015-03-10'),
(100002, 'Петрова А.С.', 'Ж', '1990-08-22', 'высшее', 2, 'Программист', '2019-07-01'),
(100003, 'Сидоров П.П.', 'М', '1975-12-30', 'среднее', 3, 'Бухгалтер', '2010-11-20');

INSERT INTO Дети (Табельный_номер_сотрудника, Имя_ребенка, Дата_рождения_ребенка) VALUES
(100001, 'Мария', '2010-04-12'),
(100001, 'Алексей', '2015-07-23'),
(100002, 'Ольга', '2018-11-05');


--2
CREATE VIEW Образовательный_уровень_сотрудников AS
SELECT 
    Образование AS уровень_образования,
    COUNT(CASE WHEN Пол = 'М' THEN 1 END) AS количество_мужчин,
    COUNT(CASE WHEN Пол = 'Ж' THEN 1 END) AS количество_женщин
FROM Сотрудники
WHERE Дата_увольнения IS NULL  -- только работающие сотрудники
GROUP BY Образование;

SELECT * FROM Образовательный_уровень_сотрудников;

--3
CREATE PROCEDURE max_uv1111
AS
BEGIN
    ;WITH cnt AS (
        SELECT Номер_отдела, COUNT(*) AS c
        FROM Сотрудники
        WHERE YEAR(Дата_увольнения) = YEAR(GETDATE())
        GROUP BY Номер_отдела
    )
    SELECT o.Название_отдела
    FROM cnt
	inner join Отделы o
	on o.Номер_отдела = cnt.Номер_отдела
    WHERE c = (SELECT MAX(c) FROM cnt);
END;


CREATE TABLE #t1 (Название_отдела NVARCHAR(200));

INSERT INTO #t1
EXEC max_uv1111;

SELECT * FROM #t1;
EXEC max_uv1111;


--4

create trigger trrrr
on Сотрудники 
after update 
as
begin 
	update o
	set Количество_сотрудников = count(case when i.Дата_увольнения is null then 1 end)
	from Отделы o
	join inserted i on i.Номер_отдела = o.Номер_отдела


--  5
use master;
go

create login Тест with password = '123'
use per_6
go
create role Экзамен;
exec sp_addrolemember 'Экзамен', 'Тест';

grant select on  dbo.Образовательный_уровень_сотрудников to Экзамен;
grant select, update, insert, delete on dbo.Отделы to Экзамен;
grant execute  on dbo.max_uv1111 to Экзамен;

--9 вариант
create database var9;
go
use var9;
go
CREATE TABLE Владельцы (
    Идентификатор INT PRIMARY KEY identity(1,1),
    Имя VARCHAR(50) NOT NULL,
    Телефон VARCHAR(20)
);

CREATE TABLE Станции_метро (
    Идентификатор INT PRIMARY KEY identity(1,1),
    Название VARCHAR(50) NOT NULL
);

CREATE TABLE Квартиры (
    Идентификатор INT PRIMARY KEY identity(1,1),
    Номер_владельца INT,
    Общая_площадь DECIMAL(4,1),
    Жилая_площадь DECIMAL(4,1) NOT NULL,
    Количество_комнат INT NOT NULL,
    Размер_кухни DECIMAL(3,1) NOT NULL,
    Этаж INT NOT NULL,
    Всего_этажей_в_доме INT,
    Ближайшая_станция_метро INT,
    Цена DECIMAL(12,2) NOT NULL,
    Адрес VARCHAR(30) NOT NULL,
    Дата_поступления DATE,
    FOREIGN KEY (Номер_владельца) REFERENCES Владельцы(Идентификатор),
    FOREIGN KEY (Ближайшая_станция_метро) REFERENCES Станции_метро(Идентификатор)
);

INSERT INTO Владельцы (Имя, Телефон) VALUES
('Иванов Петр Сергеевич', '+7-999-123-45-67'),
('Смирнова Ольга Ивановна', '+7-912-345-67-89'),
('Кузнецов Алексей Викторович', NULL);

INSERT INTO Станции_метро (Название) VALUES
('Площадь Ленина'),
('Гагаринская'),
('Чкаловская'),
('Ботаническая');

INSERT INTO Квартиры (
    Номер_владельца, Общая_площадь, Жилая_площадь, Количество_комнат, 
    Размер_кухни, Этаж, Всего_этажей_в_доме, Ближайшая_станция_метро, 
    Цена, Адрес, Дата_поступления
) VALUES
(1, 75.5, 50.0, 3, 12.5, 5, 9, 1, 8500000.00, 'ул. Ленина, 10', '2024-03-01'),
(2, 45.0, 30.0, 2, 8.0, 3, 5, 2, 5200000.00, 'ул. Гагарина, 25', '2024-03-15'),
(3, 60.0, 40.0, 3, 10.0, 2, 5, 3, 6500000.00, 'ул. Чкалова, 7', '2024-02-28');

--2
CREATE VIEW Трехкомнатные_квартиры_не_крайние_этажи AS
SELECT 
    К.*,
    В.Имя AS Владелец,
    СМ.Название AS Станция_метро
FROM 
    Квартиры К
JOIN 
    Владельцы В ON К.Номер_владельца = В.Идентификатор
JOIN 
    Станции_метро СМ ON К.Ближайшая_станция_метро = СМ.Идентификатор
WHERE 
    К.Количество_комнат = 3
    AND К.Этаж > 1
    AND К.Этаж < К.Всего_этажей_в_доме
    AND 1<= DATEdiff(MONTH ,getdate(),К.Дата_поступления);


	---3 
	CREATE PROCEDURE НайтиВладельцевКвартир
    @X DECIMAL(4,1),
    @Y DECIMAL(12,2),
    @Z INT
AS
BEGIN
    SELECT 
        В.Имя,
        В.Телефон,
        COUNT(К.Идентификатор) AS Количество_квартир,
        SUM(К.Общая_площадь) AS Общая_площадь_всего,
        SUM(CASE WHEN К.Количество_комнат = 3 THEN 1 ELSE 0 END) AS Трехкомнатных,
        SUM(CASE WHEN К.Количество_комнат = 2 THEN 1 ELSE 0 END) AS Двухкомнатных,
        SUM(CASE WHEN К.Количество_комнат = 1 THEN 1 ELSE 0 END) AS Однокомнатных
    FROM 
        Владельцы В
    INNER JOIN 
        Квартиры К ON В.Идентификатор = К.Номер_владельца
    WHERE 
        К.Общая_площадь >= @X
        AND К.Цена <= @Y
        AND К.Ближайшая_станция_метро = @Z
    GROUP BY 
        В.Имя, В.Телефон
    ORDER BY 
        В.Имя;
END;


---4 

CREATE TRIGGER КорректироватьОбщуюПлощадь
ON Квартиры
AFTER INSERT, UPDATE
AS
BEGIN
    UPDATE Квартиры
    SET Общая_площадь = i.Жилая_площадь + i.Размер_кухни
    FROM Квартиры k
    INNER JOIN inserted i ON k.Идентификатор = i.Идентификатор
    LEFT JOIN deleted d ON k.Идентификатор = d.Идентификатор
    WHERE 
        k.Общая_площадь IS NULL 
        OR (d.Идентификатор IS NOT NULL 
            AND (i.Жилая_площадь <> d.Жилая_площадь 
                 OR i.Размер_кухни <> d.Размер_кухни));
END;
GO

