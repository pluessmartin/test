--------------------------------------------------------------------------------------------------------------------------------------------
-- This Query can be used to compare values of Statistical Reports, should any differences appear and might be helpful in finding any errors
--------------------------------------------------------------------------------------------------------------------------------------------

DECLARE @dateFrom AS DateTime
DECLARE @dateTo AS DateTime

SET @dateFrom = '2013/01/01'
SET @dateTo = '2013/12/31'

--------------------------------------------
-- Transport costs per removed Organ Overall
--------------------------------------------
SELECT	DISTINCT 
		ig.ID,
		ig.Name AS Organ,
		organCount.Number AS 'Procured Organs',
		totalAmount.Total AS 'Total Costs'
FROM	TransplantOrgan tpo
		INNER JOIN Organ o ON o.ID = tpo.OrganID
		INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
		INNER JOIN Donor d ON d.ID = tpo.DonorID
		INNER JOIN Cost c ON c.DonorID = d.ID
		INNER JOIN OrganCost oc ON oc.CostID = c.ID
		INNER JOIN 
		(
			SELECT	ig.ID,
					SUM(o.CountableAs) AS Number
			FROM	TransplantOrgan tpo
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
					INNER JOIN Donor d ON d.ID = tpo.DonorID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		o.isActive = 1
			AND		ig.isActive = 1
			AND		d.IsDeleted = 0
			GROUP BY ig.ID
		) organCount ON organCount.ID = ig.ID
		INNER JOIN 
		(
			SELECT	ig.ID,
					SUM(oc.Amount) AS Total
			FROM	OrganCost oc
					INNER JOIN Cost c ON c.ID = oc.CostID
					INNER JOIN Donor d ON d.ID = c.DonorID
					INNER JOIN TransplantOrgan tpo ON tpo.ID = oc.TransplantOrganID AND tpo.DonorID = d.ID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
					INNER JOIN CostType ct ON ct.ID = c.CostTypeID
					INNER JOIN CostGroup cg ON cg.ID = ct.CostGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		o.isActive = 1
			AND		ig.isActive = 1
			AND		d.IsDeleted = 0
			AND		c.IsDeleted = 0
			AND		cg.ID = 1 -- Transport
			GROUP BY ig.ID
		) totalAmount ON totalAmount.ID = ig.ID --AND organCount.ID = totalAmount.ID
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		o.isActive = 1
AND		ig.isActive = 1
AND		d.IsDeleted = 0
AND		tpo.IsDeleted = 0
AND		c.IsDeleted = 0
GROUP BY	ig.ID, 
			ig.Name, 
			organCount.Number, 
			totalAmount.Total
ORDER BY	ig.ID


----------------------------------------
-- Transport costs per mean of transport
----------------------------------------
SELECT	v.ID, 
		v.Name ,
		transportCount.Transports,
		transportCosts.[Total Costs]
FROM	Vehicle v
		INNER JOIN Transport t ON t.VehicleID = v.ID
		INNER JOIN Donor d ON d.ID = t.DonorID
		INNER JOIN 
		(
			SELECT	v.ID, 
					v.Name ,
					COUNT(DISTINCT t.ID) AS Transports
			FROM	Vehicle v
					INNER JOIN Transport t ON t.VehicleID = v.ID
					INNER JOIN Donor d ON d.ID = t.DonorID
					LEFT JOIN Cost c ON c.TransportID = t.ID AND c.DonorID = d.ID
					LEFT JOIN CostType ct ON ct.ID = c.CostTypeID
					LEFT JOIN CostGroup cg ON cg.ID = ct.CostGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		v.isActive = 1
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			GROUP BY v.ID, v.Name
		) transportCount ON transportCount.ID = v.ID
		INNER JOIN
		(
			SELECT	v.ID, 
					v.Name,
					SUM(c.Amount) AS 'Total Costs'
			FROM	Vehicle v
					INNER JOIN Transport t ON t.VehicleID = v.ID
					INNER JOIN Donor d ON d.ID = t.DonorID
					INNER JOIN Cost c ON c.TransportID = t.ID AND c.DonorID = d.ID
					INNER JOIN CostType ct ON ct.ID = c.CostTypeID
					INNER JOIN CostGroup cg ON cg.ID = ct.CostGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		v.isActive = 1
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		c.IsDeleted = 0
			AND		cg.ID = 1 -- Transport
			GROUP BY v.ID, v.Name
		) transportCosts ON transportCosts.ID = v.ID

WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		v.isActive = 1
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY	v.ID, 
			v.Name, 
			transportCount.Transports, 
			transportCosts.[Total Costs]
ORDER BY	v.ID


------------------------------------------------------------
-- Transport costs per mean of transport separated per organ
------------------------------------------------------------
DECLARE @itemGroup AS INT
SET @itemGroup = 1
SELECT	v.ID, 
		v.Name ,
		transportCount.Transports,
		ISNULL(transportCosts.[Total Costs], 0.00)
FROM	Vehicle v
		INNER JOIN Transport t ON t.VehicleID = v.ID
		INNER JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
		INNER JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
		INNER JOIN Organ o ON o.ID = tpo.OrganID
		INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
		INNER JOIN Donor d ON d.ID = t.DonorID
		LEFT JOIN 
		(
			SELECT	v.ID, 
					v.Name ,
					COUNT(DISTINCT t.ID) AS Transports
			FROM	Vehicle v
					INNER JOIN Transport t ON t.VehicleID = v.ID
					INNER JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					INNER JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
					INNER JOIN Donor d ON d.ID = t.DonorID
					LEFT JOIN Cost c ON c.TransportID = t.ID AND c.DonorID = d.ID
					LEFT JOIN CostType ct ON ct.ID = c.CostTypeID
					LEFT JOIN CostGroup cg ON cg.ID = ct.CostGroupID
					LEFT JOIN OrganCost oc ON oc.CostID = c.ID AND oc.TransplantOrganID = tpo.ID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		v.isActive = 1
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		ig.ID = @itemGroup
			GROUP BY v.ID, v.Name
		) transportCount ON transportCount.ID = v.ID
		LEFT JOIN
		(
			SELECT	v.ID, 
					v.Name,
					SUM(oc.Amount) AS 'Total Costs'
			FROM	Vehicle v
					INNER JOIN Transport t ON t.VehicleID = v.ID
					INNER JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					INNER JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
					INNER JOIN Donor d ON d.ID = t.DonorID
					INNER JOIN Cost c ON c.TransportID = t.ID AND c.DonorID = d.ID
					INNER JOIN CostType ct ON ct.ID = c.CostTypeID
					INNER JOIN CostGroup cg ON cg.ID = ct.CostGroupID
					INNER JOIN OrganCost oc ON oc.CostID = c.ID AND oc.TransplantOrganID = tpo.ID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		v.isActive = 1
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		c.IsDeleted = 0
			AND		cg.ID = 1 -- Transport
			AND		ig.ID = @itemGroup
			GROUP BY v.ID, v.Name
		) transportCosts ON transportCosts.ID = v.ID

WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		v.isActive = 1
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
AND		ig.ID = @itemGroup
GROUP BY	v.ID, 
			v.Name, 
			transportCount.Transports, 
			transportCosts.[Total Costs]
ORDER BY	v.ID


---------------------------------------------------------
-- Transport costs separated per organ and transport item

-- Remarks: this query only covers organ costs. 
--			costs for item groups only apply if 
--			organ is not transported. this is not
--			in this query due to complexity and time
--			shortage
--			plus, this query doesn't include organ costs
--			if organ was not transported but costs have
--			been attribuated			
---------------------------------------------------------
SELECT	ig.ID,
		ig.Name,
		transportCount.Transports,
		organGroupCosts.[Total Costs]
FROM	Transport t
		INNER JOIN Donor d ON d.ID = t.DonorID
		LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
		LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
		LEFT JOIN Organ o ON o.ID = tpo.OrganID
		LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
		LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
		LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
		LEFT JOIN
		(
			SELECT	ig.ID,
					ig.Name,
					COUNT(DISTINCT t.ID) AS Transports
			FROM	Transport t
					INNER JOIN Donor d ON d.ID = t.DonorID
					LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					LEFT JOIN Organ o ON o.ID = tpo.OrganID
					LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
					LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
					LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			GROUP BY ig.ID, ig.Name
		) transportCount ON transportCount.ID = ig.ID
		LEFT JOIN
		(
			SELECT	ig.ID, 
					ig.Name,
					SUM(oc.Amount) AS 'Total Costs'
			FROM	Transport t
					INNER JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					INNER JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
					INNER JOIN Donor d ON d.ID = t.DonorID
					INNER JOIN Cost c ON c.TransportID = t.ID AND c.DonorID = d.ID
					INNER JOIN CostType ct ON ct.ID = c.CostTypeID
					INNER JOIN CostGroup cg ON cg.ID = ct.CostGroupID
					INNER JOIN OrganCost oc ON oc.CostID = c.ID AND oc.TransplantOrganID = tpo.ID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		c.IsDeleted = 0
			AND		cg.ID = 1 -- Transport
			GROUP BY ig.ID, ig.Name
		) organGroupCosts ON organGroupCosts.ID = ig.ID

WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY ig.ID, ig.Name, transportCount.Transports, organGroupCosts.[Total Costs]
ORDER BY ig.ID


---------------------------------------------
-- Transports of organs per mean of transport
---------------------------------------------
SELECT	ig.ID,
		ig.Name,
		v.Name AS Vehicle,
		COUNT(DISTINCT t.ID) AS Transports
FROM	Transport t
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN Donor d ON d.ID = t.DonorID
		INNER JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
		INNER JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
		INNER JOIN Organ o ON o.ID = tpo.OrganID
		INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY ig.ID, ig.Name, v.Name
ORDER BY ig.ID, v.Name


--------------------------------------------
-- Transports of items per mean of transport
--------------------------------------------
SELECT	ig.ID,
		ig.Name,
		v.Name AS Vehicle,
		COUNT(DISTINCT t.ID) AS Transports
FROM	Transport t
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN Donor d ON d.ID = t.DonorID
		INNER JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
		INNER JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
		INNER JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY ig.ID, ig.Name, v.Name
ORDER BY ig.ID, v.Name


--------------------------------------------------------
-- Duration of transports per organs and transport items
--------------------------------------------------------
SELECT	ig.ID,
		ig.Name,
		v.Name AS Vehicle,
		transportCount.[Count],
		CONVERT(varchar(8), DATEADD(SECOND, transportDuration.Seconds / transportCount.[Count], 0),  108) AS AverageDuration
FROM	Transport t
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN Donor d ON d.ID = t.DonorID
		LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
		LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
		LEFT JOIN Organ o ON o.ID = tpo.OrganID
		LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
		LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
		LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
		LEFT JOIN
		(
			SELECT	ig.ID,
					ig.Name,
					v.Name AS Vehicle,
					COUNT(DISTINCT t.ID) AS 'Count'
			FROM	Transport t
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN Donor d ON d.ID = t.DonorID
					LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					LEFT JOIN Organ o ON o.ID = tpo.OrganID
					LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
					LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
					LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			GROUP BY ig.ID, ig.Name, v.Name
		) transportCount ON transportCount.ID = ig.ID AND transportCount.Vehicle = v.Name
		LEFT JOIN
		(
			SELECT	ig.ID,
					ig.Name,
					v.Name AS Vehicle,
					SUM(DATEDIFF(SECOND, t.Departure, t.Arrival)) AS Seconds
			FROM	Transport t
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN Donor d ON d.ID = t.DonorID
					LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
					LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
					LEFT JOIN Organ o ON o.ID = tpo.OrganID
					LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
					LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
					LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			GROUP BY ig.ID, ig.Name, v.Name
		) transportDuration ON transportDuration.ID = ig.ID AND transportDuration.Vehicle = v.Name
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY ig.ID, ig.Name, v.Name, transportCount.[Count], transportDuration.Seconds
ORDER BY ig.ID, v.Name


-------------------------------------
-- Waiting Time per mean of Transport
-------------------------------------
SELECT	ig.ID,
		ig.Name,
		v.Name AS Vehicle,
		LEFT(CONVERT(TIME, DATEADD(MINUTE, SUM(t.WaitingTime), 0)), 5)
FROM	Transport t
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN Donor d ON d.ID = t.DonorID
		LEFT JOIN TransportedOrgan tpdo ON tpdo.TransportID = t.ID
		LEFT JOIN TransplantOrgan tpo ON tpo.ID = tpdo.TransplantOrganID
		LEFT JOIN Organ o ON o.ID = tpo.OrganID
		LEFT JOIN TransportedItem tpdi ON tpdi.TransportID = t.ID
		LEFT JOIN TransportItem tpi ON tpi.ID = tpdi.TransportItemID
		LEFT JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID OR ig.ID = o.ItemGroupID
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
GROUP BY ig.ID, ig.Name, v.Name
ORDER BY ig.ID


