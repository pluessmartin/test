	UPDATE SLIDS SET DBVersion = '4.5', Applied = GETDATE()

	/*
	 * Adding new Column to Donor
	 */
	IF NOT EXISTS
		(SELECT 
			* 
		FROM 
			sys.columns 
		WHERE Name = N'IncisionMade' and Object_ID = Object_ID(N'Donor')
		)
	BEGIN
		ALTER TABLE Donor ADD IncisionMade BIT NOT NULL Default 0
	END
	GO

	IF OBJECT_ID ('dbo.IncidentAnalysis', 'Table') > 0
	BEGIN
		-- drop foreign key constraints before deleting table
		DECLARE @stmt AS NVARCHAR(MAX)

		DECLARE cur CURSOR FOR
						SELECT 'ALTER TABLE ' +  OBJECT_SCHEMA_NAME(parent_object_id) 
							+ '.[' + OBJECT_NAME(parent_object_id) 
							+ '] DROP CONSTRAINT ' 
							+ name
						FROM sys.foreign_keys
						WHERE referenced_object_id = OBJECT_ID('dbo.IncidentAnalysis')
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

		DROP Table [dbo].[IncidentAnalysis]
	END

	-- Add IncidentAnalysis Table
	CREATE TABLE [dbo].[IncidentAnalysis]
	(
		[ID] INT IDENTITY(1,1) NOT NULL,
		[IncidentID] INT NOT NULL,
		[Analysis] VARCHAR(max) NOT NULL,
		[CreationDate] DATETIME NOT NULL,
		[IsDeleted] BIT NOT NULL
		CONSTRAINT [PK_IncidentAnalysis] PRIMARY KEY CLUSTERED 
		(
			[ID] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
	) ON [Data01]
	GO

	--foreign Keys
	ALTER TABLE [dbo].[IncidentAnalysis]  WITH CHECK ADD CONSTRAINT [FK_IncidentAnalysis_Incident] FOREIGN KEY([IncidentID])
	REFERENCES [dbo].[Incident] ([ID])
	GO
	ALTER TABLE [dbo].[IncidentAnalysis] CHECK CONSTRAINT [FK_IncidentAnalysis_Incident]
	GO

	IF EXISTS(SELECT * FROM sys.columns 
				WHERE Name = N'Analysis' AND Object_ID = Object_ID(N'Incident'))
	BEGIN
		INSERT [dbo].[IncidentAnalysis](IncidentID, Analysis,CreationDate, IsDeleted) Select ID, Analysis, CreationDate, 0 from [dbo].[Incident] Where Analysis <> '';
		ALTER TABLE [dbo].[Incident] DROP COLUMN Analysis ;
	END

	IF OBJECT_ID ('dbo.Lifeport', 'Table') > 0
		DROP Table [dbo].[Lifeport]

	CREATE TABLE [dbo].[Lifeport]
	(
		[ID] int IDENTITY(1,1) NOT NULL,
		[Number] varchar(64) NOT NULL,
		[Position] int NULL,
		[isActive] bit NOT NULL Default 1,
		CONSTRAINT [PK_Lifeport] PRIMARY KEY CLUSTERED 
		(
			[ID] ASC
		)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
	) ON [Data01]
	GO


	/*
	 * Adding new Column to Organ
	 */
	IF NOT EXISTS
		(SELECT 
			* 
		FROM 
			sys.columns 
		WHERE Name = N'Organ' and Object_ID = Object_ID(N'Organ')
		)
	BEGIN
		ALTER TABLE Organ ADD [WithLifeportNumber] bit NOT NULL Default 0
	END
	GO
	
		-- Adding new Column to TransportedOrgan
	IF NOT EXISTS
		(SELECT 
			* 
		FROM 
			sys.columns 
		WHERE Name = N'LifeportID' and Object_ID = Object_ID(N'TransportedOrgan')
		)
	BEGIN
		ALTER TABLE [dbo].TransportedOrgan ADD LifeportID int DEFAULT(NULL)
		ALTER TABLE [dbo].TransportedOrgan  WITH CHECK ADD CONSTRAINT [FK_TransportedOrgan_Lifeport] FOREIGN KEY([LifeportID])
		REFERENCES [dbo].[Lifeport] ([ID])
		ALTER TABLE [dbo].TransportedOrgan CHECK CONSTRAINT [FK_TransportedOrgan_Lifeport]
	END
	GO


	UPDATE Organ SET WithLifeportNumber = 1 WHERE Name LIKE '%Kidney%'
	UPDATE TransplantStatus SET isActive = 0 WHERE Name NOT IN ('TX', 'NTX')

	Update TransportItem Set isActive = 0 Where Name = 'Lifeport' 
	Update CostType Set isActive = 0 Where Name = 'Flat charges IC detection Hospital'

	INSERT INTO CostType (Name, CostGroupID, Position, isActive)VALUES ('Flat charges IC referral Hospital', 2, null, 1);
	
/****** Object:  View [dbo].[StatsOrgans]    Script Date: 16.06.2016 14:59:21 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



ALTER VIEW [dbo].[StatsOrgans]
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
			'Transplant Status' = s.Name,
			'Lifeport' = CASE txo.PrefusionMachine
				WHEN 1 THEN 'yes'
				WHEN 0 THEN 'no'
				ELSE null
				END
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


