-- phpMyAdmin SQL Dump
-- version 4.8.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 13, 2018 at 08:54 PM
-- Server version: 10.1.28-MariaDB
-- PHP Version: 5.6.35

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
SET AUTOCOMMIT = 0;
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `book_store`
--

-- --------------------------------------------------------

--
-- Table structure for table `books_desc`
--

CREATE TABLE `books_desc` (
  `book_id` int(10) NOT NULL,
  `book_desc` varchar(100) NOT NULL,
  `category` varchar(30) DEFAULT NULL,
  `price` double NOT NULL,
  `images` blob NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `books_master`
--

CREATE TABLE `books_master` (
  `book_id` int(20) NOT NULL,
  `book_title` varchar(50) DEFAULT NULL,
  `author` varchar(20) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `books_master`
--
DELIMITER $$
CREATE TRIGGER `add_books_insert` AFTER INSERT ON `books_master` FOR EACH ROW IF old.count() < new.count() THEN
	INSERT INTO transaction_master(trn_type)
    VALUES('add item');
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `delete_books` AFTER DELETE ON `books_master` FOR EACH ROW IF old.count() > new.count() THEN
	INSERT INTO transaction_master(trn_type)
    VALUES('delete item');
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `categories_master`
--

CREATE TABLE `categories_master` (
  `category_id` int(10) NOT NULL,
  `category_name` varchar(30) NOT NULL,
  `book_title` varchar(50) NOT NULL,
  `sub_category` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

-- --------------------------------------------------------

--
-- Table structure for table `sales_master`
--

CREATE TABLE `sales_master` (
  `sales_id` int(10) NOT NULL,
  `book_id` int(10) DEFAULT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `tr_id` int(30) NOT NULL,
  `user_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `sales_master`
--
DELIMITER $$
CREATE TRIGGER `sales_return` AFTER DELETE ON `sales_master` FOR EACH ROW IF old.count() > new.count() THEN
	INSERT into transaction_master(trn_type)
    VALUES('sales_return');
END IF
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `sales_tr` AFTER INSERT ON `sales_master` FOR EACH ROW IF old.count() < new.count() THEN 
	INSERT INTO transaction_master(trn_type)
    VALUES('sales');
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `search_master`
--

CREATE TABLE `search_master` (
  `search_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `book_title` varchar(50) NOT NULL,
  `category` varchar(30) NOT NULL,
  `date` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `search_master`
--
DELIMITER $$
CREATE TRIGGER `search_tr` AFTER INSERT ON `search_master` FOR EACH ROW IF old.count() < new.count() THEN 
	INSERT INTO transaction_master(trn_type)
    VALUES('search');
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `transaction_master`
--

CREATE TABLE `transaction_master` (
  `trn_id` int(10) NOT NULL,
  `trn_type` set('add item','delete item','search','sales','sales return') NOT NULL,
  `date` timestamp(6) NOT NULL DEFAULT CURRENT_TIMESTAMP(6) ON UPDATE CURRENT_TIMESTAMP(6),
  `sales_id` int(10) NOT NULL,
  `user_id` int(10) NOT NULL,
  `search_id` int(10) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Triggers `transaction_master`
--
DELIMITER $$
CREATE TRIGGER `transaction_type` AFTER INSERT ON `transaction_master` FOR EACH ROW IF trn_type = 'add item' OR 'delete item' THEN
   	UPDATE transaction_master SET user_id = (SELECT u_id 		FROM user_master WHERE transaction_master.date = now());
ELSEIF trn_type = 'search' THEN
	UPDATE transaction_master SET search_id = (SELECT 			search_id FROM search_master WHERE transaction_master.date =now());
ELSEIF trn_type = 'sales' THEN
	INSERT INTO sales_master(tr_id)
    VALUES(transaction_master.trn_id);
	UPDATE transaction_master SET sales_id = (SELECT sales_id FROM sales_master WHERE transaction_master.date = now());
ELSEIF trn_type = 'sales return' THEN
	UPDATE transaction_master SET sales_id = (SELECT sales_id FROM sales_master WHERE transaction_master.date = now());
END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `user_master`
--

CREATE TABLE `user_master` (
  `u_id` int(10) NOT NULL,
  `full_name` varchar(30) DEFAULT NULL,
  `user_name` varchar(30) NOT NULL,
  `password` varchar(20) NOT NULL,
  `gender` char(2) NOT NULL,
  `contact_no` int(11) NOT NULL,
  `city` varchar(20) NOT NULL,
  `user_type` set('customer','admin') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `books_desc`
--
ALTER TABLE `books_desc`
  ADD PRIMARY KEY (`book_id`),
  ADD UNIQUE KEY `category` (`category`);

--
-- Indexes for table `books_master`
--
ALTER TABLE `books_master`
  ADD PRIMARY KEY (`book_id`),
  ADD UNIQUE KEY `book_title` (`book_title`);

--
-- Indexes for table `categories_master`
--
ALTER TABLE `categories_master`
  ADD PRIMARY KEY (`category_id`),
  ADD UNIQUE KEY `sub_category` (`sub_category`);

--
-- Indexes for table `sales_master`
--
ALTER TABLE `sales_master`
  ADD PRIMARY KEY (`sales_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `tr_id` (`tr_id`),
  ADD UNIQUE KEY `book_id` (`book_id`);

--
-- Indexes for table `search_master`
--
ALTER TABLE `search_master`
  ADD PRIMARY KEY (`search_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `book_title` (`book_title`),
  ADD UNIQUE KEY `cat` (`category`);

--
-- Indexes for table `transaction_master`
--
ALTER TABLE `transaction_master`
  ADD PRIMARY KEY (`trn_id`),
  ADD UNIQUE KEY `user_id` (`user_id`),
  ADD UNIQUE KEY `sales_id` (`sales_id`),
  ADD UNIQUE KEY `search_id` (`search_id`);

--
-- Indexes for table `user_master`
--
ALTER TABLE `user_master`
  ADD PRIMARY KEY (`u_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `books_desc`
--
ALTER TABLE `books_desc`
  MODIFY `book_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `books_master`
--
ALTER TABLE `books_master`
  MODIFY `book_id` int(20) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `categories_master`
--
ALTER TABLE `categories_master`
  MODIFY `category_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `sales_master`
--
ALTER TABLE `sales_master`
  MODIFY `sales_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `search_master`
--
ALTER TABLE `search_master`
  MODIFY `search_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `transaction_master`
--
ALTER TABLE `transaction_master`
  MODIFY `trn_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `user_master`
--
ALTER TABLE `user_master`
  MODIFY `u_id` int(10) NOT NULL AUTO_INCREMENT;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `books_desc`
--
ALTER TABLE `books_desc`
  ADD CONSTRAINT `books_desc_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books_master` (`book_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `books_desc_ibfk_2` FOREIGN KEY (`category`) REFERENCES `categories_master` (`sub_category`) ON UPDATE CASCADE;

--
-- Constraints for table `sales_master`
--
ALTER TABLE `sales_master`
  ADD CONSTRAINT `sales_master_ibfk_1` FOREIGN KEY (`book_id`) REFERENCES `books_master` (`book_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_master_ibfk_2` FOREIGN KEY (`user_id`) REFERENCES `user_master` (`u_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `sales_master_ibfk_3` FOREIGN KEY (`tr_id`) REFERENCES `transaction_master` (`trn_id`) ON UPDATE CASCADE;

--
-- Constraints for table `search_master`
--
ALTER TABLE `search_master`
  ADD CONSTRAINT `search_master_ibfk_2` FOREIGN KEY (`category`) REFERENCES `categories_master` (`sub_category`) ON UPDATE CASCADE,
  ADD CONSTRAINT `search_master_ibfk_3` FOREIGN KEY (`book_title`) REFERENCES `books_master` (`book_title`) ON UPDATE CASCADE,
  ADD CONSTRAINT `search_master_ibfk_4` FOREIGN KEY (`user_id`) REFERENCES `user_master` (`u_id`) ON UPDATE CASCADE;

--
-- Constraints for table `transaction_master`
--
ALTER TABLE `transaction_master`
  ADD CONSTRAINT `transaction_master_ibfk_1` FOREIGN KEY (`user_id`) REFERENCES `user_master` (`u_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `transaction_master_ibfk_2` FOREIGN KEY (`sales_id`) REFERENCES `sales_master` (`sales_id`) ON UPDATE CASCADE,
  ADD CONSTRAINT `transaction_master_ibfk_3` FOREIGN KEY (`search_id`) REFERENCES `search_master` (`search_id`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
