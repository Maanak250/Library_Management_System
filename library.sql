CREATE DATABASE IF NOT EXISTS db_LibraryManagement;

USE db_LibraryManagement;

CREATE TABLE table_publisher (
    PublisherName VARCHAR(50) PRIMARY KEY NOT NULL,
    PublisherAddress VARCHAR(100) NOT NULL,
    PublisherPhone VARCHAR(20) NOT NULL
);

CREATE TABLE table_book (
    BookID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    Book_Title VARCHAR(100) NOT NULL,
    PublisherName VARCHAR(100) NOT NULL
);

CREATE TABLE table_library_branch (
    library_branch_BranchID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BranchName VARCHAR(100) NOT NULL,
    library_branch_BranchAddress VARCHAR(200) NOT NULL
);

CREATE TABLE table_borrower (
    CardNo INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BorrowerName VARCHAR(100) NOT NULL,
    BorrowerAddress VARCHAR(200) NOT NULL,
    BorrowerPhone VARCHAR(50) NOT NULL
);

CREATE TABLE table_book_copies (
    book_copies_CopiesID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BookID INT NOT NULL,
    BranchID INT NOT NULL,
    No_Of_Copies INT NOT NULL
);

CREATE TABLE table_book_authors (
    book_authors_AuthorID INT PRIMARY KEY NOT NULL AUTO_INCREMENT,
    BookID INT NOT NULL,
    AuthorName VARCHAR(50) NOT NULL
);

CREATE TABLE `book` (
    `isbn` char(13) NOT NULL,
    `title` varchar(80) NOT NULL,
    `author` varchar(80) NOT NULL,
    `category` varchar(80) NOT NULL,
    `price` int(4) unsigned NOT NULL,
    `copies` int(10) unsigned NOT NULL,
    PRIMARY KEY (`isbn`)
);

CREATE TABLE `book_issue` (
    `issue_id` int(11) NOT NULL AUTO_INCREMENT,
    `member` varchar(20) NOT NULL,
    `book_isbn` varchar(13) NOT NULL,
    `due_date` date NOT NULL,
    `last_reminded` date DEFAULT NULL,
    PRIMARY KEY (`issue_id`)
);

DELIMITER //
CREATE TRIGGER `issue_book` BEFORE INSERT ON `book_issue`
FOR EACH ROW BEGIN
    SET NEW.due_date = DATE_ADD(CURRENT_DATE, INTERVAL 20 DAY);
    UPDATE member SET balance = balance - (SELECT price FROM book WHERE isbn = NEW.book_isbn) WHERE username = NEW.member;
    UPDATE book SET copies = copies - 1 WHERE isbn = NEW.book_isbn;
    DELETE FROM pending_book_requests WHERE member = NEW.member AND book_isbn = NEW.book_isbn;
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER `return_book` BEFORE DELETE ON `book_issue`
FOR EACH ROW BEGIN
    UPDATE member SET balance = balance + (SELECT price FROM book WHERE isbn = OLD.book_isbn) WHERE username = OLD.member;
    UPDATE book SET copies = copies + 1 WHERE isbn = OLD.book_isbn;
END;
//
DELIMITER ;

CREATE TABLE `librarian` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(20) NOT NULL,
    `password` char(40) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`)
);

CREATE TABLE `member` (
    `id` int(11) NOT NULL AUTO_INCREMENT,
    `username` varchar(20) NOT NULL,
    `password` char(40) NOT NULL,
    `name` varchar(80) NOT NULL,
    `email` varchar(80) NOT NULL,
    `balance` int(4) NOT NULL,
    PRIMARY KEY (`id`),
    UNIQUE KEY `username` (`username`),
    UNIQUE KEY `email` (`email`)
);

DELIMITER //
CREATE TRIGGER `add_member` AFTER INSERT ON `member`
FOR EACH ROW DELETE FROM pending_registrations WHERE username = NEW.username;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER `remove_member` AFTER DELETE ON `member`
FOR EACH ROW DELETE FROM pending_book_requests WHERE member = OLD.username;
//
DELIMITER ;

CREATE TABLE `pending_book_requests` (
    `request_id` int(11) NOT NULL AUTO_INCREMENT,
    `member` varchar(20) NOT NULL,
    `book_isbn` varchar(13) NOT NULL,
    `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`request_id`)
);

CREATE TABLE `pending_registrations` (
    `username` varchar(30) NOT NULL,
    `password` char(20) NOT NULL,
    `name` varchar(40) NOT NULL,
    `email` varchar(20) NOT NULL,
    `balance` int(10),
    `time` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`username`)
);

INSERT INTO `pending_registrations` (`username`, `password`, `name`, `email`, `balance`, `time`)
VALUES
    ('Robin200', '7t6hg$56y^', 'Robin', 'robin@gmail.com', 200, '2021-03-21 08:59:00'),
    ('Aadhya100', 'Ujgf(76G5$#f@df', 'Aadhya', 'aadhya100@gmail.com', 1500, '2021-03-21 2:14:53');
