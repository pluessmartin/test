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
    public partial class FinancialReportViewPDF : ReportBasePage
    {
        #region Constants
        private const string headerDonorNumber = "Donor Number";
        private const string headerCostType = "Cost Type";
        private const string headerTotalAmount = "Total Amount";
        private const string rowColumnTotal = "Total";
        #endregion

        #region Properties
        private DateTime RegisterDateFrom { get; set; }
        private DateTime RegisterDateTo { get; set; }

        private string donorNumberToCompare = String.Empty;
        #endregion

        protected void Page_Load(object sender, EventArgs e)
        {
            // get ID of procurement hospital ID
            if (Request.Params["hID"] == null
                || Request.Params["procDateFrom"] == null
                || Request.Params["procDateTo"] == null)
            {
                return;
            }

            int procurementHospitalID = Convert.ToInt32(Request.Params["hID"]);
            RegisterDateFrom = Convert.ToDateTime(Request.Params["procDateFrom"]);
            RegisterDateTo = Convert.ToDateTime(Request.Params["procDateTo"]);

            CreateAndOpenFinancialReport(procurementHospitalID);
        }

        #region Privates
        /// <summary>
        /// Creates document using iTextSharp
        /// </summary>
        /// <param name="procurementHospitalID">hospital id</param>
        private void CreateAndOpenFinancialReport(int procurementHospitalID)
        {
            BaseColor bColorBlue = new BaseColor(11, 65, 141);
            BaseColor bColorWhite = new BaseColor(255, 255, 255);
            BaseColor bColorGrey = new BaseColor(112, 111, 111);

            BaseFont tahoma = BaseFont.CreateFont(Server.MapPath("~/resources/tahoma.ttf"), BaseFont.CP1252, BaseFont.EMBEDDED);

            iTextSharp.text.Font fontTahoma = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.NORMAL);
            iTextSharp.text.Font fontTahomaBold = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldTitle = new iTextSharp.text.Font(tahoma, 12, iTextSharp.text.Font.BOLD);
            iTextSharp.text.Font fontTahomaBoldBlue = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD, bColorBlue);
            iTextSharp.text.Font fontTahomaBoldWhite = new iTextSharp.text.Font(tahoma, 8, iTextSharp.text.Font.BOLD, bColorWhite);

            Document doc = new Document(PageSize.A4, 35, 35, 100, 80);

            HttpContext.Current.Response.ContentType = "application/pdf";

            //create an instance of the PdfWriter and write to the Response.OutputStream. This will stream it directly to the browser
            PdfWriter pdfWriter = PdfWriter.GetInstance(doc, HttpContext.Current.Response.OutputStream);

            // Set PageEvent of PdfWrite instance to the instance our PageHeader class in order to get add page numbers in OnPageEnd event
            PageHeader tevent = new PageHeader();
            pdfWriter.PageEvent = tevent;

            doc.Open();

            // Add different elements to the document
            doc.Add(GetSwisstransplantLogoImage());
            doc.Add(GetSwisstransplantAddressImage());
            doc.Add(GetTitle(fontTahomaBoldTitle));
            doc.Add(GetPeriodAndHospital(procurementHospitalID, fontTahoma));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetDynamicTable(procurementHospitalID, fontTahomaBold, fontTahoma, fontTahomaBoldWhite));
            doc.Add(new Paragraph("\n"));
            doc.Add(GetSummary(procurementHospitalID, fontTahoma));

            doc.Close();
        }

        /// <summary>
        /// Creates Financial Report titel for document
        /// </summary>
        /// <returns>paragraph containing Title</returns>
        private Paragraph GetTitle(iTextSharp.text.Font font)
        {
            Chunk chunk = new Chunk("Financial Report", font);
            chunk.SetCharacterSpacing(1);
            Paragraph paragraph = new Paragraph(chunk);
            paragraph.IndentationLeft = 24f;
            return paragraph;
        }

        /// <summary>
        /// Creates paragraph with period and hospital information for document
        /// </summary>
        /// <param name="hospitalID">hospital ID</param>
        /// <param name="font">font</param>
        /// <returns>paragraph containing period and hospital</returns>
        private Paragraph GetPeriodAndHospital(int hospitalID, iTextSharp.text.Font font)
        {
            Hospital hospital = GetHospitalByID(hospitalID);
            if (hospital == null) throw new Exception("Hospital with ID " + hospitalID + " could not be found!");

            iTextSharp.text.Font lineBreakfont = FontFactory.GetFont(FontFactory.HELVETICA, 5, iTextSharp.text.Font.NORMAL);

            Phrase periodText = new Phrase("Period: " + RegisterDateFrom.ToShortDateString() + " - " + RegisterDateTo.ToShortDateString(), font);
            Phrase hospitalText = new Phrase("Hospital: " + hospital.Display, font);
            Phrase lineBreak = new Phrase("\n", lineBreakfont);

            Paragraph paragraph = new Paragraph
                {
                    periodText,
                    lineBreak,
                    hospitalText
                };
            paragraph.IndentationLeft = 24f;

            return paragraph;
        }

        /// <summary>
        /// Creates paragraph containing Total Summary at the end of the document for document
        /// </summary>
        /// <param name="hospitalID">hospital id</param>
        /// <param name="font">font</param>
        /// <returns>PdfPTable containing summary of totals</returns>
        private PdfPTable GetSummary(int hospitalID, iTextSharp.text.Font font)
        {
            Hospital hospital = GetHospitalByID(hospitalID);
            if (hospital == null) throw new Exception("Hospital with ID " + hospitalID + " could not be found!");

            Rectangle rect = PageSize.A4;
            float pageWidth = rect.Width;

            PdfPTable table = new PdfPTable(2)
            {
                TotalWidth = 550,
                WidthPercentage = 100
            };
            table.SetWidthPercentage(new[]
                                        {
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth
                                        },
                                     rect
                );

            table.DefaultCell.Border = Rectangle.NO_BORDER;
            table.DefaultCell.PaddingLeft = 4;
            table.DefaultCell.PaddingTop = 0;
            table.DefaultCell.PaddingBottom = 4;
            table.SpacingAfter = 10;

            PdfPCell totalICText = new PdfPCell(new Phrase("Total IC:", font));
            totalICText.Border = Rectangle.NO_BORDER;
            table.AddCell(totalICText);

            PdfPCell totalICAmount = new PdfPCell(new Phrase(GetTotalICAmount(hospital, RegisterDateFrom, RegisterDateTo, false), font));
            totalICAmount.Border = Rectangle.NO_BORDER;
            totalICAmount.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalICAmount.VerticalAlignment = Element.ALIGN_BOTTOM;
            table.AddCell(totalICAmount);

            PdfPCell totalORText = new PdfPCell(new Phrase("Total OR:", font));
            totalORText.Border = Rectangle.NO_BORDER;
            table.AddCell(totalORText);

            PdfPCell totalORAmount = new PdfPCell(new Phrase(GetTotalORAmount(hospital, RegisterDateFrom, RegisterDateTo, false), font));
            totalORAmount.Border = Rectangle.NO_BORDER;
            totalORAmount.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalORAmount.VerticalAlignment = Element.ALIGN_BOTTOM;
            table.AddCell(totalORAmount);

            PdfPCell totalText = new PdfPCell(new Phrase("Total:", font));
            totalText.Border = Rectangle.NO_BORDER;
            table.AddCell(totalText);

            PdfPCell totalICORAmount = new PdfPCell(new Phrase(GetTotalICORAmount(hospital, RegisterDateFrom, RegisterDateTo, false), font));
            totalICORAmount.Border = Rectangle.NO_BORDER;
            totalICORAmount.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalICORAmount.VerticalAlignment = Element.ALIGN_BOTTOM;
            table.AddCell(totalICORAmount);

            table.HorizontalAlignment = Element.ALIGN_RIGHT;

            return table;
        }

        #region DataTable Creation
        /// <summary>
        /// Creates PdfPTable with data of costs for hospital with id hospitalID
        /// </summary>
        /// <param name="hospitalID">hospital id</param>
        /// <param name="fontBold">bold font</param>
        /// <param name="font">normal font</param>
        /// <returns>PdfPTable containgn cost data</returns>
        private PdfPTable GetDynamicTable(int hospitalID, iTextSharp.text.Font fontBold, iTextSharp.text.Font font, iTextSharp.text.Font fontBoldWhite)
        {
            Rectangle rect = PageSize.A4;
            float pageWidth = rect.Width;

            PdfPTable table = new PdfPTable(9)
            {
                TotalWidth = 550,
                WidthPercentage = 100
            };
            table.SetWidthPercentage(new[]
                                        {
                                            (float) .12*pageWidth,
                                            (float) .20*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth,
                                            (float) .10*pageWidth
                                        },
                                     rect
                );
            table.DefaultCell.PaddingLeft = 4;
            table.DefaultCell.PaddingTop = 0;
            table.DefaultCell.PaddingBottom = 4;
            table.SpacingAfter = 10;

            // repeat header row on new page. The value 1 means that the first row in table is considered as header
            table.HeaderRows = 1;

            CreateHeaderRow(table, fontBoldWhite);

            GetAndCreateDataRows(table, hospitalID, fontBold, font);

            return table;
        }

        /// <summary>
        /// Creates header row for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="font">font</param>
        private void CreateHeaderRow(PdfPTable table, iTextSharp.text.Font font)
        {
            BaseColor bColorBlue = new BaseColor(11, 65, 141);

            PdfPCell donorNumberCell = new PdfPCell(new Phrase(headerDonorNumber, font));
            donorNumberCell.BackgroundColor = bColorBlue;
            donorNumberCell.BorderColorRight = BaseColor.LIGHT_GRAY;
            table.AddCell(donorNumberCell);

            PdfPCell costTypeCell = new PdfPCell(new Phrase(headerCostType, font));
            costTypeCell.BackgroundColor = bColorBlue;
            table.AddCell(costTypeCell);

            List<ItemGroup> organGroups = GetItemGroupsByType((int)ItemGroupType.Organ).ToList();
            foreach (ItemGroup itemGroup in organGroups.OrderBy(og => og.ID))
            {
                PdfPCell organGroupCell = new PdfPCell(new Phrase(itemGroup.Name, font));
                organGroupCell.BackgroundColor = bColorBlue;
                organGroupCell.PaddingBottom = 4f;
                table.AddCell(organGroupCell);
            }

            PdfPCell totalAmountCell = new PdfPCell(new Phrase(headerTotalAmount, font));
            totalAmountCell.BackgroundColor = bColorBlue;
            totalAmountCell.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalAmountCell.PaddingBottom = 4f;
            table.AddCell(totalAmountCell);
        }

        /// <summary>
        /// Creates data rows for PdfPTable by calling methods CreateNoCostRow, CreateCostRow and CreateTotalRow
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="hospitalID">hospital ID</param>
        /// <param name="fontBold">bold font</param>
        /// <param name="font">normal font</param>
        private void GetAndCreateDataRows(PdfPTable table, int hospitalID, iTextSharp.text.Font fontBold, iTextSharp.text.Font font)
        {
            List<Donor> donors = GetDonors()
                    .Where(d => d.ProcurementHospitalID == hospitalID
                                || d.ReferralHospitalID == hospitalID
                                || d.DetectionHospitalID == hospitalID)
                    .Where(d => !d.IsDeleted)
                    .Where(d => d.RegisterDate != null && d.RegisterDate >= RegisterDateFrom)
                    .Where(d => d.RegisterDate != null && d.RegisterDate <= RegisterDateTo)
                    .OrderBy(d => d.DonorNumber)
                    .ToList();

            foreach (Donor donor in donors)
            {
                List<SLIDS.DAL.Cost> costs = GetFinancialReportCosts(hospitalID, donor.ID).ToList();

                // Add donor to table even if there are no costs attributed
                if (costs.Count == 0) CreateNoCostRow(table, donor.DonorNumber, font);

                foreach (SLIDS.DAL.Cost cost in costs.OrderBy(c => c.CostTypeID))
                {
                    CreateCostRow(table, donor.DonorNumber, cost, font);
                }

                CreateTotalRow(table, costs, fontBold);
            }
        }

        /// <summary>
        /// Creates a data row with no costs for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="donorNumber">donor number</param>
        /// <param name="font">font</param>
        private void CreateNoCostRow(PdfPTable table, string donorNumber, iTextSharp.text.Font font)
        {
            PdfPCell donorNumberCell = new PdfPCell(new Phrase(donorNumber, font));
            donorNumberCell.PaddingBottom = 4f;
            donorNumberCell.BorderColorRight = BaseColor.LIGHT_GRAY;
            table.AddCell(donorNumberCell);

            PdfPCell costTypeCell = new PdfPCell(new Phrase(String.Empty, font));
            costTypeCell.PaddingBottom = 4f;
            table.AddCell(costTypeCell);

            List<ItemGroup> organGroups = GetItemGroupsByType((int)ItemGroupType.Organ).ToList();
            foreach (ItemGroup itemGroup in organGroups.OrderBy(og => og.ID))
            {
                PdfPCell organGroupCell = new PdfPCell(new Phrase(String.Empty, font));
                organGroupCell.PaddingBottom = 4f;
                table.AddCell(organGroupCell);
            }

            PdfPCell totalAmountCell = new PdfPCell(new Phrase(String.Empty, font));
            totalAmountCell.PaddingBottom = 4f;
            table.AddCell(totalAmountCell);
        }

        /// <summary>
        /// Creates data row with costs for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="donorNumber">donor number</param>
        /// <param name="cost">cost</param>
        /// <param name="font">font</param>
        private void CreateCostRow(PdfPTable table, string donorNumber, SLIDS.DAL.Cost cost, iTextSharp.text.Font font)
        {
            if (donorNumber == donorNumberToCompare) donorNumber = String.Empty;
            else donorNumberToCompare = donorNumber;

            PdfPCell donorNumberCell = new PdfPCell(new Phrase(donorNumber, font));
            donorNumberCell.PaddingBottom = 4f;
            donorNumberCell.BorderColorRight = BaseColor.LIGHT_GRAY;
            table.AddCell(donorNumberCell);

            PdfPCell costTypeCell = new PdfPCell(new Phrase(cost.CostType.Name, font));
            costTypeCell.PaddingBottom = 4f;
            table.AddCell(costTypeCell);

            List<ItemGroup> organGroups = GetItemGroupsByType((int)ItemGroupType.Organ).ToList();
            foreach (ItemGroup itemGroup in organGroups)
            {
                decimal? organCostSum = GetOrganCostsByCostID(cost.ID)
                    .Where(oc => oc.TransplantOrgan.Organ.ItemGroupID == itemGroup.ID)
                    .Where(oc => oc.Cost.CostType.Name == FlatChargesIC
                                 || oc.Cost.CostType.Name == FlatChargesOR)
                    .Sum(oc => oc.Amount);

                string organCostAmount = organCostSum != null
                                             ? Convert.ToDecimal(organCostSum).ToString("N0")
                                             : String.Empty;

                PdfPCell organGroupCell = new PdfPCell(new Phrase(organCostAmount, font));
                organGroupCell.HorizontalAlignment = Element.ALIGN_RIGHT;
                organGroupCell.VerticalAlignment = Element.ALIGN_BOTTOM;
                organGroupCell.PaddingBottom = 4f;
                table.AddCell(organGroupCell);
            }

            string costAmount = cost.Amount != null
                ? Convert.ToDecimal(cost.Amount).ToString("N0")
                : String.Empty;

            PdfPCell totalAmountCell = new PdfPCell(new Phrase(costAmount, font));
            totalAmountCell.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalAmountCell.VerticalAlignment = Element.ALIGN_BOTTOM;
            totalAmountCell.PaddingBottom = 4f;
            table.AddCell(totalAmountCell);
        }

        /// <summary>
        /// Creates total data row for PdfPTable
        /// </summary>
        /// <param name="table">PdfPTable</param>
        /// <param name="costs">list of cost</param>
        /// <param name="font">font</param>
        private void CreateTotalRow(PdfPTable table, List<SLIDS.DAL.Cost> costs, iTextSharp.text.Font font)
        {
            BaseColor gray = new BaseColor(207, 204, 204);
            PdfPCell totalCell = new PdfPCell(new Phrase(rowColumnTotal, font));
            totalCell.BackgroundColor = gray;
            totalCell.PaddingBottom = 4f;
            table.AddCell(totalCell);

            PdfPCell costTypeCell = new PdfPCell(new Phrase(String.Empty, font));
            costTypeCell.BackgroundColor = gray;
            costTypeCell.PaddingBottom = 4f;
            table.AddCell(costTypeCell);

            List<ItemGroup> organGroups = GetItemGroupsByType((int)ItemGroupType.Organ).ToList();
            foreach (ItemGroup itemGroup in organGroups.OrderBy(og => og.ID))
            {
                PdfPCell organGroupCell = new PdfPCell(new Phrase(String.Empty, font));
                organGroupCell.BackgroundColor = gray;
                organGroupCell.PaddingBottom = 4f;
                table.AddCell(organGroupCell);
            }

            string totalAmount = costs.Sum(c => c.Amount) != 0 ? Convert.ToDecimal(costs.Sum(c => c.Amount)).ToString("N0") : String.Empty;
            PdfPCell totalAmountCell = new PdfPCell(new Phrase(totalAmount, font));
            totalAmountCell.HorizontalAlignment = Element.ALIGN_RIGHT;
            totalAmountCell.VerticalAlignment = Element.ALIGN_BOTTOM;
            totalAmountCell.BackgroundColor = gray;
            totalAmountCell.PaddingBottom = 4f;
            table.AddCell(totalAmountCell);
        }
        #endregion

        #endregion

        #region Page Header Class for Page Number
        protected class PageHeader : PdfPageEventHelper
        {
            // The template with the total number of pages
            private PdfTemplate total;

            // The header text
            public string Header { get; set; }

            // Creates the PdfTemplate that will hold the total number of pages.
            public override void OnOpenDocument(PdfWriter writer, Document document)
            {
                total = writer.DirectContent.CreateTemplate(30, 16);
            }

            // Adds a header to every page
            public override void OnEndPage(PdfWriter writer, Document document)
            {
                PdfPTable table = new PdfPTable(3);
                try
                {
                    iTextSharp.text.Font font = FontFactory.GetFont(FontFactory.HELVETICA, 8, iTextSharp.text.Font.NORMAL);

                    table.SetWidths(new int[] { 24, 24, 2 });
                    table.TotalWidth = 527;
                    table.LockedWidth = true;
                    table.DefaultCell.FixedHeight = 20;
                    //table.DefaultCell.Border = Rectangle.BOTTOM_BORDER;
                    table.DefaultCell.Border = Rectangle.NO_BORDER;
                    table.AddCell(Header);
                    table.DefaultCell.HorizontalAlignment = Element.ALIGN_RIGHT;
                    PdfPCell currentpageNumberCell = new PdfPCell(new Phrase(string.Format("Page {0} of", writer.PageNumber), font));
                    currentpageNumberCell.Border = Rectangle.NO_BORDER;
                    currentpageNumberCell.HorizontalAlignment = Element.ALIGN_RIGHT;
                    currentpageNumberCell.VerticalAlignment = Element.ALIGN_BOTTOM;
                    table.AddCell(currentpageNumberCell);
                    PdfPCell totalPageNumberCell = new PdfPCell(Image.GetInstance(total));
                    //cell.Border = Rectangle.BOTTOM_BORDER;
                    totalPageNumberCell.Border = Rectangle.NO_BORDER;
                    totalPageNumberCell.HorizontalAlignment = Element.ALIGN_RIGHT;
                    totalPageNumberCell.VerticalAlignment = Element.ALIGN_BOTTOM;
                    table.AddCell(totalPageNumberCell);
                    table.WriteSelectedRows(0, -1, 34, 34, writer.DirectContent);
                }
                catch (DocumentException de)
                {
                    throw new Exception(de.ToString());
                }
            }

            // Fills out the total number of pages before the document is closed.
            public override void OnCloseDocument(PdfWriter writer, Document document)
            {
                iTextSharp.text.Font font = FontFactory.GetFont(FontFactory.HELVETICA, 8, iTextSharp.text.Font.NORMAL);

                ColumnText.ShowTextAligned(
                    total,
                    Element.ALIGN_LEFT,
                    // NewPage() already called when closing the document; subtract 1
                    new Phrase((writer.PageNumber).ToString(CultureInfo.InvariantCulture), font),
                    2, 2, 0);
            }
        }
        #endregion
    }
}