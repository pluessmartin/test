using Pentag.SLIDS.DAL;
using System;
using System.Globalization;
using System.IO;
using System.Text;
using System.Web;
using System.Web.UI;

namespace Pentag.SLIDS
{
    /// <summary>
    /// 
    /// </summary>
    public partial class ViewDocument : Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            DocumentSLIDS doc = null;
            Entities entity = new Entities();

            // Incident Lexicon Document
            if (Request["incidentLexiconDocument"] != null && Request["incidentLexiconDocument"].Length > 0 && int.Parse(Request["incidentLexiconDocument"]) > 0)
            {
                DataService<IncidentLexiconDocument> dataService = new DataService<IncidentLexiconDocument>(entity);
                IncidentLexiconDocument ild = dataService.Get(int.Parse(Request["incidentLexiconDocument"]));

                doc = new DocumentSLIDS
                {
                    Name = ild.IncidentLexiconDocumentName,
                    ContentType = ild.IncidentLexiconDocumentFileType,
                    Content = ild.IncidentLexiconDocumentFileData
                };
            }
            else if (Request["incidentDocument"] != null && Request["incidentDocument"].Length > 0 && int.Parse(Request["incidentDocument"]) > 0)
            {
                DataService<IncidentDocument> dataService = new DataService<IncidentDocument>(entity);
                IncidentDocument ild = dataService.Get(int.Parse(Request["incidentDocument"]));

                doc = new DocumentSLIDS
                {
                    Name = ild.IncidentDocumentName,
                    ContentType = ild.IncidentDocumentFileType,
                    Content = ild.IncidentDocumentFileData
                };
            }


            if (doc != null)
            {

                // send file to user (download to browser)
                using (MemoryStream memStream = new MemoryStream())
                {
                    memStream.Write(doc.Content, 0, doc.Content.Length);
                    Response.Clear();
                    Response.ContentType = doc.ContentType;
                    Response.ContentEncoding = Encoding.Default;
                    Response.AppendHeader(
                        "Content-Disposition",
                        string.Format("attachement;filename=\"{0}\"", doc.Name));
                    Response.AppendHeader("Content-Length", doc.Content.Length.ToString(CultureInfo.InvariantCulture));
                    memStream.WriteTo(Response.OutputStream);
                    memStream.Flush();
                }

                HttpContext.Current.ApplicationInstance.CompleteRequest();
            }
        }
        private class DocumentSLIDS
        {
            public string Name { get; set; }
            public Byte[] Content { get; set; }
            public string ContentType { get; set; }
        }
    }
}