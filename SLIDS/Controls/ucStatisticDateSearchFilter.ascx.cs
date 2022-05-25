using System;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucStatisticDateSearchFilter : UserControl
    {
        #region Properties
        public TextBox DateFromTextBox { get { return TxtDateFrom; } }

        public TextBox DateToTextBox { get { return TxtDateTo; } }

        public string StringDateFrom
        {
            get { return TxtDateFrom.Text; }
            set { TxtDateFrom.Text = value; }
        }

        public string StringDateTo 
        {
            get { return TxtDateTo.Text; }
            set { TxtDateTo.Text = value; }
        }

        public DateTime? DateFrom
        {
            get
            {
                DateTime dateFrom;
                return String.IsNullOrEmpty(TxtDateFrom.Text)
                           ? null
                           : DateTime.TryParse(TxtDateFrom.Text, out dateFrom)
                                 ? DateTime.Parse(TxtDateFrom.Text)
                                 : (DateTime?) null;
            }
        }

        public DateTime? DateTo
        {
            get
            {
                DateTime dateTo;
                return String.IsNullOrEmpty(TxtDateTo.Text)
                           ? null
                           : DateTime.TryParse(TxtDateFrom.Text, out dateTo)
                                 ? DateTime.Parse(TxtDateTo.Text)
                                 : (DateTime?) null;
            }
        }

        private string SearchLabel = "Procurement date";

        public bool DateFieldsAreRequired { get; set; }
        #endregion

        public void Initialize(bool dateFieldsAreRequired = false, string searchLabel = null)
        {
            DateFieldsAreRequired = dateFieldsAreRequired;

            if (searchLabel != null) SearchLabel = searchLabel;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            lblDateSearch.Text = SearchLabel;

            rfvProcurementDateFrom.Enabled = DateFieldsAreRequired;
            rfvProcurementDateTo.Visible = DateFieldsAreRequired;
        }
    }
}