---------------------------
-- Procured organs per team
---------------------------
SELECT	h.Display,
		ig.ID,
		ig.Name,
		ISNULL(intern.[Count], 0) AS Intern,
		ISNULL(extern.[Count], 0) AS Extern
FROM	Donor d 
		INNER JOIN TransplantOrgan tpo ON tpo.DonorID = d.ID
		INNER JOIN Hospital h ON h.ID = tpo.ProcurementTeamID
		INNER JOIN Organ o ON o.ID = tpo.OrganID
		INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
		LEFT JOIN
		(
			SELECT	ig.ID,
					ig.Name,
					h.Display,
					SUM(o.CountableAs) AS [Count]
			FROM	Donor d 
					INNER JOIN TransplantOrgan tpo ON tpo.DonorID = d.ID
					INNER JOIN Hospital h ON h.ID = tpo.ProcurementTeamID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		h.isActive = 1
			AND		h.IsTransplantation = 1
			AND		h.IsFo = 0
			AND		(tpo.TransplantCenterID IS NOT NULL
					AND tpo.ProcurementTeamID IS NOT NULL
					AND tpo.TransplantCenterID = tpo.ProcurementTeamID)
			GROUP BY ig.ID, ig.Name, h.Display
		) intern ON intern.ID = ig.ID AND intern.Display = h.Display
		LEFT JOIN
		(
			SELECT	ig.ID,
					ig.Name,
					h.Display,
					SUM(o.CountableAs) AS [Count]
			FROM	Donor d 
					INNER JOIN TransplantOrgan tpo ON tpo.DonorID = d.ID
					INNER JOIN Hospital h ON h.ID = tpo.ProcurementTeamID
					INNER JOIN Organ o ON o.ID = tpo.OrganID
					INNER JOIN ItemGroup ig ON ig.ID = o.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		h.isActive = 1
			AND		h.IsTransplantation = 1
			AND		h.IsFo = 0
			AND		(tpo.TransplantCenterID IS NOT NULL
					AND tpo.ProcurementTeamID IS NOT NULL
					AND tpo.TransplantCenterID != tpo.ProcurementTeamID)
			GROUP BY ig.ID, ig.Name, h.Display
		) extern ON extern.ID = ig.ID AND extern.Display = h.Display

WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		h.isActive = 1
AND		h.IsTransplantation = 1
AND		h.IsFo = 0
GROUP BY ig.ID, ig.Name, h.Display, intern.[Count], extern.[Count]
ORDER BY h.Display, ig.ID


----------------------
-- Transports of Blood
----------------------
SELECT	tpi.ID,
		tpi.Name,
		v.Name,
		transportCount.Transports AS 'Count',
		CONVERT(varchar(8), DATEADD(SECOND, transportDuration.Seconds / transportCount.Transports, 0),  108) AS AverageDuration
FROM	Donor d 
		INNER JOIN Transport t ON d.ID = t.DonorID
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN TransportedItem tpdi ON t.ID = tpdi.TransportID
		INNER JOIN TransportItem tpi ON tpdi.TransportItemID = tpi.ID
		INNER JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID
		LEFT JOIN
		(
			SELECT	tpi.ID,
					tpi.Name,
					v.Name AS Vehicle,
					COUNT(DISTINCT t.ID) AS Transports
			FROM	Donor d 
					INNER JOIN Transport t ON d.ID = t.DonorID
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN TransportedItem tpdi ON t.ID = tpdi.TransportID
					INNER JOIN TransportItem tpi ON tpdi.TransportItemID = tpi.ID
					INNER JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		v.isActive = 1
			AND		ig.Name = 'Blood'
			GROUP BY tpi.ID, tpi.Name, v.Name
		) transportCount ON transportCount.ID = tpi.ID AND transportCount.Vehicle = v.Name
		LEFT JOIN
		(
			SELECT	tpi.ID,
					tpi.Name,
					v.Name AS Vehicle,
					SUM(DATEDIFF(SECOND, t.Departure, t.Arrival)) AS Seconds
			FROM	Donor d 
					INNER JOIN Transport t ON d.ID = t.DonorID
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN TransportedItem tpdi ON t.ID = tpdi.TransportID
					INNER JOIN TransportItem tpi ON tpdi.TransportItemID = tpi.ID
					INNER JOIN ItemGroup ig ON ig.ID = tpi.ItemGroupID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		v.isActive = 1
			AND		ig.Name = 'Blood'
			GROUP BY tpi.ID, tpi.Name, v.ID, v.Name
		) transportDuration ON transportDuration.ID = tpi.ID AND transportDuration.Vehicle = v.Name
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
AND		v.isActive = 1
AND		ig.Name = 'Blood'
GROUP BY tpi.ID, tpi.Name, v.Name, v.ID, transportCount.Transports, transportDuration.Seconds
ORDER BY tpi.Name, v.ID


