using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS.Reports.DAL
{
    public class Common
    {
        protected static BasePage basePage = new BasePage();

        protected static NLog.Logger logger = NLog.LogManager.GetCurrentClassLogger();

        public Common()
        {
            basePage.Data = null;
        }

        /// <summary>
        /// Get all active Item Groups
        /// </summary>
        /// <returns>list of all active Item Groups</returns>
        public static List<ItemGroup> GetItemGroups()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetItemGroups().Where(ig => ig.isActive).ToList();
        }

        /// <summary>
        /// Gets Itemgroup by ID itemGroupID
        /// </summary>
        /// <param name="itemGroupID">item group ID</param>
        /// <returns>ItemGroup</returns>
        public static ItemGroup GetItemGroupByID(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetItemGroupByID(itemGroupID);
        }

        /// <summary>
        /// Get active Item Groups of type Organ
        /// </summary>
        /// <returns>returns a list of Item Groups of type Organ</returns>
        public static List<ItemGroup> GetOrganItemGroups()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetItemGroupsByType((int)BasePage.ItemGroupType.Organ).Where(ig => ig.isActive).ToList();
        }

        /// <summary>
        /// Gets organs of Item Group using item group ID organItemGroupID
        /// </summary>
        /// <param name="organItemGroupID"></param>
        /// <returns></returns>
        public static List<SLIDS.DAL.Organ> GetOrgansByItemGroupID(int organItemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetOrgansByItemGroup(organItemGroupID).ToList();
        }

        /// <summary>
        /// Gets transplant organs of Item Group using item group ID ItemGroupID
        /// </summary>
        /// <param name="ItemGroupID">item group ID</param>
        /// <param name="procurementHospitalID">procurement hospital</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns list of transplant organs</returns>
        public List<TransplantOrgan> GetTransplantOrgansByItemGroupID(int ItemGroupID, int procurementHospitalID, DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return GetTransplantOrgans(procurementDateFrom, procurementDateTo)
                           .Where(to => to.Organ.ItemGroupID == ItemGroupID)
                           .Where(to => to.ProcurementTeamID == procurementHospitalID)
                           .ToList();
        }

        /// <summary>
        /// Gets transplant organs procured between procurement date from and procurement date to
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns list of transplant organs</returns>
        public List<TransplantOrgan> GetTransplantOrgans(DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            return basePage.GetTransplantOrgans()
                           .Where(to => (procurementDateFrom != null && to.Donor.ProcurementDate >= procurementDateFrom)
                                        || procurementDateFrom == null)
                           .Where(to => (procurementDateFrom != null && to.Donor.ProcurementDate <= procurementDateTo)
                                        || procurementDateTo == null)
                           .ToList();
        }

        /// <summary>
        /// Gets organ with ID organID
        /// </summary>
        /// <param name="organID">Organ ID</param>
        /// <returns>Organ</returns>
        public static SLIDS.DAL.Organ GetOrganByID(int organID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetOrganByID(organID);
        }

        /// <summary>
        /// Get active Item Groups of type TransportItem
        /// </summary>
        /// <returns>returns a list of Item Groups of type TransportItem</returns>
        public static List<ItemGroup> GetTransportItemItemGroups()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetItemGroupsByType((int)BasePage.ItemGroupType.TransportItem).Where(ig => ig.isActive).ToList();
        }

        /// <summary>
        /// Get active Item Groups according to provided itemGroupType
        /// </summary>
        /// <param name="itemGroupType">Item Group Type</param>
        /// <returns>returns a list of Item Groups of type itemGroupType</returns>
        public static List<ItemGroup> GetItemGroupsByType(int itemGroupType)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetItemGroupsByType(itemGroupType).Where(ig => ig.isActive).ToList();
        }

        /// <summary>
        /// Get procured organs of item group with id itemGroupID
        /// </summary>
        /// <param name="itemGroupID">Item Group ID</param>
        /// <param name="procurementDateFrom">Procurement Date From</param>
        /// <param name="procurementDateTo">Procurement Date To</param>
        /// <returns>returns a list of TransplantOrgan</returns>
        public static List<TransplantOrgan> GetProcuredOrgansOfItemGroup(int itemGroupID, DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetTransplantOrgansByItemGroupID(itemGroupID)
                           .Where(to => (procurementDateFrom != null && to.Donor.ProcurementDate >= procurementDateFrom) || procurementDateFrom == null)
                           .Where(to => (procurementDateTo != null && to.Donor.ProcurementDate <= procurementDateTo) || procurementDateTo == null)
                           .ToList();
        }

        /// <summary>
        /// Get transport items of item group with id itemGroupID
        /// </summary>
        /// <param name="itemGroupID">Item Group ID</param>
        /// <returns>returns a list of transport items</returns>
        public static List<TransportItem> GetTransportItemsOfItemGroup(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetTransportItemsByItemGroupID(itemGroupID);
        }

        /// <summary>
        /// Get active vehicles
        /// </summary>
        /// <returns>returns a list of active vehicles</returns>
        public static List<Vehicle> GetVehicles()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetVehicles().Where(v => v.isActive).ToList();
        }

        /// <summary>
        /// Get transports of vehicle with id vehicleID
        /// </summary>
        /// <param name="vehicleID">Vehicle ID</param>
        /// <param name="procurementDateFrom">Procurement Date From</param>
        /// <param name="procurementDateTo">Procurement Date To</param>
        /// <returns>returns list of Transport</returns>
        public static List<SLIDS.DAL.Transport> GetTransportsOfVehicle(int vehicleID, DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            return basePage.GetTransportsByVehicleID(vehicleID)
                           .Where(t => (procurementDateFrom != null && t.Donor.ProcurementDate >= procurementDateFrom) || procurementDateFrom == null)
                           .Where(t => (procurementDateTo != null && t.Donor.ProcurementDate <= procurementDateTo) || procurementDateTo == null)
                           .ToList();
        }

        /// <summary>
        /// Get Transports which are in timeframe (if timeframe is provided)
        /// </summary>
        /// <param name="procurementDateFrom">Procurement Date From</param>
        /// <param name="procurementDateTo">Procurement Date To</param>
        /// <returns>returns list of Transport</returns>
        public static List<SLIDS.DAL.Transport> GetTransports(DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            List<SLIDS.DAL.Transport> transports = basePage.GetTransports()
                                                           .Where(t =>(procurementDateFrom != null && t.Donor.ProcurementDate >= procurementDateFrom) 
                                                                        || procurementDateFrom == null)
                                                           .Where(t => (procurementDateTo != null && t.Donor.ProcurementDate <= procurementDateTo) 
                                                                        || procurementDateTo == null)
                                                           .ToList();

            return transports;
        }

        /// <summary>
        /// Get Donors which are in timeframe (if timeframe is provided)
        /// </summary>
        /// <param name="procurementDateFrom">Procurement Date From</param>
        /// <param name="procurementDateTo">Procurement Date To</param>
        /// <returns>returns list of Donor</returns>
        public static List<Donor> GetDonors(DateTime? procurementDateFrom = null, DateTime? procurementDateTo = null)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            List<Donor> donors = basePage.GetDonors()
                                         .Where(d => (procurementDateFrom != null && d.ProcurementDate >= procurementDateFrom)
                                                     || procurementDateFrom == null)
                                         .Where(d => (procurementDateTo != null && d.ProcurementDate <= procurementDateTo)
                                                     || procurementDateTo == null)
                                         .ToList();

            return donors;
        }

        /// <summary>
        /// Gets all active and swiss procurement hospitals
        /// </summary>
        /// <returns>returns list of procurement hospitals</returns>
        public List<Hospital> GetTransplantationHospitals()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            List<Hospital> hospitals = basePage.GetHospitals()
                                               .Where(h => h.isActive)
                                               .Where(h => h.IsTransplantation)
                                               .Where(h => !h.IsFo)
                                               .ToList();

            return hospitals;
        }
    }
}