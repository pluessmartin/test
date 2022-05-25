using Pentag.SLIDS.Common;
using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Web.Security;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public partial class IncidentLexicon : BasePage
    {
        private DataService<Pentag.SLIDS.DAL.IncidentLexicon> dataService;

        /// <summary>
        /// ID of IncidentLexicon
        /// </summary>
        protected int IncidentLexiconId
        {
            get { return hidIncidentLexiconID.Value == String.Empty ? 0 : Convert.ToInt32(hidIncidentLexiconID.Value); }
            set { hidIncidentLexiconID.Value = value.ToString(CultureInfo.InvariantCulture); }
        }

        /// <summary>
        /// On page load
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            // Load dataService for comunication to database
            dataService = new DataService<Pentag.SLIDS.DAL.IncidentLexicon>(Data);
            if (!IsPostBack)
            {
                SetVisbility();
            }
        }

        /// <summary>
        /// Set Visibility
        /// </summary>
        private void SetVisbility()
        {
            if (!Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentAdmin.ToString()))
            {
                btnAddNew.Visible = false;
                pnlIncidentsLexiconHelpAdd.Visible = false;
            }
        }

        #region gvLexicons

        /// <summary>
        /// Selection/Fill Method for gvAlerts
        /// </summary>
        /// <returns></returns>
        public IQueryable<Pentag.SLIDS.DAL.IncidentLexicon> gvLexicons_GetData()
        {
            return dataService.GetAll().Where(il => il.IsDeleted == false);
        }

        /// <summary>
        /// Adds postback-event to rows
        /// </summary>
        protected void gvLexicons_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvLexicons, "Select$" + e.Row.RowIndex);
            }
        }

        /// <summary>
        /// On changing selected row set new ID
        /// </summary>
        protected void gvLexicons_SelectedIndexChanged(object sender, EventArgs e)
        {
            if (gvLexicons.SelectedIndex == -1 || gvLexicons.SelectedDataKey == null) return;

            IncidentLexiconId = Convert.ToInt32(gvLexicons.SelectedDataKey.Value);

            LoadAndViewIncidentLexiconDetails();
            gvDocuments.DataBind();
        }
        #endregion

        #region gvDocuments
        /// <summary>
        /// Selection/Fill Method for gvAlerts
        /// </summary>
        /// <returns></returns>
        public IQueryable<IncidentLexiconDocument> gvDocuments_GetData()
        {
            return (new DataService<IncidentLexiconDocument>(Data)).GetAll().Where(ild => ild.IncidentLexiconID == IncidentLexiconId);
        }

        /// <summary>
        /// Adds postback-event to rows
        /// </summary>
        protected void gvDocuments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink(gvDocuments, "Select$" + e.Row.RowIndex);
            }
        }
        #endregion

        /// <summary>
        /// Button Add new Incident Lexicon / Help
        /// </summary>
        protected void btnAddNew_Click(object sender, EventArgs e)
        {
            // Reset all fields
            IncidentLexiconId = 0;
            divIncidentsLexiconHelpAdd.Attributes["style"] = "visibility: visible";
            btnUpload.Enabled = false;
            txtDefinition.Enabled = true;
            txtDefinition.Text = String.Empty;
            txtDescription.Text = String.Empty;
            txtInfoDescription.Text = String.Empty;
            gvDocuments.DataBind(); // reload documents
            gvLexicons.SelectedIndex = -1; // unselect grid
        }

        /// <summary>
        /// On save for Incident lexicon
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            DAL.IncidentLexicon il = AssignValuesToIncidentLexicon();
            txtDefinition.Enabled = false;
            btnUpload.Enabled = true;

            // Sava on Data Service
            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            // Set new ID
            IncidentLexiconId = il.ID;

            // Refresh & Reselect DataGrid
            gvLexicons.DataBind();
            SelectRowInGridView(IncidentLexiconId);
        }

        /// <summary>
        /// Selects row in DataGrid with given ID
        /// </summary>
        /// <param name="incidentLexiconID">Incident Lexicon ID</param>
        private void SelectRowInGridView(int incidentLexiconID)
        {
            for (int i = 0; i < gvLexicons.Rows.Count; i++)
            {
                var dataKey = gvLexicons.DataKeys[i];
                if (dataKey != null && incidentLexiconID != Convert.ToInt32(dataKey.Value)) continue;

                gvLexicons.SelectRow(i);
                return;
            }
        }

        /// <summary>
        /// On deleting incident lexicon
        /// </summary>
        protected void btnDelete_Click(object sender, EventArgs e)
        {
            if (IncidentLexiconId != 0)
            {
                DAL.IncidentLexicon il = dataService.Get(IncidentLexiconId);
                if (il == null)
                {
                    throw new NullReferenceException(String.Format("Incident lexicon with ID {0} could not be found!", IncidentLexiconId));
                }

                // Set Flag IsDeleted
                il.IsDeleted = true;
            }
            if (Data.SaveChanges() > 0)
            {
                Master.SetInfoLabel(StatusMessages.MsgDeleteSuccess, SLIDSMaster.LabelState.Success);

                // Reset IncidentLexiconId and refresh DataGrid
                IncidentLexiconId = 0;
                gvLexicons.DataBind();
                divIncidentsLexiconHelpAdd.Attributes["style"] = "visibility: hidden";
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
            }

            if (gvLexicons.PageIndex > gvLexicons.PageCount - 1)
            {
                gvLexicons.PageIndex = gvLexicons.PageCount;
            }
        }

        /// <summary>
        /// Assign values on change or add to fields
        /// </summary>
        private DAL.IncidentLexicon AssignValuesToIncidentLexicon()
        {
            DAL.IncidentLexicon retVal;
            if (IncidentLexiconId == 0)
            {
                // New record
                retVal = new DAL.IncidentLexicon()
                {
                    Definition = txtDefinition.Text
                };

                Data.IncidentLexicon.Add(retVal);
            }
            else
            {
                // Get actual record
                retVal = dataService.Get(IncidentLexiconId);
            }
            retVal.Description = txtDescription.Text;
            retVal.InfoDescription = txtInfoDescription.Text;

            return retVal;
        }

        /// <summary>
        /// Set new view
        /// </summary>
        private void LoadAndViewIncidentLexiconDetails()
        {
            DAL.IncidentLexicon il = dataService.Get(IncidentLexiconId);
            if (il == null) return;

            SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition();
            PopulateIncidentLexiconDetailView(il);
        }

        /// <summary>
        /// set visibility of incident lexicon / help panel
        /// </summary>
        private void SetVisibilityAndAccessOfControlsDependingOnGivenDataCondition()
        {
            divIncidentsLexiconHelpAdd.Attributes["style"] = "visibility: visible";
        }

        /// <summary>
        /// Set values to fields
        /// </summary>
        private void PopulateIncidentLexiconDetailView(DAL.IncidentLexicon il)
        {
            if (il == null) throw new Exception("IncidentLexicon datarow was not provided!");
            txtDefinition.Text = il.Definition;
            txtDefinition.Enabled = false;
            txtDescription.Text = il.Description;
            txtInfoDescription.Text = il.InfoDescription;
        }

        /// <summary>
        /// Get all Documents to incident lexicon record
        /// </summary>
        public string GetIncidentLexiconDocuments(DAL.IncidentLexicon il)
        {
            string retVal = String.Empty;

            // Adds all documentnames to a string
            DataService<IncidentLexiconDocument> ilds = new DataService<IncidentLexiconDocument>(Data);
            foreach (IncidentLexiconDocument ild in ilds.GetAll().Where(ild => ild.IncidentLexiconID == il.ID))
            {
                retVal = retVal + String.Format("<a href=\"ViewDocument.aspx?incidentLexiconDocument={0}\" target=\"_blank\"><img alt=\"down\" src=\"resources/file_download.png\"></a> {1}<br /> ", ild.ID.ToString(), ild.IncidentLexiconDocumentName);
            }
            return retVal;
        }

        /// <summary>
        /// On uploading a file
        /// </summary>
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fuDocument.HasFile)
            {
                //do save process here// Read the file and convert it to Byte Array
                string filePath = fuDocument.PostedFile.FileName;
                string filename = Path.GetFileName(filePath);
                string ext = Path.GetExtension(filename);

                //Set the contenttype based on File Extension
                string contenttype = BasePage.GetContentType(ext);

                if (contenttype != String.Empty)
                {
                    // Streamreader for saving stream in bytearray
                    Stream fs = fuDocument.PostedFile.InputStream;
                    BinaryReader br = new BinaryReader(fs);
                    Byte[] bytes = br.ReadBytes((Int32)fs.Length);

                    // Create new record
                    IncidentLexiconDocument ild = new IncidentLexiconDocument();
                    ild.IncidentLexiconID = IncidentLexiconId;
                    ild.IncidentLexiconDocumentName = filename;
                    ild.IncidentLexiconDocumentFileType = contenttype;
                    ild.IncidentLexiconDocumentFileData = bytes;

                    Data.IncidentLexiconDocument.Add(ild);
                    if (Data.SaveChanges() > 0)
                    {
                        Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                    }
                    else
                    {
                        Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                    }

                    // Bind grid views
                    gvDocuments.DataBind();
                    gvLexicons.DataBind();
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }
            }
            else
            {
                Master.SetInfoLabel("You have not specified a file.", SLIDSMaster.LabelState.Error);
            }
        }

        /// <summary>
        /// On Deleting Document
        /// </summary>
        public void gvDocuments_DeleteItem(int id)
        {
            DataService<IncidentLexiconDocument> ilds = new DataService<IncidentLexiconDocument>(Data);
            IncidentLexiconDocument ild = ilds.Get(id);
            if (ild != null)
            {
                Data.IncidentLexiconDocument.Remove(ild);
                if (Data.SaveChanges() > 0)
                {
                    Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                }
                else
                {
                    Master.SetInfoLabel(StatusMessages.MsgNoDataModified);
                }
                gvDocuments.DataBind();
                gvLexicons.DataBind();
                IncidentLexiconOverview.Update();
            }
        }
    }
}