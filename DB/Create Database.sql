USE [master]
GO

IF EXISTS (SELECT name FROM master.dbo.sysdatabases WHERE name = N'SLIDS')
    DROP DATABASE [SLIDS]
go


CREATE DATABASE [SLIDS] ON  PRIMARY 
( NAME = Primary01, FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\DATA\SLIDSPrim01.mdf' , SIZE = 5 , MAXSIZE = UNLIMITED, FILEGROWTH = 1 ),
  FILEGROUP [Data01] 
( NAME = N'Data0101', FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\DATA\SLIDSData0101.ndf' , SIZE = 20 , MAXSIZE = UNLIMITED , FILEGROWTH = 10 ),
( NAME = N'Data0102', FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\DATA\SLIDSData0102.ndf' , SIZE = 20 , MAXSIZE = UNLIMITED , FILEGROWTH = 10 ),
( NAME = N'Data0103', FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\DATA\SLIDSData0103.ndf' , SIZE = 20 , MAXSIZE = UNLIMITED , FILEGROWTH = 10 ),
( NAME = N'Data0104', FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\DATA\SLIDSData0104.ndf' , SIZE = 20 , MAXSIZE = UNLIMITED , FILEGROWTH = 10 )
LOG ON 
( NAME = Log, FILENAME = N'D:\SQL2012Prod\MSSQL11.SQL2012PROD\MSSQL\Log\SLIDSLog01.ldf' , SIZE = 10, MAXSIZE = UNLIMITED , FILEGROWTH = 10%)
GO

ALTER DATABASE [SLIDS] MODIFY FILEGROUP [Data01] DEFAULT
GO

IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC [SLIDS].[dbo].[sp_fulltext_database] @action = 'disable'
end
GO

ALTER DATABASE [SLIDS] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [SLIDS] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [SLIDS] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [SLIDS] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [SLIDS] SET ARITHABORT OFF 
GO
ALTER DATABASE [SLIDS] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [SLIDS] SET AUTO_CREATE_STATISTICS ON 
GO
ALTER DATABASE [SLIDS] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [SLIDS] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [SLIDS] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [SLIDS] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [SLIDS] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [SLIDS] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [SLIDS] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [SLIDS] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [SLIDS] SET  DISABLE_BROKER 
GO
ALTER DATABASE [SLIDS] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [SLIDS] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [SLIDS] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [SLIDS] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [SLIDS] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [SLIDS] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [SLIDS] SET  READ_WRITE 
GO
ALTER DATABASE [SLIDS] SET RECOVERY SIMPLE 
GO
ALTER DATABASE [SLIDS] SET  MULTI_USER 
GO
ALTER DATABASE [SLIDS] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [SLIDS] SET DB_CHAINING OFF 
GO

GO
SP_CONFIGURE 'nested_triggers',0 
GO 
RECONFIGURE 
GO 


USE [SLIDS]
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


 IF OBJECT_ID ('dbo.SLIDS', 'Table') > 0
    DROP Table [dbo].[SLIDS]

CREATE TABLE [dbo].[SLIDS]
(
    Developer varchar(128) NOT NULL,
    DBVersion varchar(16) NOT NULL,
    Applied [date] NOT NULL
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Main Information of SLIDS' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SLIDS'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Current Version of Database' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SLIDS', @level2type=N'COLUMN',@level2name=N'DBVersion'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date this Database Version was installed' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'SLIDS', @level2type=N'COLUMN',@level2name=N'Applied'
GO

INSERT INTO SLIDS(Developer, DBVersion, Applied)
VALUES('PENTAG Informtik AG', '1.0.0', GetDate());


-- Add Language of corresponance and accounting address to hospital
IF OBJECT_ID ('dbo.Language', 'Table') > 0
    DROP Table [dbo].[Language]

CREATE TABLE [dbo].[Language]
(
    ID int IDENTITY(1,1) NOT NULL,
    [LanguageName] varchar(64) NULL,
	[LanguageShort] varchar(64) NULL,
	isActive bit NOT NULL Default 1,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Language] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Languages' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Language name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'LanguageName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Language short name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'LanguageShort'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is language active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Language', @level2type=N'COLUMN',@level2name=N'isActive'
GO


IF OBJECT_ID ('dbo.Address', 'Table') > 0
    DROP Table [dbo].[Address]


CREATE TABLE [dbo].[Address](
    ID int IDENTITY(1,1) NOT NULL,
    ContactPerson nvarchar(64) NULL,
	Address1 nvarchar(64) NULL,
    Address2 nvarchar(64) NULL,
    Address3 nvarchar(64) NULL,
    Address4 nvarchar(64) NULL,
    Zip nvarchar(12) NULL,
    City nvarchar(64) NULL,
    CountryISO char(2) NULL,
    Phone varchar(32) NULL,
    Fax varchar(32) NULL,
    Email varchar(64) NULL,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Address] PRIMARY KEY CLUSTERED 
    (
        ID ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]	
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Addresses' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact Person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'ContactPerson'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First Address Line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Address1'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Second Address Line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Address2'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Third Address Line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Address3'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fourth Address Line' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Address4'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Zip Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Zip'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'City Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'City'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Iso Code Of Country' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'CountryISO'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Business Phone Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Phone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fax Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Fax'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Email Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'Email'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'AutoIncrementing RowVersion' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO

IF OBJECT_ID ('dbo.Hospital', 'Table') > 0
    DROP Table [dbo].[Hospital]


CREATE TABLE [dbo].[Hospital](
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(128) NOT NULL,
    Code varchar(16) NULL,
	Display varchar(128) NULL,
    AddressID int NOT NULL,
	AccountingAddressID int NULL,
	CorrespondanceLanguageID int NULL,
    IsReferral bit NOT NULL,
    IsProcurement bit NOT NULL,
    IsTransplantation bit NOT NULL,
    IsFo bit NOT NULL,
	isActive bit NOT NULL Default 1,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Hospital] PRIMARY KEY CLUSTERED 
    (
        ID ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]	
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD CONSTRAINT [FK_Hospital_Address] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Address] ([ID])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_Address]
GO

ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD CONSTRAINT [FK_Hospital_AccountingAddress] FOREIGN KEY([AccountingAddressID])
REFERENCES [dbo].[Address] ([ID])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_AccountingAddress]
GO

ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD CONSTRAINT [FK_Hospital_Language] FOREIGN KEY([CorrespondanceLanguageID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_Language]
GO

--defaults
ALTER TABLE [dbo].[Hospital] ADD CONSTRAINT [DF_Hospital_IsReferral]  DEFAULT (1) FOR [IsReferral]
GO
ALTER TABLE [dbo].[Hospital] ADD CONSTRAINT [DF_Hospital_IsProcurement]  DEFAULT (0) FOR [IsProcurement]
GO
ALTER TABLE [dbo].[Hospital] ADD CONSTRAINT [DF_Hospital_IsTransplantation]  DEFAULT (0) FOR [IsTransplantation]
GO
ALTER TABLE [dbo].[Hospital] ADD CONSTRAINT [DF_Hospital_IsFo]  DEFAULT (0) FOR [IsFo]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hospitals' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hospital Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Hospital Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value to display for Selection (Code for Swiss Name + City for Foreign))' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'Display'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key Referencing Hospitals Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'AddressID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a Detection/Referral Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'IsReferral'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a Procurement Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'IsProcurement'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a Transplantation Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'IsTransplantation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a Forreign Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Hospital', @level2type=N'COLUMN',@level2name=N'IsFo'
GO


IF OBJECT_ID ('dbo.Coordinator', 'Table') > 0
    DROP Table [dbo].[Coordinator]


CREATE TABLE [dbo].[Coordinator](
    ID int IDENTITY(1,1) NOT NULL,
    HospitalID int NULL,
    FirstName varchar(64) NULL,
    LastName varchar(64) NULL,
    Code varchar(16) NULL,
    AddressID int NULL,
    IsNC bit NOT NULL,
    IsTC bit NOT NULL,
	isActive bit NOT NULL Default 1,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Coordinator] PRIMARY KEY CLUSTERED 
    (
        ID ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[Coordinator]  WITH CHECK ADD CONSTRAINT [FK_Coordinator_Address] FOREIGN KEY([AddressID])
REFERENCES [dbo].[Address] ([ID])
GO
ALTER TABLE [dbo].[Coordinator] CHECK CONSTRAINT [FK_Coordinator_Address]
GO
ALTER TABLE [dbo].[Coordinator]  WITH CHECK ADD CONSTRAINT [FK_Coordinator_Hospital] FOREIGN KEY([HospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Coordinator] CHECK CONSTRAINT [FK_Coordinator_Hospital]
GO
--default
ALTER TABLE [dbo].[Coordinator] ADD CONSTRAINT [DF_Coordinator_IsNC]  DEFAULT (0) FOR [IsNC]
GO
ALTER TABLE [dbo].[Coordinator] ADD CONSTRAINT [DF_Coordinator_IsTC]  DEFAULT (0) FOR [IsTC]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Coordinators and Coordinators' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key Referencing Hospital the Coordinator works in' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'HospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'First Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'FirstName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Last Name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'LastName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Coordinator Code' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'Code'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key Referencing Coordinators Address' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'AddressID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a National Coordinator (will it appear in the list of National Coordinators)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'IsNC'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this a Transplantation Coordinator (will it appear in the list of Transplantation Coordinators)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Coordinator', @level2type=N'COLUMN',@level2name=N'IsTC'
GO

IF OBJECT_ID ('dbo.Organization', 'Table') > 0
    DROP Table [dbo].[Organization]


CREATE TABLE [dbo].[Organization]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_Organization] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'For FOs, Organizations the Organ comes from or goes to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Organization' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of this Organization in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'Position'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this Organization still active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organization', @level2type=N'COLUMN',@level2name=N'IsActive'
GO

IF OBJECT_ID ('dbo.ItemGroup', 'Table') > 0
    DROP Table [dbo].[ItemGroup]

CREATE TABLE [dbo].[ItemGroup]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NULL,
	[Type] smallint NOT NULL,
	isActive bit NOT NULL Default 1,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_ItemGroup] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ItemGroups' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemGroup', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Item group' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemGroup', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1 = Organ, 2 = TransportItem' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemGroup', @level2type=N'COLUMN',@level2name=N'Type'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Item group active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ItemGroup', @level2type=N'COLUMN',@level2name=N'isActive'
GO




IF OBJECT_ID ('dbo.Organ', 'Table') > 0
    DROP Table [dbo].[Organ]

CREATE TABLE [dbo].[Organ]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	ItemGroupID int NULL,
	CountableAs int NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_Organ] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign keys
ALTER TABLE [dbo].[Organ]  WITH CHECK ADD CONSTRAINT [FK_Organ_ItemGroup] FOREIGN KEY([ItemGroupID])
REFERENCES [dbo].[ItemGroup] ([ID])
GO
ALTER TABLE [dbo].[Organ] CHECK CONSTRAINT [FK_Organ_ItemGroup]

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Organs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of ItemGroup (grouping Heart, Liver, Lung etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'ItemGroupID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of which organ is countable for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'CountableAs'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position for sort order' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'Position'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is organ active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'isActive'
GO

IF OBJECT_ID ('dbo.Donor', 'Table') > 0
    DROP Table [dbo].[Donor]


CREATE TABLE [dbo].[Donor]
(
    ID int IDENTITY(1,1) NOT NULL,
    DonorNumber varchar(16) NULL,
	OrganizationID int NULL,
	DetectionHospitalID int NULL,
    ReferralHospitalID int NULL,
    ProcurementHospitalID int NULL,
    RegisterDate DateTime NULL,
    ProcurementDate DateTime NULL,
    NCID int NULL,
    TCID int NULL,
	Comment varchar(256) NULL,
    IsArchived bit NOT NULL Default 0,
    IsDeleted bit NOT NULL Default 0,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Donor] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_Organization] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_Organization]
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_DetectionHospital] FOREIGN KEY([DetectionHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_DetectionHospital]
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_ReferralHospital] FOREIGN KEY([ReferralHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_ReferralHospital]
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_ProcurementHospital] FOREIGN KEY([ProcurementHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_ProcurementHospital]
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_NC] FOREIGN KEY([NCID])
REFERENCES [dbo].[Coordinator] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_NC]
GO
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_TC] FOREIGN KEY([TCID])
REFERENCES [dbo].[Coordinator] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_TC]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Donors' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ST/FO number identifying the Donor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'DonorNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing Organization (like Swisstransplant) the ORgan comes from in case of FO' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'OrganizationID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Detection Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'DetectionHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Referral Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ReferralHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Procurement Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ProcurementHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of Registration of Donor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'RegisterDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of Procurement' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ProcurementDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing responsible national coordinator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'NCID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing responsible local coordinator' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'TCID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this Record archived' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'IsArchived'
GO

/*
IF OBJECT_ID ('dbo.TransportType', 'Table') > 0
    DROP Table [dbo].[TransportType]


CREATE TABLE [dbo].[TransportType]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
    CostDistributionID int null,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_TransportType] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[TransportType]  WITH CHECK ADD CONSTRAINT [FK_TransportType_CostDistribution] FOREIGN KEY([CostDistributionID])
REFERENCES [dbo].[CostDistribution] ([ID])
GO
ALTER TABLE [dbo].[TransportType] CHECK CONSTRAINT [FK_TransportType_CostDistribution]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TransportTypes (Organ, Blood, Donor, Crew...)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of TransportType' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing CostDistribution of this type of Transport if applicable' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportType', @level2type=N'COLUMN',@level2name=N'CostDistributionID'
GO
*/

IF OBJECT_ID ('dbo.Creditor', 'Table') > 0
    DROP Table [dbo].[Creditor]


CREATE TABLE [dbo].[Creditor]
(
    ID int IDENTITY(1,1) NOT NULL,
    CreditorName varchar(64) NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_Creditor] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Creditors' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Creditor'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Creditor', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Creditor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Creditor', @level2type=N'COLUMN',@level2name=N'CreditorName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is Creditor active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Creditor', @level2type=N'COLUMN',@level2name=N'isActive'
GO

IF OBJECT_ID ('dbo.Vehicle', 'Table') > 0
    DROP Table [dbo].[Vehicle]


CREATE TABLE [dbo].[Vehicle]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_Vehicle] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Vehicles (Organ, Blood, Donor, Crew...)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Vehicle'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Vehicle', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Vehicle' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Vehicle', @level2type=N'COLUMN',@level2name=N'Name'
GO

IF OBJECT_ID ('dbo.OperationCenter', 'Table') > 0
    DROP Table [dbo].[OperationCenter]


CREATE TABLE [dbo].[OperationCenter]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_OperationCenter] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'OperationCenters where the transports are organised' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OperationCenter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OperationCenter', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of OperationCenter' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OperationCenter', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of this OperationCenter in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OperationCenter', @level2type=N'COLUMN',@level2name=N'Position'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this OperationCenter still active?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OperationCenter', @level2type=N'COLUMN',@level2name=N'IsActive'
GO


IF OBJECT_ID ('dbo.Transport', 'Table') > 0
    DROP Table [dbo].[Transport]


CREATE TABLE [dbo].[Transport]
(
    ID int IDENTITY(1,1) NOT NULL,
    DonorID int NOT NULL,
 --   TransportTypeID int NULL,
	Forewarning int NULL,
    VehicleID int NULL,
	PoliceEscorted bit NOT NULL Default 0,
    DepartureHospitalID int NULL,
	OtherDeparture varchar(64) NULL,
    DestinationHospitalID int NULL,
	OtherDestination varchar(64) NULL,
    Departure DateTime NULL,
    Arrival DateTime NULL,
    FlightNumber varchar(32) NULL,
	Immatriculation varchar(32) NULL,
	WaitingTime int NULL,
	Distance int NULL,
	OperationCenterID int NULL,
	Provider varchar(32) NULL,
	Comment varchar(256) NULL,
    IsDeleted bit NOT NULL Default 0,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Transport] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_Donor] FOREIGN KEY([DonorID])
REFERENCES [dbo].[Donor] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_Donor]
GO
/*ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_TransportType] FOREIGN KEY([TransportTypeID])
REFERENCES [dbo].[TransportType] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_TransportType]
GO*/
ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_Vehicle] FOREIGN KEY([VehicleID])
REFERENCES [dbo].[Vehicle] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_Vehicle]
GO
ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_Departure] FOREIGN KEY([DepartureHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_Departure]
GO
ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_Destination] FOREIGN KEY([DestinationHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_Destination]
GO
ALTER TABLE [dbo].[Transport]  WITH CHECK ADD CONSTRAINT [FK_Transport_OperationCenter] FOREIGN KEY([OperationCenterID])
REFERENCES [dbo].[OperationCenter] ([ID])
GO
ALTER TABLE [dbo].[Transport] CHECK CONSTRAINT [FK_Transport_OperationCenter]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Transports' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Donor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'DonorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Zeit von der Auftragserteilung bis zur Startzeit' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Forewarning'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing used Vehicle' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'VehicleID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Did police escort the Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'PoliceEscorted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Departure Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'DepartureHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Departure if not a Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'OtherDeparture'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Destination Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'DestinationHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Destination if not a Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'OtherDestination'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Departure Time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Departure'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Arrival Time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Arrival'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Flight Number if Vehicle = Jet' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'FlightNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Immatriculation Number if Vehicle = Jet' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Immatriculation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Waiting time in Minutes untill next Transport if Destination is a stopOver (also for a two way transport)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'WaitingTime'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distance of Transport in KM' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Distance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Center Organizing the Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'OperationCenterID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Provider running the transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Provider'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Yes, space for a comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of Modification (Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Transport', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO


IF OBJECT_ID ('dbo.TransplantStatus', 'Table') > 0
    DROP Table [dbo].[TransplantStatus]


CREATE TABLE [dbo].[TransplantStatus]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_TransplantStatus] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TransplantStatuses (TX, NTX...)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantStatus'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantStatus', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Status' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantStatus', @level2type=N'COLUMN',@level2name=N'Name'
GO


IF OBJECT_ID ('dbo.TransplantOrgan', 'Table') > 0
    DROP Table [dbo].[TransplantOrgan]


CREATE TABLE [dbo].[TransplantOrgan]
(
    ID int IDENTITY(1,1) NOT NULL,
    DonorID int NOT NULL,
    OrganID int NOT NULL,
	OrganizationID int NULL,
    TransplantCenterID int NULL,
    TCID int NULL,
    GraftBoxNo int NULL,
    ProcurementTeamID int NULL,
    ProcurementSurgeon varchar(64) NULL,
	ReceivedNecroReportWithin5Days bit NULL Default NULL,
	QualityOfProcurementWasBad bit NULL Default NULL,
    TransplantStatusID int NULL,
	Comment varchar(256) NULL,
    IsDeleted bit NOT NULL Default 0,
	ModificationVersion ROWVERSION,
    CONSTRAINT [PK_TransplantOrgan] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_Donor] FOREIGN KEY([DonorID])