---------
-- Delays
---------
SELECT	DISTINCT
		d.DonorNumber,
		delayVehicle.Vehicle,
		LEFT(CONVERT(TIME, delayDuration.Duration), 5),
		STUFF(ISNULL((	SELECT	'; ' + dlr.Reason
						FROM	[Delay] dl
								INNER JOIN DelayReason dlr ON dlr.ID = dl.DelayReasonID
						WHERE	dl.TransportID = t.ID
						GROUP BY dlr.Reason
						FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 2, '') 'Delay Reason',
		STUFF(ISNULL((	SELECT	'; ' + dl.Comment
						FROM	[Delay] dl
						WHERE	dl.TransportID = t.ID
						GROUP BY dl.Comment
						FOR XML PATH (''), TYPE).value('.','VARCHAR(max)'), ''), 1, 2, '') [Comment]
FROM	Donor d
		INNER JOIN Transport t ON d.ID = t.DonorID
		INNER JOIN Vehicle v ON v.ID = t.VehicleID
		INNER JOIN [Delay] dl ON dl.TransportID = t.ID
		INNER JOIN DelayReason dlr ON dlr.ID = dl.DelayReasonID
		LEFT JOIN
		(
			SELECT	d.DonorNumber,
					v.Name AS Vehicle
			FROM	Donor d
					INNER JOIN Transport t ON d.ID = t.DonorID
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN [Delay] dl ON dl.TransportID = t.ID
					INNER JOIN DelayReason dlr ON dlr.ID = dl.DelayReasonID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		v.isActive = 1
			GROUP BY d.DonorNumber, v.Name
		) delayVehicle ON delayVehicle.DonorNumber = d.DonorNumber AND delayVehicle.Vehicle = v.Name
		LEFT JOIN
		(
			SELECT	d.DonorNumber,
					v.Name AS Vehicle,
					DATEADD(ms, SUM(DATEDIFF(ms, '00:00:00.000', dl.Duration)), '00:00:00.000') AS Duration
			FROM	Donor d
					INNER JOIN Transport t ON d.ID = t.DonorID
					INNER JOIN Vehicle v ON v.ID = t.VehicleID
					INNER JOIN [Delay] dl ON dl.TransportID = t.ID
					INNER JOIN DelayReason dlr ON dlr.ID = dl.DelayReasonID
			WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
			AND		d.IsDeleted = 0
			AND		t.IsDeleted = 0
			AND		v.isActive = 1
			GROUP BY d.DonorNumber, v.Name
		) delayDuration ON delayDuration.DonorNumber = d.DonorNumber AND delayDuration.Vehicle = v.Name
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		t.IsDeleted = 0
AND		v.isActive = 1


--------------------------------------
-- Procurement of Organ in bad Quality
--------------------------------------
SELECT	d.DonorNumber,
		o.Name AS Organ,
		'Bad',
		h.Display,
		tpo.ProcurementSurgeon
FROM	Donor d
		INNER JOIN TransplantOrgan tpo ON d.ID = tpo.DonorID
		INNER JOIN Organ o ON o.ID = tpo.OrganID
		INNER JOIN Hospital h ON h.ID = tpo.ProcurementTeamID
WHERE	(d.ProcurementDate >= @dateFrom AND d.ProcurementDate <= @dateTo)
AND		d.IsDeleted = 0
AND		o.isActive = 1
AND		h.isActive = 1
AND		tpo.QualityOfProcurementWasBad = 1