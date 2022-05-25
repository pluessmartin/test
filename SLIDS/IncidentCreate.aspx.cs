using Pentag.SLIDS.Constants;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Pentag.SLIDS
{
    public partial class IncidentCreate : BasePage
    {
        public int IncidentId { get; set; }

        /// <summary>
        /// On Loading page
        /// </summary>
        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Debug("Incident Create called");
            if (IsPostBack)
            {
                IncidentId = int.Parse(hidIncidentID.Value);
            }
            else
            {
                hidGUID.Value = Guid.NewGuid().ToString();
                SetToolTipps();
                icIncidentDonorControl.Enabled = true;
                // Load Params
                string donorID = HttpUtility.UrlDecode(Request.QueryString["donorID"]);
                if (donorID != null)
                {
                    Master.DonorID = Convert.ToInt32(donorID);
                    icIncidentControl.DonorNr = new DataService<Donor>(Data).Get(Master.DonorID).DonorNumber;
                }

                // Prefill Informations
                string transplantOrganID = HttpUtility.UrlDecode(Request.QueryString["transplantOrganID"]);
                if (transplantOrganID != null)
                {
                    icIncidentDonorControl.SelectOrgan(int.Parse(transplantOrganID));
                }
                string transportID = HttpUtility.UrlDecode(Request.QueryString["transportID"]);
                if (transportID != null)
                {
                    icIncidentDonorControl.SelectTransport(int.Parse(transportID));
                }
                string transportDelaysID = HttpUtility.UrlDecode(Request.QueryString["transportDelaysID"]);
                if (transportDelaysID != null)
                {
                    icIncidentDonorControl.SelectTransportDelays(int.Parse(transportDelaysID));
                }
                icIncidentDocumentsControl.GUID = hidGUID.Value;
            }
            icIncidentDocumentsControl.ErrorMsg += icIncidentDocumentsControl_ErrorMsg;
        }

        /// <summary>
        /// Displays Error messages when thrown
        /// </summary>
        void icIncidentDocumentsControl_ErrorMsg(object sender, EventArgs e)
        {
            if (sender is KeyValuePair<SLIDSMaster.LabelState, string>)
            {
                KeyValuePair<SLIDSMaster.LabelState, string> error = (KeyValuePair<SLIDSMaster.LabelState, string>)sender;
                Master.SetInfoLabel(error.Value, error.Key);
            }
        }

        /// <summary>
        /// Bind new data on Donor change
        /// </summary>
        protected void icIncidentControl_DonorNrChanged(object sender, EventArgs e)
        {
            if (!Master.IsIncidentUser)
            {
                icIncidentDonorControl.DonorNumber = icIncidentControl.DonorNr;
                icIncidentDonorControl.DataBind();
            }
        }

        /// <summary>
        /// An saving
        /// </summary>
        protected void btnSave_Click(object sender, EventArgs e)
        {
            if (icIncidentControl.IsValid())
            {
                logger.Debug("Incident saving");
                DataService<Incident> dataService = new DataService<Incident>(Data);
                if (IncidentId == 0)
                {
                    Incident incident = icIncidentControl.AssignValuesToIncident(new Incident());
                    Incident incidentCopy = icIncidentControl.AssignValuesToIncident(new Incident());
                    incidentCopy = dataService.Add(incidentCopy);
                    incident.OriginalID = incidentCopy.ID;
                    incident = dataService.Add(incident);
                    IncidentId = incident.ID;

                    logger.Debug("Incident saved");
                    icIncidentDocumentsControl.GUID = String.Empty;
                    icIncidentDocumentsControl.IncidentID = incident.ID;
                    logger.Debug("Incident Documents saved");

                    icIncidentDonorControl.IncidentId = incident.ID;
                    icIncidentDonorControl.Save();
                    logger.Debug("Incident DonorInfos saved");

                    icIncidentControl.PopulateIncidentView(incident);

                    SendMail(incident);

                    // Document
                    DataService<DAL.IncidentDocument> dsIncidentDocument = new DataService<DAL.IncidentDocument>(Data);
                    List<IncidentDocument> listDocs = dsIncidentDocument.FindAll(d => d.IncidentGUID == hidGUID.Value).ToList();
                    foreach (DAL.IncidentDocument doc in listDocs)
                    {
                        doc.IncidentGUID = null;
                        doc.IncidentID = incident.ID;
                        dsIncidentDocument.Update(doc, doc.ID);
                        IncidentDocument iDoc = new IncidentDocument()
                        {
                            IncidentID = incident.OriginalID,
                            IncidentDocumentFileData = doc.IncidentDocumentFileData,
                            IncidentDocumentFileType = doc.IncidentDocumentFileType,
                            IncidentDocumentName = doc.IncidentDocumentName
                        };
                        dsIncidentDocument.Add(iDoc);
                    }
                    hidGUID.Value = String.Empty;

                    icIncidentDocumentsControl.OriginalIncidentID = (int)incident.OriginalID;
                }
                else
                {
                    Incident incident = icIncidentControl.AssignValuesToIncident(dataService.Get(IncidentId));
                    incident = dataService.Update(incident, incident.ID);
                    icIncidentDonorControl.IncidentId = IncidentId;
                    icIncidentDonorControl.Save();
                    logger.Debug("Incident saved (IncNo: " + IncidentId.ToString());
                }
                Master.SetInfoLabel(StatusMessages.MsgSaveSuccess, SLIDSMaster.LabelState.Success);
                hidIncidentID.Value = IncidentId.ToString();

                // Disable all controls when the user isn't incident admin
                if (!Master.IsIncidentAdmin)
                {
                    EnableOrDisableControls(upIncidentCreate, false);
                }
            }
            else
            {
                Master.SetInfoLabel(StatusMessages.MsgSaveError, SLIDSMaster.LabelState.Error);
            }
        }
    }
}