REFERENCES [dbo].[Donor] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_Donor]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_Organ] FOREIGN KEY([OrganID])
REFERENCES [dbo].[Organ] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_Organ]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_Organization] FOREIGN KEY([OrganizationID])
REFERENCES [dbo].[Organization] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_Organization]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_TransplantCenter] FOREIGN KEY([TransplantCenterID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_TransplantCenter]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_TC] FOREIGN KEY([TCID])
REFERENCES [dbo].[Coordinator] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_TC]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_ProcurementTeam] FOREIGN KEY([ProcurementTeamID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_ProcurementTeam]
GO
ALTER TABLE [dbo].[TransplantOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransplantOrgan_TransplantStatus] FOREIGN KEY([TransplantStatusID])
REFERENCES [dbo].[TransplantStatus] ([ID])
GO
ALTER TABLE [dbo].[TransplantOrgan] CHECK CONSTRAINT [FK_TransplantOrgan_TransplantStatus]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TransplantOrgans' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing Donor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'DonorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'OrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing Organization (like Swisstransplant) the Organ goes to in case of FO' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'OrganizationID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing TransplantationCenter this Organ goes to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'TransplantCenterID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing TransplantationCoordinator at destination' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'TCID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Graftbox number in case on is used' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'GraftBoxNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing Hospital the procurement team for this organ comes from' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'ProcurementTeamID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of the Surgeon procuring this Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'ProcurementSurgeon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Received Necro-report within 5 days? (1 = yes, 0 = no)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'ReceivedNecroReportWithin5Days'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Was quality of procurement bad? (1 = bad, 0 = good)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'QualityOfProcurementWasBad'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key rferencing the final State od this Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'TransplantStatusID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Yes, space for a comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of modification (for Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransplantOrgan', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO


IF OBJECT_ID ('dbo.TransportedOrgan', 'Table') > 0
    DROP Table [dbo].[TransportedOrgan]

CREATE TABLE [dbo].[TransportedOrgan](
    TransplantOrganID int  NOT NULL,
    TransportID int  NOT NULL,
	CONSTRAINT [PK_TransportedOrgan] PRIMARY KEY CLUSTERED 
    (
        [TransplantOrganID] ASC,
        [TransportID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[TransportedOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransportedOrgan_TransplantOrgan] FOREIGN KEY([TransplantOrganID])
REFERENCES [dbo].[TransplantOrgan] ([ID])
GO
ALTER TABLE [dbo].[TransportedOrgan] CHECK CONSTRAINT [FK_TransportedOrgan_TransplantOrgan]
GO
ALTER TABLE [dbo].[TransportedOrgan]  WITH CHECK ADD CONSTRAINT [FK_TransportedOrgan_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[TransportedOrgan] CHECK CONSTRAINT [FK_TransportedOrgan_Transport]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listing Organs that are transported with this transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedOrgan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing TransplantOrgan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedOrgan', @level2type=N'COLUMN',@level2name=N'TransplantOrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedOrgan', @level2type=N'COLUMN',@level2name=N'TransportID'
GO

IF OBJECT_ID ('dbo.TransportItem', 'Table') > 0
    DROP Table [dbo].[TransportItem]


CREATE TABLE [dbo].[TransportItem]
(
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64) NOT NULL,
	ItemGroupID int NULL,
	CountableAs int NULL,
	Position int null,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_TransportItem] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign keys
ALTER TABLE [dbo].[TransportItem]  WITH CHECK ADD CONSTRAINT [FK_TransportItem_ItemGroup] FOREIGN KEY([ItemGroupID])
REFERENCES [dbo].[ItemGroup] ([ID])
GO
ALTER TABLE [dbo].[TransportItem] CHECK CONSTRAINT [FK_TransportItem_ItemGroup]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TransportItems (Blood, Koord, Surgeon...)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ItemName' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of ItemGroup (grouping Coordinators, Team, Blood etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem', @level2type=N'COLUMN',@level2name=N'ItemGroupID'
GO


IF OBJECT_ID ('dbo.OrganToTransportItemAssociation', 'Table') > 0
    DROP Table [dbo].[OrganToTransportItemAssociation]

CREATE TABLE [dbo].[OrganToTransportItemAssociation]
(
    ID int IDENTITY(1,1) NOT NULL,
    OrganID int NULL,
	TransportItemID int NULL,
    CONSTRAINT [PK_OrganToTransportItemAssociation] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Associated Organ(s) to TransportItem' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganToTransportItemAssociation'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganToTransportItemAssociation', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of table Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganToTransportItemAssociation', @level2type=N'COLUMN',@level2name=N'OrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of table TransportItem' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganToTransportItemAssociation', @level2type=N'COLUMN',@level2name=N'TransportItemID'
GO

--foreign Keys
ALTER TABLE [dbo].[OrganToTransportItemAssociation]  WITH CHECK ADD CONSTRAINT [FK_OrganToTransportItemAssociation_Organ] FOREIGN KEY([OrganID])
REFERENCES [dbo].[Organ] ([ID])
GO
ALTER TABLE [dbo].[OrganToTransportItemAssociation] CHECK CONSTRAINT [FK_OrganToTransportItemAssociation_Organ]
GO
ALTER TABLE [dbo].[OrganToTransportItemAssociation]  WITH CHECK ADD CONSTRAINT [FK_OrganToTransportItemAssociation_TransportItem] FOREIGN KEY([TransportItemID])
REFERENCES [dbo].[TransportItem] ([ID])
GO
ALTER TABLE [dbo].[OrganToTransportItemAssociation] CHECK CONSTRAINT [FK_OrganToTransportItemAssociation_TransportItem]
GO


IF OBJECT_ID ('dbo.TransportedItem', 'Table') > 0
    DROP Table [dbo].[TransportedItem]

CREATE TABLE [dbo].[TransportedItem](
    TransportItemID int  NOT NULL,
    TransportID int  NOT NULL,
    CONSTRAINT [PK_TransportedItem] PRIMARY KEY CLUSTERED 
    (
        [TransportItemID] ASC,
        [TransportID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[TransportedItem]  WITH CHECK ADD CONSTRAINT [FK_TransportedItem_TransportItem] FOREIGN KEY([TransportItemID])
REFERENCES [dbo].[TransportItem] ([ID])
GO
ALTER TABLE [dbo].[TransportedItem] CHECK CONSTRAINT [FK_TransportedItem_TransportItem]
GO
ALTER TABLE [dbo].[TransportedItem]  WITH CHECK ADD CONSTRAINT [FK_TransportedItem_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[TransportedItem] CHECK CONSTRAINT [FK_TransportedItem_Transport]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listing Items other than Organs that are transported with this transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedItem'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Item' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedItem', @level2type=N'COLUMN',@level2name=N'TransportItemID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportedItem', @level2type=N'COLUMN',@level2name=N'TransportID'
GO


IF OBJECT_ID ('dbo.RelatedTransport', 'Table') > 0
    DROP Table [dbo].[RelatedTransport]

CREATE TABLE [dbo].[RelatedTransport](
    TransplantOrganID int  NOT NULL,
    TransportID int  NOT NULL,
	CONSTRAINT [PK_RelatedTransport] PRIMARY KEY CLUSTERED 
    (
        [TransplantOrganID] ASC,
        [TransportID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[RelatedTransport]  WITH CHECK ADD CONSTRAINT [FK_RelatedTransport_TransplantOrgan] FOREIGN KEY([TransplantOrganID])
REFERENCES [dbo].[TransplantOrgan] ([ID])
GO
ALTER TABLE [dbo].[RelatedTransport] CHECK CONSTRAINT [FK_RelatedTransport_TransplantOrgan]
GO
ALTER TABLE [dbo].[RelatedTransport]  WITH CHECK ADD CONSTRAINT [FK_RelatedTransport_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[RelatedTransport] CHECK CONSTRAINT [FK_RelatedTransport_Transport]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listing Organs to Transport they relate with (and costs are spent for)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelatedTransport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing TransplantOrgan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelatedTransport', @level2type=N'COLUMN',@level2name=N'TransplantOrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'RelatedTransport', @level2type=N'COLUMN',@level2name=N'TransportID'
GO

IF OBJECT_ID ('dbo.CostGroup', 'Table') > 0
    DROP Table [dbo].[CostGroup]

CREATE TABLE [dbo].[CostGroup](
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(32)  NOT NULL,
    CONSTRAINT [PK_CostGroup] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Grouping Cost categories (mainly used for correct Stats)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostGroup'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostGroup', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'GroupName' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostGroup', @level2type=N'COLUMN',@level2name=N'Name'
GO

IF OBJECT_ID ('dbo.CostType', 'Table') > 0
    DROP Table [dbo].[CostType]

CREATE TABLE [dbo].[CostType](
    ID int IDENTITY(1,1) NOT NULL,
    Name varchar(64)  NOT NULL,
    CostGroupID int NOT NULL,
	Position int NULL,
	isActive bit NOT NULL Default 1,
    CONSTRAINT [PK_CostType] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[CostType]  WITH CHECK ADD CONSTRAINT [FK_CostType_CostGroup] FOREIGN KEY([CostGroupID])
REFERENCES [dbo].[CostGroup] ([ID])
GO
ALTER TABLE [dbo].[CostType] CHECK CONSTRAINT [FK_CostType_CostGroup]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'CostType to charge)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostType', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TypeName' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostType', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing CostGroup ths type fits to' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostType', @level2type=N'COLUMN',@level2name=N'CostGroupID'
GO

IF OBJECT_ID ('dbo.Cost', 'Table') > 0
    DROP Table [dbo].[Cost]

CREATE TABLE [dbo].[Cost](
    ID int IDENTITY(1,1) NOT NULL,
    CostTypeID int NULL,
    Name varchar(64)  NOT NULL,
    KreditorName varchar(32) NULL,
	KreditorHospitalID int NULL,
	CreditorID int NULL,
    InvoiceNo varchar(32) NULL,
    Amount numeric(8,2) NULL,
    DonorID int NULL,
    TransportID int NULL,
	Comment varchar(256) NULL,
    IsDeleted bit NOT NULL Default 0,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_Cost] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_CostType] FOREIGN KEY([CostTypeID])
REFERENCES [dbo].[CostType] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_CostType]
GO
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_Kreditor] FOREIGN KEY([KreditorHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_Kreditor]
GO
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_Creditor] FOREIGN KEY([CreditorID])
REFERENCES [dbo].[Creditor] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_Creditor]
GO
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_Donor] FOREIGN KEY([DonorID])
REFERENCES [dbo].[Donor] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_Donor]
GO
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_Transport]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Cost to charge' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing CostType' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'CostTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'TypeName' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of Kreditor if not a Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'KreditorName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Hospital that is Kreditor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'KreditorHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Creditor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'CreditorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Invoice Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'InvoiceNo'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'Amount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Donor this cost is for (eigther Donor or Transport is referenced)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'DonorID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Transport this cost is for (eigther Donor or Transport is referenced)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'TransportID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Yes, space for a comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of Modification (Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Cost', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO


IF OBJECT_ID ('dbo.OrganCost', 'Table') > 0
    DROP Table [dbo].[OrganCost]

CREATE TABLE [dbo].[OrganCost](
    ID int IDENTITY(1,1) NOT NULL,
    CostID int NULL,
    Amount numeric(8,2) NULL,
    TransplantOrganID int NULL,
	Comment varchar(256) NULL,
    ModificationVersion ROWVERSION,
    CONSTRAINT [PK_OrganCost] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[OrganCost]  WITH CHECK ADD CONSTRAINT [FK_OrganCost_Cost] FOREIGN KEY([CostID])
REFERENCES [dbo].[Cost] ([ID])
GO
ALTER TABLE [dbo].[OrganCost] CHECK CONSTRAINT [FK_OrganCost_Cost]
GO
ALTER TABLE [dbo].[OrganCost]  WITH CHECK ADD CONSTRAINT [FK_OrganCost_TransplantOrgan] FOREIGN KEY([TransplantOrganID])
REFERENCES [dbo].[TransplantOrgan] ([ID])
GO
ALTER TABLE [dbo].[OrganCost] CHECK CONSTRAINT [FK_OrganCost_TransplantOrgan]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'partial Cost on a Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Cost' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'CostID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Amount' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'Amount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Organ this OrganCost is for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'TransplantOrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Yes, space for a comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of Modification (Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCost', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO


IF OBJECT_ID ('dbo.CostDistribution', 'Table') > 0
    DROP Table [dbo].[CostDistribution]

CREATE TABLE [dbo].[CostDistribution]
(
    ID int IDENTITY(1,1) NOT NULL,
    CostTypeID int NOT NULL,
	VehicleID int NULL,
    Name varchar(64) NOT NULL,
    ForAllOrgans bit Default  0,
	CalcTotal bit NOT NULL Default 0,
	TotalConst numeric (8,2) NULL,
	MinOrganCount int NULL,
	MaxOrganCount int NULL,
	ReferOnlyOnTransplantedOrgans bit NOT NULL Default 1
	CONSTRAINT [PK_CostDistribution] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO
ALTER TABLE [dbo].[CostDistribution]  WITH CHECK ADD CONSTRAINT [FK_CostDistribution_CostType] FOREIGN KEY([CostTypeID])
REFERENCES [dbo].[CostType] ([ID])
GO
ALTER TABLE [dbo].[CostDistribution] CHECK CONSTRAINT [FK_CostDistribution_CostType]
GO
ALTER TABLE [dbo].[CostDistribution]  WITH CHECK ADD CONSTRAINT [FK_CostDistribution_Vehicle] FOREIGN KEY([VehicleID])
REFERENCES [dbo].[Vehicle] ([ID])
GO
ALTER TABLE [dbo].[CostDistribution] CHECK CONSTRAINT [FK_CostDistribution_Vehicle]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distribution of costs (weight per organ or consts...- actuall values are in OrganCostWeight and OrganCostConst - )' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing the CostType this distribution is defined for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'CostTypeID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing the Vehicle this distribution is defined for (in case of Transport Cost)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'VehicleID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of CostDistribution' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'Name'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Apply Cost Distribution to all Organs of Donor or only linked ones' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'ForAllOrgans'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Calculate Total Amount from OrganCostDistribution Constances' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'CalcTotal'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Constant Amount of Total Costs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'TotalConst'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If Constant amount based on number of Organs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'MinOrganCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'If Constant amount based on number of Organs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'MaxOrganCount'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Refer only on translpanted organs (in state TX)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'CostDistribution', @level2type=N'COLUMN',@level2name=N'ReferOnlyOnTransplantedOrgans'
GO


IF OBJECT_ID ('dbo.OrganCostDistribution', 'Table') > 0
    DROP Table [dbo].[OrganCostDistribution]

CREATE TABLE [dbo].[OrganCostDistribution](
    ID int IDENTITY(1,1) NOT NULL,
    OrganID int  NOT NULL,
    CostDistributionID int  NOT NULL,
    [Weight] int NULL,
    Const numeric(8,2) NULL,
    ConstPerKm numeric (8,2) NULL,
	CONSTRAINT [PK_OrganCostDistribution] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[OrganCostDistribution]  WITH CHECK ADD CONSTRAINT [FK_OrganCostDistribution_Organ] FOREIGN KEY([OrganID])
REFERENCES [dbo].[Organ] ([ID])
GO
ALTER TABLE [dbo].[OrganCostDistribution] CHECK CONSTRAINT [FK_OrganCostDistribution_Organ]
GO
ALTER TABLE [dbo].[OrganCostDistribution]  WITH CHECK ADD CONSTRAINT [FK_OrganCostDistribution_CostDistribution] FOREIGN KEY([CostDistributionID])
REFERENCES [dbo].[CostDistribution] ([ID])
GO
ALTER TABLE [dbo].[OrganCostDistribution] CHECK CONSTRAINT [FK_OrganCostDistribution_CostDistribution]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value table Organ-CostDistribution Weights' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Organ' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution', @level2type=N'COLUMN',@level2name=N'OrganID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing CostDistribution' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution', @level2type=N'COLUMN',@level2name=N'CostDistributionID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Weight for this organ in this CostDistribution' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution', @level2type=N'COLUMN',@level2name=N'Weight'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Constant for this organ in this CostDistribution' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution', @level2type=N'COLUMN',@level2name=N'Const'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Constant per Kilometer for this organ in this CostDistribution' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'OrganCostDistribution', @level2type=N'COLUMN',@level2name=N'ConstPerKm'
GO



IF OBJECT_ID ('dbo.Distance', 'Table') > 0
    DROP Table [dbo].[Distance]

CREATE TABLE [dbo].[Distance](
    ID int IDENTITY(1,1) NOT NULL,
    Hospital1ID int  NOT NULL,
    Hospital2ID int  NOT NULL,
    Km int NULL,
	CONSTRAINT [PK_Distance] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[Distance]  WITH CHECK ADD CONSTRAINT [FK_Distance_Hospital1] FOREIGN KEY([Hospital1ID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Distance] CHECK CONSTRAINT [FK_Distance_Hospital1]
GO
ALTER TABLE [dbo].[Distance]  WITH CHECK ADD CONSTRAINT [FK_Distance_Hospital2] FOREIGN KEY([Hospital2ID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Distance] CHECK CONSTRAINT [FK_Distance_Hospital2]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value table Organ-CostDistribution Weights' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Distance'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Hospital1' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Distance', @level2type=N'COLUMN',@level2name=N'Hospital1ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Hospital2' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Distance', @level2type=N'COLUMN',@level2name=N'Hospital2ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Distance in Kilometers' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Distance', @level2type=N'COLUMN',@level2name=N'Km'
GO

IF OBJECT_ID ('dbo.DelayReason', 'Table') > 0
    DROP Table [dbo].[DelayReason]

CREATE TABLE [dbo].[DelayReason](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[Reason] [varchar](64) NULL,
	CONSTRAINT [PK_DelayReason] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value table DelayReason' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DelayReason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DelayReason', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reason of delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DelayReason', @level2type=N'COLUMN',@level2name=N'Reason'
GO

IF OBJECT_ID ('dbo.Delay', 'Table') > 0
    DROP Table [dbo].[Delay]

CREATE TABLE [dbo].[Delay](
	[ID] [int] IDENTITY(1,1) NOT NULL,
	[TransportID] [int] NOT NULL,
	[DelayReasonID] [int] NULL,
	[OtherReason] [varchar](64) NULL,
	[Duration] [time](7) NULL,
	[IsOrganLost] [bit] NOT NULL Default 0,
	[Comment] [varchar](256) NULL,
	[IsDeleted] bit NOT NULL Default 0,
    [ModificationVersion] ROWVERSION,
	CONSTRAINT [PK_Delay] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
GO

-- foreign keys
ALTER TABLE [dbo].[Delay]  WITH CHECK ADD  CONSTRAINT [FK_Delay_DelayReason] FOREIGN KEY([DelayReasonID])
REFERENCES [dbo].[DelayReason] ([ID])
GO
ALTER TABLE [dbo].[Delay] CHECK CONSTRAINT [FK_Delay_DelayReason]
GO
ALTER TABLE [dbo].[Delay]  WITH CHECK ADD  CONSTRAINT [FK_Delay_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[Delay] CHECK CONSTRAINT [FK_Delay_Transport]
GO

-- descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value table Delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'TransportID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing DelayReason' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'DelayReasonID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Other reason of delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'OtherReason'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Duration of delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'Duration'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if organ got lost because of delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'IsOrganLost'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Yes, space for a comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'Comment'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if row is marked as deleted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of Modification (Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Delay', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO

-- Add new table Font
---------------------
IF OBJECT_ID ('dbo.Font', 'Table') > 0
    DROP Table [dbo].[Font]

CREATE TABLE [dbo].[Font]
(
    ID INT IDENTITY(1,1) NOT NULL,
    FontName VARCHAR(64) NULL,
	FontSize INT NOT NULL
    CONSTRAINT [PK_Font] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Fonts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Font'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Font', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Name of font' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Font', @level2type=N'COLUMN',@level2name=N'FontName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Size of font' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Font', @level2type=N'COLUMN',@level2name=N'FontSize'
GO

-- Add new table ReminderLetter
-------------------------------
IF OBJECT_ID ('dbo.ReminderLetter', 'Table') > 0
    DROP Table [dbo].[ReminderLetter]

CREATE TABLE [dbo].[ReminderLetter]
(
    ID INT IDENTITY(1,1) NOT NULL,
	LanguageID INT NOT NULL,
	FontID INT NOT NULL,
	Location VARCHAR(64) NULL,
    SalutationText VARCHAR(256) NULL,
	TextBlockA NVARCHAR(MAX) NULL,
	TextBlockB NVARCHAR(MAX) NULL,
	GreetingText NVARCHAR(256),
	SignatureText NVARCHAR(128) NULL,
	HeaderDonorNumber NVARCHAR(64) NULL,
	HeaderCostType NVARCHAR(64) NULL,
	HeaderCosts NVARCHAR(64) NULL,
	FooterTotal NVARCHAR(64) NULL
    CONSTRAINT [PK_ReminderLetter] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Reminder Letters' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Language' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'LanguageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Font' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'FontID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Location, city' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'Location'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Salutation Block' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'SalutationText'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'1st Text Block' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'TextBlockA'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'2nd Text Block' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'TextBlockB'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Greeting Block' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'GreetingText'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Signature Block' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'SignatureText'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Data Table Header Donor Number' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'HeaderDonorNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Data Table Header Cost Type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'HeaderCostType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Data Table Header Costs' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'HeaderCosts'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Data Table Footer Total' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'ReminderLetter', @level2type=N'COLUMN',@level2name=N'FooterTotal'
GO

--foreign keys
ALTER TABLE [dbo].[ReminderLetter]  WITH CHECK ADD CONSTRAINT [FK_ReminderLetter_Language] FOREIGN KEY([LanguageID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[ReminderLetter] CHECK CONSTRAINT [FK_ReminderLetter_Language]
GO

ALTER TABLE [dbo].[ReminderLetter]  WITH CHECK ADD CONSTRAINT [FK_ReminderLetter_Font] FOREIGN KEY([FontID])
REFERENCES [dbo].[Font] ([ID])
GO
ALTER TABLE [dbo].[ReminderLetter] CHECK CONSTRAINT [FK_ReminderLetter_Font]
GO


CREATE VIEW StatsDonor
as
SELECT
	DonorNumber as 'Donor Number',
	hDetection.Display as 'Detection Hospital',
	hReferral.Display as 'Referral Hospital',
	hProc.Display as 'Procurement Hospital',
	d.RegisterDate as 'Register Date',
	d.ProcurementDate as 'Procurement Date',
	isnull(tc.FirstName, '') + ' ' + isnull(tc.LastName, '') as 'Transplant Coordinator',
	o.Name  as 'Organization',
	isnull(nc.FirstName, '') + ' ' + isnull(nc.LastName, '') as 'National Coordinator',
	d.Comment as 'Comment'
FROM Donor d
LEFT JOIN Organization o ON o.ID = d.OrganizationID
LEFT JOIN Hospital hDetection ON hDetection.ID = d.DetectionHospitalID
LEFT JOIN Hospital hReferral ON hReferral.ID = d.ReferralHospitalID
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN Coordinator tc ON tc.ID = d.TCID
LEFT JOIN Coordinator nc ON nc.ID = d.NCID
WHERE d.IsDeleted = 0
GO

CREATE VIEW StatsOrgans
as
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
	d.RegisterDate as 'Register Date',
	d.ProcurementDate as 'Procurement Date',
	o.Name as 'Organ',
	hTx.Name as 'Transplantation Center',
		isnull(tc.FirstName, '') + ' ' + isnull(tc.LastName, '') as 'Transplant Coordinator', 
	procTeam.Display as 'Procurement Team',
	txo.ProcurementSurgeon as 'Procurement Surgeon',
	CASE txo.ReceivedNecroReportWithin5Days
		WHEN 1 THEN 'yes'
		WHEN 0 THEN 'no'
		ELSE null
		END
	as 'Necro Report within 5 days',
	CASE txo.QualityOfProcurementWasBad
		WHEN 1 THEN 'bad'
		WHEN 0 THEN 'good'
		ELSE null
		END
	as 'Procurement Quality',
	s.Name as 'Transplant Status'
FROM Donor d
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN TransplantOrgan txo ON txo.DonorID = d.ID AND txo.IsDeleted = 0
LEFT JOIN Organ o ON o.ID = txo.OrganID
LEFT JOIN Hospital hTx ON hTx.ID = txo.TransplantCenterID
LEFT JOIN TransplantStatus s ON s.ID = txo.TransplantStatusID
LEFT JOIN Coordinator tc ON tc.ID = txo.TCID
LEFT JOIN Hospital procTeam ON procTeam.ID = txo.ProcurementTeamID
WHERE d.IsDeleted = 0

GO

CREATE FUNCTION GetTranportedOrgans (@TransportID int) RETURNS VARCHAR(max) AS
BEGIN

			DECLARE @LIST varchar(1024)
			SELECT @LIST = Coalesce(@List + ',', '') + o.Name 
			from TransportedOrgan transpOrgan 
			join TransplantOrgan transplantOrgan ON transplantOrgan.ID = transpOrgan.TransplantOrganID 
			join Organ o ON o.ID = transplantOrgan.OrganID
			where TransportID = @TransportID
			RETURN @List
END	;
GO

CREATE FUNCTION GetTranportedItems (@TransportID int) RETURNS VARCHAR(max) AS
BEGIN

			DECLARE @LIST varchar(1024)
			SELECT @LIST = Coalesce(@List + ',', '') + transportItem.Name 
			from TransportedItem transpItem 
			join TransportItem transportItem ON transportItem.ID = transpItem.TransportItemID
			where TransportID = @TransportID
			RETURN @List
END	;
GO

CREATE VIEW [dbo].[StatsTransports]
as
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
	d.RegisterDate as 'Register Date',
	d.ProcurementDate as 'Procurement Date',
	CASE WHEN t.DepartureHospitalID IS NULL 
		THEN t.OtherDeparture
		ELSE hDep.Display
	END as 'Departure',
	CASE WHEN t.DestinationHospitalID IS NULL
		THEN t.OtherDestination
		ELSE hDest.Display
	END as 'Destination',
	dbo.GetTranportedOrgans(t.ID) as 'Organs',
	dbo.GetTranportedItems(t.ID) as 'Items',
	(select ISNULL(sum(o.CountableAs), 0) 
	 from	Organ o
			join TransplantOrgan txo on o.ID = txo.OrganID 
			join TransportedOrgan tro on tro.TransplantOrganID = txo.ID 
	 where	tro.TransportID = t.ID) as OrganCount,
	(select ISNULL(sum(ti.CountableAs), 0) 
	 from	TransportItem ti join TransportedItem tri ON ti.ID = tri.TransportItemID 
	 where	tri.TransportID = t.ID) as ItemCount,
	 (
	 (select ISNULL(sum(o.CountableAs), 0) 
	 from	Organ o
			join TransplantOrgan txo on o.ID = txo.OrganID 
			join TransportedOrgan tro on tro.TransplantOrganID = txo.ID 
	 where	tro.TransportID = t.ID)
	 +
	 (select ISNULL(sum(ti.CountableAs), 0) 
	 from	TransportItem ti join TransportedItem tri ON ti.ID = tri.TransportItemID 
	 where	tri.TransportID = t.ID)
	 ) as TotalCount,
	Departure as 'Departed', 
	Arrival as 'Arrived',
	WaitingTime as 'Waiting Time',
	v.Name as 'Vehicle',
	CASE PoliceEscorted WHEN 1
		THEN 'yes'
		ELSE 'no'
	END as 'Police Escorted',
	FlightNumber,
	Immatriculation,
	oc.Name as 'Operation Center',
	Provider,
	Forewarning,
	t.Comment,
	DatePart(hour, del.Duration) * 60 +  DatePart(Minute, del.Duration)  as 'Delay',
	CASE WHEN del.DelayReasonID IS NULL
		THEN del.OtherReason
		ELSE delR.Reason
	END as 'Delay Reason',
	CASE del.IsOrganLost WHEN 1
		THEN 'yes'
		ELSE 'no'
	END as 'Organ lost due to delay',
	del.Comment as 'Delay comment'
FROM Donor d
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN Transport t ON t.DonorID = d.ID AND t.IsDeleted = 0
LEFT JOIN Hospital hDep ON hDep.ID = t.DepartureHospitalID
LEFT JOIN Hospital hDest ON hDest.ID = t.DestinationHospitalID
LEFT JOIN Vehicle v ON v.ID = t.VehicleID
LEFT JOIN OperationCenter oc ON oc.ID = t.OperationCenterID
LEFT JOIN Delay del ON del.TransportID = t.ID AND del.IsDeleted = 0
LEFT JOIN DelayReason delR ON delR.ID = del.DelayReasonID
WHERE d.IsDeleted = 0

GO

CREATE VIEW StatsGeneralCosts
as
SELECT
	DonorNumber AS 'Donor Number',
	hProc.Display AS 'Procurement Hospital',
	d.RegisterDate AS 'Register Date',
	d.ProcurementDate AS 'Procurement Date',
	ct.Name AS 'Cost',
	CASE WHEN c.KreditorHospitalID IS NULL 
		THEN c.KreditorName
		ELSE k.Display
	END AS 'Kreditor',
	c.InvoiceNo AS 'Invoice Number',
	c.Amount AS 'Total',
	o.Name AS 'Organ', 
	ISNULL(oc.Amount, c.Amount) AS 'Amount'
FROM Donor d
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN Cost c ON c.DonorID = d.ID AND C.IsDeleted = 0
LEFT JOIN CostType ct ON ct.ID = c.CostTypeID
LEFT JOIN CostGroup cg ON cg.ID = ct.CostGroupID
LEFT JOIN OrganCost oc ON oc.CostID = c.ID
LEFT JOIN TransplantOrgan tro ON tro.ID = oc.TransplantOrganID
LEFT JOIN Organ o ON o.ID = tro.OrganID
LEFT JOIN Hospital k ON k.ID = c.KreditorHospitalID
WHERE d.IsDeleted = 0
AND cg.Name = 'Donor'
GO

CREATE VIEW [dbo].[StatsTransportCosts]
as
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
	d.RegisterDate as 'Register Date',
	d.ProcurementDate as 'Procurement Date',
	null 'Departure',
	null 'Destination',
	null 'Organs',
	null as 'Items',
	null as OrganCount,
	null as ItemCount,
	null as TotalCount,
	null as 'Departed', 
	null as 'Arrived',
	null as 'Waiting Time',
	null  as 'Vehicle',
	null as 'Police Escorted',
	null as 'Operation Center',
	ct.Name as 'Cost',
	CASE WHEN c.CreditorID IS NULL 
		THEN c.KreditorName
		ELSE k.CreditorName
	END as 'Kreditor',
	c.InvoiceNo as 'Invoice Number',
	c.Amount as 'Total',
	o.Name as 'Organ', 
	ISNULL(oc.Amount, c.Amount) AS 'Amount'
FROM Donor d
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN Cost c ON c.DonorID = d.ID AND C.IsDeleted = 0
LEFT JOIN CostType ct ON ct.ID = c.CostTypeID
LEFT JOIN OrganCost oc ON oc.CostID = c.ID
LEFT JOIN CostGroup cg ON cg.ID = ct.CostGroupID
LEFT JOIN TransplantOrgan tro ON tro.ID = oc.TransplantOrganID
LEFT JOIN Organ o ON o.ID = tro.OrganID
LEFT JOIN Creditor k ON k.ID = c.CreditorID
WHERE d.IsDeleted = 0
AND cg.Name = 'TransportGlobal'
AND c.TransportID IS NULL
UNION
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
	d.RegisterDate as 'Register Date',
	d.ProcurementDate as 'Procurement Date',
	CASE WHEN t.DepartureHospitalID IS NULL 
		THEN t.OtherDeparture
		ELSE hDep.Display
	END as 'Departure',
	CASE WHEN t.DestinationHospitalID IS NULL
		THEN t.OtherDestination
		ELSE hDest.Display
	END as 'Destination',
	dbo.GetTranportedOrgans(t.ID) as 'Organs',
	dbo.GetTranportedItems(t.ID) as 'Items',
	(select ISNULL(sum(o.CountableAs), 0) 
	 from	Organ o
			join TransplantOrgan txo on o.ID = txo.OrganID 
			join TransportedOrgan tro on tro.TransplantOrganID = txo.ID 
	 where	tro.TransportID = t.ID) as OrganCount,
	(select ISNULL(sum(ti.CountableAs), 0) 
	 from	TransportItem ti join TransportedItem tri ON ti.ID = tri.TransportItemID 
	 where	tri.TransportID = t.ID) as ItemCount,
	(
		(select ISNULL(sum(o.CountableAs), 0) 
		 from	Organ o
				join TransplantOrgan txo on o.ID = txo.OrganID 
				join TransportedOrgan tro on tro.TransplantOrganID = txo.ID 
		 where	tro.TransportID = t.ID)
		+
		(select ISNULL(sum(ti.CountableAs), 0) 
		 from	TransportItem ti 
				join TransportedItem tri ON ti.ID = tri.TransportItemID 
		 where	tri.TransportID = t.ID) 
	) as TotalCount,
	Departure as 'Departed', 
	Arrival as 'Arrived',
	WaitingTime as 'Waiting Time',
	v.Name as 'Vehicle',
	CASE PoliceEscorted WHEN 1
		THEN 'yes'
		ELSE 'no'
	END as 'Police Escorted',
	oc.Name as 'Operation Center',
	ct.Name as 'Cost',
	CASE WHEN c.CreditorID IS NULL 
		THEN c.KreditorName
		ELSE k.CreditorName
	END as 'Kreditor',
	c.InvoiceNo as 'Invoice Number',
	c.Amount as 'Total',
	o.Name as 'Organ', 
	ISNULL(ocost.Amount, c.Amount) AS 'Amount'
FROM Donor d
LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
LEFT JOIN Transport t ON t.DonorID = d.ID AND t.IsDeleted = 0
LEFT JOIN Hospital hDep ON hDep.ID = t.DepartureHospitalID
LEFT JOIN Hospital hDest ON hDest.ID = t.DestinationHospitalID
LEFT JOIN Vehicle v ON v.ID = t.VehicleID
LEFT JOIN OperationCenter oc ON oc.ID = t.OperationCenterID
LEFT JOIN Cost c ON c.TransportID = t.ID AND C.IsDeleted = 0
LEFT JOIN CostType ct ON ct.ID = c.CostTypeID
LEFT JOIN CostGroup cg ON cg.ID = ct.CostGroupID
LEFT JOIN OrganCost ocost ON ocost.CostID = c.ID
LEFT JOIN TransplantOrgan tro ON tro.ID = ocost.TransplantOrganID
LEFT JOIN Organ o ON o.ID = tro.OrganID
LEFT JOIN Creditor k ON k.ID = c.CreditorID
WHERE d.IsDeleted = 0
AND cg.Name = 'Transport'

GO


--USER
use [master]
IF NOT EXISTS (SELECT name FROM [master].[dbo].syslogins WHERE name = N'SLIDS_User')
CREATE LOGIN [SLIDS_User] WITH PASSWORD=N'Cantaloop01', DEFAULT_DATABASE=[SLIDS], DEFAULT_LANGUAGE=[English], CHECK_EXPIRATION=OFF, CHECK_POLICY=ON
GO

USE [SLIDS]
GO
/****** User Mapping ***/
CREATE USER [SLIDS_User] FOR LOGIN [SLIDS_User]
GO
EXEC sp_addrolemember N'db_datareader', N'SLIDS_User'
GO
EXEC sp_addrolemember N'db_datawriter', N'SLIDS_User'
GO

/*
	Membership objects
*/
USE [SLIDS]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Membership_BasicAccess' AND type = 'R')
CREATE ROLE [aspnet_Membership_BasicAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Membership_FullAccess' AND type = 'R')
CREATE ROLE [aspnet_Membership_FullAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Membership_ReportingAccess' AND type = 'R')
CREATE ROLE [aspnet_Membership_ReportingAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Personalization_BasicAccess' AND type = 'R')
CREATE ROLE [aspnet_Personalization_BasicAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Personalization_FullAccess' AND type = 'R')
CREATE ROLE [aspnet_Personalization_FullAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Personalization_ReportingAccess' AND type = 'R')
CREATE ROLE [aspnet_Personalization_ReportingAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Profile_BasicAccess' AND type = 'R')
CREATE ROLE [aspnet_Profile_BasicAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Profile_FullAccess' AND type = 'R')
CREATE ROLE [aspnet_Profile_FullAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Profile_ReportingAccess' AND type = 'R')
CREATE ROLE [aspnet_Profile_ReportingAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Roles_BasicAccess' AND type = 'R')
CREATE ROLE [aspnet_Roles_BasicAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Roles_FullAccess' AND type = 'R')
CREATE ROLE [aspnet_Roles_FullAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_Roles_ReportingAccess' AND type = 'R')
CREATE ROLE [aspnet_Roles_ReportingAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.database_principals WHERE name = N'aspnet_WebEvent_FullAccess' AND type = 'R')
CREATE ROLE [aspnet_WebEvent_FullAccess] AUTHORIZATION [dbo]
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Membership_BasicAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Membership_BasicAccess] AUTHORIZATION [aspnet_Membership_BasicAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Membership_FullAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Membership_FullAccess] AUTHORIZATION [aspnet_Membership_FullAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Membership_ReportingAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Membership_ReportingAccess] AUTHORIZATION [aspnet_Membership_ReportingAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Personalization_BasicAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Personalization_BasicAccess] AUTHORIZATION [aspnet_Personalization_BasicAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Personalization_FullAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Personalization_FullAccess] AUTHORIZATION [aspnet_Personalization_FullAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Personalization_ReportingAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Personalization_ReportingAccess] AUTHORIZATION [aspnet_Personalization_ReportingAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Profile_BasicAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Profile_BasicAccess] AUTHORIZATION [aspnet_Profile_BasicAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Profile_FullAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Profile_FullAccess] AUTHORIZATION [aspnet_Profile_FullAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Profile_ReportingAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Profile_ReportingAccess] AUTHORIZATION [aspnet_Profile_ReportingAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Roles_BasicAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Roles_BasicAccess] AUTHORIZATION [aspnet_Roles_BasicAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Roles_FullAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Roles_FullAccess] AUTHORIZATION [aspnet_Roles_FullAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_Roles_ReportingAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_Roles_ReportingAccess] AUTHORIZATION [aspnet_Roles_ReportingAccess]'
GO
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = N'aspnet_WebEvent_FullAccess')
EXEC sys.sp_executesql N'CREATE SCHEMA [aspnet_WebEvent_FullAccess] AUTHORIZATION [aspnet_WebEvent_FullAccess]'
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Applications]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Applications](
	[ApplicationName] [nvarchar](256) NOT NULL,
	[LoweredApplicationName] [nvarchar](256) NOT NULL,
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[Description] [nvarchar](256) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[ApplicationId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01],
UNIQUE NONCLUSTERED 
(
	[LoweredApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01],
UNIQUE NONCLUSTERED 
(
	[ApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Applications]') AND name = N'aspnet_Applications_Index')
CREATE CLUSTERED INDEX [aspnet_Applications_Index] ON [dbo].[aspnet_Applications] 
(
	[LoweredApplicationName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
SET ANSI_PADDING ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_WebEvent_Events]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_WebEvent_Events](
	[EventId] [char](32) NOT NULL,
	[EventTimeUtc] [datetime] NOT NULL,
	[EventTime] [datetime] NOT NULL,
	[EventType] [nvarchar](256) NOT NULL,
	[EventSequence] [decimal](19, 0) NOT NULL,
	[EventOccurrence] [decimal](19, 0) NOT NULL,
	[EventCode] [int] NOT NULL,
	[EventDetailCode] [int] NOT NULL,
	[Message] [nvarchar](1024) NULL,
	[ApplicationPath] [nvarchar](256) NULL,
	[ApplicationVirtualPath] [nvarchar](256) NULL,
	[MachineName] [nvarchar](256) NOT NULL,
	[RequestUrl] [nvarchar](1024) NULL,
	[ExceptionType] [nvarchar](256) NULL,
	[Details] [ntext] NULL,
PRIMARY KEY CLUSTERED 
(
	[EventId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01] TEXTIMAGE_ON [Data01]
END
GO
SET ANSI_PADDING OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Setup_RestorePermissions]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Setup_RestorePermissions]
    @name   sysname
AS
BEGIN
    DECLARE @object sysname
    DECLARE @protectType char(10)
    DECLARE @action varchar(60)
    DECLARE @grantee sysname
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT Object, ProtectType, [Action], Grantee FROM #aspnet_Permissions where Object = @name

    OPEN c1

    FETCH c1 INTO @object, @protectType, @action, @grantee
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = @protectType + '' '' + @action + '' on '' + @object + '' TO ['' + @grantee + '']''
        EXEC (@cmd)
        FETCH c1 INTO @object, @protectType, @action, @grantee
    END

    CLOSE c1
    DEALLOCATE c1
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Setup_RemoveAllRoleMembers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Setup_RemoveAllRoleMembers]
    @name   sysname
AS
BEGIN
    CREATE TABLE #aspnet_RoleMembers
    (
        Group_name      sysname,
        Group_id        smallint,
        Users_in_group  sysname,
        User_id         smallint
    )

    INSERT INTO #aspnet_RoleMembers
    EXEC sp_helpuser @name

    DECLARE @user_id smallint
    DECLARE @cmd nvarchar(500)
    DECLARE c1 cursor FORWARD_ONLY FOR
        SELECT User_id FROM #aspnet_RoleMembers

    OPEN c1

    FETCH c1 INTO @user_id
    WHILE (@@fetch_status = 0)
    BEGIN
        SET @cmd = ''EXEC sp_droprolemember '' + '''''''' + @name + '''''', '''''' + USER_NAME(@user_id) + ''''''''
        EXEC (@cmd)
        FETCH c1 INTO @user_id
    END

    CLOSE c1
    DEALLOCATE c1
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_SchemaVersions]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_SchemaVersions](
	[Feature] [nvarchar](128) NOT NULL,
	[CompatibleSchemaVersion] [nvarchar](128) NOT NULL,
	[IsCurrentVersion] [bit] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[Feature] ASC,
	[CompatibleSchemaVersion] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_Applications]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_Applications]
  AS SELECT [dbo].[aspnet_Applications].[ApplicationName], [dbo].[aspnet_Applications].[LoweredApplicationName], [dbo].[aspnet_Applications].[ApplicationId], [dbo].[aspnet_Applications].[Description]
  FROM [dbo].[aspnet_Applications]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_WebEvent_LogEvent]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_WebEvent_LogEvent]
        @EventId         char(32),
        @EventTimeUtc    datetime,
        @EventTime       datetime,
        @EventType       nvarchar(256),
        @EventSequence   decimal(19,0),
        @EventOccurrence decimal(19,0),
        @EventCode       int,
        @EventDetailCode int,
        @Message         nvarchar(1024),
        @ApplicationPath nvarchar(256),
        @ApplicationVirtualPath nvarchar(256),
        @MachineName    nvarchar(256),
        @RequestUrl      nvarchar(1024),
        @ExceptionType   nvarchar(256),
        @Details         ntext
AS
BEGIN
    INSERT
        dbo.aspnet_WebEvent_Events
        (
            EventId,
            EventTimeUtc,
            EventTime,
            EventType,
            EventSequence,
            EventOccurrence,
            EventCode,
            EventDetailCode,
            Message,
            ApplicationPath,
            ApplicationVirtualPath,
            MachineName,
            RequestUrl,
            ExceptionType,
            Details
        )
    VALUES
    (
        @EventId,
        @EventTimeUtc,
        @EventTime,
        @EventType,
        @EventSequence,
        @EventOccurrence,
        @EventCode,
        @EventDetailCode,
        @Message,
        @ApplicationPath,
        @ApplicationVirtualPath,
        @MachineName,
        @RequestUrl,
        @ExceptionType,
        @Details
    )
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Users](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[UserName] [nvarchar](256) NOT NULL,
	[LoweredUserName] [nvarchar](256) NOT NULL,
	[MobileAlias] [nvarchar](16) NULL,
	[IsAnonymous] [bit] NOT NULL,
	[LastActivityDate] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users]') AND name = N'aspnet_Users_Index')
CREATE UNIQUE CLUSTERED INDEX [aspnet_Users_Index] ON [dbo].[aspnet_Users] 
(
	[ApplicationId] ASC,
	[LoweredUserName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users]') AND name = N'aspnet_Users_Index2')
CREATE NONCLUSTERED INDEX [aspnet_Users_Index2] ON [dbo].[aspnet_Users] 
(
	[ApplicationId] ASC,
	[LastActivityDate] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UnRegisterSchemaVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UnRegisterSchemaVersion]
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    DELETE FROM dbo.aspnet_SchemaVersions
        WHERE   Feature = LOWER(@Feature) AND @CompatibleSchemaVersion = CompatibleSchemaVersion
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_CheckSchemaVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_CheckSchemaVersion]
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128)
AS
BEGIN
    IF (EXISTS( SELECT  *
                FROM    dbo.aspnet_SchemaVersions
                WHERE   Feature = LOWER( @Feature ) AND
                        CompatibleSchemaVersion = @CompatibleSchemaVersion ))
        RETURN 0

    RETURN 1
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Applications_CreateApplication]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Applications_CreateApplication]
    @ApplicationName      nvarchar(256),
    @ApplicationId        uniqueidentifier OUTPUT
AS
BEGIN
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName

    IF(@ApplicationId IS NULL)
    BEGIN
        DECLARE @TranStarted   bit
        SET @TranStarted = 0

        IF( @@TRANCOUNT = 0 )
        BEGIN
	        BEGIN TRANSACTION
	        SET @TranStarted = 1
        END
        ELSE
    	    SET @TranStarted = 0

        SELECT  @ApplicationId = ApplicationId
        FROM dbo.aspnet_Applications WITH (UPDLOCK, HOLDLOCK)
        WHERE LOWER(@ApplicationName) = LoweredApplicationName

        IF(@ApplicationId IS NULL)
        BEGIN
            SELECT  @ApplicationId = NEWID()
            INSERT  dbo.aspnet_Applications (ApplicationId, ApplicationName, LoweredApplicationName)
            VALUES  (@ApplicationId, @ApplicationName, LOWER(@ApplicationName))
        END


        IF( @TranStarted = 1 )
        BEGIN
            IF(@@ERROR = 0)
            BEGIN
	        SET @TranStarted = 0
	        COMMIT TRANSACTION
            END
            ELSE
            BEGIN
                SET @TranStarted = 0
                ROLLBACK TRANSACTION
            END
        END
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Paths]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Paths](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[PathId] [uniqueidentifier] NOT NULL,
	[Path] [nvarchar](256) NOT NULL,
	[LoweredPath] [nvarchar](256) NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[PathId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Paths]') AND name = N'aspnet_Paths_index')
CREATE UNIQUE CLUSTERED INDEX [aspnet_Paths_index] ON [dbo].[aspnet_Paths] 
(
	[ApplicationId] ASC,
	[LoweredPath] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Personalization_GetApplicationId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Personalization_GetApplicationId] (
    @ApplicationName NVARCHAR(256),
    @ApplicationId UNIQUEIDENTIFIER OUT)
AS
BEGIN
    SELECT @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Roles](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
	[RoleName] [nvarchar](256) NOT NULL,
	[LoweredRoleName] [nvarchar](256) NOT NULL,
	[Description] [nvarchar](256) NULL,
PRIMARY KEY NONCLUSTERED 
(
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles]') AND name = N'aspnet_Roles_index1')
CREATE UNIQUE CLUSTERED INDEX [aspnet_Roles_index1] ON [dbo].[aspnet_Roles] 
(
	[ApplicationId] ASC,
	[LoweredRoleName] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_RegisterSchemaVersion]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_RegisterSchemaVersion]
    @Feature                   nvarchar(128),
    @CompatibleSchemaVersion   nvarchar(128),
    @IsCurrentVersion          bit,
    @RemoveIncompatibleSchema  bit
AS
BEGIN
    IF( @RemoveIncompatibleSchema = 1 )
    BEGIN
        DELETE FROM dbo.aspnet_SchemaVersions WHERE Feature = LOWER( @Feature )
    END
    ELSE
    BEGIN
        IF( @IsCurrentVersion = 1 )
        BEGIN
            UPDATE dbo.aspnet_SchemaVersions
            SET IsCurrentVersion = 0
            WHERE Feature = LOWER( @Feature )
        END
    END

    INSERT  dbo.aspnet_SchemaVersions( Feature, CompatibleSchemaVersion, IsCurrentVersion )
    VALUES( LOWER( @Feature ), @CompatibleSchemaVersion, @IsCurrentVersion )
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_PersonalizationPerUser](
	[Id] [uniqueidentifier] NOT NULL,
	[PathId] [uniqueidentifier] NULL,
	[UserId] [uniqueidentifier] NULL,
	[PageSettings] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY NONCLUSTERED 
(
	[Id] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01] TEXTIMAGE_ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]') AND name = N'aspnet_PersonalizationPerUser_index1')
CREATE UNIQUE CLUSTERED INDEX [aspnet_PersonalizationPerUser_index1] ON [dbo].[aspnet_PersonalizationPerUser] 
(
	[PathId] ASC,
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]') AND name = N'aspnet_PersonalizationPerUser_ncindex2')
CREATE UNIQUE NONCLUSTERED INDEX [aspnet_PersonalizationPerUser_ncindex2] ON [dbo].[aspnet_PersonalizationPerUser] 
(
	[UserId] ASC,
	[PathId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Profile](
	[UserId] [uniqueidentifier] NOT NULL,
	[PropertyNames] [ntext] NOT NULL,
	[PropertyValuesString] [ntext] NOT NULL,
	[PropertyValuesBinary] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01] TEXTIMAGE_ON [Data01]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_Membership](
	[ApplicationId] [uniqueidentifier] NOT NULL,
	[UserId] [uniqueidentifier] NOT NULL,
	[Password] [nvarchar](128) NOT NULL,
	[PasswordFormat] [int] NOT NULL,
	[PasswordSalt] [nvarchar](128) NOT NULL,
	[MobilePIN] [nvarchar](16) NULL,
	[Email] [nvarchar](256) NULL,
	[LoweredEmail] [nvarchar](256) NULL,
	[PasswordQuestion] [nvarchar](256) NULL,
	[PasswordAnswer] [nvarchar](128) NULL,
	[IsApproved] [bit] NOT NULL,
	[IsLockedOut] [bit] NOT NULL,
	[CreateDate] [datetime] NOT NULL,
	[LastLoginDate] [datetime] NOT NULL,
	[LastPasswordChangedDate] [datetime] NOT NULL,
	[LastLockoutDate] [datetime] NOT NULL,
	[FailedPasswordAttemptCount] [int] NOT NULL,
	[FailedPasswordAttemptWindowStart] [datetime] NOT NULL,
	[FailedPasswordAnswerAttemptCount] [int] NOT NULL,
	[FailedPasswordAnswerAttemptWindowStart] [datetime] NOT NULL,
	[Comment] [ntext] NULL,
PRIMARY KEY NONCLUSTERED 
(
	[UserId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01] TEXTIMAGE_ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership]') AND name = N'aspnet_Membership_index')
CREATE CLUSTERED INDEX [aspnet_Membership_index] ON [dbo].[aspnet_Membership] 
(
	[ApplicationId] ASC,
	[LoweredEmail] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Paths_CreatePath]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Paths_CreatePath]
    @ApplicationId UNIQUEIDENTIFIER,
    @Path           NVARCHAR(256),
    @PathId         UNIQUEIDENTIFIER OUTPUT
AS
BEGIN
    BEGIN TRANSACTION
    IF (NOT EXISTS(SELECT * FROM dbo.aspnet_Paths WHERE LoweredPath = LOWER(@Path) AND ApplicationId = @ApplicationId))
    BEGIN
        INSERT dbo.aspnet_Paths (ApplicationId, Path, LoweredPath) VALUES (@ApplicationId, @Path, LOWER(@Path))
    END
    COMMIT TRANSACTION
    SELECT @PathId = PathId FROM dbo.aspnet_Paths WHERE LOWER(@Path) = LoweredPath AND ApplicationId = @ApplicationId
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAllUsers]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_PersonalizationAllUsers](
	[PathId] [uniqueidentifier] NOT NULL,
	[PageSettings] [image] NOT NULL,
	[LastUpdatedDate] [datetime] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[PathId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01] TEXTIMAGE_ON [Data01]
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users_CreateUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Users_CreateUser]
    @ApplicationId    uniqueidentifier,
    @UserName         nvarchar(256),
    @IsUserAnonymous  bit,
    @LastActivityDate DATETIME,
    @UserId           uniqueidentifier OUTPUT
AS
BEGIN
    IF( @UserId IS NULL )
        SELECT @UserId = NEWID()
    ELSE
    BEGIN
        IF( EXISTS( SELECT UserId FROM dbo.aspnet_Users
                    WHERE @UserId = UserId ) )
            RETURN -1
    END

    INSERT dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate)
    VALUES (@ApplicationId, @UserId, @UserName, LOWER(@UserName), @IsUserAnonymous, @LastActivityDate)

    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles_RoleExists]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Roles_RoleExists]
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(0)
    IF (EXISTS (SELECT RoleName FROM dbo.aspnet_Roles WHERE LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId ))
        RETURN(1)
    ELSE
        RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles_GetAllRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Roles_GetAllRoles] (
    @ApplicationName           nvarchar(256))
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN
    SELECT RoleName
    FROM   dbo.aspnet_Roles WHERE ApplicationId = @ApplicationId
    ORDER BY RoleName
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles]') AND type in (N'U'))
BEGIN
CREATE TABLE [dbo].[aspnet_UsersInRoles](
	[UserId] [uniqueidentifier] NOT NULL,
	[RoleId] [uniqueidentifier] NOT NULL,
PRIMARY KEY CLUSTERED 
(
	[UserId] ASC,
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
) ON [Data01]
END
GO
IF NOT EXISTS (SELECT * FROM sys.indexes WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles]') AND name = N'aspnet_UsersInRoles_index')
CREATE NONCLUSTERED INDEX [aspnet_UsersInRoles_index] ON [dbo].[aspnet_UsersInRoles] 
(
	[RoleId] ASC
)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles_CreateRole]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Roles_CreateRole]
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
        BEGIN TRANSACTION
        SET @TranStarted = 1
    END
    ELSE
        SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF (EXISTS(SELECT RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId))
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    INSERT INTO dbo.aspnet_Roles
                (ApplicationId, RoleName, LoweredRoleName)
         VALUES (@ApplicationId, @RoleName, LOWER(@RoleName))

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
        COMMIT TRANSACTION
    END

    RETURN(0)

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
        ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_Users]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_Users]
  AS SELECT [dbo].[aspnet_Users].[ApplicationId], [dbo].[aspnet_Users].[UserId], [dbo].[aspnet_Users].[UserName], [dbo].[aspnet_Users].[LoweredUserName], [dbo].[aspnet_Users].[MobileAlias], [dbo].[aspnet_Users].[IsAnonymous], [dbo].[aspnet_Users].[LastActivityDate]
  FROM [dbo].[aspnet_Users]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_Roles]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_Roles]
  AS SELECT [dbo].[aspnet_Roles].[ApplicationId], [dbo].[aspnet_Roles].[RoleId], [dbo].[aspnet_Roles].[RoleName], [dbo].[aspnet_Roles].[LoweredRoleName], [dbo].[aspnet_Roles].[Description]
  FROM [dbo].[aspnet_Roles]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_WebPartState_Paths]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_Paths]
  AS SELECT [dbo].[aspnet_Paths].[ApplicationId], [dbo].[aspnet_Paths].[PathId], [dbo].[aspnet_Paths].[Path], [dbo].[aspnet_Paths].[LoweredPath]
  FROM [dbo].[aspnet_Paths]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_WebPartState_User]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_User]
  AS SELECT [dbo].[aspnet_PersonalizationPerUser].[PathId], [dbo].[aspnet_PersonalizationPerUser].[UserId], [DataSize]=DATALENGTH([dbo].[aspnet_PersonalizationPerUser].[PageSettings]), [dbo].[aspnet_PersonalizationPerUser].[LastUpdatedDate]
  FROM [dbo].[aspnet_PersonalizationPerUser]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_WebPartState_Shared]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_WebPartState_Shared]
  AS SELECT [dbo].[aspnet_PersonalizationAllUsers].[PathId], [DataSize]=DATALENGTH([dbo].[aspnet_PersonalizationAllUsers].[PageSettings]), [dbo].[aspnet_PersonalizationAllUsers].[LastUpdatedDate]
  FROM [dbo].[aspnet_PersonalizationAllUsers]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_UsersInRoles]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_UsersInRoles]
  AS SELECT [dbo].[aspnet_UsersInRoles].[UserId], [dbo].[aspnet_UsersInRoles].[RoleId]
  FROM [dbo].[aspnet_UsersInRoles]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_Profiles]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_Profiles]
  AS SELECT [dbo].[aspnet_Profile].[UserId], [dbo].[aspnet_Profile].[LastUpdatedDate],
      [DataSize]=  DATALENGTH([dbo].[aspnet_Profile].[PropertyNames])
                 + DATALENGTH([dbo].[aspnet_Profile].[PropertyValuesString])
                 + DATALENGTH([dbo].[aspnet_Profile].[PropertyValuesBinary])
  FROM [dbo].[aspnet_Profile]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.views WHERE object_id = OBJECT_ID(N'[dbo].[vw_aspnet_MembershipUsers]'))
