BEGIN TRAN

UPDATE SLIDS SET DBVersion = '4.6', Applied = GETDATE()

ALTER TABLE Organization ALTER COLUMN [Name] nvarchar(100)

IF NOT EXISTS(SELECT ID FROM Organization WHERE Name = 'National Bureau on Transplantation under Ministry of Health Lithuania (NTB), LTI') BEGIN
	INSERT Organization (Name, isActive)
	SELECT 'National Bureau on Transplantation under Ministry of Health Lithuania (NTB), LTI', 1
END

-- Removing QualityOfProcurementWasBad from TransplantOrgan
IF EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'QualityOfProcurementWasBad'
          AND Object_ID = Object_ID(N'TransplantOrgan'))
BEGIN
	DECLARE @sql NVARCHAR(MAX)
	WHILE 1=1
	BEGIN
		SELECT TOP 1 @sql = N'alter table TransplantOrgan drop constraint ['+dc.NAME+N']'
		from sys.default_constraints dc
		JOIN sys.columns c
			ON c.default_object_id = dc.object_id
		WHERE 
			dc.parent_object_id = OBJECT_ID('TransplantOrgan')
		AND c.name = N'QualityOfProcurementWasBad'
		IF @@ROWCOUNT = 0 BREAK
		EXEC (@sql)
	END

	ALTER TABLE TransplantOrgan DROP COLUMN QualityOfProcurementWasBad
END


IF NOT EXISTS(SELECT 1 FROM sys.columns 
          WHERE Name = N'Remark'
          AND Object_ID = Object_ID(N'TransplantOrgan'))
BEGIN
	ALTER TABLE TransplantOrgan ADD Remark nvarchar(max) null
END

COMMIT TRAN


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
			'Transplant Status' = s.Name,
			'Lifeport' = CASE WHEN o.Name LIKE 'Kidney%' THEN
				CASE txo.PrefusionMachine
					WHEN 1 THEN 'yes'
					WHEN 0 THEN 'no'
					ELSE null
					END
			END,
			'Ex Vivo' = CASE WHEN o.Name LIKE 'Lung%' THEN
				CASE txo.PrefusionMachine
					WHEN 1 THEN 'yes'
					WHEN 0 THEN 'no'
					ELSE null
					END
			END,
			'Hope' = CASE WHEN o.Name LIKE 'Liver%' THEN
				CASE txo.PrefusionMachine
					WHEN 1 THEN 'yes'
					WHEN 0 THEN 'no'
					ELSE null
					END
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

GO
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
	CASE d.IncisionMade
		WHEN 1 THEN 'yes'
		WHEN 0 THEN 'no'
		ELSE null
		END
	as 'Incision made',
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