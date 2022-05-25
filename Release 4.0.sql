USE [SLIDS]
GO

/*--------------------------------------------------------------------------------------------------
	-- Membership bezogene Daten: Neue Rollen Incident Admin und Swisstransplant hinzufügen
--------------------------------------------------------------------------------------------------*/
DECLARE @ApplicationId AS Uniqueidentifier
SET @ApplicationId = (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = 'SLIDS')


IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'incidentadmin')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'IncidentAdmin', 'incidentadmin', 'Incident Administrator')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'incidentuser')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'IncidentUser', 'incidentuser', 'Incident User')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'swisstransplant')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'Swisstransplant', 'swisstransplant', 'Swisstransplant')
END


/* Inciden Tool Tables */
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

/* Inciden Tool Data Entries */
--insert IncidentState
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'New')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('New', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'In Process')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('In Process', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'Closed')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('Closed', 3, 3)
END

--insert IncidentProcess
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Procurement')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Procurement', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Transport')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Transport', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Donormanagement')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Donormanagement', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Documentation')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Documentation', 4, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Allocation')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Allocation', 5, 5)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Packing')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Packing', 6, 6)
END

--insert IncidentCategory
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Software')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Software', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Means of Transport')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Means of Transport', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Hardware')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Hardware', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Human error')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Human error', 4, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Equipment')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Equipment', 5, 5)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Communication')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Communication', 6, 6)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'SOAS')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('SOAS', 7, 7)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Other')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Other', 8, 8)
END

--insert IncidentDamageCategory
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Catastrophic')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Catastrophic', 7, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Major')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Major', 5, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Moderate')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Moderate', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Minor')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Minor', 1, 4)
END

--insert IncidentPotentialDamage
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'High')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('High', 1, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'Moderate')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('Moderate', 2, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'Low')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('Low', 3, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'No')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('No', 4, 1)
END



--insert IncidentLikelihoodToRepeat
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Exceptional')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Exceptional', 1, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Rare')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Rare', 2, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Occasional')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Occasional', 3, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Frequent')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Frequent', 4, 1)
END


/*Incident Lexicon Preentries*/
DECLARE @tblEntries TABLE (
	strDefinition varchar(50)
)

INSERT @tblEntries
SELECT 'Incident No' UNION ALL
SELECT 'ST/RS/FO No' UNION ALL
SELECT 'Date of Event' UNION ALL
SELECT 'Time of Event' UNION ALL
SELECT 'Location' UNION ALL
SELECT 'Incident Description' UNION ALL
SELECT 'Persons Involved' UNION ALL
SELECT 'Impact' UNION ALL
SELECT 'Suggestions / Propositions' UNION ALL
SELECT 'Process' UNION ALL
SELECT 'Category' UNION ALL
SELECT 'Documents' UNION ALL
SELECT 'State of Incident' UNION ALL
SELECT 'Damage Category' UNION ALL
SELECT 'Potential Damage' UNION ALL
SELECT 'Likelihood to Repeat' UNION ALL
SELECT 'Damage Descritpion' UNION ALL
SELECT 'Risk scaling number' UNION ALL
SELECT 'Corrective action' UNION ALL
SELECT 'Preventive action'

INSERT IncidentLexicon (
	Definition,
	InfoDescription,
	IsDeleted
)
SELECT
	strDefinition, 
	strDefinition, 
	0 
FROM 
	@tblEntries
WHERE
	NOT strDefinition IN(SELECT Definition FROM IncidentLexicon)

---------------------------------------------
-- IncidentAlert to Hospital
---------------------------------------------
IF OBJECT_ID ('dbo.IncidentAlertHospital', 'Table') > 0
    DROP Table [dbo].[IncidentAlertHospital]

