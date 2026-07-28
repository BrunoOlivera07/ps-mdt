CREATE TABLE IF NOT EXISTS `mdt_settings` (
  `key` varchar(100) NOT NULL,
  `value` longtext DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`key`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `mdt_settings` (`key`, `value`) VALUES
('jail_fines', '{"reductionOffers":[10,25,50],"maxFineAmount":100000}');

CREATE TABLE IF NOT EXISTS `mdt_bulletins` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `content` text NOT NULL,
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_profiles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `fullname` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `callsign` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `badge_number` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `rank` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `department` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `profilepicture` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `certifications` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_logout_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid` (`citizenid`),
  UNIQUE KEY `callsign` (`callsign`),
  KEY `badge_number` (`badge_number`),
  KEY `idx_department` (`department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_messages` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `sender_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `sender_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `receiver_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `receiver_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `subject` varchar(120) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `body` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `read_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `sender_citizenid` (`sender_citizenid`),
  KEY `receiver_citizenid` (`receiver_citizenid`),
  CONSTRAINT `FK_mdt_messages_sender` FOREIGN KEY (`sender_citizenid`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_messages_receiver` FOREIGN KEY (`receiver_citizenid`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_penal_codes` (
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `charge_class` enum('felony','misdemeanor','infraction') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `months` int(10) unsigned NOT NULL DEFAULT 0,
  `fine` int(10) unsigned NOT NULL DEFAULT 0,
  `color` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`code`),
  KEY `label` (`label`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_permission_roles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `grade` int(10) unsigned NOT NULL,
  `permissions` json NOT NULL,
  `updated_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `job_grade` (`job`,`grade`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT INTO `mdt_penal_codes` (`code`, `label`, `charge_class`, `months`, `fine`, `color`, `description`) VALUES
('P.C. 1001','Ataque Simples','misdemeanor',7,500,'green','Quando uma pessoa intencionalmente ou conscientemente causa contato físico com outra (sem arma)'),
('P.C. 1002','Assalto','misdemeanor',15,850,'orange','Se uma pessoa intencionalmente ou conscientemente causar ferimentos a outra (sem arma)'),
('P.C. 1003','Assalto Agravado','felony',20,1250,'orange','Quando uma pessoa, de forma não intencional e imprudente, causa lesões corporais a outra como resultado de um confronto E causa lesões corporais'),
('P.C. 1004','Ataque com arma mortal','felony',30,3750,'red','Quando uma pessoa intencionalmente, conscientemente ou imprudentemente causa lesões corporais a outra pessoa E causa lesões corporais graves ou usa ou exibe uma arma mortal'),
('P.C. 1005','Homicídio involuntário','felony',60,7500,'red','Quando uma pessoa, de forma involuntária e imprudente, causa a morte de outra'),
('P.C. 1006','Homicídio Veicular','felony',75,7500,'red','Quando uma pessoa involuntariamente e de forma imprudente causa a morte de outra com um veículo'),
('P.C. 1007','Tentativa de assassinato de um civil','felony',50,7500,'red','Quando uma pessoa não governamental ataca intencionalmente outra pessoa com a intenção de matar'),
('P.C. 1008','Assassinato de segundo grau','felony',100,15000,'red','Qualquer assassinato intencional que não seja premeditado ou planejado. Situação em que o assassino pretende apenas infligir lesões corporais graves.'),
('P.C. 1009','Cumplicidade em Assassinato de Segundo Grau','felony',50,5000,'red','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 1010','Assassinato de primeiro grau','felony',90,15000,'red','Qualquer assassinato intencional, intencional e premeditado com malícia.'),
('P.C. 1011','Cumplicidade em assassinato em primeiro grau','felony',60,10000,'red','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 1012','Assassinato de um funcionário público ou agente da lei','felony',120,20000,'red','Qualquer assassinato intencional cometido contra um funcionário público'),
('P.C. 1013','Tentativa de assassinato de funcionário público ou agente da lei','felony',65,10000,'red','Quaisquer ataques feitos a um funcionário público com a intenção de causar a morte'),
('P.C. 1014','Cumplicidade no assassinato de um funcionário público ou agente da lei','felony',80,15000,'red','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 1015','Prisão ilegal','misdemeanor',10,600,'green','O ato de pegar outra pessoa contra sua vontade e mantê-la por um longo período de tempo'),
('P.C. 1016','Sequestro','felony',15,900,'orange','O ato de tomar outra pessoa contra sua vontade por um curto período de tempo'),
('P.C. 1017','Cumplicidade em sequestro','felony',7,450,'orange','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 1018','Tentativa de sequestro','felony',10,450,'orange','O ato de tentar levar alguém contra sua vontade'),
('P.C. 1019','Tomada de reféns','felony',20,1200,'orange','O ato de tomar outra pessoa contra sua vontade para ganho pessoal'),
('P.C. 1020','Cumplicidade em tomada de reféns','felony',10,600,'orange','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 1021','Prisão ilegal de funcionário público ou agente da lei.','felony',25,4000,'orange','O ato de manter um funcionário público contra sua vontade por um longo período de tempo'),
('P.C. 1022','Ameaças Criminosas','misdemeanor',5,500,'orange','O ato de declarar a intenção de cometer um crime contra outrem'),
('P.C. 1023','Perigo imprudente','misdemeanor',10,1000,'orange','O ato de desconsiderar a segurança de outra pessoa que pode colocar outra pessoa em perigo de morte ou lesão corporal'),
('P.C. 1024','Tiro relacionado a gangues','felony',30,2500,'red','O ato em que uma arma de fogo é disparada em relação à atividade de gangue'),
('P.C. 1025','Canibalismo','felony',100,20000,'red','O ato em que uma pessoa consome a carne de outra voluntariamente'),
('P.C. 1026','Tortura','felony',40,4500,'red','O ato de causar dano a outrem para extrair informações e/ou para prazer próprio'),
('P.C. 2001','Pequeno roubo','infraction',0,250,'green','Roubo de propriedade abaixo do valor de US$ 50'),
('P.C. 2002','Grande roubo','misdemeanor',10,600,'green','Roubo de propriedade acima de US$ 700'),
('P.C. 2003','Grande roubo de automóveis A','felony',15,900,'green','O ato de roubar um veículo que pertence a outra pessoa sem permissão'),
('P.C. 2004','Grande roubo de automóveis B','felony',35,3500,'green','O ato de roubar um veículo que pertence a outra pessoa sem permissão e armado'),
('P.C. 2005','Roubo de carro','felony',30,2000,'orange','O ato de alguém tirar à força um veículo de seus ocupantes'),
('P.C. 2006','Roubo','misdemeanor',10,500,'green','Ato de entrar ilegalmente em um prédio com a intenção de cometer um crime, principalmente roubo.'),
('P.C. 2007','Roubo','felony',25,2000,'green','A ação de tirar propriedade ilegalmente de uma pessoa ou lugar pela força ou ameaça de força.'),
('P.C. 2008','Cumplicidade em Roubo','felony',12,1000,'green','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 2009','Tentativa de roubo','felony',20,1000,'green','A ação de tentar a propriedade ilegalmente de uma pessoa ou lugar pela força ou ameaça de força.'),
('P.C. 2010','Assalto à mão armada','felony',30,3000,'orange','A ação de tirar propriedade ilegalmente de uma pessoa ou lugar pela força ou ameaça de força enquanto estiver armado.'),
('P.C. 2011','Cumplicidade em assalto à mão armada','felony',15,1500,'orange','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 2012','Tentativa de assalto à mão armada','felony',25,1500,'orange','A ação de tentar a propriedade ilegalmente de uma pessoa ou lugar pela força ou ameaça de força enquanto estiver armado.'),
('P.C. 2013','Grande Furto','felony',45,7500,'orange','Roubo de bens pessoais com valor superior a um valor legalmente especificado.'),
('P.C. 2014','Sair sem pagar','infraction',0,500,'green','O ato de sair de um estabelecimento sem pagar pelo serviço prestado'),
('P.C. 2015','Posse de moeda não legal','misdemeanor',10,750,'green','Estar em posse de moeda roubada'),
('P.C. 2016','Posse de itens emitidos pelo governo','misdemeanor',15,1000,'green','Estar na posse de itens que só podem ser adquiridos por funcionários do governo'),
('P.C. 2017','Posse de itens usados ​​na prática de um crime','misdemeanor',10,500,'green','Estar em posse de itens que foram usados ​​anteriormente para cometer crimes'),
('P.C. 2018','Venda de itens usados ​​na prática de um crime','felony',15,1000,'orange','O ato de vender itens que antes eram usados ​​para cometer crimes'),
('P.C. 2019','Roubo de uma aeronave','felony',20,1000,'green','O ato de roubar uma aeronave'),
('P.C. 3001','Personificando','misdemeanor',15,1250,'green','A ação de se identificar falsamente como outra pessoa para enganar'),
('P.C. 3002','Fazendo-se passar por agente da lei ou servidor público','felony',25,2750,'green','A ação de identificar-se falsamente como funcionário público para enganar'),
('P.C. 3003','Fazendo-se passar por juiz','felony',30,3500,'green','A ação de se identificar falsamente como Juiz para enganar'),
('P.C. 3004','Posse de identificação roubada','misdemeanor',10,750,'green','Ter a identificação de outra pessoa sem consentimento'),
('P.C. 3005','Posse de identificação governamental roubada','misdemeanor',20,2000,'green','Ter a identificação de um funcionário público sem consentimento'),
('P.C. 3006','Extorsão','felony',20,900,'orange','Ameaçar ou causar danos a uma pessoa ou propriedade para ganho financeiro'),
('P.C. 3007','Fraude','misdemeanor',10,450,'green','Para enganar outro para ganho financeiro'),
('P.C. 3008','Falsificação','misdemeanor',15,750,'green','Falsificar documentação legal para ganho pessoal'),
('P.C. 3009','Lavagem de dinheiro','felony',40,7500,'red','O processamento de dinheiro roubado em moeda legal'),
('P.C. 4001','Invasão','misdemeanor',10,450,'green','Para uma pessoa estar dentro dos limites de um local onde não é legalmente permitida'),
('P.C. 4002','Invasão criminosa','felony',15,1500,'green','Para uma pessoa ter entrado repetidamente nos limites de um local onde ela não é legalmente permitida'),
('P.C. 4003','Incêndio criminoso','felony',15,1500,'orange','O uso de fogo e aceleradores para destruir, danificar ou causar a morte intencional e maliciosamente a uma pessoa ou propriedade'),
('P.C. 4004','Vandalismo','infraction',0,300,'green','A destruição intencional de propriedade'),
('P.C. 4005','Vandalismo de propriedade governamental','felony',20,1500,'green','A destruição intencional de propriedade do governo'),
('P.C. 4006','Lixo','infraction',0,200,'green','O descarte intencional de lixo em recipiente aberto e não designado'),
('P.C. 5001','Suborno de um funcionário do governo','felony',20,3500,'green','o uso de dinheiro, favores e/ou propriedades para obter favores de um funcionário do governo'),
('P.C. 5002','Lei Antimáscara','infraction',0,750,'green','Usar máscara em zona proibida'),
('P.C. 5003','Posse de contrabando em instalação governamental','felony',25,1000,'green','Estar em posse de itens ilegais enquanto estiver dentro de um prédio governamental'),
('P.C. 5004','Posse criminosa de propriedade roubada','misdemeanor',10,500,'green','Estar em posse de itens roubados intencionalmente ou não'),
('P.C. 5005','Escapando','felony',10,450,'green','A ação de deixar a custódia intencional e conscientemente enquanto está legalmente preso, detido ou na prisão'),
('P.C. 5006','Fuga de presos','felony',30,2500,'orange','A ação de sair da custódia estadual de um centro de detenção estadual ou municipal'),
('P.C. 5007','Cumplicidade em Jailbreak','felony',25,2000,'orange','Estar presente e/ou participar do ato da acusação principal'),
('P.C. 5008','Tentativa de jailbreak','felony',20,1500,'orange','A tentativa de fuga intencional e intencional de um centro de detenção estadual ou municipal'),
('P.C. 5009','Perjúrio','felony',20,2000,'green','A ação de declarar falsidades enquanto está legalmente obrigado a falar a verdade'),
('P.C. 5010','Violação de uma ordem de restrição','felony',20,2250,'green','A violação intencional e consciente mediante pedido judicial de documentação de proteção'),
('P.C. 5011','Desfalque','felony',45,10000,'green','A movimentação intencional e consciente de fundos de contas bancárias não pessoais para contas bancárias pessoais para ganho pessoal'),
('P.C. 5012','Prática Ilegal','felony',15,1500,'orange','A ação de realizar um serviço sem o devido licenciamento e aprovação legal'),
('P.C. 5013','Uso indevido de sistemas de emergência','infraction',0,600,'orange','Uso de equipamento de emergência governamental para fins não pretendidos'),
('P.C. 5014','Conspiração','misdemeanor',10,450,'green','O ato de planejar um crime, mas ainda não cometê-lo'),
('P.C. 5015','Violando uma ordem judicial','misdemeanor',10,1000,'orange','A violação da documentação ordenada pelo tribunal'),
('P.C. 5016','Não comparecimento','misdemeanor',15,1500,'orange','Quando alguém que está legalmente obrigado a comparecer em tribunal não o faz'),
('P.C. 5017','Desacato ao Tribunal','felony',20,2500,'orange','A interrupção do processo judicial numa sala de tribunal durante a sessão (decisão judicial)'),
('P.C. 5018','Resistindo à prisão','misdemeanor',5,300,'orange','O ato de não permitir que oficiais de paz o levem sob custódia voluntariamente'),
('P.C. 6001','Desobedecendo a um Agente da Lei','infraction',0,750,'green','O desrespeito intencional de uma ordem legal'),
('P.C. 6002','Conduta Desordeira','infraction',0,250,'green','Agir de maneira que crie uma condição perigosa ou fisicamente ofensiva por qualquer ato que não sirva a nenhum propósito legítimo do ator.'),
('P.C. 6003','Perturbando a paz','infraction',0,350,'green','Ação de uma maneira que cause agitação e perturbe a ordem pública'),
('P.C. 6004','Relatórios falsos','misdemeanor',10,750,'green','O ato de denunciar um crime que não aconteceu'),
('P.C. 6005','Assédio','misdemeanor',10,500,'orange','A interrupção repetida ou ataques verbais de outra pessoa'),
('P.C. 6006','Obstrução da Justiça (Contravenção)','misdemeanor',10,500,'green','Agir de forma que dificulte o processo da Justiça ou investigações legais'),
('P.C. 6007','Obstrução da Justiça (Crime Grave)','felony',15,900,'green','Agir de forma que dificulte o processo de Justiça ou investigações legais ao usar violência'),
('P.C. 6008','Incitando um motim','felony',25,1000,'orange','Causar agitação civil de forma a incitar um grupo a causar danos a pessoas ou propriedades'),
('P.C. 6009','Vadiando em propriedades governamentais','infraction',0,500,'green','Quando alguém está presente em um governo propriamente dito por um longo período de tempo'),
('P.C. 6010','Adulteração','misdemeanor',10,500,'green','Quando alguém interfere intencionalmente, consciente e indiretamente em pontos-chave de uma investigação legal'),
('P.C. 6011','Adulteração de veículos','misdemeanor',15,750,'green','A interferência intencional e consciente no funcionamento normal de um veículo'),
('P.C. 6012','Adulteração de evidências','felony',20,1000,'green','A interferência intencional e consciente nas evidências de uma investigação legal'),
('P.C. 6013','Adulteração de testemunha','felony',25,3000,'green','O treinamento ou coação intencional e consciente de uma testemunha em uma investigação legal'),
('P.C. 6014','Falha no fornecimento de identificação','misdemeanor',15,1500,'green','O ato de não apresentar identificação quando legalmente obrigado a fazê-lo'),
('P.C. 6015','Vigilantismo','felony',30,1500,'orange','O ato de se envolver na aplicação da lei com autoridade legal para fazê-lo'),
('P.C. 6016','Assembleia ilegal','misdemeanor',10,750,'orange','quando um grande grupo se reúne em um local que requer aprovação prévia para fazê-lo'),
('P.C. 6017','Corrupção Governamental','felony',50,10000,'red','O ato de usar a posição política e o poder para ganho próprio'),
('P.C. 6018','Perseguição','felony',40,1500,'orange','Quando uma pessoa monitora outra sem o seu consentimento'),
('P.C. 6019','Ajudando e incentivando','misdemeanor',15,450,'orange','Para ajudar alguém a cometer ou encorajar alguém a cometer um crime'),
('P.C. 6020','Abrigando um fugitivo','misdemeanor',10,1000,'green','Quando alguém esconde voluntariamente outro que é procurado pelas autoridades'),
('P.C. 7001','Porte ilegal de maconha','misdemeanor',5,250,'green','A posse de uma quantidade de maconha em quantidade inferior a 4 embotamentos'),
('P.C. 7002','Fabricação criminosa de maconha','felony',15,1000,'red','A posse de uma quantidade de maconha proveniente da fabricação'),
('P.C. 7003','Cultivo de Maconha A','misdemeanor',10,750,'green','Posse de 4 ou menos plantas de maconha'),
('P.C. 7004','Cultivo de maconha B','felony',30,1500,'orange','Posse de 5 ou mais plantas de maconha'),
('P.C. 7005','Posse de maconha com intenção de distribuição','felony',30,3000,'orange','Posse de quantidade de maconha para distribuição'),
('P.C. 7006','Porte ilegal de cocaína','misdemeanor',7,500,'green','Posse de cocaína em pequena quantidade, geralmente para uso pessoal'),
('P.C. 7007','Posse criminosa oriunda da fabricação de cocaína','felony',25,1500,'red','A posse de uma quantidade de cocaína proveniente da fabricação'),
('P.C. 7008','Posse de cocaína com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de cocaína para distribuição'),
('P.C. 7009','Porte ilegal de metanfetamina','misdemeanor',7,500,'green','Posse de metanfetamina em pequena quantidade, geralmente para uso pessoal'),
('P.C. 7010','Posse criminosa oriunda da fabricação de metanfetamina','felony',25,1500,'red','A posse de uma quantidade de metanfetamina proveniente da fabricação'),
('P.C. 7011','Posse de metanfetamina com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de metanfetamina para distribuição'),
('P.C. 7012','Posse simples de Oxy / Vicodin','misdemeanor',7,500,'green','Posse de oxi / vicodin em pequena quantidade, geralmente para uso pessoal sem receita médica'),
('P.C. 7013','Posse criminosa oriunda da fabricação de Oxy / Vicodin','felony',25,1500,'red','A posse de uma quantidade de oxi / vicodin proveniente da fabricação'),
('P.C. 7014','Posse criminosa de Oxy / Vicodin com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de oxi/vicodin para distribuição'),
('P.C. 7015','Porte ilegal de ecstasy','misdemeanor',7,500,'green','Posse de ecstasy em pequena quantidade, geralmente para uso pessoal'),
('P.C. 7016','Posse criminosa oriunda da fabricação de ecstasy','felony',25,1500,'red','A posse de uma quantidade de êxtase proveniente da fabricação'),
('P.C. 7017','Posse de êxtase com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de ecstasy para distribuição'),
('P.C. 7018','Porte ilegal de ópio','misdemeanor',7,500,'green','Posse de ópio em pequena quantidade, geralmente para uso pessoal'),
('P.C. 7019','Posse criminosa oriunda da fabricação de ópio','felony',25,1500,'red','A posse de uma quantidade de ópio proveniente da indústria'),
('P.C. 7020','Posse de ópio com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de ópio para distribuição'),
('P.C. 7021','Posse simples de Adderall','misdemeanor',7,500,'green','Posse de Adderall em pequena quantidade, geralmente para uso pessoal sem receita médica'),
('P.C. 7022','Posse criminosa oriunda da fabricação de Adderall','felony',25,1500,'red','A posse de uma quantidade de adderall proveniente da fabricação'),
('P.C. 7023','Posse de Adderall com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de Adderall para distribuição'),
('P.C. 7024','Posse simples de Xanax','misdemeanor',7,500,'green','Posse de xanax em pequena quantidade, geralmente para uso pessoal sem receita médica'),
('P.C. 7025','Posse criminosa oriunda da fabricação de Xanax','felony',25,1500,'red','A posse de uma quantidade de xanax proveniente da fabricação'),
('P.C. 7026','Posse de Xanax com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de Xanax para distribuição'),
('P.C. 7027','Posse simples de cogumelos','misdemeanor',7,500,'green','A posse de cogumelos em pequena quantidade geralmente para uso pessoal'),
('P.C. 7028','Posse criminosa oriunda da fabricação de cogumelos','felony',25,1500,'red','A posse de uma quantidade de cogumelos proveniente da fabricação'),
('P.C. 7029','Posse de cogumelos com intenção de distribuição','felony',35,4500,'orange','A posse de uma quantidade de cogumelos para distribuição'),
('P.C. 7030','Posse simples de Lean','misdemeanor',7,500,'green','A posse de Lean em pequena quantidade, geralmente para uso pessoal'),
('P.C. 7031','Posse criminosa oriunda da fabricação de Lean','felony',25,1500,'red','A posse de uma quantidade de Lean proveniente da produção'),
('P.C. 7032','Posse de Lean com Intenção de Distribuir','felony',35,4500,'orange','A posse de uma quantidade de lean para distribuição'),
('P.C. 7033','Venda de uma substância controlada','misdemeanor',10,1000,'green','A venda de uma substância controlada por lei'),
('P.C. 7034','Tráfico de Drogas','felony',45,8000,'red','O movimento em grande escala de drogas ilegais'),
('P.C. 7035','Profanação de um cadáver humano','felony',20,1500,'orange','Quando alguém prejudica, perturba ou destrói os restos mortais de outra pessoa'),
('P.C. 7036','Intoxicação Pública','infraction',0,500,'green','Quando alguém está intoxicado acima do limite legal em público'),
('P.C. 7037','Indecência Pública','misdemeanor',10,750,'green','O ato de alguém se expor de forma que infringe a moral pública'),
('P.C. 8001','Posse Criminosa de Arma Classe A','felony',10,500,'green','Posse de arma de fogo Classe A sem licença'),
('P.C. 8002','Posse Criminosa de Arma Classe B','felony',15,1000,'green','Posse de arma de fogo Classe B sem licença'),
('P.C. 8003','Posse Criminosa de Arma Classe C','felony',30,3500,'green','Posse de arma de fogo Classe C sem licença'),
('P.C. 8004','Posse Criminosa de Arma Classe D','felony',25,1500,'green','Posse de arma de fogo Classe D sem licença'),
('P.C. 8005','Venda criminosa de arma classe A','felony',15,1000,'orange','O ato de vender arma de fogo Classe A sem licenciamento'),
('P.C. 8006','Venda Criminosa de Arma Classe B','felony',20,2000,'orange','O ato de vender arma de fogo Classe B sem licenciamento'),
('P.C. 8007','Venda Criminosa de Arma Classe C','felony',35,7000,'orange','O ato de vender arma de fogo Classe C sem licenciamento'),
('P.C. 8008','Venda Criminosa de Arma Classe D','felony',30,3000,'orange','O ato de vender arma de fogo Classe D sem licenciamento'),
('P.C. 8009','Uso criminoso de arma','misdemeanor',10,450,'orange','Uso de arma durante a prática de um crime'),
('P.C. 8010','Posse de modificações ilegais de armas de fogo','misdemeanor',10,300,'green','Estar em posse de modificações de armas de fogo ilegalmente'),
('P.C. 8011','Tráfico de Armas','felony',50,10000,'red','O transporte de uma grande quantidade de armas de um ponto para outro'),
('P.C. 8012','Brandindo uma arma','misdemeanor',15,500,'orange','O ato de tornar uma arma de fogo propositadamente visível'),
('P.C. 8013','Insurreição','felony',120,25000,'red','Tentativa de derrubar o governo com violência'),
('P.C. 8014','Voando para espaço aéreo restrito','felony',20,1500,'green','Pilotagem e aeronaves em espaço aéreo controlado pelo governo'),
('P.C. 8015','Caminhada na rua','infraction',0,150,'green','atravessar uma estrada de maneira perigosa para veículos motorizados'),
('P.C. 8016','Uso criminoso de explosivos','felony',30,2500,'orange','Uso de explosivos para cometer um crime'),
('P.C. 9001','Dirigir embriagado','misdemeanor',5,300,'green','Dirigir um veículo motorizado sob o efeito do álcool'),
('P.C. 9002','Fugindo','misdemeanor',5,400,'green','Esconder-se ou fugir da detenção legal'),
('P.C. 9003','Evasão imprudente','felony',10,800,'orange','Desconsiderar imprudentemente a segurança e Esconder-se ou fugir de detenção legal enquanto'),
('P.C. 9004','Falha em ceder ao veículo de emergência','infraction',0,600,'green','Não dar prioridade a veículos de emergência'),
('P.C. 9005','Falha em obedecer ao dispositivo de controle de tráfego','infraction',0,150,'green','Não seguir os dispositivos de segurança da estrada'),
('P.C. 9006','Veículo não funcional','infraction',0,75,'green','Ter um veículo que não funciona mais na estrada'),
('P.C. 9007','Condução negligente','infraction',0,300,'green','Dirigir de maneira a desconsiderar a segurança sem saber'),
('P.C. 9008','Condução imprudente','misdemeanor',10,750,'orange','Dirigir de maneira a desconsiderar conscientemente a segurança'),
('P.C. 9009','Excesso de velocidade de terceiro grau','infraction',0,225,'green','Acelerando 15 acima do limite'),
('P.C. 9010','Excesso de velocidade de segundo grau','infraction',0,450,'green','Acelerando 35 acima do limite'),
('P.C. 9011','Excesso de velocidade de primeiro grau','infraction',0,750,'green','Acelerando 50 acima do limite'),
('P.C. 9012','Operação não licenciada de veículo','infraction',0,500,'green','A operação de veículo automotor sem o devido licenciamento'),
('P.C. 9013','Retorno ilegal','infraction',0,75,'green','Fazer meia-volta onde for proibido'),
('P.C. 9014','Passagem Ilegal','infraction',0,300,'green','Ultrapassar outros veículos motorizados de forma proibida'),
('P.C. 9015','Falha em manter a pista','infraction',0,300,'green','Não permanecer na faixa correta com veículo motorizado'),
('P.C. 9016','Turno ilegal','infraction',0,150,'green','Realizando uma curva onde é proibido'),
('P.C. 9017','Falha ao parar','infraction',0,600,'green','Não parar por uma parada legal ou dispositivo de trânsito'),
('P.C. 9018','Estacionamento não autorizado','infraction',0,300,'green','Estacionar um veículo em local que exija aprovação de qualquer'),
('P.C. 9019','Bata e corra','misdemeanor',10,500,'green','Atingir outra pessoa ou veículo e fugir do local'),
('P.C. 9020','Dirigindo sem faróis ou sinais','infraction',0,300,'green','Operar um veículo sem luzes funcionais'),
('P.C. 9021','Corridas de rua','felony',15,1500,'green','Operar veículos motorizados em uma competição'),
('P.C. 9022','Pilotar sem licença adequada','felony',20,1500,'orange','Não possuir licença válida ao operar uma aeronave'),
('P.C. 9023','Uso ilegal de um veículo motorizado','misdemeanor',10,750,'green','A utilização de veículo motorizado sem motivo lícito'),
('P.C. 10001','Caça em áreas restritas','infraction',0,450,'green','Captura de caça em áreas onde é proibido fazê-lo'),
('P.C. 10002','Caça não licenciada','infraction',0,450,'green','Colheita de jogo sem licenciamento adequado'),
('P.C. 10003','Crueldade Animal','misdemeanor',10,450,'green','O ato de abusar de um animal, conscientemente ou não'),
('P.C. 10004','Caçando com uma arma que não seja de caça','misdemeanor',10,750,'green','Usar uma arma não declarada ou fabricada legalmente para ser usada na colheita de caça selvagem'),
('P.C. 10005','Caça fora do horário de caça','infraction',0,750,'green','Colher animais fora do horário especificado para fazê-lo'),
('P.C. 10006','Caça excessiva','misdemeanor',10,1000,'green','Pegar mais do que a quantidade de jogo legalmente especificada'),
('P.C. 10007','Caça furtiva','felony',20,1250,'red','Colher um animal listado como legalmente não colhível')
ON DUPLICATE KEY UPDATE
  `label` = VALUES(`label`),
  `charge_class` = VALUES(`charge_class`),
  `months` = VALUES(`months`),
  `fine` = VALUES(`fine`),
  `color` = VALUES(`color`),
  `description` = VALUES(`description`);

CREATE TABLE IF NOT EXISTS `mdt_profiles_clocking` (
  `profileId` int(10) unsigned NOT NULL,
  `clockindate` timestamp NOT NULL DEFAULT current_timestamp(),
  `clockoutdate` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  KEY `FK_mdt_profiles_clocking_mdt_profiles` (`profileId`),
  CONSTRAINT `FK_mdt_profiles_clocking_mdt_profiles` FOREIGN KEY (`profileId`) REFERENCES `mdt_profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_profiles_gallery` (
  `profileId` int(10) unsigned NOT NULL,
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datecreated` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `FK_mdt_profiles_gallery_mdt_profiles` (`profileId`),
  CONSTRAINT `FK_mdt_profiles_gallery_mdt_profiles` FOREIGN KEY (`profileId`) REFERENCES `mdt_profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_profiles_identifiers` (
  `profileId` int(10) unsigned NOT NULL,
  `content` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `datecreated` timestamp NOT NULL DEFAULT current_timestamp(),
  KEY `FK_mdt_profiles_identifiers_mdt_profiles` (`profileId`),
  CONSTRAINT `FK_mdt_profiles_identifiers_mdt_profiles` FOREIGN KEY (`profileId`) REFERENCES `mdt_profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_profiles_tags` (
  `profileId` int(10) unsigned NOT NULL,
  `tag` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  UNIQUE KEY `unique_profile_tag` (`profileId`, `tag`),
  KEY `FK_mdt_profiles_tags_mdt_profiles` (`profileId`),
  CONSTRAINT `FK_mdt_profiles_tags_mdt_profiles` FOREIGN KEY (`profileId`) REFERENCES `mdt_profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_profile_sessions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `profile_id` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `source` int(11) DEFAULT NULL,
  `login_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `logout_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `profile_id` (`profile_id`),
  KEY `citizenid` (`citizenid`),
  KEY `idx_profile_logout` (`profile_id`, `logout_at`),
  CONSTRAINT `FK_mdt_profile_sessions_profiles` FOREIGN KEY (`profile_id`) REFERENCES `mdt_profiles` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `type` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `contentyjs` longblob DEFAULT NULL,
  `contentplaintext` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `authorplaintext` VARCHAR(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `datecreated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `dateupdated` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_author` (`author`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_charges` (
  `reportid` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `charge` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `count` int(10) unsigned NOT NULL DEFAULT 1,
  `time` int(10) unsigned DEFAULT NULL,
  `fine` int(10) unsigned DEFAULT NULL,
  KEY `FK_mdt_reports_charges_mdt_reports` (`reportid`),
  KEY `FK_mdt_reports_charges_mdt_penal_codes` (`charge`),
  KEY `idx_charges_citizenid` (`citizenid`),
  CONSTRAINT `FK_mdt_reports_charges_mdt_penal_codes` FOREIGN KEY (`charge`) REFERENCES `mdt_penal_codes` (`label`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_reports_charges_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_evidence` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `content` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `note` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stored` tinyint(4) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `FK_mdt_reports_evidence_mdt_reports` (`reportid`),
  CONSTRAINT `FK_mdt_reports_evidence_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_involved` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mdt_reports_involved_mdt_reports` (`reportid`),
  KEY `idx_involved_citizenid` (`citizenid`),
  CONSTRAINT `FK_mdt_reports_involved_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_restrictions` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `type` varchar(7) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `identifier` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mdt_reports_restrictions_mdt_reports` (`reportid`),
  CONSTRAINT `FK_mdt_reports_restrictions_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_tags` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `tag` varchar(25) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mdt_reports_tags_mdt_reports` (`reportid`),
  CONSTRAINT `FK_mdt_reports_tags_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_reports_warrants` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) NOT NULL DEFAULT '',
  `felonies` int(10) unsigned NOT NULL DEFAULT 0,
  `misdemeanors` int(10) unsigned NOT NULL DEFAULT 0,
  `infractions` int(10) unsigned NOT NULL DEFAULT 0,
  `expirydate` timestamp NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_warrant` (`reportid`, `citizenid`),
  KEY `FK_mdt_reports_warrants_mdt_reports` (`reportid`),
  KEY `FK_mdt_reports_warrants_mdt_profiles` (`citizenid`),
  CONSTRAINT `FK_mdt_reports_warrants_mdt_profiles` FOREIGN KEY (`citizenid`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_reports_warrants_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_arrests` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `officer_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `officer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `reportid` (`reportid`),
  KEY `citizenid` (`citizenid`),
  CONSTRAINT `FK_mdt_arrests_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_arrests_profiles` FOREIGN KEY (`citizenid`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_cases` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_number` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `summary` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `status` enum('open','in_progress','closed') NOT NULL DEFAULT 'open',
  `priority` enum('low','medium','high') NOT NULL DEFAULT 'medium',
  `assigned_department` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_by_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `case_number` (`case_number`),
  KEY `status` (`status`),
  KEY `assigned_department` (`assigned_department`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_case_officers` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `role` enum('primary','assisting','supervisor') NOT NULL DEFAULT 'assisting',
  `assigned_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  KEY `citizenid` (`citizenid`),
  CONSTRAINT `FK_mdt_case_officers_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_case_officers_profiles` FOREIGN KEY (`citizenid`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_case_attachments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(10) unsigned NOT NULL,
  `type` enum('photo','document','other') NOT NULL DEFAULT 'document',
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  CONSTRAINT `FK_mdt_case_attachments_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_case_notes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(10) unsigned NOT NULL,
  `content` text NOT NULL,
  `author_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  CONSTRAINT `FK_mdt_case_notes_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_case_reports` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(10) unsigned NOT NULL,
  `report_id` int(10) unsigned NOT NULL,
  `linked_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `linked_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_case_report` (`case_id`, `report_id`),
  KEY `case_id` (`case_id`),
  KEY `report_id` (`report_id`),
  CONSTRAINT `FK_case_reports_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_case_reports_reports` FOREIGN KEY (`report_id`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_evidence_items` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_id` int(10) unsigned DEFAULT NULL,
  `report_id` int(10) unsigned DEFAULT NULL,
  `title` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `serial` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `location` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stash_id` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `stored` tinyint(1) NOT NULL DEFAULT 0,
  `last_holder` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `case_id` (`case_id`),
  KEY `report_id` (`report_id`),
  KEY `last_holder` (`last_holder`),
  CONSTRAINT `FK_mdt_evidence_items_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  CONSTRAINT `FK_mdt_evidence_items_reports` FOREIGN KEY (`report_id`) REFERENCES `mdt_reports` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_evidence_custody` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `evidence_id` int(10) unsigned NOT NULL,
  `from_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `to_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` enum('collected','transferred','stored','released','updated','viewed') NOT NULL DEFAULT 'collected',
  `notes` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `evidence_id` (`evidence_id`),
  CONSTRAINT `FK_mdt_evidence_custody_items` FOREIGN KEY (`evidence_id`) REFERENCES `mdt_evidence_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_evidence_images` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `evidence_id` int(10) unsigned NOT NULL,
  `url` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `evidence_id` (`evidence_id`),
  CONSTRAINT `FK_mdt_evidence_images_items` FOREIGN KEY (`evidence_id`) REFERENCES `mdt_evidence_items` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_audit_logs` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `actor_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `actor_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `action` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `entity_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `details` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `entity_type` (`entity_type`),
  KEY `entity_id` (`entity_id`),
  KEY `actor_citizenid` (`actor_citizenid`),
  KEY `action` (`action`),
  KEY `created_at` (`created_at`),
  KEY `idx_entity_lookup` (`entity_type`, `entity_id`, `created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Extend player_vehicles with MDT fields (fresh install)
ALTER TABLE `player_vehicles`
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_points` int(11) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_status` varchar(500) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'valid',
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_stolen` tinyint(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_boloactive` tinyint(1) NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS `mdt_vehicle_image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL;

CREATE TABLE IF NOT EXISTS `mdt_weapons` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `serial` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT '',
  `scratched` tinyint(1) NOT NULL DEFAULT 0,
  `owner` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weaponClass` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weaponModel` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `flags` JSON DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE KEY `unique_serial` (`serial`),
  KEY `FK_mdt_weapons_mdt_profiles` (`owner`),
  CONSTRAINT `FK_mdt_weapons_mdt_profiles` FOREIGN KEY (`owner`) REFERENCES `mdt_profiles` (`citizenid`) ON DELETE NO ACTION ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_weapon_ownership_history` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `serial` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `owner` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weapon_model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `weapon_class` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `information` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `changed_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `reason` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mdt_weapon_history_serial` (`serial`),
  KEY `idx_mdt_weapon_history_owner` (`owner`),
  CONSTRAINT `FK_mdt_weapon_history_weapons` FOREIGN KEY (`serial`) REFERENCES `mdt_weapons` (`serial`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_cameras` (
  `cam_id` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cam_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `cam_type` enum('placed','store','bank','jewelry','government','medical','other') CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'placed',
  `model` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'security_cam_03',
  `coords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `rotation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `feed_coords` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Decoupled camera feed position (what the operator sees). NULL = use prop coords',
  `feed_rotation` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL COMMENT 'Decoupled camera feed rotation. NULL = use prop rotation + heading offset',
  `feed_fov` float DEFAULT NULL COMMENT 'Decoupled camera feed FOV. NULL = default FOV',
  `image` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `can_rotate` BOOLEAN NOT NULL DEFAULT TRUE,
  `is_online` BOOLEAN NOT NULL DEFAULT TRUE,
  `spawns_model` BOOLEAN NOT NULL DEFAULT TRUE COMMENT 'TRUE = spawns 3D model (player-placed), FALSE = virtual camera (uses existing world model)',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `created_by` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`cam_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Migration for existing installs: add decoupled camera-feed columns (MariaDB)
ALTER TABLE `mdt_cameras`
  ADD COLUMN IF NOT EXISTS `feed_coords` text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `feed_rotation` text DEFAULT NULL,
  ADD COLUMN IF NOT EXISTS `feed_fov` float DEFAULT NULL;

-- DEFAULT CAMERA DATA (remove if not needed for your server)
INSERT IGNORE INTO `mdt_cameras` (`cam_id`, `cam_label`, `cam_type`, `coords`, `rotation`, `image`, `can_rotate`, `is_online`, `spawns_model`, `created_by`) VALUES
('PCB01', 'Banco do Pacífico: lobby', 'bank', '{"x":257.45,"y":210.07,"z":109.08}', '{"x":-25.0,"y":0.0,"z":28.05}', 'https://files.fivemerr.com/images/45bab512-5836-4449-8831-fbe67d7c886f.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('PCB02', 'Banco do Pacífico: Hall de entrada', 'bank', '{"x":232.86,"y":221.46,"z":107.83}', '{"x":-25.0,"y":0.0,"z":-140.91}', 'https://files.fivemerr.com/images/4a50b347-aa12-4df2-9efc-cf3f38cc1d41.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('PCB03', 'Banco do Pacífico: Cofre', 'bank', '{"x":252.27,"y":225.52,"z":103.99}', '{"x":-35.0,"y":0.0,"z":-74.87}', 'https://files.fivemerr.com/images/7c1604e9-480b-41d2-9c6b-1899c763fb51.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('LTD01', 'Ltd Grove St', 'store', '{"x":-53.14,"y":-1746.71,"z":31.54}', '{"x":-35.0,"y":0.0,"z":-168.9182}', 'https://files.fivemerr.com/images/1ff40a9c-ee6e-4c6f-9273-15bae452375e.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('RLQ01', 'Rob''s Liquor Prosperidade St', 'store', '{"x":-1482.9,"y":-380.463,"z":42.363}', '{"x":-35.0,"y":0.0,"z":79.53281}', 'https://files.fivemerr.com/images/b5bcfe95-3c3f-4dde-a0b9-2024ea5bfa08.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('RLQ02', 'Rob''s Liquor San Andreas Ave', 'store', '{"x":-1224.874,"y":-911.094,"z":14.401}', '{"x":-35.0,"y":0.0,"z":-6.778894}', 'https://files.fivemerr.com/images/f4aba38b-faa0-4050-ab00-ec55d8a1068d.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('LTD02', 'Ltd Gengibre St', 'store', '{"x":-718.153,"y":-909.211,"z":21.49}', '{"x":-35.0,"y":0.0,"z":-137.1431}', 'https://files.fivemerr.com/images/ca78a638-f17a-4456-9061-1648b593e394.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24701', 'Avenida Inocência 24 horas por dia, 7 dias por semana', 'store', '{"x":23.885,"y":-1342.441,"z":31.672}', '{"x":-35.0,"y":0.0,"z":-142.9191}', 'https://files.fivemerr.com/images/ca78a638-f17a-4456-9061-1648b593e394.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('RLQ03', 'Rob''s Liquor El Rancho Blvd', 'store', '{"x":1133.024,"y":-978.712,"z":48.515}', '{"x":-35.0,"y":0.0,"z":-137.302}', 'https://files.fivemerr.com/images/63f7c1dd-c537-44a4-9076-2dd9227dfa97.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('LTD03', 'Ltd West Mirror Drive', 'store', '{"x":1151.93,"y":-320.389,"z":71.33}', '{"x":-35.0,"y":0.0,"z":-119.4468}', 'https://files.fivemerr.com/images/686831ef-ed81-4882-bd23-72c2754e38ab.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24702', 'Avenida Clinton 24/7', 'store', '{"x":383.402,"y":328.915,"z":105.541}', '{"x":-35.0,"y":0.0,"z":118.585}', 'https://files.fivemerr.com/images/2b19a04e-0f1d-4725-8262-1da93b30391e.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('LTD04', 'Ltd Banham Canyon Dr.', 'store', '{"x":-1832.057,"y":789.389,"z":140.436}', '{"x":-35.0,"y":0.0,"z":-91.481}', 'https://files.fivemerr.com/images/c6f53e50-75da-4e4c-806c-08be6822e884.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('RLQ04', 'Liqour de Rob Great Ocean Hwy', 'store', '{"x":-2966.15,"y":387.067,"z":17.393}', '{"x":-35.0,"y":0.0,"z":32.92229}', 'https://files.fivemerr.com/images/f25096f5-5724-4f4b-8a75-b7f968dd67ef.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24703', 'Estrada Ineseno 24 horas por dia, 7 dias por semana', 'store', '{"x":-3046.749,"y":592.491,"z":9.808}', '{"x":-35.0,"y":0.0,"z":-116.673}', 'https://files.fivemerr.com/images/055956f5-6f62-48a7-80d0-c6d94540b6e4.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24704', 'Rua Barbareno 24/7', 'store', '{"x":-3246.489,"y":1010.408,"z":14.705}', '{"x":-35.0,"y":0.0,"z":-135.2151}', 'https://files.fivemerr.com/images/14b9a9ff-4cf0-4373-a784-0723bec9c3b2.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24705', 'Rota 68 24 horas por dia, 7 dias por semana', 'store', '{"x":539.773,"y":2664.904,"z":44.056}', '{"x":-35.0,"y":0.0,"z":-42.947}', 'https://files.fivemerr.com/images/4535c506-42dc-4ca9-9f6e-ece7215e1b7f.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('RLQ05', 'Rota 68 do licor de Rob', 'store', '{"x":1169.855,"y":2711.493,"z":40.432}', '{"x":-35.0,"y":0.0,"z":127.17}', 'https://files.fivemerr.com/images/b8b8e6ff-234a-461f-8636-02c1c9247aeb.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24706', '24 horas por dia, 7 dias por semana, Señora Fwy', 'store', '{"x":2673.579,"y":3281.265,"z":57.541}', '{"x":-35.0,"y":0.0,"z":-80.242}', 'https://files.fivemerr.com/images/cf0b6dc6-3310-441a-ad00-2666fe89c700.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24707', '24 horas por dia, 7 dias por semana, Alhambra Dr.', 'store', '{"x":1966.24,"y":3749.545,"z":34.143}', '{"x":-35.0,"y":0.0,"z":163.065}', 'https://files.fivemerr.com/images/6c3eb8b8-c8a5-4a25-895c-44724ac24a6f.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('24708', '24 horas por dia, 7 dias por semana, Señora Fwy', 'store', '{"x":1729.522,"y":6419.87,"z":37.262}', '{"x":-35.0,"y":0.0,"z":-160.089}', 'https://files.fivemerr.com/images/64918129-eb25-4bd6-abe7-cc6263e36f1d.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('FLB01', 'Praça da Legião do Banco Fleeca', 'bank', '{"x":144.871,"y":-1043.044,"z":31.017}', '{"x":-35.0,"y":0.0,"z":-143.9796}', 'https://files.fivemerr.com/images/92659204-5c5d-44ab-a14f-68a7f83e01f3.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('FLB02', 'Banco Fleeca Hawick/Power', 'bank', '{"x":309.341,"y":-281.439,"z":55.88}', '{"x":-35.0,"y":0.0,"z":-146.1595}', 'https://files.fivemerr.com/images/17a41043-bc9d-4a0c-945d-63d03ff4660d.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('FLB03', 'Fleeca Bank Hawick/San Vitas', 'bank', '{"x":-355.7643,"y":-52.506,"z":50.746}', '{"x":-35.0,"y":0.0,"z":-143.8711}', 'https://files.fivemerr.com/images/ead3415f-bdc5-447f-9d6f-287c77211388.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('FLB04', 'Fleeca Bank Del Perro Blvd.', 'bank', '{"x":-1214.226,"y":-335.86,"z":39.515}', '{"x":-35.0,"y":0.0,"z":-97.862}', 'https://files.fivemerr.com/images/6d00ce1d-6078-4a69-8cfb-ebed60cbf833.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('FLB05', 'Banco Fleeca Great Ocean Hwy', 'bank', '{"x":-2958.885,"y":478.983,"z":17.406}', '{"x":-35.0,"y":0.0,"z":-34.69595}', 'https://files.fivemerr.com/images/dbb2ec99-8212-47f2-9f79-e0b787608ce2.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('PLB01', 'Banco Paleto', 'bank', '{"x":-102.939,"y":6467.668,"z":33.424}', '{"x":-35.0,"y":0.0,"z":24.66}', 'https://files.fivemerr.com/images/ff06da26-2cd6-4337-a1ca-c738d4267ae5.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('VGY01', 'Joias Vangelico: Frente Direita', 'jewelry', '{"x":-627.54,"y":-239.74,"z":40.33}', '{"x":-35.0,"y":0.0,"z":5.78}', 'https://files.fivemerr.com/images/348eca1b-17ad-48fc-8f03-1c21bd87dadc.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('VGY02', 'Joias Vangelico: Frente Esquerda', 'jewelry', '{"x":-627.51,"y":-229.51,"z":40.24}', '{"x":-35.0,"y":0.0,"z":-95.78}', 'https://files.fivemerr.com/images/707df30b-440e-4e55-ac93-c1878c381cee.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('VGY03', 'Joias Vangelico: Atrás Esquerda', 'jewelry', '{"x":-620.3,"y":-224.31,"z":40.23}', '{"x":-35.0,"y":0.0,"z":165.78}', 'https://files.fivemerr.com/images/371e5386-c901-451d-a3c4-ce7a371bee86.png', TRUE, TRUE, FALSE, 'SYSTEM'),
('VGY04', 'Joalharia Vangelico: Lado', 'jewelry', '{"x":-622.57,"y":-236.3,"z":40.31}', '{"x":-35.0,"y":0.0,"z":5.78}', 'https://files.fivemerr.com/images/4c90514e-7a31-4654-a7a9-40864d106028.png', TRUE, TRUE, FALSE, 'SYSTEM');

CREATE TABLE IF NOT EXISTS `mdt_bolos` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `type` enum('citizen','vehicle','weapon','property','other') NOT NULL DEFAULT 'citizen',
  `subject_id` varchar(50) NOT NULL COMMENT 'citizenid, plate, serial, etc depending on type',
  `subject_name` varchar(100) DEFAULT NULL COMMENT 'Full name, vehicle model, weapon type, etc',
  `reportId` int(11) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `status` enum('active','inactive','resolved') NOT NULL DEFAULT 'active',
  PRIMARY KEY (`id`),
  KEY `type` (`type`),
  KEY `subject_id` (`subject_id`),
  KEY `status` (`status`),
  KEY `reportId` (`reportId`),
  CONSTRAINT `FK_mdt_bolos_reports` FOREIGN KEY (`reportId`) REFERENCES `mdt_reports` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_impound` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `vehicleid` int(11) NOT NULL,
  `status` enum('active','released') NOT NULL DEFAULT 'active',
  `plate` varchar(16) DEFAULT NULL,
  `reason` varchar(100) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `photo` varchar(255) DEFAULT NULL,
  `lot` varchar(32) DEFAULT NULL,
  `linkedreport` int(10) unsigned DEFAULT NULL,
  `fee` int(11) NOT NULL DEFAULT 0,
  `fee_paid` tinyint(1) NOT NULL DEFAULT 0,
  `hold_type` enum('immediate','timed','indefinite') NOT NULL DEFAULT 'immediate',
  `hold_until` int(11) DEFAULT NULL,
  `hold_label` varchar(64) DEFAULT NULL,
  `officer_citizenid` varchar(50) DEFAULT NULL,
  `officer_name` varchar(100) DEFAULT NULL,
  `time` int(11) NOT NULL DEFAULT 0,
  `released_at` int(11) DEFAULT NULL,
  `released_by_citizenid` varchar(50) DEFAULT NULL,
  `released_by_name` varchar(100) DEFAULT NULL,
  `override_reason` varchar(300) DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `vehicleid` (`vehicleid`),
  KEY `linkedreport` (`linkedreport`),
  KEY `idx_impound_status` (`status`, `time`),
  KEY `idx_impound_plate` (`plate`),
  CONSTRAINT `FK_mdt_impound_reports` FOREIGN KEY (`linkedreport`) REFERENCES `mdt_reports` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `mdt_reports_charges_after_delete` AFTER UPDATE ON `mdt_reports_charges` FOR EACH ROW BEGIN
    UPDATE mdt_reports_warrants
    SET
        felonies = (
            SELECT SUM(CASE WHEN mc.charge_class = 'felony' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = OLD.reportid
        ),
        misdemeanors = (
            SELECT SUM(CASE WHEN mc.charge_class = 'misdemeanor' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = OLD.reportid
        ),
        infractions = (
            SELECT SUM(CASE WHEN mc.charge_class = 'infraction' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = OLD.reportid
        )
    WHERE reportid = OLD.reportid;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;

SET @OLDTMP_SQL_MODE=@@SQL_MODE, SQL_MODE='STRICT_TRANS_TABLES,ERROR_FOR_DIVISION_BY_ZERO,NO_AUTO_CREATE_USER,NO_ENGINE_SUBSTITUTION';
DELIMITER //
CREATE TRIGGER `mdt_reports_charges_after_insert` AFTER INSERT ON `mdt_reports_charges` FOR EACH ROW BEGIN
    UPDATE mdt_reports_warrants
    SET
        felonies = (
            SELECT SUM(CASE WHEN mc.charge_class = 'felony' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = NEW.reportid
        ),
        misdemeanors = (
            SELECT SUM(CASE WHEN mc.charge_class = 'misdemeanor' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = NEW.reportid
        ),
        infractions = (
            SELECT SUM(CASE WHEN mc.charge_class = 'infraction' THEN 1 ELSE 0 END)
        FROM mdt_reports_charges AS mrc
                     INNER JOIN mdt_penal_codes AS mc
                                ON mrc.charge = mc.label
            WHERE mrc.reportid = NEW.reportid
        )
    WHERE reportid = NEW.reportid;
END//
DELIMITER ;
SET SQL_MODE=@OLDTMP_SQL_MODE;


-- Tags master table

CREATE TABLE IF NOT EXISTS `mdt_tags` (
  `id` INT(10) UNSIGNED NOT NULL AUTO_INCREMENT,
  `name` VARCHAR(25) NOT NULL,
  `type` ENUM('report','officer','citizen') NOT NULL DEFAULT 'citizen',
  `color` VARCHAR(7) NOT NULL DEFAULT '#6b7280',
  `job_type` VARCHAR(10) NOT NULL DEFAULT 'all',
  `description` VARCHAR(120) NULL DEFAULT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_tag_name_job` (`name`, `job_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Default LEO Officer Tags
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('SWAT', 'officer', '#3b82f6', 'leo'),
('FTO', 'officer', '#10b981', 'leo'),
('Detetive', 'officer', '#8b5cf6', 'leo'),
('Provação', 'officer', '#f59e0b', 'leo'),
('Comando', 'officer', '#ef4444', 'leo'),
('Certificado K9', 'officer', '#06b6d4', 'leo'),
('Certificado Aéreo', 'officer', '#ec4899', 'leo');

-- Default EMS Officer Tags
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('Paramédico', 'officer', '#10b981', 'ems'),
('Cirurgião', 'officer', '#3b82f6', 'ems'),
('Estagiário', 'officer', '#f59e0b', 'ems'),
('De plantão', 'officer', '#06b6d4', 'ems');

-- Default Citizen Tags (LEO) — officer-safety / record flags
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('Armado e Perigoso', 'citizen', '#dc2626', 'leo'),
('Violento', 'citizen', '#ef4444', 'leo'),
('Risco de voo', 'citizen', '#f97316', 'leo'),
('Resistindo', 'citizen', '#f97316', 'leo'),
('Criminoso', 'citizen', '#b91c1c', 'leo'),
('Ofensor reincidente', 'citizen', '#ea580c', 'leo'),
('Membro de gangue', 'citizen', '#ec4899', 'leo'),
('Usuário de drogas', 'citizen', '#06b6d4', 'leo'),
('Provação', 'citizen', '#f59e0b', 'leo'),
('Liberdade condicional', 'citizen', '#f59e0b', 'leo'),
('Informante', 'citizen', '#06b6d4', 'leo'),
('Saúde mental', 'citizen', '#8b5cf6', 'leo'),
('Licença Suspensa', 'citizen', '#6b7280', 'leo'),
('Veterano', 'citizen', '#10b981', 'leo');

-- Default Citizen Tags (EMS medical + shared)
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('Alergia', 'citizen', '#ef4444', 'ems'),
('DNR', 'citizen', '#8b5cf6', 'ems'),
('Diabético', 'citizen', '#06b6d4', 'ems'),
('Epiléptico', 'citizen', '#a855f7', 'ems'),
('Condição cardíaca', 'citizen', '#dc2626', 'ems'),
('Doador de órgãos', 'citizen', '#10b981', 'ems'),
('Alerta Médico', 'citizen', '#f59e0b', 'all');

-- Default LEO Report Tags
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('Roubo', 'report', '#ef4444', 'leo'),
('Armado', 'report', '#f97316', 'leo'),
('Prioridade', 'report', '#f59e0b', 'leo'),
('Ativo', 'report', '#10b981', 'leo'),
('Balística', 'report', '#8b5cf6', 'leo'),
('Relacionado a gangues', 'report', '#ec4899', 'leo'),
('Relacionado a drogas', 'report', '#06b6d4', 'leo'),
('Tráfego', 'report', '#3b82f6', 'leo'),
('Doméstico', 'report', '#6b7280', 'leo'),
('Assalto', 'report', '#ef4444', 'leo'),
('Alta prioridade', 'report', '#f59e0b', 'leo'),
('Confidencial', 'report', '#8b5cf6', 'leo'),
('Investigação Ativa', 'report', '#10b981', 'leo');

-- Default EMS Report Tags
INSERT IGNORE INTO mdt_tags (name, type, color, job_type) VALUES
('Overdose', 'report', '#ef4444', 'ems'),
('Trauma', 'report', '#f97316', 'ems'),
('DOA', 'report', '#6b7280', 'ems'),
('Transporte', 'report', '#3b82f6', 'ems'),
('Emergência Médica', 'report', '#f59e0b', 'ems'),
('Psiquiátrico', 'report', '#8b5cf6', 'ems');

CREATE TABLE IF NOT EXISTS `mdt_report_vehicles` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `reportid` int(10) unsigned NOT NULL,
  `plate` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `vehicle_label` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `owner_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `owner_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `FK_mdt_report_vehicles_mdt_reports` (`reportid`),
  KEY `idx_report_vehicles_plate` (`plate`),
  CONSTRAINT `FK_mdt_report_vehicles_mdt_reports` FOREIGN KEY (`reportid`) REFERENCES `mdt_reports` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_report_templates` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `type` varchar(50) NOT NULL,
  `content` longtext NOT NULL,
  `job_type` VARCHAR(50) NULL DEFAULT 'all',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `mdt_report_templates` (`name`, `type`, `content`) VALUES
('Incidente Padrão', 'Incident Report', '<h2>Resumo do incidente</h2>\n<p>Em [DATE], aproximadamente às [TIME] horas, [OFFICER NAME/BADGE] respondeu a uma chamada em [LOCATION] sobre [TYPE OF INCIDENT].</p>\n\n<h2>Detalhes do incidente</h2>\n<p>Na chegada, os policiais observaram [DESCRIBE SCENE]. [DESCRIBE WHAT HAPPENED IN CHRONOLOGICAL ORDER].</p>\n\n<h2>Partes Envolvidas</h2>\n<p><strong>Parte Denunciante:</strong> [NAME] - [CONTACT INFO]</p>\n<p><strong>Suspeito(s):</strong> [NAME/DESCRIPTION]</p>\n<p><strong>Vítima(s):</strong> [NAME]</p>\n<p><strong>Testemunha(s):</strong> [NAME - STATEMENT SUMMARY]</p>\n\n<h2>Evidência Coletado</h2>\n<ul>\n<li>[ITEM 1 - DESCRIPTION AND LOCATION FOUND]</li>\n<li>[ITEM 2 - DESCRIPTION AND LOCATION FOUND]</li>\n</ul>\n\n<h2>Ações tomadas</h2>\n<p>[DESCRIBE OFFICER ACTIONS: ARRESTS MADE, CITATIONS ISSUED, MEDICAL ATTENTION PROVIDED, ETC.]</p>\n\n<h2>Conclusão</h2>\n<p>[CASE STATUS: OPEN/CLOSED/PENDING INVESTIGATION]. [ANY FOLLOW-UP REQUIRED].</p>'),
('Tráfego padrão', 'Traffic Report', '<h2>Resumo de incidente de trânsito</h2>\n<p>Em [DATE] aproximadamente às [TIME] horas, [OFFICER NAME/BADGE] respondeu a um incidente de trânsito em [LOCATION/INTERSECTION].</p>\n\n<h2>Informações do veículo</h2>\n<p><strong>Veículo 1:</strong> [YEAR MAKE MODEL COLOR] - Placa: [PLATE] - Driver: [NAME]</p>\n<p><strong>Veículo 2:</strong> [YEAR MAKE MODEL COLOR] - Placa: [PLATE] - Driver: [NAME]</p>\n\n<h2>Descrição do Incidente</h2>\n<p>[DESCRIBE HOW THE INCIDENT OCCURRED. INCLUDE DIRECTION OF TRAVEL, SPEED, ROAD CONDITIONS, WEATHER.]</p>\n\n<h2>Lesões</h2>\n<p>[DESCRIBE ANY INJURIES. NOTE IF EMS WAS CALLED AND TRANSPORT DESTINATION.]</p>\n\n<h2>Citações emitidas</h2>\n<ul>\n<li>[DRIVER NAME] - [VIOLATION CODE] - [DESCRIPTION]</li>\n</ul>\n\n<h2>Declarações de testemunhas</h2>\n<p>[NAME]: [BRIEF SUMMARY OF STATEMENT]</p>\n\n<h2>Diagrama / Adicional Notas</h2>\n<p>[DESCRIBE SCENE LAYOUT OR REFERENCE ATTACHED DIAGRAM]</p>'),
('Investigação Completa', 'Investigation Report', '<h2>Visão Geral do Caso</h2>\n<p><strong>Número do Caso:</strong> [CASE #]</p>\n<p><strong>Investigador Principal:</strong> [NAME/BADGE]</p>\n<p><strong>Data Aberto:</strong> [DATE]</p>\n<p><strong>Classificação:</strong> [FELONY/MISDEMEANOR/OTHER]</p>\n\n<h2>Contexto</h2>\n<p>[PROVIDE CONTEXT FOR THE INVESTIGATION. WHAT PROMPTED IT. REFERENCE ANY PRIOR REPORTS.]</p>\n\n<h2>Pessoas de Interesse</h2>\n<p><strong>Suspeito 1:</strong> [NAME] - [DESCRIPTION, KNOWN ASSOCIATES, LAST KNOWN LOCATION]</p>\n<p><strong>Suspeito 2:</strong> [NAME] - [DESCRIPTION]</p>\n\n<h2>Resumo de evidências</h2>\n<ul>\n<li>[EVIDENCE ITEM] - [WHERE/HOW OBTAINED] - [RELEVANCE]</li>\n<li>[EVIDENCE ITEM] - [WHERE/HOW OBTAINED] - [RELEVANCE]</li>\n</ul>\n\n<h2>Linha do tempo de Eventos</h2>\n<ul>\n<li><strong>[DATE/TIME]:</strong> [EVENT]</li>\n<li><strong>[DATE/TIME]:</strong> [EVENT]</li>\n</ul>\n\n<h2>Entrevistas realizadas</h2>\n<p><strong>[NAME]:</strong> [SUMMARY OF INTERVIEW]</p>\n\n<h2>Descobertas e Recomendações</h2>\n<p>[SUMMARIZE FINDINGS. RECOMMEND NEXT STEPS: CHARGES, FURTHER INVESTIGATION, CASE CLOSURE.]</p>'),
('Prisão Padrão', 'Arrest Report', '<h2>Resumo da prisão</h2>\n<p>Em [DATE], aproximadamente às [TIME] horas, [OFFICER NAME/BADGE] colocou [SUSPECT NAME] sob prisão em [LOCATION].</p>\n\n<h2>Suspeito Informações</h2>\n<p><strong>Nome:</strong> [FULL NAME]</p>\n<p><strong>ID do cidadão:</strong> [ID]</p>\n<p><strong>Descrição:</strong> [HEIGHT, BUILD, CLOTHING, DISTINGUISHING MARKS]</p>\n\n<h2>Causa provável</h2>\n<p>[DESCRIBE THE CIRCUMSTANCES AND EVIDENCE THAT ESTABLISHED PROBABLE CAUSE FOR THE ARREST]</p>\n\n<h2>Cargas</h2>\n<ul>\n<li>[CHARGE CODE] - [CHARGE DESCRIPTION] - [FELONY/MISDEMEANOR]</li>\n<li>[CHARGE CODE] - [CHARGE DESCRIPTION] - [FELONY/MISDEMEANOR]</li>\n</ul>\n\n<h2>Narrativa</h2>\n<p>[DETAILED CHRONOLOGICAL ACCOUNT OF EVENTS LEADING TO THE ARREST]</p>\n\n<h2>Evidências Apreendidas</h2>\n<ul>\n<li>[ITEM] - [DESCRIPTION]</li>\n</ul>\n\n<h2>Miranda Rights</h2>\n<p>O suspeito foi lido pelos direitos de Miranda em [TIME]. O suspeito [DID/DID NOT] invoca o direito a um advogado. O suspeito [DID/DID NOT] fornece uma declaração.</p>\n\n<h2>Processing</h2>\n<p>O suspeito foi autuado em [FACILITY] em [TIME]. [BAIL/HOLD INFORMATION].</p>'),
('Coleta de evidências', 'Evidence Report', '<h2>Resumo do relatório de evidências</h2>\n<p><strong>Caso relacionado:</strong> [CASE #]</p>\n<p><strong>Oficial de coleta:</strong> [NAME/BADGE]</p>\n<p><strong>Data Coletado:</strong> [DATE]</p>\n<p><strong>Localização:</strong> [COLLECTION SITE]</p>\n\n<h2>Itens de evidência</h2>\n<h3>Item 1</h3>\n<p><strong>Descrição:</strong> [DETAILED DESCRIPTION]</p>\n<p><strong>Série/ID:</strong> [IF APPLICABLE]</p>\n<p><strong>Localização Encontrado:</strong> [EXACT LOCATION AT SCENE]</p>\n<p><strong>Condição:</strong> [CONDITION WHEN FOUND]</p>\n<p><strong>Armazenamento:</strong> [LOCKER/STASH ID]</p>\n\n<h3>Item 2</h3>\n<p><strong>Descrição:</strong> [DETAILED DESCRIPTION]</p>\n<p><strong>Local encontrado:</strong> [EXACT LOCATION AT SCENE]</p>\n<p><strong>Armazenamento:</strong> [LOCKER/STASH ID]</p>\n\n<h2>Cadeia de Custódia</h2>\n<ul>\n<li><strong>[DATE/TIME]:</strong> Coletado por [NAME] em [LOCATION]</li>\n<li><strong>[DATE/TIME]:</strong> Transferido para [NAME/FACILITY]</li>\n</ul>\n\n<h2>Análise solicitada</h2>\n<p>[DESCRIBE ANY LAB ANALYSIS OR FORENSIC TESTING REQUESTED]</p>\n\n<h2>Notas</h2>\n<p>[ANY ADDITIONAL OBSERVATIONS OR CONTEXT]</p>');


-- Keep report templates isolated by MDT domain.
UPDATE `mdt_report_templates`
SET `job_type` = 'leo'
WHERE (`job_type` IS NULL OR `job_type` = 'all')
  AND `type` IN ('Incident Report', 'Traffic Report', 'Investigation Report', 'Arrest Report', 'Evidence Report', 'Relatório de incidente', 'Relatório de tráfego', 'Relatório de Investigação', 'Relatório de prisão', 'Relatório de evidências');

INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Avaliação Médica Geral', 'Medical Report', '<h2>Avaliação do paciente</h2><p><strong>Queixa principal:</strong> [QUEIXA]</p><p><strong>Sinais vitais:</strong> [SINAIS VITAIS]</p><h2>Tratamento e Destino</h2><p>[TRATAMENTO / TRANSPORTE]</p>', 'ems'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'ems' AND `type` = 'Medical Report');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Atendimento de Trauma', 'Trauma Report', '<h2>Avaliação do trauma</h2><p><strong>Mecanismo da lesão:</strong> [MECANISMO]</p><p><strong>Lesões:</strong> [LESÕES]</p><h2>Intervenções</h2><p>[INTERVENÇÕES / TRANSPORTE]</p>', 'ems'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'ems' AND `type` = 'Trauma Report');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Atendimento de Overdose', 'Overdose Report', '<h2>Avaliação da overdose</h2><p><strong>Substância suspeita:</strong> [SUBSTÂNCIA]</p><p><strong>Condição inicial:</strong> [CONDIÇÃO]</p><h2>Tratamento e Resultado</h2><p>[TRATAMENTO / RESPOSTA / TRANSPORTE]</p>', 'ems'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'ems' AND `type` = 'Overdose Report');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Avaliação Psiquiátrica', 'Psychiatric Report', '<h2>Avaliação de saúde mental</h2><p><strong>Apresentação:</strong> [APRESENTAÇÃO]</p><p><strong>Avaliação de risco:</strong> [RISCO]</p><h2>Intervenção e Destino</h2><p>[INTERVENÇÃO / DESTINO]</p>', 'ems'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'ems' AND `type` = 'Psychiatric Report');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Atendimento com Múltiplas Vítimas', 'Mass Casualty Report', '<h2>Visão geral do incidente</h2><p><strong>Local:</strong> [LOCAL]</p><p><strong>Resumo da triagem:</strong> [QUANTIDADES POR TRIAGEM]</p><h2>Recursos e Transporte</h2><p>[RECURSOS / DESTINOS]</p>', 'ems'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'ems' AND `type` = 'Mass Casualty Report');

INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Petição Judicial Padrão', 'Court Filing', '<h2>Petição judicial</h2><p><strong>Processo:</strong> [PROCESSO Nº]</p><p>[DETALHES DA PETIÇÃO]</p>', 'doj'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'doj' AND `type` = 'Court Filing');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Memorial Jurídico Padrão', 'Legal Brief', '<h2>Memorial jurídico</h2><p><strong>Matéria:</strong> [MATÉRIA]</p><p>[ARGUMENTOS E FUNDAMENTOS]</p>', 'doj'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'doj' AND `type` = 'Legal Brief');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Ordem Judicial Padrão', 'Judicial Order', '<h2>Ordem judicial</h2><p><strong>Processo:</strong> [PROCESSO Nº]</p><p>[ORDEM]</p>', 'doj'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'doj' AND `type` = 'Judicial Order');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Acordo Judicial Padrão', 'Plea Agreement', '<h2>Acordo judicial</h2><p><strong>Réu:</strong> [NOME]</p><p>[TERMOS]</p>', 'doj'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'doj' AND `type` = 'Plea Agreement');
INSERT INTO `mdt_report_templates` (`name`, `type`, `content`, `job_type`)
SELECT 'Relatório de Sentença Padrão', 'Sentencing Report', '<h2>Relatório de sentença</h2><p><strong>Réu:</strong> [NOME]</p><p>[FUNDAMENTAÇÃO E SENTENÇA]</p>', 'doj'
WHERE NOT EXISTS (SELECT 1 FROM `mdt_report_templates` WHERE `job_type` = 'doj' AND `type` = 'Sentencing Report');

CREATE TABLE IF NOT EXISTS `mdt_awards` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(100) NOT NULL,
  `description` varchar(255) DEFAULT NULL,
  `icon` varchar(50) NOT NULL DEFAULT 'emoji_events',
  `category` varchar(50) NOT NULL DEFAULT 'general',
  `goal_type` varchar(50) NOT NULL,
  `goal_amount` int(10) unsigned NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `mdt_awards` (`name`, `description`, `icon`, `category`, `goal_type`, `goal_amount`) VALUES
('Primeiro relatório', 'Arquive seu primeiro relatório no sistema MDT', 'description', 'relatórios', 'reports', 1),
('50 relatórios arquivados', 'Arquive 50 relatórios demonstrando documentação consistente', 'description', 'relatórios', 'reports', 50),
('100 relatórios arquivados', 'Arquive 100 relatórios mostrando dedicação à manutenção completa de registros', 'description', 'relatórios', 'reports', 100),
('Primeira prisão', 'Faça sua primeira prisão e apresente o relatório de prisão', 'local_police', 'prisões', 'arrests', 1),
('50 prisões', 'Processe 50 prisões como oficial experiente', 'local_police', 'prisões', 'arrests', 50),
('Assistente de caso', 'Trabalhe em 25 casos como investigador', 'work', 'casos', 'cases', 25),
('$ 100 mil multado', 'Emitir um total de US$ 100.000 em multas', 'payments', 'financeiro', 'totalFined', 100000),
('10 mandados emitidos', 'Emitir 10 mandados para suspeitos', 'gavel', 'mandados', 'warrants', 10);

CREATE TABLE IF NOT EXISTS `mdt_custom_licenses` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `name` varchar(50) NOT NULL,
  `description` varchar(150) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_license_name` (`name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_citizen_licenses` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `license_id` int(10) unsigned NOT NULL,
  `active` tinyint(1) NOT NULL DEFAULT 1,
  `granted_by` varchar(50) DEFAULT NULL,
  `granted_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `unique_citizen_license` (`citizenid`, `license_id`),
  KEY `citizenid` (`citizenid`),
  KEY `license_id` (`license_id`),
  CONSTRAINT `FK_mdt_citizen_licenses_custom` FOREIGN KEY (`license_id`) REFERENCES `mdt_custom_licenses` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

INSERT IGNORE INTO `mdt_custom_licenses` (`name`, `description`) VALUES
('Licença de caça', 'Permite a caça de animais selvagens em áreas designadas'),
('Licença de navegação', 'Necessário para operar embarcações'),
('Licença de Piloto', 'Necessário para operar aeronaves');

-- Internal Affairs
CREATE TABLE IF NOT EXISTS `mdt_ia_complaints` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `complaint_number` varchar(20) NOT NULL,
  `complainant_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `complainant_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `complainant_phone` varchar(20) DEFAULT NULL,
  `officer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `officer_badge` varchar(20) DEFAULT NULL,
  `category` enum('misconduct','excessive_force','corruption','negligence','discrimination','other') NOT NULL DEFAULT 'other',
  `description` text NOT NULL,
  `incident_date` varchar(20) DEFAULT NULL,
  `incident_location` varchar(200) DEFAULT NULL,
  `witnesses` text DEFAULT NULL,
  `evidence` text DEFAULT NULL,
  `status` enum('open','under_review','investigated','sustained','exonerated','unfounded','closed') NOT NULL DEFAULT 'open',
  `assigned_to` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `assigned_to_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `complaint_number` (`complaint_number`),
  KEY `status` (`status`),
  KEY `assigned_to` (`assigned_to`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_ia_notes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `complaint_id` int(10) unsigned NOT NULL,
  `content` text NOT NULL,
  `author_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `complaint_id` (`complaint_id`),
  CONSTRAINT `FK_ia_notes_complaints` FOREIGN KEY (`complaint_id`) REFERENCES `mdt_ia_complaints` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- PPR (Performance Planning and Review)

CREATE TABLE IF NOT EXISTS `mdt_ppr` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ppr_number` varchar(20) NOT NULL DEFAULT '',
  `officer_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `officer_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `author_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `category` enum('positive','coaching','disciplinary') NOT NULL DEFAULT 'coaching',
  `title` varchar(200) NOT NULL,
  `description` text NOT NULL,
  `incident_date` varchar(20) DEFAULT NULL,
  `incident_location` varchar(200) DEFAULT NULL,
  `linked_report_id` int(10) unsigned DEFAULT NULL,
  `linked_case_id` int(10) unsigned DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `ppr_number` (`ppr_number`),
  KEY `officer_citizenid` (`officer_citizenid`),
  KEY `author_citizenid` (`author_citizenid`),
  KEY `category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_ppr_notes` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `ppr_id` int(10) unsigned NOT NULL,
  `content` text NOT NULL,
  `author_citizenid` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `author_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `ppr_id` (`ppr_id`),
  CONSTRAINT `FK_ppr_notes_ppr` FOREIGN KEY (`ppr_id`) REFERENCES `mdt_ppr` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- FTO (Field Training Officer) Tables

CREATE TABLE IF NOT EXISTS `mdt_fto_phases` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL DEFAULT 'police',
  `name` varchar(200) NOT NULL,
  `description` text DEFAULT NULL,
  `duration_days` int(10) unsigned DEFAULT 0,
  `sort_order` int(10) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_fto_competencies` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL DEFAULT 'police',
  `name` varchar(200) NOT NULL,
  `category` varchar(100) DEFAULT 'General',
  `sort_order` int(10) unsigned DEFAULT 0,
  PRIMARY KEY (`id`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_fto_assignments` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `fto_number` varchar(20) NOT NULL DEFAULT '',
  `trainee_citizenid` varchar(50) NOT NULL,
  `trainee_name` varchar(100) NOT NULL,
  `trainer_citizenid` varchar(50) NOT NULL,
  `trainer_name` varchar(100) NOT NULL,
  `current_phase_id` int(10) unsigned DEFAULT NULL,
  `status` enum('active','completed','failed','suspended') NOT NULL DEFAULT 'active',
  `start_date` varchar(20) DEFAULT NULL,
  `end_date` varchar(20) DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `fto_number` (`fto_number`),
  KEY `trainee_citizenid` (`trainee_citizenid`),
  KEY `trainer_citizenid` (`trainer_citizenid`),
  KEY `status` (`status`),
  KEY `current_phase_id` (`current_phase_id`),
  CONSTRAINT `FK_fto_assignments_phase` FOREIGN KEY (`current_phase_id`) REFERENCES `mdt_fto_phases` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_fto_dors` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `assignment_id` int(10) unsigned NOT NULL,
  `phase_id` int(10) unsigned DEFAULT NULL,
  `author_citizenid` varchar(50) NOT NULL,
  `author_name` varchar(100) NOT NULL,
  `shift_date` varchar(20) NOT NULL,
  `overall_rating` int(1) unsigned NOT NULL DEFAULT 3,
  `notes` text DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `assignment_id` (`assignment_id`),
  KEY `phase_id` (`phase_id`),
  CONSTRAINT `FK_fto_dors_assignment` FOREIGN KEY (`assignment_id`) REFERENCES `mdt_fto_assignments` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_fto_dors_phase` FOREIGN KEY (`phase_id`) REFERENCES `mdt_fto_phases` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_fto_dor_ratings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `dor_id` int(10) unsigned NOT NULL,
  `competency_id` int(10) unsigned NOT NULL,
  `rating` int(1) unsigned NOT NULL DEFAULT 3,
  `notes` text DEFAULT NULL,
  PRIMARY KEY (`id`),
  KEY `dor_id` (`dor_id`),
  KEY `competency_id` (`competency_id`),
  CONSTRAINT `FK_fto_dor_ratings_dor` FOREIGN KEY (`dor_id`) REFERENCES `mdt_fto_dors` (`id`) ON DELETE CASCADE ON UPDATE CASCADE,
  CONSTRAINT `FK_fto_dor_ratings_competency` FOREIGN KEY (`competency_id`) REFERENCES `mdt_fto_competencies` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- FTO Default Data (change 'police' to your job name if different)

INSERT IGNORE INTO `mdt_fto_phases` (`id`, `job`, `name`, `description`, `duration_days`, `sort_order`) VALUES
(1, 'police', 'Fase 1 - Observação', 'O estagiário observa o FTO durante chamadas e patrulha. O FTO demonstra procedimentos adequados, redação de relatórios e comunicação por rádio.', 14, 1),
(2, 'police', 'Fase 2 – Patrulha Supervisionada', 'O estagiário lidera as chamadas com supervisão do FTO. O FTO avalia a tomada de decisões, a segurança dos oficiais e a aplicação da lei.', 21, 2),
(3, 'police', 'Fase 3 – Supervisão Reduzida', 'O estagiário opera com entrada mínima de FTO. O FTO só intervém quando necessário e avalia a prontidão para patrulha individual.', 14, 3),
(4, 'police', 'Fase 4 – Avaliação Solo', 'O estagiário patrulha de forma independente enquanto o FTO observa à distância ou analisa relatórios. Avaliação final antes da aprovação.', 7, 4);

INSERT IGNORE INTO `mdt_fto_competencies` (`id`, `job`, `name`, `category`, `sort_order`) VALUES
(1, 'police', 'Condução e operações de veículos', 'Patrulha', 1),
(2, 'police', 'Radiocomunicação', 'Comunicação', 2),
(3, 'police', 'Comunicação verbal', 'Comunicação', 3),
(4, 'police', 'Redação de relatórios', 'Documentação', 4),
(5, 'police', 'Conhecimento dos Códigos Penais', 'Jurídico', 5),
(6, 'police', 'Conhecimento das leis de trânsito', 'Jurídico', 6),
(7, 'police', 'Uso de decisões de força', 'Tático', 7),
(8, 'police', 'Segurança e Conscientização do Oficial', 'Tático', 8),
(9, 'police', 'Interação suspeita e redução da escalada', 'Comunicação', 9),
(10, 'police', 'Gerenciamento de cena', 'Tático', 10),
(11, 'police', 'Tratamento de evidências', 'Documentação', 11),
(12, 'police', 'Profissionalismo e Conduta', 'Em geral', 12);

-- SOP (Standard Operating Procedures) Tables

CREATE TABLE IF NOT EXISTS `mdt_sop_categories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL,
  `title` varchar(200) NOT NULL,
  `icon` varchar(50) DEFAULT 'description',
  `sort_order` int(10) unsigned DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_sop_sections` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `category_id` int(10) unsigned NOT NULL,
  `title` varchar(200) NOT NULL,
  `content` text NOT NULL,
  `sort_order` int(10) unsigned DEFAULT 0,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `category_id` (`category_id`),
  CONSTRAINT `FK_sop_sections_category` FOREIGN KEY (`category_id`) REFERENCES `mdt_sop_categories` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_sop_settings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL,
  `mission_statement` text DEFAULT NULL,
  `introduction` text DEFAULT NULL,
  `version` int(10) unsigned DEFAULT 0,
  `updated_by` varchar(100) DEFAULT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_sop_acknowledgements` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `job` varchar(50) NOT NULL,
  `version` int(10) unsigned NOT NULL,
  `agreed_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  UNIQUE KEY `citizenid_job` (`citizenid`, `job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- SOP Default Data (change 'police' to your job name if different)

INSERT IGNORE INTO `mdt_sop_settings` (`job`, `mission_statement`, `introduction`, `version`) VALUES
('police',
 '<p><strong>Missão</strong></p><p>A missão da Aplicação da Lei é fornecer serviços de segurança pública eficientes e eficazes aos residentes e visitantes da cidade. Fornecemos esses serviços com caráter, competência e comunicação aberta.</p><p><strong>Valores</strong></p><p>Julgamento, Unidade, Habilidade, Confiança, Engenhosidade, Coragem, Empoderamento = <strong>JUSTIÇA</strong></p><p><strong>M.O.S. Requisito</strong></p><p>Todos os Membros do Serviço (MOS) devem cumprir os valores acima mencionados e o código de conduta de procedimento em todos os momentos.</p><p>Um briefing deve ser realizado se houver 4 ou mais policiais no referido departamento por seu departamento CS. A legislatura do departamento ditará os termos desses briefings.</p>',
 '<p>Ao acessar este Terminal de Dados Móvel, você reconhece que leu, compreendeu e concorda em seguir todos os Procedimentos Operacionais Padrão estabelecidos pelo Departamento.</p><p>Espera-se que todos os Membros do Serviço mantenham o profissionalismo, cumpram a lei e ajam com integridade em todos os momentos durante o serviço.</p><p>O não cumprimento desses procedimentos pode resultar em ação disciplinar, incluindo, mas não se limitando a suspensão, rebaixamento ou rescisão.</p><p>Se você tiver alguma dúvida sobre esses procedimentos, entre em contato com seu supervisor ou cadeia de comando.</p>',
 0);

INSERT IGNORE INTO `mdt_sop_categories` (`id`, `job`, `title`, `icon`, `sort_order`) VALUES
(1, 'police', 'Código de Ética', 'gavel', 1),
(2, 'police', 'Juramento de Serviço', 'military_tech', 2),
(3, 'police', 'Padrões de Patrulha', 'local_police', 3),
(4, 'police', 'Conduta dos Membros', 'groups', 4),
(5, 'police', 'Disciplinas de Comando', 'report', 5),
(6, 'police', 'Incidentes', 'emergency', 6),
(7, 'police', 'Condução e chamadas de emergência', 'directions_car', 7),
(8, 'police', 'Políticas', 'policy', 8),
(9, 'police', 'Uso da Força', 'security', 9),
(10, 'police', 'Treinamento e Procedimentos', 'school', 10),
(11, 'police', 'Veículos', 'directions_car', 11);

INSERT IGNORE INTO `mdt_sop_sections` (`category_id`, `title`, `content`, `sort_order`) VALUES
-- Code of Ethics
(1, 'Código de Ética',
 '<p>O Código de Ética estabelece um conjunto de valores e princípios nos quais todo o trabalho do departamento deve ser realizado. A violação de qualquer Ética pode levar a reclamações e ações disciplinares que podem incluir demissão.</p><p>Ao se tornar um Oficial de Aplicação da Lei, você ganha muitas responsabilidades, incluindo o poder e a capacidade de fazer cumprir a lei. Dentro da lei, você tem muito poder para prender, acusar e revistar civis. Tudo isso deve estar dentro das leis do estado. Qualquer falha em seguir qualquer oficial de patente superior pode levar ao Comando Disciplinar. A habilidade dada aos LEOs não pode ser abusada ou usada de qualquer forma diversa, caso contrário, ações disciplinares poderão ser tomado.</p><ul><li>Profissionalismo</li><li>Responsabilidade</li><li>Respeito</li><li>Liderança</li></ul><p>Nunca agirei oficiosamente ou permitirei sentimentos pessoais, preconceitos, animosidades ou amizades para influenciar minhas decisões. Sem comprometer o crime e com acusação implacável de criminosos, aplicarei a lei de maneira cortês e apropriada, sem medo ou favor, malícia ou má vontade, nunca empregando força ou violência desnecessária e nunca aceitando gratificações.</p><p>Reconheço o distintivo do meu cargo como um símbolo de fé pública, e aceito-o como uma confiança pública a ser mantida, desde que eu seja fiel à ética do serviço policial. Me esforçarei constantemente para alcançar esses objetivos e ideais, dedicando-me diante de Deus à profissão que escolhi... aplicação da lei.</p>',
 1),

-- Oath of Service
(2, 'Juramento de Estado',
 '<p><em>"Juro solenemente: apoiarei, protegerei e defenderei a Constituição e o Governo dos Estados Unidos e do Estado; prestarei estrita obediência aos meus superiores na Agência de Aplicação da Lei e observarei todas as ordens e regulamentos prescritos por eles para o governo e a administração da Patrulha; sempre me conduzirei com sobriedade, honra e honestidade; manterei atenção rigorosa, pontual e constante aos meus deveres; absterei-me de qualquer conduta ofensiva ou incompatível com um agente da lei; desempenharei minhas funções sem medo, com imparcialidade e a devida cortesia; e cumprirei bem e fielmente os deveres do cargo que agora assumo. Que Deus me ajude."</em></p>',
 1),

-- Patrol Standards
(3, 'Equipamento e prontidão',
 '<ul><li><strong>Os agentes da lei devem ter todos os equipamentos adequados para desempenhar as funções policiais.</strong></li><li><strong>Os agentes da lei devem ter todos os equipamentos em condições de uso e prontos para uso.</strong></li><li><strong>Os agentes da lei devem garantir que o veículo tenha as devidas equipamento e pode ser reparado.</strong></li><li><strong>Os agentes da lei devem garantir que todas as armas estejam carregadas e em condições de uso.</strong></li><li><strong>Os agentes da lei devem comparecer a todos os TODOS CHAMADAS.</strong></li><li><strong>Os agentes da lei seguirão a cadeia de comando adequada.</strong></li><li><strong>Os agentes da lei devem garantir que agem de maneira segura.</strong></li></ul>',
 1),

-- Member Conduct
(4, 'Padrões de Conduta dos Oficiais',
 '<ul><li>Os Policiais devem manter uma postura profissional em todos os momentos.</li><li>Os Policiais nunca devem assediar, intimidar ou de outra forma infringir os direitos de qualquer civil.</li><li>Os Policiais nunca devem abusar de seu poder para beneficiar a si mesmos ou prejudicar outras pessoas de qualquer forma. (Financeiramente, fisicamente, verbalmente ou de qualquer forma que esteja abaixo do juramento de um Oficial de proteger e servir.)</li><li>Os Policiais devem ajudar qualquer civil necessitado com o melhor de sua capacidade.</li><li>Os Policiais devem obedecer a qualquer ordem legal emitida por um supervisor de posto acima do seu.</li><li>Lei Os Policiais são responsáveis por qualquer dano que causarem a uma pessoa fora do estado de direito e de acordo com o guia de patrulha de cada departamento.</li><li>Os Policiais devem e irão seguir todas as leis rodoviárias e não abusar das sirenes para ignorar essas leis.</li><li>Os Policiais devem ser capazes de justificar qualquer uso de força ou causa para uma prisão/parada de qualquer pessoa.</li><li>Os policiais não discriminarão qualquer pessoa por qualquer motivo, incluindo, mas não se limitando a: raça, religião, orientação sexual e gênero.</li></ul>',
 1),

-- Command Disciplines
(5, 'Disciplinas de Comando',
 '<p>Disciplinas de Comando são recomendadas para má conduta que é mais problemática do que treinamento inadequado, mas não chega ao nível de cobrança. As disciplinas de comando serão emitidas para todos os policiais que infringirem os regulamentos ou não obedecerem a uma ordem legal de um supervisor, também conhecida como insubordinação.</p><p>Os policiais podem acumular até <strong>(3)</strong> Disciplinas de comando antes de serem demitidos do departamento. Os encarregados da aplicação da lei também podem ser demitidos dependendo do nível da infração ou infrações cometidas; isso cabe ao estado-maior de comando e é aprovado pelo Comissário.</p><p><strong>Nota:</strong> Um Verbal e Escrito devido à repetição da mesma má conduta será igual a um FINAL.</p><p>(Verbal, Escrito, Final) são os CDs a que se referem.</p>',
 1),
(5, 'Suspensão e Rescisão',
 '<p>Os Policiais estão sujeitos à suspensão em qualquer CD escrito com base no critério do supervisor.</p><p>A rescisão é a resposta final aos problemas de comportamento de um Policial. Os dirigentes serão formalmente demitidos pelo departamento e isso será decidido pelo supervisor. Oficiais Probatórios, ainda em situação de acompanhamento, podem ser demitidos por um SGT/LT.</p>',
 2),
(5, 'Regras e Presença',
 '<p><strong>Regras:</strong> Todas as regras, políticas e procedimentos se aplicam aos LEOs em todos os momentos.</p><p><strong>Política de Presença:</strong> Os Policiais que estão ativos são muito apreciados, mas como todos sabemos, nossas vidas e família são mais importantes. Os policiais que estarão ocupados devem notificar a equipe de comando.</p><p><strong>Conduta proibida:</strong></p><ul><li>Qualquer consumo de narcóticos e/ou álcool durante o serviço = TERMINAÇÃO</li><li>Envolver-se em discussão com outros membros enquanto estiver embriagado IRL em uma patrulha canal.</li></ul>',
 3),

-- Incidents
(6, 'Direito a um Supervisor',
 '<p>Os membros do público têm o direito de falar com um supervisor. Quando um supervisor é solicitado por um civil, espera-se que ele responda à chamada quando estiver disponível.</p><p>Os detidos também têm o direito de falar com um supervisor, se o solicitarem. Se um supervisor for solicitado por um suspeito que está sendo preso, ele poderá ser levado ao Departamento de Polícia ou ao local ativo atual para aguardar por um. <strong>Mas, eles não devem receber nenhuma acusação criminal até que o supervisor tenha falado com eles.</strong></p><p><strong>O direito a um supervisor só pode ser recusado nas seguintes situações:</strong></p><ul><li>O Supervisor esteve anteriormente envolvido no caso do suspeito e confirmou que o suspeito será acusado.</li><li>Se o policial que fez a prisão já for um Supervisor. Por exemplo, o sargento não precisa solicitar que um tenente ou outro supervisor fale com seu suspeito se o suspeito solicitar.</li><li>Não há supervisores disponíveis.</li><li>Se não houver supervisores de plantão, qualquer FTA pode assumir o papel do supervisor e falar com o suspeito como assistente de treinamento de campo.</li></ul>',
 1),
(6, 'Recebendo e respondendo a chamadas',
 '<p><strong>Recebendo uma chamada de emergência:</strong> Sempre confirme a chamada, se for enviada por despacho, avise e esclareça que você está respondendo. Se notificado pelo sistema 911, informe a todos sobre o Canal de Tráfego de Rádio ao qual você estará respondendo.</p><p><strong>Chegando ao local:</strong> Quando você chegar ao local, alerte o despacho e seus colegas de que você chegou ao local. Geralmente, a menos que seja designado, o primeiro oficial no local será sempre o Oficial Responsável (OIC). O primeiro Supervisor na cena assumirá o comando da cena. É sua responsabilidade manter o despachante e/ou outros policiais informados sobre o desenrolar da situação e levar quaisquer suspeitos de volta à Delegacia.</p>',
 2),
(6, 'Prisão e Castigo',
 '<p><strong>Tratamento de Suspeitos:</strong> Se um supervisor for solicitado por um suspeito que está sendo preso, ele poderá ser levado ao Departamento de Polícia para esperar por um, mas não deverá receber nenhuma acusação criminal até que o supervisor tenha falado com ele. Consulte Direito a um Supervisor para saber quando o direito a um supervisor pode ser negado.</p><p><strong>Punições:</strong> Espera-se que os oficiais não somem leis e não maximizem as sentenças, a menos que o assunto seja Crime. Violações menores de leis (por exemplo, infrações de trânsito) devem <strong>NUNCA</strong> ser somadas para criar uma sentença de prisão maior. Geralmente, a extensão ou cooperação oferecida pelo suspeito deve ser considerada ao estabelecer uma sentença de prisão ou emitir uma multa.</p><ul><li><strong>O oficial que prendeu DEVE ler os Direitos de Miranda</strong> antes de prender ou transportar o sujeito para a Delegacia. *Em diferentes circunstâncias, os direitos de Miranda podem ser lidos na delegacia.</li><li>Os policiais que prendem devem explicar a(s) acusação(ões) do suspeito antes de prendê-los.</li><li>Os policiais devem tirar as algemas do suspeito antes de enviá-lo para a prisão.</li><li>Ao transportar um suspeito, o veículo deve incluir uma gaiola de transporte prisional nele.</li><li>O(s) suspeito(s) devem ser revistados antes de serem transportados.</li><li>Os agentes de detenção devem escrever um relatório de detenção no sistema MDT.</li><li><strong>Ao prender um suspeito, o agente de detenção deve sempre usar os códigos penais para as sentenças e para o Acusações.</strong></li></ul><p>Todas as sentenças estão sujeitas ao critério do oficial após levar em consideração outros crimes pendentes, status de liberdade condicional, reincidência ou outras informações obtidas durante a investigação. Os policiais são incentivados a dar clemência a criminosos cooperativos e não violentos. Todas as acusações são acumuláveis ​​e sujeitas a alterações sem aviso prévio.</p><p><strong>Classificação de Crimes:</strong></p><ul><li><strong>Infração</strong> - Violação menos grave do código penal. Resulta em multa e/ou perda de privilégio.</li><li><strong>Contravenção</strong> - Violação menor do código penal. Resulta em prisão, multa e/ou pena de prisão.</li><li><strong>Crime grave</strong> - Violação grave do código penal. Resulta em prisão, multa e pena de prisão.</li></ul>',
 3),

-- Driving and Emergency Calls
(7, 'Definições de condução de emergência',
 '<p><strong>Condução de emergência (sem perseguição):</strong> Operação de um veículo de emergência, com luzes vermelhas e azuis e sirene acionadas, por um agente da lei em resposta a uma situação de risco à vida ou a um crime violento em andamento, observando a segurança de terceiros.</p><p><strong>Condução em perseguição:</strong> Tentativa de um agente da lei, operando um veículo de emergência com luzes e sirene acionadas, de abordar os ocupantes de outro veículo em movimento quando o condutor em fuga está ciente da tentativa e resiste à abordagem mantendo ou aumentando a velocidade, desobedecendo às leis de trânsito ou tentando escapar.</p><p>Os agentes devem manter distância segura do veículo suspeito durante a perseguição para permitir frenagens de emergência. A manobra PIT só pode ser realizada por supervisores ou agentes certificados, sem trânsito próximo e fora de áreas residenciais.</p><p><strong>Acompanhamento:</strong> Condução próxima a um veículo de interesse sem empregar meios de abordagem, como luzes, sirene ou outra ordem de parada.</p>',
 1),
(7, 'Códigos de resposta',
 '<p><strong>Códigos de resposta de chamada de emergência:</strong></p><p><strong>Código 1 - Não urgente / sem luzes, sem sirenes:</strong> Chamadas de supervisor, danos à propriedade, invasão, roubo de propriedade (não em andamento), Travessia irregular.</p><p><strong>Código 2 - Alta prioridade / Luzes acesas, sem sirenes:</strong> Chamadas de parada de trânsito, briga em andamento, acidentes de carro, tiros disparados na área, roubo de propriedade em andamento.</p><p><strong>Código 3 - Emergência / Luzes e sirenes ligadas:</strong> Perseguição de veículo, policial caído ou em perigo, assalto à mão armada, pessoa procurada, atualização de crime, Atirador ativo.</p>',
 2),

-- Policies
(8, 'Identificação de Diretores',
 '<p>Espera-se sempre que os policiais se identifiquem como policiais durante uma situação e especialmente ao entrar em um prédio ou durante paradas de trânsito. Caso contrário, os oficiais poderiam ser confundidos com pessoas hostis. Os policiais também devem informar seu nome e números de crachá a outras pessoas, se solicitado, se a pessoa que os solicita desejar fazer uma reclamação.</p><p><em>*Oficiais disfarçados não são obrigados a se identificar para civis se estiverem conduzindo uma investigação.</em></p>',
 1),
(8, 'Desempenho de Funções',
 '<p><strong>Desempenho negligente de funções:</strong> Um oficial que desempenha funções, mesmo dentro dos limites da lei, pode ser considerado negligente no desempenho de suas funções se obviamente não agir da melhor maneira possível ou se seu comportamento colocar injustificadamente em perigo a vida de cidadãos, de outros oficiais ou de si mesmo e os riscos superarem óbvia e fortemente os benefícios.</p><p><strong>Respostas do supervisor às chamadas:</strong> Espera-se que os supervisores respondam à chamada mais importante no momento e não podem ficar ociosos ou ignorar o policiamento regular e as tarefas de supervisão em preferência a tarefas mais servis. <strong>Os supervisores devem responder e julgar todos os incidentes de tiroteio envolvendo policiais.</strong></p><ul><li>Os supervisores devem fazer relatórios de incidentes (no MDT) de cenas envolvidas em tiroteios, acidentes com oficiais, perseguições com veículos.</li></ul>',
 2),
(8, 'Estrutura do Mandado',
 '<p>Para que um mandado seja motivo suficiente para prender alguém e seja classificado como "válido", você precisa fornecer uma visão geral da situação, incluindo evidências e armas utilizadas (se houver). Mandados que digam apenas “Tentativa de atropelar o motorista do uber” não serão classificados como “válidos” nem serão suficientes para prender alguém, pois não fornecem uma visão geral da situação nem nos dizem que tipo de evidência estava presente no momento. Também é importante especificar se se trata de um mandado de busca ou de prisão.</p><p>Um bom exemplo de mandado de prisão é: <em>"Mandado de prisão: Atirou e matou um civil durante o assalto à mão armada em Sandy 24 horas por dia, 7 dias por semana, com uma Beretta M9. Várias testemunhas, incluindo policiais, testemunharam a situação. Evidências encontradas no local."</em></p><p>A um bom exemplo de mandado de busca e apreensão é: <em> "Mandado de busca: As plantas de drogas parecem visíveis da janela do apartamento, indicando que a produção de drogas está em andamento. O proprietário do apartamento recusou-se a abrir a porta para os policiais."</em></p>',
 3),
(8, 'Botão de pânico e comando de cena',
 '<p><strong>Botão de Pânico:</strong> O Botão de Pânico só deve ser pressionado quando houver uma preocupação urgente com a segurança pessoal sua ou de um colega, que requer assistência imediata.</p><ul><li><strong>Todas as Unidades devem responder a 10-99 Cenas. Os supervisores podem cancelar se não forem necessárias mais unidades no local.</strong></li></ul><p><strong>Comando de cena:</strong> O primeiro sargento ou superior no local será considerado como Comando de cena. Somente o comando de cena pode eliminar unidades da cena ativa, independentemente da classificação. O Comando de Cena Ativo aconselhará os policiais sobre o que fazer. <strong>Os assistentes de treinamento de campo podem assumir o comando de cena se não houver nenhum supervisor ativo em serviço.</strong></p>',
 4),
(8, 'Paradas de trânsito',
 '<p>No momento de qualquer parada de trânsito, ela é e será conhecida como cena e será tratada como tal. Embora um policial tenha qualquer pessoa sob investigação por excesso de velocidade, equipamentos inoperantes e veículos considerados impróprios para as estradas, todos os suspeitos serão atualmente DETIDOS (<strong>eles não precisam estar algemados, eles podem estar em seu veículo</strong>) durante a parada de trânsito. Eles não podem sair do local, mas podem chamar um advogado com antecedência se sentirem necessidade de fazê-lo. Em nenhum momento durante uma parada de trânsito deve ser utilizado o uso de força letal, a menos que um policial tema por sua vida. Menos que letal é sempre permitido se a situação surgir.</p><p>Durante uma parada de trânsito, se comandos de policiais forem dados ao suspeito ou acusado e após múltiplas tentativas o suspeito se recusar a obedecer, então várias etapas de força menos que letal são permitidas. O uso desta força é determinado pelo chefe do departamento. O uso de força letal não é permitido e resultará na remoção do policial ou em ação disciplinar.</p>',
 5),
(8, 'Limites de velocidade e roubos',
 '<p><strong>Limites de velocidade:</strong></p><ul><li>Limites da cidade - 40 MPH</li><li>Rodovias / fora da cidade - 80 MPH</li></ul><p><strong>Máximo de oficiais permitidos por Roubo:</strong></p><ul><li>Assalto ao cassino: 4</li><li>Assalto no Pacífico: 5</li><li>Assalto a joias: 3</li><li>Fleeca Roubo: 4</li><li>Assalto a casa: 2</li><li>Assalto a loja: 3</li><li>Assalto a trem: 4</li><li>Assalto a caminhão: 3</li><li>Ativo 10-80s: 3 (carros)</li></ul>',
 6),
(8, 'Ar Um',
 '<p>Para um oficial ser certificado Air One, ele deve ser treinado e liberado por um FTI (Field Training Instructor). Somente um FTI do Departamento certificado pela Air One pode autorizar outros a serem certificados. Para obter a certificação Air One, seu instrutor de treinamento o guiará pelo curso de treinamento Air One, onde você deverá mostrar ao instrutor sua habilidade de voar e usar o Air One. Você só será aprovado se mostrar ao seu instrutor que está pronto. Você também aprenderá a maneira correta de usar o Air One.</p><p><strong>Regras:</strong></p><ul><li>O Air One só pode ficar desligado por 30 minutos antes de ter que voltar ao MRPD para reabastecer.</li><li>Deve haver um tempo de reabastecimento de 3 a 5 minutos antes que o Air One possa voltar ao ar ou reconecte-se a uma situação ativa.</li><li>Só pode lançar pessoas se a área for segura (o que significa que ninguém está atirando no Air One).</li></ul>',
 7),

-- Use of Force
(9, 'Política de Uso da Força',
 '<p>Os agentes da lei podem usar qualquer quantidade de força no desempenho de suas funções, desde que seja razoável e justificável.</p><ul><li><strong>Uma arma de fogo só pode ser usada quando houver um perigo claro e presente à vida e outros métodos não letais forem inadequados ou falharem.</strong></li><li><strong>As armas de fogo nunca devem ser usado para apreender um suspeito em fuga, a menos que justificado no ponto acima.</strong></li><li><strong>Tiro(s) de advertência nunca devem ser disparados.</strong></li><li><strong>Só deve disparar sua arma de fogo se você tiver uma linha de visão desobstruída e for seguro fazê-lo.</strong> (NÃO FAÇA FOGO CRUZADO AOS OFICIAIS)</li><li><strong>Oficiais que usam força excessiva no desempenho de suas funções sem uma razão razoável e justificável podem levar a ação disciplinar.</strong></li></ul>',
 1),
(9, 'Diretrizes de Força Mortal',
 '<p><strong>(a) Uso de força letal:</strong> Força letal significa força usada contra outro indivíduo, que pode causar lesões corporais graves ou morte ao indivíduo em questão. O uso de força letal pode ser usado se uma ou mais das seguintes circunstâncias existirem:</p><p><strong>1 - Autodefesa:</strong> Quando a força letal parece razoavelmente necessária para proteger um policial que razoavelmente acredita que está em perigo iminente de morte ou lesão corporal grave.</p><p><strong>2 - Ofensas Graves:</strong> Quando força letal parece ser razoável e objectivamente necessária para proteger o público em geral de uma infracção grave. Exemplos: O sujeito em questão está dirigindo de forma imprudente a ponto de representar uma ameaça iminente ao público em geral ou aos oficiais. Ou o sujeito está atualmente armado com uma arma de fogo e os policiais acreditam que, sem qualquer dúvida, o sujeito a usará.</p><p><strong>3 - Pneus:</strong> Os policiais devem mirar nos pneus de um veículo quando for necessário atirar em um veículo que dirige de forma imprudente onde os ocupantes são conhecidos por estarem armados ou são um perigo para o público. Depois que os pneus forem estourados, os policiais devem parar de atirar no veículo.</p><p><strong>4 - Um aviso:</strong> "POLÍCIA PARE" ou "POLÍCIA, PARE OU VOCÊ SERÁ BALEADO" geralmente deve ser dado, se possível, antes que o policial dispare sua arma de fogo.</p><p><strong>5 - Veículos:</strong> Os veículos geralmente não devem ser usados como arma, a menos que este seja o último recurso do policial.</p>',
 2),

-- Training and Procedures
(10, 'Fases de Treinamento',
 '<p>Quando você se torna um Oficial de Aplicação da Lei dentro do departamento, você deve passar por 3 etapas de Treinamento de Campo. Cada estagiário será designado com um Oficial de Treinamento de Campo ou Assistente de Treinamento de Campo. Os estagiários que passarem nas 3 etapas do Treinamento de Campo terão a capacidade de Patrulhar Sozinhos. Até então, eles só podem patrulhar com oficiais de patrulha ou com o FTO designado.</p>',
 1),
(10, 'Direitos Miranda',
 '<p><em> "Você tem o direito de permanecer em silêncio, qualquer coisa que você diga ou faça pode ser usada contra você em um tribunal, você tem direito a um advogado. Se não puder pagar um, um será nomeado para você pelo estado. Você entende os direitos que foram lidos para você? Com ​​esses direitos em mente, deseja falar comigo?"</em></p>',
 2),
(10, 'Advogado Ping',
 '<p>Quando você prende alguém, essa pessoa tem direito à presença de um advogado. Faça ping para um advogado no Discord na categoria DOJ> #lawyer-ping. Aguarde uma resposta ou a chegada de um advogado. Se ninguém chegar após 10 minutos, prossiga com a prisão.</p>',
 3),

-- Vehicles
(11, 'Veículos de polícia',
 'Os carros <p>PD (aqueles que você encontra na garagem) serão distribuídos como carros pessoais. Você pode estacioná-los em suas garagens e fazer atualizações em seus cruzadores pessoais.</p><ul><li>Você não pode alterar as cores ou pinturas.</li><li>Você pode instalar atualizações para tornar seu carro mais rápido com qualquer um dos mecânicos da cidade.</li></ul>',
 1),
(11, 'Unidade K9',
 '<p><em>Trabalho em andamento</em></p>',
 2);

-- DOJ Court Cases
CREATE TABLE IF NOT EXISTS `mdt_court_cases` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `case_number` varchar(30) NOT NULL DEFAULT '',
  `title` varchar(255) NOT NULL,
  `summary` text DEFAULT NULL,
  `status` enum('pending','scheduled','in_trial','closed','dismissed','appealed') NOT NULL DEFAULT 'pending',
  `case_type` enum('criminal','civil','appeal','motion') NOT NULL DEFAULT 'criminal',
  `presiding_judge` varchar(50) DEFAULT NULL,
  `presiding_judge_name` varchar(100) DEFAULT NULL,
  `prosecutor` varchar(50) DEFAULT NULL,
  `prosecutor_name` varchar(100) DEFAULT NULL,
  `defense_attorney` varchar(50) DEFAULT NULL,
  `defense_attorney_name` varchar(100) DEFAULT NULL,
  `defendant_citizenid` varchar(50) DEFAULT NULL,
  `defendant_name` varchar(100) DEFAULT NULL,
  `hearing_date` datetime DEFAULT NULL,
  `filed_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `closed_date` datetime DEFAULT NULL,
  `linked_mdt_case_id` int(10) unsigned DEFAULT NULL,
  `referred_from_report_id` int(10) unsigned DEFAULT NULL,
  `notes` text DEFAULT NULL,
  `created_by` varchar(50) NOT NULL,
  `created_by_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_status` (`status`),
  KEY `idx_defendant` (`defendant_citizenid`),
  KEY `idx_hearing_date` (`hearing_date`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- DOJ Court Orders
CREATE TABLE IF NOT EXISTS `mdt_court_orders` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `order_number` varchar(30) NOT NULL DEFAULT '',
  `court_case_id` int(10) unsigned DEFAULT NULL,
  `type` enum('restraining_order','subpoena','bail_conditions','search_warrant','arrest_warrant','other') NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `target_citizenid` varchar(50) DEFAULT NULL,
  `target_name` varchar(100) DEFAULT NULL,
  `status` enum('active','expired','revoked') NOT NULL DEFAULT 'active',
  `issued_by` varchar(50) NOT NULL,
  `issued_by_name` varchar(100) DEFAULT NULL,
  `effective_date` datetime DEFAULT CURRENT_TIMESTAMP,
  `expiry_date` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_court_case` (`court_case_id`),
  KEY `idx_target` (`target_citizenid`),
  KEY `idx_status` (`status`),
  KEY `idx_type` (`type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- DOJ Legal Documents
CREATE TABLE IF NOT EXISTS `mdt_legal_documents` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `court_case_id` int(10) unsigned DEFAULT NULL,
  `type` enum('brief','motion','ruling','opinion','plea_deal','sentencing','other') NOT NULL,
  `title` varchar(255) NOT NULL,
  `content` longtext DEFAULT NULL,
  `status` enum('draft','filed','approved','rejected') NOT NULL DEFAULT 'draft',
  `author_citizenid` varchar(50) NOT NULL,
  `author_name` varchar(100) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_court_case` (`court_case_id`),
  KEY `idx_author` (`author_citizenid`),
  KEY `idx_type` (`type`),
  KEY `idx_status` (`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- DOJ Warrant Requests (separate from mdt_reports_warrants)
CREATE TABLE IF NOT EXISTS `mdt_warrant_requests` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `citizenid` varchar(50) NOT NULL,
  `citizen_name` varchar(100) NOT NULL DEFAULT '',
  `requesting_officer` varchar(50) NOT NULL,
  `officer_name` varchar(100) NOT NULL DEFAULT '',
  `charges` text DEFAULT NULL,
  `reason` text NOT NULL,
  `linked_report_id` int(10) unsigned DEFAULT NULL,
  `status` enum('pending','approved','denied','closed') NOT NULL DEFAULT 'pending',
  `reviewer_citizenid` varchar(50) DEFAULT NULL,
  `reviewer_name` varchar(100) DEFAULT NULL,
  `review_reason` text DEFAULT NULL,
  `reviewed_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_citizenid` (`citizenid`),
  KEY `idx_status` (`status`),
  KEY `idx_requesting_officer` (`requesting_officer`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- DOJ Warrant Reviews (audit log)
CREATE TABLE IF NOT EXISTS `mdt_warrant_reviews` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `warrant_request_id` int(10) unsigned NOT NULL,
  `reviewer_citizenid` varchar(50) NOT NULL,
  `reviewer_name` varchar(100) DEFAULT NULL,
  `decision` enum('approved','denied') NOT NULL,
  `reason` text DEFAULT NULL,
  `reviewed_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`),
  KEY `idx_warrant_request` (`warrant_request_id`),
  KEY `idx_reviewer` (`reviewer_citizenid`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Add lawyer_requested column to mdt_reports
ALTER TABLE `mdt_reports` ADD COLUMN IF NOT EXISTS `lawyer_requested` tinyint(1) NOT NULL DEFAULT 0;
-- Update mdt_reports_evidence with new columns
ALTER TABLE mdt_reports_evidence
  ADD COLUMN IF NOT EXISTS title VARCHAR(255) NOT NULL DEFAULT '' AFTER reportid,
  ADD COLUMN IF NOT EXISTS images LONGTEXT NULL DEFAULT NULL AFTER stored;

-- Add flags column to mdt_weapons
ALTER TABLE `mdt_weapons` ADD COLUMN IF NOT EXISTS `flags` JSON DEFAULT NULL;


-- ════════════════════════════════════════════════════════════════════════════
--  Patrols  (server/backend/tracking.lua)
--  Persisted patrols: membership, ordering, and optional map-zone geometry.
--  `member_ids` and `zone_points` hold JSON; `member_ids` is reset to '[]' on
--  resource start so officers re-assign after a restart. `job_type` is the MDT
--  domain the patrol belongs to ('police' or 'ems').
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `mdt_patrols` (
  `id` varchar(64) NOT NULL,
  `name` varchar(64) NOT NULL,
  `color` varchar(7) NOT NULL DEFAULT '#3B82F6',
  `member_ids` longtext DEFAULT NULL,
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `zone_points` longtext DEFAULT NULL,
  `job_type` varchar(10) NOT NULL DEFAULT 'police',
  PRIMARY KEY (`id`),
  KEY `idx_mdt_patrols_job_sort` (`job_type`,`sort_order`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ════════════════════════════════════════════════════════════════════════════
--  Officer Status  (server/backend/officer_status.lua)
--  One row per officer who has ever set a status. `status` is a free-form key
--  validated server-side against Config.OfficerStatus (see config.lua), so new
--  statuses can be added there without a migration. `note` is the optional
--  custom description (e.g. "Traffic Stop"); NULL falls back to the status
--  label client-side. `updated_at` powers the "since" timestamp in the UI.
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `mdt_officer_status` (
  `citizenid` varchar(64) NOT NULL,
  `status` varchar(32) NOT NULL DEFAULT 'active',
  `note` varchar(120) DEFAULT NULL,
  `job_type` varchar(10) NOT NULL DEFAULT 'police',
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`citizenid`),
  KEY `idx_mdt_officer_status_job` (`job_type`,`status`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ════════════════════════════════════════════════════════════════════════════
--  Court / Training calendar  (server/backend/court.lua)
--  Hearings cover court dates, trainings and meetings; `job_type` keeps the
--  police/DOJ calendar separate from the EMS calendar. Attendees are the people
--  invited to a hearing, with reminder bookkeeping (`notified_at`/`delivered_at`).
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `mdt_court_hearings` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `category` enum('court','training','meeting','other') NOT NULL DEFAULT 'court',
  `hearing_type` enum('arraignment','trial','sentencing','appeal','motion','hearing','other') NOT NULL DEFAULT 'trial',
  `case_id` int(10) unsigned DEFAULT NULL,
  `warrant_reportid` int(10) unsigned DEFAULT NULL,
  `defendant_cid` varchar(50) DEFAULT NULL,
  `defendant_name` varchar(100) DEFAULT NULL,
  `scheduled_at` datetime NOT NULL,
  `duration_minutes` int(11) NOT NULL DEFAULT 30,
  `location` varchar(255) DEFAULT NULL,
  `judge_cid` varchar(50) DEFAULT NULL,
  `judge_name` varchar(100) DEFAULT NULL,
  `status` enum('scheduled','in_session','completed','adjourned','cancelled') NOT NULL DEFAULT 'scheduled',
  `notes` text DEFAULT NULL,
  `created_by` varchar(50) NOT NULL,
  `created_by_name` varchar(100) DEFAULT NULL,
  `job_type` varchar(10) NOT NULL DEFAULT 'police',
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mdt_court_hearings_schedule` (`job_type`,`scheduled_at`),
  KEY `idx_mdt_court_hearings_status` (`status`),
  KEY `idx_mdt_court_hearings_case` (`case_id`),
  CONSTRAINT `FK_mdt_court_hearings_cases` FOREIGN KEY (`case_id`) REFERENCES `mdt_cases` (`id`) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_court_attendees` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `hearing_id` int(10) unsigned NOT NULL,
  `citizenid` varchar(50) NOT NULL,
  `display_name` varchar(100) DEFAULT NULL,
  `role` enum('prosecutor','defense','officer','witness','judge','trainee','instructor','attendee') NOT NULL DEFAULT 'officer',
  `notified_at` datetime DEFAULT NULL,
  `delivered_at` datetime DEFAULT NULL,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mdt_court_attendees_hearing_cid` (`hearing_id`,`citizenid`),
  KEY `idx_mdt_court_attendees_citizen` (`citizenid`),
  CONSTRAINT `FK_mdt_court_attendees_hearing` FOREIGN KEY (`hearing_id`) REFERENCES `mdt_court_hearings` (`id`) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- ════════════════════════════════════════════════════════════════════════════
--  Bulletin board  (server/backend/bulletinboard.lua)
--  Posts are scoped per department (`job`); categories are per-department too
--  and are soft-referenced by `mdt_bulletin_posts.category` = value (no FK, so a
--  category can be renamed/removed with the reassignment logic in the resource).
--  Default categories are seeded automatically on first use per job.
-- ════════════════════════════════════════════════════════════════════════════
CREATE TABLE IF NOT EXISTS `mdt_bulletin_categories` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `job` varchar(50) NOT NULL,
  `value` varchar(48) NOT NULL,
  `label` varchar(48) NOT NULL,
  `icon` varchar(48) NOT NULL DEFAULT 'label',
  `color` varchar(7) NOT NULL DEFAULT '#6B7280',
  `sort_order` int(11) NOT NULL DEFAULT 0,
  `is_default` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`id`),
  UNIQUE KEY `uq_mdt_bulletin_categories_job_value` (`job`,`value`),
  KEY `idx_mdt_bulletin_categories_job` (`job`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

CREATE TABLE IF NOT EXISTS `mdt_bulletin_posts` (
  `id` int(10) unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `content` text NOT NULL,
  `author` varchar(100) DEFAULT NULL,
  `author_rank` varchar(50) DEFAULT NULL,
  `category` varchar(48) NOT NULL DEFAULT 'general',
  `priority` enum('urgent','high','normal','low') NOT NULL DEFAULT 'normal',
  `pinned` tinyint(1) NOT NULL DEFAULT 0,
  `job` varchar(50) NOT NULL,
  `created_by` varchar(50) DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  PRIMARY KEY (`id`),
  KEY `idx_mdt_bulletin_posts_job` (`job`,`pinned`),
  KEY `idx_mdt_bulletin_posts_job_category` (`job`,`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
