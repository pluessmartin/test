using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Web;
using Pentag.SLIDS.DAL;
using iTextSharp.text;
using iTextSharp.text.pdf;

namespace Pentag.SLIDS.Reports
{
    public partial class ReminderLetterViewPDF : ReportBasePage
    {
        #region Properties
        private DateTime RegisterDateFrom { get; set; }
        private DateTime RegisterDateTo { get; set; }
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            // if params were not provided, return
            if (Request.Params["hID"] == null
                || Request.Params["lang"] == null
                || Request.Params["procDateFrom"] == null
                || Request.Params["procDateTo"] == null)
            {
                return;
            }

            // get procurement Hospital ID
            int procurementHospitalID = Convert.ToInt32(Request.Params["hID"]);

            // set default language "de" if langauge was not provided
            String lang = String.IsNullOrEmpty(Request.Params["lang"]) ? "de" : Request.Params["lang"];

            // get period which will be used as filter
            RegisterDateFrom = Convert.ToDateTime(Request.Params["procDateFrom"]);
            RegisterDateTo = Convert.ToDateTime(Request.Params["procDateTo"]);

            // create and open reminder letter
            CreateAndOpenReminderLetter(procurementHospitalID, lang);
        }

        #region Privates
        /// <summary>
        /// Creates document using iTextSharp
        /// </summary>
        /// <param name="procurementHospitalID">procurement hospital ID</param>
        /// <param name="lang">language</param>
        private void CreateAndOpenReminderLetter(int procurementHospitalID, string lang)
        {
            ReminderLetter reminderLetter = GetReminderLetterByLanguageShort(lang);
            if (reminderLetter == null) throw new Exception("Reminder letter with language " + lang + "not found!");

            BaseColor bColorBlue = new BaseColor(11, 65, 141);
            BaseColor bColorWhite = new BaseColor(255, 255, 255);
            BaseColor bColorGrey = new BaseColor(112, 111, 111);

            BaseFont tahoma = BaseFont.CreateFont(Server.MapPath("~/resources/tahoma.ttf"), BaseFont.CP1252, BaseFont.EMBEDDED);

            iTextSharp.text.Font fontTahoma = new iTextSharp.text.Font(tahoma, 9, iTextSharp.text.Font.NORMAL);
            iTextSharp.text.Font fontTahomaBold = new iTextSharp.text.Font(tahoma, 9, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldTitle = new iTextSharp.text.Font(tahoma, 14, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaSmall = new iTextSharp.text.Font(tahoma, 7, iTextSharp.text.Font.NORMAL);
            iTextSharp.text.Font fontTahomaBoldBlue = new iTextSharp.text.Font(tahoma, 9, iTextSharp.text.Font.BOLD, bColorBlue);
            iTextSharp.text.Font fontTahomaBoldWhite = new iTextSharp.text.Font(tahoma, 9, iTextSharp.text.Font.BOLD, bColorWhite);

            Document doc = new Document(PageSize.A4, 61, 47, 140, 80);

            HttpContext.Current.Response.ContentType = "application/pdf";

            PdfWriter.GetInstance(doc, HttpContext.Current.Response.OutputStream);
            doc.Open();

            doc.Add(GetSwisstransplantLogoImage());
            doc.Add(GetSwisstransplantAddressImage());
            doc.Add(new Paragraph("\n"));
            doc.Add(GetAddressBlock(procurementHospitalID, fontTahoma));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetLocationAndDate(reminderLetter, fontTahomaSmall));
            doc.Add(new Paragraph("\n"));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetStartBlock(reminderLetter, fontTahoma));
            doc.Add(new Paragraph("\n"));

            doc.Add(GetDynamicTable(procurementHospitalID, reminderLetter, fontTahomaBold, fontTahoma, fontTahomaBoldWhite));
            doc.Add(GetEndingBlock(reminderLetter, fontTahoma));

            doc.Close();
        }

        /// <summary>
        /// Creates paragraph with address block for document
        /// </summary>
        /// <param name="procurementHospitalID">hospital ID</param>
        /// <param name="font">font</param>
        /// <returns>paragraph containing address block</returns>
        private Paragraph GetAddressBlock(int procurementHospitalID, iTextSharp.text.Font font)
        {
            Hospital hospital = GetHospitalByID(procurementHospitalID);
            if (hospital == null) throw new Exception("hospital with id " + procurementHospitalID.ToString(CultureInfo.InvariantCulture) + " could not be found");

            Address address = GetAddressByID(hospital.AccountingAddressID ?? hospital.AddressID);
            if (address == null) throw new Exception(string.Format("address with id {0}could not be found!", hospital.AccountingAddressID.ToString()));

            Phrase contactPerson = new Phrase(address.ContactPerson, font);
            Phrase hospitalName = new Phrase(hospital.Name, font);
            Phrase address1 = new Phrase(address.Address1, font);
            Phrase address2 = new Phrase(address.Address2, font);
            Phrase address3 = new Phrase(address.Address3, font);
            Phrase address4 = new Phrase(address.Address4, font);
            Phrase zipCity = new Phrase(address.CountryISO != "CH" && !string.IsNullOrEmpty(address.CountryISO)
                                            ? address.CountryISO + "-" + address.Zip + " " + address.City
                                            : address.Zip + " " + address.City, font);

            Paragraph paragraph = new Paragraph
                {
                    hospitalName, 
                    "\n", 
                    contactPerson,
                    "\n",
                    address1, 
                    "\n"
                };
            if (!address2.IsEmpty())
            {
                paragraph.Add(address2);
                paragraph.Add("\n");
            }
            if (!address3.IsEmpty())
            {
                paragraph.Add(address3);
                paragraph.Add("\n");
            }
            if (!address3.IsEmpty())
            {
                paragraph.Add(address3);
                paragraph.Add("\n");
            }
            if (!address3.IsEmpty())
            {
                paragraph.Add(address4);
                paragraph.Add("\n");
            }
            paragraph.Add(zipCity);

            return paragraph;
        }

