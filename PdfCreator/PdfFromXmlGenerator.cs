using System;
using System.Collections.Generic;
using System.Data;
using System.IO;
using System.Xml;
using iTextSharp.text;
using iTextSharp.text.pdf;
using NLog;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: nydegger $
//  $Date: 2010-06-28 11:17:03 $
//  $Revision: 1.7 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// generates a pdf from a xml file.
    /// The data is provided in a XML file. This XML File contains the data AND the layout relevant properties.
    /// The structure of the XML file is based on the XML Schema 'FlowsheetGeneric.xsd' See inline schema description for more information 
    /// about the structure of the xml files
    /// </summary>
    public class PdfFromXmlGenerator
    {
        private static Logger logger = LogManager.GetCurrentClassLogger();

        /// <summary>
        /// constructor
        /// </summary>
        public PdfFromXmlGenerator()
        {
        }

        /// <summary>
        /// Generates the PDF document from a xml and the corresponding Data
        /// </summary>
        /// <param name="data">datatable with the Data to be filled</param>
        /// <param name="doc">xmldocument</param>
        public byte[] Generate(DataTable data, byte[] xmlTemplate)
        {

            // creating an xml document
            XmlDocument doc = new XmlDocument();
            // load the xml template into the xml document
            Stream s = new MemoryStream(xmlTemplate);

            doc.Load(s);

            SetXmlNodesValues(data, ref doc);

            return genDoc(doc);
        }

        private void SetXmlNodesValues(DataTable dt, ref XmlDocument doc)
        {
            // when a table is dynamic, it can have a certain amount of rows. The number of rows are not determined before runtime.
            // the rows (including all cells) must to be added dynamically during runtime, thus we distinct between dynamic tables and static tables.
            // so we need to find out first, if there exists any dynamic table in this document
            //oldXmlNode nodeDynamicTable = doc.SelectSingleNode("//Item[TableIsDynamic='true']");
            XmlNodeList dynamicTableNodes = doc.SelectNodes("//Item[TableIsDynamic='true']");

            foreach (XmlNode nodeDynamicTable in dynamicTableNodes)
            {

                if (nodeDynamicTable != null && dt.Rows.Count > 0)
                {
                    // at the first row we replace the values or add a value if there is no value specified
                    DataRow row = dt.Rows[0];
                    foreach (DataColumn col in dt.Columns)
                    {
                        try
                        {
                            // select from the dynamic table node the values which correspond to the fieldnames
                            XmlNode node = nodeDynamicTable.SelectSingleNode("DataCells/Data[FieldName='" + col.Caption + "']/Value");
                            if (node != null)
                            {
                                node.InnerText = row[col.Caption].ToString();
                            }
                        }
                        catch (Exception)
                        {
                            logger.Info("xmlnode " + col.Caption + " doesn't exist");
                        }
                    }

                    // for the further rows, we need to create xmlelements
                    if (dt.Rows.Count > 1)
                    {
                        for (int i = 1; i < dt.Rows.Count; i++)
                        {
                            DataRow dataRow = dt.Rows[i];
                            // add an xmlelement for each cell. the element should have the following form:
                            /*<DataCells>
                                <Data>
                                    <Value>1</Value>
                                    <FieldName>Count</FieldName>
                                </Data>
                            </DataCells> */
                            // TODO: just elements that belong to this table should appear there...

                            foreach (DataColumn col in dt.Columns)
                            {
                                try
                                {
                                    XmlNode partOfTable = nodeDynamicTable.SelectSingleNode("DataCells/Data[FieldName='" + col.Caption + "']/Value");
                                    if (partOfTable != null)
                                    {
                                        XmlElement elemDataCells = doc.CreateElement("DataCells");
                                        XmlElement elemData = doc.CreateElement("Data");

                                        XmlElement elemValue = doc.CreateElement("Value");
                                        elemValue.InnerText = dataRow[col.Caption].ToString();
                                        XmlElement elemFieldName = doc.CreateElement("FieldName");
                                        elemFieldName.InnerText = col.Caption;

                                        elemData.AppendChild(elemValue);
                                        elemData.AppendChild(elemFieldName);
                                        elemDataCells.AppendChild(elemData);
                                        // get the last datacells element
                                        XmlNode refChild = nodeDynamicTable.SelectSingleNode("DataCells[last()]");
                                        nodeDynamicTable.InsertAfter(elemDataCells, refChild);
                                    }
                                }
                                catch (Exception ex)
                                {
                                    logger.Info("xmlnode " + col.Caption + " doesn't exist: " + ex.Message);
                                }
                            }
                        }
                    }
                }
            }


            if (dt.Rows.Count > 0)
            {
                DataRow row = dt.Rows[0];
                foreach (DataColumn col in dt.Columns)
                {
                    try
                    {
                        // Replace the values in tables
                        XmlNode node = doc.SelectSingleNode("//Data[FieldName='" + col.Caption + "']/Value");
                        if (node != null)
                        {
                            node.InnerText = row[col.Caption].ToString();
                        }
                    }
                    catch (Exception)
                    {
                        logger.Debug("xmlnode " + col.Caption + " doesn't exist");
                    }
                    // replace the values in text elements
                    try
                    {
                        XmlNode node = doc.SelectSingleNode("//Item[Name='" + col.Caption + "']/Data/Value");
                        if (node != null)
                        {
                            node.InnerText = row[col.Caption].ToString();
                        }
                    }
                    catch (Exception)
                    {
                        logger.Debug("xmlnode " + col.Caption + " doesn't exist");
                    }
                }
            }
        }


        /// <summary>
        /// generates the flowsheet pdf
        /// </summary>
        /// <remarks>Probleme: Momentan wird über die verschiedenen Typen iteriert und diese sequentiell gezeichnet. z.b.
        /// zuerst Bilder, dann Elemente, Tabellen und Rechtecke. Die Rechtecke Doktor und der entsprechende Text
        /// sollen jedoch z.b. nur auf der letzten seite erscheinen, währenddem die Patientendaten z.b. auf jeder Seite
        /// erscheinen können. Somit können nicht zuerst alle Tabellen oder alle Elemente gezeichnet werden.
        /// </remarks>
        private byte[] genDoc(XmlDocument xmlDoc)
        {
            Document document = null;

            MemoryStream output = new MemoryStream();
            // creation of a document-object

            XmlNode defaultSettings = null;
            defaultSettings = xmlDoc.GetElementsByTagName("DefaultSettings")[0];

            XmlNodeList borderNodes = xmlDoc.GetElementsByTagName("Margin");
            if (borderNodes.Count > 0)
            {
                XmlNode borderNode = borderNodes[0];
                float top = XmlNodeUtil.GetElementValueAsFloat(borderNode, "Top");
                float bottom = XmlNodeUtil.GetElementValueAsFloat(borderNode, "Bottom");
                float left = XmlNodeUtil.GetElementValueAsFloat(borderNode, "Left");
                float right = XmlNodeUtil.GetElementValueAsFloat(borderNode, "Right");
                document = new Document(PageSize.A4, left, right, top, bottom);
            }
            else
            {
                document = new Document(PageSize.A4);
            }
            EmbedFonts(xmlDoc);

            try
            {
                // we create a writer that listens to the document and directs a PDF-stream to a stream
                // PdfWriter writer = PdfWriter.GetInstance(document, new FileStream("c:/temp/flowsheet_from_xml.pdf", FileMode.Create));
                PdfWriter writer = PdfWriter.GetInstance(document, output);

                //event handler
                // create add the event handler
                MyPageEvents events = new MyPageEvents(xmlDoc);
                writer.PageEvent = events;

                // we open the document
                document.Open();

                // we grab the ContentByte and will do some stuff with it later
                PdfContentByte cb = writer.DirectContent;

                // select all elements
                XmlNodeList xmlItems = xmlDoc.GetElementsByTagName("Item");

                // determine if a document can have multiple pages with possible dynamic tables.
                // if the content is dynamic and the created tables can have a dynamic size, the order of the elements is cruical.
                // therefore an order id on each element is mandatory!
                // if the document doesnt contain any dynamic tables, the order of the elements doesn't matter, so we can renounce to order the list first.
                // In this case, also an OrderID on each element is not necessary
                bool isMultiplePages = XmlNodeUtil.GetElementValueAsBool(defaultSettings, "IsMultiPagesDocument");
                // handling the different types different
                if (isMultiplePages)
                {
                    // sort the xmlItems depending on OrderID element. This is just necessary when table document can expand over one page
                    SortedList<int, XmlNode> sortedList = XmlNodeUtil.SortNodeList(xmlItems, "OrderID");
                    // now we have the elements in the correct order, lets print them one after
                    foreach (var item in sortedList)
                    {
                        XmlNode node = (XmlNode)item.Value;
                        PaintElements(node, cb, document, defaultSettings);
                    }
                }
                else
                {
                    foreach (XmlNode node in xmlItems)
                    {
                        PaintElements(node, cb, document, defaultSettings);
                    }
                }

                document.Close();
                output.Close();
                return output.ToArray();
            }
            catch (Exception ex)
            {
                logger.ErrorException("error creating pdf " + ex.Message, ex);
                return null;
            }
            finally
            {
                if (document.IsOpen())
                {
                    try
                    {
                        document.Close();
                    }
                    catch (Exception)
                    {
                    }
                }
                output.Close();
            }
        }

        /// <summary>
        /// not used at the moment
        /// tried to embed Insel Logo 08 font
        /// -> remember without the help of iTextSharps FontFactory
        /// </summary>
        /// <param name="xmlDoc"></param>
        private void EmbedFonts(XmlDocument xmlDoc)
        {
            XmlNodeList fontNodes = xmlDoc.GetElementsByTagName("EmbededFont");
            if (fontNodes.Count > 0)
            {
                string fontPath;
                string fontName;
                BaseFont customfont;
                foreach (XmlNode fontNode in fontNodes)
                {
                    fontPath = XmlNodeUtil.GetElementValue(fontNode, "ttsFilePath");
                    fontPath.Replace("~", System.Reflection.Assembly.GetExecutingAssembly().Location);
                    if (File.Exists(fontPath))
                    {
                        fontName = XmlNodeUtil.GetElementValue(fontNode, "Name");

                        customfont = BaseFont.CreateFont(fontPath, BaseFont.CP1252, BaseFont.EMBEDDED);
                        if (FontUtil.embededFonts.ContainsKey(fontName))
                        {
                            FontUtil.embededFonts[fontName] = customfont;
                        }
                        else
                        {
                            FontUtil.embededFonts.Add(fontName, customfont);
                        }
                    }
                    else
                    {
                        logger.Warn("FontFile {0} was not found", fontPath);
                    }
                }
            }
        }

        /// <summary>
        /// paints the different elements.
        /// Depending on the 'Type' of the element this methods call the different Painting methods
        /// </summary>
        /// <param name="cb">the canvas</param>
        /// <param name="node">the XmlNode containing the element</param>
        private void PaintElements(XmlNode node, PdfContentByte cb, Document document, XmlNode defaultSettings)
        {
            string elementType = XmlNodeUtil.GetElementValue(node, "Type");
            GenericElement element = ElementFactory.GetInstance(LayoutHelper.GetElementType(elementType), document, defaultSettings, node, cb);
            element.Paint();
        }

    }

    /// <summary>
    /// pdf creation events 
    /// </summary>
    class MyPageEvents : PdfPageEventHelper
    {
        private XmlDocument xmlDoc = null;

        /// <summary>
        /// ctor
        /// </summary>
        /// <param name="box">receptacle to eport</param>
        /// <param name="webpath">webpat we work in (to get logo image)</param>
        public MyPageEvents(XmlDocument xmlDoc)
        {
            this.xmlDoc = xmlDoc;
        }

        /// <summary>
        /// a new page started - drw header
        /// </summary>
        /// <param name="writer">pdf writer</param>
        /// <param name="document">pdf document</param>
        public override void OnStartPage(PdfWriter writer, Document document)
        {
            // select header elements
            XmlNodeList xmlHeaderItems = xmlDoc.GetElementsByTagName("HeaderItem");

            XmlNode defaultSettings = xmlDoc.GetElementsByTagName("DefaultSettings")[0];

            PdfContentByte cb = writer.DirectContent;

            foreach (XmlNode node in xmlHeaderItems)
            {
                PaintElements(node, cb, document, defaultSettings);
            }
        }

        public override void OnEndPage(PdfWriter writer, Document document)
        {
            base.OnEndPage(writer, document);

            // select footer elements
            XmlNodeList xmlHeaderItems = xmlDoc.GetElementsByTagName("FooterItem");

            XmlNode defaultSettings = xmlDoc.GetElementsByTagName("DefaultSettings")[0];

            PdfContentByte cb = writer.DirectContent;

            foreach (XmlNode node in xmlHeaderItems)
            {
                PaintElements(node, cb, document, defaultSettings);
            }
        }

        /// <summary>
        /// paints the different elements.
        /// Depending on the 'Type' of the element this methods call the different Painting methods
        /// </summary>
        /// <param name="cb">the canvas</param>
        /// <param name="node">the XmlNode containing the element</param>
        private void PaintElements(XmlNode node, PdfContentByte cb, Document document, XmlNode defaultSettings)
        {
            string elementType = XmlNodeUtil.GetElementValue(node, "Type");
            GenericElement element = ElementFactory.GetInstance(LayoutHelper.GetElementType(elementType), document, defaultSettings, node, cb);
            element.Paint();
        }
    }

}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: FlowSheetXmlGenerator.cs,v $
// Revision 1.7  2010-06-28 11:17:03  nydegger
// *** empty log message ***
//
// Revision 1.6  2010-06-25 12:55:32  nydegger
// *** empty log message ***
//
// Revision 1.5  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
// Revision 1.4  2010-06-06 22:25:04  nydegger
// *** empty log message ***
//
// Revision 1.3  2010-06-03 20:19:39  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-03 18:49:06  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-01 22:11:58  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-05-24 19:46:53  nydegger
// initial version
//
//
#endregion

