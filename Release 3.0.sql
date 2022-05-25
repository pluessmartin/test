USE SLIDS

-- Set new version
------------------
UPDATE SLIDS SET DBVersion = '3.0'


-- Add new table ItemGroup and set its foreign key to table Organ and TransportItem
---------------------------------------------------------------
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

-- add new foreign key column of ItemGroupID
ALTER TABLE [dbo].[Organ] ADD ItemGroupID int NULL
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of ItemGroup (grouping Heart, Liver, Lung etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'ItemGroupID'
GO

-- foreign key on table Organ
ALTER TABLE [dbo].[Organ]  WITH CHECK ADD CONSTRAINT [FK_Organ_ItemGroup] FOREIGN KEY([ItemGroupID])
REFERENCES [dbo].[ItemGroup] ([ID])
GO
ALTER TABLE [dbo].[Organ] CHECK CONSTRAINT [FK_Organ_ItemGroup]


-- drop column TransportItemType which is not used
ALTER TABLE [dbo].[TransportItem] DROP COLUMN [TransportItemType]
GO

-- add new foreign key column of ItemGroupID
ALTER TABLE [dbo].[TransportItem] ADD ItemGroupID int NULL
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key of ItemGroup (grouping Coordinators, Team, Blood etc.)' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem', @level2type=N'COLUMN',@level2name=N'ItemGroupID'
GO

-- foreign key on table TransportItem
ALTER TABLE [dbo].[TransportItem]  WITH CHECK ADD CONSTRAINT [FK_TransportItem_ItemGroup] FOREIGN KEY([ItemGroupID])
REFERENCES [dbo].[ItemGroup] ([ID])
GO
ALTER TABLE [dbo].[TransportItem] CHECK CONSTRAINT [FK_TransportItem_ItemGroup]
GO

-- insert Data in table ItemGroup
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Heart' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Heart', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Lung' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Lung', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Liver' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Liver', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Kidney' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Kidney', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Pancreas' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Pancreas', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Small bowel' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Small bowel', 1)
END

IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Blood' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Blood', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Biopsy' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Biopsy', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Teams' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Teams', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Transplant Coordinator' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Transplant Coordinator', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Donor' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Donor', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Other' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Other', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Empty' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Empty', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Lifeport' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Lifeport', 2)
END


-- Update existant data with new Item Group ID
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Heart' AND [Type] = 1)
WHERE	Name = 'Heart'
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Lung' AND [Type] = 1)
WHERE	Name LIKE 'Lung%'
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Liver' AND [Type] = 1)
WHERE	Name LIKE 'Liver%'
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Kidney' AND [Type] = 1)
WHERE	Name LIKE '%Kidney%'
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Pancreas' AND [Type] = 1)
WHERE	Name LIKE 'Pancreas%'
UPDATE	[dbo].[Organ] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Small bowel' AND [Type] = 1)
WHERE	Name = 'Small bowel'

UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Blood' AND [Type] = 2)
WHERE	Name LIKE 'Blood%'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Biopsy' AND [Type] = 2)
WHERE	Name LIKE '%Biopsy%' OR Name = 'Rapid section diagnosis'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Teams' AND [Type] = 2)
WHERE	Name LIKE '%Team'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Transplant Coordinator' AND [Type] = 2)
WHERE	Name LIKE 'Transplant Coordinator%'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Donor' AND [Type] = 2)
WHERE	Name = 'Donor'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Other' AND [Type] = 2)
WHERE	Name = 'Surgical material' OR Name = 'Solutions' OR Name = 'Other'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Empty' AND [Type] = 2)
WHERE	Name = 'Empty'
UPDATE	[dbo].[TransportItem] 
SET		ItemGroupID = (SELECT ID FROM ItemGroup WHERE Name = 'Lifeport' AND [Type] = 2)
WHERE	Name = 'Lifeport'


-- add new column ContactPerson to table Address
ALTER TABLE [dbo].[Address] ADD ContactPerson nvarchar(64) NULL
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Contact Person' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Address', @level2type=N'COLUMN',@level2name=N'ContactPerson'
GO



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

