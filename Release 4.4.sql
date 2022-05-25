BEGIN TRAN

UPDATE SLIDS SET DBVersion = '4.4'
/*
 * Update Donor Management
 */
UPDATE IncidentProcess SET Description = 'Donor Management' WHERE Description = 'Donormanagement'

/*
 * Updates Incident with Process Packing and maps it to Procurement - Packaging
 */
IF(EXISTS(SELECT * FROM Incident WHERE IncidentProcessID IN (SELECT ID FROM IncidentProcess as tblS WHERE tblS.Description = 'Packing'))) BEGIN
	DECLARE @intIncidentProcessIDProcurement int
	DECLARE @intIncidentCategoryIDPackaging int

	SELECT
		@intIncidentProcessIDProcurement = ID
	FROM
		IncidentProcess
	WHERE
		IncidentProcess.Description = 'Procurement'

	SELECT
		@intIncidentCategoryIDPackaging = ID
	FROM
		IncidentProcess
	WHERE
		IncidentProcess.Description = 'Packaging'

	UPDATE 
		Incident 
	SET 
		IncidentCategoryID = @intIncidentCategoryIDPackaging, 
		IncidentProcessID = @intIncidentProcessIDProcurement 
	WHERE 
		IncidentProcessID IN (SELECT ID FROM IncidentProcess as tblS WHERE tblS.Description = 'Packing')
END

/*
 * Deletes Process Packing
 */
DELETE IncidentProcess WHERE IncidentProcess.Description = 'Packing'

/*
 * New mapping of Other
 */
DECLARE @intCategoryIDOther int
SELECT @intCategoryIDOther = ID FROM IncidentCategory WHERE IncidentCategory.Description = 'Other'
UPDATE Incident
SET IncidentCategoryID = @intCategoryIDOther
FROM
	Incident
	INNER JOIN IncidentCategory
		ON IncidentCategory.ID = Incident.IncidentCategoryID
WHERE
	IncidentCategory.Description = 'Other'

DELETE IncidentCategory
WHERE
	IncidentCategory.Description = 'Other'
	AND NOT IncidentCategory.ID = @intCategoryIDOther

/*
 * Inserts missing categories
 */
DECLARE @tblCategories TABLE (
	strName nvarchar(250)
)
INSERT @tblCategories
SELECT 'Anamnesis' UNION
SELECT 'Blood for X-match' UNION
SELECT 'Blood samples' UNION
SELECT 'Communication' UNION
SELECT 'Contamination' UNION
SELECT 'Correction' UNION
SELECT 'Delay' UNION
SELECT 'Documentation' UNION
SELECT 'Equipment' UNION
SELECT 'Examination report' UNION
SELECT 'Exams' UNION
SELECT 'HLA' UNION
SELECT 'Laboratory' UNION
SELECT 'Management' UNION
SELECT 'Organs' UNION
SELECT 'Other' UNION
SELECT 'Packaging' UNION
SELECT 'Procedure' UNION
SELECT 'Procurement report' UNION
SELECT 'Retrieval injury' UNION
SELECT 'Software' UNION
SELECT 'Transcription' UNION
SELECT 'Weather conditions'

INSERT IncidentCategory (Description, Value, Position)
SELECT 
	strName,
	0,
	0 --Position is calculated later
FROM
	@tblCategories
WHERE
	strName NOT IN (SELECT Description FROM IncidentCategory)

DECLARE @tblPosition TABLE(
	ID int NOT NULL,
	intPos int NOT NULL
)
INSERT @tblPosition
SELECT
	ID,
	ROW_NUMBER() OVER (ORDER BY Description)
FROM
	IncidentCategory
WHERE
	NOT IncidentCategory.Description = 'Other'

INSERT @tblPosition
SELECT
	ID,
	(SELECT MAX(intPos) FROM @tblPosition) + 1
FROM
	IncidentCategory
WHERE
	IncidentCategory.Description = 'Other'
	

