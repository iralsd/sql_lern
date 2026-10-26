CREATE DATABASE var2_1g;
GO

USE var2_1g;
GO
-- Таблица Города (как узел)
CREATE TABLE Cities (
    CityId INT PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100)
) AS NODE;

-- Таблица Персоны (как узел)
CREATE TABLE Persons (
    PersonId INT PRIMARY KEY,
    NameP NVARCHAR(50) NOT NULL,
    Age INT
) AS NODE;

-- Таблица Рестораны (как узел)
CREATE TABLE Restaurants (
    RestaurantId INT PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    CuisineType NVARCHAR(100),
    Rating DECIMAL(3,2)
) AS NODE;

CREATE TABLE LivesIn AS EDGE;

CREATE TABLE FriendsWith AS EDGE;

CREATE TABLE LikesCity AS EDGE;

CREATE TABLE LikesRes AS EDGE;

CREATE TABLE Located AS EDGE;




insert into Cities(CityId , CityName , Country ) values
(1, 'Ярославль', 'Россия'),
(2, 'Вологда', 'Россия'),
(3, 'Москва', 'Россия');

insert into Persons values
(1, 'ЧонГук', 21),
(2, 'Ирина', 21),
(3, 'Миша', 21);
	
insert into Restaurants values
(1, 'мак', 'фастфуд',5),
(2, 'Много рыбы', 'фастфуд',5),
(3, 'Столовая', 'крутатень',9);

insert into FriendsWith($from_id, $to_id) values
((select $node_id  from Persons where PersonId = 3), (select $node_id  from Persons where PersonId = 2)), 
((select $node_id  from Persons where PersonId = 2), (select $node_id  from Persons where PersonId = 1)),
((select $node_id  from Persons where PersonId = 2), (select $node_id  from Persons where PersonId = 3));

insert into LivesIn($from_id, $to_id) values
((select $node_id  from Persons where PersonId = 3), (select $node_id  from Cities where CityId = 1)), 
((select $node_id  from Persons where PersonId = 2), (select $node_id  from Cities where CityId = 2)), 
((select $node_id from Persons where PersonId = 1), (select $node_id  from Cities where CityId = 3));

insert into LikesCity($from_id, $to_id) values
((select $node_id  from Persons where PersonId = 3), (select $node_id  from Cities where CityId = 3)), 
((select $node_id  from Persons where PersonId = 2), (select $node_id  from Cities where CityId = 2)), 
((select $node_id  from Persons where PersonId = 1), (select $node_id  from Cities where CityId = 1));

insert into Located($from_id, $to_id) values
((select $node_id  from Restaurants where RestaurantId = 3), (select $node_id  from Cities where CityId = 3)), 
((select $node_id  from Restaurants where RestaurantId= 2), (select $node_id  from Cities where CityId = 2)), 
((select $node_id from Restaurants where RestaurantId = 1), (select $node_id  from Cities where CityId = 1));

insert into LikesRes($from_id, $to_id) values
((select $node_id  from Persons where PersonId = 3), (select $node_id  from Restaurants where RestaurantId = 3)), 
((select $node_id  from Persons where PersonId = 2), (select $node_id  from Restaurants where RestaurantId = 1)), 
((select $node_id  from Persons where PersonId = 1), (select $node_id from Restaurants where RestaurantId = 1));



-- задание 4
select p2.NameP, p2.Age
from Persons p, FriendsWith f, LivesIn l, Cities c, Persons p2
where match(p-(f)->p2)
and p.NameP = 'Ирина'
and match(p2-(l)->c)
and c.CityName  not in(select c1.CityName
									from Cities c1,Persons p1, LivesIn l1
									where  p1.NameP = 'Ирина'
									and match(p1-(l1)->c1))


--задание 3

CREATE DATABASE var2;
GO

USE var2;
GO
-- Таблица Города (как узел)
CREATE TABLE Cities (
    Id INT PRIMARY KEY,
    CityName NVARCHAR(100) NOT NULL,
    Country NVARCHAR(100)
) 
-- Таблица Рестораны (как узел)
CREATE TABLE Restaurants (
    Id INT PRIMARY KEY,
    Name NVARCHAR(150) NOT NULL,
    CuisineType NVARCHAR(100),
    Rating DECIMAL(3,2),
	Lokal int,
	foreign key (Lokal) references Cities(Id)
) 

-- Таблица Персоны (как узел)
CREATE TABLE Persons (
    PersonId INT PRIMARY KEY,
    NameP NVARCHAR(50) NOT NULL,
    Age INT,
	CitiId int,
	LikeCiti int,
	LikeRes int,
	foreign key(CitiId) references Cities(Id),
	foreign key(LikeCiti) references Cities(Id),
	foreign key(LikeRes) references Restaurants(Id)
) 

create table FriendsWi(
	personId int ,
	friendId int,
	primary key (personId, friendId),
	foreign key(personId) references Persons(PersonId),
	foreign key(friendId) references Persons(PersonId)
)

insert into Cities(Id , CityName , Country ) values
(1, 'Ярославль', 'Россия'),
(2, 'Вологда', 'Россия'),
(3, 'Москва', 'Россия');

insert into Persons values
(1, 'ЧонГук', 21, 3, 1, 1),
(2, 'Ирина', 21, 2, 2, 1),
(3, 'Миша', 21, 1, 3, 3);
	
insert into Restaurants values
(1, 'мак', 'фастфуд',5,1),
(2, 'Много рыбы', 'фастфуд',5, 2),
(3, 'Столовая', 'крутатень',9, 3);

insert into FriendsWi values
(3,2),
(2,1),
(2,3);


-- номер 5
select r.Name, count (x.PersonId)
from Restaurants r
inner join (select p.PersonId, p.LikeRes
				from Persons p

				union 

				select  f.friendId as PersonId , p.LikeRes
				from Persons p
				inner join FriendsWi f
				on f.personId = p.PersonId) as x
on x.LikeRes = r.Id
group by r.Name