EXEC dbo.sp_executesql @statement = N'
  CREATE VIEW [dbo].[vw_aspnet_MembershipUsers]
  AS SELECT [dbo].[aspnet_Membership].[UserId],
            [dbo].[aspnet_Membership].[PasswordFormat],
            [dbo].[aspnet_Membership].[MobilePIN],
            [dbo].[aspnet_Membership].[Email],
            [dbo].[aspnet_Membership].[LoweredEmail],
            [dbo].[aspnet_Membership].[PasswordQuestion],
            [dbo].[aspnet_Membership].[PasswordAnswer],
            [dbo].[aspnet_Membership].[IsApproved],
            [dbo].[aspnet_Membership].[IsLockedOut],
            [dbo].[aspnet_Membership].[CreateDate],
            [dbo].[aspnet_Membership].[LastLoginDate],
            [dbo].[aspnet_Membership].[LastPasswordChangedDate],
            [dbo].[aspnet_Membership].[LastLockoutDate],
            [dbo].[aspnet_Membership].[FailedPasswordAttemptCount],
            [dbo].[aspnet_Membership].[FailedPasswordAttemptWindowStart],
            [dbo].[aspnet_Membership].[FailedPasswordAnswerAttemptCount],
            [dbo].[aspnet_Membership].[FailedPasswordAnswerAttemptWindowStart],
            [dbo].[aspnet_Membership].[Comment],
            [dbo].[aspnet_Users].[ApplicationId],
            [dbo].[aspnet_Users].[UserName],
            [dbo].[aspnet_Users].[MobileAlias],
            [dbo].[aspnet_Users].[IsAnonymous],
            [dbo].[aspnet_Users].[LastActivityDate]
  FROM [dbo].[aspnet_Membership] INNER JOIN [dbo].[aspnet_Users]
      ON [dbo].[aspnet_Membership].[UserId] = [dbo].[aspnet_Users].[UserId]
  '
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_DeleteInactiveProfiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_DeleteInactiveProfiles]
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @InactiveSinceDate      datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT  0
        RETURN
    END

    DELETE
    FROM    dbo.aspnet_Profile
    WHERE   UserId IN
            (   SELECT  UserId
                FROM    dbo.aspnet_Users u
                WHERE   ApplicationId = @ApplicationId
                        AND (LastActivityDate <= @InactiveSinceDate)
                        AND (
                                (@ProfileAuthOptions = 2)
                             OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                             OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                            )
            )

    SELECT  @@ROWCOUNT
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_RemoveUsersFromRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_RemoveUsersFromRoles]
	@ApplicationName  nvarchar(256),
	@UserNames		  nvarchar(4000),
	@RoleNames		  nvarchar(4000)
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)


	DECLARE @TranStarted   bit
	SET @TranStarted = 0

	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @tbNames  table(Name nvarchar(256) NOT NULL PRIMARY KEY)
	DECLARE @tbRoles  table(RoleId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @tbUsers  table(UserId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @Num	  int
	DECLARE @Pos	  int
	DECLARE @NextPos  int
	DECLARE @Name	  nvarchar(256)
	DECLARE @CountAll int
	DECLARE @CountU	  int
	DECLARE @CountR	  int


	SET @Num = 0
	SET @Pos = 1
	WHILE(@Pos <= LEN(@RoleNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @RoleNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@RoleNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@RoleNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbRoles
	  SELECT RoleId
	  FROM   dbo.aspnet_Roles ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredRoleName AND ar.ApplicationId = @AppId
	SELECT @CountR = @@ROWCOUNT

	IF (@CountR <> @Num)
	BEGIN
		SELECT TOP 1 N'''', Name
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT ar.LoweredRoleName FROM dbo.aspnet_Roles ar,  @tbRoles r WHERE r.RoleId = ar.RoleId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(2)
	END


	DELETE FROM @tbNames WHERE 1=1
	SET @Num = 0
	SET @Pos = 1


	WHILE(@Pos <= LEN(@UserNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @UserNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@UserNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@UserNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbUsers
	  SELECT UserId
	  FROM   dbo.aspnet_Users ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredUserName AND ar.ApplicationId = @AppId

	SELECT @CountU = @@ROWCOUNT
	IF (@CountU <> @Num)
	BEGIN
		SELECT TOP 1 Name, N''''
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT au.LoweredUserName FROM dbo.aspnet_Users au,  @tbUsers u WHERE u.UserId = au.UserId)

		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(1)
	END

	SELECT  @CountAll = COUNT(*)
	FROM	dbo.aspnet_UsersInRoles ur, @tbUsers u, @tbRoles r
	WHERE   ur.UserId = u.UserId AND ur.RoleId = r.RoleId

	IF (@CountAll <> @CountU * @CountR)
	BEGIN
		SELECT TOP 1 UserName, RoleName
		FROM		 @tbUsers tu, @tbRoles tr, dbo.aspnet_Users u, dbo.aspnet_Roles r
		WHERE		 u.UserId = tu.UserId AND r.RoleId = tr.RoleId AND
					 tu.UserId NOT IN (SELECT ur.UserId FROM dbo.aspnet_UsersInRoles ur WHERE ur.RoleId = tr.RoleId) AND
					 tr.RoleId NOT IN (SELECT ur.RoleId FROM dbo.aspnet_UsersInRoles ur WHERE ur.UserId = tu.UserId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(3)
	END

	DELETE FROM dbo.aspnet_UsersInRoles
	WHERE UserId IN (SELECT UserId FROM @tbUsers)
	  AND RoleId IN (SELECT RoleId FROM @tbRoles)
	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        ' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_IsUserInRole]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_IsUserInRole]
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(2)
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    DECLARE @RoleId uniqueidentifier
    SELECT  @RoleId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.aspnet_Users
    WHERE   LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

    IF (@UserId IS NULL)
        RETURN(2)

    SELECT  @RoleId = RoleId
    FROM    dbo.aspnet_Roles
    WHERE   LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

    IF (@RoleId IS NULL)
        RETURN(3)

    IF (EXISTS( SELECT * FROM dbo.aspnet_UsersInRoles WHERE  UserId = @UserId AND RoleId = @RoleId))
        RETURN(1)
    ELSE
        RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_GetUsersInRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_GetUsersInRoles]
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
     DECLARE @RoleId uniqueidentifier
     SELECT  @RoleId = NULL

     SELECT  @RoleId = RoleId
     FROM    dbo.aspnet_Roles
     WHERE   LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId

     IF (@RoleId IS NULL)
         RETURN(1)

    SELECT u.UserName
    FROM   dbo.aspnet_Users u, dbo.aspnet_UsersInRoles ur
    WHERE  u.UserId = ur.UserId AND @RoleId = ur.RoleId AND u.ApplicationId = @ApplicationId
    ORDER BY u.UserName
    RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_GetRolesForUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_GetRolesForUser]
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT  @UserId = UserId
    FROM    dbo.aspnet_Users
    WHERE   LoweredUserName = LOWER(@UserName) AND ApplicationId = @ApplicationId

    IF (@UserId IS NULL)
        RETURN(1)

    SELECT r.RoleName
    FROM   dbo.aspnet_Roles r, dbo.aspnet_UsersInRoles ur
    WHERE  r.RoleId = ur.RoleId AND r.ApplicationId = @ApplicationId AND ur.UserId = @UserId
    ORDER BY r.RoleName
    RETURN (0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_FindUsersInRole]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_FindUsersInRole]
    @ApplicationName  nvarchar(256),
    @RoleName         nvarchar(256),
    @UserNameToMatch  nvarchar(256)
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)
     DECLARE @RoleId uniqueidentifier
     SELECT  @RoleId = NULL

     SELECT  @RoleId = RoleId
     FROM    dbo.aspnet_Roles
     WHERE   LOWER(@RoleName) = LoweredRoleName AND ApplicationId = @ApplicationId

     IF (@RoleId IS NULL)
         RETURN(1)

    SELECT u.UserName
    FROM   dbo.aspnet_Users u, dbo.aspnet_UsersInRoles ur
    WHERE  u.UserId = ur.UserId AND @RoleId = ur.RoleId AND u.ApplicationId = @ApplicationId AND LoweredUserName LIKE LOWER(@UserNameToMatch)
    ORDER BY u.UserName
    RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles_AddUsersToRoles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_UsersInRoles_AddUsersToRoles]
	@ApplicationName  nvarchar(256),
	@UserNames		  nvarchar(4000),
	@RoleNames		  nvarchar(4000),
	@CurrentTimeUtc   datetime
