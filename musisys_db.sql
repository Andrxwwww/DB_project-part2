-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Tempo de geração: 19-Dez-2023 às 00:21
-- Versão do servidor: 10.4.28-MariaDB
-- versão do PHP: 8.2.4

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Banco de dados: `musisys_db`
--

DELIMITER $$
--
-- Procedimentos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `Ainda_nao_entrevistados_por` (IN `nome_jornalista` VARCHAR(60))   BEGIN
    DECLARE codigo_jornalista INT;

    SELECT num_carteira_profissional INTO codigo_jornalista
    FROM jornalista
    WHERE (SELECT identificador FROM espetador WHERE nome_jornalista = nome) = Espetador_identificador;

    SELECT DISTINCT
        p.nome AS Nome_Artista
    FROM Participante p
    JOIN contrata c ON p.codigo = c.Participante_codigo_
    WHERE c.Edicao_numero_ = (SELECT MAX(numero) FROM Edicao) 
      AND NOT EXISTS (
          SELECT 1
          FROM Entrevista e
          WHERE p.codigo = e.Participante_codigo_
            AND e.Jornalista_num_carteira_profissional_ = codigo_jornalista
      );
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `clonar_edicao` (IN `original_edition_number` INT(4), IN `clone_start_date` DATE)   BEGIN
    DECLARE original_start_date DATE;
    DECLARE original_end_date DATE;
    DECLARE days_difference INT;
    DECLARE new_edition_number TINYINT;
    DECLARE current_day INT;

    -- obter a data de inicio e fim da edicao original
    SELECT data_inicio, data_fim
    INTO original_start_date, original_end_date
    FROM Edicao
    WHERE numero = original_edition_number;

    -- calcular o numero de dias entre a data de inicio e fim da edicao original
    SET days_difference = DATEDIFF(original_end_date, original_start_date);

    -- determinar o numero da nova edicao
    SET new_edition_number = (SELECT MAX(numero) + 1 FROM Edicao);

    -- clonar a edicao
    INSERT INTO Edicao(numero, nome, localidade, local, data_inicio, data_fim, lotacao)
    SELECT new_edition_number, nome, localidade, local, clone_start_date, DATE_ADD(clone_start_date, INTERVAL days_difference DAY), lotacao
    FROM Edicao
    WHERE numero = original_edition_number;
    
  -- clonar os dias do festival para obter a data final
    SET current_day = 0;
    WHILE current_day <= days_difference DO
        INSERT INTO Dia_festival(Edicao_numero, data, qtd_espetadores)
        VALUES (new_edition_number, DATE_ADD(clone_start_date, INTERVAL current_day DAY), 0);
        SET current_day = current_day + 1;
    END WHILE;
    
    -- clonar os palcos -> dá um erro de nao meter o codigo + 1
  INSERT INTO Palco(Edicao_numero, codigo, nome)
  SELECT new_edition_number,codigo + 1, nome
  FROM Palco 
  WHERE Edicao_numero = original_edition_number;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `criarDias_festival` (IN `edicao` INT, IN `data_inicio` DATE, IN `data_fim` DATE)   BEGIN 
    DECLARE current_day INT;
    
    SET current_day = 0;
    WHILE current_day <= DATEDIFF(data_fim, data_inicio) DO
        INSERT INTO Dia_festival(Edicao_numero, data, qtd_espetadores)
        VALUES (edicao, DATE_ADD(data_inicio, INTERVAL current_day DAY), 0); 
        SET current_day = current_day + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `criar_edicao` (IN `nmr_edicao` TINYINT(4), IN `nome_edicao` VARCHAR(60), IN `localidade_edicao` VARCHAR(60), IN `local_edicao` VARCHAR(60), IN `data_inicio_edicao` DATE, IN `data_fim_edicao` DATE, IN `lotacao_edicao` INT(11))   BEGIN
  INSERT INTO Edicao(numero,nome, localidade, local, data_inicio, data_fim, lotacao)
    VALUES (nmr_edicao, nome_edicao, localidade_edicao, local_edicao, data_inicio_edicao, data_fim_edicao, lotacao_edicao);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `criar_palcos` (IN `numero_edicao` TINYINT(4), IN `codigo` TINYINT(4))   BEGIN
  INSERT INTO palco(Edicao_numero,codigo,nome)
    VALUES(numero_edicao, codigo_palco, nome);
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `Entrevistados_por` (IN `Edicao_numero_entrevista` INT(4), IN `nome_jornalista_entrevista` VARCHAR(60))   BEGIN
    DECLARE codigo_jornalista INT;
    
    SELECT num_carteira_profissional INTO codigo_jornalista
    FROM jornalista
    WHERE (SELECT identificador FROM espetador WHERE nome_jornalista_entrevista = nome) = Espetador_identificador;
    
    SELECT DISTINCT
     p.nome AS Nome_Artista
    FROM Participante p , entrevista e ,  contrata c ,jornalista j
    WHERE p.codigo = e.Participante_codigo_ AND c.Edicao_numero_= edicao_numero_entrevista AND e.Jornalista_num_carteira_profissional_ = j.num_carteira_profissional AND codigo_jornalista = e.Jornalista_num_carteira_profissional_;
