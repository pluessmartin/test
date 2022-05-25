using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucIncidentDonor : System.Web.UI.UserControl
    {
        public string DonorNumber { get; set; }
        public int IncidentId { get; set; }

        /// <summary>
        /// On Page loading
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
        }

        public bool Enabled { get; set; }

        /// <summary>
        /// Gets a BasePage
        /// </summary>
        protected BasePage BasePage
        {
            get { return new BasePage(); }
        }

        /// <summary>
        /// Return Transportet elements in a string
        /// </summary>
        public string GetTransportedElements(DAL.Transport t)
        {
            return BasePage.GetTransportedElements(t);
        }

        /// <summary>
        /// Binding Data
        /// </summary>
        protected void gridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            BasePage.gridView_RowDataBound(sender, e);
        }

        /// <summary>
        /// Shows Donor releated informations
        /// </summary>
        protected void chkisplayAddDonorReleatedInformation_CheckedChanged(object sender, EventArgs e)
        {
            panelAddDonorReleatedInformation.Visible = chkisplayAddDonorReleatedInformation.Checked;
        }

        #region Getting Data
        /// <summary>
        /// Gets the data for Organ grid
        /// </summary>
        public IQueryable<Pentag.SLIDS.DAL.TransplantOrgan> gvOrgans_GetData()
        {
            return from to in BasePage.Data.TransplantOrgan
                   join don in BasePage.Data.Donor on to.DonorID equals don.ID
                   where don.DonorNumber == DonorNumber
                   select to;
        }

        /// <summary>
        /// Gets data for Transport grid
        /// </summary>
        public IQueryable<Pentag.SLIDS.DAL.Transport> gvTransports_GetData()
        {
            return from trans in BasePage.Data.Transport
                   join don in BasePage.Data.Donor on trans.DonorID equals don.ID
                   where don.DonorNumber == DonorNumber
                   select trans;
        }

        /// <summary>
        /// Gets data for delay grid
        /// </summary>
        public IQueryable<Pentag.SLIDS.DAL.Delay> gvDelays_GetData()
        {
            return from del in BasePage.Data.Delay
                   join trans in BasePage.Data.Transport on del.TransportID equals trans.ID
                   join don in BasePage.Data.Donor on trans.DonorID equals don.ID
                   where don.DonorNumber == DonorNumber
                   select del;
        }
        #endregion

        #region DataBind
        /// <summary>
        /// Binds all grid views
        /// </summary>
        override public void DataBind()
        {
            base.DataBind();
            gvDelays.DataBind();
            bool delay = gvDelays.DataKeys.Count != 0;
            panelDelays.Visible = delay;
            gvOrgans.DataBind();
            bool organ = gvOrgans.DataKeys.Count != 0;
            panelOrgans.Visible = organ;
            gvTransports.DataBind();
            bool transport = gvTransports.DataKeys.Count != 0;
            panelTransports.Visible = transport;

            //this.Visible = !(panelDelays.Visible == false && panelOrgans.Visible == false && panelTransports.Visible == false);
            PopulateOrgan();
            PopulateTransports();
            PopulateDelays();

            bool visible = new DataService<Donor>(BasePage.Data).Find(d => d.DonorNumber == DonorNumber) != null
                && (delay || organ || transport);
            chkisplayAddDonorReleatedInformation.Visible = visible;
            upAddDonorReleatedInformation.Visible = visible;

        }

        /// <summary>
        /// Populate all chekcboxes on organ grid
        /// </summary>
        private void PopulateOrgan()
        {
            List<IncidentDonorRelatedOrgan> idro = new DataService<IncidentDonorRelatedOrgan>(BasePage.Data).FindAll(o => o.IncidentID == IncidentId).ToList();
            foreach (GridViewRow row in gvOrgans.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkOrganTable = (CheckBox)row.FindControl("chkOrganTable");
                    chkOrganTable.Enabled = Enabled;

                    int transplantOrganID = (int)gvOrgans.DataKeys[row.RowIndex].Value;
                    if (idro.Where(o => o.TransplantOrganID == transplantOrganID).Count() != 0)
                    {
                        chkOrganTable.Checked = true;
                    }
                }
            }
        }

        /// <summary>
        /// Populate all checkboxes on transport grid
        /// </summary>
        private void PopulateTransports()
        {
            List<IncidentDonorRelatedTransport> idrt = new DataService<IncidentDonorRelatedTransport>(BasePage.Data).FindAll(t => t.IncidentID == IncidentId).ToList();
            foreach (GridViewRow row in gvTransports.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkTransportTable = (CheckBox)row.FindControl("chkTransportTable");
                    chkTransportTable.Enabled = Enabled;

                    int transportId = (int)gvTransports.DataKeys[row.RowIndex].Value;
                    if (idrt.Where(t => t.TransportID == transportId).Count() != 0)
                    {
                        chkTransportTable.Checked = true;
                    }
                }
            }
        }

        /// <summary>
        /// Populate all checkboxes ob delay grid
        /// </summary>
        private void PopulateDelays()
        {
            List<IncidentDonorRelatedDelay> idrd = new DataService<IncidentDonorRelatedDelay>(BasePage.Data).FindAll(d => d.IncidentID == IncidentId).ToList();
            foreach (GridViewRow row in gvDelays.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkDelayTable = (CheckBox)row.FindControl("chkDelayTable");
                    chkDelayTable.Enabled = Enabled;

                    int delayId = (int)gvDelays.DataKeys[row.RowIndex].Value;
                    if (idrd.Where(d => d.DelayID == delayId).Count() != 0)
                    {
                        chkDelayTable.Checked = true;
                    }
                }
            }
        }
        #endregion

        #region save
        /// <summary>
        /// Saves all marked checkboxes
        /// </summary>
        public void Save()
        {
            if (IncidentId != 0)
            {
                SaveOrganCheckboxes();
                SaveTransportCheckboxes();
                SaveDelayCheckboxes();
            }
            else
            {
                throw new Exception("There is no IncidentId!");
            }
        }

        /// <summary>
        /// Saves checkboxes on organ grid
        /// </summary>
        private void SaveOrganCheckboxes()
        {
            DataService<IncidentDonorRelatedOrgan> dsIdro = new DataService<IncidentDonorRelatedOrgan>(BasePage.Data);
            // Getting all marked organs on database
            List<IncidentDonorRelatedOrgan> organs = (from releatedOrgan in BasePage.Data.IncidentDonorRelatedOrgan
                                                      where releatedOrgan.IncidentID == IncidentId
                                                      select releatedOrgan).ToList();
            List<IncidentDonorRelatedOrgan> organsSelected = new List<IncidentDonorRelatedOrgan>();

            // Getting all marked organs on grid
            foreach (GridViewRow row in gvOrgans.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkOrganTable = (CheckBox)row.FindControl("chkOrganTable");
                    if (chkOrganTable.Checked)
                    {
                        IncidentDonorRelatedOrgan idro = new IncidentDonorRelatedOrgan()
                        {
                            TransplantOrganID = (int)gvOrgans.DataKeys[row.RowIndex].Value,
                            IncidentID = IncidentId
                        };
                        organsSelected.Add(idro);
                    }
                }
            }

            // Delete not used entries
            foreach (IncidentDonorRelatedOrgan organ in organs)
            {
                if (!organsSelected.Exists(o => o.TransplantOrganID == organ.TransplantOrganID))
                {
                    dsIdro.Delete(organ);
                }
            }
            // Add new entries
            foreach (IncidentDonorRelatedOrgan organ in organsSelected)
            {
                if (!organs.Exists(o => o.TransplantOrganID == organ.TransplantOrganID))
                {
                    dsIdro.Add(organ);
                }
            }
        }

        /// <summary>
        /// Save checkboxes on transport grid
        /// </summary>
        private void SaveTransportCheckboxes()
        {
            DataService<IncidentDonorRelatedTransport> dsIdrt = new DataService<IncidentDonorRelatedTransport>(BasePage.Data);
            List<IncidentDonorRelatedTransport> Transports = (from releatedTransport in BasePage.Data.IncidentDonorRelatedTransport
                                                              where releatedTransport.IncidentID == IncidentId
                                                              select releatedTransport).ToList();
            List<IncidentDonorRelatedTransport> TransportsSelected = new List<IncidentDonorRelatedTransport>();

            foreach (GridViewRow row in gvTransports.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkTransportTable = (CheckBox)row.FindControl("chkTransportTable");
                    if (chkTransportTable.Checked)
                    {
                        IncidentDonorRelatedTransport idro = new IncidentDonorRelatedTransport()
                        {
                            TransportID = (int)gvTransports.DataKeys[row.RowIndex].Value,
                            IncidentID = IncidentId
                        };
                        TransportsSelected.Add(idro);
                    }
                }
            }

            foreach (IncidentDonorRelatedTransport Transport in Transports)
            {
                if (!TransportsSelected.Exists(t => t.TransportID == Transport.TransportID))
                {
                    dsIdrt.Delete(Transport);
                }
            }
            foreach (IncidentDonorRelatedTransport Transport in TransportsSelected)
            {
                if (!Transports.Exists(t => t.TransportID == Transport.TransportID))
                {
                    dsIdrt.Add(Transport);
                }
            }
        }

        /// <summary>
        /// Save checkboxes on delay grid
        /// </summary>
        private void SaveDelayCheckboxes()
        {
            DataService<IncidentDonorRelatedDelay> dsIdrd = new DataService<IncidentDonorRelatedDelay>(BasePage.Data);
            List<IncidentDonorRelatedDelay> Delays = (from releatedDelay in BasePage.Data.IncidentDonorRelatedDelay
                                                      where releatedDelay.IncidentID == IncidentId
                                                      select releatedDelay).ToList();
            List<IncidentDonorRelatedDelay> DelaysSelected = new List<IncidentDonorRelatedDelay>();

            foreach (GridViewRow row in gvDelays.Rows)
            {
                if (row.RowType == DataControlRowType.DataRow)
                {
                    CheckBox chkDelayTable = (CheckBox)row.FindControl("chkDelayTable");
                    if (chkDelayTable.Checked)
                    {
                        IncidentDonorRelatedDelay idro = new IncidentDonorRelatedDelay()
                        {
                            DelayID = (int)gvDelays.DataKeys[row.RowIndex].Value,
                            IncidentID = IncidentId
                        };
                        DelaysSelected.Add(idro);
                    }
                }
            }

            foreach (IncidentDonorRelatedDelay Delay in Delays)
            {
                if (!DelaysSelected.Exists(d => d.DelayID == Delay.DelayID))
                {
                    dsIdrd.Delete(Delay);
                }
            }
            foreach (IncidentDonorRelatedDelay Delay in DelaysSelected)
            {
                if (!Delays.Exists(d => d.DelayID == Delay.DelayID))
                {
                    dsIdrd.Add(Delay);
                }
            }
        }
        #endregion

        /// <summary>
        /// Preselect Organs
        /// </summary>
        internal void SelectOrgan(int ID)
        {
            Visible = CheckChekboxInGridView(gvOrgans, ID, "chkOrganTable");
        }

        /// <summary>
        /// Preselect Transports
        /// </summary>
        /// <param name="ID"></param>
        internal void SelectTransport(int ID)
        {
            Visible = CheckChekboxInGridView(gvTransports, ID, "chkTransportTable");
        }

        /// <summary>
        /// Preselect Delays
        /// </summary>
        internal void SelectTransportDelays(int transportID)
        {
            IQueryable<DAL.Delay> delays = new DataService<DAL.Delay>(BasePage.Data).GetAll().Where(d => d.TransportID == transportID);
            List<int> delaysId = new List<int>();
            foreach (DAL.Delay delay in delays)
            {
                delaysId.Add(delay.ID);
            }
            Visible = CheckChekboxInGridView(gvDelays, delaysId, "chkDelayTable");
        }
        /// <summary>
        /// Selects row in DataGrid with given List
        /// </summary>
        private bool CheckChekboxInGridView(GridView gridView, List<int> listOfIDs, string checkBoxName)
        {
            int i = 0;

            gridView.DataBind();
            for (gridView.PageIndex = 0; gridView.PageIndex < gridView.PageCount; gridView.PageIndex++)
            {
                gridView.DataBind();
                foreach (GridViewRow row in gridView.Rows)
                {

                    var dataKey = gridView.DataKeys[row.RowIndex];
                    if (dataKey == null || !listOfIDs.Contains((int)dataKey.Value)) continue;

                    CheckBox chkCheckbox = (CheckBox)row.FindControl(checkBoxName);
                    chkCheckbox.Checked = true;
                    i++;
                    if (i >= listOfIDs.Count)
                    {
                        return true;
                    }
                }
            }
            gridView.SelectedIndex = -1;
            gridView.PageIndex = 0;
            return false;
        }

        /// <summary>
        /// Selects row in DataGrid with given ID
        /// </summary>
        private bool CheckChekboxInGridView(GridView gridView, int ID, string checkBoxName)
        {
            List<int> list = new List<int>();
            list.Add(ID);
            return CheckChekboxInGridView(gridView, list, checkBoxName);
        }
    }
}