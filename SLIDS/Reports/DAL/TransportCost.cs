using System;
using System.Collections.Generic;
using System.Linq;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS.Reports.DAL
{
    #region reports data structures

    public class ProcurementHospitalWithCosts
    {
        public int ID { get; set; }
        public String Name { get; set; }
        public String Display { get; set; }
        public decimal? ICCosts { get; set; }
        public decimal? OCCosts { get; set; }
        public decimal? TotalCosts { get; set; }
    }

    public class TransportCostPerRemovedOrganOverall
    {
        public string OrganGroup { get; set; }
        public int? ProcuredOrganCount { get; set; }
        public decimal? TotalCosts { get; set; }
        public decimal? AverageCosts { get; set; }
        public decimal? Min { get; set; }
        public decimal? Max { get; set; }

        public TransportCostPerRemovedOrganOverall(string organGroup, int? procuredOrganCount, decimal? totalCosts, decimal? averageCosts, decimal? min, decimal? max)
        {
            OrganGroup = organGroup;
            ProcuredOrganCount = procuredOrganCount;
            TotalCosts = totalCosts;
            AverageCosts = averageCosts;
            Min = min;
            Max = max;
        }
    }

    public class TransportCostPerVehicleOverall
    {
        public string Vehicle { get; set; }
        public int? TransportCount { get; set; }
        public decimal? TotalCosts { get; set; }
        public decimal? AverageCosts { get; set; }
        public decimal? Min { get; set; }
        public decimal? Max { get; set; }

        public TransportCostPerVehicleOverall(string vehicle, int? transportCount, decimal? totalCosts, decimal? averageCosts, decimal? min, decimal? max)
        {
            Vehicle = vehicle;
            TransportCount = transportCount;
            TotalCosts = totalCosts;
            AverageCosts = averageCosts;
            Min = min;
            Max = max;
        }
    }

    public class TransportCostPerVehiclePerOrgan
    {
        public string OrganGroup { get; set; }
        public string Vehicle { get; set; }
        public int? TransportCount { get; set; }
        public decimal? TotalCosts { get; set; }
        public decimal? AverageCosts { get; set; }
        public decimal? Min { get; set; }
        public decimal? Max { get; set; }

        public TransportCostPerVehiclePerOrgan(string organGroup, string vehicle, int? transportCount, decimal? totalCosts, decimal? averageCosts, decimal? min, decimal? max)
        {
            OrganGroup = organGroup;
            Vehicle = vehicle;
            TransportCount = transportCount;
            TotalCosts = totalCosts;
            AverageCosts = averageCosts;
            Min = min;
            Max = max;
        }
    }

    public class TransportCostPerItemGroup
    {
        public string ItemGroup { get; set; }
        public int? TransportCount { get; set; }
        public decimal? TotalCosts { get; set; }
        public decimal? AverageCosts { get; set; }
        public decimal? Min { get; set; }
        public decimal? Max { get; set; }

        public TransportCostPerItemGroup(string itemGroup, int? transportCount, decimal? totalCosts, decimal? averageCosts, decimal? min, decimal? max)
        {
            ItemGroup = itemGroup;
            TransportCount = transportCount;
            TotalCosts = totalCosts;
            AverageCosts = averageCosts;
            Min = min;
            Max = max;
        }
    }

    #endregion

    public class TransportCost : Common
    {
        /// <summary>
        /// Used for report "Transport costs per removed organ overall"
        /// Gets a list of organ item groups, their number and costs
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>list of TransportCostPerRemovedOrganOverall</returns>
        public List<TransportCostPerRemovedOrganOverall> GetTransportCostPerRemovedOrganOverall(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportCostPerRemovedOrganOverall>();

                List<TransportCostPerRemovedOrganOverall> listTransportCostPerRemovedOrganOverall = new List<TransportCostPerRemovedOrganOverall>();

                List<ItemGroup> organGroups = GetOrganItemGroups();

                foreach (ItemGroup organGroup in organGroups)
                {
                    decimal? minCosts = null;
                    decimal? maxCosts = null;
                    string organGroupName = organGroup.Name;
                    int procuredOrganCount = GetProcuredOrganCount(organGroup, procurementDateFrom, procurementDateTo);
                    decimal? totalCosts = procuredOrganCount > 0
                                              ? GetTotalCostsOfOrganGroup(organGroup,
                                                                          procurementDateFrom,
                                                                          procurementDateTo,
                                                                          out minCosts,
                                                                          out maxCosts)
                                              : (decimal?)null;
                    decimal? averageCosts = procuredOrganCount > 0
                                                ? GetAverageCosts(procuredOrganCount, totalCosts)
                                                : null;

                    TransportCostPerRemovedOrganOverall transportCostPerRemovedOrganOverall = new TransportCostPerRemovedOrganOverall(organGroupName,
                                                                                                                                      procuredOrganCount > 0
                                                                                                                                          ? procuredOrganCount
                                                                                                                                          : (int?)
                                                                                                                                            null,
                                                                                                                                      totalCosts,
                                                                                                                                      averageCosts,
                                                                                                                                      minCosts,
                                                                                                                                      maxCosts);

                    listTransportCostPerRemovedOrganOverall.Add(transportCostPerRemovedOrganOverall);
                }

                return listTransportCostPerRemovedOrganOverall;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport cost per removed organ overall report data due to an error: " + ex.Message);
            }

            return new List<TransportCostPerRemovedOrganOverall>();
        }

        /// <summary>
        /// Used for report "Transport costs per mean of transport"
        /// Gets a list of vehicles, their transport numbers and costs
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>list of TransportCostPerVehicleOverall</returns>
        public List<TransportCostPerVehicleOverall> GetTransportCostPerVehicleOverall(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportCostPerVehicleOverall>();

                List<TransportCostPerVehicleOverall> listTransportCostPerVehicleOverall = new List<TransportCostPerVehicleOverall>();

                List<Vehicle> vehicles = GetVehicles();

                foreach (Vehicle vehicle in vehicles)
                {
                    decimal? minCosts = null;
                    decimal? maxCosts = null;
                    string vehicleName = vehicle.Name;
                    int transportCount = GetTransportCount(null, vehicle, procurementDateFrom, procurementDateTo);
                    decimal? totalCosts = transportCount > 0
                                              ? GetTotalCostsOfVehicle(
                                                                       vehicle, procurementDateFrom,
                                                                       procurementDateTo,
                                                                       out minCosts,
                                                                       out maxCosts)
                                              : (decimal?)null;
                    decimal? averageCosts = transportCount > 0
                                                ? GetAverageCosts(transportCount, totalCosts)
                                                : null;

                    TransportCostPerVehicleOverall transportCostPerVehicleOverall = new TransportCostPerVehicleOverall(vehicleName,
                                                                                                                       transportCount > 0
                                                                                                                           ? transportCount
                                                                                                                           : (int?)null,
                                                                                                                       totalCosts,
                                                                                                                       averageCosts,
                                                                                                                       minCosts,
                                                                                                                       maxCosts);

                    listTransportCostPerVehicleOverall.Add(transportCostPerVehicleOverall);
                }

                return listTransportCostPerVehicleOverall;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport cost per vehicle overall report data due to an error: " + ex.Message);
            }

            return new List<TransportCostPerVehicleOverall>();
        }

        /// <summary>
        /// Used for reports "Transport costs per mean of transport separated per organ"
        /// Gets a list of vehicles, their transport numbers and costs per organ item group
        /// </summary>
        /// <remarks>
        /// Costs of transport items which were assigned to organs are ignored
        /// </remarks>
        /// <param name="organItemGroupID">organ item group</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>list of TransportCostPerVehiclePerOrgan</returns>
        public List<TransportCostPerVehiclePerOrgan> GetTransportCostPerVehiclePerOrgan(int organItemGroupID, DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportCostPerVehiclePerOrgan>();

                ItemGroup itemGroup = GetItemGroupByID(organItemGroupID);
                if (itemGroup == null) return null;

                List<TransportCostPerVehiclePerOrgan> listTransportCostPerVehiclePerOrgan = new List<TransportCostPerVehiclePerOrgan>();

                List<Vehicle> vehicles = GetVehicles();

                foreach (Vehicle vehicle in vehicles)
                {
                    decimal? minCosts = null;
                    decimal? maxCosts = null;
                    string organGroupName = itemGroup.Name;
                    string vehicleName = vehicle.Name;
                    int transportCount = GetTransportCount(itemGroup, vehicle, procurementDateFrom, procurementDateTo);
                    decimal? totalCosts = transportCount > 0
                                              ? GetTotalCostsOfVehiclePerOrganItemGroup(itemGroup,
                                                                                        vehicle,
                                                                                        procurementDateFrom,
                                                                                        procurementDateTo,
                                                                                        out minCosts,
                                                                                        out maxCosts)
                                              : null;
                    decimal? averageCosts = transportCount > 0
                                                ? GetAverageCosts(transportCount, totalCosts)
                                                : null;

                    TransportCostPerVehiclePerOrgan transportCostPerVehicleOverall = new TransportCostPerVehiclePerOrgan(organGroupName,
                                                                                                                         vehicleName,
                                                                                                                         transportCount > 0
                                                                                                                             ? transportCount
                                                                                                                             : (int?)null,
                                                                                                                         totalCosts,
                                                                                                                         averageCosts,
                                                                                                                         minCosts,
                                                                                                                         maxCosts);

                    listTransportCostPerVehiclePerOrgan.Add(transportCostPerVehicleOverall);
                }

                return listTransportCostPerVehiclePerOrgan;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport cost per vehicle per organ report data due to an error: " + ex.Message);
            }

            return new List<TransportCostPerVehiclePerOrgan>();
        }

        /// <summary>
        /// Used for report "Transport costs separated per organ and transport item"
        /// Gets a list of item groups, their transport numbers and costs
        /// </summary>
        /// <remarks>
        /// Costs of transport items which were assigned to organs will be attribuated to the organ if the organ was transported for that transport.
        /// If the organ was not transported but the transport item was, costs will be attributed to the transport item.
        /// Costs of transport items with no attributed organ will be shared equally between the number of them per transport
        /// </remarks>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>list of TransportCostPerItemGroup</returns>
        public List<TransportCostPerItemGroup> GetTransportCostPerItemGroup(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportCostPerItemGroup>();

                List<TransportCostPerItemGroup> listTransportCostPerItemGroup = new List<TransportCostPerItemGroup>();

                List<ItemGroup> itemGroups = GetItemGroups();

                foreach (ItemGroup itemGroup in itemGroups.OrderBy(i => i.ID))
                {
                    decimal? minCosts = null;
                    decimal? maxCosts = null;
                    string itemGroupName = itemGroup.Name;
                    int transportCount = GetTransportCountPerItemGroup(itemGroup, procurementDateFrom, procurementDateTo);
                    decimal? totalCosts = transportCount > 0
                                              ? GetTotalCostsOfItemGroup(itemGroup, procurementDateFrom, procurementDateTo, out minCosts, out maxCosts)
                                              : null;
                    decimal? averageCosts = transportCount > 0
                                                ? GetAverageCosts(transportCount, totalCosts)
                                                : null;

                    TransportCostPerItemGroup transportCostPerItemGroup = new TransportCostPerItemGroup(itemGroupName,
                                                                                                        transportCount > 0
                                                                                                            ? transportCount
                                                                                                            : (int?)null,
                                                                                                        totalCosts,
                                                                                                        averageCosts,
                                                                                                        minCosts,
                                                                                                        maxCosts);

                    listTransportCostPerItemGroup.Add(transportCostPerItemGroup);
                }

                return listTransportCostPerItemGroup;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport cost per item group report data due to an error: " + ex.Message);
            }

            return new List<TransportCostPerItemGroup>();
        }

        #region Privates

        #region General
        /// <summary>
        /// Calculates average costs and returns it
        /// </summary>
        /// <param name="count">number to divide total costs in order to get average costs</param>
        /// <param name="totalCosts">total costs</param>
        /// <returns>Average costs</returns>
        private static decimal? GetAverageCosts(int count, decimal? totalCosts)
        {
            return count == 0 || totalCosts == null ? (decimal?)null : Math.Round((decimal)totalCosts / count, 2);
        }

        /// <summary>
        /// Sums organ costs to total costs
        /// </summary>
        /// <param name="organCosts">list of OrganCost</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <returns>Sum of total costs</returns>
        private decimal SumOrganCostsToTotalCost(List<OrganCost> organCosts, decimal? inMinCost, decimal? inMaxCost, out decimal? outMinCost, out decimal? outMaxCost)
        {
            bool costsExists;

            return SumOrganCostsToTotalCost(organCosts, inMinCost, inMaxCost, false, out outMinCost, out outMaxCost, out costsExists);
        }

        /// <summary>
        /// Sums organ costs to total costs
        /// </summary>
        /// <param name="organCosts">list of OrganCost</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="inCostsExists">input indicator if any costs are existent</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <param name="outCostsExists">output indicator if any costs are existent</param>
        /// <returns>Sum of total costs</returns>
        private decimal SumOrganCostsToTotalCost(List<OrganCost> organCosts, decimal? inMinCost, decimal? inMaxCost, bool inCostsExists, out decimal? outMinCost, out decimal? outMaxCost, out bool outCostsExists)
        {
            outMinCost = inMinCost;
            outMaxCost = inMaxCost;
            outCostsExists = inCostsExists;
            decimal totalCost = 0;

            foreach (OrganCost organCost in organCosts)
            {
                // Determin total costs
                totalCost += Convert.ToDecimal(organCost.Amount);

                // Determin min costs
                if (outMinCost == null || organCost.Amount < outMinCost) outMinCost = Convert.ToDecimal(organCost.Amount);

                // Determin max costs
                if (outMaxCost == null || organCost.Amount > outMaxCost) outMaxCost = Convert.ToDecimal(organCost.Amount);

                outCostsExists = true;
            }

            return totalCost;
        }

        /// <summary>
        /// Sums costs to total costs
        /// </summary>
        /// <param name="cost">list of Cost</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <returns>Sum of total costs</returns>
        private decimal SumCostToTotalCost(SLIDS.DAL.Cost cost, decimal? inMinCost, decimal? inMaxCost, out decimal? outMinCost, out decimal? outMaxCost)
        {
            outMinCost = inMinCost;
            outMaxCost = inMaxCost;
            decimal totalCost = 0;

            // Determin total costs
            totalCost += Convert.ToDecimal(cost.Amount);

            // Determin min costs
            if (outMinCost == null || cost.Amount < outMinCost) outMinCost = Convert.ToDecimal(cost.Amount);

            // Determin max costs
            if (outMaxCost == null || cost.Amount > outMaxCost) outMaxCost = Convert.ToDecimal(cost.Amount);

            return totalCost;
        }
        #endregion

        #region TransportCostPerRemovedOrganOverall
        /// <summary>
        /// Gets the number of procured organs bewteen procurement date from and procurement date to
        /// </summary>
        /// <param name="organGroup">Organ ItemGroup</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>Number of procured organs</returns>
        private static int GetProcuredOrganCount(ItemGroup organGroup, DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            List<TransplantOrgan> procuredOrgans = GetProcuredOrgansOfItemGroup(organGroup.ID, procurementDateFrom, procurementDateTo);

            return procuredOrgans
                    .Where(to => to.Organ.CountableAs != null)
                    .Sum(to => Convert.ToInt32(to.Organ.CountableAs));
        }

        /// <summary>
        /// Gets total costs of organ ItemGroup
        /// </summary>
        /// <param name="organGroup">Organ ItemGroup</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <param name="minCost">output minimal costs</param>
        /// <param name="maxCost">output maximum costs</param>
        /// <returns>total costs of organ ItemGroup</returns>
        private decimal GetTotalCostsOfOrganGroup(ItemGroup organGroup, DateTime? procurementDateFrom, DateTime? procurementDateTo, out decimal? minCost, out decimal? maxCost)
        {
            minCost = null;
            maxCost = null;

            List<TransplantOrgan> procuredOrgans = GetProcuredOrgansOfItemGroup(organGroup.ID, procurementDateFrom, procurementDateTo);

            decimal totalCost = 0;
            foreach (TransplantOrgan procuredOrgan in procuredOrgans)
            {
                List<OrganCost> organCosts = procuredOrgan.OrganCost
                                                          .Where(oc => oc.Amount != null)
                                                          .Where(oc => !oc.Cost.IsDeleted)
                                                          .Where(oc => oc.Cost.CostType.CostGroup.ID == (int)BasePage.CostGroup.Transport)
                                                          .ToList();

                totalCost += SumOrganCostsToTotalCost(organCosts, minCost, maxCost, out minCost, out maxCost);
            }

            return totalCost;
        }
        #endregion

        #region TransportCostPerVehicle
        /// <summary>
        /// Gets the number of transports bewteen procurement date from and procurement date to
        /// </summary>
        /// <param name="itemGroup">ItemGroup</param>
        /// <param name="vehicle">Vehicle</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>Number of transports</returns>
        private static int GetTransportCount(ItemGroup itemGroup, Vehicle vehicle, DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            List<SLIDS.DAL.Transport> transports = GetTransportsOfVehicle(vehicle.ID, procurementDateFrom, procurementDateTo)
                                                    .Where(t => (itemGroup != null && t.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroup == itemGroup) || itemGroup == null))
                                                    .ToList();

            return transports.Count;
        }

        /// <summary>
        /// Gets total costs of Vehicle
        /// </summary>
        /// <param name="vehicle">Vehicle</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <param name="minCost">output minimal costs</param>
        /// <param name="maxCost">output maximum costs</param>
        /// <returns>total costs of Vehicle</returns>
        private decimal GetTotalCostsOfVehicle(Vehicle vehicle, DateTime? procurementDateFrom, DateTime? procurementDateTo, out decimal? minCost, out decimal? maxCost)
        {
            minCost = null;
            maxCost = null;

            // Get transports of transplantorgans for this ItemGroup (do not get Costs for this organ since only costs of TransportItems allocated to organs are not included here)
            List<SLIDS.DAL.Transport> transports = GetTransportsOfVehicle(vehicle.ID, procurementDateFrom, procurementDateTo).ToList();

            decimal totalCost = 0;
            foreach (SLIDS.DAL.Transport transport in transports)
            {
                foreach (SLIDS.DAL.Cost cost in transport.Cost
                                                            .Where(c => !c.IsDeleted)
                                                            .Where(c => c.Amount != null)
                                                            .Where(c => c.CostType.CostGroup.ID == (int)BasePage.CostGroup.Transport))
                {
                    totalCost += SumCostToTotalCost(cost, minCost, maxCost, out minCost, out maxCost);
                }
            }

            return totalCost;
        }

        /// <summary>
        /// Gets total costs of Vehicle
        /// </summary>
        /// <param name="itemGroup">ItemGroup</param>
        /// <param name="vehicle">Vehicle</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <param name="minCost">output minimal costs</param>
        /// <param name="maxCost">output maximum costs</param>
        /// <returns>total costs of Vehicle</returns>
        private decimal? GetTotalCostsOfVehiclePerOrganItemGroup(ItemGroup itemGroup, Vehicle vehicle, DateTime? procurementDateFrom, DateTime? procurementDateTo, out decimal? minCost, out decimal? maxCost)
        {
            minCost = null;
            maxCost = null;

            // Get transports of transplantorgans for this ItemGroup (do not get Costs for this organ since only costs of TransportItems allocated to organs are not included here)
            List<SLIDS.DAL.Transport> transports = GetTransportsOfVehicle(vehicle.ID, procurementDateFrom, procurementDateTo)
                                                    .Where(t => (itemGroup != null && t.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroup == itemGroup) || itemGroup == null))
                                                    .ToList();

            decimal? totalCost = 0;
            bool costsExists = false;
            foreach (SLIDS.DAL.Transport transport in transports)
            {
                List<SLIDS.DAL.Cost> costs = transport.Cost
                                                      .Where(c => !c.IsDeleted)
                                                      .Where(c => c.Amount != null)
                                                      .Where(c => c.CostType.CostGroup.ID == (int)BasePage.CostGroup.Transport).ToList();

                foreach (SLIDS.DAL.Cost cost in costs)
                {
                    List<OrganCost> organCosts = cost.OrganCost.Where(oc => oc.TransplantOrgan.Organ.ItemGroup == itemGroup).ToList();

                    totalCost += SumOrganCostsToTotalCost(organCosts, minCost, maxCost, out minCost, out maxCost);

                    costsExists = true;
                }
            }

            return costsExists ? totalCost : null;
        }
        #endregion

        #region TransportCostPerItemGroup
        private static int GetTransportCountPerItemGroup(ItemGroup itemGroup, DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo)
                .Where(t => (itemGroup.Type == (int)BasePage.ItemGroupType.Organ
                             && t.TransportedOrgan != null
                             && t.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroupID == itemGroup.ID))
                            ||
                            (itemGroup.Type == (int)BasePage.ItemGroupType.TransportItem
                             && t.TransportItem != null
                             && t.TransportItem.Any(ti => ti.ItemGroupID == itemGroup.ID)))
                .ToList();

            return transports.Count();
        }

        /// <summary>
        /// Gets total costs of item group
        /// </summary>
        /// <remarks>
        /// if type of item group is not Organ, then associated organ costs (of transport item) will be added to item, if organ was not transported with this transport.
        /// if organ was transported with this transport, no costs will be allocated to the transport item since the costs already have been allocated to organ.
        /// if transport item has no association between organs, the rest value (value after deduction of any costs attribuated to organs or its associated transport items for this transport)
        /// will be associated to this transport item group. If there are more than one transport item of this transport which have no associated organ, then value will be divided
        /// by the number of transport items which no organ association to ensure an even distribution.
        /// </remarks>
        /// <param name="itemGroup">Item Group</param>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <param name="minCost">minimal cost amount</param>
        /// <param name="maxCost">maximum cost amount</param>
        /// <returns>Total costs of correspoding item group</returns>
        private decimal? GetTotalCostsOfItemGroup(ItemGroup itemGroup, DateTime? procurementDateFrom, DateTime? procurementDateTo, out decimal? minCost, out decimal? maxCost)
        {
            minCost = null;
            maxCost = null;
            bool costsExists = false;

            // Get all transports
            List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo).ToList();

            decimal? totalCost = 0;
            foreach (SLIDS.DAL.Transport transport in transports)
            {
                // Get costs of transport
                List<SLIDS.DAL.Cost> costs = transport.Cost
                                                      .Where(c => !c.IsDeleted)
                                                      .Where(c => c.Amount != null)
                                                      .Where(c => c.CostType.CostGroup.ID == (int)BasePage.CostGroup.Transport)
                                                      .ToList();

                // if organ to which costs were allocated was transported, then costs will be attribuated to organ item group
                if (transport.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroup == itemGroup))
                {
                    totalCost += SumCostsOfOrganGroup(costs, itemGroup, minCost, maxCost, costsExists, out minCost, out maxCost, out costsExists);
                }
                else
                {
                    if (transport.TransportItem.Any(ti => ti.ItemGroup == itemGroup))
                    {
                        totalCost += SumCostsOfTransportItemGroup(transport, costs, itemGroup, minCost, maxCost, costsExists, out minCost, out maxCost, out costsExists);
                    }
                }
            }

            return costsExists ? totalCost : null;
        }

        /// <summary>
        /// Sums costs of organ ItemGroup
        /// </summary>
        /// <param name="costs">list of Cost</param>
        /// <param name="itemGroup">Organ ItemGroup</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="inCostsExists">input indicating if costs exists</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <param name="outCostsExists">output indicating if costs exists</param>
        /// <returns>Sum of costs of organ ItemGroup</returns>
        private decimal SumCostsOfOrganGroup(List<SLIDS.DAL.Cost> costs,
                                              ItemGroup itemGroup,
                                              decimal? inMinCost,
                                              decimal? inMaxCost,
                                              bool inCostsExists,
                                              out decimal? outMinCost,
                                              out decimal? outMaxCost,
                                              out bool outCostsExists)
        {
            outMinCost = inMinCost;
            outMaxCost = inMaxCost;
            outCostsExists = inCostsExists;
            decimal totalCost = 0;

            // add allocated organ costs to item group
            foreach (SLIDS.DAL.Cost cost in costs)
            {
                List<OrganCost> organCosts = cost.OrganCost.Where(oc => oc.TransplantOrgan.Organ.ItemGroup == itemGroup).ToList();

                totalCost += SumOrganCostsToTotalCost(organCosts, outMinCost, outMaxCost, outCostsExists, out outMinCost, out outMaxCost, out outCostsExists);
            }

            return totalCost;
        }

        /// <summary>
        /// Sums costs of transport item ItemGroup
        /// </summary>
        /// <param name="transport">Transport</param>
        /// <param name="costs">list of Cost</param>
        /// <param name="itemGroup">Transport item ItemGroup</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="inCostsExists">input indicating costs exist</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <param name="outCostsExists">output indicating costs exists</param>
        /// <returns>Sum of costs of transport item ItemGroup</returns>
        private decimal SumCostsOfTransportItemGroup(SLIDS.DAL.Transport transport,
                                                     List<SLIDS.DAL.Cost> costs,
                                                     ItemGroup itemGroup,
                                                     decimal? inMinCost,
                                                     decimal? inMaxCost,
                                                     bool inCostsExists,
                                                     out decimal? outMinCost,
                                                     out decimal? outMaxCost,
                                                     out bool outCostsExists)
        {
            outMinCost = inMinCost;
            outMaxCost = inMaxCost;
            outCostsExists = inCostsExists;
            decimal totalCost = 0;

            // get costs of every transported item of this transport
            foreach (TransportItem transportedItem in transport.TransportItem.Where(ti => ti.ItemGroup == itemGroup))
            {
                // get all organ associations for this transported item
                foreach (OrganToTransportItemAssociation organToTransportItemAssociation in transportedItem.OrganToTransportItemAssociation)
                {
                    SLIDS.DAL.Organ associatedOrgan = organToTransportItemAssociation.Organ;

                    if (transport.TransportedOrgan.All(to => to.TransplantOrgan.Organ != associatedOrgan))
                    {
                        // add allocated organ costs to item group
                        foreach (SLIDS.DAL.Cost cost in costs)
                        {
                            List<OrganCost> organCosts = cost.OrganCost.Where(oc => oc.TransplantOrgan.Organ == associatedOrgan).ToList();

                            totalCost += SumOrganCostsToTotalCost(organCosts, outMinCost, outMaxCost, outCostsExists, out outMinCost, out outMaxCost, out outCostsExists);
                        }
                    }
                }

                // if no association is available allocate costs to transport item but take in consideration that there might be more than one transport item 
                // with no organ association in this case we simply divide the amount of the costs by the number of transport items with no organ association
                if (transportedItem.OrganToTransportItemAssociation.Count == 0)
                {
                    // get number of transport items with no organ associations in order to know by how many transport items costs need to be divided
                    int numberOfTransportItemWithNoOrganAssociation = transport.TransportItem
                                                                               .Where(ti => ti.ItemGroup == itemGroup)
                                                                               .Count(ti => ti.OrganToTransportItemAssociation.Count == 0);

                    totalCost += SumCostsOfTransportItemsWithNoOrganAssociation(costs, transport, numberOfTransportItemWithNoOrganAssociation,
                                                                                outMinCost, outMaxCost, outCostsExists,
                                                                                out outMinCost, out outMaxCost, out outCostsExists);
                }
            }

            return totalCost;
        }

        /// <summary>
        /// Sums costs of transport item ItemGroups with no organ association
        /// </summary>
        /// <param name="costs">list of Cost</param>
        /// <param name="transport">transport</param>
        /// <param name="numberOfTransportItemWithNoOrganAssociation">number of transported items with no Organ Association</param>
        /// <param name="inMinCost">input min costs</param>
        /// <param name="inMaxCost">input max costs</param>
        /// <param name="inCostsExists">input indicating costs exists</param>
        /// <param name="outMinCost">output min costs</param>
        /// <param name="outMaxCost">output max costs</param>
        /// <param name="outCostsExists">output indicating costs exists</param>
        /// <returns>Sum of costs of transport item ItemGroups with no organ association</returns>
        private decimal SumCostsOfTransportItemsWithNoOrganAssociation(List<SLIDS.DAL.Cost> costs,
                                                                       SLIDS.DAL.Transport transport,
                                                                       int numberOfTransportItemWithNoOrganAssociation,
                                                                       decimal? inMinCost,
                                                                       decimal? inMaxCost,
                                                                       bool inCostsExists,
                                                                       out decimal? outMinCost,
                                                                       out decimal? outMaxCost,
                                                                       out bool outCostsExists)
        {
            outMinCost = inMinCost;
            outMaxCost = inMaxCost;
            outCostsExists = inCostsExists;
            decimal totalCost = 0;

            // loop through all costs of transport and allocate costs depending on the number of transport items with no organ association
            // but taking in consideration that a part of the amount could already have been attributed to an organ or an organ associated transport item
            foreach (SLIDS.DAL.Cost cost in costs.Where(c => c.Amount != null))
            {
                // Deduct from cost what could have potentially be attribuated to organs (only deduct organ costs if organ was actually transported)
                decimal costTotal = Convert.ToDecimal(cost.Amount);
                foreach (TransportedOrgan transportedOrgan in transport.TransportedOrgan)
                {
                    TransplantOrgan organ = transportedOrgan.TransplantOrgan;
                    foreach (OrganCost organCost in cost.OrganCost
                                                        .Where(oc => oc.Amount != null)
                                                        .Where(oc => oc.TransplantOrganID == organ.ID))
                    {
                        costTotal -= Convert.ToDecimal(organCost.Amount);
                    }
                }

                // Deduct from cost what could have potentially be attribuated to transport item of associated organs (only deduct organ costs if transported item was acutally transported)
                foreach (TransportItem transportItem in transport.TransportItem.Where(ti => ti.OrganToTransportItemAssociation.Count > 0))
                {
                    foreach (OrganToTransportItemAssociation organToTransportItemAssociation in transportItem.OrganToTransportItemAssociation)
                    {
                        // Get associated Organ
                        SLIDS.DAL.Organ associatedOrgan = organToTransportItemAssociation.Organ;

                        if (transport.TransportedOrgan.All(to => to.TransplantOrgan.Organ != associatedOrgan))
                        {
                            foreach (OrganCost organCost in cost.OrganCost
                                                                .Where(oc => oc.Amount != null)
                                                                .Where(oc => oc.TransplantOrgan.OrganID == associatedOrgan.ID))
                            {
                                costTotal -= Convert.ToDecimal(organCost.Amount);
                            }
                        }
                    }
                }


                if (costTotal > 0)
                {
                    // Determin total costs
                    decimal costShare = costTotal / numberOfTransportItemWithNoOrganAssociation;
                    totalCost += Math.Round(costShare, 2);

                    // Determin min costs
                    if (outMinCost == null || costShare < outMinCost)
                    {
                        outMinCost = Math.Round(costShare, 2);
                    }

                    // Determin max costs
                    if (outMaxCost == null || costShare > outMaxCost)
                    {
                        outMaxCost = Math.Round(costShare, 2);
                    }

                    outCostsExists = true;
                }
            }
            return totalCost;
        }

        #endregion

        #endregion
    }
}