        /// <summary>
        /// Creates paragraph with location and date
        /// </summary>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="font">font</param>
        /// <returns>paragraph containing location and date</returns>
        private Paragraph GetLocationAndDate(ReminderLetter reminderLetter, iTextSharp.text.Font font)
        {
            Phrase locationAndDate = new Phrase(reminderLetter.Location + DateTime.Today.ToShortDateString(), font);

            Paragraph paragraph = new Paragraph
                {
                    locationAndDate
                };

            return paragraph;
        }

        /// <summary>
        /// Creates paragraph with start block for document
        /// </summary>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="font">font</param>
        /// <returns>paragraph containing start block</returns>
        private Paragraph GetStartBlock(ReminderLetter reminderLetter, iTextSharp.text.Font font)
        {
            Phrase salutation = new Phrase(reminderLetter.SalutationText, font);
            Phrase textblockA = new Phrase(reminderLetter.TextBlockA, font);

            Paragraph paragraph = new Paragraph
                {
                    salutation, 
                    "\n", 
                    "\n", 
                    textblockA
                };

            return paragraph;
        }

        /// <summary>
        /// Creates paragraph with end block for document
        /// </summary>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="font">font</param>
        /// <returns>paragraph containing end block</returns>
        private Paragraph GetEndingBlock(ReminderLetter reminderLetter, iTextSharp.text.Font font)
        {
            Phrase textblockB = new Phrase(reminderLetter.TextBlockB, font);
            Phrase greetings = new Phrase(reminderLetter.GreetingText, font);
            Phrase signature = new Phrase(reminderLetter.SignatureText, font);
            Phrase lineBreak = new Phrase("\n", font);

            Paragraph paragraph = new Paragraph
                {
                    textblockB, 
                    lineBreak, 
                    lineBreak, 
                    lineBreak, 
                    greetings, 
                    lineBreak, 
                    lineBreak, 
                    lineBreak, 
                    signature
                };
            paragraph.KeepTogether = true;

            return paragraph;
        }

        #region DataTable Creation
        /// <summary>
        /// Creates PdfPTable with data of costs which are not yet billed from hospital with id hospitalID
        /// </summary>
        /// <param name="hospitalID">hospital id</param>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="fontBold">bold font</param>
        /// <param name="font">normal font</param>
        /// <returns>PdfPTable containgn cost data</returns>
        private PdfPTable GetDynamicTable(int hospitalID, ReminderLetter reminderLetter, iTextSharp.text.Font fontBold, iTextSharp.text.Font font, iTextSharp.text.Font fontBoldWhite)
        {
            Rectangle rect = PageSize.A4;
            float pageWidth = rect.Width;

            PdfPTable table = new PdfPTable(3)
                {
                    TotalWidth = 500,
                    WidthPercentage = 100
                };
            table.SetWidthPercentage(new[]
                {
                    (float) .15*pageWidth,
                    (float) .70*pageWidth,
                    (float) .15*pageWidth
                },
                                     rect
                );
            table.DefaultCell.PaddingLeft = 4;
            table.DefaultCell.PaddingTop = 0;
            table.DefaultCell.PaddingBottom = 4;
            table.SpacingAfter = 10;
            table.HeaderRows = 1;

            CreateHeaderRow(table, reminderLetter, fontBoldWhite);

            GetDonorsAndCreateDataRows(table, reminderLetter, hospitalID, fontBold, font);

            return table;
        }

