using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS.Reports.DAL
{
    #region reports data structures

    public class TransportPerItemGroupAndVehicle
    {
        public string ItemGroup { get; set; }
        public string Vehicle { get; set; }
        public int? TransportCount { get; set; }
        public decimal? TransportRatio { get; set; }
        public int ItemGroupSort { get; set; }

        public TransportPerItemGroupAndVehicle(string itemGroup, string vehicle, int? transportCount, decimal? transportRatio, int itemGroupSort)
        {
            ItemGroup = itemGroup;
            Vehicle = vehicle;
            TransportCount = transportCount;
            TransportRatio = transportRatio;
            ItemGroupSort = itemGroupSort;
        }
    }

    public class TransportDuration
    {
        public string ItemGroup { get; set; }
        public string Vehicle { get; set; }
        public int? TransportCount { get; set; }
        public TimeSpan Duration { get; set; }
        public TimeSpan AverageDuration { get; set; }
        public string AverageDurationDisplay { get; set; }
        public TimeSpan MinDuration { get; set; }
        public TimeSpan MaxDuration { get; set; }
        public string MinDurationDisplay { get; set; }
        public string MaxDurationDisplay { get; set; }
        public int ItemGroupSort { get; set; }

        public TransportDuration(string itemGroup, string vehicle, int? transportCount, TimeSpan duration,
                                 TimeSpan averageDuration, string averageDurationDisplay,
                                 TimeSpan minDuration, TimeSpan maxDuration, string minDurationDisplay, string maxDurationDisplay,
                                 int itemGroupSort)
        {
            ItemGroup = itemGroup;
            Vehicle = vehicle;
            TransportCount = transportCount;
            Duration = duration;
            AverageDuration = averageDuration;
            AverageDurationDisplay = averageDurationDisplay;
            MinDuration = minDuration;
            MaxDuration = maxDuration;
            MinDurationDisplay = minDurationDisplay;
            MaxDurationDisplay = maxDurationDisplay;
            ItemGroupSort = itemGroupSort;
        }
    }

    public class TransportDurationChart
    {
        public string ItemGroup { get; set; }
        public TimeSpan TransportDuration { get; set; }
        public int ItemGroupSort { get; set; }

        public TransportDurationChart(string itemGroup, TimeSpan transportDuration, int itemGroupSort)
        {
            ItemGroup = itemGroup;
            TransportDuration = transportDuration;
            ItemGroupSort = itemGroupSort;
        }
    }

    public class WaitingDurationPerVehicle
    {
        public string ItemGroup { get; set; }
        public string Vehicle { get; set; }
        public int WaitingDuration { get; set; }
        public string WaitingDurationDisplay { get; set; }
        public int AvgWaitingDuration { get; set; }
        public string AvgWaitingDurationDisplay { get; set; }
        public int TotalWaitingDuration { get; set; }
        public string TotalWaitingDurationDisplay { get; set; }
        public int MinWaitingDuration { get; set; }
        public string MinWaitingDurationDisplay { get; set; }
        public int MaxWaitingDuration { get; set; }
        public string MaxWaitingDurationDisplay { get; set; }
        public int ItemGroupSort { get; set; }

        public WaitingDurationPerVehicle(string itemGroup, string vehicle,
            int waitingDuration, string waitingDurationDisplay,
            int avgWaitingDuration, string avgWaitingDurationDisplay,
            int totalWaitingDuration, string totalWaitingDurationDisplay,
            int minWaitingDuration, string minWaitingDurationDisplay,
            int maxWaitingDuration, string maxWaitingDurationDisplay,
            int itemGroupSort)
        {
            ItemGroup = itemGroup;
            Vehicle = vehicle;
            WaitingDuration = waitingDuration;
            WaitingDurationDisplay = waitingDurationDisplay;
            AvgWaitingDuration = avgWaitingDuration;
            AvgWaitingDurationDisplay = avgWaitingDurationDisplay;
            TotalWaitingDuration = totalWaitingDuration;
            TotalWaitingDurationDisplay = totalWaitingDurationDisplay;
            MinWaitingDuration = minWaitingDuration;
            MinWaitingDurationDisplay = minWaitingDurationDisplay;
            MaxWaitingDuration = maxWaitingDuration;
            MaxWaitingDurationDisplay = maxWaitingDurationDisplay;
            ItemGroupSort = itemGroupSort;
        }
    }

    public class BloodTransportDuration
    {
        public string BloodTransportItem { get; set; }
        public string Vehicle { get; set; }
        public int? TransportCount { get; set; }
        public TimeSpan Duration { get; set; }
        public TimeSpan AvgDuration { get; set; }
        public string AvgDurationDisplay { get; set; }
        public int TransportItemSort { get; set; }

        public BloodTransportDuration(string bloodTransportItem, string vehicle, int? transportCount, TimeSpan duration, TimeSpan avgDuration, string transportAverageDuration, int transportItemSort)
        {
            BloodTransportItem = bloodTransportItem;
            Vehicle = vehicle;
            TransportCount = transportCount;
            Duration = duration;
            AvgDuration = avgDuration;
            AvgDurationDisplay = transportAverageDuration;
            TransportItemSort = transportItemSort;
        }
    }

    public class TransportDelay
    {
        public string DonorNumber { get; set; }
        public string Vehicle { get; set; }
        public TimeSpan DelayDuration { get; set; }
        public string DelayDurationDisplay { get; set; }
        public string DelayReason { get; set; }
        public string Comment { get; set; }

        public TransportDelay(string donorNumber, string vehicle, TimeSpan delayDuration, string delayDurationDisplay, string delayReason, string comment)
        {
            DonorNumber = donorNumber;
            Vehicle = vehicle;
            DelayDuration = delayDuration;
            DelayDurationDisplay = delayDurationDisplay;
            DelayReason = delayReason;
            Comment = comment;
        }
    }

    #endregion

    public class Transport : Common
    {
        private const string TOTAL = "Total";

        /// <summary>
        /// Used for report "Transports of organs per mean of transport" and "Transports of items per mean of transport"
        /// Gets a list of the number of transports per item group and vehicle.
        /// Also includes percentage ratio per vehicle
        /// </summary>
        /// <remarks>
        /// The total row does not necessarily sum up the columns seeing as one transport
        /// can contain multiple item groups. The total row will count transports
        /// with multiple item groups only once.
        /// </remarks>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <param name="itemGroupType">item group type (1= organ, 2= transport item)</param>
        /// <returns></returns>
        public List<TransportPerItemGroupAndVehicle> GetNumberOfTransportsPerItemGroupAndVehicle(DateTime? procurementDateFrom, DateTime? procurementDateTo, int itemGroupType)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportPerItemGroupAndVehicle>();

                List<TransportPerItemGroupAndVehicle> listTransportPerItemGroupAndVehicle = new List<TransportPerItemGroupAndVehicle>();

                List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo);
                List<ItemGroup> itemGroups = GetItemGroupsByType(itemGroupType);
                List<Vehicle> vehicles = GetVehicles();

                foreach (ItemGroup itemGroup in itemGroups)
                {
                    int totalTransportCountPerItemGroup = GetTotalTransport(transports, itemGroup, null, BasePage.ItemGroupType.Undefined);
                    int itemGroupSort = itemGroup.ID;
                    string itemGroupName = itemGroup.Name;

                    foreach (Vehicle vehicle in vehicles.OrderBy(v => v.ID))
                    {
                        string vehicleName = vehicle.Name;
                        int totalTransportCountPerItemGroupAndVehicle = GetTotalTransport(transports, itemGroup, vehicle,
                                                                                          BasePage.ItemGroupType.Undefined);
                        decimal? ratioPerItemGroupAndVehicle = GetRatio(totalTransportCountPerItemGroup, totalTransportCountPerItemGroupAndVehicle);

                        TransportPerItemGroupAndVehicle transportPerItemGroupAndVehicle = new TransportPerItemGroupAndVehicle(itemGroupName,
                                                                                                                              vehicleName,
                                                                                                                              totalTransportCountPerItemGroupAndVehicle > 0
                                                                                                                                  ? totalTransportCountPerItemGroupAndVehicle
                                                                                                                                  : (int?)null,
                                                                                                                              ratioPerItemGroupAndVehicle,
                                                                                                                              itemGroupSort);

                        listTransportPerItemGroupAndVehicle.Add(transportPerItemGroupAndVehicle);
                    }
                }

                AddTotalRowOfTransportPerItemGroupAndVehicle(listTransportPerItemGroupAndVehicle,
                                                             transports,
                                                             vehicles,
                                                             (BasePage.ItemGroupType)itemGroupType);

                return listTransportPerItemGroupAndVehicle.OrderBy(t => t.ItemGroupSort).ToList();
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport item group per vehicle report data due to an error: " + ex.Message);
            }

            return new List<TransportPerItemGroupAndVehicle>();
        }

        /// <summary>
        /// Used for report "Duration of transports per organs and transport items"
        /// Gets a list of all item groups and vehicles and their transport duration accordingly.
        /// Also includes roundup columns min and max. Total column is handled like a vehicle column inside the list (no dedicated list parameter).
        /// </summary>
        /// <remarks>
        /// The total row does not necessarily sum up the columns seeing as one transport
        /// can contain multiple item groups. The total row will count transport durations
        /// with multiple item groups only once.
        /// </remarks>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns></returns>
        public List<TransportDuration> GetTransportDuration(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportDuration>();

                List<TransportDuration> listTransportDuration = new List<TransportDuration>();

                List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo);
                List<ItemGroup> itemGroups = GetItemGroups();
                List<Vehicle> vehicles = GetVehicles();

                foreach (ItemGroup itemGroup in itemGroups)
                {
                    List<SLIDS.DAL.Transport> filteredTransportList = GetFilteredTransportList(transports, itemGroup);

                    AddVehicleColumnsToTransportDurationList(listTransportDuration, transports, vehicles, itemGroup, itemGroup.Name, itemGroup.ID);

                    AddTotalColumnToTransportDurationList(listTransportDuration, filteredTransportList, itemGroup.Name, TOTAL, itemGroup.ID);

                    AddMinMaxColumnsToTransportDurationList(listTransportDuration, filteredTransportList, itemGroup.Name);
                }

                AddTotalRowOfTransportDuration(listTransportDuration, transports, vehicles);

                return listTransportDuration;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport duration report data due to an error: " + ex.Message);
            }

            return new List<TransportDuration>();
        }

        /// <summary>
        /// Used for chart in report "Duration of transports per organs and transport items"
        /// This list is a cut down version of list TransportDuration for display purposes of the chart only
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns a list of all item groups and vehicles and their transport duration</returns>
        public List<TransportDurationChart> GetTransportDurationChart(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportDurationChart>();

                List<TransportDurationChart> listTransportDurationChart = new List<TransportDurationChart>();

                List<TransportDuration> listTransportDuration = GetTransportDuration(procurementDateFrom, procurementDateTo);

                foreach (TransportDuration transportDuration in listTransportDuration.Where(td => td.ItemGroup != TOTAL && td.Vehicle == TOTAL))
                {
                    TransportDurationChart transportDurationChart = new TransportDurationChart(transportDuration.ItemGroup,
                                                                                               transportDuration.AverageDuration,
                                                                                               transportDuration.ItemGroupSort);

                    listTransportDurationChart.Add(transportDurationChart);
                }

                return listTransportDurationChart;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport duration chart report data due to an error: " + ex.Message);
            }

            return new List<TransportDurationChart>();
        }

        /// <summary>
        /// Used for report "Waiting time per mean of transport"
        /// Gets a list of all item groups and vehicles and their waiting times accordingly. 
        /// Also includes roundup columns such as avg, total, min and max per item group
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns a list of all item groups and vehicles and their waiting times</returns>
        public List<WaitingDurationPerVehicle> GetWaitingDurationPerVehicle(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<WaitingDurationPerVehicle>();

                List<WaitingDurationPerVehicle> listWaitingDurationPerVehicle = new List<WaitingDurationPerVehicle>();

                List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo).Where(t => t.WaitingTime != null).ToList();
                List<ItemGroup> itemGroups = GetItemGroups();
                List<Vehicle> vehicles = GetVehicles();

                foreach (ItemGroup itemGroup in itemGroups)
                {
                    string itemGroupName = itemGroup.Name;
                    int itemGroupSort = itemGroup.ID;

                    List<SLIDS.DAL.Transport> filteredTransportList = GetFilteredTransportList(transports, itemGroup);

                    AddVehicleColumnsToWaitingDurationPerVehicleList(listWaitingDurationPerVehicle, filteredTransportList, vehicles, itemGroupName, itemGroupSort);

                    AddRoundUpsColumnsToWaitingDurationPerVehicleList(listWaitingDurationPerVehicle, filteredTransportList, itemGroupName);
                }

                AddTotalRowOfWaitingDurationPerVehicle(listWaitingDurationPerVehicle, transports, vehicles);

                return listWaitingDurationPerVehicle;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading waiting duration per vehicle report data due to an error: " + ex.Message);
            }

            return new List<WaitingDurationPerVehicle>();
        }

        /// <summary>
        /// Used for report "Transports of Blood"
        /// Gets a list of all transport items with item group of "Blood" and their transport duration
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns a list of transport items of item group "Blood" and their transport duration</returns>
        public List<BloodTransportDuration> GetBloodTransportDuration(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<BloodTransportDuration>();

                List<BloodTransportDuration> listBloodTransportDurations = new List<BloodTransportDuration>();

                List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo);
                List<Vehicle> vehicles = GetVehicles();

                ItemGroup bloodItemGroup = GetItemGroupByID((int)BasePage.ItemGroupValue.Blood);
                if (bloodItemGroup == null) throw new Exception("ItemGroup with ID " + Convert.ToString((int)BasePage.ItemGroupValue.Blood) + " could not be found!");
                List<TransportItem> bloodTransportItems = GetTransportItemsOfItemGroup(bloodItemGroup.ID);
                List<SLIDS.DAL.Transport> filteredTransportList = GetFilteredTransportList(transports, bloodItemGroup);

                foreach (TransportItem bloodTransportItem in bloodTransportItems.OrderBy(bti => bti.ID))
                {
                    string transportItemName = bloodTransportItem.Name;
                    int transportItemSort = bloodTransportItem.Position != null
                                                ? Convert.ToInt32(bloodTransportItem.Position)
                                                : bloodTransportItem.ID;

                    AddVehicleColumnsToBloodTransportDurationList(listBloodTransportDurations, filteredTransportList, vehicles, bloodTransportItem, transportItemName, transportItemSort);

                    AddTotalColumnToBloodTransportDurationList(listBloodTransportDurations, filteredTransportList, bloodTransportItem, transportItemName, transportItemSort);
                }

                return listBloodTransportDurations;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading blood transport duration report data due to an error: " + ex.Message);
            }

            return new List<BloodTransportDuration>();
        }

        /// <summary>
        /// Used for report "Delays"
        /// Gets a list of all transport delays
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns></returns>
        public List<TransportDelay> GetTransportDelay(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<TransportDelay>();

                List<TransportDelay> listTransportDelay = new List<TransportDelay>();

                List<Donor> donors = GetDonors(procurementDateFrom, procurementDateTo);
                List<SLIDS.DAL.Transport> transports = GetTransports(procurementDateFrom, procurementDateTo);

                foreach (Donor donor in donors)
                {
                    int donorID = donor.ID;
                    // Create a filtered transport list for this donor
                    List<SLIDS.DAL.Transport> filteredTransports = transports.Where(t => t.DonorID == donorID).ToList();
                    if (filteredTransports.Count > 0)
                    {
                        // Get delays
                        AddDonorColumnToTransportDelayList(listTransportDelay, donor, filteredTransports);
                    }
                }

                return listTransportDelay;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading transport delay report data due to an error: " + ex.Message);
            }

            return new List<TransportDelay>();
        }

        #region privates

        #region General
        /// <summary>
        /// Returns number of transports depending on passed filter values
        /// </summary>
        /// <param name="transports">list Transport</param>
        /// <param name="itemGroup">filter param ItemGroup (pass null to avoid filter)</param>
        /// <param name="vehicle">filter param Vehicle (pass null to avoid filter)</param>
        /// <param name="itemGroupType">filter param ItemGroupType (Organ, TransportItem or Undefinded)</param>
        /// <returns>number of transports according to passed filter params</returns>
        private int GetTotalTransport(List<SLIDS.DAL.Transport> transports, ItemGroup itemGroup, Vehicle vehicle, BasePage.ItemGroupType itemGroupType)
        {
            return GetFilteredTransportList(transports, itemGroup, vehicle, itemGroupType: itemGroupType).Count;
        }

        /// <summary>
        /// Gets a list of transports depending on passed filter values
        /// </summary>
        /// <param name="transports">list Transport</param>
        /// <param name="itemGroup">filter param ItemGroup (pass null to avoid filter)</param>
        /// <param name="vehicle">filter param Vehicle (pass null to avoid filter)</param>
        /// <param name="transportItem">filter param TransportItem (pass null to avoid filter)</param>
        /// <param name="itemGroupType">filter param ItemGroupType (Organ, TransportItem or Undefinded)</param>
        /// <returns>list of transports according to passed filter params</returns>
        private List<SLIDS.DAL.Transport> GetFilteredTransportList(List<SLIDS.DAL.Transport> transports, ItemGroup itemGroup = null, Vehicle vehicle = null, TransportItem transportItem = null, BasePage.ItemGroupType itemGroupType = BasePage.ItemGroupType.Undefined)
        {
            return transports.Where(t => (itemGroup != null
                                          && itemGroup.Type == (int)BasePage.ItemGroupType.Organ
                                          &&
                                          t.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroup != null && to.TransplantOrgan.Organ.ItemGroup.ID == itemGroup.ID)
                                         )
                                         ||
                                         (itemGroup != null
                                          && itemGroup.Type == (int)BasePage.ItemGroupType.TransportItem
                                          && t.TransportItem.Any(ti => ti.ItemGroup != null && ti.ItemGroup.ID == itemGroup.ID)
                                         )
                                         || itemGroup == null)
                             .Where(t => (transportItem != null
                                          && t.TransportItem.Any(ti => ti.ID == transportItem.ID)
                                         )
                                         || transportItem == null)
                             .Where(t => (vehicle != null
                                          && t.VehicleID == vehicle.ID
                                         )
                                         || vehicle == null)
                             .Where(t => (itemGroupType == BasePage.ItemGroupType.Organ
                                          && t.TransportedOrgan.Any(to => to.TransplantOrgan.Organ.ItemGroup != null && to.TransplantOrgan.Organ.ItemGroup.Type == (int)itemGroupType)
                                         )
                                         ||
                                         (itemGroupType == BasePage.ItemGroupType.TransportItem
                                          && t.TransportItem.Any(ti => ti.ItemGroup != null && ti.ItemGroup.Type == (int)itemGroupType)
                                         )
                                         || itemGroupType == BasePage.ItemGroupType.Undefined)
                             .ToList();
        }

        /// <summary>
        /// Gets ratio between totalCount and partialCount
        /// </summary>
        /// <remarks>
        /// report viewer will multiply by 100 automatically, therefore it won't be done here. 
        /// The formatting of this field is set to percentage in report viewer
        /// </remarks>
        /// <param name="totalCount">total value</param>
        /// <param name="partialCount">partial value</param>
        /// <returns>ratio of partial value</returns>
        private decimal? GetRatio(int totalCount, int partialCount)
        {
            if (totalCount == 0 || partialCount == 0) return null;

            return ((decimal)partialCount / totalCount);
        }

        /// <summary>
        /// Formats duration of TimeSpan to an output like "2h45"
        /// </summary>
        /// <param name="duration">duration</param>
        /// <returns>returns duration in string value for report (ex. "2h45")</returns>
        private string FormatDurationToString(TimeSpan duration)
        {
            return String.Format("{0:0}h{1:00}", duration.Days * 24 + duration.Hours, duration.Minutes);
        }

        /// <summary>
        /// Formats duration of minutes in int to an output like "2h45"
        /// </summary>
        /// <param name="waitingTime">waiting time (min)</param>
        /// <returns>returns duration in string value for export (ex. "2h45")</returns>
        private string FormatWaitingTimeToString(int waitingTime)
        {
            if (waitingTime == 0) return string.Empty;

            DateTime firstDate = DateTime.Now;
            DateTime secondDate = firstDate.AddMinutes(waitingTime);
            TimeSpan duration = secondDate.Subtract(firstDate);

            return string.Format("{0:D1}h{1:D2}", duration.Hours, duration.Minutes);
        }
        #endregion

        #region TransportPerItemGroupAndVehicle
        /// <summary>
        /// Adds total row to list TransportPerItemGroupAndVehicle. Each vehicle will have its total value. The matrix in report will then
        /// display its values accordingly
        /// </summary>
        /// <param name="listTransportPerItemGroupAndVehicle">list TransportPerItemGroupAndVehicle</param>
        /// <param name="transports">list of filtered Transport</param>
        /// <param name="vehicles">list of all Vehicle</param>
        /// <param name="itemGroupType">item group type (1=Organ, 2=TransportItem)</param>
        private void AddTotalRowOfTransportPerItemGroupAndVehicle(List<TransportPerItemGroupAndVehicle> listTransportPerItemGroupAndVehicle,
                                                                  List<SLIDS.DAL.Transport> transports,
                                                                  List<Vehicle> vehicles,
                                                                  BasePage.ItemGroupType itemGroupType)
        {
            // Create total row
            int totalTransportCount = GetTotalTransport(transports, null, null, itemGroupType);
            int itemGroupSort = listTransportPerItemGroupAndVehicle.Max(t => t.ItemGroupSort) + 1;
            const string itemGroupName = TOTAL;

            foreach (Vehicle vehicle in vehicles.OrderBy(v => v.ID))
            {
                string vehicleName = vehicle.Name;
                int totalTransportCountPerVehicle = GetTotalTransport(transports, null, vehicle, itemGroupType);
                decimal? ratioPerVehicle = GetRatio(totalTransportCount, totalTransportCountPerVehicle);

                TransportPerItemGroupAndVehicle transportOrganGroupPerVehicle = new TransportPerItemGroupAndVehicle(itemGroupName,
                                                                                                                    vehicleName,
                                                                                                                    totalTransportCountPerVehicle > 0
                                                                                                                        ? totalTransportCountPerVehicle
                                                                                                                        : (int?)null,
                                                                                                                    ratioPerVehicle,
                                                                                                                    itemGroupSort);

                listTransportPerItemGroupAndVehicle.Add(transportOrganGroupPerVehicle);
            }
        }

        #endregion

        #region TransportDuration
        /// <summary>
        /// Gets sort criteria and creates total row by calling methods
        /// AddVehicleColumnsToTotalRowOfTransportDuration, AddTotalColumnToTotalRowOfTransportDuration and AddMinMaxColumnToTotalRowOfTransportDuration
        /// </summary>
        /// <param name="listTransportDuration"></param>
        /// <param name="transports"></param>
        /// <param name="vehicles"></param>
        private void AddTotalRowOfTransportDuration(List<TransportDuration> listTransportDuration,
                                                    List<SLIDS.DAL.Transport> transports,
                                                    List<Vehicle> vehicles)
        {
            // Create total row
            int itemGroupSort = listTransportDuration.Max(t => t.ItemGroupSort) + 1;

            AddVehicleColumnsToTransportDurationList(listTransportDuration, transports, vehicles, null, TOTAL, itemGroupSort);

            AddTotalColumnToTransportDurationList(listTransportDuration, transports, TOTAL, TOTAL, itemGroupSort);

            AddMinMaxColumnsToTransportDurationList(listTransportDuration, transports, TOTAL);
        }

        /// <summary>
        /// Gets duration of transports for each vehicle (eiter per item group or overall) and adds information to list TransportDuration for each vehicle
        /// </summary>
        /// <param name="listTransportDuration">list TransportDuration</param>
        /// <param name="transports">filtered list of transports</param>
        /// <param name="vehicles">list of all active vehicles</param>
        /// <param name="itemGroup">item group for which transport durations will be gathered</param>
        /// <param name="itemGroupName">name of item Group which will be display in report</param>
        /// <param name="itemGroupSort">sort value which will sort item groups</param>
        private void AddVehicleColumnsToTransportDurationList(List<TransportDuration> listTransportDuration,
                                                              List<SLIDS.DAL.Transport> transports,
                                                              List<Vehicle> vehicles,
                                                              ItemGroup itemGroup,
                                                              string itemGroupName,
                                                              int itemGroupSort)
        {
            // Get number of transports and durations of transport per vehicle
            foreach (Vehicle vehicle in vehicles.OrderBy(v => v.ID))
            {
                List<SLIDS.DAL.Transport> transportsPerVehicleList = GetFilteredTransportList(transports, itemGroup, vehicle);

                string vehicleName = vehicle.Name;
                // Get Average per itemgroup and per vehicle
                int totalTransportCountPerItemGroupAndVehicle = transportsPerVehicleList.Count;
                TimeSpan totalDuration = GetDurationOfTransports(transportsPerVehicleList);
                TimeSpan averageDuration = CalculateAverageDuration(totalTransportCountPerItemGroupAndVehicle, totalDuration);
                string averageDurationDisplay = totalTransportCountPerItemGroupAndVehicle > 0
                                                    ? FormatDurationToString(averageDuration)
                                                    : String.Empty;

                TransportDuration transportDuration = new TransportDuration(itemGroupName,
                                                                            vehicleName,
                                                                            totalTransportCountPerItemGroupAndVehicle > 0
                                                                                ? totalTransportCountPerItemGroupAndVehicle
                                                                                : (int?)null,
                                                                            totalDuration,
                                                                            averageDuration,
                                                                            averageDurationDisplay,
                                                                            new TimeSpan(),
                                                                            new TimeSpan(),
                                                                            String.Empty,
                                                                            String.Empty,
                                                                            itemGroupSort);

                listTransportDuration.Add(transportDuration);
            }
        }

        /// <summary>
        /// Gets total duration of transports per item group and adds information to list TransportDuration
        /// </summary>
        /// <remarks>
        /// This will be used for the Total Column in report (not Total row!)
        /// </remarks>
        /// <param name="listTransportDuration">list TransportDuration</param>
        /// <param name="transports">filtered list of transports</param>
        /// <param name="itemGroupName">name of item group</param>
        /// <param name="vehicleName">name of vehicle</param>
        /// <param name="itemGroupSort">sort value which will sort item groups</param>
        private void AddTotalColumnToTransportDurationList(List<TransportDuration> listTransportDuration, List<SLIDS.DAL.Transport> transports,
                                                           string itemGroupName, string vehicleName, int itemGroupSort)
        {
            // Get Average over all itemgroups and all vehicles
            int totalTransportCount = transports.Count;
            TimeSpan totalDuration = GetDurationOfTransports(transports);
            TimeSpan totalAverageDuration = CalculateAverageDuration(totalTransportCount, totalDuration);

            string totalAverageDurationDisplay = FormatDurationToString(totalAverageDuration);

            TransportDuration transportDuration = new TransportDuration(itemGroupName,
                                                                        vehicleName,
                                                                        totalTransportCount > 0
                                                                            ? totalTransportCount
                                                                            : (int?)null,
                                                                        totalDuration,
                                                                        totalAverageDuration,
                                                                        totalAverageDurationDisplay,
                                                                        new TimeSpan(),
                                                                        new TimeSpan(),
                                                                        String.Empty,
                                                                        String.Empty,
                                                                        itemGroupSort);

            listTransportDuration.Add(transportDuration);
        }

        /// <summary>
        /// Gets minimum and maximum duration of a transport per item group and adds information to list TransportDuration
        /// </summary>
        /// <param name="listTransportDuration">list TransportDuration</param>
        /// <param name="transports">filtered list of transports</param>
        /// <param name="itemGroupName">item group name</param>
        private void AddMinMaxColumnsToTransportDurationList(List<TransportDuration> listTransportDuration, List<SLIDS.DAL.Transport> transports, string itemGroupName)
        {
            TimeSpan minDuration;
            TimeSpan maxDuration;

            GetMinMaxDurationOfTransports(transports, out minDuration, out maxDuration);

            string minDurationDisplay = FormatDurationToString(minDuration);
            string maxDurationDisplay = FormatDurationToString(maxDuration);

            foreach (TransportDuration transportDuration in listTransportDuration.Where(t => t.ItemGroup == itemGroupName))
            {
                transportDuration.MinDuration = minDuration;
                transportDuration.MaxDuration = maxDuration;
                transportDuration.MinDurationDisplay = minDurationDisplay;
                transportDuration.MaxDurationDisplay = maxDurationDisplay;
            }
        }

        /// <summary>
        /// Retrieves duration of transport using arrival and departure in list of transports
        /// </summary>
        /// <param name="transports">list of Transport</param>
        /// <returns>sum of duration of transport</returns>
        private TimeSpan GetDurationOfTransports(List<SLIDS.DAL.Transport> transports)
        {
            TimeSpan totalDuration = new TimeSpan();

            foreach (SLIDS.DAL.Transport transport in transports.Where(t => t.Departure != null && t.Arrival != null))
            {
                // sum durations of transport
                totalDuration += Convert.ToDateTime(transport.Arrival).Subtract(Convert.ToDateTime(transport.Departure));
            }

            return totalDuration;
        }

        /// <summary>
        /// Retrieves minimum and maximum duration in list of transports
        /// </summary>
        /// <param name="transports">list of Transport</param>
        /// <param name="minDuration">out param with value of minimum duration</param>
        /// <param name="maxDuration">out param with value of maximum duration</param>
        private void GetMinMaxDurationOfTransports(List<SLIDS.DAL.Transport> transports, out TimeSpan minDuration, out TimeSpan maxDuration)
        {
            minDuration = new TimeSpan();
            maxDuration = new TimeSpan();

            foreach (SLIDS.DAL.Transport transport in transports.Where(t => t.Departure != null && t.Arrival != null))
            {
                // get duration of transport
                TimeSpan transportDuration = Convert.ToDateTime(transport.Arrival).Subtract(Convert.ToDateTime(transport.Departure));

                // set min and max of duration if applicable
                if (minDuration == TimeSpan.Zero || (transportDuration != TimeSpan.Zero && transportDuration < minDuration)) minDuration = transportDuration;
                if (maxDuration == TimeSpan.Zero || (transportDuration != TimeSpan.Zero && transportDuration > maxDuration)) maxDuration = transportDuration;
            }
        }

        /// <summary>
        /// Calculates average duration using duration and number of transports
        /// </summary>
        /// <param name="transportCount">number of transports</param>
        /// <param name="duration">duration of transports</param>
        /// <returns>average duration</returns>
        private TimeSpan CalculateAverageDuration(int transportCount, TimeSpan duration)
        {
            return transportCount == 0
                       ? new TimeSpan()
                       : TimeSpan.FromTicks(duration.Ticks / transportCount);
        }
        #endregion

        #region WaitingDurationPerVehicle
        /// <summary>
        /// Gets item group sort (row sort) and creates total row in list WaitingDurationPerVehicle by calling
        /// methods AddVehicleColumnsToWaitingDurationPerVehicleList and AddRoundUpsColumnsToWaitingDurationPerVehicleList
        /// </summary>
        /// <param name="listWaitingDurationPerVehicle">list WaitingDurationPerVehicle</param>
        /// <param name="transports">filtered transport list (all transport which fits input period and where column WaitingTime is not null</param>
        /// <param name="vehicles">list of all active vehicles</param>
        private void AddTotalRowOfWaitingDurationPerVehicle(List<WaitingDurationPerVehicle> listWaitingDurationPerVehicle,
                                                            List<SLIDS.DAL.Transport> transports,
                                                            List<Vehicle> vehicles)
        {
            // Create total row
            int itemGroupSort = listWaitingDurationPerVehicle.Max(t => t.ItemGroupSort) + 1;

            AddVehicleColumnsToWaitingDurationPerVehicleList(listWaitingDurationPerVehicle, transports, vehicles, TOTAL, itemGroupSort);

            AddRoundUpsColumnsToWaitingDurationPerVehicleList(listWaitingDurationPerVehicle, transports, TOTAL);
        }

        /// <summary>
        /// Gets waiting duration of item group per vehcile and calls method AddRowToWaitingDurationPerVehicleList which will add the row to the list
        /// WaitingDurationPerVehicle
        /// </summary>
        /// <param name="listWaitingDurationPerVehicle">list WaitingDurationPerVehicle</param>
        /// <param name="transports">filtered transport list (filtered either per item group or overall for total row)</param>
        /// <param name="vehicles">list of all active vehicles</param>
        /// <param name="itemGroupName">item group name (name which will appear in column itemGroup of report)</param>
        /// <param name="itemGroupSort">sort value which will be used in report to sort rows</param>
        private void AddVehicleColumnsToWaitingDurationPerVehicleList(List<WaitingDurationPerVehicle> listWaitingDurationPerVehicle,
                                                                      List<SLIDS.DAL.Transport> transports,
                                                                      List<Vehicle> vehicles,
                                                                      string itemGroupName,
                                                                      int itemGroupSort)
        {
            // Set total values per vehicle
            foreach (Vehicle vehicle in vehicles.OrderBy(v => v.ID))
            {
                List<SLIDS.DAL.Transport> filteredTransportList = GetFilteredTransportList(transports, null, vehicle);

                string vehicleName = vehicle.Name;
                int waitingDuration = GetWaitingDuration(filteredTransportList);
                AddRowToWaitingDurationPerVehicleList(listWaitingDurationPerVehicle,
                                                      itemGroupName,
                                                      vehicleName,
                                                      waitingDuration,
                                                      itemGroupSort);
            }
        }

        /// <summary>
        /// This method actually adds the row to the list WaitingDurationPerVehicle according to its given parameter
        /// </summary>
        /// <remarks>
        /// roundup params of list WaitingDurationPerVehicle (avg, total, min and max) will only be initialised here.
        /// They will be updated once all data from vehicle and item groups are available in the list.
        /// </remarks>
        /// <param name="listWaitingDurationPerVehicle">list WaitingDurationPerVehicle</param>
        /// <param name="itemGroupName">item group name</param>
        /// <param name="vehicleName">vehicle name</param>
        /// <param name="waitingDuration">waiting duration</param>
        /// <param name="itemGroupSort">sort value which will be used in report to sort sequence in rows</param>
        private void AddRowToWaitingDurationPerVehicleList(List<WaitingDurationPerVehicle> listWaitingDurationPerVehicle, string itemGroupName, string vehicleName, int waitingDuration, int itemGroupSort)
        {
            string waitingDurationDisplay = FormatWaitingTimeToString(waitingDuration);

            WaitingDurationPerVehicle waitingDurationPerVehicle = new WaitingDurationPerVehicle(itemGroupName,
                                                                                                vehicleName,
                                                                                                waitingDuration,
                                                                                                waitingDurationDisplay,
                                                                                                0,              // avg
                                                                                                String.Empty,   // avg display
                                                                                                0,              // total
                                                                                                String.Empty,   // total display
                                                                                                0,              // min
                                                                                                String.Empty,   // min display
                                                                                                0,              // max
                                                                                                String.Empty,   // max display
                                                                                                itemGroupSort);

            listWaitingDurationPerVehicle.Add(waitingDurationPerVehicle);
        }

        /// <summary>
        /// Round up values will be gathered and list WaitingDurationPerVehicle will be updated accordingly
        /// </summary>
        /// <param name="listWaitingDurationPerVehicle">list WaitingDurationPerVehicle</param>
        /// <param name="transports">filtere transport list</param>
        /// <param name="itemGroupName">item group name which will indicate for which item group the round up will be updated</param>
        private void AddRoundUpsColumnsToWaitingDurationPerVehicleList(List<WaitingDurationPerVehicle> listWaitingDurationPerVehicle,
                                                                List<SLIDS.DAL.Transport> transports,
                                                                string itemGroupName)
        {
            int totalWaitingDuration = GetWaitingDuration(transports);
            int avgWaitingDuration = transports.Count > 0
                                         ? totalWaitingDuration / transports.Count // = average duration
                                         : 0;
            int minWaitingDuration = GetMinWaitingDuration(transports);
            int maxWaitingDuration = GetMaxWaitingDuration(transports);

            string avgWaitingDurationDisplay = FormatWaitingTimeToString(avgWaitingDuration);
            string totalWaitingDurationDisplay = FormatWaitingTimeToString(totalWaitingDuration);
            string minWaitingDurationDisplay = FormatWaitingTimeToString(minWaitingDuration);
            string maxWaitingDurationDisplay = FormatWaitingTimeToString(maxWaitingDuration);

            foreach (WaitingDurationPerVehicle waitingDurationPerVehicle in listWaitingDurationPerVehicle.Where(wd => wd.ItemGroup == itemGroupName))
            {
                waitingDurationPerVehicle.AvgWaitingDuration = avgWaitingDuration;
                waitingDurationPerVehicle.AvgWaitingDurationDisplay = avgWaitingDurationDisplay;
                waitingDurationPerVehicle.TotalWaitingDuration = totalWaitingDuration;
                waitingDurationPerVehicle.TotalWaitingDurationDisplay = totalWaitingDurationDisplay;
                waitingDurationPerVehicle.MinWaitingDuration = minWaitingDuration;
                waitingDurationPerVehicle.MinWaitingDurationDisplay = minWaitingDurationDisplay;
                waitingDurationPerVehicle.MaxWaitingDuration = maxWaitingDuration;
                waitingDurationPerVehicle.MaxWaitingDurationDisplay = maxWaitingDurationDisplay;
            }
        }

        /// <summary>
        /// Gets sum of WaitingTime of the list transports
        /// </summary>
        /// <param name="transports">list Transport</param>
        /// <returns>sum of waiting duration (min)</returns>
        private int GetWaitingDuration(List<SLIDS.DAL.Transport> transports)
        {
            return transports
                .Where(t => t.WaitingTime != null)
                .Sum(transport => Convert.ToInt32(transport.WaitingTime));
        }

        /// <summary>
        /// Gets max value of WaitingTime of the list transports
        /// </summary>
        /// <param name="transports">list Transport</param>
        /// <returns>max value of waiting duration (min)</returns>
        private int GetMaxWaitingDuration(List<SLIDS.DAL.Transport> transports)
        {
            int max = 0;
            foreach (SLIDS.DAL.Transport transport in transports)
            {
                if (max == 0 || Convert.ToInt32(transport.WaitingTime) > max) max = Convert.ToInt32(transport.WaitingTime);
            }

            return max;
        }

        /// <summary>
        /// Gets min value of WaitingTime of the list transports
        /// </summary>
        /// <param name="transports">list Transport</param>
        /// <returns>min value of waiting duration (min)</returns>
        private int GetMinWaitingDuration(List<SLIDS.DAL.Transport> transports)
        {
            int min = 0;
            foreach (SLIDS.DAL.Transport transport in transports)
            {
                if (min == 0 || Convert.ToInt32(transport.WaitingTime) < min) min = Convert.ToInt32(transport.WaitingTime);
            }

            return min;
        }
        #endregion

        #region BloodTransportDuration
        /// <summary>
        /// Gets duration of transports for each vehicle (eiter per item group or overall) and adds information to list TransportDuration for each vehicle
        /// </summary>
        /// <param name="listBloodTransportDuration">list BloodTransportDuration</param>
        /// <param name="transports">filtered list of transports</param>
        /// <param name="vehicles">list of all active vehicles</param>
        /// <param name="transportItem">transport item for which transport durations will be gathered</param>
        /// <param name="transportItemName">name of transport item which will be display in report</param>
        /// <param name="transportItemSort">sort value which will sort transport items</param>
        private void AddVehicleColumnsToBloodTransportDurationList(List<BloodTransportDuration> listBloodTransportDuration,
                                                                   List<SLIDS.DAL.Transport> transports,
                                                                   List<Vehicle> vehicles,
                                                                   TransportItem transportItem,
                                                                   string transportItemName,
                                                                   int transportItemSort)
        {
            // Get number of transports and durations of transport per vehicle
            foreach (Vehicle vehicle in vehicles.OrderBy(v => v.ID))
            {
                List<SLIDS.DAL.Transport> transportsPerTransportItemListAndVehicle = GetFilteredTransportList(transports, null, vehicle, transportItem);

                string vehicleName = vehicle.Name;
                // Get Average per transport item and per vehicle
                int totalTransportCountPerTransportItemAndVehicle = transportsPerTransportItemListAndVehicle.Count;
                TimeSpan totalDuration = GetDurationOfTransports(transportsPerTransportItemListAndVehicle);
                TimeSpan averageDuration = CalculateAverageDuration(totalTransportCountPerTransportItemAndVehicle, totalDuration);
                string averageDurationDisplay = totalTransportCountPerTransportItemAndVehicle > 0
                                                    ? FormatDurationToString(averageDuration)
                                                    : String.Empty;

                BloodTransportDuration transportDuration = new BloodTransportDuration(transportItemName,
                                                                                      vehicleName,
                                                                                      totalTransportCountPerTransportItemAndVehicle > 0
                                                                                          ? totalTransportCountPerTransportItemAndVehicle
                                                                                          : (int?)null,
                                                                                      totalDuration,
                                                                                      averageDuration,
                                                                                      averageDurationDisplay,
                                                                                      transportItemSort);

                listBloodTransportDuration.Add(transportDuration);
            }
        }

        /// <summary>
        /// Gets total duration of blood transports and adds those information to list BloodTransportDuration
        /// </summary>
        /// <param name="listBloodTransportDuration">list TransportDuration</param>
        /// <param name="transports">filtered list of transports</param>
        /// <param name="transportItem">TransportItem object</param>
        /// <param name="transportItemName">name of transport item</param>
        /// <param name="transportItemSort">sort value which will sort transport items</param>
        private void AddTotalColumnToBloodTransportDurationList(List<BloodTransportDuration> listBloodTransportDuration,
                                                                List<SLIDS.DAL.Transport> transports,
                                                                TransportItem transportItem,
                                                                string transportItemName,
                                                                int transportItemSort)
        {
            List<SLIDS.DAL.Transport> transportsPerTransportItemList = GetFilteredTransportList(transports, null, null, transportItem);

            // Get Average over all transport items and all vehicles
            int totalTransportCount = transportsPerTransportItemList.Count;
            TimeSpan totalDuration = GetDurationOfTransports(transportsPerTransportItemList);
            TimeSpan totalAverageDuration = CalculateAverageDuration(totalTransportCount, totalDuration);
            string totalAverageDurationDisplay = FormatDurationToString(totalAverageDuration);

            BloodTransportDuration transportDuration = new BloodTransportDuration(transportItemName,
                                                                                  TOTAL,
                                                                                  totalTransportCount,
                                                                                  totalDuration,
                                                                                  totalAverageDuration,
                                                                                  totalAverageDurationDisplay,
                                                                                  transportItemSort);

            listBloodTransportDuration.Add(transportDuration);
        }
        #endregion

        #region TransportDelay
        /// <summary>
        /// Gets delay data of transports for the given donor, creates a TransportDelay object with all informations and adds the object to the list
        /// TransportDelay
        /// </summary>
        /// <param name="listTransportDelay">list TransportDelay</param>
        /// <param name="donor">donor</param>
        /// <param name="transports">filtered transport list by donor</param>
        private void AddDonorColumnToTransportDelayList(List<TransportDelay> listTransportDelay, Donor donor, List<SLIDS.DAL.Transport> transports)
        {
            string donorNumber = donor.DonorNumber;

            foreach (SLIDS.DAL.Transport transport in transports)
            {
                List<SLIDS.DAL.Delay> delays = transport.Delay.ToList();
                if (delays.Count <= 0) continue;

                string vehicleName = transport.Vehicle.Name;
                TimeSpan delayDuration = GetDelayDuration(delays);
                string delayDurationDisplay = FormatDurationToString(delayDuration);
                string delayReasons = GetDelayReasons(delays);
                string delayComments = GetDelayComments(delays);

                TransportDelay transportDelay = new TransportDelay(donorNumber, vehicleName, delayDuration, delayDurationDisplay, delayReasons, delayComments);

                listTransportDelay.Add(transportDelay);
            }
        }

        /// <summary>
        /// Gets total duration of delays
        /// </summary>
        /// <param name="delays">list of type Delay</param>
        /// <returns>returns sum of delay durations in list delays</returns>
        private TimeSpan GetDelayDuration(List<SLIDS.DAL.Delay> delays)
        {
            TimeSpan duration = new TimeSpan();
            foreach (SLIDS.DAL.Delay delay in delays.Where(d => d.Duration != null))
            {
                if (delay.Duration != null) duration += (TimeSpan)delay.Duration;
            }

            return duration;
        }

        /// <summary>
        /// Gets all reasons of delays
        /// </summary>
        /// <param name="delays">list of type Delay</param>
        /// <returns>returns all delay reasons of list delays in a string</returns>
        private string GetDelayReasons(List<SLIDS.DAL.Delay> delays)
        {
            StringBuilder delayReasons = new StringBuilder();

            foreach (SLIDS.DAL.Delay delay in delays.Where(d => d.DelayReason.Reason != null))
            {
                delayReasons.AppendLine(delay.DelayReason.Reason);
            }

            return delayReasons.ToString();
        }

        /// <summary>
        /// Gets all comments of delays
        /// </summary>
        /// <param name="delays">list of type Delay</param>
        /// <returns>returns all delay comments of list delays in a string</returns>
        private string GetDelayComments(List<SLIDS.DAL.Delay> delays)
        {
            StringBuilder delayComments = new StringBuilder();

            foreach (SLIDS.DAL.Delay delay in delays.Where(d => d.Comment != null))
            {
                delayComments.AppendLine(delay.Comment);
            }

            return delayComments.ToString();
        }
        #endregion

        #endregion
    }
}