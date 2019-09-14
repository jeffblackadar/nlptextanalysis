CREATE DATABASE `corpus_entities_nlptextanalysis` /*!40100 DEFAULT CHARACTER SET utf8 */;
use `corpus_entities_nlptextanalysis`;

CREATE TABLE `entities_locations` (
  `id_entities_location` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(99) DEFAULT NULL,
  `name_spell_checked` varchar(99) DEFAULT NULL,
  PRIMARY KEY (`id_entities_location`),
  UNIQUE KEY `identities_locations_UNIQUE` (`id_entities_location`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `names` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=112903 DEFAULT CHARSET=utf8;

CREATE TABLE `entities_organizations` (
  `id_entities_organization` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(99) DEFAULT NULL,
  `name_spell_checked` varchar(99) DEFAULT NULL,
  PRIMARY KEY (`id_entities_organization`),
  UNIQUE KEY `id_entities_organizations_UNIQUE` (`id_entities_organization`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `names` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=490572 DEFAULT CHARSET=utf8;

CREATE TABLE `entities_people` (
  `id_entities_person` int(11) NOT NULL AUTO_INCREMENT,
  `name` varchar(99) DEFAULT NULL,
  `name_spell_checked` varchar(99) DEFAULT NULL,
  PRIMARY KEY (`id_entities_person`),
  UNIQUE KEY `identities_UNIQUE` (`id_entities_person`),
  UNIQUE KEY `name_UNIQUE` (`name`),
  KEY `names` (`name`)
) ENGINE=InnoDB AUTO_INCREMENT=614500 DEFAULT CHARSET=utf8;

CREATE TABLE `locations_x_sourcedocuments` (
  `id_locations_x_sourcedocuments` int(11) NOT NULL AUTO_INCREMENT,
  `id_entities_location` int(11) DEFAULT '0',
  `id_source_document` int(11) DEFAULT '0',
  PRIMARY KEY (`id_locations_x_sourcedocuments`),
  UNIQUE KEY `id_locations_x_sourcedocuments_UNIQUE` (`id_locations_x_sourcedocuments`),
  KEY `ids` (`id_entities_location`,`id_source_document`)
) ENGINE=InnoDB AUTO_INCREMENT=680991 DEFAULT CHARSET=utf8 COMMENT='Cross reference table';

CREATE TABLE `organizations_x_sourcedocuments` (
  `id_organizations_x_sourcedocuments` int(11) NOT NULL AUTO_INCREMENT,
  `id_entities_organization` int(11) DEFAULT '0',
  `id_source_document` int(11) DEFAULT '0',
  PRIMARY KEY (`id_organizations_x_sourcedocuments`),
  UNIQUE KEY `id_organizations_x_sourcedocuments_UNIQUE` (`id_organizations_x_sourcedocuments`),
  KEY `ids` (`id_entities_organization`,`id_source_document`)
) ENGINE=InnoDB AUTO_INCREMENT=1334922 DEFAULT CHARSET=utf8 COMMENT='Cross reference table';

CREATE TABLE `people_x_sourcedocuments` (
  `id_people_x_sourcedocuments` int(11) NOT NULL AUTO_INCREMENT,
  `id_entities_person` int(11) DEFAULT '0',
  `id_source_document` int(11) DEFAULT '0',
  PRIMARY KEY (`id_people_x_sourcedocuments`),
  UNIQUE KEY `idpeople_x_sourcedocuments_UNIQUE` (`id_people_x_sourcedocuments`),
  KEY `ids` (`id_entities_person`,`id_source_document`)
) ENGINE=InnoDB AUTO_INCREMENT=1909522 DEFAULT CHARSET=utf8 COMMENT='Cross reference table';



CREATE TABLE `source_documents` (
  `id_source_document` int(11) NOT NULL AUTO_INCREMENT,
  `source_document_name` varchar(19) DEFAULT NULL,
  `source_document_base_url` varchar(99) DEFAULT NULL,
  `source_document_file_extension_1` varchar(4) DEFAULT NULL,
  `source_document_file_extension_2` varchar(4) DEFAULT NULL,
  `source_document_processed` int(11) DEFAULT '0',
  PRIMARY KEY (`id_source_document`),
  UNIQUE KEY `idsourcedocument_UNIQUE` (`id_source_document`),
  UNIQUE KEY `sourcedocumentname_UNIQUE` (`source_document_name`)
) ENGINE=InnoDB AUTO_INCREMENT=6635 DEFAULT CHARSET=utf8 COMMENT='The source document the text is extract from';