AS
BEGIN
	DECLARE @AppId uniqueidentifier
	SELECT  @AppId = NULL
	SELECT  @AppId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
	IF (@AppId IS NULL)
		RETURN(2)
	DECLARE @TranStarted   bit
	SET @TranStarted = 0

	IF( @@TRANCOUNT = 0 )
	BEGIN
		BEGIN TRANSACTION
		SET @TranStarted = 1
	END

	DECLARE @tbNames	table(Name nvarchar(256) NOT NULL PRIMARY KEY)
	DECLARE @tbRoles	table(RoleId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @tbUsers	table(UserId uniqueidentifier NOT NULL PRIMARY KEY)
	DECLARE @Num		int
	DECLARE @Pos		int
	DECLARE @NextPos	int
	DECLARE @Name		nvarchar(256)

	SET @Num = 0
	SET @Pos = 1
	WHILE(@Pos <= LEN(@RoleNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @RoleNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@RoleNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@RoleNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbRoles
	  SELECT RoleId
	  FROM   dbo.aspnet_Roles ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredRoleName AND ar.ApplicationId = @AppId

	IF (@@ROWCOUNT <> @Num)
	BEGIN
		SELECT TOP 1 Name
		FROM   @tbNames
		WHERE  LOWER(Name) NOT IN (SELECT ar.LoweredRoleName FROM dbo.aspnet_Roles ar,  @tbRoles r WHERE r.RoleId = ar.RoleId)
		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(2)
	END

	DELETE FROM @tbNames WHERE 1=1
	SET @Num = 0
	SET @Pos = 1

	WHILE(@Pos <= LEN(@UserNames))
	BEGIN
		SELECT @NextPos = CHARINDEX(N'','', @UserNames,  @Pos)
		IF (@NextPos = 0 OR @NextPos IS NULL)
			SELECT @NextPos = LEN(@UserNames) + 1
		SELECT @Name = RTRIM(LTRIM(SUBSTRING(@UserNames, @Pos, @NextPos - @Pos)))
		SELECT @Pos = @NextPos+1

		INSERT INTO @tbNames VALUES (@Name)
		SET @Num = @Num + 1
	END

	INSERT INTO @tbUsers
	  SELECT UserId
	  FROM   dbo.aspnet_Users ar, @tbNames t
	  WHERE  LOWER(t.Name) = ar.LoweredUserName AND ar.ApplicationId = @AppId

	IF (@@ROWCOUNT <> @Num)
	BEGIN
		DELETE FROM @tbNames
		WHERE LOWER(Name) IN (SELECT LoweredUserName FROM dbo.aspnet_Users au,  @tbUsers u WHERE au.UserId = u.UserId)

		INSERT dbo.aspnet_Users (ApplicationId, UserId, UserName, LoweredUserName, IsAnonymous, LastActivityDate)
		  SELECT @AppId, NEWID(), Name, LOWER(Name), 0, @CurrentTimeUtc
		  FROM   @tbNames

		INSERT INTO @tbUsers
		  SELECT  UserId
		  FROM	dbo.aspnet_Users au, @tbNames t
		  WHERE   LOWER(t.Name) = au.LoweredUserName AND au.ApplicationId = @AppId
	END

	IF (EXISTS (SELECT * FROM dbo.aspnet_UsersInRoles ur, @tbUsers tu, @tbRoles tr WHERE tu.UserId = ur.UserId AND tr.RoleId = ur.RoleId))
	BEGIN
		SELECT TOP 1 UserName, RoleName
		FROM		 dbo.aspnet_UsersInRoles ur, @tbUsers tu, @tbRoles tr, aspnet_Users u, aspnet_Roles r
		WHERE		u.UserId = tu.UserId AND r.RoleId = tr.RoleId AND tu.UserId = ur.UserId AND tr.RoleId = ur.RoleId

		IF( @TranStarted = 1 )
			ROLLBACK TRANSACTION
		RETURN(3)
	END

	INSERT INTO dbo.aspnet_UsersInRoles (UserId, RoleId)
	SELECT UserId, RoleId
	FROM @tbUsers, @tbRoles

	IF( @TranStarted = 1 )
		COMMIT TRANSACTION
	RETURN(0)
END                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     ' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Users_DeleteUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Users_DeleteUser]
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @TablesToDeleteFrom int,
    @NumTablesDeletedFrom int OUTPUT
AS
BEGIN
    DECLARE @UserId               uniqueidentifier
    SELECT  @UserId               = NULL
    SELECT  @NumTablesDeletedFrom = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
	SET @TranStarted = 0

    DECLARE @ErrorCode   int
    DECLARE @RowCount    int

    SET @ErrorCode = 0
    SET @RowCount  = 0

    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a
    WHERE   u.LoweredUserName       = LOWER(@UserName)
        AND u.ApplicationId         = a.ApplicationId
        AND LOWER(@ApplicationName) = a.LoweredApplicationName

    IF (@UserId IS NULL)
    BEGIN
        GOTO Cleanup
    END

    -- Delete from Membership table if (@TablesToDeleteFrom & 1) is set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_MembershipUsers'') AND (type = ''V''))))
    BEGIN
        DELETE FROM dbo.aspnet_Membership WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
               @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_UsersInRoles table if (@TablesToDeleteFrom & 2) is set
    IF ((@TablesToDeleteFrom & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_UsersInRoles'') AND (type = ''V''))) )
    BEGIN
        DELETE FROM dbo.aspnet_UsersInRoles WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Profile table if (@TablesToDeleteFrom & 4) is set
    IF ((@TablesToDeleteFrom & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_Profiles'') AND (type = ''V''))) )
    BEGIN
        DELETE FROM dbo.aspnet_Profile WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_PersonalizationPerUser table if (@TablesToDeleteFrom & 8) is set
    IF ((@TablesToDeleteFrom & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_WebPartState_User'') AND (type = ''V''))) )
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    -- Delete from aspnet_Users table if (@TablesToDeleteFrom & 1,2,4 & 8) are all set
    IF ((@TablesToDeleteFrom & 1) <> 0 AND
        (@TablesToDeleteFrom & 2) <> 0 AND
        (@TablesToDeleteFrom & 4) <> 0 AND
        (@TablesToDeleteFrom & 8) <> 0 AND
        (EXISTS (SELECT UserId FROM dbo.aspnet_Users WHERE @UserId = UserId)))
    BEGIN
        DELETE FROM dbo.aspnet_Users WHERE @UserId = UserId

        SELECT @ErrorCode = @@ERROR,
                @RowCount = @@ROWCOUNT

        IF( @ErrorCode <> 0 )
            GOTO Cleanup

        IF (@RowCount <> 0)
            SELECT  @NumTablesDeletedFrom = @NumTablesDeletedFrom + 1
    END

    IF( @TranStarted = 1 )
    BEGIN
	    SET @TranStarted = 0
	    COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:
    SET @NumTablesDeletedFrom = 0

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
	    ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Roles_DeleteRole]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Roles_DeleteRole]
    @ApplicationName            nvarchar(256),
    @RoleName                   nvarchar(256),
    @DeleteOnlyIfRoleIsEmpty    bit
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN(1)

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
        BEGIN TRANSACTION
        SET @TranStarted = 1
    END
    ELSE
        SET @TranStarted = 0

    DECLARE @RoleId   uniqueidentifier
    SELECT  @RoleId = NULL
    SELECT  @RoleId = RoleId FROM dbo.aspnet_Roles WHERE LoweredRoleName = LOWER(@RoleName) AND ApplicationId = @ApplicationId

    IF (@RoleId IS NULL)
    BEGIN
        SELECT @ErrorCode = 1
        GOTO Cleanup
    END
    IF (@DeleteOnlyIfRoleIsEmpty <> 0)
    BEGIN
        IF (EXISTS (SELECT RoleId FROM dbo.aspnet_UsersInRoles  WHERE @RoleId = RoleId))
        BEGIN
            SELECT @ErrorCode = 2
            GOTO Cleanup
        END
    END


    DELETE FROM dbo.aspnet_UsersInRoles  WHERE @RoleId = RoleId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DELETE FROM dbo.aspnet_Roles WHERE @RoleId = RoleId  AND ApplicationId = @ApplicationId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
        COMMIT TRANSACTION
    END

    RETURN(0)

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
        ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_UpdateUserInfo]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateUserInfo]
    @ApplicationName                nvarchar(256),
    @UserName                       nvarchar(256),
    @IsPasswordCorrect              bit,
    @UpdateLastLoginActivityDate    bit,
    @MaxInvalidPasswordAttempts     int,
    @PasswordAttemptWindow          int,
    @CurrentTimeUtc                 datetime,
    @LastLoginDate                  datetime,
    @LastActivityDate               datetime
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier
    DECLARE @IsApproved                             bit
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId,
            @IsApproved = m.IsApproved,
            @IsLockedOut = m.IsLockedOut,
            @LastLockoutDate = m.LastLockoutDate,
            @FailedPasswordAttemptCount = m.FailedPasswordAttemptCount,
            @FailedPasswordAttemptWindowStart = m.FailedPasswordAttemptWindowStart,
            @FailedPasswordAnswerAttemptCount = m.FailedPasswordAnswerAttemptCount,
            @FailedPasswordAnswerAttemptWindowStart = m.FailedPasswordAnswerAttemptWindowStart
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m WITH ( UPDLOCK )
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF ( @@rowcount = 0 )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    IF( @IsLockedOut = 1 )
    BEGIN
        GOTO Cleanup
    END

    IF( @IsPasswordCorrect = 0 )
    BEGIN
        IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAttemptWindowStart ) )
        BEGIN
            SET @FailedPasswordAttemptWindowStart = @CurrentTimeUtc
            SET @FailedPasswordAttemptCount = 1
        END
        ELSE
        BEGIN
            SET @FailedPasswordAttemptWindowStart = @CurrentTimeUtc
            SET @FailedPasswordAttemptCount = @FailedPasswordAttemptCount + 1
        END

        BEGIN
            IF( @FailedPasswordAttemptCount >= @MaxInvalidPasswordAttempts )
            BEGIN
                SET @IsLockedOut = 1
                SET @LastLockoutDate = @CurrentTimeUtc
            END
        END
    END
    ELSE
    BEGIN
        IF( @FailedPasswordAttemptCount > 0 OR @FailedPasswordAnswerAttemptCount > 0 )
        BEGIN
            SET @FailedPasswordAttemptCount = 0
            SET @FailedPasswordAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )
            SET @FailedPasswordAnswerAttemptCount = 0
            SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )
            SET @LastLockoutDate = CONVERT( datetime, ''17540101'', 112 )
        END
    END

    IF( @UpdateLastLoginActivityDate = 1 )
    BEGIN
        UPDATE  dbo.aspnet_Users
        SET     LastActivityDate = @LastActivityDate
        WHERE   @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END

        UPDATE  dbo.aspnet_Membership
        SET     LastLoginDate = @LastLoginDate
        WHERE   UserId = @UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END


    UPDATE dbo.aspnet_Membership
    SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
        FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
        FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
        FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
        FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
    WHERE @UserId = UserId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_UpdateUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_UpdateUser]
    @ApplicationName      nvarchar(256),
    @UserName             nvarchar(256),
    @Email                nvarchar(256),
    @Comment              ntext,
    @IsApproved           bit,
    @LastLoginDate        datetime,
    @LastActivityDate     datetime,
    @UniqueEmail          int,
    @CurrentTimeUtc       datetime
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId, @ApplicationId = a.ApplicationId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF (@UserId IS NULL)
        RETURN(1)

    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.aspnet_Membership WITH (UPDLOCK, HOLDLOCK)
                    WHERE ApplicationId = @ApplicationId  AND @UserId <> UserId AND LoweredEmail = LOWER(@Email)))
        BEGIN
            RETURN(7)
        END
    END

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
	SET @TranStarted = 0

    UPDATE dbo.aspnet_Users WITH (ROWLOCK)
    SET
         LastActivityDate = @LastActivityDate
    WHERE
       @UserId = UserId

    IF( @@ERROR <> 0 )
        GOTO Cleanup

    UPDATE dbo.aspnet_Membership WITH (ROWLOCK)
    SET
         Email            = @Email,
         LoweredEmail     = LOWER(@Email),
         Comment          = @Comment,
         IsApproved       = @IsApproved,
         LastLoginDate    = @LastLoginDate
    WHERE
       @UserId = UserId

    IF( @@ERROR <> 0 )
        GOTO Cleanup

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN -1
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_UnlockUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_UnlockUser]
    @ApplicationName                         nvarchar(256),
    @UserName                                nvarchar(256)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF ( @UserId IS NULL )
        RETURN 1

    UPDATE dbo.aspnet_Membership
    SET IsLockedOut = 0,
        FailedPasswordAttemptCount = 0,
        FailedPasswordAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 ),
        FailedPasswordAnswerAttemptCount = 0,
        FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 ),
        LastLockoutDate = CONVERT( datetime, ''17540101'', 112 )
    WHERE @UserId = UserId

    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_SetPassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_SetPassword]
    @ApplicationName  nvarchar(256),
    @UserName         nvarchar(256),
    @NewPassword      nvarchar(128),
    @PasswordSalt     nvarchar(128),
    @CurrentTimeUtc   datetime,
    @PasswordFormat   int = 0
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF (@UserId IS NULL)
        RETURN(1)

    UPDATE dbo.aspnet_Membership
    SET Password = @NewPassword, PasswordFormat = @PasswordFormat, PasswordSalt = @PasswordSalt,
        LastPasswordChangedDate = @CurrentTimeUtc
    WHERE @UserId = UserId
    RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_ResetPassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_ResetPassword]
    @ApplicationName             nvarchar(256),
    @UserName                    nvarchar(256),
    @NewPassword                 nvarchar(128),
    @MaxInvalidPasswordAttempts  int,
    @PasswordAttemptWindow       int,
    @PasswordSalt                nvarchar(128),
    @CurrentTimeUtc              datetime,
    @PasswordFormat              int = 0,
    @PasswordAnswer              nvarchar(128) = NULL