UPDATE IncidentCategory
SET Position = intPos
FROM IncidentCategory
	INNER JOIN @tblPosition AS tblPos
		ON tblPos.ID = IncidentCategory.ID

/*
 * Creating Process to Category table
 */
 
-- Add Language of corresponance and accounting address to hospital
IF OBJECT_ID ('dbo.IncidentProcessToCategory', 'Table') > 0
	DROP Table [dbo].IncidentProcessToCategory

CREATE TABLE [dbo].IncidentProcessToCategory
(
	[ID] INT IDENTITY(1,1) NOT NULL,
	IncidentCategoryID INT NOT NULL,
	IncidentProcessID INT NOT NULL,
	CONSTRAINT [PK_IncidentProcessToCategory] PRIMARY KEY CLUSTERED 
	(
		[ID] ASC
	)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]
) ON [Data01]
GO

-- foreign key on table IncidentProcessToCategory
ALTER TABLE [dbo].IncidentProcessToCategory  WITH CHECK ADD CONSTRAINT [FK_IncidentProcessToCategory_IncidentProcess] FOREIGN KEY(IncidentProcessID)
REFERENCES [dbo].IncidentProcess ([ID])
GO
ALTER TABLE [dbo].IncidentProcessToCategory CHECK CONSTRAINT [FK_IncidentProcessToCategory_IncidentProcess]

-- foreign key on table IncidentProcessToCategory
ALTER TABLE [dbo].IncidentProcessToCategory  WITH CHECK ADD CONSTRAINT [FK_IncidentProcessToCategory_IncidentCategory] FOREIGN KEY(IncidentCategoryID)
REFERENCES [dbo].IncidentCategory ([ID])
GO
ALTER TABLE [dbo].IncidentProcessToCategory CHECK CONSTRAINT [FK_IncidentProcessToCategory_IncidentCategory]

GO
/*
 * Creating DataSet
 */
DECLARE @tblProcessToCategory TABLE (
	strCategory nvarchar(255) NOT NULL,
	strProcess nvarchar(255) NOT NULL
)

INSERT @tblProcessToCategory (strProcess, strCategory)
SELECT 'Donor Management', 'Anamnesis' UNION ALL
SELECT 'Donor Management', 'Communication' UNION ALL
SELECT 'Donor Management', 'Delay' UNION ALL
SELECT 'Donor Management', 'Documentation' UNION ALL
SELECT 'Donor Management', 'Equipment' UNION ALL
SELECT 'Donor Management', 'Exams' UNION ALL
SELECT 'Donor Management', 'Management' UNION ALL
SELECT 'Donor Management', 'Other' UNION ALL
SELECT 'Allocation', 'Blood for X-match' UNION ALL
SELECT 'Allocation', 'Communication' UNION ALL
SELECT 'Allocation', 'Delay' UNION ALL
SELECT 'Allocation', 'Documentation' UNION ALL
SELECT 'Allocation', 'Exams' UNION ALL
SELECT 'Allocation', 'Software' UNION ALL
SELECT 'Allocation', 'Other' UNION ALL
SELECT 'Documentation', 'Communication' UNION ALL
SELECT 'Documentation', 'Correction' UNION ALL
SELECT 'Documentation', 'Delay' UNION ALL
SELECT 'Documentation', 'Examination report' UNION ALL
SELECT 'Documentation', 'HLA' UNION ALL
SELECT 'Documentation', 'Laboratory' UNION ALL
SELECT 'Documentation', 'Transcription' UNION ALL
SELECT 'Documentation', 'Other' UNION ALL
SELECT 'Procurement', 'Communication' UNION ALL
SELECT 'Procurement', 'Contamination' UNION ALL
SELECT 'Procurement', 'Documentation' UNION ALL
SELECT 'Procurement', 'Equipment' UNION ALL
SELECT 'Procurement', 'Packaging' UNION ALL
SELECT 'Procurement', 'Procurement report' UNION ALL
SELECT 'Procurement', 'Retrieval injury' UNION ALL
SELECT 'Procurement', 'Procedure' UNION ALL
SELECT 'Procurement', 'Other' UNION ALL
SELECT 'Transport', 'Blood samples' UNION ALL
SELECT 'Transport', 'Communication' UNION ALL
SELECT 'Transport', 'Delay' UNION ALL
SELECT 'Transport', 'Equipment' UNION ALL
SELECT 'Transport', 'Organs' UNION ALL
SELECT 'Transport', 'Weather conditions' UNION ALL
SELECT 'Transport', 'Other'

