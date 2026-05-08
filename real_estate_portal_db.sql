-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: May 08, 2026 at 05:00 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `real_estate_portal_db`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`` PROCEDURE `AddOrUpdateUser` (IN `p_userId` INT, IN `p_userName` VARCHAR(50), IN `p_contactInfo` VARCHAR(200), IN `p_passwordHash` VARCHAR(255), IN `p_userType` ENUM('agent','buyer','renter'))   BEGIN

IF p_userId IS NULL THEN

    INSERT INTO Users(userName, contactInfo, passwordHash, userType)
    VALUES(p_userName, p_contactInfo, p_passwordHash, p_userType);

ELSE

    UPDATE Users
    SET
        userName = p_userName,
        contactInfo = p_contactInfo,
        passwordHash = p_passwordHash,
        userType = p_userType
    WHERE userId = p_userId;

END IF;

END$$

CREATE DEFINER=`` PROCEDURE `ProcessTransaction` (IN `p_propertyId` INT, IN `p_userId` INT, IN `p_transactionType` ENUM('sale','rental'), IN `p_amount` DECIMAL(12,2))   BEGIN

INSERT INTO Transactions(
    propertyId,
    userId,
    transactionType,
    amount
)
VALUES(
    p_propertyId,
    p_userId,
    p_transactionType,
    p_amount
);

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `favorites`
--

