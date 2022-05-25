using System;
using System.Data;
using System.Data.SqlClient;
using System.Web.Configuration;

namespace Pentag.SLIDS.DAL
{
    public class Ado : IDisposable
    {
        private const string sqlQuery = "select * from {0} where [Donor Number] like @DonorNo ";

        private readonly SqlConnection con;

        public Ado()
        {
            try
            {
                string conStr = WebConfigurationManager.ConnectionStrings["SLIDS"].ConnectionString;
                con = new SqlConnection(conStr);
                con.Open();
            }
            catch (Exception ex)
            {
                throw new Exception("Failed to open Database Connection", ex);
            }
        }

        public void Dispose()
        {
            if (con == null) return;

            con.Close();
            con.Dispose();
        }

        public DataTable GetDataFromWiew(string viewName, SearchParameters searchParameters)
        {
            try
            {
                DataTable dt = new DataTable(viewName);
                using (SqlCommand com = new SqlCommand(String.Format(sqlQuery, viewName), con))
                {
                    com.CommandType = CommandType.Text;
                    SqlParameter paramDonorNo = new SqlParameter("@DonorNo", searchParameters.DonorNo);
                    com.Parameters.Add(paramDonorNo);
                    if (!String.IsNullOrEmpty(searchParameters.MinRegDate))
                    {
                        com.CommandText += " and [Register Date] >= @MinRegDate ";
                        SqlParameter paramMaxProcDate = new SqlParameter("@MinRegDate", SqlDbType.Date);
                        paramMaxProcDate.Value = Convert.ToDateTime(searchParameters.MinRegDate);
                        com.Parameters.Add(paramMaxProcDate);
                    }
                    if (!String.IsNullOrEmpty(searchParameters.MaxRegDate))
                    {
                        com.CommandText += " and [Register Date] <= @MaxRegDate ";
                        SqlParameter paramMaxProcDate = new SqlParameter("@MaxRegDate", SqlDbType.Date);
                        paramMaxProcDate.Value = Convert.ToDateTime(searchParameters.MaxRegDate);
                        com.Parameters.Add(paramMaxProcDate);
                    }
                    using (SqlDataReader reader = com.ExecuteReader())
                    {
                        dt.Load(reader);
                    }
                }
                return dt;
            }
            catch (Exception ex)
            {
                throw new Exception("Select Data from View " + viewName + " failed", ex);
            }
        }

        public class SearchParameters
        {
            private string donorNo;

            public SearchParameters(string donorNumber, string minimumRegisterDate, string maximumRgisterDate)
            {
                DonorNo = donorNumber;
                MinRegDate = minimumRegisterDate;
                MaxRegDate = maximumRgisterDate;
            }

            internal string DonorNo
            {
                get { return "%" + donorNo + "%"; }
                private set { donorNo = value; }
            }

            internal string MinRegDate { get; private set; }
            internal string MaxRegDate { get; private set; }
        }
    }
}