AS
BEGIN
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @UserId                                 uniqueidentifier
    SET     @UserId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Users u, dbo.aspnet_Applications a, dbo.aspnet_Membership m
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId

    IF ( @UserId IS NULL )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    SELECT @IsLockedOut = IsLockedOut,
           @LastLockoutDate = LastLockoutDate,
           @FailedPasswordAttemptCount = FailedPasswordAttemptCount,
           @FailedPasswordAttemptWindowStart = FailedPasswordAttemptWindowStart,
           @FailedPasswordAnswerAttemptCount = FailedPasswordAnswerAttemptCount,
           @FailedPasswordAnswerAttemptWindowStart = FailedPasswordAnswerAttemptWindowStart
    FROM dbo.aspnet_Membership WITH ( UPDLOCK )
    WHERE @UserId = UserId

    IF( @IsLockedOut = 1 )
    BEGIN
        SET @ErrorCode = 99
        GOTO Cleanup
    END

    UPDATE dbo.aspnet_Membership
    SET    Password = @NewPassword,
           LastPasswordChangedDate = @CurrentTimeUtc,
           PasswordFormat = @PasswordFormat,
           PasswordSalt = @PasswordSalt
    WHERE  @UserId = UserId AND
           ( ( @PasswordAnswer IS NULL ) OR ( LOWER( PasswordAnswer ) = LOWER( @PasswordAnswer ) ) )

    IF ( @@ROWCOUNT = 0 )
        BEGIN
            IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAnswerAttemptWindowStart ) )
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = 1
            END
            ELSE
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount + 1
            END

            BEGIN
                IF( @FailedPasswordAnswerAttemptCount >= @MaxInvalidPasswordAttempts )
                BEGIN
                    SET @IsLockedOut = 1
                    SET @LastLockoutDate = @CurrentTimeUtc
                END
            END

            SET @ErrorCode = 3
        END
    ELSE
        BEGIN
            IF( @FailedPasswordAnswerAttemptCount > 0 )
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = 0
                SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )
            END
        END

    IF( NOT ( @PasswordAnswer IS NULL ) )
    BEGIN
        UPDATE dbo.aspnet_Membership
        SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
            FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
            FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
            FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
            FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
        WHERE @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetUserByUserId]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByUserId]
    @UserId               uniqueidentifier,
    @CurrentTimeUtc       datetime,
    @UpdateLastActivity   bit = 0
AS
BEGIN
    IF ( @UpdateLastActivity = 1 )
    BEGIN
        UPDATE   dbo.aspnet_Users
        SET      LastActivityDate = @CurrentTimeUtc
        FROM     dbo.aspnet_Users
        WHERE    @UserId = UserId

        IF ( @@ROWCOUNT = 0 ) -- User ID not found
            RETURN -1
    END

    SELECT  m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate, m.LastLoginDate, u.LastActivityDate,
            m.LastPasswordChangedDate, u.UserName, m.IsLockedOut,
            m.LastLockoutDate
    FROM    dbo.aspnet_Users u, dbo.aspnet_Membership m
    WHERE   @UserId = u.UserId AND u.UserId = m.UserId

    IF ( @@ROWCOUNT = 0 ) -- User ID not found
       RETURN -1

    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetUserByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByName]
    @ApplicationName      nvarchar(256),
    @UserName             nvarchar(256),
    @CurrentTimeUtc       datetime,
    @UpdateLastActivity   bit = 0
AS
BEGIN
    DECLARE @UserId uniqueidentifier

    IF (@UpdateLastActivity = 1)
    BEGIN
        -- select user ID from aspnet_users table
        SELECT TOP 1 @UserId = u.UserId
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE    LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                LOWER(@UserName) = u.LoweredUserName AND u.UserId = m.UserId

        IF (@@ROWCOUNT = 0) -- Username not found
            RETURN -1

        UPDATE   dbo.aspnet_Users
        SET      LastActivityDate = @CurrentTimeUtc
        WHERE    @UserId = UserId

        SELECT m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
                m.CreateDate, m.LastLoginDate, u.LastActivityDate, m.LastPasswordChangedDate,
                u.UserId, m.IsLockedOut, m.LastLockoutDate
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE  @UserId = u.UserId AND u.UserId = m.UserId 
    END
    ELSE
    BEGIN
        SELECT TOP 1 m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
                m.CreateDate, m.LastLoginDate, u.LastActivityDate, m.LastPasswordChangedDate,
                u.UserId, m.IsLockedOut,m.LastLockoutDate
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE    LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                LOWER(@UserName) = u.LoweredUserName AND u.UserId = m.UserId

        IF (@@ROWCOUNT = 0) -- Username not found
            RETURN -1
    END

    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetUserByEmail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetUserByEmail]
    @ApplicationName  nvarchar(256),
    @Email            nvarchar(256)
AS
BEGIN
    IF( @Email IS NULL )
        SELECT  u.UserName
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                u.UserId = m.UserId AND
                m.ApplicationId = a.ApplicationId AND
                m.LoweredEmail IS NULL
    ELSE
        SELECT  u.UserName
        FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
                u.ApplicationId = a.ApplicationId    AND
                u.UserId = m.UserId AND
                m.ApplicationId = a.ApplicationId AND
                LOWER(@Email) = m.LoweredEmail

    IF (@@rowcount = 0)
        RETURN(1)
    RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetPasswordWithFormat]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetPasswordWithFormat]
    @ApplicationName                nvarchar(256),
    @UserName                       nvarchar(256),
    @UpdateLastLoginActivityDate    bit,
    @CurrentTimeUtc                 datetime