        /// <summary>
        /// Gets Donors and calls methods CreateHeaderRow, CreateCostRow and CreateTotalRow which creates rows for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="hospitalID">hospital ID</param>
        /// <param name="fontBold">font bold</param>
        /// <param name="font">font normal</param>
        private void GetDonorsAndCreateDataRows(PdfPTable table, ReminderLetter reminderLetter, int hospitalID, iTextSharp.text.Font fontBold, iTextSharp.text.Font font)
        {
            List<Donor> donors = GetDonors()
                .Where(d => (d.ProcurementHospitalID == hospitalID
                             || d.ReferralHospitalID == hospitalID
                             || d.DetectionHospitalID == hospitalID
                            )
                            || (d.Cost.Any(c => !c.IsDeleted
                                                && c.KreditorHospitalID == hospitalID
                                                && string.IsNullOrEmpty(c.InvoiceNo)))
                )
                .Where(d => d.RegisterDate != null && d.RegisterDate >= RegisterDateFrom)
                .Where(d => d.RegisterDate != null && d.RegisterDate <= RegisterDateTo)
                .Where(d => d.Hospital1.isActive)
                .OrderBy(d => d.DonorNumber)
                .ToList();

            decimal totalCosts = 0;

            foreach (Donor donor in donors)
            {
                List<SLIDS.DAL.Cost> costs = GetCostsOfKreditorHospitalByDonorID(hospitalID, donor.ID)
                                                .Where(c => string.IsNullOrEmpty(c.InvoiceNo))
                                                .ToList();

                // Add donor to table even if there are no costs attributed
                if (costs.Count == 0) continue;

                foreach (SLIDS.DAL.Cost cost in costs.OrderBy(c => c.CostTypeID))
                {
                    CreateCostRow(table, donor, cost, font);
                }

                // add total costs of donor to totalCost overall
                totalCosts += Convert.ToDecimal(costs.Sum(c => c.Amount));
            }

            // create total row
            CreateTotalRow(table, reminderLetter, totalCosts, fontBold);
        }

        /// <summary>
        /// Creates header row for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="font">font</param>
        private static void CreateHeaderRow(PdfPTable table, ReminderLetter reminderLetter, iTextSharp.text.Font font)
        {
            BaseColor bColorBlue = new BaseColor(11, 65, 141);

            PdfPCell donorNumberCell = new PdfPCell(new Phrase(reminderLetter.HeaderDonorNumber, font));
            donorNumberCell.BackgroundColor = bColorBlue;
            donorNumberCell.PaddingBottom = 4f;

            PdfPCell costTypeCell = new PdfPCell(new Phrase(reminderLetter.HeaderCostType, font));
            costTypeCell.BackgroundColor = bColorBlue;
            costTypeCell.PaddingBottom = 4f;

            PdfPCell costsCell = new PdfPCell(new Phrase(reminderLetter.HeaderCosts, font));
            costsCell.BackgroundColor = bColorBlue;
            costsCell.PaddingBottom = 4f;
            costsCell.HorizontalAlignment = Element.ALIGN_RIGHT;

            table.AddCell(donorNumberCell);
            table.AddCell(costTypeCell);
            table.AddCell(costsCell);
        }

        /// <summary>
        /// Creates data row with costs for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="donor">Donor</param>
        /// <param name="cost">Cost</param>
        /// <param name="font">font</param>
        private static void CreateCostRow(PdfPTable table, Donor donor, SLIDS.DAL.Cost cost, iTextSharp.text.Font font)
        {
            PdfPCell donorNumberCell = new PdfPCell(new Phrase(donor.DonorNumber, font));
            PdfPCell costTypeCell = new PdfPCell(new Phrase(cost.CostType.Name, font));
            PdfPCell costsCell = new PdfPCell(new Phrase(cost.Amount != null ? Convert.ToDecimal(cost.Amount).ToString("N2") : String.Empty, font));
            costsCell.HorizontalAlignment = 2;
            costsCell.VerticalAlignment = 6;
            costsCell.PaddingBottom = 4f;
            costTypeCell.PaddingBottom = 4f;
            donorNumberCell.PaddingBottom = 4f;

            table.AddCell(donorNumberCell);
            table.AddCell(costTypeCell);
            table.AddCell(costsCell);
        }

        /// <summary>
        /// Creates total data row for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="reminderLetter">reminder letter</param>
        /// <param name="totalCosts">total costs</param>
        /// <param name="font">font</param>
        private static void CreateTotalRow(PdfPTable table, ReminderLetter reminderLetter, decimal totalCosts, iTextSharp.text.Font font)
        {
            BaseColor gray = new BaseColor(207, 204, 204);

            PdfPCell totalTitleCell = new PdfPCell(new Phrase(reminderLetter.FooterTotal, font));
            totalTitleCell.BackgroundColor = gray;
            totalTitleCell.DisableBorderSide(Rectangle.RIGHT_BORDER);

            PdfPCell emptyCell = new PdfPCell(new Phrase("", font));
            emptyCell.BackgroundColor = gray;
            emptyCell.DisableBorderSide(Rectangle.LEFT_BORDER);
            emptyCell.DisableBorderSide(Rectangle.RIGHT_BORDER);

            PdfPCell totalAmoutCell = new PdfPCell(new Phrase(Convert.ToDecimal(totalCosts).ToString("N2"), font));
            totalAmoutCell.BackgroundColor = gray;
            totalAmoutCell.HorizontalAlignment = 2;
            totalAmoutCell.VerticalAlignment = 6;
            totalAmoutCell.DisableBorderSide(Rectangle.LEFT_BORDER);

            totalTitleCell.PaddingBottom = 4f;
            emptyCell.PaddingBottom = 4f;
            totalAmoutCell.PaddingBottom = 4f;

            table.AddCell(totalTitleCell);
            table.AddCell(emptyCell);
            table.AddCell(totalAmoutCell);
        }
        #endregion

        #endregion
    }
}