-- add new foreign key column of Language to table hospital
ALTER TABLE [dbo].[Hospital] ADD CorrespondanceLanguageID int NULL
GO

-- foreign key on table Organ
ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD CONSTRAINT [FK_Hospital_Language] FOREIGN KEY([CorrespondanceLanguageID])
REFERENCES [dbo].[Language] ([ID])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_Language]


-- add new foreign key column of Accounting Address to table hospital
ALTER TABLE [dbo].[Hospital] ADD AccountingAddressID int NULL
GO

-- foreign key on table Organ
ALTER TABLE [dbo].[Hospital]  WITH CHECK ADD CONSTRAINT [FK_Hospital_AccountingAddress] FOREIGN KEY([AccountingAddressID])
REFERENCES [dbo].[Address] ([ID])
GO
ALTER TABLE [dbo].[Hospital] CHECK CONSTRAINT [FK_Hospital_AccountingAddress]
GO

-- insert Data in table Language
-- insert Data in table Language
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'German')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('German', 'de')
END
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'French')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('French', 'fr')
END
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'Italian')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('Italian', 'it')
END
GO

-- Update table Hospital and set accounting address and corresponding language
--Update Hospitals
DECLARE @AccountingAddressID AS INT

IF EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-AAHIRS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schänisweg', '5000', 'Aarau', 'CH')
SET	@AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'AG-AAHIRS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-AAKSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Tellstrasse 15', '5001', 'Aarau', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'AG-AAKSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-BAKSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Im Ergel 1', '5404', 'Baden', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'AG-BAKSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'AR-KANSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 6', '9100', 'Herisau', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'AR-KANSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-BEAUSI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schänzlihalde 11', '3000', 'Bern 25', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-BEAUSI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-BIEL')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2,  Zip, City, CountryISO) VALUES('Finanzen', 'Vogelsang 84', 'Postfach', '2501', 'Biel', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-BIEL'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-EMBURG')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Oberburgstrasse 54', '3400', 'Burgdorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-EMBURG'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-INSEL')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Buchhaltung', 'Freiburgerstrasse 10', '3010', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-INSEL'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-INTERL')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Weissenaustrasse 27', '3800', 'Unterseen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-INTERL'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-LANGEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'St. Urbanstrasse 67', '4901', 'Langenthal', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-LANGEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE- LINDEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Bremgartenstrasse 117', 'Postfach', '3001', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE- LINDEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-SONNEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Buchserstrasse 30', '3006', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-SONNEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-THUN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Krankenhausstrasse 12', '3600', 'Thun', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-THUN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-TIEFEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Tiefenaustrasse 112', 'Postfach 700', '3004', 'Bern 4', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-TIEFEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-ZIEGLE')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Morillonstrasse 75', 'Postfach', '3001', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BE-ZIEGLE'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BL-BRUDER')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', NULL, '4101', 'Bruderholz', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BL-BRUDER'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BL-LIES')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Rheinstrasse 26', '4410', 'Liestal', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BL-LIES'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-CLARAS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Kleinriehenstrasse 30', '4058', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BS-CLARAS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-KISPIT')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 33', '4056', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BS-KISPIT'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-UNISPIT')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Petersgraben 4', '4031', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'BS-UNISPIT'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'FR-HOPCAN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Facturation', 'Chemin de Pensionnats 2-6', 'Case postale', '1708', 'Fribourg', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2 
WHERE	Code = 'FR-HOPCAN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GE-HUG')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Secteur facturation aux tiers', 'Chemin de Petit-Bel-Air 2', '1225', 'Chène-Bourg', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2 
WHERE	Code = 'GE-HUG'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GE-LATOUR')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue J.D. Maillard 3', '1217', 'Meyrin', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'GE-LATOUR'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GL-GLARUS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Burgstrasse 99', '8750', 'Glarus', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'GL-GLARUS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-CHUR')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Loesstrasse 170', '7000', 'Chur', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'GR-CHUR'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-DAVOS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Promenade 4', '7270', 'Davos', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'GR-DAVOS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-SAMED')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', NULL, '7503', 'Samedan', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'GR-SAMED'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'JU-DELEMO')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Fbg des Capucins 30', '2800', 'Delémont', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'JU-DELEMO'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-KANSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Ambulante Abrechnung', 'Spitalstrasse', '6000', 'Luzern 16', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'LU-KANSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-KISPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Kantonsspital', '6000', 'Luzern 16', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'LU-KISPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-NOTTWI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Guido A. Zäch-Strasse 1', '6207', 'Nottwil', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'LU-NOTTWI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-STANNA')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'St. Annastrasse 32', '6006', 'Luzern', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'LU-STANNA'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-SURSEE')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 16a', 'Postfach', '6210', 'Sursee', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'LU-SURSEE'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'NE-CHAUX')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chasseral 20', '2300', 'La Chaux-de-Fonds', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'NE-CHAUX'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'NE-NEPOUR')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Maladière 45', '2000', 'Neuchâtel', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'NE-NEPOUR'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'NW-NIDWALD')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Ennetmooserstrasse 19', '6370', 'Stans', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'NW-NIDWALD'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-KANSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Rorschacherstrasse 95', '9007', 'St. Gallen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SG-KANSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-KISPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Claudiusstrasse 6', '9007', 'St. Gallen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SG-KISPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-WALENS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 5', '8880', 'Walenstadt', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SG-WALENS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SH-SCHAFF')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Geissbergstrasse 81', '8208', 'Schaffhausen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SH-SCHAFF'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SO-OLKSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Baslerstrasse 150', '4600', 'Olten', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SO-OLKSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SO-SOBUER')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schöngrünstrasse 42', '4500', 'Solothurn', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SO-SOBUER'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SZ-LACHEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Oberdorfstrasse 41', '8853', 'Lachen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SZ-LACHEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'SZ-SCHWYZ')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Waldeggstrasse 10', '6430', 'Schwyz', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'SZ-SCHWYZ'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-FRAUEN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Pfaffenholzstrasse 4', '8501', 'Frauenfeld', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'TG-FRAUEN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-KREUZ')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Weinbergstrasse 1', '8280', 'Kreuzlingen 2', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'TG-KREUZ'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-MÜNST')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalcampus 1', '8596', 'Münsterlingen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'TG-MÜNST'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-BELLIN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', NULL, '6500', 'Bellinzona', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 3
WHERE	Code = 'TI-BELLIN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LOCARN')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', 'Via all''Ospedale 1', '6600', 'Locarno', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 3
WHERE	Code = 'TI-LOCARN'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LUCARD')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', 'Via Tesserete 48', '6903', 'Lugano', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 3
WHERE	Code = 'TI-LUCARD'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LUCIVI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Servizio Cent. Contabilita e fatturazione', 'Via Lugano 4b', '6501', 'Bellinzona', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 3
WHERE	Code = 'TI-LUCIVI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-MENDRI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Fatturazione', 'Via Turconi 23', 'CP 1652', '6850', 'Mendrisio', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 3
WHERE	Code = 'TI-MENDRI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'UR-ALKSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 1', '6460', 'Altdorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'UR-ALKSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-CECIL')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue Louis-Ruchonnet 53', '1003', 'Lausanne', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-CECIL'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-CHUV')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation opérationelle', 'Rue du Bugnon', '1011', 'Lausanne', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-CHUV'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-GHOL')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chemin Monastier 10', '1260', 'Nyon', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-GHOL'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-MORGES')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chemin du Crêt 2', '1110', 'Morges', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-MORGES'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-PAYERNE')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Facturation', 'Avenue de la Colline 3', 'Case postale 192', '1530', 'Payerne', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-PAYERNE'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-POMPAP')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', NULL, '1318', 'Pompaples', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-POMPAP'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-VEVSAM')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Boulevard Paderewski 3', '1800', 'Vevey', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-VEVSAM'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-YVERD')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Rue d''Entremonts 11', '1400', 'Yverdon-les-bains', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VD-YVERD'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-MONTH')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Route de Morgins', '1870', 'Monthey', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VS-MONTH'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-OBWS')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Ueberlandstrasse 14', '3900', 'Brig', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'VS-OBWS'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-SION')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue Grand-Champsec 80', '1951', 'Sion', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 2
WHERE	Code = 'VS-SION'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZG-ZUKSPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Landhausstrasse 11', '6340', 'Baar', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZG-ZUKSPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-BÜLACH')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 24', '8180', 'Bülach', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-BÜLACH'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-HIRSLA')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Witellikerstrasse 40', '8008', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-HIRSLA'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-KISPI')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Steinwiesstrasse 75', '8032', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-KISPI'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-LIMMAT')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Urdorferstrasse 100', '8952', 'Schlieren', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-LIMMAT'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-MÄNNED')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Asylstrasse 10', '8708', 'Männedorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-MÄNNED'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-PARK')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Seestrasse 220', '8027', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-PARK'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-TRIEM')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Birmensdorferstrasse 497', '8063', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-TRIEM'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-USTER')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Brunnenstrasse 42', '8610', 'Uster', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-USTER'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-USZ')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Stationäre Abrechnung', 'Rämistrasse 100', '8091', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-USZ'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WAID')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Tièchestrasse 99', '8037', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-WAID'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WETZ')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 60', '8620', 'Wetzikon', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-WETZ'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WINTH')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Brauerstrasse 15', '8401', 'Winterthur', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-WINTH'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-ZIMBER')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Asylstrasse 19', '8810', 'Horgen', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-ZIMBER'
END
IF EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-ZOLLIK')
BEGIN
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Trichtenhauserstrasse 20', '8125', 'Zollikerberg', 'CH')
SET @AccountingAddressID = @@IDENTITY
UPDATE	Hospital 
SET		AccountingAddressID = @AccountingAddressID, 
		CorrespondanceLanguageID = 1 