AS
BEGIN
    DECLARE @IsLockedOut                        bit
    DECLARE @UserId                             uniqueidentifier
    DECLARE @Password                           nvarchar(128)
    DECLARE @PasswordSalt                       nvarchar(128)
    DECLARE @PasswordFormat                     int
    DECLARE @FailedPasswordAttemptCount         int
    DECLARE @FailedPasswordAnswerAttemptCount   int
    DECLARE @IsApproved                         bit
    DECLARE @LastActivityDate                   datetime
    DECLARE @LastLoginDate                      datetime

    SELECT  @UserId          = NULL

    SELECT  @UserId = u.UserId, @IsLockedOut = m.IsLockedOut, @Password=Password, @PasswordFormat=PasswordFormat,
            @PasswordSalt=PasswordSalt, @FailedPasswordAttemptCount=FailedPasswordAttemptCount,
		    @FailedPasswordAnswerAttemptCount=FailedPasswordAnswerAttemptCount, @IsApproved=IsApproved,
            @LastActivityDate = LastActivityDate, @LastLoginDate = LastLoginDate
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF (@UserId IS NULL)
        RETURN 1

    IF (@IsLockedOut = 1)
        RETURN 99

    SELECT   @Password, @PasswordFormat, @PasswordSalt, @FailedPasswordAttemptCount,
             @FailedPasswordAnswerAttemptCount, @IsApproved, @LastLoginDate, @LastActivityDate

    IF (@UpdateLastLoginActivityDate = 1 AND @IsApproved = 1)
    BEGIN
        UPDATE  dbo.aspnet_Membership
        SET     LastLoginDate = @CurrentTimeUtc
        WHERE   UserId = @UserId

        UPDATE  dbo.aspnet_Users
        SET     LastActivityDate = @CurrentTimeUtc
        WHERE   @UserId = UserId
    END


    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetPassword]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetPassword]
    @ApplicationName                nvarchar(256),
    @UserName                       nvarchar(256),
    @MaxInvalidPasswordAttempts     int,
    @PasswordAttemptWindow          int,
    @CurrentTimeUtc                 datetime,
    @PasswordAnswer                 nvarchar(128) = NULL
AS
BEGIN
    DECLARE @UserId                                 uniqueidentifier
    DECLARE @PasswordFormat                         int
    DECLARE @Password                               nvarchar(128)
    DECLARE @passAns                                nvarchar(128)
    DECLARE @IsLockedOut                            bit
    DECLARE @LastLockoutDate                        datetime
    DECLARE @FailedPasswordAttemptCount             int
    DECLARE @FailedPasswordAttemptWindowStart       datetime
    DECLARE @FailedPasswordAnswerAttemptCount       int
    DECLARE @FailedPasswordAnswerAttemptWindowStart datetime

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    SELECT  @UserId = u.UserId,
            @Password = m.Password,
            @passAns = m.PasswordAnswer,
            @PasswordFormat = m.PasswordFormat,
            @IsLockedOut = m.IsLockedOut,
            @LastLockoutDate = m.LastLockoutDate,
            @FailedPasswordAttemptCount = m.FailedPasswordAttemptCount,
            @FailedPasswordAttemptWindowStart = m.FailedPasswordAttemptWindowStart,
            @FailedPasswordAnswerAttemptCount = m.FailedPasswordAnswerAttemptCount,
            @FailedPasswordAnswerAttemptWindowStart = m.FailedPasswordAnswerAttemptWindowStart
    FROM    dbo.aspnet_Applications a, dbo.aspnet_Users u, dbo.aspnet_Membership m WITH ( UPDLOCK )
    WHERE   LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.ApplicationId = a.ApplicationId    AND
            u.UserId = m.UserId AND
            LOWER(@UserName) = u.LoweredUserName

    IF ( @@rowcount = 0 )
    BEGIN
        SET @ErrorCode = 1
        GOTO Cleanup
    END

    IF( @IsLockedOut = 1 )
    BEGIN
        SET @ErrorCode = 99
        GOTO Cleanup
    END

    IF ( NOT( @PasswordAnswer IS NULL ) )
    BEGIN
        IF( ( @passAns IS NULL ) OR ( LOWER( @passAns ) <> LOWER( @PasswordAnswer ) ) )
        BEGIN
            IF( @CurrentTimeUtc > DATEADD( minute, @PasswordAttemptWindow, @FailedPasswordAnswerAttemptWindowStart ) )
            BEGIN
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
                SET @FailedPasswordAnswerAttemptCount = 1
            END
            ELSE
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount + 1
                SET @FailedPasswordAnswerAttemptWindowStart = @CurrentTimeUtc
            END

            BEGIN
                IF( @FailedPasswordAnswerAttemptCount >= @MaxInvalidPasswordAttempts )
                BEGIN
                    SET @IsLockedOut = 1
                    SET @LastLockoutDate = @CurrentTimeUtc
                END
            END

            SET @ErrorCode = 3
        END
        ELSE
        BEGIN
            IF( @FailedPasswordAnswerAttemptCount > 0 )
            BEGIN
                SET @FailedPasswordAnswerAttemptCount = 0
                SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )
            END
        END

        UPDATE dbo.aspnet_Membership
        SET IsLockedOut = @IsLockedOut, LastLockoutDate = @LastLockoutDate,
            FailedPasswordAttemptCount = @FailedPasswordAttemptCount,
            FailedPasswordAttemptWindowStart = @FailedPasswordAttemptWindowStart,
            FailedPasswordAnswerAttemptCount = @FailedPasswordAnswerAttemptCount,
            FailedPasswordAnswerAttemptWindowStart = @FailedPasswordAnswerAttemptWindowStart
        WHERE @UserId = UserId

        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    IF( @TranStarted = 1 )
    BEGIN
	SET @TranStarted = 0
	COMMIT TRANSACTION
    END

    IF( @ErrorCode = 0 )
        SELECT @Password, @PasswordFormat

    RETURN @ErrorCode

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetNumberOfUsersOnline]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetNumberOfUsersOnline]
    @ApplicationName            nvarchar(256),
    @MinutesSinceLastInActive   int,
    @CurrentTimeUtc             datetime
AS
BEGIN
    DECLARE @DateActive datetime
    SELECT  @DateActive = DATEADD(minute,  -(@MinutesSinceLastInActive), @CurrentTimeUtc)

    DECLARE @NumOnline int
    SELECT  @NumOnline = COUNT(*)
    FROM    dbo.aspnet_Users u(NOLOCK),
            dbo.aspnet_Applications a(NOLOCK),
            dbo.aspnet_Membership m(NOLOCK)
    WHERE   u.ApplicationId = a.ApplicationId                  AND
            LastActivityDate > @DateActive                     AND
            a.LoweredApplicationName = LOWER(@ApplicationName) AND
            u.UserId = m.UserId
    RETURN(@NumOnline)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_GetAllUsers]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_GetAllUsers]
    @ApplicationName       nvarchar(256),
    @PageIndex             int,
    @PageSize              int
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0


    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
    SELECT u.UserId
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u
    WHERE  u.ApplicationId = @ApplicationId AND u.UserId = m.UserId
    ORDER BY u.UserName

    SELECT @TotalRecords = @@ROWCOUNT

    SELECT u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY u.UserName
    RETURN @TotalRecords
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_FindUsersByName]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_FindUsersByName]
    @ApplicationName       nvarchar(256),
    @UserNameToMatch       nvarchar(256),
    @PageIndex             int,
    @PageSize              int
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
        SELECT u.UserId
        FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
        WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND u.LoweredUserName LIKE LOWER(@UserNameToMatch)
        ORDER BY u.UserName


    SELECT  u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY u.UserName

    SELECT  @TotalRecords = COUNT(*)
    FROM    #PageIndexForUsers
    RETURN @TotalRecords
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_FindUsersByEmail]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_FindUsersByEmail]
    @ApplicationName       nvarchar(256),
    @EmailToMatch          nvarchar(256),
    @PageIndex             int,
    @PageSize              int
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN 0

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    IF( @EmailToMatch IS NULL )
        INSERT INTO #PageIndexForUsers (UserId)
            SELECT u.UserId
            FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
            WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND m.Email IS NULL
            ORDER BY m.LoweredEmail
    ELSE
        INSERT INTO #PageIndexForUsers (UserId)
            SELECT u.UserId
            FROM   dbo.aspnet_Users u, dbo.aspnet_Membership m
            WHERE  u.ApplicationId = @ApplicationId AND m.UserId = u.UserId AND m.LoweredEmail LIKE LOWER(@EmailToMatch)
            ORDER BY m.LoweredEmail

    SELECT  u.UserName, m.Email, m.PasswordQuestion, m.Comment, m.IsApproved,
            m.CreateDate,
            m.LastLoginDate,
            u.LastActivityDate,
            m.LastPasswordChangedDate,
            u.UserId, m.IsLockedOut,
            m.LastLockoutDate
    FROM   dbo.aspnet_Membership m, dbo.aspnet_Users u, #PageIndexForUsers p
    WHERE  u.UserId = p.UserId AND u.UserId = m.UserId AND
           p.IndexId >= @PageLowerBound AND p.IndexId <= @PageUpperBound
    ORDER BY m.LoweredEmail

    SELECT  @TotalRecords = COUNT(*)
    FROM    #PageIndexForUsers
    RETURN @TotalRecords
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_CreateUser]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_CreateUser]
    @ApplicationName                        nvarchar(256),
    @UserName                               nvarchar(256),
    @Password                               nvarchar(128),
    @PasswordSalt                           nvarchar(128),
    @Email                                  nvarchar(256),
    @PasswordQuestion                       nvarchar(256),
    @PasswordAnswer                         nvarchar(128),
    @IsApproved                             bit,
    @CurrentTimeUtc                         datetime,
    @CreateDate                             datetime = NULL,
    @UniqueEmail                            int      = 0,
    @PasswordFormat                         int      = 0,
    @UserId                                 uniqueidentifier OUTPUT
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @NewUserId uniqueidentifier
    SELECT @NewUserId = NULL

    DECLARE @IsLockedOut bit
    SET @IsLockedOut = 0

    DECLARE @LastLockoutDate  datetime
    SET @LastLockoutDate = CONVERT( datetime, ''17540101'', 112 )

    DECLARE @FailedPasswordAttemptCount int
    SET @FailedPasswordAttemptCount = 0

    DECLARE @FailedPasswordAttemptWindowStart  datetime
    SET @FailedPasswordAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )

    DECLARE @FailedPasswordAnswerAttemptCount int
    SET @FailedPasswordAnswerAttemptCount = 0

    DECLARE @FailedPasswordAnswerAttemptWindowStart  datetime
    SET @FailedPasswordAnswerAttemptWindowStart = CONVERT( datetime, ''17540101'', 112 )

    DECLARE @NewUserCreated bit
    DECLARE @ReturnValue   int
    SET @ReturnValue = 0

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
	    BEGIN TRANSACTION
	    SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    SET @CreateDate = @CurrentTimeUtc

    SELECT  @NewUserId = UserId FROM dbo.aspnet_Users WHERE LOWER(@UserName) = LoweredUserName AND @ApplicationId = ApplicationId
    IF ( @NewUserId IS NULL )
    BEGIN
        SET @NewUserId = @UserId
        EXEC @ReturnValue = dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, 0, @CreateDate, @NewUserId OUTPUT
        SET @NewUserCreated = 1
    END
    ELSE
    BEGIN
        SET @NewUserCreated = 0
        IF( @NewUserId <> @UserId AND @UserId IS NOT NULL )
        BEGIN
            SET @ErrorCode = 6
            GOTO Cleanup
        END
    END

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @ReturnValue = -1 )
    BEGIN
        SET @ErrorCode = 10
        GOTO Cleanup
    END

    IF ( EXISTS ( SELECT UserId
                  FROM   dbo.aspnet_Membership
                  WHERE  @NewUserId = UserId ) )
    BEGIN
        SET @ErrorCode = 6
        GOTO Cleanup
    END

    SET @UserId = @NewUserId

    IF (@UniqueEmail = 1)
    BEGIN
        IF (EXISTS (SELECT *
                    FROM  dbo.aspnet_Membership m WITH ( UPDLOCK, HOLDLOCK )
                    WHERE ApplicationId = @ApplicationId AND LoweredEmail = LOWER(@Email)))
        BEGIN
            SET @ErrorCode = 7
            GOTO Cleanup
        END
    END

    IF (@NewUserCreated = 0)
    BEGIN
        UPDATE dbo.aspnet_Users
        SET    LastActivityDate = @CreateDate
        WHERE  @UserId = UserId
        IF( @@ERROR <> 0 )
        BEGIN
            SET @ErrorCode = -1
            GOTO Cleanup
        END
    END

    INSERT INTO dbo.aspnet_Membership
                ( ApplicationId,
                  UserId,
                  Password,
                  PasswordSalt,
                  Email,
                  LoweredEmail,
                  PasswordQuestion,
                  PasswordAnswer,
                  PasswordFormat,
                  IsApproved,
                  IsLockedOut,
                  CreateDate,
                  LastLoginDate,
                  LastPasswordChangedDate,
                  LastLockoutDate,
                  FailedPasswordAttemptCount,
                  FailedPasswordAttemptWindowStart,
                  FailedPasswordAnswerAttemptCount,
                  FailedPasswordAnswerAttemptWindowStart )
         VALUES ( @ApplicationId,
                  @UserId,
                  @Password,
                  @PasswordSalt,
                  @Email,
                  LOWER(@Email),
                  @PasswordQuestion,
                  @PasswordAnswer,
                  @PasswordFormat,
                  @IsApproved,
                  @IsLockedOut,
                  @CreateDate,
                  @CreateDate,
                  @CreateDate,
                  @LastLockoutDate,
                  @FailedPasswordAttemptCount,
                  @FailedPasswordAttemptWindowStart,
                  @FailedPasswordAnswerAttemptCount,
                  @FailedPasswordAnswerAttemptWindowStart )

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
	    SET @TranStarted = 0
	    COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_Membership_ChangePasswordQuestionAndAnswer]
    @ApplicationName       nvarchar(256),
    @UserName              nvarchar(256),
    @NewPasswordQuestion   nvarchar(256),
    @NewPasswordAnswer     nvarchar(128)
AS
BEGIN
    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL
    SELECT  @UserId = u.UserId
    FROM    dbo.aspnet_Membership m, dbo.aspnet_Users u, dbo.aspnet_Applications a
    WHERE   LoweredUserName = LOWER(@UserName) AND
            u.ApplicationId = a.ApplicationId  AND
            LOWER(@ApplicationName) = a.LoweredApplicationName AND
            u.UserId = m.UserId
    IF (@UserId IS NULL)
    BEGIN
        RETURN(1)
    END

    UPDATE dbo.aspnet_Membership
    SET    PasswordQuestion = @NewPasswordQuestion, PasswordAnswer = @NewPasswordAnswer
    WHERE  UserId=@UserId
    RETURN(0)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_AnyDataInTables]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_AnyDataInTables]
    @TablesToCheck int
AS
BEGIN
    -- Check Membership table if (@TablesToCheck & 1) is set
    IF ((@TablesToCheck & 1) <> 0 AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_MembershipUsers'') AND (type = ''V''))))
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Membership))
        BEGIN
            SELECT N''aspnet_Membership''
            RETURN
        END
    END

    -- Check aspnet_Roles table if (@TablesToCheck & 2) is set
    IF ((@TablesToCheck & 2) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_Roles'') AND (type = ''V''))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 RoleId FROM dbo.aspnet_Roles))
        BEGIN
            SELECT N''aspnet_Roles''
            RETURN
        END
    END

    -- Check aspnet_Profile table if (@TablesToCheck & 4) is set
    IF ((@TablesToCheck & 4) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_Profiles'') AND (type = ''V''))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Profile))
        BEGIN
            SELECT N''aspnet_Profile''
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 8) is set
    IF ((@TablesToCheck & 8) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''vw_aspnet_WebPartState_User'') AND (type = ''V''))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_PersonalizationPerUser))
        BEGIN
            SELECT N''aspnet_PersonalizationPerUser''
            RETURN
        END
    END

    -- Check aspnet_PersonalizationPerUser table if (@TablesToCheck & 16) is set
    IF ((@TablesToCheck & 16) <> 0  AND
        (EXISTS (SELECT name FROM sysobjects WHERE (name = N''aspnet_WebEvent_LogEvent'') AND (type = ''P''))) )
    BEGIN
        IF (EXISTS(SELECT TOP 1 * FROM dbo.aspnet_WebEvent_Events))
        BEGIN
            SELECT N''aspnet_WebEvent_Events''
            RETURN
        END
    END

    -- Check aspnet_Users table if (@TablesToCheck & 1,2,4 & 8) are all set
    IF ((@TablesToCheck & 1) <> 0 AND
        (@TablesToCheck & 2) <> 0 AND
        (@TablesToCheck & 4) <> 0 AND
        (@TablesToCheck & 8) <> 0 AND
        (@TablesToCheck & 32) <> 0 AND
        (@TablesToCheck & 128) <> 0 AND
        (@TablesToCheck & 256) <> 0 AND
        (@TablesToCheck & 512) <> 0 AND
        (@TablesToCheck & 1024) <> 0)
    BEGIN
        IF (EXISTS(SELECT TOP 1 UserId FROM dbo.aspnet_Users))
        BEGIN
            SELECT N''aspnet_Users''
            RETURN
        END
        IF (EXISTS(SELECT TOP 1 ApplicationId FROM dbo.aspnet_Applications))
        BEGIN
            SELECT N''aspnet_Applications''
            RETURN
        END
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAdministration_ResetUserState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetUserState] (
    @Count                  int                 OUT,
    @ApplicationName        NVARCHAR(256),
    @InactiveSinceDate      DATETIME            = NULL,
    @UserName               NVARCHAR(256)       = NULL,
    @Path                   NVARCHAR(256)       = NULL)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationPerUser
        WHERE Id IN (SELECT PerUser.Id
                     FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
                     WHERE Paths.ApplicationId = @ApplicationId
                           AND PerUser.UserId = Users.UserId
                           AND PerUser.PathId = Paths.PathId
                           AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
                           AND (@UserName IS NULL OR Users.LoweredUserName = LOWER(@UserName))
                           AND (@Path IS NULL OR Paths.LoweredPath = LOWER(@Path)))

        SELECT @Count = @@ROWCOUNT
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAdministration_ResetSharedState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_ResetSharedState] (
    @Count int OUT,
    @ApplicationName NVARCHAR(256),
    @Path NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        DELETE FROM dbo.aspnet_PersonalizationAllUsers
        WHERE PathId IN
            (SELECT AllUsers.PathId
             FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
             WHERE Paths.ApplicationId = @ApplicationId
                   AND AllUsers.PathId = Paths.PathId
                   AND Paths.LoweredPath = LOWER(@Path))

        SELECT @Count = @@ROWCOUNT
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAdministration_GetCountOfState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_GetCountOfState] (
    @Count int OUT,
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @Path NVARCHAR(256) = NULL,
    @UserName NVARCHAR(256) = NULL,
    @InactiveSinceDate DATETIME = NULL)
