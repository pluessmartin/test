USE SLIDS

-- Set new version
------------------
UPDATE SLIDS SET DBVersion = '3.0.1'
GO

-- Statistical Filter is now set depending on Register Date and not Procurement Date as before
-- All Stats-Views will therefore be updated accordingly


/* ----------------------------------------------------------------------------------------------
	Views Donor details
	
	Created:	24.01.2013
	Modified:	11.06.2013		Added Columns Detection Hospital and Comment
				05.02.2014		Added Column Register Date
*/ ----------------------------------------------------------------------------------------------
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

/* ----------------------------------------------------------------------------------------------
	Views Organ details
	
	Created:	24.01.2013
	Modified:	05.02.2014		Added Column Register Date
*/ ----------------------------------------------------------------------------------------------
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

/* ----------------------------------------------------------------------------------------------
	Views Transport details
	
	Created:	24.01.2013
	Modified:	10.06.2013		OrganCount and ItemCount (and TotalCount) take their value from 
								Column CountableAs instead of number of available rows
				05.02.2014		Added Column Register Date
*/ ----------------------------------------------------------------------------------------------
ALTER VIEW [dbo].[StatsTransports]
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

/* ----------------------------------------------------------------------------------------------
	Views General Costs details
	
	Created:	24.01.2013
	Modified:	08.11.2013		Costs which are not related to organs will still appear in 
								Column Amount
				05.02.2014		Added Column Register Date
*/ ----------------------------------------------------------------------------------------------

ALTER VIEW [dbo].[StatsGeneralCosts]
AS
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

/* ----------------------------------------------------------------------------------------------
	Views Transport Costs details
	
	Created:	24.01.2013
	Modified:	05.02.2014		Added Column Register Date
*/ ----------------------------------------------------------------------------------------------
ALTER VIEW [dbo].[StatsTransportCosts]
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