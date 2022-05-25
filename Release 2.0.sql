USE SLIDS

-- Set new version
------------------
Update SLIDS set DBVersion = '2.0'


-- Add new table Creditor and set its foreign key to table Cost
---------------------------------------------------------------
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

ALTER TABLE [dbo].[Cost] ADD CreditorID int NULL
GO

-- foreign key
ALTER TABLE [dbo].[Cost]  WITH CHECK ADD CONSTRAINT [FK_Cost_Creditor] FOREIGN KEY([CreditorID])
REFERENCES [dbo].[Creditor] ([ID])
GO
ALTER TABLE [dbo].[Cost] CHECK CONSTRAINT [FK_Cost_Creditor]
GO

-- Insert Data in Table Creditor
--------------------------------
-- insert Creditors
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Bären Taxi AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Bären Taxi AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA EuroMedTrans')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA EuroMedTrans')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA TCS')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA TCS')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Sprenger AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Sprenger AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Skymedia AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Skymedia AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Bahnhof Taxi')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Bahnhof Taxi')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Lions Air')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Lions Air')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = '360° Transports Urgents')
begin
	insert into [dbo].[Creditor](CreditorName) Values('360° Transports Urgents')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Intermedic AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Intermedic AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Ville de Lausanne')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Ville de Lausanne')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Sanitätspolizei BE')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Sanitätspolizei BE')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA SK Ambulances SA')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA SK Ambulances SA')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Wieland Bus')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Wieland Bus')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA VGS Medicals')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA VGS Medicals')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Hermes Transporting')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Hermes Transporting')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Sprenger AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Sprenger AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA TRS')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA TRS')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Ernst Hess AG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Ernst Hess AG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA V. Janicijevic')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA V. Janicijevic')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA O''key Taxi ZH')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA O''key Taxi ZH')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Elart AG Taxi')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Elart AG Taxi')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Ambulanz Murten')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Ambulanz Murten')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Kantonsspital Obwalden')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Kantonsspital Obwalden')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Herold Taxi')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Herold Taxi')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Taxi Alpina')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Taxi Alpina')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Taxiphone')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Taxiphone')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'AAA Croce Verde Lugano')
begin
	insert into [dbo].[Creditor](CreditorName) Values('AAA Croce Verde Lugano')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'HUG')
begin
	insert into [dbo].[Creditor](CreditorName) Values('HUG')
end
if not exists (select * from [dbo].[Creditor] where CreditorName = 'REGA')
begin
	insert into [dbo].[Creditor](CreditorName) Values('REGA')
end

-- update existing items in Cost with new CreditorID's
UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA'),
		KreditorName = NULL
WHERE KreditorName = 'AAA'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Bären Taxi AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Bären Taxi%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA EuroMedTrans'),
		KreditorName = NULL
WHERE KreditorName LIKE '%EuroMed%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA TCS'),
		KreditorName = NULL
WHERE KreditorName LIKE '%TCS%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Sprenger AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Sprenger%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Skymedia AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Skymedia%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Bahnhof Taxi'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Bahnhof%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Lions Air'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Lions%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = '360° Transports Urgents'),
		KreditorName = NULL
WHERE KreditorName LIKE '%360°%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Intermedic AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Intermedic%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Ville de Lausanne'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Ville de Lausanne%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Sanitätspolizei BE'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Sanitätspolizei BE%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA SK Ambulances SA'),
		KreditorName = NULL
WHERE KreditorName LIKE '%SK Ambulance%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Wieland Bus'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Wieland%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA VGS Medicals'),
		KreditorName = NULL
WHERE KreditorName LIKE '%VGS Medicals%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Hermes Transporting'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Hermes%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Sprenger AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Sprenger%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA TRS'),
		KreditorName = NULL
WHERE KreditorName LIKE '%TRS%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Ernst Hess AG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Ernst Hess%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA V. Janicijevic'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Janicijevic%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA O''key Taxi ZH'),
		KreditorName = NULL