INSERT IncidentProcessToCategory (IncidentProcessID, IncidentCategoryID)
SELECT
	IncidentProcess.ID,
	IncidentCategory.ID
FROM
	@tblProcessToCategory AS tblS
	INNER JOIN IncidentProcess
		ON IncidentProcess.Description = tblS.strProcess
	INNER JOIN IncidentCategory
		ON IncidentCategory.Description = tblS.strCategory
GO
/*
 * Adding new Column to Incidents
 */
IF NOT EXISTS
	(SELECT 
		* 
	FROM 
		sys.columns 
	WHERE Name = N'CategoryOther' and Object_ID = Object_ID(N'Incident')
	)
BEGIN
	ALTER TABLE Incident ADD CategoryOther NVARCHAR(MAX) NULL
END
GO
/*
 * Adding new Column to TransplantOrgan
 */

IF NOT EXISTS
	(SELECT 
		* 
	FROM 
		sys.columns 
	WHERE Name = N'PrefusionMachine' and Object_ID = Object_ID(N'TransplantOrgan')
	)
BEGIN
	ALTER TABLE TransplantOrgan ADD PrefusionMachine bit DEFAULT(0)
END
GO
UPDATE TransplantOrgan SET PrefusionMachine = 0 WHERE PrefusionMachine IS NULL

IF NOT EXISTS
	(SELECT 
		* 
	FROM 
		sys.columns 
	WHERE Name = N'PrefusionMachineNumber' and Object_ID = Object_ID(N'TransplantOrgan')
	)
BEGIN
	ALTER TABLE TransplantOrgan ADD PrefusionMachineNumber nvarchar(250) DEFAULT('')
END
GO
UPDATE TransplantOrgan SET PrefusionMachineNumber = '' WHERE PrefusionMachineNumber IS NULL

COMMIT

UPDATE [IncidentMail] SET BodyText = 'Your incident declaration have been saved and registered under n°{IncidentNumber}.
Incident administrator will be informed by mail and you will receive a feed-back as soon as possible

Incident administrator
+41 (0)58 123 80 07 / incidentSLIDS@swisstransplant.org' WHERE ID = 1
UPDATE [IncidentMail] SET BodyText = 'Your incident declaration n°{IncidentNumber} registered (date) have been closed
Decision: {CorrectiveAction}
SWT working group involved:	
Improvements:

Incident administrator
+41 (0)58 123 80 07 / incidentSLIDS@swisstransplant.org ' WHERE ID = 3

DECLARE @tblCat TABLE (
	Id int NOT NULL,
	Pos int NOT NULL
)

INSERT @tblCat
SELECT
	ID,
	ROW_NUMBER() OVER (ORDER BY Description)
FROM
	IncidentCategory

UPDATE 
	IncidentCategory
SET
	Position = tblCat.Pos
FROM 
	IncidentCategory
	INNER JOIN @tblCat tblCat
		ON tblCat.Id = IncidentCategory.ID

DECLARE @tblProc TABLE (
	Id int NOT NULL,
	Pos int NOT NULL
)

INSERT @tblProc
SELECT
	ID,
	ROW_NUMBER() OVER (ORDER BY Description)
FROM
	IncidentProcess

UPDATE 
	IncidentProcess
SET
	Position = tblProc.Pos
FROM 
	IncidentProcess
	INNER JOIN @tblProc tblProc
		ON tblProc.Id = IncidentProcess.ID