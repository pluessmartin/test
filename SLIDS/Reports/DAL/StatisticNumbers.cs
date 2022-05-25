using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS.Reports.DAL
{
    #region reports data structures

    public class StatisticNumberValues
    {
        public string Month { get; set; }
        public int TransplantOrganCount { get; set; }
        public double Median { get; set; }
        public double Mean { get; set; }
        public double Variance { get; set; }
        public double StandardDeviation { get; set; }

        public StatisticNumberValues(string month, int transplantOrganCount, double median, double mean, double variance, double standardDeviation)
        {
            Month = month;
            TransplantOrganCount = transplantOrganCount;
            Median = median;
            Mean = mean;
            Variance = variance;
            StandardDeviation = standardDeviation;
        }
    }

    public class StatisticPeriod
    {
        public string MonthName { get; set; }
        public int MonthNumber { get; set; }
        public DateTime DateFrom { get; set; }
        public DateTime DateTo { get; set; }

        public StatisticPeriod(string monthName, int monthNumber, DateTime dateFrom, DateTime dateTo)
        {
            MonthName = monthName;
            MonthNumber = monthNumber;
            DateFrom = dateFrom;
            DateTo = dateTo;
        }
    }

    public class StatisticTransplantOrganCount
    {
        public int OrganCount { get; set; }
        public int DonorID { get; set; }

        public StatisticTransplantOrganCount(int organCount, int donorID)
        {
            OrganCount = organCount;
            DonorID = donorID;
        }
    }

    #endregion

    public class StatisticNumbers : Common
    {
        /// <summary>
        /// Used for report "Statistic numbers of organs per donor"
        /// Gets a list of statistic numbers in given period.
        /// </summary>
        /// <remarks>
        /// Foreign donors (FO) are not beeing considerate in this statistic
        /// </remarks>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns list of StatisticNumberValues</returns>
        public List<StatisticNumberValues> GetStatisticNumbersPerMonth(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<StatisticNumberValues>();

                List<StatisticNumberValues> listTransportDuration = new List<StatisticNumberValues>();

                List<StatisticPeriod> statisticPeriod = GetStatisticPeriod(Convert.ToDateTime(procurementDateFrom),
                                                                           Convert.ToDateTime(procurementDateTo));

                foreach (StatisticPeriod period in statisticPeriod.OrderBy(sp => sp.MonthNumber))
                {
                    List<StatisticTransplantOrganCount> transplantOrganCounts = GetTransplantOrganCount(period.DateFrom, period.DateTo);
                    if (transplantOrganCounts.Count <= 0) continue;

                    double median = GetMedian(transplantOrganCounts);
                    double mean = transplantOrganCounts.Average(toc => toc.OrganCount);
                    double variance = GetVariance(transplantOrganCounts, mean);
                    double standardDeviation = Math.Sqrt(variance);

                    StatisticNumberValues statisticNumberValues = new StatisticNumberValues(period.MonthName, listTransportDuration.Count, median, mean, variance, standardDeviation);

                    listTransportDuration.Add(statisticNumberValues);
                }

                return listTransportDuration;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading statistic numbers report data due to an error: " + ex.Message);
            }

            return new List<StatisticNumberValues>();
        }

        public List<StatisticNumberValues> GetStatisticNumbersOverall(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<StatisticNumberValues>();

                List<StatisticNumberValues> listTransportDuration = new List<StatisticNumberValues>();

                List<StatisticTransplantOrganCount> transplantOrganCounts = GetTransplantOrganCount(Convert.ToDateTime(procurementDateFrom), Convert.ToDateTime(procurementDateTo));
                if(transplantOrganCounts.Count == 0) return new List<StatisticNumberValues>();

                double median = GetMedian(transplantOrganCounts);
                double mean = transplantOrganCounts.Average(toc => toc.OrganCount);
                double variance = GetVariance(transplantOrganCounts, mean);
                double standardDeviation = Math.Sqrt(variance);
                string period = Convert.ToDateTime(procurementDateFrom).ToShortDateString() + " - " + Convert.ToDateTime(procurementDateTo).ToShortDateString();

                StatisticNumberValues statisticNumberValues = new StatisticNumberValues(period, listTransportDuration.Count, median, mean, variance, standardDeviation);

                listTransportDuration.Add(statisticNumberValues);

                return listTransportDuration;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading statistic numbers report data due to an error: " + ex.Message);
            }

            return new List<StatisticNumberValues>();
        }

        #region Privates
        /// <summary>
        /// Creates list of StatisticPeriod including month names and periods per month
        /// </summary>
        /// <param name="datePeriodFrom">period date from</param>
        /// <param name="datePeriodTo">period date to</param>
        /// <returns>list of StatisticPeriod having monthly portions of periods</returns>
        private List<StatisticPeriod> GetStatisticPeriod(DateTime datePeriodFrom, DateTime datePeriodTo)
        {
            // If dateFrom > dateTo, invert
            if (datePeriodFrom > datePeriodTo) 
            {
                var temp = datePeriodFrom;
                datePeriodFrom = datePeriodTo;
                datePeriodTo = temp;
            }

            DateTime dateFrom = datePeriodFrom;
            DateTime dateTo = datePeriodTo;

            DateTimeFormatInfo mfi = new DateTimeFormatInfo();

            List<StatisticPeriod> listStatisticPeriods = new List<StatisticPeriod>();
            while (dateFrom.Year <= dateTo.Year && dateFrom.Month <= dateTo.Month)
            {
                string monthName = mfi.GetMonthName(dateFrom.Month).ToString(CultureInfo.InvariantCulture);
                int monthNumber = dateFrom.Month;
                DateTime firstDayOfMonth = new DateTime(dateFrom.Year, dateFrom.Month, 1);
                DateTime lastDayOfMonth = firstDayOfMonth.AddMonths(1).AddDays(-1);

                DateTime monthDateFrom = dateFrom.Month == datePeriodFrom.Month
                                             ? datePeriodFrom
                                             : firstDayOfMonth;
                DateTime monthDateTo = dateTo.Month == dateFrom.Month
                                           ? datePeriodTo
                                           : lastDayOfMonth;

                dateFrom = dateFrom.AddMonths(1);

                StatisticPeriod statisticPeriod = new StatisticPeriod(monthName, monthNumber, monthDateFrom, monthDateTo);

                listStatisticPeriods.Add(statisticPeriod);
            }

            return listStatisticPeriods;
        }

        /// <summary>
        /// Gets all donors with procurement date during specified period and which have transplanted organs in state TX (transplanted)
        /// </summary>
        /// <remarks>
        /// Foreign donors (FO) are ignored for this statistic
        /// </remarks>
        /// <param name="datePeriodFrom">period date from</param>
        /// <param name="datePeriodTo">period date to</param>
        /// <returns></returns>
        private List<Donor> GetSwissDonorsWithTransplantedOrgans(DateTime datePeriodFrom, DateTime datePeriodTo)
        {
            List<Donor> donors = GetDonors(datePeriodFrom, datePeriodTo)
                                    .Where(d => d.TransplantOrgan.Any(to => to.TransplantStatusID == (int) BasePage.TransplantStatus.TX))
                                    .Where(d => d.DonorNumber.StartsWith("ST"))
                                    .ToList();

            return donors;
        }

        /// <summary>
        /// Gets number of transplanted organs in state TX for each donor
        /// </summary>
        /// <param name="datePeriodFrom">period date from</param>
        /// <param name="datePeriodTo">period date to</param>
        /// <returns>list of StatisticTransplantOrganCount</returns>
        private List<StatisticTransplantOrganCount> GetTransplantOrganCount(DateTime datePeriodFrom, DateTime datePeriodTo)
        {
            List<Donor> donors = GetSwissDonorsWithTransplantedOrgans(datePeriodFrom, datePeriodTo);

            List<StatisticTransplantOrganCount> listStatisticTransplantOrganCount = new List<StatisticTransplantOrganCount>();

            foreach (Donor donor in donors)
            {
                List<TransplantOrgan> transplantOrgans = donor.TransplantOrgan
                                                              .Where(to => to.TransplantStatusID == (int) BasePage.TransplantStatus.TX)
                                                              .ToList();

                StatisticTransplantOrganCount statisticTransplantOrganCount = new StatisticTransplantOrganCount(transplantOrgans.Count, donor.ID);

                listStatisticTransplantOrganCount.Add(statisticTransplantOrganCount);
            }

            return listStatisticTransplantOrganCount;
        }

        /// <summary>
        /// Gets Median number of Organ counts from list StatisticTransplantOrganCount
        /// </summary>
        /// <param name="listStatisticTransplantOrganCount">list of StatisticTransplantOrganCount</param>
        /// <returns>returns median out of transplant organ counts in list StatisticTransplantOrganCount</returns>
        private double GetMedian(List<StatisticTransplantOrganCount> listStatisticTransplantOrganCount)
        {
            List<StatisticTransplantOrganCount> sortedList = listStatisticTransplantOrganCount.OrderBy(stoc => stoc.OrganCount).ToList();

            int count = sortedList.Count();
            int itemIndex = count / 2;

            if (count%2 == 0)
            {
                // Even number of items
                double organCount1 = sortedList.ElementAt(itemIndex).OrganCount;
                double organCount2 = sortedList.ElementAt(itemIndex - 1).OrganCount;

                return (organCount1 + organCount2)/2;
            }

            // Odd number of items. 
            return sortedList.ElementAt(itemIndex).OrganCount; 
        }

        /// <summary>
        /// Gets Variance in order to calculate standard deviation
        /// </summary>
        /// <param name="listStatisticTransplantOrganCount">listStatisticTransplantOrganCount</param>
        /// <param name="mean">mean</param>
        /// <returns>variance number </returns>
        private double GetVariance(List<StatisticTransplantOrganCount> listStatisticTransplantOrganCount, double mean)
        {
            double variance = 0;

            foreach (StatisticTransplantOrganCount statisticTransplantOrganCount in listStatisticTransplantOrganCount)
            {
                double derivation = (statisticTransplantOrganCount.OrganCount - mean);
                // square derivation and add to variance value
                variance += derivation * derivation;
            }

            // return variance = average of total variance value
            return variance / listStatisticTransplantOrganCount.Count;
        } 
        #endregion
    }
}