END$$

--
-- Funções
--
CREATE DEFINER=`root`@`localhost` FUNCTION `calcular_media` (`ano` INT(6)) RETURNS INT(11)  BEGIN
    	DECLARE avg_lucro DECIMAL(10, 2);
    
    	SELECT IFNULL(AVG(cachet), 0)
    	INTO avg_lucro
    	FROM Contrata
    	WHERE YEAR(Dia_festival_data) = ano;

    	RETURN avg_lucro;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `calcular_num_participantes` () RETURNS INT(11)  BEGIN
    DECLARE num_participantes INT;

    SELECT COUNT(*) INTO num_participantes
    FROM participante
    WHERE codigo IN (SELECT Participante_codigo_
                     FROM contrata
                     WHERE Edicao_numero_ = (SELECT MAX(numero) FROM edicao));

    RETURN num_participantes;
END$$

CREATE DEFINER=`root`@`localhost` FUNCTION `Qtd_espetadores_no_dia` (`data_consulta` DATE) RETURNS INT(11)  BEGIN
    DECLARE quantidade INT;
    SELECT
        COUNT(b.Espetador_com_bilhete_Espetador_identificador)
    INTO quantidade
    FROM Dia_festival d , acesso a, Bilhete b
    WHERE a.Dia_festival_data_ = d.data AND a.Tipo_de_bilhete_Nome_ = b.Tipo_de_bilhete_Nome AND d.data = data_consulta;
    RETURN quantidade;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `acesso`
--

