using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucAddresses : UserControl
    {
        public int AddressID
        {
            get { return String.IsNullOrEmpty(hidAddressID.Value) ? 0 : Convert.ToInt32(hidAddressID.Value); }
            set { hidAddressID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        public bool ShowContactPerson = false;

        public bool IsFO { get; set; }

        public bool DeactivateValidators { get; set; }

        public Panel AddressDetailsPanel { get { return pnlAddressDetails; } }

        public Panel ExistingAddressesPanel { get { return pnlExistingAdresses; } }

        private readonly BasePage basePage = new BasePage();

        public void Initialize(bool deactivateValidators = false, bool showContactPerson = false)
        {
            // if passed true by parent page, validators won't trigger
            DeactivateValidators = deactivateValidators;
            ShowContactPerson = showContactPerson;
        }

        protected void Page_Load(object sender, EventArgs e)
        {
            if (DeactivateValidators) DisableValidators();

            trContactPerson.Visible = ShowContactPerson;
        }

        public IQueryable<Address> gvExistingAddress_GetData()
        {
            return GetAddressesWithoutDuplicates();
        }

        private IQueryable<Address> GetAddressesWithoutDuplicates()
        {
            List<Address> addressListWithoutDuplicates = new List<Address>();
            bool addressDoesNotExist = true;

            foreach (Address address in basePage.GetAddresses().ToList())
            {
                foreach (Address addressWithoutDucplicates in addressListWithoutDuplicates)
                {
                    if (address.Address1 == addressWithoutDucplicates.Address1
                        && address.Address2 == addressWithoutDucplicates.Address2
                        && address.Address3 == addressWithoutDucplicates.Address3
                        && address.Address4 == addressWithoutDucplicates.Address4
                        && address.Zip == addressWithoutDucplicates.Zip
                        && address.City == addressWithoutDucplicates.City) addressDoesNotExist = false;
                    else addressDoesNotExist = true;
                }

                if (addressDoesNotExist) addressListWithoutDuplicates.Add(address);
            }

            return addressListWithoutDuplicates.AsQueryable().Distinct();
        }

        protected void btnChooseExisting_Click(object sender, EventArgs e)
        {
            pnlExistingAdresses.Visible = true;

            if (!ShowContactPerson) HideContactPersonColumn(gvExistingAddress);
        }

        protected void gvExistingAddress_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = Page.ClientScript.GetPostBackClientHyperlink(gvExistingAddress, "Select$" + e.Row.RowIndex);
            }
        }

        private static void HideContactPersonColumn(GridView gridView)
        {
            //Hide column ContactPerson
            foreach (DataControlField col in gridView.Columns)
            {
                if (col.HeaderText == "Contact Person")
                {
                    col.Visible = false;
                }
            }
        }

        protected void gvExistingAddress_SelectedIndexChanged(object sender, EventArgs e)
        {
            // Clean all fields
            InitialiseAddressDetailControls();

            // Populate fields from GridView
            GridViewRow row = gvExistingAddress.Rows[gvExistingAddress.SelectedIndex];

            if (row != null)
            {
                Label lblExistingContactPerson = row.FindControl("lblExistingContactPerson") as Label;
                Label lblExistingAddress1 = row.FindControl("lblExistingAddress1") as Label;
                Label lblExistingAddress2 = row.FindControl("lblExistingAddress2") as Label;
                Label lblExistingAddress3 = row.FindControl("lblExistingAddress3") as Label;
                Label lblExistingAddress4 = row.FindControl("lblExistingAddress4") as Label;
                Label lblExistingZip = row.FindControl("lblExistingZip") as Label;
                Label lblExistingCity = row.FindControl("lblExistingCity") as Label;
                Label lblExistingPhone = row.FindControl("lblExistingPhone") as Label;
                Label lblExistingFax = row.FindControl("lblExistingFax") as Label;
                Label lblExistingCountryISO = row.FindControl("lblExistingCountryISO") as Label;

                if (lblExistingContactPerson != null) txtContactPerson.Text = lblExistingContactPerson.Text;
                if (lblExistingAddress1 != null) txtAddress1.Text = lblExistingAddress1.Text;
                if (lblExistingAddress2 != null) txtAddress2.Text = lblExistingAddress2.Text;
                if (lblExistingAddress3 != null) txtAddress3.Text = lblExistingAddress3.Text;
                if (lblExistingAddress4 != null) txtAddress4.Text = lblExistingAddress4.Text;
                if (lblExistingZip != null) txtZip.Text = lblExistingZip.Text;
                if (lblExistingCity != null) txtCity.Text = lblExistingCity.Text;
                if (lblExistingPhone != null) txtPhone.Text = lblExistingPhone.Text;
                if (lblExistingFax != null) txtFax.Text = lblExistingFax.Text;
                if (lblExistingCountryISO != null)
                {
                    txtCountryISO.Text = lblExistingCountryISO.Text;
                    IsFO = (lblExistingCountryISO.Text != "CH");
                }
            }

            pnlExistingAdresses.Visible = false;
        }

        public void InitialiseAddressDetailControls()
        {
            txtContactPerson.Text = String.Empty;
            txtAddress1.Text = String.Empty;
            txtAddress2.Text = String.Empty;
            txtAddress3.Text = String.Empty;
            txtAddress4.Text = String.Empty;
            txtZip.Text = String.Empty;
            txtCity.Text = String.Empty;
            txtCountryISO.Text = String.Empty;
            txtPhone.Text = String.Empty;
            txtFax.Text = String.Empty;
            txtEmail.Text = String.Empty;
        }

        public void PopulateAddressDetailView(Address address)
        {
            txtContactPerson.Text = address.ContactPerson;
            txtAddress1.Text = address.Address1;
            txtAddress2.Text = address.Address2;
            txtAddress3.Text = address.Address3;
            txtAddress4.Text = address.Address4;
            txtZip.Text = address.Zip;
            txtCity.Text = address.City;
            txtCountryISO.Text = address.CountryISO;
            txtPhone.Text = address.Phone;
            txtFax.Text = address.Fax;
            txtEmail.Text = address.Email;
            AddressID = address.ID;
        }

        public void AssignValuesToAddress()
        {
            if (AddressExists())
            {
                return;
            }

            // Check if there are other coordinators on this address
            DataService<Coordinator> dsCoordinator = new DataService<Coordinator>(basePage.Data);
            int addressCount = dsCoordinator.FindAll(c => c.AddressID == AddressID).Count();

            bool isRowAdded = AddressID == 0;
            Address address;

            if (isRowAdded || addressCount > 1)
            {
                // create new datarow
                address = new Address();
                basePage.Data.Address.Add(address);
            }
            else
            {
                // update existing datarow
                address = basePage.GetAddressByID(AddressID);
                if (address == null) throw new ArgumentNullException(String.Format("Address with ID {0} could not be found!", AddressID));
            }

            address.ContactPerson = !String.IsNullOrWhiteSpace(txtContactPerson.Text) ? txtContactPerson.Text : null;
            address.Address1 = !String.IsNullOrWhiteSpace(txtAddress1.Text) ? txtAddress1.Text : null;
            address.Address2 = !String.IsNullOrWhiteSpace(txtAddress2.Text) ? txtAddress2.Text : null;
            address.Address3 = !String.IsNullOrWhiteSpace(txtAddress3.Text) ? txtAddress3.Text : null;
            address.Address4 = !String.IsNullOrWhiteSpace(txtAddress4.Text) ? txtAddress4.Text : null;
            address.Zip = !String.IsNullOrWhiteSpace(txtZip.Text) ? txtZip.Text : null;
            address.City = !String.IsNullOrWhiteSpace(txtCity.Text) ? txtCity.Text : null;
            address.CountryISO = !String.IsNullOrWhiteSpace(txtCountryISO.Text.Trim()) ? txtCountryISO.Text : null;
            address.Phone = !String.IsNullOrWhiteSpace(txtPhone.Text) ? txtPhone.Text : null;
            address.Fax = !String.IsNullOrWhiteSpace(txtFax.Text) ? txtFax.Text : null;
            address.Email = !String.IsNullOrWhiteSpace(txtEmail.Text) ? txtEmail.Text : null;

            AddressID = address.ID;
        }

        private bool AddressExists()
        {
            String contactPerson = txtContactPerson.Text.Trim();
            String address1 = txtAddress1.Text.Trim();
            String address2 = txtAddress2.Text.Trim();
            String address3 = txtAddress3.Text.Trim();
            String address4 = txtAddress4.Text.Trim();
            String zip = txtZip.Text.Trim();
            String city = txtCity.Text.Trim();
            String countryISO = txtCountryISO.Text.Trim();
            String phone = txtPhone.Text.Trim();
            String fax = txtFax.Text.Trim();
            String email = txtEmail.Text.Trim();

            IQueryable<Address> iqAddress = basePage.GetAddresses()
                                      .Where(a => (!String.IsNullOrEmpty(contactPerson) && a.ContactPerson == txtContactPerson.Text)
                                                  || (String.IsNullOrEmpty(contactPerson) && String.IsNullOrEmpty(a.ContactPerson)))
                                      .Where(a => (!String.IsNullOrEmpty(address1) && a.Address1 == txtAddress1.Text)
                                                  || (String.IsNullOrEmpty(address1) && String.IsNullOrEmpty(a.Address1)))
                                      .Where(a => (!String.IsNullOrEmpty(address2) && a.Address2 == txtAddress2.Text)
                                                  || (String.IsNullOrEmpty(address2) && String.IsNullOrEmpty(a.Address2)))
                                      .Where(a => (!String.IsNullOrEmpty(address3) && a.Address3 == txtAddress3.Text)
                                                  || (String.IsNullOrEmpty(address3) && String.IsNullOrEmpty(a.Address3)))
                                      .Where(a => (!String.IsNullOrEmpty(address4) && a.Address4 == txtAddress4.Text)
                                                  || (String.IsNullOrEmpty(address4) && String.IsNullOrEmpty(a.Address4)))
                                      .Where(a => (!String.IsNullOrEmpty(zip) && a.Zip == txtZip.Text)
                                                  || (String.IsNullOrEmpty(zip) && String.IsNullOrEmpty(a.Zip)))
                                      .Where(a => (!String.IsNullOrEmpty(city) && a.City == txtCity.Text)
                                                  || (String.IsNullOrEmpty(city) && String.IsNullOrEmpty(a.City)))
                                      .Where(a => (!String.IsNullOrEmpty(countryISO) && a.CountryISO == txtCountryISO.Text)
                                                  || (String.IsNullOrEmpty(countryISO) && String.IsNullOrEmpty(a.CountryISO)))
                                      .Where(a => (!String.IsNullOrEmpty(phone) && a.Phone == txtPhone.Text)
                                                  || (String.IsNullOrEmpty(phone) && String.IsNullOrEmpty(a.Phone)))
                                      .Where(a => (!String.IsNullOrEmpty(fax) && a.Fax == txtFax.Text)
                                                  || (String.IsNullOrEmpty(fax) && String.IsNullOrEmpty(a.Fax)))
                                      .Where(a => (!String.IsNullOrEmpty(email) && a.Email == txtEmail.Text)
                                                            || (String.IsNullOrEmpty(email) && String.IsNullOrEmpty(a.Email)));

            if (iqAddress != null && iqAddress.Count() > 0)
            {
                Address address = iqAddress.First();
                AddressID = address.ID;
                return true;
            }

            return false;
        }

        private void DisableValidators()
        {
            // disable validators
            rfvAddress1.Enabled = false;
            rfvCity.Enabled = false;
            rfvCountryISO.Enabled = false;

            // reset labels
            lblAddress1.Text = lblAddress1.Text.Replace("*", "");
            lblCity.Text = lblCity.Text.Replace("*", "");
            lblCountryISO.Text = lblCountryISO.Text.Replace("*", "");
        }
    }
}