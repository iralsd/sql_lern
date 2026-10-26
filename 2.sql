CREATE DATABASE var1_2;
GO

USE var1_2;
GO
--второе задание
create table ForumMembers(
	MemberId int primary key,
	MemberName nvarchar(10)
);
CREATE TABLE ForumPosts (
    PostId INT PRIMARY KEY,
    Title NVARCHAR(200),
    Body TEXT,
    OwnerID INT FOREIGN KEY REFERENCES ForumMembers(MemberId),
    ReplyTo int foreign key references ForumPosts(PostId)
);

CREATE TABLE LikeMember (
    MemberId int foreign key references ForumMembers(MemberId),
	LikedMemberid int foreign key references ForumMembers(MemberId),
	primary key (MemberId, LikedMemberid)
);


CREATE TABLE Likes (
    --MemberId INT,
   -- PostId INT,
    
	MemberId int foreign key references  ForumMembers(MemberId),
	PostId INT foreign key references ForumPosts(PostId),
	PRIMARY KEY (MemberId, PostId)
);

INSERT INTO ForumMembers (MemberId, MemberName) VALUES
(1, 'Анна'),
(2, 'Борис'),
(3, 'Виктор'),
(4, 'Дарья'),
(5, 'Елена');

INSERT INTO ForumPosts (PostId, Title, Body, OwnerID, ReplyTo) VALUES
(1, 'Привет всем!', 'Рада присоединиться к форуму!', 1, NULL),  -- корневой пост Анны
(2, 'Как настроение?', 'Как ваши дела?', 2, NULL),            -- корневой пост Бориса
(3, 'Re: Привет всем!', 'Привет, Анна!', 3, 1),               -- ответ Виктора на пост 1
(4, 'Re: Как настроение?', 'Всё отлично!', 4, 2),             -- ответ Дарьи на пост 2
(5, 'Re: Re: Как настроение?', 'Я тоже!', 5, 4),              -- ответ Елены на ответ Дарьи
(6, 'Новости проекта', 'Скоро выйдет обновление...', 2, NULL), -- ещё один корневой пост от Бориса
(7, 'Re: Новости проекта', 'Ждём с нетерпением!', 1, 6); 

INSERT INTO Likes (MemberId, PostId) VALUES
-- Лайки на пост 1
(2, 1),
(3, 1),
(4, 1),
-- Лайки на пост 2
(1, 2),
(3, 2),
-- Лайки на пост 3
(2, 3),
-- Лайки на пост 6
(1, 6),
(3, 6),
(4, 6),
(5, 6);
-- Пост 4, 5, 7 без лайков (для разнообразия)

INSERT INTO LikeMember (MemberId, LikedMemberid) VALUES
(1, 3),  -- Анна симпатизирует Виктору
(1, 4),  -- Анна симпатизирует Дарье
(2, 1),  -- Борис симпатизирует Анне
(3, 2),  -- Виктор симпатизирует Борису
(4, 5),  -- Дарья симпатизирует Елене
(5, 1);  -- Елена симпатизирует Анне



-- четвертое задание
select p.PostId, p.Title, count(l.MemberId)
from ForumPosts p
left join Likes l 
on l.PostId = p.PostId
group by p.PostId, p.Title;


--третье задание

create database var_1g
go

use  var_1g
go

create table Posts(
PostId INT PRIMARY KEY,
    Title NVARCHAR(200),
    Body TEXT
	) as node;

	create table Members(
	MemberId int primary key,
	MemberName nvarchar(10)
	) as Node;

	create table LikeM as edge;
	create table ReplyTo as edge;
	create table LikeP as edge;
	create table WrittenBy as edge;

INSERT INTO Members (MemberId, MemberName) VALUES
(1, 'Анна'),
(2, 'Борис'),
(3, 'Виктор'),
(4, 'Дарья'),
(5, 'Елена');

INSERT INTO Posts (PostId, Title, Body) VALUES
(1, 'Привет всем!', 'Рада присоединиться к форуму!'),  -- корневой пост Анны
(2, 'Как настроение?', 'Как ваши дела?'),            -- корневой пост Бориса
(3, 'Re: Привет всем!', 'Привет, Анна!'),               -- ответ Виктора на пост 1
(4, 'Re: Как настроение?', 'Всё отлично!'),             -- ответ Дарьи на пост 2
(5, 'Re: Re: Как настроение?', 'Я тоже!'),              -- ответ Елены на ответ Дарьи
(6, 'Новости проекта', 'Скоро выйдет обновление...'), -- ещё один корневой пост от Бориса
(7, 'Re: Новости проекта', 'Ждём с нетерпением!');

