-- A library of my actual books with accurate published year/author name/page numbers
-- I will create a procedure to assign books as out on loan by specific members
-- I will use aggregate functions to show the members with the oldest and newest memberships, to target promotions.
-- Those promotions will use data about members who have not got any books on loan
-- I will add a scenario where members will take out books, return them, 
-- where a book is removed from the library and where a new book is added.

CREATE DATABASE my_library;

USE my_library;


-- Different data types
CREATE TABLE books (
id INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
title VARCHAR(80),
author_lname VARCHAR(30),
author_fname VARCHAR(30),
pages INT,
published_year YEAR,
is_fiction BOOL,
in_stock BOOL NOT NULL DEFAULT 1
);

-- The database stores the names of library members and the dates they joined. 
-- Member ID must be unique and auto increment easily deals with this. 
-- If no joining date is known, a default value is entered.
-- The foreign key links the member to the books they have on loan. 
CREATE TABLE members (
member_id INT NOT NULL AUTO_INCREMENT,
f_name VARCHAR(30), 
l_name VARCHAR(40) NOT NULL,
items_loaned INT,
joined_date DATE NOT NULL DEFAULT '2000-01-01', -- Different data types
PRIMARY KEY (member_id), 
FOREIGN KEY (items_loaned) REFERENCES books(id) -- Primary and foreign keys
);

-- I'm not sure I will need this for this assignment but I've written it now.
CREATE TABLE employees (
staff_id INT NOT NULL AUTO_INCREMENT,
f_name VARCHAR(30) NOT NULL, 
l_name VARCHAR(40) NOT NULL,
PRIMARY KEY (staff_id)
);

CREATE TABLE loaned_items (
loaning_member INT,
book_loaned_id INT,
FOREIGN KEY (loaning_member) REFERENCES members(member_id),
FOREIGN KEY (book_loaned_id) REFERENCES books(id)
);


INSERT INTO members (f_name, l_name, joined_date)
VALUES
('Jill', 'Colligan', '1997-07-22'),
('Nilay', 'Nasir', '2015-01-01'),
('David', 'Hemingway', '1975-08-17'),
('George', 'Smith', '1992-03-04'),
('Mary', 'King', '2017-09-22'),
('Parvinder', 'Gujral', '2022-02-28'),
('Emmett', 'Locke', '2022-02-28'),
('Evelyn', 'Joyce', '2011-08-21'),
('Naina', 'Nasri', '2018-11-30');

INSERT INTO employees (f_name, l_name)
VALUES
('Emily', 'Dixon'),
('Charlie', 'Marley'),
('Stephen', 'Kingsley'),
('Tony', 'Pratchett'),
('George', 'Martin'),
('Mike', 'Crichton'),
('Emily', 'Said'),
('Matthew', 'Zusak');

INSERT INTO books (title, author_lname, author_fname, pages, published_year, is_fiction)
VALUES
('Birdsong', 'Faulks', 'Sebastian', 503, 1994, 1),
('Angela Carter\'s Book of Fairy Tales', 'Carter', 'Angela', 486, 2009, 1),
('Decline and Fall', 'Waugh', 'Evelyn', 252, 1979, 1),
('The Collected Works of', 'Poe', 'Edgar Allan', 783, 2009, 1),
('The Collected Works of', 'Wilde', 'Oscar', 1098, 2007, 1),
('The Complete Works of', 'Shakespeare', 'William', 1263, 1994, 1),
('Collected Works', 'Austen', 'Jane', 767, 1982, 1),
('Principles of Literary Criticism', 'Richards', 'I. A.', 283, 2002, 0),
('Mend Your English', 'Bruton-Simmonds', 'Ian', 150, 2010, 0),
('Txtng: The gr8 db8', 'Crystal', 'David', 239, 2009, 0),
('Mythologies', 'Barthes', 'Roland', 159, 2000, 0),
('hillwalking', 'Long', 'Steve', 208, 2011, 0),
('The Etymologicon', 'Forsyth', 'Mark', 249, 2011, 0),
('The Horologicon', 'Forsyth', 'Mark', 258, 2012, 0),
('Charles Dickens: A Life', 'Tomalin', 'Claire', 527, 2011, 0),
('Good Morning, Midnight', 'Rhys', 'Jean', 159, 2000, 1),
('The Rubaiyat of Omar Khayyam', 'Khayyam', 'Omar', 96, 1993, 1),
('Heliopolis', 'Scudamore', 'James', 278, 2010, 1),
('The Ghost Road', 'Barker', 'Pat', 276, 2008, 1),
('The Prime of Miss Jean Brodie', 'Spark', 'Muriel', 128, 2011, 1),
('The Girl with All the Gifts', 'Carey', 'M. R.',  460, 2014, 1),
('Tequila Mockingbird', 'Federle', 'Tim', 148, 2013, 0),
('Evolving English', 'Crystal', 'David', 156, 2010, 0),
('Language and Power', 'Fairclough', 'Norman', 218, 2001, 0),
('Mini Weapons of Mass Destruction', 'Austin', 'John', 224, 2017, 0);