CREATE TABLE [dbo].[IncidentAlertHospital](
    IncidentAlertID int  NOT NULL,
    HospitalID int  NOT NULL,
	CONSTRAINT [PK_IncidentAlertHospital] PRIMARY KEY CLUSTERED 
    (
        IncidentAlertID ASC,
        HospitalID ASC
    )WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [DATA01]    
) ON [Data01]
GO
--foreign Keys
ALTER TABLE [dbo].[IncidentAlertHospital]  WITH CHECK ADD CONSTRAINT [FK_IncidentAlertHospital_IncidentAlert] FOREIGN KEY(IncidentAlertID)
REFERENCES [dbo].[IncidentAlert] ([ID])
GO
ALTER TABLE [dbo].[IncidentAlertHospital] CHECK CONSTRAINT [FK_IncidentAlertHospital_IncidentAlert]
GO
ALTER TABLE [dbo].[IncidentAlertHospital]  WITH CHECK ADD CONSTRAINT [FK_IncidentAlertHospital_Hospital] FOREIGN KEY(HospitalID)
REFERENCES [dbo].Hospital ([ID])
GO
ALTER TABLE [dbo].[IncidentAlertHospital] CHECK CONSTRAINT [FK_IncidentAlertHospital_Hospital]
GO

--descriptions
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Listing Incident Alerts to Hospital they relate with' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlertHospital'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing TransplantOrgan' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlertHospital', @level2type=N'COLUMN',@level2name=N'IncidentAlertID'
GO
EXEC sys.sp_addextendedproperty @name=N'MS_Description', @value=N'Foreign key referencing Transport' , @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'IncidentAlertHospital', @level2type=N'COLUMN',@level2name=N'HospitalID'
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
    ID INT IDENTITY(1,1) NOT NULL,
	IncidentStateID int NOT NULL,
	[To] nvarchar(50) NOT NULL,
	[ReplyTo] nvarchar(255) NOT NULL,
	[Subject] nvarchar(255) NOT NULL,
	[BodyText] nvarchar(max) NOT NULL,
	blnEditBefore bit NOT NULL,
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

INSERT IncidentMail (
	[IncidentStateID],
	[To],
	[Subject],
	[BodyText],
	blnEditBefore,
	[ReplyTo]
)
SELECT
	1, -- New
	'{Creator}',
	'New Incident created',
	'Your incident declaration have been saved and registered under n°{IncidentNumber}.
Incident administrator will be informed by mail and you will receive a feed-back as soon as possible

Incident administrator
+41(0)31 380 81 02/incidentSLIDS@swisstransplant.org ',
	0,
	'incidentSLIDS@swisstransplant.org'
UNION ALL
SELECT
	1, -- New
	'{Admin}',
	'New Incident created',
	'A new incident declaration has been registered under n°{IncidentNumber}',
	0,
	'{Creator}'
UNION ALL
SELECT
	3, -- Closed
	'{Creator}',
	'Incident closed',
	'Your incident declaration n°{IncidentNumber} registered (date) have been closed
Decision: {CorrectiveAction}
SWT working group involved:	
Improvements:

Incident administrator
+41(0)31 380 81 02 / incidentSLIDS@swisstransplant.org ',
	1,
	'incidentSLIDS@swisstransplant.org'

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


INSERT aspnet_UsersInRoles
(
	UserId,
	RoleId
)
SELECT 
	UserId,
	(
		SELECT RoleId FROM aspnet_Roles WHERE LoweredRoleName = 'swisstransplant'
	)
FROM 
	aspnet_Users 
WHERE 
	LoweredUserName LIKE 'ST-%'
	AND
	NOT UserId IN(
		SELECT 
			UserId
		FROM
			aspnet_UsersInRoles
			INNER JOIN aspnet_Roles
				ON aspnet_Roles.RoleId = aspnet_UsersInRoles.RoleId
		WHERE
			aspnet_Roles.LoweredRoleName = 'swisstransplant'
	)

IF (
	NOT EXISTS(
		SELECT 
			*
		FROM 
			aspnet_UsersInRoles, 
			aspnet_Users, 
			aspnet_Roles 
		WHERE 
			aspnet_Roles.RoleName = 'IncidentAdmin'
			AND aspnet_Users.UserName = 'Pentag_User'
			AND aspnet_UsersInRoles.UserId = aspnet_Users.UserId
			AND aspnet_UsersInRoles.RoleId = aspnet_Roles.RoleId)) BEGIN
			
	INSERT aspnet_UsersInRoles
	SELECT
		tblUser.UserId,
		tblRoles.RoleId
	FROM
		aspnet_Users AS tblUser,
		aspnet_Roles AS tblRoles
	WHERE
		tblRoles.RoleName = 'IncidentAdmin'
		AND tblUser.UserName = 'Pentag_User'
END
	