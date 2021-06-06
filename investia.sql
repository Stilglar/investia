-- phpMyAdmin SQL Dump
-- version 5.1.0
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Jun 06, 2021 at 07:35 PM
-- Server version: 10.4.18-MariaDB
-- PHP Version: 7.4.16

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `investia`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_ConsultaReservas` (IN `p_idEquipo` TINYINT, IN `p_semanas` TINYINT)  BEGIN
	
    DECLARE v_primerDia DATE;
    DECLARE v_ultimoDia DATE;
    
    -- v_primerDia será la fecha del Lunes de la semana que estamos consultando (semana actual = 0)
    SET v_primerDia = DATE_ADD(DATE_SUB(CURRENT_DATE, INTERVAL(WEEKDAY(CURRENT_DATE)) DAY), INTERVAL (7 * p_semanas) DAY);
    -- v_ultimoDia será la fecha del Domingo de la semana que estamos consultando (semana actual = 0)
    SET v_ultimoDia = DATE_ADD(DATE_ADD(CURRENT_DATE, INTERVAL(6-WEEKDAY(CURRENT_DATE)) DAY), INTERVAL (7 * p_semanas) DAY);

    SELECT idPrestamo, usuario, fechaInicio, fechaFin, TIME_FORMAT(horaInicio, '%H:%i') AS horaInicio, TIME_FORMAT(horaFin, '%H:%i') AS horaFin
    FROM reservas 
    WHERE finalizada = 0 AND estado = 1 AND idEquipo = p_idEquipo AND ((fechaInicio BETWEEN v_primerDia AND v_ultimoDia) OR (fechaFin BETWEEN v_primerDia AND v_ultimoDia) OR (fechaInicio < v_primerDia AND fechaFin > v_ultimoDia))
    ORDER BY fechaInicio ASC, fechaFin ASC, horaInicio ASC;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_ConsultarSolicitudes` ()  SELECT r.idPrestamo, e.nombre, r.usuario, CONCAT(DATE_FORMAT(r.fechaInicio,'%d-%m-%Y'),' ',TIME_FORMAT(r.horaInicio, '%H:%i')) AS inicio, CONCAT(DATE_FORMAT(r.fechaFin,'%d-%m-%Y'),' ',TIME_FORMAT(r.horaFin, '%H:%i')) AS final
FROM reservas AS r
JOIN equipos AS e
ON r.idEquipo = e.idEquipo
WHERE estado = 0 AND finalizada = 0$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_Equipos` ()  SELECT e.idEquipo, e.nombre, t.tipo
FROM equipos AS e
JOIN tipo_equipos AS t
ON e.idTipo = t.idTipo$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_LimpiarReservas` ()  UPDATE reservas
SET finalizada = 1
WHERE (fechaFin <= CURRENT_DATE) AND (finalizada = 0)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_ProcesarSolicitud` (IN `p_idPrestamo` INT, IN `p_supervisor` VARCHAR(20), IN `p_decision` TINYINT(1), OUT `p_salida` INT)  IF EXISTS (	SELECT idPrestamo
          	FROM reservas
          	WHERE idPrestamo = p_idPrestamo AND estado = 0) THEN
	
    INSERT INTO concesion_reservas(idPrestamo,fechaDecision,supervisor,decision)
    VALUES (p_idPrestamo,NOW(),p_supervisor,p_decision);
    
    SET p_salida = p_idPrestamo;
    
ELSE

	SET p_salida = -1;

END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `pr_RealizarReserva` (IN `p_usuario` VARCHAR(20), IN `p_idEquipo` TINYINT, IN `p_fechaInicio` DATE, IN `p_fechaFin` DATE, IN `p_horaInicio` TIME, IN `p_horaFin` TIME, OUT `p_salida` TINYINT)  BEGIN
    
    DECLARE v_curFin tinyint DEFAULT 0;
    DECLARE v_Inicio DATETIME;
    DECLARE v_Fin DATETIME;
    DECLARE v_NuevoInicio DATETIME;
    DECLARE v_NuevoFin DATETIME;
    DECLARE v_estado TINYINT DEFAULT 1;
    
    DECLARE cur_reservas CURSOR
    FOR SELECT CONCAT(fechaInicio,' ',horaInicio), CONCAT(fechaFin,' ',horaFin)
    	FROM reservas
        WHERE idEquipo = p_idEquipo AND finalizada = 0 AND estado = 1;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_curFin=1;
    
    DECLARE EXIT HANDLER FOR 1452 -- FK
    BEGIN
       SET p_salida=-1;
    END;
    
    SET p_salida = 0;
    SET v_NuevoInicio = CONCAT(p_fechaInicio,' ',p_horaInicio);
    SET v_NuevoFin = CONCAT(p_fechaFin,' ',p_horaFin);
    
    IF p_fechaInicio > p_fechaFin THEN

        SET p_salida = -2;

    ELSEIF (p_fechaInicio = p_fechaFin) AND (p_horaInicio >= p_horaFin) THEN
    
    	SET p_salida = -3;
    
    ELSEIF (p_fechaInicio < CURRENT_DATE) THEN
        
        SET p_salida = -4;
        
    END IF;
    
    IF p_salida = 0 THEN
    
        OPEN cur_reservas;
        inicio: LOOP

            FETCH cur_reservas INTO v_Inicio, v_Fin;

            IF v_curFin = 1 THEN
                LEAVE inicio;
            END IF;
		
        	IF (v_NuevoInicio > v_Inicio AND v_NuevoInicio < v_Fin) OR (v_NuevoFin > v_Inicio AND v_NuevoFin < v_Fin) OR (v_NuevoInicio < v_Inicio AND v_NuevoFin > v_Fin) OR (v_NuevoInicio = v_Inicio AND v_NuevoFin = v_Fin) THEN
            
            	SET p_salida = -5;
                LEAVE inicio;
            
            END IF;
		
        END LOOP inicio;

        CLOSE cur_reservas;

    END IF;
    
    IF p_salida = 0 THEN
    
        IF(	SELECT e.idTipo
			FROM equipos AS e
			JOIN tipo_equipos AS t
			ON e.idTipo = t.idTipo
			WHERE e.idEquipo = p_idEquipo) = 4 THEN
            
            SET v_estado = 0;
        
        END IF;
        
        INSERT INTO reservas(usuario,idEquipo,estado,fechaInicio,fechaFin,horaInicio,horaFin)
        VALUES (p_usuario,p_idEquipo,v_estado,p_fechaInicio,p_fechaFin,p_horaInicio,p_horaFin);
	
    END IF;

END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `compras`
--

CREATE TABLE `compras` (
  `idPedido` mediumint(9) NOT NULL,
  `fechaAprobacion` date NOT NULL,
  `fechaEntrega` date NOT NULL,
  `precio` mediumint(9) NOT NULL,
  `idSolicitud` mediumint(9) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `concesion_reservas`
--

CREATE TABLE `concesion_reservas` (
  `idPrestamo` int(11) NOT NULL,
  `fechaDecision` datetime NOT NULL,
  `supervisor` varchar(20) NOT NULL,
  `decision` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `concesion_reservas`
--

INSERT INTO `concesion_reservas` (`idPrestamo`, `fechaDecision`, `supervisor`, `decision`) VALUES
(112, '2021-06-04 23:12:32', 'fmermela', 1),
(114, '2021-06-05 17:17:16', 'fmermela', 1),
(115, '2021-06-05 17:31:24', 'fmermela', 1),
(116, '2021-06-05 17:52:38', 'fmermela', -1),
(117, '2021-06-05 17:56:34', 'fmermela', 1);

--
-- Triggers `concesion_reservas`
--
DELIMITER $$
CREATE TRIGGER `tr_actualizarReserva` AFTER INSERT ON `concesion_reservas` FOR EACH ROW IF new.decision = 1 THEN

	UPDATE reservas
    SET estado = 1
    WHERE reservas.idPrestamo = new.idPrestamo;

ELSEIF new.decision = -1 THEN

	UPDATE reservas
    SET estado = -1
    WHERE reservas.idPrestamo = new.idPrestamo;

END IF
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `equipos`
--

CREATE TABLE `equipos` (
  `idEquipo` tinyint(4) NOT NULL,
  `idTipo` tinyint(4) NOT NULL,
  `nombre` varchar(20) NOT NULL,
  `disponible` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `equipos`
--

INSERT INTO `equipos` (`idEquipo`, `idTipo`, `nombre`, `disponible`) VALUES
(1, 1, 'pcPrestamo-1', 1),
(2, 1, 'pcPrestamo-2', 1),
(3, 1, 'pcPrestamo-3', 1),
(4, 2, 'auriculares-1', 1),
(5, 2, 'auriculares-2', 1),
(6, 2, 'auriculares-3', 1),
(7, 2, 'auriculares-4', 1),
(8, 2, 'auriculares-5', 1),
(9, 3, 'webcam-1', 1),
(10, 3, 'webcam-2', 1),
(11, 3, 'webcam-3', 1),
(12, 4, 'coche-1', 1),
(13, 5, 'Sala-1', 1),
(14, 5, 'Sala-2', 1);

-- --------------------------------------------------------

--
-- Table structure for table `reservas`
--

CREATE TABLE `reservas` (
  `idPrestamo` int(11) NOT NULL,
  `usuario` varchar(20) NOT NULL,
  `idEquipo` tinyint(4) NOT NULL,
  `estado` tinyint(1) NOT NULL,
  `fechaInicio` date NOT NULL,
  `fechaFin` date NOT NULL,
  `horaInicio` time NOT NULL,
  `horaFin` time NOT NULL,
  `finalizada` tinyint(1) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `reservas`
--

INSERT INTO `reservas` (`idPrestamo`, `usuario`, `idEquipo`, `estado`, `fechaInicio`, `fechaFin`, `horaInicio`, `horaFin`, `finalizada`) VALUES
(71, 'bcamelas', 1, 1, '2021-05-27', '2021-05-27', '08:00:00', '10:00:00', 1),
(72, 'bcamelas', 1, 1, '2021-05-27', '2021-05-27', '10:00:00', '13:00:00', 1),
(73, 'bcamelas', 1, 1, '2021-05-27', '2021-05-27', '13:00:00', '16:30:00', 1),
(74, 'bcamelas', 2, 1, '2021-05-27', '2021-05-27', '14:00:00', '16:00:00', 1),
(75, 'bcamelas', 2, 1, '2021-05-27', '2021-05-27', '11:00:00', '12:00:00', 1),
(76, 'bcamelas', 2, 1, '2021-05-27', '2021-05-27', '08:00:00', '10:00:00', 1),
(77, 'bcamelas', 2, 1, '2021-05-18', '2021-05-18', '11:00:00', '12:00:00', 1),
(78, 'bcamelas', 2, 1, '2021-05-18', '2021-05-18', '08:00:00', '10:00:00', 1),
(79, 'bcamelas', 2, 1, '2021-05-17', '2021-05-17', '08:30:00', '12:30:00', 1),
(80, 'bcamelas', 2, 1, '2021-05-19', '2021-05-20', '10:30:00', '13:00:00', 1),
(82, 'bcamelas', 2, 1, '2021-05-30', '2021-06-03', '08:00:00', '09:30:00', 0),
(84, 'bcamelas', 1, 1, '2021-06-01', '2021-06-01', '08:30:00', '09:30:00', 0),
(85, 'bcamelas', 1, 1, '2021-06-01', '2021-06-01', '10:00:00', '12:00:00', 0),
(86, 'bcamelas', 1, 1, '2021-05-31', '2021-05-31', '10:00:00', '13:00:00', 0),
(87, 'bcamelas', 1, 1, '2021-06-03', '2021-06-03', '08:00:00', '10:00:00', 0),
(88, 'bcamelas', 10, 1, '2021-06-02', '2021-06-02', '10:00:00', '11:00:00', 0),
(89, 'bcamelas', 2, 1, '2021-06-08', '2021-06-09', '15:00:00', '09:00:00', 0),
(90, 'bcamelas', 1, 1, '2021-06-04', '2021-06-04', '12:00:00', '15:00:00', 0),
(91, 'bcamelas', 1, 1, '2021-06-01', '2021-06-01', '12:00:00', '14:00:00', 0),
(92, 'bcamelas', 1, 1, '2021-06-02', '2021-06-02', '11:00:00', '13:00:00', 0),
(93, 'edelbosque', 3, 1, '2021-06-02', '2021-06-02', '08:00:00', '10:30:00', 0),
(94, 'edelbosque', 3, 1, '2021-06-04', '2021-06-04', '11:00:00', '12:30:00', 0),
(95, 'edelbosque', 1, 1, '2021-06-03', '2021-06-03', '11:00:00', '12:30:00', 0),
(96, 'edelbosque', 1, 1, '2021-06-07', '2021-06-08', '15:00:00', '09:00:00', 0),
(97, 'edelbosque', 1, 1, '2021-06-07', '2021-06-07', '09:00:00', '10:30:00', 0),
(98, 'edelbosque', 1, 1, '2021-06-07', '2021-06-07', '11:00:00', '13:00:00', 0),
(99, 'edelbosque', 1, 1, '2021-06-08', '2021-06-08', '10:00:00', '11:30:00', 0),
(100, 'edelbosque', 1, 1, '2021-06-08', '2021-06-08', '12:00:00', '15:00:00', 0),
(101, 'edelbosque', 1, 1, '2021-06-09', '2021-06-09', '08:30:00', '11:00:00', 0),
(102, 'edelbosque', 1, 1, '2021-06-09', '2021-06-09', '11:00:00', '14:30:00', 0),
(103, 'edelbosque', 1, 1, '2021-06-09', '2021-06-10', '15:00:00', '12:00:00', 0),
(104, 'edelbosque', 1, 1, '2021-06-10', '2021-06-10', '12:00:00', '14:00:00', 0),
(105, 'edelbosque', 1, 1, '2021-06-02', '2021-06-02', '13:00:00', '17:00:00', 0),
(106, 'edelbosque', 1, 1, '2021-06-08', '2021-06-08', '15:00:00', '17:00:00', 0),
(107, 'edelbosque', 1, 1, '2021-06-10', '2021-06-11', '14:00:00', '10:00:00', 0),
(108, 'edelbosque', 1, 1, '2021-06-11', '2021-06-11', '10:30:00', '13:00:00', 0),
(110, 'fmermela', 1, 1, '2021-06-04', '2021-06-04', '08:00:00', '10:00:00', 0),
(111, 'fmermela', 3, 1, '2021-06-04', '2021-06-04', '12:30:00', '14:00:00', 0),
(112, 'fmermela', 12, 1, '2021-06-04', '2021-06-04', '09:00:00', '14:00:00', 0),
(114, 'fmermela', 12, 1, '2021-06-07', '2021-06-07', '09:00:00', '12:00:00', 0),
(115, 'fmermela', 12, 1, '2021-06-09', '2021-06-09', '13:00:00', '14:30:00', 0),
(116, 'bcamelas', 12, -1, '2021-06-08', '2021-06-08', '09:00:00', '13:00:00', 0),
(117, 'edelbosque', 12, 1, '2021-06-08', '2021-06-08', '09:00:00', '13:00:00', 0);

-- --------------------------------------------------------

--
-- Table structure for table `solicitudes`
--

CREATE TABLE `solicitudes` (
  `idSolicitud` mediumint(9) NOT NULL,
  `fecha` date NOT NULL,
  `usuario` varchar(20) NOT NULL,
  `detalles` varchar(600) NOT NULL,
  `estado` tinyint(1) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- --------------------------------------------------------

--
-- Table structure for table `tipo_equipos`
--

CREATE TABLE `tipo_equipos` (
  `idTipo` tinyint(4) NOT NULL,
  `tipo` varchar(15) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

--
-- Dumping data for table `tipo_equipos`
--

INSERT INTO `tipo_equipos` (`idTipo`, `tipo`) VALUES
(1, 'Portatiles'),
(2, 'Auriculares'),
(3, 'Webcams'),
(4, 'Coches'),
(5, 'Salas');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `compras`
--
ALTER TABLE `compras`
  ADD PRIMARY KEY (`idPedido`),
  ADD KEY `FK_pedido|solicitud` (`idSolicitud`);

--
-- Indexes for table `concesion_reservas`
--
ALTER TABLE `concesion_reservas`
  ADD PRIMARY KEY (`idPrestamo`);

--
-- Indexes for table `equipos`
--
ALTER TABLE `equipos`
  ADD PRIMARY KEY (`idEquipo`),
  ADD KEY `FK_equipos|tipo` (`idTipo`);

--
-- Indexes for table `reservas`
--
ALTER TABLE `reservas`
  ADD PRIMARY KEY (`idPrestamo`),
  ADD KEY `FK_prestamos|equipos` (`idEquipo`);

--
-- Indexes for table `solicitudes`
--
ALTER TABLE `solicitudes`
  ADD PRIMARY KEY (`idSolicitud`);

--
-- Indexes for table `tipo_equipos`
--
ALTER TABLE `tipo_equipos`
  ADD PRIMARY KEY (`idTipo`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `compras`
--
ALTER TABLE `compras`
  MODIFY `idPedido` mediumint(9) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT for table `equipos`
--
ALTER TABLE `equipos`
  MODIFY `idEquipo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT for table `reservas`