-- I want to know how many members there are
SELECT COUNT(*) FROM members;

-- Remove a book from stock because I can't find it anywhere...
DELETE FROM books WHERE title='hillwalking';

-- Oh whoops, I found it, hiding behind another new book!
INSERT INTO books (title, author_lname, author_fname, pages, published_year, is_fiction)
VALUES 
('Jurassic Park', 'Crichton', 'Michael', 438, 2020, 1),
('hillwalking', 'Long', 'Steve', 208, 2011, 0);

-- Another member has joined today :)
INSERT INTO members (f_name, l_name, joined_date)
VALUES
('Robert', 'Gaskin', '2024-03-26');
SELECT COUNT(*) FROM members;

-- And we have a new member of staff
INSERT INTO employees (f_name, l_name)
VALUES
('Tabitha', 'McTat');


-- Store procedure for loaning books - change in_stock to 0, add book and user id in loaned items table
DELIMITER //

CREATE PROCEDURE loan_book (IN member_id INT, IN book_id INT)
BEGIN
    UPDATE books SET in_stock = 0 WHERE id = book_id;
    INSERT INTO loaned_items (loaning_member, book_loaned_id)
    VALUES (member_id, book_id);
    SELECT member_id, book_id FROM loaned_items LIMIT 1;
END //

DELIMITER ;

-- Here are my members taking out some books
CALL loan_book(1, 16);
CALL loan_book(1, 3);
CALL loan_book(1, 9);
CALL loan_book(3, 5);
CALL loan_book(4, 17);
CALL loan_book(10, 1);

-- Check that the books table has updated to reflect these titles being out on loan
SELECT id, title, in_stock FROM books ORDER BY title;

SELECT loaned_items.book_loaned_id AS BookID, books.title AS Title, 
books.published_year AS Published, members.member_id AS MemberNo, 
CONCAT(members.f_name, ' ', members.l_name) AS Borrower
FROM loaned_items
INNER JOIN books ON loaned_items.book_loaned_id = books.id
INNER JOIN members ON loaned_items.loaning_member = members.member_id;

-- Let's see how many older books are out on loan
SELECT title, published_year FROM books 
WHERE published_year <= 2000 AND in_stock = 0 
ORDER BY published_year DESC;

-- Procedure for when a member wants to return a book
DELIMITER //

CREATE PROCEDURE return_book (IN book_id INT) -- I don't actually mind if it's the right member returning it, as long as it's returned!
BEGIN
    UPDATE books SET in_stock = 1 WHERE books.id = book_id; -- I had to put books.id = book_id as MySQL was getting confused otherwise
    DELETE FROM loaned_items WHERE book_loaned_id = book_id;
END //

DELIMITER ;

CALL return_book(16);

-- Another join to show members who have not borrowed any books, as well as our oldest and newest members, so we can send them marketing materials
DELIMITER //

CREATE PROCEDURE promote_library ()
BEGIN
    -- Members with no books on loan
    SELECT member_id, CONCAT(f_name, ' ', l_name) AS member_name
    FROM members
    LEFT JOIN loaned_items ON members.member_id = loaned_items.loaning_member
    WHERE loaned_items.loaning_member IS NULL
    
    UNION
    
    -- Members with oldest membership
    SELECT member_id, CONCAT(f_name, ' ', l_name) AS member_name
    FROM members
    WHERE joined_date = (SELECT MIN(joined_date) FROM members)
    
    UNION
    
    -- Members with newest membership
    SELECT member_id, CONCAT(f_name, ' ', l_name) AS member_name
    FROM members
    WHERE joined_date = (SELECT MAX(joined_date) FROM members);
END //

DELIMITER ;

CALL promote_library;

-- Find the newest books in the library to promote to these members
SELECT published_year, title, CONCAT(author_fname, ' ', author_lname) AS author_name 
FROM books ORDER BY published_year DESC LIMIT 5;