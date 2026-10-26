CREATE DATABASE TrainingSQLServer;
GO

USE TrainingSQLServer;
GO

CREATE TABLE Users (
    Id INT IDENTITY PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    Birthdate DATE NULL,
    IsActive BIT DEFAULT 1
);

CREATE TABLE Products (
    Id INT IDENTITY PRIMARY KEY,
    Title NVARCHAR(100) NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    Stock INT NOT NULL
);

CREATE TABLE Orders (
    Id INT IDENTITY PRIMARY KEY,
    UserId INT NOT NULL,
    Total DECIMAL(10,2) DEFAULT 0,
    CreatedAt DATETIME NULL,
    FOREIGN KEY (UserId) REFERENCES Users(Id)
);

CREATE TABLE OrderItems (
    Id INT IDENTITY PRIMARY KEY,
    OrderId INT NOT NULL,
    ProductId INT NOT NULL,
    Quantity INT NOT NULL,
    Price DECIMAL(10,2) NOT NULL,
    FOREIGN KEY (OrderId) REFERENCES Orders(Id),
    FOREIGN KEY (ProductId) REFERENCES Products(Id)
);
INSERT INTO Users(Name, Birthdate) VALUES
(N'Masha', '2003-05-05'),
(N'Ivan', '1999-10-10'),
(N'Oleg', '1985-01-01');

INSERT INTO Products(Title, Price, Stock) VALUES
(N'Laptop', 120000, 5),
(N'Mouse', 1500, 40),
(N'Keyboard', 4500, 25);



--функции
create function GetAge(@date_bir DATE)
returns int
as
begin
return DATEDIFF(year, @date_bir, getdate())
end

select dbo.GetAge('11.01.2005');

create function  CatPrice(@price decimal(10,2))
returns nvarchar(20)
as 
begin
declare @t nvarchar(20)
set @t =
case 
when @price < 2000 then  'cheap'
when @price between 2000 and 10000 then  'normal'
else  'expensive'
end ;
return @t;
end;

select dbo.CatPrice(1000);

--процедуры

create procedure decUs
@us_id int
as
begin
update  Users
set IsActive = 0
where @us_id = id
end;


exec decUs 1;

select * from Users;

create procedure AddStock
@productId INT, 
@amount INT
as
begin
update Products
set Stock = Stock + @amount
where Id = @productId
end;

exec AddStock 1, 12;
select * from Products;

--триггеры
create trigger CreAt
on Orders
after insert 
as
begin
update o
set CreatedAt = getdate()
from Orders o
inner join inserted i
on i.Id = o.Id 
where i.CreatedAt  is null 
end;



create trigger tri
on OrderItems
after insert 
as
begin
update p
set p.Stock =p.Stock-i.Quantity
from Products p
inner join inserted i 
on i.ProductId = p.Id
and p.Stock > i.Quantity
end;

create trigger tri2
on OrderItems
after insert 
as
begin
update p
set p.Stock =p.Stock-i.Quantity
from Products p
inner join inserted i 
on i.ProductId = p.Id

if exists (select  1
			from Products
			where Stock <0)
begin 
rollback transaction 
end
end;


create trigger t3
on OrderItems
after insert, delete, update
as
begin 
WITH affected_orders AS (
        SELECT DISTINCT OrderId
        FROM inserted
        UNION
        SELECT DISTINCT OrderId
        FROM deleted
    )
    UPDATE o
    SET o.Total = totals.SumTotal
    FROM Orders o
    INNER JOIN (
        SELECT oi.OrderId, SUM(oi.Quantity * oi.Price) AS SumTotal
        FROM OrderItems oi
        GROUP BY oi.OrderId
    ) totals
	ON o.Id = totals.OrderId
    INNER JOIN affected_orders ao
	ON ao.OrderId = o.Id;
end;
