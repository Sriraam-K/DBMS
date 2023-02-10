CREATE DATABASE IF NOT EXISTS Popeye;
USE Popeye;

CREATE TABLE IF NOT EXISTS sailors (
    sid VARCHAR(10) NOT NULL PRIMARY KEY,
    sname VARCHAR(30) NOT NULL,
    rating INT(2) NOT NULL,
    age INT(2) NOT NULL
);

CREATE TABLE IF NOT EXISTS boats (
    bid VARCHAR(10) NOT NULL PRIMARY KEY,
    bname VARCHAR(20) NOT NULL,
    color VARCHAR(10) NOT NULL
);

CREATE TABLE IF NOT EXISTS reservers (
    sid VARCHAR(10) NOT NULL,
    bid VARCHAR(10) NOT NULL,
    s_date DATE NOT NULL,
    FOREIGN KEY(sid) REFERENCES sailors(sid) ON DELETE CASCADE,
    FOREIGN KEY(bid) REFERENCES boats(bid) ON DELETE CASCADE
);

INSERT INTO sailors VALUES


INSERT INTO boat VALUES


INSERT INTO reservers VALUES


-- QUERY 1
select color from boats where bid in (select bid from reservers where 
sid=(select sid from sailors where sname="Albert"));

select b.color as 'Boat colors' from boats b, reservers r, sailors s
where b.bid=r.bid and r.sid=s.sid and s.sname="Albert";

-- QUERY 2
(select sid from sailors where rating>=8)
union
(select sid from reservers where bid="B103");

-- QUERY 3
select sname from sailors where sid not in (select sid from reservers where bid in (select bid from boats where bname like "%storm%"));

-- QUERY 4
select s.sname as 'Proactive Sailors' from sailors s where not exists
((select bid from boats) except (select r.bid from reservers r where r.sid=s.sid));

-- QUERY 5
select sname, age from sailors where age=(select max(age) from sailors);

-- QUERY 6
select b.bid, avg(s.age) as 'Average age' from sailors s, reservers r, boats b
where b.bid=r.bid and r.sid=s.sid and s.age>=40
group by b.bid having count(s.sid)>=5;

-- VIEW 1
create view ratings as
select  sname, rating from sailors order by rating desc;

select * from ratings;

-- VIEW 2
create view reserveOn as
select sname from sailors where sid in (select sid from reservers where s_date="2019-12-15");

select * from reserveOn;

-- VIEW 3 *
create view boatBook as
select bname, color from boats where bid in (select distinct bid from reservers where sid in (select sid from sailors where rating>5));

select * from boatBook;

-- TRIGGER 1 *
delimiter //
create trigger activeRes
before delete on boats
for each row
begin
    if curdate() < (select max(s_date) from reservers where bid=old.bid) then
        signal sqlstate '50004' set message_text='Boat has active reservations! Deletion not permitted';
    end if;
end;//
delimiter ;

-- TRIGGER 2
delimiter //
create trigger invalidRes
before insert on reservers
for each row
begin
    if (select rating from sailors where sid=new.sid) < 3 then
        signal sqlstate '50005' set message_text='Sailor inexperienced! Cant reserve the requested boat';
    end if;
end;//
delimiter ;