CREATE TABLE `acesso` (
  `Dia_festival_data_` date NOT NULL,
  `Tipo_de_bilhete_Nome_` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `acesso`
--

INSERT INTO `acesso` (`Dia_festival_data_`, `Tipo_de_bilhete_Nome_`) VALUES
('2023-12-05', 'diario_1'),
('2023-12-05', 'geral'),
('2023-12-06', 'diario_2'),
('2023-12-06', 'geral'),
('2023-12-07', 'diario_3'),
('2023-12-07', 'geral');

-- --------------------------------------------------------

--
-- Estrutura da tabela `bilhete`
--

CREATE TABLE `bilhete` (
  `num_serie` int(11) NOT NULL,
  `Tipo_de_bilhete_Nome` varchar(30) NOT NULL,
  `Espetador_com_bilhete_Espetador_identificador` int(11) DEFAULT NULL,
  `designacao` varchar(60) DEFAULT NULL,
  `devolvido` tinyint(1) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `bilhete`
--

INSERT INTO `bilhete` (`num_serie`, `Tipo_de_bilhete_Nome`, `Espetador_com_bilhete_Espetador_identificador`, `designacao`, `devolvido`) VALUES
(100, 'diario_1', 2, 'ye', 0),
(101, 'diario_1', 1, 'ye', 0),
(102, 'diario_1', 3, 'ye', 0),
(103, 'geral', 3, 'ye', 0);

--
-- Acionadores `bilhete`
--
DELIMITER $$
CREATE TRIGGER `addBilhete` AFTER INSERT ON `bilhete` FOR EACH ROW BEGIN
  DECLARE data_festival DATE;
    
  IF NEW.devolvido = 0 THEN
  	IF  NEW.Tipo_de_bilhete_Nome LIKE 'diario%' THEN
   		SET data_festival = (SELECT Dia_festival_data_ FROM acesso WHERE Tipo_de_bilhete_Nome_ = NEW.Tipo_de_bilhete_Nome);
    	UPDATE Dia_festival
  		SET qtd_espetadores = qtd_espetadores + 1
    	WHERE data = data_festival;
    END IF;
  	IF NEW.Tipo_de_bilhete_Nome LIKE 'geral' THEN
    	UPDATE dia_festival
    	SET qtd_espetadores = qtd_espetadores + 1;
    END IF;
  END IF;
    
  IF (SELECT qtd_espetadores FROM Dia_festival WHERE data = data_festival) 
  > (SELECT lotacao FROM Edicao WHERE numero = (SELECT Edicao_numero FROM dia_festival WHERE data = data_festival))
  THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'A lotação diária do recinto já foi excedida.';
  END IF;
END
$$
DELIMITER ;
DELIMITER $$
CREATE TRIGGER `uptBilhete` AFTER UPDATE ON `bilhete` FOR EACH ROW BEGIN
  DECLARE data_festival DATE;
    
  IF NEW.devolvido = 1 THEN
  	IF  NEW.Tipo_de_bilhete_Nome LIKE 'diario%' THEN
   		SET data_festival = (SELECT Dia_festival_data_ FROM acesso WHERE Tipo_de_bilhete_Nome_ = NEW.Tipo_de_bilhete_Nome);
    	UPDATE Dia_festival
  		SET qtd_espetadores = qtd_espetadores - 1
    	WHERE data = data_festival;
    END IF;
  	IF NEW.Tipo_de_bilhete_Nome LIKE 'geral' THEN
    	UPDATE dia_festival
    	SET qtd_espetadores = qtd_espetadores - 1;
    END IF;
  END IF;
    
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `cartaz`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `cartaz` (
`Edicao_numero_` tinyint(4)
,`Participante_codigo_` smallint(6)
,`Nome_Artista` varchar(80)
,`Dia_festival_data` date
,`cachet` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `contrata`
--

CREATE TABLE `contrata` (
  `Edicao_numero_` tinyint(4) NOT NULL,
  `Participante_codigo_` smallint(6) NOT NULL,
  `cachet` int(11) DEFAULT NULL,
  `Palco_Edicao_numero` tinyint(4) NOT NULL,
  `Palco_codigo` tinyint(4) NOT NULL,
  `Dia_festival_data` date NOT NULL,
  `hora_inicio` time DEFAULT NULL,
  `hora_fim` time DEFAULT NULL,
  `Convidado_Edicao_numero_` tinyint(4) DEFAULT NULL,
  `Convidado_Participante_codigo_` smallint(6) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `contrata`
--

INSERT INTO `contrata` (`Edicao_numero_`, `Participante_codigo_`, `cachet`, `Palco_Edicao_numero`, `Palco_codigo`, `Dia_festival_data`, `hora_inicio`, `hora_fim`, `Convidado_Edicao_numero_`, `Convidado_Participante_codigo_`) VALUES
(1, 1, 5, 1, 2, '2023-12-05', NULL, NULL, NULL, NULL),
(1, 4, 111111, 1, 2, '2023-12-06', '11:02:39', '13:02:39', NULL, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `dia_festival`
--

CREATE TABLE `dia_festival` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `data` date NOT NULL,
  `qtd_espetadores` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `dia_festival`
--

INSERT INTO `dia_festival` (`Edicao_numero`, `data`, `qtd_espetadores`) VALUES
(1, '2023-12-05', 4),
(1, '2023-12-06', 1),
(1, '2023-12-07', 1),
(3, '2024-10-07', 0),
(3, '2024-10-08', 0),
(3, '2024-10-09', 0),
(3, '2024-10-10', 0);

-- --------------------------------------------------------

--
-- Estrutura da tabela `edicao`
--

CREATE TABLE `edicao` (
  `numero` tinyint(4) NOT NULL,
  `nome` varchar(60) DEFAULT NULL,
  `localidade` varchar(60) DEFAULT NULL,
  `local` varchar(60) DEFAULT NULL,
  `data_inicio` date DEFAULT NULL,
  `data_fim` date DEFAULT NULL,
  `lotacao` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `edicao`
--

INSERT INTO `edicao` (`numero`, `nome`, `localidade`, `local`, `data_inicio`, `data_fim`, `lotacao`) VALUES
(1, 'Primavera Sound', 'Porto', 'Porto', '2023-08-08', '2023-08-12', 20000),
(2, 'Primavera Sound', 'Porto', 'Porto', '2023-10-10', '2023-10-15', 10000),
(3, 'PRIMAVERA SOUND', 'porto', 'porto', '2024-10-07', '2024-10-10', 10000);

-- --------------------------------------------------------

--
-- Estrutura da tabela `elemento_grupo`
--

CREATE TABLE `elemento_grupo` (
  `Individual_Participante_codigo_` smallint(6) NOT NULL,
  `Grupo_Participante_codigo_` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `entrevista`
--

CREATE TABLE `entrevista` (
  `Participante_codigo_` smallint(6) NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL,
  `data` date DEFAULT NULL,
  `hora` time DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `entrevista`
--

INSERT INTO `entrevista` (`Participante_codigo_`, `Jornalista_num_carteira_profissional_`, `data`, `hora`) VALUES
(1, 1, '2023-12-06', '11:01:44'),
(4, 2, '2023-12-05', '17:44:27');

-- --------------------------------------------------------

--
-- Estrutura da tabela `espetador`
--

CREATE TABLE `espetador` (
  `identificador` int(11) NOT NULL,
  `nome` varchar(100) DEFAULT NULL,
  `genero` enum('M','F') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `espetador`
--

INSERT INTO `espetador` (`identificador`, `nome`, `genero`) VALUES
(1, 'Andre', 'M'),
(2, 'Jota', 'M'),
(3, 'Chico', 'M'),
(4, 'Alex', 'M');

-- --------------------------------------------------------

--
-- Estrutura da tabela `espetador_com_bilhete`
--

CREATE TABLE `espetador_com_bilhete` (
  `Espetador_identificador` int(11) NOT NULL,
  `idade` tinyint(6) DEFAULT NULL,
  `profissao` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `espetador_com_bilhete`
--

INSERT INTO `espetador_com_bilhete` (`Espetador_identificador`, `idade`, `profissao`) VALUES
(1, 19, NULL),
(2, 20, NULL),
(3, 19, NULL),
(4, 20, NULL);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estilo`
--

CREATE TABLE `estilo` (
  `Nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estilo`
--

INSERT INTO `estilo` (`Nome`) VALUES
('pop'),
('rap'),
('tecno');

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `estilos_musicais_por_edicao`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `estilos_musicais_por_edicao` (
`Edicao` tinyint(4)
,`Estilo` varchar(30)
,`Qtd_Artistas` bigint(21)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `estilo_de_artista`
--

CREATE TABLE `estilo_de_artista` (
  `Participante_codigo_` smallint(6) NOT NULL,
  `Estilo_Nome_` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `estilo_de_artista`
--

INSERT INTO `estilo_de_artista` (`Participante_codigo_`, `Estilo_Nome_`) VALUES
(1, 'rap'),
(2, 'tecno');

-- --------------------------------------------------------

--
-- Estrutura da tabela `grupo`
--

CREATE TABLE `grupo` (
  `Participante_codigo` smallint(6) NOT NULL,
  `qtd_elementos` tinyint(4) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `individual`
--

CREATE TABLE `individual` (
  `Participante_codigo` smallint(6) NOT NULL,
  `Pais_nome` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `jornalista`
--

CREATE TABLE `jornalista` (
  `Espetador_identificador` int(11) NOT NULL,
  `Media_nome` varchar(30) NOT NULL,
  `num_carteira_profissional` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `jornalista`
--

INSERT INTO `jornalista` (`Espetador_identificador`, `Media_nome`, `num_carteira_profissional`) VALUES
(3, 'RFM', 1),
(4, 'CNN', 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `livre_transito`
--

CREATE TABLE `livre_transito` (
  `Edicao_numero_` tinyint(4) NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL,
  `numero` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `livre_transito`
--

INSERT INTO `livre_transito` (`Edicao_numero_`, `Jornalista_num_carteira_profissional_`, `numero`) VALUES
(1, 1, 100);

-- --------------------------------------------------------

--
-- Estrutura da tabela `media`
--

CREATE TABLE `media` (
  `nome` varchar(30) NOT NULL,
  `tipo` enum('Rádio','TV','Jornal','Revista') DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `media`
--

INSERT INTO `media` (`nome`, `tipo`) VALUES
('CNN', 'Rádio'),
('RFM', 'Rádio'),
('RTP', 'TV');

-- --------------------------------------------------------

--
-- Estrutura da tabela `montado`
--

CREATE TABLE `montado` (
  `Palco_Edicao_numero_` tinyint(4) NOT NULL,
  `Palco_codigo_` tinyint(4) NOT NULL,
  `Tecnico_numero_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `montado`
--

INSERT INTO `montado` (`Palco_Edicao_numero_`, `Palco_codigo_`, `Tecnico_numero_`) VALUES
(1, 1, 3);

--
-- Acionadores `montado`
--
DELIMITER $$
CREATE TRIGGER `checkRoadieStage` BEFORE INSERT ON `montado` FOR EACH ROW BEGIN
  -- Check if the roadie is associated with any artist performing on the stage
  IF NOT EXISTS (
    SELECT 1
    FROM Contrata
    WHERE Palco_Edicao_numero = NEW.Palco_Edicao_numero_
      AND Palco_codigo = NEW.Palco_codigo_
      AND Participante_codigo_ IN (
        SELECT Participante_codigo
        FROM Roadie
        WHERE Tecnico_numero = NEW.Tecnico_numero_
      )
  ) THEN
    SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'Roadies can only set up the stage where their artist performs.';
  END IF;
END
$$
DELIMITER ;

-- --------------------------------------------------------

--
-- Estrutura da tabela `pais`
--

CREATE TABLE `pais` (
  `nome` varchar(60) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `palco`
--

CREATE TABLE `palco` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `codigo` tinyint(4) NOT NULL,
  `nome` varchar(30) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `palco`
--

INSERT INTO `palco` (`Edicao_numero`, `codigo`, `nome`) VALUES
(1, 1, 'pinguinho'),
(1, 2, 'verne'),
(2, 3, 'Nos Stage');

-- --------------------------------------------------------

--
-- Estrutura da tabela `papel`
--

CREATE TABLE `papel` (
  `Nome` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `papel_no_grupo`
--

CREATE TABLE `papel_no_grupo` (
  `Elemento_grupo_Individual_Participante_codigo__` smallint(6) NOT NULL,
  `Elemento_grupo_Grupo_Participante_codigo__` smallint(6) NOT NULL,
  `Papel_Nome_` varchar(30) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `participante`
--

CREATE TABLE `participante` (
  `edicao_num` tinyint(4) NOT NULL,
  `codigo` smallint(6) NOT NULL,
  `nome` varchar(80) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `participante`
--

INSERT INTO `participante` (`edicao_num`, `codigo`, `nome`) VALUES
(1, 1, 'Lil Snowy'),
(1, 2, 'Bruno Carvalho'),
(1, 3, 'Van zee'),
(1, 4, 'Travis Scott');

-- --------------------------------------------------------

--
-- Estrutura da tabela `reportagem`
--

CREATE TABLE `reportagem` (
  `Dia_festival_data_` date NOT NULL,
  `Jornalista_num_carteira_profissional_` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `reportagem`
--

INSERT INTO `reportagem` (`Dia_festival_data_`, `Jornalista_num_carteira_profissional_`) VALUES
('2023-12-06', 1);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `resultados_diarios`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `resultados_diarios` (
`Dia_festival_data` date
,`Quantidade_Espetadores` int(11)
,`Faturacao` decimal(32,6)
);

-- --------------------------------------------------------

--
-- Estrutura da tabela `roadie`
--

CREATE TABLE `roadie` (
  `Tecnico_numero` int(11) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `roadie`
--

INSERT INTO `roadie` (`Tecnico_numero`, `Participante_codigo`) VALUES
(1, 1),
(3, 2);

-- --------------------------------------------------------

--
-- Estrutura da tabela `tecnico`
--

CREATE TABLE `tecnico` (
  `numero` int(11) NOT NULL,
  `nome` varchar(120) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `tecnico`
--

INSERT INTO `tecnico` (`numero`, `nome`) VALUES
(1, 'Rainho'),
(2, 'Garrids'),
(3, 'jota'),
(4, 'chico');

-- --------------------------------------------------------

--
-- Estrutura da tabela `tema`
--

CREATE TABLE `tema` (
  `Edicao_numero` tinyint(4) NOT NULL,
  `Participante_codigo` smallint(6) NOT NULL,
  `nr_ordem` tinyint(4) NOT NULL,
  `titulo` varchar(60) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

-- --------------------------------------------------------

--
-- Estrutura da tabela `tipo_de_bilhete`
--

CREATE TABLE `tipo_de_bilhete` (
  `Nome` varchar(30) NOT NULL,
  `preco` decimal(6,2) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=latin1 COLLATE=latin1_bin;

--
-- Extraindo dados da tabela `tipo_de_bilhete`
--

INSERT INTO `tipo_de_bilhete` (`Nome`, `preco`) VALUES
('diario_1', 5.00),
('diario_2', 5.00),
('diario_3', 5.00),
('geral', 15.00);

-- --------------------------------------------------------

--
-- Estrutura stand-in para vista `todos_os_participantes`
-- (Veja abaixo para a view atual)
--
CREATE TABLE `todos_os_participantes` (
`Participante_codigo` smallint(6)
,`Nome` varchar(80)
,`Ano_Ultima_Atuação` int(4)
,`Cachet_Ultima_Atuação` int(11)
);

-- --------------------------------------------------------

--
-- Estrutura para vista `cartaz`
--
DROP TABLE IF EXISTS `cartaz`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `cartaz`  AS SELECT `c`.`Edicao_numero_` AS `Edicao_numero_`, `c`.`Participante_codigo_` AS `Participante_codigo_`, (select `p`.`nome` from `participante` `p` where `c`.`Participante_codigo_` = `p`.`codigo`) AS `Nome_Artista`, `c`.`Dia_festival_data` AS `Dia_festival_data`, `c`.`cachet` AS `cachet` FROM `contrata` AS `c` ORDER BY `c`.`Dia_festival_data` ASC, `c`.`cachet` DESC ;

-- --------------------------------------------------------

--
-- Estrutura para vista `estilos_musicais_por_edicao`
--
DROP TABLE IF EXISTS `estilos_musicais_por_edicao`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `estilos_musicais_por_edicao`  AS SELECT `e`.`numero` AS `Edicao`, `ea`.`Estilo_Nome_` AS `Estilo`, count(0) AS `Qtd_Artistas` FROM ((`edicao` `e` join `contrata` `c`) join `estilo_de_artista` `ea`) WHERE `c`.`Edicao_numero_` = `e`.`numero` AND `c`.`Participante_codigo_` = `ea`.`Participante_codigo_` GROUP BY `e`.`numero`, `ea`.`Estilo_Nome_` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `resultados_diarios`
--
DROP TABLE IF EXISTS `resultados_diarios`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `resultados_diarios`  AS SELECT `d`.`data` AS `Dia_festival_data`, `d`.`qtd_espetadores` AS `Quantidade_Espetadores`, sum(case when `b`.`devolvido` = 0 and `b`.`Tipo_de_bilhete_Nome` like 'diario%' then `tb`.`preco` when `b`.`devolvido` = 0 and `b`.`Tipo_de_bilhete_Nome` like 'geral' then `tb`.`preco` / ((select to_days(`edicao`.`data_fim`) - to_days(`edicao`.`data_inicio`) from `edicao`) + 1) else 0 end) AS `Faturacao` FROM (((`dia_festival` `d` join `acesso` `a`) join `bilhete` `b`) join `tipo_de_bilhete` `tb`) WHERE `a`.`Dia_festival_data_` = `d`.`data` AND `a`.`Tipo_de_bilhete_Nome_` = `b`.`Tipo_de_bilhete_Nome` AND `b`.`Tipo_de_bilhete_Nome` = `tb`.`Nome` GROUP BY `d`.`data` ;

-- --------------------------------------------------------

--
-- Estrutura para vista `todos_os_participantes`
--
DROP TABLE IF EXISTS `todos_os_participantes`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `todos_os_participantes`  AS SELECT `p`.`codigo` AS `Participante_codigo`, `p`.`nome` AS `Nome`, year(max(`c`.`Dia_festival_data`)) AS `Ano_Ultima_Atuação`, max(`c`.`cachet`) AS `Cachet_Ultima_Atuação` FROM (`participante` `p` join `contrata` `c`) WHERE `p`.`codigo` = `c`.`Participante_codigo_` GROUP BY `p`.`codigo`, `p`.`nome` ;

--
-- Índices para tabelas despejadas
--

--
-- Índices para tabela `acesso`
--
ALTER TABLE `acesso`
  ADD PRIMARY KEY (`Dia_festival_data_`,`Tipo_de_bilhete_Nome_`),
  ADD KEY `FK_Tipo_de_bilhete_acesso_Dia_festival_` (`Tipo_de_bilhete_Nome_`);

--
-- Índices para tabela `bilhete`
--
ALTER TABLE `bilhete`
  ADD PRIMARY KEY (`num_serie`),
  ADD KEY `FK_Bilhete_noname_Tipo_de_bilhete` (`Tipo_de_bilhete_Nome`),
  ADD KEY `FK_Bilhete_tem_Espetador_com_bilhete` (`Espetador_com_bilhete_Espetador_identificador`);

--
-- Índices para tabela `contrata`
--
ALTER TABLE `contrata`
  ADD PRIMARY KEY (`Edicao_numero_`,`Participante_codigo_`),
  ADD KEY `FK_Participante_Contrata_Edicao_` (`Participante_codigo_`),
  ADD KEY `FK_Contrata_apresenta_Palco` (`Palco_codigo`),
  ADD KEY `FK_Contrata_Atuacao_Dia_festival` (`Dia_festival_data`),
  ADD KEY `FK_Participante_Convida_Participante_` (`Convidado_Edicao_numero_`,`Convidado_Participante_codigo_`);

--
-- Índices para tabela `dia_festival`
--
ALTER TABLE `dia_festival`
  ADD PRIMARY KEY (`data`),
  ADD KEY `FK_Dia_festival_noname_Edicao` (`Edicao_numero`);

--
-- Índices para tabela `edicao`
--
ALTER TABLE `edicao`
  ADD PRIMARY KEY (`numero`);

--
-- Índices para tabela `elemento_grupo`
--
ALTER TABLE `elemento_grupo`
  ADD PRIMARY KEY (`Individual_Participante_codigo_`,`Grupo_Participante_codigo_`),
  ADD KEY `FK_Grupo_Elemento_grupo_Individual_` (`Grupo_Participante_codigo_`);

--
-- Índices para tabela `entrevista`
--
ALTER TABLE `entrevista`
  ADD PRIMARY KEY (`Participante_codigo_`,`Jornalista_num_carteira_profissional_`),
  ADD KEY `FK_Jornalista_Entrevista_Participante_` (`Jornalista_num_carteira_profissional_`);

--
-- Índices para tabela `espetador`
--
ALTER TABLE `espetador`
  ADD PRIMARY KEY (`identificador`);

--
-- Índices para tabela `espetador_com_bilhete`
--
ALTER TABLE `espetador_com_bilhete`
  ADD PRIMARY KEY (`Espetador_identificador`);

--
-- Índices para tabela `estilo`
--
ALTER TABLE `estilo`
  ADD PRIMARY KEY (`Nome`);

--
-- Índices para tabela `estilo_de_artista`
--
ALTER TABLE `estilo_de_artista`
  ADD PRIMARY KEY (`Participante_codigo_`,`Estilo_Nome_`),
  ADD KEY `FK_Estilo_estilo_de_artista_Participante_` (`Estilo_Nome_`);

--
-- Índices para tabela `grupo`
--
ALTER TABLE `grupo`
  ADD PRIMARY KEY (`Participante_codigo`);

--
-- Índices para tabela `individual`
--
ALTER TABLE `individual`
  ADD PRIMARY KEY (`Participante_codigo`),
  ADD KEY `FK_Individual_origem_Pais` (`Pais_nome`);

--
-- Índices para tabela `jornalista`
--
ALTER TABLE `jornalista`
  ADD PRIMARY KEY (`num_carteira_profissional`),
  ADD KEY `FK_Jornalista_Espetador` (`Espetador_identificador`),
  ADD KEY `FK_Jornalista_representa_Media` (`Media_nome`);

--
-- Índices para tabela `livre_transito`
--
ALTER TABLE `livre_transito`
  ADD PRIMARY KEY (`Edicao_numero_`,`Jornalista_num_carteira_profissional_`),
  ADD KEY `FK_Jornalista_Livre_transito_Edicao_` (`Jornalista_num_carteira_profissional_`);

--
-- Índices para tabela `media`
--
ALTER TABLE `media`
  ADD PRIMARY KEY (`nome`);

--
-- Índices para tabela `montado`
--
ALTER TABLE `montado`
  ADD PRIMARY KEY (`Palco_Edicao_numero_`,`Palco_codigo_`,`Tecnico_numero_`),
  ADD KEY `FK_Palco_montado_Tecnico_` (`Palco_codigo_`),
  ADD KEY `FK_Tecnico_montado_Palco_` (`Tecnico_numero_`);

--
-- Índices para tabela `pais`
--
ALTER TABLE `pais`
  ADD PRIMARY KEY (`nome`);

--
-- Índices para tabela `palco`
--
ALTER TABLE `palco`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `FK_Palco_tem_Edicao` (`Edicao_numero`);

--
-- Índices para tabela `papel`
--
ALTER TABLE `papel`
  ADD PRIMARY KEY (`Nome`);

--
-- Índices para tabela `papel_no_grupo`
--
ALTER TABLE `papel_no_grupo`
  ADD PRIMARY KEY (`Elemento_grupo_Individual_Participante_codigo__`,`Elemento_grupo_Grupo_Participante_codigo__`,`Papel_Nome_`),
  ADD KEY `FK_Papel_papel_no_grupo_Elemento_grupo_` (`Papel_Nome_`);

--
-- Índices para tabela `participante`
--
ALTER TABLE `participante`
  ADD PRIMARY KEY (`codigo`),
  ADD KEY `edicao_num_` (`edicao_num`) USING BTREE;

--
-- Índices para tabela `reportagem`
--
ALTER TABLE `reportagem`
  ADD PRIMARY KEY (`Dia_festival_data_`,`Jornalista_num_carteira_profissional_`),
  ADD KEY `FK_Jornalista_Reportagem_Dia_festival_` (`Jornalista_num_carteira_profissional_`);

--
-- Índices para tabela `roadie`
--
ALTER TABLE `roadie`
  ADD PRIMARY KEY (`Tecnico_numero`),
  ADD KEY `FK_Roadie_ligado_Participante` (`Participante_codigo`);

--
-- Índices para tabela `tecnico`
--
ALTER TABLE `tecnico`
  ADD PRIMARY KEY (`numero`);

--
-- Índices para tabela `tema`
--
ALTER TABLE `tema`
  ADD PRIMARY KEY (`Edicao_numero`,`Participante_codigo`,`nr_ordem`);

--
-- Índices para tabela `tipo_de_bilhete`
--
ALTER TABLE `tipo_de_bilhete`
  ADD PRIMARY KEY (`Nome`);

--
-- AUTO_INCREMENT de tabelas despejadas
--

--
-- AUTO_INCREMENT de tabela `bilhete`
--
ALTER TABLE `bilhete`
  MODIFY `num_serie` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=1004;

--
-- AUTO_INCREMENT de tabela `espetador`
--
ALTER TABLE `espetador`
  MODIFY `identificador` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT de tabela `palco`
--
ALTER TABLE `palco`
  MODIFY `codigo` tinyint(4) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=127;

--
-- AUTO_INCREMENT de tabela `tecnico`
--
ALTER TABLE `tecnico`
  MODIFY `numero` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=102;

--
-- Restrições para despejos de tabelas
--

--
-- Limitadores para a tabela `acesso`
--
ALTER TABLE `acesso`
  ADD CONSTRAINT `FK_Dia_festival_acesso_Tipo_de_bilhete_` FOREIGN KEY (`Dia_festival_data_`) REFERENCES `dia_festival` (`data`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Tipo_de_bilhete_acesso_Dia_festival_` FOREIGN KEY (`Tipo_de_bilhete_Nome_`) REFERENCES `tipo_de_bilhete` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `bilhete`
--
ALTER TABLE `bilhete`
  ADD CONSTRAINT `FK_Bilhete_noname_Tipo_de_bilhete` FOREIGN KEY (`Tipo_de_bilhete_Nome`) REFERENCES `tipo_de_bilhete` (`Nome`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Bilhete_tem_Espetador_com_bilhete` FOREIGN KEY (`Espetador_com_bilhete_Espetador_identificador`) REFERENCES `espetador_com_bilhete` (`Espetador_identificador`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `contrata`
--
ALTER TABLE `contrata`
  ADD CONSTRAINT `FK_Contrata_Atuacao_Dia_festival` FOREIGN KEY (`Dia_festival_data`) REFERENCES `dia_festival` (`data`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Contrata_apresenta_Palco` FOREIGN KEY (`Palco_codigo`) REFERENCES `palco` (`codigo`) ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Edicao_Contrata_Participante_` FOREIGN KEY (`Edicao_numero_`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Contrata_Edicao_` FOREIGN KEY (`Participante_codigo_`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Convida_Participante_` FOREIGN KEY (`Convidado_Edicao_numero_`,`Convidado_Participante_codigo_`) REFERENCES `contrata` (`Edicao_numero_`, `Participante_codigo_`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `dia_festival`
--
ALTER TABLE `dia_festival`
  ADD CONSTRAINT `FK_Dia_festival_noname_Edicao` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `elemento_grupo`
--
ALTER TABLE `elemento_grupo`
  ADD CONSTRAINT `FK_Grupo_Elemento_grupo_Individual_` FOREIGN KEY (`Grupo_Participante_codigo_`) REFERENCES `grupo` (`Participante_codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Individual_Elemento_grupo_Grupo_` FOREIGN KEY (`Individual_Participante_codigo_`) REFERENCES `individual` (`Participante_codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `entrevista`
--
ALTER TABLE `entrevista`
  ADD CONSTRAINT `FK_Jornalista_Entrevista_Participante_` FOREIGN KEY (`Jornalista_num_carteira_profissional_`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_Entrevista_Jornalista_` FOREIGN KEY (`Participante_codigo_`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `espetador_com_bilhete`
--
ALTER TABLE `espetador_com_bilhete`
  ADD CONSTRAINT `FK_Espetador_com_bilhete_Espetador` FOREIGN KEY (`Espetador_identificador`) REFERENCES `espetador` (`identificador`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `estilo_de_artista`
--
ALTER TABLE `estilo_de_artista`
  ADD CONSTRAINT `FK_Estilo_estilo_de_artista_Participante_` FOREIGN KEY (`Estilo_Nome_`) REFERENCES `estilo` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Participante_estilo_de_artista_Estilo_` FOREIGN KEY (`Participante_codigo_`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `grupo`
--
ALTER TABLE `grupo`
  ADD CONSTRAINT `FK_Grupo_Participante` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `individual`
--
ALTER TABLE `individual`
  ADD CONSTRAINT `FK_Individual_Participante` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Individual_origem_Pais` FOREIGN KEY (`Pais_nome`) REFERENCES `pais` (`nome`) ON DELETE SET NULL ON UPDATE CASCADE;

--
-- Limitadores para a tabela `jornalista`
--
ALTER TABLE `jornalista`
  ADD CONSTRAINT `FK_Jornalista_Espetador` FOREIGN KEY (`Espetador_identificador`) REFERENCES `espetador` (`identificador`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jornalista_representa_Media` FOREIGN KEY (`Media_nome`) REFERENCES `media` (`nome`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `livre_transito`
--
ALTER TABLE `livre_transito`
  ADD CONSTRAINT `FK_Edicao_Livre_transito_Jornalista_` FOREIGN KEY (`Edicao_numero_`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jornalista_Livre_transito_Edicao_` FOREIGN KEY (`Jornalista_num_carteira_profissional_`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `montado`
--
ALTER TABLE `montado`
  ADD CONSTRAINT `FK_Palco_montado_Tecnico_` FOREIGN KEY (`Palco_codigo_`) REFERENCES `palco` (`codigo`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Tecnico_montado_Palco_` FOREIGN KEY (`Tecnico_numero_`) REFERENCES `tecnico` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `palco`
--
ALTER TABLE `palco`
  ADD CONSTRAINT `FK_Palco_tem_Edicao` FOREIGN KEY (`Edicao_numero`) REFERENCES `edicao` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `papel_no_grupo`
--
ALTER TABLE `papel_no_grupo`
  ADD CONSTRAINT `FK_Elemento_grupo_papel_no_grupo_Papel_` FOREIGN KEY (`Elemento_grupo_Individual_Participante_codigo__`,`Elemento_grupo_Grupo_Participante_codigo__`) REFERENCES `elemento_grupo` (`Individual_Participante_codigo_`, `Grupo_Participante_codigo_`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Papel_papel_no_grupo_Elemento_grupo_` FOREIGN KEY (`Papel_Nome_`) REFERENCES `papel` (`Nome`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `reportagem`
--
ALTER TABLE `reportagem`
  ADD CONSTRAINT `FK_Dia_festival_Reportagem_Jornalista_` FOREIGN KEY (`Dia_festival_data_`) REFERENCES `dia_festival` (`data`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Jornalista_Reportagem_Dia_festival_` FOREIGN KEY (`Jornalista_num_carteira_profissional_`) REFERENCES `jornalista` (`num_carteira_profissional`) ON DELETE CASCADE ON UPDATE CASCADE;

--
-- Limitadores para a tabela `roadie`
--
ALTER TABLE `roadie`
  ADD CONSTRAINT `FK_Roadie_Tecnico` FOREIGN KEY (`Tecnico_numero`) REFERENCES `tecnico` (`numero`) ON DELETE CASCADE ON UPDATE CASCADE,
  ADD CONSTRAINT `FK_Roadie_ligado_Participante` FOREIGN KEY (`Participante_codigo`) REFERENCES `participante` (`codigo`) ON UPDATE CASCADE;

--
-- Limitadores para a tabela `tema`
--
ALTER TABLE `tema`
  ADD CONSTRAINT `FK_Tema_enterpretado_Contrata` FOREIGN KEY (`Edicao_numero`,`Participante_codigo`) REFERENCES `contrata` (`Edicao_numero_`, `Participante_codigo_`) ON UPDATE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
