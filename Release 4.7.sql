-- =============================================
-- Author:	Martin Plüss
--		PENTAG Informatik AG
-- Create date: 04.05.2022
-- Description:	Updates SLIDS Rel. 4.7
-- Version:		1.0
-- Release:		4.7
-- =============================================

SET IMPLICIT_TRANSACTIONS OFF
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

-- =============================================
-- Martin Plüss
-- Update SLIDS DB
-- =============================================


DECLARE @strName nvarchar(255)

BEGIN TRY
	BEGIN TRANSACTION UpdateDB
				
			IF NOT EXISTS(
			SELECT *
			FROM sys.columns 
			WHERE Name      = N'Nut'
			  AND Object_ID = Object_ID(N'Donor'))
		BEGIN
			ALTER TABLE [dbo].[Donor]
			ADD [Nut] [BIT] NOT NULL DEFAULT 0;
			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'Nut', @value=N'Nut';
		END

		IF NOT EXISTS(
			SELECT *
			FROM sys.columns 
			WHERE Name      = N'ID_DonationPathway'
			  AND Object_ID = Object_ID(N'Donor'))
		BEGIN
			ALTER TABLE [dbo].[Donor]
			ADD [ID_DonationPathway] [int] NULL;
			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'Donor', @level2type=N'COLUMN',@level2name=N'ID_DonationPathway', @value=N'ID_DonationPathway';
		END
		
		
		IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'DonationPathway')
		BEGIN
			CREATE TABLE [dbo].[DonationPathway](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[Name] [varchar](64) NOT NULL,
				[Position] [int] NULL,
				[isActive] [bit] NOT NULL				
				
			 CONSTRAINT [PK_DonationPathway] PRIMARY KEY CLUSTERED 
			(	[ID] ASC	
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
			) ON [Data01];

			ALTER TABLE [dbo].[Donor]  WITH CHECK ADD  CONSTRAINT [FK_DonationPathway_Donor] FOREIGN KEY([ID_DonationPathway])
			REFERENCES [dbo].[DonationPathway]([ID]);
			

			ALTER TABLE [dbo].[Donor] CHECK CONSTRAINT [FK_DonationPathway_Donor]

			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DonationPathway', @value=N'DonationPathway';
			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'DonationPathway', @level2type=N'COLUMN',@level2name=N'ID', @value=N'Schlüssel, Eindeutige fortlaufende Zahl';
		END
		
		SET @strName = 'DBD';
		IF NOT EXISTS (SELECT * FROM DonationPathway WHERE Name = @strName)
		BEGIN
			
		INSERT DonationPathway (Name, Position, isActive)
		SELECT	
			Name = @strName,
			Position = 0,
			isActive = 1
			
		END
		
		SET @strName = 'DCD III';
		IF NOT EXISTS (SELECT * FROM DonationPathway WHERE Name = @strName)
		BEGIN
			
		INSERT DonationPathway (Name, Position, isActive)
		SELECT	
			Name = @strName,
			Position = 1,
			isActive = 1
		END

		DECLARE @sql NVARCHAR(MAX);
		IF not Exists (Select * from sys.objects where name ='GetTranportedVehicle'  and type =N'FN')
			BEGIN
				
				SET @sql = N'CREATE FUNCTION GetTranportedVehicle(@TransplantOrganID int) RETURNS VARCHAR(max) AS
					BEGIN
						DECLARE @LIST varchar(1024)
						SELECT @LIST = Coalesce(@List + '', '', '''') + Vehicle.Name 
						from Transport  
						join TransportedOrgan on TransportedOrgan.TransportID = Transport.ID 
						join Vehicle on Vehicle.ID  = Transport.VehicleID
						where TransportedOrgan.TransplantOrganID = @TransplantOrganID
						RETURN @List
					END'
				EXEC sp_executesql @sql;
		END

		IF not Exists (Select * from sys.objects where name ='GetTranportedFirstDeparture'  and type =N'FN')
			BEGIN
				
				SET @sql = N'Create FUNCTION GetTranportedFirstDeparture(@TransplantOrganID int) RETURNS DATETIME AS
				BEGIN
					DECLARE @LIST DATETIME
					SELECT Top 1 @LIST =  Transport.Departure 
					from TransportedOrgan 
					join Transport on Transport.ID =TransportedOrgan.TransportID
					where TransportedOrgan.TransplantOrganID = @TransplantOrganID order by Transport.Departure desc
					RETURN @List
				END'
				EXEC sp_executesql @sql;
		END

		IF not Exists (Select * from sys.objects where name ='GetTranportedLastArrival'  and type =N'FN')
			BEGIN
				SET @sql = N'Create FUNCTION GetTranportedLastArrival(@TransplantOrganID int) RETURNS DATETIME AS
				BEGIN

					DECLARE @LIST DATETIME
					SELECT Top 1 @LIST =  Transport.Arrival 
					from TransportedOrgan 
					join Transport on Transport.ID =TransportedOrgan.TransportID
					where TransportedOrgan.TransplantOrganID = @TransplantOrganID order by Transport.Arrival asc
					RETURN @List
				END'
				EXEC sp_executesql @sql;
		END

		IF not Exists (Select * from sys.objects where name ='StatsDonorWhiteTransporttime')
			BEGIN
				SET @sql = N'Create VIEW StatsDonorWhiteTransporttime
					as
					SELECT
						DonorNumber as ''Donor Number'',
						isnull(dp.Name, '''') as ''Donor Typ'',
						CASE d.Nut
							WHEN 1 THEN ''WAHR''
							WHEN 0 THEN ''FALSCH''
							ELSE null
							END
						as ''NUT'',
						o.Name as ''Organ'',
						d.RegisterDate as ''Register Date'',
						d.ProcurementDate as ''Procurement Date'',
						hTx.Name as ''Transplantation Center'',
						hProc.Display as ''Procurement Hospital'',
						isnull(tc.FirstName, '''') + '' '' + isnull(tc.LastName, '''') as ''Transplant Coordinator'', 
						procTeam.Display as ''Procurement Team'',
						dbo.GetTranportedVehicle(txo.id) as ''Organ Transport mean'',
						dbo.GetTranportedFirstDeparture(txo.id) as ''Start Transport Organ'',
						dbo.GetTranportedLastArrival(txo.id) as ''End Transport Organ''
					FROM Donor d
					LEFT JOIN Hospital hProc ON hProc.ID = d.ProcurementHospitalID
					LEFT JOIN TransplantOrgan txo ON txo.DonorID = d.ID AND txo.IsDeleted = 0
					LEFT JOIN Organ o ON o.ID = txo.OrganID
					LEFT JOIN Hospital hTx ON hTx.ID = txo.TransplantCenterID
					LEFT JOIN TransplantStatus s ON s.ID = txo.TransplantStatusID
					LEFT JOIN Coordinator tc ON tc.ID = txo.TCID
					LEFT JOIN Hospital procTeam ON procTeam.ID = txo.ProcurementTeamID
					Left Join DonationPathway dp on dp.ID = d.ID_DonationPathway
					WHERE d.IsDeleted = 0'
				EXEC sp_executesql @sql;
		END

		IF NOT EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = N'PasswordResetToken')
		BEGIN
			CREATE TABLE [dbo].[PasswordResetToken](
				[ID] [int] IDENTITY(1,1) NOT NULL,
				[UserName] [varchar](64) NOT NULL,
				[Token] [varchar](32) NULL,
				[DateCreated] [datetime] NOT NULL				
				
			 CONSTRAINT [PK_PasswordResetToken] PRIMARY KEY CLUSTERED 
			(	[ID] ASC	
			)WITH (PAD_INDEX  = OFF, STATISTICS_NORECOMPUTE  = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS  = ON, ALLOW_PAGE_LOCKS  = ON) ON [Data01]
			) ON [Data01];

			
			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PasswordResetToken', @value=N'PasswordResetToken';
			EXEC sys.sp_addextendedproperty @name=N'MS_Description', @level0type=N'SCHEMA',@level0name=N'dbo', @level1type=N'TABLE',@level1name=N'PasswordResetToken', @level2type=N'COLUMN',@level2name=N'ID', @value=N'Schlüssel, Eindeutige fortlaufende Zahl';
		END

		update ReminderLetter set TextBlockB = 'Für Fragen steht Ihnen Frau Huber gerne zur Verfügung, melanie.huber@swisstransplant.org' where ID = 1;
		update ReminderLetter set TextBlockB = 'Si vous avez des questions ou souhaitez recevoir de plus amples informations, veuillez-vous adressez à Madame Huber au melanie.huber@swisstransplant.org' where ID = 2;
		update ReminderLetter set TextBlockB = 'In caso di domande si rivolga alla Signora Huber, melanie.huber@swisstransplant.org' where ID = 3;


	COMMIT TRANSACTION UpdateDB
	PRINT 'Done'
END TRY
BEGIN CATCH
	IF (@@TRANCOUNT > 0)
	BEGIN
		ROLLBACK TRANSACTION UpdateDB
		PRINT 'Error thrown, reverting changes..'
	END
   	SELECT
        ERROR_NUMBER() AS ErrorNumber,
        ERROR_SEVERITY() AS ErrorSeverity,
        ERROR_STATE() AS ErrorState,
        ERROR_PROCEDURE() AS ErrorProcedure,
        ERROR_LINE() AS ErrorLine,
        ERROR_MESSAGE() AS ErrorMessage
END CATCH

GO