AS
BEGIN

    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
        IF (@AllUsersScope = 1)
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND AllUsers.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
        ELSE
            SELECT @Count = COUNT(*)
            FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
            WHERE Paths.ApplicationId = @ApplicationId
                  AND PerUser.UserId = Users.UserId
                  AND PerUser.PathId = Paths.PathId
                  AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
                  AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
                  AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAdministration_FindState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_FindState] (
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @PageIndex              INT,
    @PageSize               INT,
    @Path NVARCHAR(256) = NULL,
    @UserName NVARCHAR(256) = NULL,
    @InactiveSinceDate DATETIME = NULL)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound INT
    DECLARE @PageUpperBound INT
    DECLARE @TotalRecords   INT
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table to store the selected results
    CREATE TABLE #PageIndex (
        IndexId int IDENTITY (0, 1) NOT NULL,
        ItemId UNIQUEIDENTIFIER
    )

    IF (@AllUsersScope = 1)
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT Paths.PathId
        FROM dbo.aspnet_Paths Paths,
             ((SELECT Paths.PathId
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND AllUsers.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT DISTINCT Paths.PathId
               FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Paths Paths
               WHERE Paths.ApplicationId = @ApplicationId
                      AND PerUser.PathId = Paths.PathId
                      AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path,
               SharedDataPerPath.LastUpdatedDate,
               SharedDataPerPath.SharedDataLength,
               UserDataPerPath.UserDataLength,
               UserDataPerPath.UserCount
        FROM dbo.aspnet_Paths Paths,
             ((SELECT PageIndex.ItemId AS PathId,
                      AllUsers.LastUpdatedDate AS LastUpdatedDate,
                      DATALENGTH(AllUsers.PageSettings) AS SharedDataLength
               FROM dbo.aspnet_PersonalizationAllUsers AllUsers, #PageIndex PageIndex
               WHERE AllUsers.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
              ) AS SharedDataPerPath
              FULL OUTER JOIN
              (SELECT PageIndex.ItemId AS PathId,
                      SUM(DATALENGTH(PerUser.PageSettings)) AS UserDataLength,
                      COUNT(*) AS UserCount
               FROM aspnet_PersonalizationPerUser PerUser, #PageIndex PageIndex
               WHERE PerUser.PathId = PageIndex.ItemId
                     AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
               GROUP BY PageIndex.ItemId
              ) AS UserDataPerPath
              ON SharedDataPerPath.PathId = UserDataPerPath.PathId
             )
        WHERE Paths.PathId = SharedDataPerPath.PathId OR Paths.PathId = UserDataPerPath.PathId
        ORDER BY Paths.Path ASC
    END
    ELSE
    BEGIN
        -- Insert into our temp table
        INSERT INTO #PageIndex (ItemId)
        SELECT PerUser.Id
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths
        WHERE Paths.ApplicationId = @ApplicationId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND (@Path IS NULL OR Paths.LoweredPath LIKE LOWER(@Path))
              AND (@UserName IS NULL OR Users.LoweredUserName LIKE LOWER(@UserName))
              AND (@InactiveSinceDate IS NULL OR Users.LastActivityDate <= @InactiveSinceDate)
        ORDER BY Paths.Path ASC, Users.UserName ASC

        SELECT @TotalRecords = @@ROWCOUNT

        SELECT Paths.Path, PerUser.LastUpdatedDate, DATALENGTH(PerUser.PageSettings), Users.UserName, Users.LastActivityDate
        FROM dbo.aspnet_PersonalizationPerUser PerUser, dbo.aspnet_Users Users, dbo.aspnet_Paths Paths, #PageIndex PageIndex
        WHERE PerUser.Id = PageIndex.ItemId
              AND PerUser.UserId = Users.UserId
              AND PerUser.PathId = Paths.PathId
              AND PageIndex.IndexId >= @PageLowerBound AND PageIndex.IndexId <= @PageUpperBound
        ORDER BY Paths.Path ASC, Users.UserName ASC
    END

    RETURN @TotalRecords
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAdministration_DeleteAllState]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAdministration_DeleteAllState] (
    @AllUsersScope bit,
    @ApplicationName NVARCHAR(256),
    @Count int OUT)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
        SELECT @Count = 0
    ELSE
    BEGIN
        IF (@AllUsersScope = 1)
            DELETE FROM aspnet_PersonalizationAllUsers
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)
        ELSE
            DELETE FROM aspnet_PersonalizationPerUser
            WHERE PathId IN
               (SELECT Paths.PathId
                FROM dbo.aspnet_Paths Paths
                WHERE Paths.ApplicationId = @ApplicationId)

        SELECT @Count = @@ROWCOUNT
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser_SetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_SetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @PageSettings     IMAGE,
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, 0, @CurrentTimeUtc, @UserId OUTPUT
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationPerUser WHERE UserId = @UserId AND PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationPerUser SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE UserId = @UserId AND PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationPerUser(UserId, PathId, PageSettings, LastUpdatedDate) VALUES (@UserId, @PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser_ResetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_ResetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    DELETE FROM dbo.aspnet_PersonalizationPerUser WHERE PathId = @PathId AND UserId = @UserId
    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser_GetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationPerUser_GetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @UserName         NVARCHAR(256),
    @Path             NVARCHAR(256),
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER
    DECLARE @UserId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL
    SELECT @UserId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @UserId = u.UserId FROM dbo.aspnet_Users u WHERE u.ApplicationId = @ApplicationId AND u.LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
    BEGIN
        RETURN
    END

    UPDATE   dbo.aspnet_Users WITH (ROWLOCK)
    SET      LastActivityDate = @CurrentTimeUtc
    WHERE    UserId = @UserId
    IF (@@ROWCOUNT = 0) -- Username not found
        RETURN

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationPerUser p WHERE p.PathId = @PathId AND p.UserId = @UserId
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAllUsers_SetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_SetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @Path             NVARCHAR(256),
    @PageSettings     IMAGE,
    @CurrentTimeUtc   DATETIME)
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        EXEC dbo.aspnet_Paths_CreatePath @ApplicationId, @Path, @PathId OUTPUT
    END

    IF (EXISTS(SELECT PathId FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId))
        UPDATE dbo.aspnet_PersonalizationAllUsers SET PageSettings = @PageSettings, LastUpdatedDate = @CurrentTimeUtc WHERE PathId = @PathId
    ELSE
        INSERT INTO dbo.aspnet_PersonalizationAllUsers(PathId, PageSettings, LastUpdatedDate) VALUES (@PathId, @PageSettings, @CurrentTimeUtc)
    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_ResetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @Path              NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    DELETE FROM dbo.aspnet_PersonalizationAllUsers WHERE PathId = @PathId
    RETURN 0
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAllUsers_GetPageSettings]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'CREATE PROCEDURE [dbo].[aspnet_PersonalizationAllUsers_GetPageSettings] (
    @ApplicationName  NVARCHAR(256),
    @Path              NVARCHAR(256))
AS
BEGIN
    DECLARE @ApplicationId UNIQUEIDENTIFIER
    DECLARE @PathId UNIQUEIDENTIFIER

    SELECT @ApplicationId = NULL
    SELECT @PathId = NULL

    EXEC dbo.aspnet_Personalization_GetApplicationId @ApplicationName, @ApplicationId OUTPUT
    IF (@ApplicationId IS NULL)
    BEGIN
        RETURN
    END

    SELECT @PathId = u.PathId FROM dbo.aspnet_Paths u WHERE u.ApplicationId = @ApplicationId AND u.LoweredPath = LOWER(@Path)
    IF (@PathId IS NULL)
    BEGIN
        RETURN
    END

    SELECT p.PageSettings FROM dbo.aspnet_PersonalizationAllUsers p WHERE p.PathId = @PathId
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_SetProperties]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_SetProperties]
    @ApplicationName        nvarchar(256),
    @PropertyNames          ntext,
    @PropertyValuesString   ntext,
    @PropertyValuesBinary   image,
    @UserName               nvarchar(256),
    @IsUserAnonymous        bit,
    @CurrentTimeUtc         datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL

    DECLARE @ErrorCode     int
    SET @ErrorCode = 0

    DECLARE @TranStarted   bit
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
       BEGIN TRANSACTION
       SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    EXEC dbo.aspnet_Applications_CreateApplication @ApplicationName, @ApplicationId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    DECLARE @UserId uniqueidentifier
    DECLARE @LastActivityDate datetime
    SELECT  @UserId = NULL
    SELECT  @LastActivityDate = @CurrentTimeUtc

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)
    IF (@UserId IS NULL)
        EXEC dbo.aspnet_Users_CreateUser @ApplicationId, @UserName, @IsUserAnonymous, @LastActivityDate, @UserId OUTPUT

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    UPDATE dbo.aspnet_Users
    SET    LastActivityDate=@CurrentTimeUtc
    WHERE  UserId = @UserId

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF (EXISTS( SELECT *
               FROM   dbo.aspnet_Profile
               WHERE  UserId = @UserId))
        UPDATE dbo.aspnet_Profile
        SET    PropertyNames=@PropertyNames, PropertyValuesString = @PropertyValuesString,
               PropertyValuesBinary = @PropertyValuesBinary, LastUpdatedDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    ELSE
        INSERT INTO dbo.aspnet_Profile(UserId, PropertyNames, PropertyValuesString, PropertyValuesBinary, LastUpdatedDate)
             VALUES (@UserId, @PropertyNames, @PropertyValuesString, @PropertyValuesBinary, @CurrentTimeUtc)

    IF( @@ERROR <> 0 )
    BEGIN
        SET @ErrorCode = -1
        GOTO Cleanup
    END

    IF( @TranStarted = 1 )
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END

    RETURN 0

Cleanup:

    IF( @TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END

    RETURN @ErrorCode

END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_GetProperties]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_GetProperties]
    @ApplicationName      nvarchar(256),
    @UserName             nvarchar(256),
    @CurrentTimeUtc       datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM dbo.aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    DECLARE @UserId uniqueidentifier
    SELECT  @UserId = NULL

    SELECT @UserId = UserId
    FROM   dbo.aspnet_Users
    WHERE  ApplicationId = @ApplicationId AND LoweredUserName = LOWER(@UserName)

    IF (@UserId IS NULL)
        RETURN
    SELECT TOP 1 PropertyNames, PropertyValuesString, PropertyValuesBinary
    FROM         dbo.aspnet_Profile
    WHERE        UserId = @UserId

    IF (@@ROWCOUNT > 0)
    BEGIN
        UPDATE dbo.aspnet_Users
        SET    LastActivityDate=@CurrentTimeUtc
        WHERE  UserId = @UserId
    END
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_GetProfiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_GetProfiles]
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @PageIndex              int,
    @PageSize               int,
    @UserNameToMatch        nvarchar(256) = NULL,
    @InactiveSinceDate      datetime      = NULL
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
        RETURN

    -- Set the page bounds
    DECLARE @PageLowerBound int
    DECLARE @PageUpperBound int
    DECLARE @TotalRecords   int
    SET @PageLowerBound = @PageSize * @PageIndex
    SET @PageUpperBound = @PageSize - 1 + @PageLowerBound

    -- Create a temp table TO store the select results
    CREATE TABLE #PageIndexForUsers
    (
        IndexId int IDENTITY (0, 1) NOT NULL,
        UserId uniqueidentifier
    )

    -- Insert into our temp table
    INSERT INTO #PageIndexForUsers (UserId)
        SELECT  u.UserId
        FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
        WHERE   ApplicationId = @ApplicationId
            AND u.UserId = p.UserId
            AND (@InactiveSinceDate IS NULL OR LastActivityDate <= @InactiveSinceDate)
            AND (     (@ProfileAuthOptions = 2)
                   OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                   OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
                 )
            AND (@UserNameToMatch IS NULL OR LoweredUserName LIKE LOWER(@UserNameToMatch))
        ORDER BY UserName

    SELECT  u.UserName, u.IsAnonymous, u.LastActivityDate, p.LastUpdatedDate,
            DATALENGTH(p.PropertyNames) + DATALENGTH(p.PropertyValuesString) + DATALENGTH(p.PropertyValuesBinary)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p, #PageIndexForUsers i
    WHERE   u.UserId = p.UserId AND p.UserId = i.UserId AND i.IndexId >= @PageLowerBound AND i.IndexId <= @PageUpperBound

    SELECT COUNT(*)
    FROM   #PageIndexForUsers

    DROP TABLE #PageIndexForUsers
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_GetNumberOfInactiveProfiles]
    @ApplicationName        nvarchar(256),
    @ProfileAuthOptions     int,
    @InactiveSinceDate      datetime
AS
BEGIN
    DECLARE @ApplicationId uniqueidentifier
    SELECT  @ApplicationId = NULL
    SELECT  @ApplicationId = ApplicationId FROM aspnet_Applications WHERE LOWER(@ApplicationName) = LoweredApplicationName
    IF (@ApplicationId IS NULL)
    BEGIN
        SELECT 0
        RETURN
    END

    SELECT  COUNT(*)
    FROM    dbo.aspnet_Users u, dbo.aspnet_Profile p
    WHERE   ApplicationId = @ApplicationId
        AND u.UserId = p.UserId
        AND (LastActivityDate <= @InactiveSinceDate)
        AND (
                (@ProfileAuthOptions = 2)
                OR (@ProfileAuthOptions = 0 AND IsAnonymous = 1)
                OR (@ProfileAuthOptions = 1 AND IsAnonymous = 0)
            )
END' 
END
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER OFF
GO
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[aspnet_Profile_DeleteProfiles]') AND type in (N'P', N'PC'))
BEGIN
EXEC dbo.sp_executesql @statement = N'
CREATE PROCEDURE [dbo].[aspnet_Profile_DeleteProfiles]
    @ApplicationName        nvarchar(256),
    @UserNames              nvarchar(4000)
AS
BEGIN
    DECLARE @UserName     nvarchar(256)
    DECLARE @CurrentPos   int
    DECLARE @NextPos      int
    DECLARE @NumDeleted   int
    DECLARE @DeletedUser  int
    DECLARE @TranStarted  bit
    DECLARE @ErrorCode    int

    SET @ErrorCode = 0
    SET @CurrentPos = 1
    SET @NumDeleted = 0
    SET @TranStarted = 0

    IF( @@TRANCOUNT = 0 )
    BEGIN
        BEGIN TRANSACTION
        SET @TranStarted = 1
    END
    ELSE
    	SET @TranStarted = 0

    WHILE (@CurrentPos <= LEN(@UserNames))
    BEGIN
        SELECT @NextPos = CHARINDEX(N'','', @UserNames,  @CurrentPos)
        IF (@NextPos = 0 OR @NextPos IS NULL)
            SELECT @NextPos = LEN(@UserNames) + 1

        SELECT @UserName = SUBSTRING(@UserNames, @CurrentPos, @NextPos - @CurrentPos)
        SELECT @CurrentPos = @NextPos+1

        IF (LEN(@UserName) > 0)
        BEGIN
            SELECT @DeletedUser = 0
            EXEC dbo.aspnet_Users_DeleteUser @ApplicationName, @UserName, 4, @DeletedUser OUTPUT
            IF( @@ERROR <> 0 )
            BEGIN
                SET @ErrorCode = -1
                GOTO Cleanup
            END
            IF (@DeletedUser <> 0)
                SELECT @NumDeleted = @NumDeleted + 1
        END
    END
    SELECT @NumDeleted
    IF (@TranStarted = 1)
    BEGIN
    	SET @TranStarted = 0
    	COMMIT TRANSACTION
    END
    SET @TranStarted = 0

    RETURN 0

Cleanup:
    IF (@TranStarted = 1 )
    BEGIN
        SET @TranStarted = 0
    	ROLLBACK TRANSACTION
    END
    RETURN @ErrorCode
END' 
END
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Ap__Appli__72C60C4A]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Applications]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Ap__Appli__72C60C4A]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Applications] ADD  DEFAULT (newid()) FOR [ApplicationId]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Me__Passw__0D7A0286]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Membership]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Me__Passw__0D7A0286]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Membership] ADD  DEFAULT ((0)) FOR [PasswordFormat]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Pa__PathI__45BE5BA9]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Paths]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Pa__PathI__45BE5BA9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Paths] ADD  DEFAULT (newid()) FOR [PathId]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Perso__Id__51300E55]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Perso__Id__51300E55]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser] ADD  DEFAULT (newid()) FOR [Id]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Ro__RoleI__2EDAF651]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Roles]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Ro__RoleI__2EDAF651]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Roles] ADD  DEFAULT (newid()) FOR [RoleId]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Us__UserI__787EE5A0]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Users]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Us__UserI__787EE5A0]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT (newid()) FOR [UserId]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Us__Mobil__797309D9]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Users]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Us__Mobil__797309D9]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT (NULL) FOR [MobileAlias]
END


End
GO
IF Not EXISTS (SELECT * FROM sys.default_constraints WHERE object_id = OBJECT_ID(N'[dbo].[DF__aspnet_Us__IsAno__7A672E12]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Users]'))
Begin
IF NOT EXISTS (SELECT * FROM dbo.sysobjects WHERE id = OBJECT_ID(N'[DF__aspnet_Us__IsAno__7A672E12]') AND type = 'D')
BEGIN
ALTER TABLE [dbo].[aspnet_Users] ADD  DEFAULT ((0)) FOR [IsAnonymous]
END


End
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Me__Appli__0B91BA14]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Membership]'))
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Me__UserI__0C85DE4D]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Membership]'))
ALTER TABLE [dbo].[aspnet_Membership]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Pa__Appli__44CA3770]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Paths]'))
ALTER TABLE [dbo].[aspnet_Paths]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Pe__PathI__4C6B5938]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationAllUsers]'))
ALTER TABLE [dbo].[aspnet_PersonalizationAllUsers]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Pe__PathI__5224328E]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]'))
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([PathId])
REFERENCES [dbo].[aspnet_Paths] ([PathId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Pe__UserI__531856C7]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_PersonalizationPerUser]'))
ALTER TABLE [dbo].[aspnet_PersonalizationPerUser]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Pr__UserI__22751F6C]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Profile]'))
ALTER TABLE [dbo].[aspnet_Profile]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Ro__Appli__2DE6D218]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Roles]'))
ALTER TABLE [dbo].[aspnet_Roles]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Us__Appli__778AC167]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_Users]'))
ALTER TABLE [dbo].[aspnet_Users]  WITH CHECK ADD FOREIGN KEY([ApplicationId])
REFERENCES [dbo].[aspnet_Applications] ([ApplicationId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Us__RoleI__3493CFA7]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles]'))
ALTER TABLE [dbo].[aspnet_UsersInRoles]  WITH CHECK ADD FOREIGN KEY([RoleId])
REFERENCES [dbo].[aspnet_Roles] ([RoleId])
GO
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK__aspnet_Us__UserI__339FAB6E]') AND parent_object_id = OBJECT_ID(N'[dbo].[aspnet_UsersInRoles]'))
ALTER TABLE [dbo].[aspnet_UsersInRoles]  WITH CHECK ADD FOREIGN KEY([UserId])
REFERENCES [dbo].[aspnet_Users] ([UserId])
GO

/*-----------------------------------------------------------------------------------------------------------------
	INSERT aspnet_SchemaVersions
-----------------------------------------------------------------------------------------------------------------*/
IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'common' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('common', 1, 1) 

IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'health monitoring' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('health monitoring', 1, 1) 

IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'membership' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('membership', 1, 1) 

IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'personalization' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('personalization', 1, 1) 

IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'profile' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('profile', 1, 1) 

IF NOT EXISTS(SELECT * FROM aspnet_SchemaVersions WHERE Feature = 'role manager' AND CompatibleSchemaVersion = 1 AND IsCurrentVersion = 1)
INSERT INTO aspnet_SchemaVersions (Feature, CompatibleSchemaVersion, IsCurrentVersion) VALUES('role manager', 1, 1)

/*-----------------------------------------------------------------------------------------------------------------
	Grant Permissions of Membership stored procedure to SLIDS_User
-----------------------------------------------------------------------------------------------------------------*/
GRANT EXECUTE ON [dbo].aspnet_AnyDataInTables TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Applications_CreateApplication TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_CheckSchemaVersion TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_ChangePasswordQuestionAndAnswer TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_CreateUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_FindUsersByEmail TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_FindUsersByName TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetAllUsers TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetNumberOfUsersOnline TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetPassword TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetPasswordWithFormat TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetUserByEmail TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetUserByName TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_GetUserByUserId TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_ResetPassword TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_SetPassword TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_UnlockUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_UpdateUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Membership_UpdateUserInfo TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Paths_CreatePath TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Personalization_GetApplicationId TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAdministration_DeleteAllState TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAdministration_FindState TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAdministration_GetCountOfState TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAdministration_ResetSharedState TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAdministration_ResetUserState TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAllUsers_GetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAllUsers_ResetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationAllUsers_SetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationPerUser_GetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationPerUser_ResetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_PersonalizationPerUser_SetPageSettings TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_DeleteInactiveProfiles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_DeleteProfiles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_GetNumberOfInactiveProfiles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_GetProfiles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_GetProperties TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Profile_SetProperties TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_RegisterSchemaVersion TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Roles_CreateRole TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Roles_DeleteRole TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Roles_GetAllRoles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Roles_RoleExists TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Setup_RemoveAllRoleMembers TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Setup_RestorePermissions TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UnRegisterSchemaVersion TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Users_CreateUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_Users_DeleteUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_AddUsersToRoles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_FindUsersInRole TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_GetRolesForUser TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_GetUsersInRoles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_IsUserInRole TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_UsersInRoles_RemoveUsersFromRoles TO [SLIDS_User]
GRANT EXECUTE ON [dbo].aspnet_WebEvent_LogEvent TO [SLIDS_User]



/* Incident Tool */
USE [SLIDS]
GO

IF OBJECT_ID ('dbo.IncidentState', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentState')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentState]
END

CREATE TABLE [dbo].[IncidentState]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentState] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'State of incident (new, in process, closed)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentState'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentState', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentState', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of state' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentState', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentState in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentState', @level2type=N'COLUMN',@level2name=N'Position'
GO