WHERE	Code = 'ZH-ZOLLIK'
END
GO


-- Alter Excel Export so that Total of costs which are not related to organs will still appear in Column Amount
ALTER VIEW [dbo].[StatsGeneralCosts]
AS
SELECT
	DonorNumber AS 'Donor Number',
	hProc.Display AS 'Procurement Hospital',
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


DECLARE @FontID AS INT
-- insert Data in table Font
IF NOT EXISTS (SELECT * FROM [dbo].[Font] WHERE FontName = 'Helvetica' AND FontSize = 11)
BEGIN
	INSERT INTO [dbo].[Font](FontName, FontSize) VALUES('Helvetica', 11)
	SET @FontID = @@IDENTITY
END

-- insert Data in table ReminderLetter
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 1)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	1, 
						@FontID, 
						'Bern, ', 
						'Sehr geehrte Damen und Herren',
						'Wir bitten Sie gemäss dem Vertrag zwischen Swisstransplant und ihrem Spital, die Pauschalen der unten aufgeführten Positionen zu verrechnen.',
						'Bei Fragen melden Sie sich bei Frau Corpataux, Tel. 031 380 81 26',
						'Freundliche Grüsse',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Total')
END
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 2)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	2, 
						@FontID, 
						'Berne, ',
						'Mesdames, Messieurs,',
						'Selon les contrats que votre hôpital a signé avec Swisstransplant, nous vous prions de bien vouloir nous adresser les facturations des actes exécutés et inscrits dans le tableau ci-dessous selon les forfaits établis.',
						'Si vous avez des questions, adressez vous à Madame Corpataux, Tel. 031 380 81 26',
						'Meilleures salutations',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Total')
END
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 3)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	3, 
						@FontID, 
						'Berna, ', 
						'Egregi Signora e Signore,',
						'La preghiamo di ben volere inviarci la fatturazione degli atti eseguiti e indicati nella tabella sottostante, secondo i forfait del contratto firmato tra Swisstransplant e il vostro ospedale.',
						'In caso di domande si rivolga alla Signora Corpataux, Tel. 031 380 81 26',
						'Cordiali saluti',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Totale')
END
GO