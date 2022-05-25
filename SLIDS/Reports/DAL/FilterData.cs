using System;
using System.Collections.Generic;

namespace Pentag.SLIDS.Reports.DAL
{
    #region reports data structures
    public class FilterDataValue
    {
        public DateTime? ProcurementDateFrom { get; set; }
        public DateTime? ProcurementDateTo { get; set; }
        public string Period { get; set; }

        public FilterDataValue(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            ProcurementDateFrom = procurementDateFrom;
            ProcurementDateTo = procurementDateTo;
            string procDateFrom = procurementDateFrom != null ? Convert.ToDateTime(procurementDateFrom).ToString("dd.MM.yyyy") : String.Empty;
            string procDateTo = procurementDateTo != null ? Convert.ToDateTime(procurementDateTo).ToString("dd.MM.yyyy") : String.Empty;
            Period = procDateFrom + " - " + procDateTo;
        }
    }
    #endregion

    public class FilterData : Common
    {
        /// <summary>
        /// Used in Statistical Report header, displays filter period
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>list of FilterDataValue</returns>
        public List<FilterDataValue> GetFilterDataValue(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                List<FilterDataValue> listFilterDataValue = new List<FilterDataValue>();

                FilterDataValue filterDataValue = new FilterDataValue(procurementDateFrom, procurementDateTo);

                listFilterDataValue.Add(filterDataValue);

                return listFilterDataValue;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading filter data report data due to an error: " + ex.Message);
            }

            return new List<FilterDataValue>();
        }
    }
}