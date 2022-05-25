using iTextSharp.text;
using System.Xml;
using iTextSharp.text.pdf;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: nydegger $
//  $Date: 2010-06-22 07:11:04 $
//  $Revision: 1.3 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// This class represents a table cell element
    /// </summary>
    public class CellElement : GenericElement
    {
        private PdfPTable table;
        private CellType cellType;

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">the default settings</param>
        /// <param name="node">the XmlNode containing the date used to paint this element</param>
        /// <param name="cb">the canvas where this element is painted</param>
        public CellElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb) : base(document, defaultSettings, node, cb)
        {
        }

        /// <summary>
        /// paints this element
        /// </summary>
        public override void Paint()
        {
            TableCellUtil tableCellUtil = new TableCellUtil(defaultSettings, cellType);
            // create font based on cell properties, if these are missing, create font on default cell properties
            // if these are also missing, use the document default font properties
            // Font font7 = FontFactory.GetFont(FontFactory.HELVETICA, 7);
            string value = XmlNodeUtil.GetElementValue(node, "Data/Value");
            string fontName = tableCellUtil.GetCellFontName(node);
            int fontSize = tableCellUtil.GetCellFontSize(node);
            string fontStyle = tableCellUtil.GetCellFontStyle(node);
            string encoding = tableCellUtil.GetCellFontEncoding(node);
            Font font = FontUtil.CreateFont(node, fontName, encoding, fontStyle, fontSize);
            table.AddCell(new Phrase(value, font));
        }

        /// <summary>
        /// sets the table to which the cell should be added
        /// it's bad design, as all other generic elements don't need this, looking for a more beautiful solution when there is time
        /// </summary>
        /// <param name="table"></param>
        internal void SetTable(PdfPTable table)
        {
            this.table = table;
        }

        internal void SetCellType(CellType cellType)
        {
            this.cellType = cellType;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: CellElement.cs,v $
// Revision 1.3  2010-06-22 07:11:04  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-10 07:44:01  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion
