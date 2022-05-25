using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS.Controls
{
    public partial class ucIncidentDocuments : System.Web.UI.UserControl
    {
        /// <summary>
        /// Incident row identification
        /// </summary>
        public int IncidentID
        {
            get { return int.Parse(hidIncidentID.Value); }
            set
            {
                hidIncidentID.Value = value.ToString();
            }
        }

        /// <summary>
        /// Incident row identification
        /// </summary>
        public int OriginalIncidentID
        {
            get { return int.Parse(hidOriginalIncidentID.Value); }
            set
            {
                hidOriginalIncidentID.Value = value.ToString();
            }
        }

        public string GUID
        {
            get { return hidGUID.Value; }
            set
            {
                hidGUID.Value = value.ToString();
            }
        }

        protected void Page_Load(object sender, EventArgs e)
        {
        }

        /// <summary>
        /// Returns BasePage
        /// </summary>
        protected BasePage BasePage
        {
            get { return new BasePage(); }
        }

        /// <summary>
        /// Enable/Disable control
        /// </summary>
        public bool Enabled
        {
            get { return btnUpload.Visible; }
            set
            {
                fuDocument.Style.Clear();
                if (!value)
                {
                    fuDocument.Style.Add("display", "none");
                }
                btnUpload.Visible = value;
            }
        }

        #region GridView
        /// <summary>
        /// Bind grid views
        /// </summary>
        public void DataBind()
        {
            gvDocuments.DataBind();
            upDocuments.Update();
        }

        /// <summary>
        /// Get rows for document grid view
        /// </summary>
        public IQueryable<Pentag.SLIDS.DAL.IncidentDocument> gvDocuments_GetData()
        {
            if (IncidentID != 0)
            {
                return new DataService<IncidentDocument>(BasePage.Data).GetAll().Where(d => d.IncidentID == IncidentID).OrderByDescending(d => d.ID);
            }
            else
            {
                return new DataService<IncidentDocument>(BasePage.Data).GetAll().Where(d => d.IncidentGUID == GUID).OrderByDescending(d => d.ID);
            }
        }

        /// <summary>
        /// Setting row data bound (calls BasePage row data binder)
        /// </summary>
        protected void gvDocuments_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            BasePage.gridView_RowDataBound(sender, e);

            if (e.Row.Cells.Count > 2)
            {
                e.Row.Cells[2].Visible = Enabled;
            }
        }

        /// <summary>
        /// On deleting an document
        /// </summary>
        public void gvDocuments_DeleteItem(int id)
        {
            DataService<IncidentDocument> ds = new DataService<IncidentDocument>(BasePage.Data);
            ds.Delete(ds.Get(id));
        }
        #endregion

        /// <summary>
        /// Uploads a file to the server
        /// </summary>
        protected void btnUpload_Click(object sender, EventArgs e)
        {
            if (fuDocument.HasFile || (fuDocument.PostedFiles.Count > 0 && fuDocument.PostedFiles[0].FileName != String.Empty))
            {
                // Read the file and convert it to Byte Array
                string filePath = fuDocument.PostedFile.FileName;
                string filename = Path.GetFileName(filePath);
                string ext = Path.GetExtension(filename);
                string contenttype = String.Empty;

                //Set the contenttype based on File Extension
                contenttype = BasePage.GetContentType(ext);
                if (contenttype != String.Empty)
                {
                    // Streamreader for saving stream in bytearray
                    Stream fs = fuDocument.PostedFile.InputStream;
                    BinaryReader br = new BinaryReader(fs);
                    Byte[] bytes = br.ReadBytes((Int32)fs.Length);

                    // Create new record
                    IncidentDocument id = new IncidentDocument()
                    {
                        IncidentDocumentName = filename,
                        IncidentDocumentFileType = contenttype,
                        IncidentDocumentFileData = bytes
                    };
                    if (IncidentID != 0)
                    {
                        id.IncidentID = IncidentID;
                    }
                    else
                    {
                        id.IncidentGUID = GUID;
                    }

                    (new DataService<IncidentDocument>(BasePage.Data)).Add(id);

                    if (OriginalIncidentID != 0)
                    {
                        IncidentDocument iDoc = new IncidentDocument()
                        {
                            IncidentDocumentName = filename,
                            IncidentDocumentFileType = contenttype,
                            IncidentDocumentFileData = bytes,
                            IncidentID = OriginalIncidentID
                        };
                        (new DataService<IncidentDocument>(BasePage.Data)).Add(iDoc);
                    }

                    // Bind grid views
                    gvDocuments.DataBind();
                    upDocuments.Update();
                }
                else
                {
                    KeyValuePair<SLIDSMaster.LabelState, string> error = new KeyValuePair<SLIDSMaster.LabelState, string>(SLIDSMaster.LabelState.Info, "Unsupported datatype");
                    ErrorMsg(error, new EventArgs());
                }
            }
            else
            {
                KeyValuePair<SLIDSMaster.LabelState, string> error = new KeyValuePair<SLIDSMaster.LabelState, string>(SLIDSMaster.LabelState.Error, "You have not specified a file.");
                ErrorMsg(error, new EventArgs());
            }
        }

        /// <summary>
        /// Is thrown on Event messages
        /// </summary>
        public event EventHandler ErrorMsg;

    }
}