IF OBJECT_ID ('dbo.IncidentProcess', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentProcess')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentProcess]
END

CREATE TABLE [dbo].[IncidentProcess]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentProcess] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Process of incident (Procurement, Transport, Allocation etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentProcess'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentProcess', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentProcess', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of process' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentProcess', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentProcess in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentProcess', @level2type=N'COLUMN',@level2name=N'Position'
GO


IF OBJECT_ID ('dbo.IncidentCategory', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentCategory')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentCategory]
END

CREATE TABLE [dbo].[IncidentCategory]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentCategory] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Category of incident (Software, Hardware, Human error etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentCategory', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentCategory', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentCategory', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentCategory in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentCategory', @level2type=N'COLUMN',@level2name=N'Position'
GO


IF OBJECT_ID ('dbo.IncidentDamageCategory', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentDamageCategory')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentDamageCategory]
END

CREATE TABLE [dbo].[IncidentDamageCategory]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentDamageCategory] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Damage category of incident (minor, moderate, major)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDamageCategory'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDamageCategory', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of damage category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDamageCategory', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of damage category' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDamageCategory', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentDamageCategory in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDamageCategory', @level2type=N'COLUMN',@level2name=N'Position'
GO


IF OBJECT_ID ('dbo.IncidentPotentialDamage', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentPotentialDamage')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentPotentialDamage]
END

CREATE TABLE [dbo].[IncidentPotentialDamage]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentPotentialDamage] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'potential damage from incident (minor, moderate, major)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentPotentialDamage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentPotentialDamage', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of potential damage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentPotentialDamage', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of potential damage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentPotentialDamage', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentPotentialDamage in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentPotentialDamage', @level2type=N'COLUMN',@level2name=N'Position'
GO


IF OBJECT_ID ('dbo.IncidentLikelihoodToRepeat', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentLikelihoodToRepeat')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentLikelihoodToRepeat]
END

CREATE TABLE [dbo].[IncidentLikelihoodToRepeat]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[Value] INT NULL,
	[Position] INT NULL
    CONSTRAINT [PK_IncidentLikelihoodToRepeat] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Likelihood that incident will repeat itself (low, medium, high)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLikelihoodToRepeat'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLikelihoodToRepeat', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of potential damage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLikelihoodToRepeat', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Value of potential damage' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLikelihoodToRepeat', @level2type=N'COLUMN',@level2name=N'Value'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Position of IncidentPotentialDamage in List' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLikelihoodToRepeat', @level2type=N'COLUMN',@level2name=N'Position'
GO

--------------------------------------------------------------------------------------------------------------------------------------------------
IF OBJECT_ID ('dbo.Incident', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.Incident')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[Incident]
END

CREATE TABLE [dbo].[Incident](
	[ID] INT IDENTITY(1,1) NOT NULL,
	[OriginalID] INT NULL,
	[IncidentStateID] INT NULL,
	[IncidentNo] INT NOT NULL,
	[CreatorUserName] NVARCHAR(256) NULL,
	[CreatorEmail] NVARCHAR(256) NULL,
	[CreatorCenter] NVARCHAR(256) NULL,
	[CreatorPhone] NVARCHAR(32) NULL,
	[CreationDate] DATETIME NOT NULL,
	[IncidentProcessID] INT NULL,
	[IncidentCategoryID] INT NULL,
	[DonorNumber] VARCHAR(16) NULL,
	[DateTimeOfIncident] DATETIME NULL,
	[Location] VARCHAR(256) NULL,
	[IncidentDescription] VARCHAR(512) NULL,
	[PersonsInvolved] VARCHAR(256) NULL,
	[Impact] VARCHAR(256) NULL,
	[Suggestions] VARCHAR(512) NULL,
	[IncidentDamageCategoryID] INT NULL,
	[IncidentPotentialDamageID] INT NULL,
	[IncidentLikelihoodToRepeatID] INT NULL,
	[DamageDescription] VARCHAR(512) NULL,
	[CorrectiveAction] VARCHAR(512) NULL,
	[PreventiveAction] VARCHAR(512) NULL,
	[Analysis] VARCHAR(512) NULL,
	[IsArchived] BIT NOT NULL,
	[IsDeleted] BIT NOT NULL,
	[ModificationDate] DATETIME NULL,
	[ModificationVersion] TIMESTAMP NOT NULL,
 CONSTRAINT [PK_Incident] PRIMARY KEY CLUSTERED 
(
	[ID] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [Data01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_Incident] FOREIGN KEY([OriginalID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_Incident]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentState] FOREIGN KEY([IncidentStateID])
REFERENCES [dbo].[IncidentState] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentState]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentProcess] FOREIGN KEY([IncidentProcessID])
REFERENCES [dbo].[IncidentProcess] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentProcess]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentCategory] FOREIGN KEY([IncidentCategoryID])
REFERENCES [dbo].[IncidentCategory] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentCategory]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentDamageCategory] FOREIGN KEY([IncidentDamageCategoryID])
REFERENCES [dbo].[IncidentDamageCategory] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentDamageCategory]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentPotentialDamage] FOREIGN KEY([IncidentPotentialDamageID])
REFERENCES [dbo].[IncidentPotentialDamage] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentPotentialDamage]
GO
ALTER TABLE [dbo].[Incident]  WITH CHECK ADD CONSTRAINT [FK_Incident_IncidentLikelihoodToRepeat] FOREIGN KEY([IncidentLikelihoodToRepeatID])
REFERENCES [dbo].[IncidentLikelihoodToRepeat] ([ID])
GO
ALTER TABLE [dbo].[Incident] CHECK CONSTRAINT [FK_Incident_IncidentLikelihoodToRepeat]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incidents' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentState (New, In Process or Closed)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentStateID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Membership username of person reporting incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CreatorUserName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Membership email of person reporting incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CreatorEmail'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Center of person reporting incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CreatorCenter'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Phone of person reporting incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CreatorPhone'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Creation date of reported incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CreationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentProcess (Procurement, Transport, Allocation, etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentProcessID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentCategory (Software, Hardware, Human error, etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'ST/RS/FO number identifying the Donor' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'DonorNumber'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date and time when incident happened' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'DateTimeOfIncident'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Location where incident happened' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'Location'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Persons involved in incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'PersonsInvolved'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Impact of incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'Impact'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Suggestions to solve prevent incident (usually filled by person reporting incident)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'Suggestions'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentDamageCategory (No, Minor, Moderate, Major)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentDamageCategoryID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentPotentialDamage (Minor, Moderate, Major)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentPotentialDamageID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing IncidentLikelihoodToRepeat (Low, Medium, High)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IncidentLikelihoodToRepeatID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of damage caused by incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'DamageDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actions to undertake to correct / solve incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'CorrectiveAction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Actions to undertake to prevent incident the next time' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'PreventiveAction'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Analysis of incidents' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'Analysis'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Is this Record archived' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IsArchived'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if row is marked as deleted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Date of Modification' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'ModificationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Version of Modification (Concurrency)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Incident', @level2type=N'COLUMN',@level2name=N'ModificationVersion'
GO
--------------------------------------------------------------------------------------------------------------------------------------------------


IF OBJECT_ID ('dbo.IncidentDocument', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentDocument')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentDocument]
END

CREATE TABLE [dbo].[IncidentDocument]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NULL,
	[IncidentGUID] nvarchar(50) NULL,
	[IncidentDocumentName] NVARCHAR(64) NOT NULL,
	[IncidentDocumentFileType] NVARCHAR(64) NOT NULL,
    [IncidentDocumentFileData] VARBINARY(MAX) NOT NULL,
    CONSTRAINT [PK_IncidentDocument] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentDocument]  WITH CHECK ADD CONSTRAINT [FK_IncidentDocument_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentDocument] CHECK CONSTRAINT [FK_IncidentDocument_Incident]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident documents' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident file name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument', @level2type=N'COLUMN',@level2name=N'IncidentDocumentName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident file type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument', @level2type=N'COLUMN',@level2name=N'IncidentDocumentFileType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident file data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDocument', @level2type=N'COLUMN',@level2name=N'IncidentDocumentFileData'
GO

IF OBJECT_ID ('dbo.IncidentDonorRelatedOrgan', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentDonorRelatedOrgan')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentDonorRelatedOrgan]
END

CREATE TABLE [dbo].[IncidentDonorRelatedOrgan]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NOT NULL,
    [TransplantOrganID] INT NOT NULL
    CONSTRAINT [PK_IncidentDonorRelatedOrgan] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentDonorRelatedOrgan]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedOrgan_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedOrgan] CHECK CONSTRAINT [FK_IncidentDonorRelatedOrgan_Incident]
GO
ALTER TABLE [dbo].[IncidentDonorRelatedOrgan]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedOrgan_TransplantOrgan] FOREIGN KEY([TransplantOrganID])
REFERENCES [dbo].[TransplantOrgan] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedOrgan] CHECK CONSTRAINT [FK_IncidentDonorRelatedOrgan_TransplantOrgan]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Donor related organs for incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedOrgan'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedOrgan', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedOrgan', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to TransplantOrgan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedOrgan', @level2type=N'COLUMN',@level2name=N'TransplantOrganID'
GO


IF OBJECT_ID ('dbo.IncidentDonorRelatedTransport', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentDonorRelatedTransport')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentDonorRelatedTransport]
END

CREATE TABLE [dbo].[IncidentDonorRelatedTransport]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NOT NULL,
    [TransportID] INT NOT NULL
    CONSTRAINT [PK_IncidentDonorRelatedTransport] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentDonorRelatedTransport]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedTransport_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedTransport] CHECK CONSTRAINT [FK_IncidentDonorRelatedTransport_Incident]
GO
ALTER TABLE [dbo].[IncidentDonorRelatedTransport]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedTransport_Transport] FOREIGN KEY([TransportID])
REFERENCES [dbo].[Transport] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedTransport] CHECK CONSTRAINT [FK_IncidentDonorRelatedTransport_Transport]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Donor related organs for incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedTransport'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedTransport', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedTransport', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedTransport', @level2type=N'COLUMN',@level2name=N'TransportID'
GO


IF OBJECT_ID ('dbo.IncidentDonorRelatedDelay', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentDonorRelatedDelay')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentDonorRelatedDelay]
END

CREATE TABLE [dbo].[IncidentDonorRelatedDelay]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NOT NULL,
    [DelayID] INT NOT NULL
    CONSTRAINT [PK_IncidentDonorRelatedDelay] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentDonorRelatedDelay]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedDelay_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedDelay] CHECK CONSTRAINT [FK_IncidentDonorRelatedDelay_Incident]
GO
ALTER TABLE [dbo].[IncidentDonorRelatedDelay]  WITH CHECK ADD CONSTRAINT [FK_IncidentDonorRelatedDelay_Delay] FOREIGN KEY([DelayID])
REFERENCES [dbo].[Delay] ([ID])
GO
ALTER TABLE [dbo].[IncidentDonorRelatedDelay] CHECK CONSTRAINT [FK_IncidentDonorRelatedDelay_Delay]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Donor related organs for incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedDelay'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedDelay', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedDelay', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Delay' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentDonorRelatedDelay', @level2type=N'COLUMN',@level2name=N'DelayID'
GO


IF OBJECT_ID ('dbo.IncidentTask', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentTask')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentTask]
END

CREATE TABLE [dbo].[IncidentTask]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NOT NULL,
    [Description] VARCHAR(64) NOT NULL,
	[CreationDate] DATETIME NOT NULL,
	[Deadline] DATETIME NULL,
	[IsDone] BIT NOT NULL
    CONSTRAINT [PK_IncidentTask] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentTask]  WITH CHECK ADD CONSTRAINT [FK_IncidentTask_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentTask] CHECK CONSTRAINT [FK_IncidentTask_Incident]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident documents' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of task' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Creation date of task' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'CreationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Deadline of task' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'Deadline'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'is task done?' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentTask', @level2type=N'COLUMN',@level2name=N'IsDone'
GO


IF OBJECT_ID ('dbo.IncidentAlert', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentAlert')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentAlert]
END

CREATE TABLE [dbo].[IncidentAlert]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentID] INT NOT NULL,
    [AlertMessage] VARCHAR(64) NOT NULL,
	[CreationDate] DATETIME NOT NULL,
	[StartDate] DATETIME NOT NULL,
	[EndDate] DATETIME NOT NULL,
	[IsDeleted] BIT NOT NULL
    CONSTRAINT [PK_IncidentAlert] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentAlert]  WITH CHECK ADD CONSTRAINT [FK_IncidentAlert_Incident] FOREIGN KEY([IncidentID])
REFERENCES [dbo].[Incident] ([ID])
GO
ALTER TABLE [dbo].[IncidentAlert] CHECK CONSTRAINT [FK_IncidentAlert_Incident]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident alerts' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to Incident' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'IncidentID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Alert message' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'AlertMessage'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Creation date of alert' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'CreationDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Start date of alert' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'StartDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'End date of alert' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'EndDate'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if row is marked as deleted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlert', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO


IF OBJECT_ID ('dbo.IncidentLexicon', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentLexicon')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentLexicon]
END

CREATE TABLE [dbo].[IncidentLexicon]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
    [Definition] VARCHAR(64) NULL,
	[Description] VARCHAR(256) NULL,
	[InfoDescription] VARCHAR(256) NULL,
	[IsDeleted] BIT NOT NULL
    CONSTRAINT [PK_IncidentLexicon] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident lexicon' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Definition' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon', @level2type=N'COLUMN',@level2name=N'Definition'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of definition' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon', @level2type=N'COLUMN',@level2name=N'Description'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Description of definition for info mouse over' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon', @level2type=N'COLUMN',@level2name=N'InfoDescription'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Indicates if row is marked as deleted' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexicon', @level2type=N'COLUMN',@level2name=N'IsDeleted'
GO

IF OBJECT_ID ('dbo.IncidentLexiconDocument', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentLexiconDocument')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentLexiconDocument]
END

CREATE TABLE [dbo].[IncidentLexiconDocument]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	[IncidentLexiconID] INT NOT NULL,
    [IncidentLexiconDocumentName] NVARCHAR(64) NOT NULL,
	[IncidentLexiconDocumentFileType] NVARCHAR(64) NOT NULL,
    [IncidentLexiconDocumentFileData] VARBINARY(MAX) NOT NULL,
    CONSTRAINT [PK_IncidentLexiconDocument] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO


--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident lexicon Document' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Primary Key' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument', @level2type=N'COLUMN',@level2name=N'ID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key to IncidentLexicon' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument', @level2type=N'COLUMN',@level2name=N'IncidentLexiconID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident Lexicon file name' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument', @level2type=N'COLUMN',@level2name=N'IncidentLexiconDocumentName'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident Lexicon file type' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument', @level2type=N'COLUMN',@level2name=N'IncidentLexiconDocumentFileType'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Incident Lexicon file data' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentLexiconDocument', @level2type=N'COLUMN',@level2name=N'IncidentLexiconDocumentFileData'
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentLexiconDocument]  WITH CHECK ADD CONSTRAINT [FK_IncidentLexiconDocument_IncidentLexicon] FOREIGN KEY([IncidentLexiconID])
REFERENCES [dbo].[IncidentLexicon] ([ID])
GO
ALTER TABLE [dbo].[IncidentLexiconDocument] CHECK CONSTRAINT [FK_IncidentLexiconDocument_IncidentLexicon]
GO

-- Swisstransplant Hospital
IF NOT EXISTS(SELECT * FROM Hospital WHERE ID = -2) BEGIN
	SET IDENTITY_INSERT Hospital ON

	INSERT Hospital
	(
		ID,
		Name,
		Code,
		Display,
		AddressID,
		IsReferral,
		IsProcurement,
		IsTransplantation,
		IsFo,
		isActive,
		CorrespondanceLanguageID
	)
	SELECT
		-2,
		'Swisstransplant',
		'ST',
		'Swisstransplant',
		-1,
		1,
		0,
		0,
		0,
		1,
		1

	SET IDENTITY_INSERT Hospital OFF

	UPDATE Coordinator 
	SET
		HospitalID = -2
	WHERE 
		HospitalID IS NULL 
		AND 
		Code LIKE 'ST-%'
END

/* Inciden Tool Tables */
IF OBJECT_ID ('dbo.IncidentMail', 'Table') > 0
BEGIN
	-- drop foreign key constraints before deleting table
	DECLARE @stmt AS NVARCHAR(MAX)

	DECLARE cur CURSOR FOR
					SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
						+ '.[' + OBJECT_NAME(parent_object_id) 
						+ '] DROP CONSTRAINT ' 
						+ name
					FROM sys.foreign_keys
					WHERE referenced_object_id = OBJECT_ID('dbo.IncidentMail')
 
	OPEN cur
	FETCH cur INTO @stmt
 
   -- Drop each found foreign key constraint 
	WHILE @@FETCH_STATUS = 0
		BEGIN
			EXEC (@stmt)
			FETCH cur INTO @stmt
		END
 
	CLOSE cur
	DEALLOCATE cur

    DROP Table [dbo].[IncidentMail]
END

CREATE TABLE [dbo].[IncidentMail]
(
    [ID] INT IDENTITY(1,1) NOT NULL,
	IncidentStateID int NOT NULL,
	[To] nvarchar(50) NOT NULL,
	[Subject] nvarchar(255) NOT NULL,
	[BodyText] nvarchar(max) NOT NULL
    CONSTRAINT [PK_IncidentMail] PRIMARY KEY CLUSTERED 
    (
        [ID] ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

--foreign Keys
ALTER TABLE [dbo].[IncidentMail]  WITH CHECK ADD CONSTRAINT [FK_IncidentMail_IncidentState] FOREIGN KEY(IncidentStateID)
REFERENCES [dbo].[IncidentState] ([ID])
GO
ALTER TABLE [dbo].[IncidentMail] CHECK CONSTRAINT [FK_IncidentMail_IncidentState]
GO

/* Incident archiving task */
USE [msdb]
GO

/****** Object:  Job [SLIDS Incident archiving]    Script Date: 18.07.2014 16:07:02 ******/
BEGIN TRANSACTION
DECLARE @ReturnCode INT
SELECT @ReturnCode = 0
/****** Object:  JobCategory [[Uncategorized (Local)]]    Script Date: 18.07.2014 16:07:02 ******/
IF NOT EXISTS (SELECT name FROM msdb.dbo.syscategories WHERE name=N'[Uncategorized (Local)]' AND category_class=1)
BEGIN
EXEC @ReturnCode = msdb.dbo.sp_add_category @class=N'JOB', @type=N'LOCAL', @name=N'[Uncategorized (Local)]'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback

END

DECLARE @jobId BINARY(16)
EXEC @ReturnCode =  msdb.dbo.sp_add_job @job_name=N'SLIDS Incident archiving', 
		@enabled=1, 
		@notify_level_eventlog=2, 
		@notify_level_email=0, 
		@notify_level_netsend=0, 
		@notify_level_page=0, 
		@delete_level=0, 
		@description=N'SLIDS Incident archiving', 
		@category_name=N'[Uncategorized (Local)]', 
		@owner_login_name=N'SLIDS_User', @job_id = @jobId OUTPUT
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
/****** Object:  Step [Archiving Incidents]    Script Date: 18.07.2014 16:07:03 ******/
EXEC @ReturnCode = msdb.dbo.sp_add_jobstep @job_id=@jobId, @step_name=N'Archiving Incidents', 
		@step_id=1, 
		@cmdexec_success_code=0, 
		@on_success_action=1, 
		@on_success_step_id=0, 
		@on_fail_action=2, 
		@on_fail_step_id=0, 
		@retry_attempts=0, 
		@retry_interval=0, 
		@os_run_priority=0, @subsystem=N'TSQL', 
		@command=N'UPDATE
	Incident
SET
	IsArchived = 1
WHERE 
	IsArchived = 0 
	AND
	IsDeleted = 0
	AND
	IncidentStateID = (SELECT ID FROM IncidentState WHERE Value = 3)
	AND
	DATEADD(month, 6, ModificationDate) <= GETDATE()
	
	DELETE IncidentDocument WHERE IncidentID IS NULL', 
		@database_name=N'SLIDS', 
		@flags=0
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_update_job @job_id = @jobId, @start_step_id = 1
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobschedule @job_id=@jobId, @name=N'Daily', 
		@enabled=1, 
		@freq_type=4, 
		@freq_interval=1, 
		@freq_subday_type=1, 
		@freq_subday_interval=0, 
		@freq_relative_interval=0, 
		@freq_recurrence_factor=0, 
		@active_start_date=20140101, 
		@active_end_date=99991231, 
		@active_start_time=23000, 
		@active_end_time=235959, 
		@schedule_uid=N'96bb02f1-edeb-4673-9dc2-0a699f493b7e'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
EXEC @ReturnCode = msdb.dbo.sp_add_jobserver @job_id = @jobId, @server_name = N'(local)'
IF (@@ERROR <> 0 OR @ReturnCode <> 0) GOTO QuitWithRollback
COMMIT TRANSACTION
GOTO EndSave
QuitWithRollback:
    IF (@@TRANCOUNT > 0) ROLLBACK TRANSACTION
EndSave:

GO
USE [SLIDS]
GO


