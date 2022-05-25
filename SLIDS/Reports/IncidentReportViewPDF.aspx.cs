using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using Pentag.SLIDS.DAL;
using iTextSharp.text;
using iTextSharp.text.pdf;
using iTextSharp.text.pdf.draw;
using System.Web.Security;
using Pentag.SLIDS.Common;

namespace Pentag.SLIDS.Reports
{
    public partial class IncidentReportViewPDF : ReportBasePage
    {

        protected void Page_Load(object sender, EventArgs e)
        {
            // get ID of procurement hospital ID
            if (Request.Params["Id"] == null || !Roles.IsUserInRole(Context.User.Identity.Name, Enums.UserRole.IncidentAdmin.ToString()))
            {
                return;
            }

            int incidentId = Convert.ToInt32(Request.Params["Id"]);
            Incident incident = Data.Incident.SingleOrDefault(inc => inc.ID == incidentId);
            if (incident == null)
            {
                return;
            }

            CreateAndOpenIncidentReport(incident);

        }

        private void CreateAndOpenIncidentReport(Incident incident)
        {
            BaseColor bColorBlue = new BaseColor(11, 65, 141);
            BaseColor bColorWhite = new BaseColor(255, 255, 255);
            BaseColor bColorGrey = new BaseColor(112, 111, 111);
            BaseFont tahoma = BaseFont.CreateFont(Server.MapPath("~/resources/tahoma.ttf"), BaseFont.CP1252, BaseFont.EMBEDDED);

            iTextSharp.text.Font fontTahoma = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.NORMAL);
            iTextSharp.text.Font fontTahomaBold = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldTitle = new iTextSharp.text.Font(tahoma, 12, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldSubTitle = new iTextSharp.text.Font(tahoma, 10, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldBlue = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD, bColorBlue);
            iTextSharp.text.Font fontTahomaBoldWhite = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD, bColorWhite);

            HttpContext.Current.Response.ContentType = "application/pdf";
            iTextSharp.text.Document doc = new iTextSharp.text.Document(PageSize.A4, 35, 35, 100, 80);

            //create an instance of the PdfWriter and write to the Response.OutputStream. This will stream it directly to the browser
            PdfWriter pdfWriter = PdfWriter.GetInstance(doc, HttpContext.Current.Response.OutputStream);

            doc.Open();
            doc.Add(GetSwisstransplantLogoImage());
            doc.Add(GetSwisstransplantAddressImage());
            doc.Add(GetTitle(fontTahomaBoldTitle, "Incident No. " + incident.IncidentNo.ToString()));
            doc.Add(GetTitle(fontTahomaBoldSubTitle, "Declarer"));
            doc.Add(GetField(fontTahomaBold, "User Name", fontTahoma, incident.CreatorUserName));
            doc.Add(GetField(fontTahomaBold, "E-Mail", fontTahoma, incident.CreatorEmail));
            doc.Add(GetField(fontTahomaBold, "Hospital", fontTahoma, incident.CreatorCenter));
            doc.Add(GetField(fontTahomaBold, "Phone", fontTahoma, incident.CreatorPhone));
            doc.Add(GetField(fontTahomaBold, "Creation Date", fontTahoma, incident.CreationDate.ToShortDateString() + " " + incident.CreationDate.ToShortTimeString()));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetTitle(fontTahomaBoldSubTitle, "Incident"));
            doc.Add(GetField(fontTahomaBold, "ST/RS/FO No", fontTahoma, incident.DonorNumber));
            if (incident.DateTimeOfIncident != null)
            {
                doc.Add(GetField(fontTahomaBold, "Date and time of event", fontTahoma, ((DateTime)incident.DateTimeOfIncident).ToShortDateString() + " " + ((DateTime)incident.DateTimeOfIncident).ToShortTimeString()));
            }
            doc.Add(GetField(fontTahomaBold, "Location", fontTahoma, incident.Location));
            doc.Add(GetField(fontTahomaBold, "Persons involved", fontTahoma, incident.PersonsInvolved));
            doc.Add(GetField(fontTahomaBold, "Description", fontTahoma, incident.IncidentDescription));
            doc.Add(GetField(fontTahomaBold, "Impact", fontTahoma, incident.Impact));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetTitle(fontTahomaBoldSubTitle, "Suggestions / Propositions"));
            doc.Add(GetText(fontTahoma, incident.Suggestions));
            doc.Close();

        }

        /// <summary>
        /// Creates Financial Report titel for document
        /// </summary>
        /// <returns>paragraph containing Title</returns>
        private Paragraph GetTitle(iTextSharp.text.Font font, string text)
        {
            Chunk chunk = new Chunk(text, font);
            chunk.SetCharacterSpacing(1);
            Paragraph paragraph = new Paragraph(chunk);
            paragraph.IndentationLeft = 24f;
            return paragraph;
        }

        /// <summary>
        /// Creates Financial Report titel for document
        /// </summary>
        /// <returns>paragraph containing Title</returns>
        private Paragraph GetField(iTextSharp.text.Font fontLabel, string label, iTextSharp.text.Font fontValue, string value)
        {
            Chunk tab = new Chunk(new VerticalPositionMark(), 100, true);

            Chunk chunkLabel = new Chunk(label, fontLabel);
            Chunk chunkValue = new Chunk(value, fontValue);
            Paragraph paragraph = new Paragraph();
            paragraph.Add(chunkLabel);
            if (value != null && value.Length > 150)
            {
                paragraph.Add("\n");
                paragraph.Add(chunkValue);
            }
            else
            {
                paragraph.Add(tab);
                paragraph.Add(chunkValue);
            }
            paragraph.IndentationLeft = 24f;
            return paragraph;
        }

        private Paragraph GetText(iTextSharp.text.Font font, string text)
        {
            Paragraph paragraph = new Paragraph();
            paragraph.Add(new Chunk(text, font));
            paragraph.IndentationLeft = 24f;
            return paragraph;
        }
    }
}