CREATE TABLE `favorites` (
  `favoriteId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `savedDate` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `favorites`
--

INSERT INTO `favorites` (`favoriteId`, `userId`, `propertyId`, `savedDate`) VALUES
(1, 2, 1, '2026-05-05 20:45:19'),
(2, 3, 2, '2026-05-05 20:45:19'),
(3, 2, 3, '2026-05-05 20:45:19');

-- --------------------------------------------------------

--
-- Table structure for table `inquiries`
--

CREATE TABLE `inquiries` (
  `inquiryId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `message` varchar(255) NOT NULL,
  `inquiryDate` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `inquiries`
--

INSERT INTO `inquiries` (`inquiryId`, `userId`, `propertyId`, `message`, `inquiryDate`) VALUES
(1, 2, 1, 'Is this property still available?', '2026-05-05 20:45:19'),
(2, 3, 2, 'Can I schedule a viewing?', '2026-05-05 20:45:19'),
(3, 2, 3, 'What are the HOA fees?', '2026-05-05 20:45:19'),
(4, 2, 4, 'hello', '2026-05-06 22:39:58'),
(5, 2, 4, 'I am interested in the property', '2026-05-06 22:41:20');

-- --------------------------------------------------------

--
-- Table structure for table `properties`
--

CREATE TABLE `properties` (
  `propertyId` int(11) NOT NULL,
  `title` varchar(100) NOT NULL,
  `propertyType` varchar(50) NOT NULL,
  `address` varchar(200) NOT NULL,
  `city` varchar(100) NOT NULL,
  `price` decimal(12,2) NOT NULL,
  `status` enum('available','sold','rented') NOT NULL DEFAULT 'available',
  `agentId` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `properties`
--

INSERT INTO `properties` (`propertyId`, `title`, `propertyType`, `address`, `city`, `price`, `status`, `agentId`) VALUES
(1, 'Luxury Apartment', 'Apartment', '123 Main St', 'New York', 250000.00, 'sold', 1),
(2, 'Family House', 'House', '45 Park Ave', 'Chicago', 450000.00, 'rented', 1),
(3, 'Beach Condo', 'Condo', '78 Ocean Dr', 'Miami', 350000.00, 'sold', 1),
(4, 'test property', 'house', '100 main street', 'boston', 50000.00, 'available', 1),
(5, 'hello', 'house', '123', 'ny', 5000000.00, 'available', 8);

-- --------------------------------------------------------

--
-- Stand-in structure for view `propertylistingview`
-- (See below for the actual view)
--
CREATE TABLE `propertylistingview` (
`propertyId` int(11)
,`title` varchar(100)
,`propertyType` varchar(50)
,`city` varchar(100)
,`price` decimal(12,2)
,`status` enum('available','sold','rented')
,`agentName` varchar(50)
);

-- --------------------------------------------------------

--
-- Table structure for table `transactions`
--

CREATE TABLE `transactions` (
  `transactionId` int(11) NOT NULL,
  `propertyId` int(11) NOT NULL,
  `userId` int(11) NOT NULL,
  `transactionType` enum('sale','rental') NOT NULL,
  `transactionDate` datetime NOT NULL DEFAULT current_timestamp(),
  `amount` decimal(12,2) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `transactions`
--

INSERT INTO `transactions` (`transactionId`, `propertyId`, `userId`, `transactionType`, `transactionDate`, `amount`) VALUES
(1, 1, 2, 'sale', '2026-05-05 20:45:19', 250000.00),
(2, 2, 3, 'rental', '2026-05-05 20:45:19', 2000.00),
(3, 3, 2, 'sale', '2026-05-05 20:45:19', 350000.00);

--
-- Triggers `transactions`
--
DELIMITER $$
CREATE TRIGGER `AfterTransactionInsert` AFTER INSERT ON `transactions` FOR EACH ROW BEGIN
    IF NEW.transactionType = 'sale' THEN
        UPDATE Properties
        SET status = 'sold'
        WHERE propertyId = NEW.propertyId;
    ELSEIF NEW.transactionType = 'rental' THEN
        UPDATE Properties
        SET status = 'rented'
        WHERE propertyId = NEW.propertyId;
    END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `users`
--

CREATE TABLE `users` (
  `userId` int(11) NOT NULL,
  `userName` varchar(50) NOT NULL,
  `contactInfo` varchar(200) DEFAULT NULL,
  `passwordHash` varchar(255) NOT NULL,
  `userType` enum('agent','buyer','renter') NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_general_ci;

--
-- Dumping data for table `users`
--

INSERT INTO `users` (`userId`, `userName`, `contactInfo`, `passwordHash`, `userType`) VALUES
(1, 'agent1', 'agent1@email.com', 'pass123', 'agent'),
(2, 'buyer1', 'buyer1@email.com', 'pass123', 'buyer'),
(3, 'renter1', 'renter1@email.com', 'pass123', 'renter'),
(4, 'testuser', '2121331111', '', 'agent'),
(5, 'test3', '2122121111', '', 'agent'),
(7, 'test8', '222222222222222', '1234', 'renter'),
(8, 'leh', '0000000000000', '1234', 'agent'),
(9, 'peter', '4444444444', '1234', 'buyer');

-- --------------------------------------------------------

--
-- Structure for view `propertylistingview`
--
DROP TABLE IF EXISTS `propertylistingview`;

CREATE ALGORITHM=UNDEFINED DEFINER=`` SQL SECURITY DEFINER VIEW `propertylistingview`  AS SELECT `properties`.`propertyId` AS `propertyId`, `properties`.`title` AS `title`, `properties`.`propertyType` AS `propertyType`, `properties`.`city` AS `city`, `properties`.`price` AS `price`, `properties`.`status` AS `status`, `users`.`userName` AS `agentName` FROM (`properties` join `users` on(`properties`.`agentId` = `users`.`userId`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `favorites`
--
ALTER TABLE `favorites`
  ADD PRIMARY KEY (`favoriteId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD PRIMARY KEY (`inquiryId`),
  ADD KEY `userId` (`userId`),
  ADD KEY `propertyId` (`propertyId`);

--
-- Indexes for table `properties`
--
ALTER TABLE `properties`
  ADD PRIMARY KEY (`propertyId`),
  ADD KEY `agentId` (`agentId`);

--
-- Indexes for table `transactions`
--
ALTER TABLE `transactions`
  ADD PRIMARY KEY (`transactionId`),
  ADD KEY `propertyId` (`propertyId`),
  ADD KEY `userId` (`userId`);

--
-- Indexes for table `users`
--
ALTER TABLE `users`
  ADD PRIMARY KEY (`userId`),
  ADD UNIQUE KEY `userName` (`userName`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `favorites`
--
ALTER TABLE `favorites`
  MODIFY `favoriteId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `inquiries`
--
ALTER TABLE `inquiries`
  MODIFY `inquiryId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `properties`
--
ALTER TABLE `properties`
  MODIFY `propertyId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=6;

--
-- AUTO_INCREMENT for table `transactions`
--
ALTER TABLE `transactions`
  MODIFY `transactionId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT for table `users`
--
ALTER TABLE `users`
  MODIFY `userId` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `favorites`
--
ALTER TABLE `favorites`
  ADD CONSTRAINT `favorites_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`),
  ADD CONSTRAINT `favorites_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`);

--
-- Constraints for table `inquiries`
--
ALTER TABLE `inquiries`
  ADD CONSTRAINT `inquiries_ibfk_1` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`),
  ADD CONSTRAINT `inquiries_ibfk_2` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`);

--
-- Constraints for table `properties`
--
ALTER TABLE `properties`
  ADD CONSTRAINT `properties_ibfk_1` FOREIGN KEY (`agentId`) REFERENCES `users` (`userId`);

--
-- Constraints for table `transactions`
--
ALTER TABLE `transactions`
  ADD CONSTRAINT `transactions_ibfk_1` FOREIGN KEY (`propertyId`) REFERENCES `properties` (`propertyId`),
  ADD CONSTRAINT `transactions_ibfk_2` FOREIGN KEY (`userId`) REFERENCES `users` (`userId`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
