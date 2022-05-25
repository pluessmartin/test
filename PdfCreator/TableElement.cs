using System;
using iTextSharp.text.pdf;
using System.Xml;
using iTextSharp.text;
using NLog;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: kracher $
//  $Date: 2010-07-23 05:56:09 $
//  $Revision: 1.5 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// This class represents a table element
    /// </summary>
    public class TableElement : GenericElement
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">the default settings</param>
        /// <param name="node">the XmlNode containing the date used to paint this element</param>
        /// <param name="cb">the canvas where this element is painted</param>
        public TableElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb)
            : base(document, defaultSettings, node, cb)
        {
        }

        /// <summary>
        /// paints this element
        /// </summary>
        public override void Paint()
        {
            int numOfCols = XmlNodeUtil.GetElementValueAsInt(node, "NumberOfColumns");
            string headerLoc = XmlNodeUtil.GetElementValue(node, "HeaderCellLocation");

            // we create the table with the desired count of columns
            PdfPTable table = new PdfPTable(numOfCols);

            // setting the default cell properties
            table.DefaultCell.PaddingLeft = XmlNodeUtil.GetElementValueAsInt(node, "DefaultCell/Padding/PaddingLeft"); ;
            table.DefaultCell.PaddingTop = XmlNodeUtil.GetElementValueAsInt(node, "DefaultCell/Padding/PaddingTop");
            table.DefaultCell.PaddingBottom = XmlNodeUtil.GetElementValueAsInt(node, "DefaultCell/Padding/PaddingBottom");
            table.DefaultCell.Border = LayoutHelper.GetBorder(XmlNodeUtil.GetElementValue(node, "DefaultCell/Border"));

            table.TotalWidth = 100;

            float[] cellWidth = new float[numOfCols];
                                int w = 0;

            // the normal case, the header of a table is on top
            switch (LayoutHelper.GetTableHeaderLocation(headerLoc))
            {
                case (int)TableHeaderLocation.TOP:
                    // add the header cells
                    XmlNodeList nodeListCells = node.SelectNodes("HeaderCells");
                    try
                    {
                        if (nodeListCells != null && nodeListCells.Count > 0)
                        {
                            // iterate over all cell nodes
                            foreach (XmlNode nodeCell in nodeListCells)
                            {
                                CellElement cell = (CellElement)ElementFactory.GetInstance((int)ElementType.CELL, document, defaultSettings, nodeCell, cb);
                                cell.SetTable(table);
                                cell.SetCellType(CellType.HEADER);
                                cell.Paint();
                                float width = XmlNodeUtil.GetElementValueAsFloat(nodeCell, "Width");
                                if (width != 0)
                                {
                                    cellWidth[w] = width;
                                }
                                else
                                {
                                    cellWidth[w] = 1;
                                }
                                w++;
                            }
                        }
                        table.SetWidths(cellWidth);
                        table.HeaderRows = 1;
                    }
                    catch (Exception ex)
                    {
                        logger.ErrorException("error painting cells " + ex.Message, ex);
                    }

                    // adding the datacells
                    // when a table is dynamic, it can have a certain amount of rows. The number of rows are not determined before runtime.
                    // the rows (including all cells) must to be added dynamically during runtime, thus we distinct between dynamic tables and static tables

                    nodeListCells = node.SelectNodes("DataCells");
                    try
                    {
                        if (nodeListCells != null && nodeListCells.Count > 0)
                        {
                            // iterate over all cell nodes
                            foreach (XmlNode nodeCell in nodeListCells)
                            {
                                CellElement cell = (CellElement)ElementFactory.GetInstance((int)ElementType.CELL, document, defaultSettings, nodeCell, cb);
                                cell.SetTable(table);
                                cell.SetCellType(CellType.DATA);
                                cell.Paint();
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        logger.ErrorException("error painting cells " + ex.Message, ex);
                    }

                    // set the tables total width
                    table.TotalWidth = XmlNodeUtil.GetElementValueAsFloat(node, "TotalWidth");
                    float overpage = XmlNodeUtil.GetElementValueAsFloat(node, "OverPage");
                    bool isDynamic = XmlNodeUtil.GetElementValueAsBool(node, "TableIsDynamic");

                    // Einschub Seitenumbruch
                    if (isDynamic)
                    {
                        table.WidthPercentage = 100;
                        table.SpacingAfter = overpage;
                        document.Add(table);
                        
                        //Paragraph p = new Paragraph(overpage);
                        //document.Add(p);
                    }
                    else
                    {
                        WriteTableToCanvas(node, cb, table, 0, 0, 0);
                    }

                    break;

                case (int)TableHeaderLocation.LEFT:
                    // when the header is on the left side, the a headercell must to be painted followed by a datacell.
                    // it is necessary that there are the same amount of headercells and datacells
                    XmlNodeList nodeListHeaderCells = node.SelectNodes("HeaderCells");
                    XmlNodeList nodeListDataCells = node.SelectNodes("DataCells");
                    if (nodeListHeaderCells.Count != nodeListDataCells.Count)
                    {
                        string tableName = XmlNodeUtil.GetElementValue(node, "TableName");
                        string errMsg = "error painting table " + tableName;
                        errMsg += "number of headercells must be the same like number of datacells when HeaderLocation is set to LEFT or RIGHT";
                        errMsg += "Number of headercells=" + nodeListHeaderCells;
                        errMsg += "Number of headercells=" + nodeListDataCells;
                        logger.ErrorException(errMsg, new Exception());
                    }
                    else
                    {
                        table.SetWidths(DefineWidths());
                        // paint a headercell followed by a datacell
                        for (int i = 0; i < nodeListHeaderCells.Count; i++)
                        {
                            XmlNode header = nodeListHeaderCells[i];
                            XmlNode data = nodeListDataCells[i];
                            CellElement cellHeader = (CellElement)ElementFactory.GetInstance((int)ElementType.CELL, document, defaultSettings, header, cb);
                            cellHeader.SetTable(table);
                            cellHeader.SetCellType(CellType.HEADER);
                            CellElement cellData = (CellElement)ElementFactory.GetInstance((int)ElementType.CELL, document, defaultSettings, data, cb);
                            cellData.SetTable(table);
                            cellData.SetCellType(CellType.DATA);
                            cellHeader.Paint();
                            cellData.Paint();
                        }

                        WriteTableToCanvas(node, cb, table, 0, 0, 0);
                    }

                    break;

                default:
                    break;
                // ende einschub seitenumbruch
            }
        }

        private float[] DefineWidths()
        {

            float headerWidth = 0;
            float dataWidth = 0;
            headerWidth = XmlNodeUtil.GetElementValueAsFloat(node, "DefaultHeaderCell/Width");
            dataWidth = XmlNodeUtil.GetElementValueAsFloat(node, "DefaultDataCell/Width");
            headerWidth = headerWidth != 0 ? headerWidth : XmlNodeUtil.GetElementValueAsFloat(node, "DefaultCell/Width");
            dataWidth = dataWidth != 0 ? dataWidth : XmlNodeUtil.GetElementValueAsFloat(node, "DefaultCell/Width");
            headerWidth = headerWidth != 0 ? headerWidth : (float)1;
            dataWidth = dataWidth != 0 ? dataWidth : (float)1;

            return new float[2] {headerWidth, dataWidth};
        }

        /// <summary>
        /// writes the table to the canvas
        /// </summary>
        /// <param name="node">the xml node containing the positioning data</param>
        /// <param name="cb">the canvas</param>
        /// <param name="table">the table</param>
        /// <param name="breakIntAtRowStart">during runtime calculated value, where to start the row, replace the rowStart value defined in xml</param>
        /// <param name="breakIntAtRowEnd">during runtime calculated value, where to end the row, replace the rowEnd value defined in xml</param>
        /// <param name="yOffset">y offsets, used for correct pagebreak handling</param>
        private void WriteTableToCanvas(XmlNode node, PdfContentByte cb, PdfPTable table, int breakIntAtRowStart, int breakIntAtRowEnd, int yOffset)
        {
            // set the tables total width
            table.TotalWidth = XmlNodeUtil.GetElementValueAsFloat(node, "TotalWidth");
            // get the positioning data
            int rowStart;
            int rowEnd;
            if (breakIntAtRowStart != 0)
            {
                rowStart = breakIntAtRowStart;
            }
            else
            {
                rowStart = XmlNodeUtil.GetElementValueAsInt(node, "RowPosition/RowStart");
            }
            if (breakIntAtRowEnd != 0)
            {
                rowEnd = breakIntAtRowEnd;
            }
            else
            {
                rowEnd = XmlNodeUtil.GetElementValueAsInt(node, "RowPosition/RowEnd");
            }
            float rowXPos = XmlNodeUtil.GetElementValueAsFloat(node, "RowPosition/XPos");
            float rowYPos = XmlNodeUtil.GetElementValueAsFloat(node, "RowPosition/YPos");
            table.WriteSelectedRows(rowStart, rowEnd, rowXPos, rowYPos + yOffset, cb);
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: TableElement.cs,v $
// Revision 1.5  2010-07-23 05:56:09  kracher
// *** empty log message ***
//
// Revision 1.4  2010-06-25 12:55:32  nydegger
// *** empty log message ***
//
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