WHERE KreditorName LIKE '%key Taxi%' OR KreditorName LIKE 'kay Taxi'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Elart AG Taxi'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Elart%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Ambulanz Murten'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Ambulanz Murten%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Kantonsspital Obwalden'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Kantonsspital Obwalden%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Herold Taxi'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Herold%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Taxi Alpina'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Alpina%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Taxiphone'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Taxiphone%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'AAA Croce Verde Lugano'),
		KreditorName = NULL
WHERE KreditorName LIKE '%Croce Verde Lugano%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'HUG'),
		KreditorName = NULL
WHERE KreditorName LIKE '%HUG%'

UPDATE [dbo].[Cost] 
	SET CreditorID = (SELECT ID FROM Creditor WHERE CreditorName = 'REGA'),
		KreditorName = NULL
WHERE KreditorName LIKE '%REGA%'


-- Add new column 'CountableAs' in tables Organ and TransportItem in order to have the correct number in excel export (fields OrganCount and ItemCount)
-------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER TABLE [dbo].[Organ] ADD CountableAs int NULL
GO
--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of which organ is countable for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Organ', @level2type=N'COLUMN',@level2name=N'CountableAs'
GO
--set default value
UPDATE [dbo].[Organ] SET CountableAs = 1

-- update organ count for known organs with more than 1 countable organ
UPDATE [dbo].[Organ] Set CountableAs = 2 WHERE Name = 'Both kidneys' OR Name = 'Kidneys en bloc'
GO

ALTER TABLE [dbo].[TransportItem] ADD CountableAs int NULL
GO
--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Number of which transport item is countable for' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'TransportItem', @level2type=N'COLUMN',@level2name=N'CountableAs'
GO
--set default value
UPDATE [dbo].[TransportItem] SET CountableAs = 1
GO


-- Associate Organ(s) to TransportItem
--------------------------------------
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


-- Add columns 'DetectionHospitalID' and 'Comment' to table  Donor
------------------------------------------------------------------
ALTER TABLE [dbo].[Donor] ADD DetectionHospitalID int NULL, Comment varchar(256) NULL 
GO

--foreign Keys
ALTER TABLE [dbo].[Donor]  WITH CHECK ADD CONSTRAINT [FK_Donor_DetectionHospital] FOREIGN KEY([DetectionHospitalID])
REFERENCES [dbo].[Hospital] ([ID])
GO
ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_Donor_DetectionHospital]
GO

--descriptions
EXEC sys.sp_updateextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Referral Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ReferralHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign Key referencing Detection Hospital' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'DetectionHospitalID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Comment' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'Comment'
GO

-- Edit StatsDonor so that Columns Detection Hospital and Comment are in Excel Export
ALTER VIEW [dbo].[StatsDonor]
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


-- Edit StatsTransports so that OrganCount and ItemCount (and TotalCount) take their value from Column CountableAs instead of number of available rows
------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER VIEW [dbo].[StatsTransports]
as
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
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


-- Edit StatsTransportCosts so that OrganCount and ItemCount (and TotalCount) take their value from Column CountableAs instead of number of available rows and include Dossier Costs (CostGroup TransportGlobal)
----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
ALTER VIEW [dbo].[StatsTransportCosts]
as
SELECT
	DonorNumber as 'Donor Number',
	hProc.Display as 'Procurement Hospital',
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
	oc.Amount as 'Amount'
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
	ocost.Amount as 'Amount'
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



-- According to requests on Release 2, only allocate costs to organs which were transplanted (state TX)
-------------------------------------------------------------------------------------------------------
UPDATE CostDistribution SET ReferOnlyOnTransplantedOrgans = 1
GO


-- Insert OrganToTransportItemAssociations for 'Blood for Serology', Donor and Transplant Coordinator
------------------------------------------
if not exists (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Blood for Serology/BG/HLA' AND t.isActive = 1)
begin
	INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Blood for Serology/BG/HLA' AND t.isActive = 1 AND o.isActive = 1)
end
if not exists (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Donor' AND t.isActive = 1)
begin
INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Donor' AND t.isActive = 1 AND o.isActive = 1)
end
if not exists (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Transplant Coordinator(s)' AND t.isActive = 1)
begin
INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Transplant Coordinator(s)' AND t.isActive = 1 AND o.isActive = 1)
end
GO