insert into WrittenBy ($from_id, $to_id) values
((select $node_id from Posts where PostId = 1), (select $node_id from Members where MemberId = 1)),
((select $node_id from Posts where PostId = 2), (select $node_id from Members where MemberId = 2)),
((select $node_id from Posts where PostId = 3), (select $node_id from Members where MemberId = 3)),
((select $node_id from Posts where PostId = 4), (select $node_id from Members where MemberId = 4)),
((select $node_id from Posts where PostId = 5), (select $node_id from Members where MemberId = 5)),
((select $node_id from Posts where PostId = 6), (select $node_id from Members where MemberId = 1)),
((select $node_id from Posts where PostId = 7), (select $node_id from Members where MemberId = 2));

insert into ReplyTo ($from_id, $to_id) values
((select $node_id from Posts where PostId = 3), (select $node_id from Posts where PostId =1)),
((select $node_id from Posts where PostId = 4), (select $node_id from Posts where PostId =2)),
((select $node_id from Posts where PostId = 5), (select $node_id from Posts where PostId =4)),
((select $node_id from Posts where PostId = 7), (select $node_id from Posts where PostId =6));

insert into LikeM($from_id, $to_id) values
((select $node_id from Members where MemberId  = 1), (select $node_id from Members where MemberId =3)),
((select $node_id from Members where MemberId  = 1), (select $node_id from Members where MemberId =4)),
((select $node_id from Members where MemberId  = 2), (select $node_id from Members where MemberId =1)),
((select $node_id from Members where MemberId  = 3), (select $node_id from Members where MemberId =2)),
((select $node_id from Members where MemberId  = 4), (select $node_id from Members where MemberId =5)),
((select $node_id from Members where MemberId  = 5), (select $node_id from Members where MemberId =1));

insert into LikeP($from_id, $to_id) values
((select $node_id from Members where MemberId  = 2), (select $node_id from Posts where PostId =1)),
((select $node_id from Members where MemberId  = 3), (select $node_id from Posts where PostId =1)),
((select $node_id from Members where MemberId  = 4), (select $node_id from Posts where PostId =1)),
((select $node_id from Members where MemberId  = 1), (select $node_id from Posts where PostId =2)),
((select $node_id from Members where MemberId  = 3), (select $node_id from Posts where PostId =2)),
((select $node_id from Members where MemberId  = 2), (select $node_id from Posts where PostId =3)),
((select $node_id from Members where MemberId  = 1), (select $node_id from Posts where PostId =6)),
((select $node_id from Members where MemberId  = 3), (select $node_id from Posts where PostId =6)),
((select $node_id from Members where MemberId  = 4), (select $node_id from Posts where PostId =6)),
((select $node_id from Members where MemberId  = 5), (select $node_id from Posts where PostId =6));


--пятое задание
select distinct  m.MemberName
from Members m, LikeP lp, Posts p
where match (m -(lp)-> p)
and not exists(
	select * 
	from WrittenBy w, ReplyTo r, Posts p2
	where match (m <-(w)- p2)
	and match(p2 -(r)-> p)
	)




	--------------Другой вариант--------------------

	--4 задание

select p.Title, m.MemberName , x.cola as кол_лайков, y.core as кол_реп
from ForumPosts p
inner join ForumMembers m
on p.OwnerID = m.MemberId
left join (select p1.PostId, count(l1.MemberId) as cola
				from ForumPosts p1
				inner join Likes l1
				on p1.PostId = l1.PostId
				group by p1.PostId) as x
on p.PostId = x.PostId

left join ( select p2.PostId, count(p3.PostId) as core
				from ForumPosts p2
				inner join ForumPosts p3
				on p2.ReplyTo = p3.PostId
				group by p2.PostId) as y
on p.PostId = y.PostId


--5 задание

select p.Title
from Posts p, WrittenBy w, Members m
where match (p-(w)->m)
and exists (
	select *
	from  LikeP lp
	where match (m-(lp)->p))
and exists(
	select * 
	from  ReplyTo r, Posts p2, WrittenBy w2
	where match (p2 -(r)->p)
	and match (p2-(w2)->m))