--
ALTER TABLE `reservas`
  MODIFY `idPrestamo` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=118;

--
-- AUTO_INCREMENT for table `solicitudes`
--
ALTER TABLE `solicitudes`
  MODIFY `idSolicitud` mediumint(9) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `compras`
--
ALTER TABLE `compras`
  ADD CONSTRAINT `FK_pedido|solicitud` FOREIGN KEY (`idSolicitud`) REFERENCES `solicitudes` (`idSolicitud`);

--
-- Constraints for table `concesion_reservas`
--
ALTER TABLE `concesion_reservas`
  ADD CONSTRAINT `FK_concesion|reservas` FOREIGN KEY (`idPrestamo`) REFERENCES `reservas` (`idPrestamo`);

--
-- Constraints for table `equipos`
--
ALTER TABLE `equipos`
  ADD CONSTRAINT `FK_equipos|tipo` FOREIGN KEY (`idTipo`) REFERENCES `tipo_equipos` (`idTipo`);

--
-- Constraints for table `reservas`
--
ALTER TABLE `reservas`
  ADD CONSTRAINT `FK_prestamos|equipos` FOREIGN KEY (`idEquipo`) REFERENCES `equipos` (`idEquipo`);

DELIMITER $$
--
-- Events
--
CREATE DEFINER=`root`@`localhost` EVENT `ev_limpiarReservas` ON SCHEDULE EVERY 1 WEEK STARTS '2021-06-05 22:00:00' ON COMPLETION NOT PRESERVE ENABLE DO CALL pr_LimpiarReservas()$$

DELIMITER ;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
