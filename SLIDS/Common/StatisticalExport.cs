using System;
using System.Data;
using System.IO;
using OfficeOpenXml;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS
{
    public class StatisticalExport : IDisposable
    {
        private readonly ExcelPackage excel;

        public StatisticalExport()
        {
            MemoryStream stream = new MemoryStream();
            excel = new ExcelPackage(stream);
        }

        public void Dispose()
        {
            if (excel != null)
            {
                excel.Dispose();
            }
        }

        public MemoryStream CreateExcel(Ado.SearchParameters filter)
        {
            try
            {
                using (Ado ado = new Ado())
                {
                    DataTable data;
                    data = ado.GetDataFromWiew(ViewName.StatsDonor, filter);
                    AddWorksheet(ViewName.StatsDonor, data);
                    data = ado.GetDataFromWiew(ViewName.StatsOrgans, filter);
                    AddWorksheet(ViewName.StatsOrgans, data);
                    data = ado.GetDataFromWiew(ViewName.StatsTransports, filter);
                    AddWorksheet(ViewName.StatsTransports, data);
                    data = ado.GetDataFromWiew(ViewName.StatsGeneralCosts, filter);
                    AddWorksheet(ViewName.StatsGeneralCosts, data);
                    data = ado.GetDataFromWiew(ViewName.StatsTransportCosts, filter);
                    AddWorksheet(ViewName.StatsTransportCosts, data);

                    data = ado.GetDataFromWiew(ViewName.StatsDonorWhiteTransporttime, filter);
                    AddWorksheet(ViewName.StatsDonorWhiteTransporttime, data);
                    excel.Save();
                }
                return (MemoryStream) excel.Stream;
            }
            catch (Exception ex)
            {
                throw new Exception("Excel file could not be created", ex);
            }
        }


        public MemoryStream CreateExcel(DataTable data1, DataTable data2)
        {
            try
            {
                using (Ado ado = new Ado())
                {
                    AddWorksheet("Process", data1);
                    AddWorksheet("Category", data2);

                    excel.Save();
                }
                return (MemoryStream)excel.Stream;
            }
            catch (Exception ex)
            {
                throw new Exception("Excel file could not be created", ex);
            }
        }

        private void AddWorksheet(string name, DataTable data)
        {
            try
            {
                ExcelWorksheet sheet1 = excel.Workbook.Worksheets.Add(name);
                sheet1.Cells["A1"].LoadFromDataTable(data, true);

                //apply Format
                if (data.Rows.Count > 0)
                {
                    int column = 0;
                    foreach (DataColumn col in data.Columns)
                    {
                        column++;
                        if (col.DataType == typeof (DateTime) || col.DataType == typeof (DateTime?))
                        {
                            if (ColumnHasTime(data, column - 1))
                            {
                                sheet1.Cells[2, column, data.Rows.Count + 1, column].Style.Numberformat.Format =
                                    "dd.mm.yyyy hh:MM";
                            }
                            else
                            {
                                sheet1.Cells[2, column, data.Rows.Count + 1, column].Style.Numberformat.Format =
                                    "dd.mm.yyyy";
                            }
                        }
                    }
                    sheet1.Cells[1, 1, data.Rows.Count + 1, column].AutoFitColumns();
                }
            }
            catch (Exception ex)
            {
                throw new Exception(String.Format("Worksheet {0} could not be added to excel file", name), ex);
            }
        }

        private bool ColumnHasTime(DataTable table, int column)
        {
            DateTime toCheck;
            bool hasTime = false;
            foreach (DataRow row in table.Rows)
            {
                if (!String.IsNullOrEmpty(row[column].ToString()))
                {
                    toCheck = (DateTime) row[column];
                    if (toCheck.Hour != 0 || toCheck.Minute != 0)
                    {
                        hasTime = true;
                        break;
                    }
                }
            }
            return hasTime;
        }
    }
}