using System;
using System.Xml;
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
//  $Date: 2010-06-22 07:11:04 $
//  $Revision: 1.5 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// this class provides several table cell methods.
    /// Given a XmlNode it reads the fontname, the fontsize, the font style and the encoding.
    /// </summary>
    public class TableCellUtil
    {

        private XmlNode defaultSettings = null;
        private CellType cellType;

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="defaultSettingsNode">an XmlNode with several default settings about encoding, fonts etc.</param>
        public TableCellUtil(XmlNode defaultSettingsNode, CellType cellType)
        {
            this.defaultSettings = defaultSettingsNode;
            this.cellType = cellType;
        }

        private static Logger logger = LogManager.GetCurrentClassLogger();
        /// <summary>
        /// returns the font that should be used to write the text. Provides several backup functions in case
        /// there is no font declared for example in one cell. 
        /// </summary>
        /// <param name="node">the node containing the </param>
        /// <returns></returns>
        public string GetCellFontName(XmlNode node)
        {
            string fontName = XmlNodeUtil.GetElementValue(node, "Font/Name");
            if (fontName == null || fontName == "")
            {
                // get font name different if is a header or a datacell
                if (cellType == CellType.HEADER)
                {
                    fontName = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultHeaderCell/Font/Name");
                }
                else
                {
                    fontName = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultDataCell/Font/Name");
                }
                if (fontName == null || fontName == "")
                {

                    // get font props of parent node
                    fontName = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultCell/Font/Name");
                    if (fontName == null || fontName == "")
                    {
                        // get default font props
                        fontName = XmlNodeUtil.GetElementValue(defaultSettings, "DefaultFont/Name");
                    }
                }
            }
            return fontName;
        }


        /// <summary>
        /// returns the size of the font that should be used to write the text.
        /// Provides several backup functions in case
        /// there is no font size declared for example in one cell. 
        /// </summary>
        /// <param name="node">the xml node containing the text</param>
        /// <returns>the size of the font</returns>
        public int GetCellFontSize(XmlNode node)
        {
            int fontSize = XmlNodeUtil.GetElementValueAsInt(node, "Font/Size");
            if (fontSize == 0)
            {
                // get font name different if is a header or a datacell
                if (cellType == CellType.HEADER)
                {
                    fontSize = XmlNodeUtil.GetElementValueAsInt(node.ParentNode, "DefaultHeaderCell/Font/Size");
                }
                else
                {
                    fontSize = XmlNodeUtil.GetElementValueAsInt(node.ParentNode, "DefaultDataCell/Font/Size");
                }
                if (fontSize == 0)
                {
                    // get font props of parent node
                    fontSize = XmlNodeUtil.GetElementValueAsInt(node.ParentNode, "DefaultCell/Font/Size");
                    if (fontSize == 0)
                    {
                        // get default font props
                        fontSize = XmlNodeUtil.GetElementValueAsInt(defaultSettings, "DefaultFont/Size");
                    }
                }
            }
            if (fontSize == 0)
            {
                fontSize = 8;
                logger.ErrorException("ERROR; font-size to small: " + fontSize + ", replaced with size 8", new Exception());
            }
            return fontSize;
        }

        /// <summary>
        /// returns the style attributes for a tablecell
        /// </summary>
        /// <param name="node">the XmlNode containing a datatable cell</param>
        /// <returns>the style of a font</returns>
        public string GetCellFontStyle(XmlNode node)
        {
            string fontStyle = XmlNodeUtil.GetElementValue(node, "Font/Style");
            if (fontStyle == null || fontStyle == "")
            {
                if (cellType == CellType.HEADER)
                {
                    fontStyle = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultHeaderCell/Font/Style");
                }
                else
                {
                    fontStyle = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultDataCell/Font/Style");
                }
                if (fontStyle == null || fontStyle == "")
                {
                    // get font props of parent node
                    fontStyle = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultCell/Font/Style");
                    if (fontStyle == null || fontStyle == "")
                    {
                        // get default font props
                        fontStyle = XmlNodeUtil.GetElementValue(defaultSettings, "DefaultFont/Style");
                    }
                }
            }
            return fontStyle;
        }

        /// <summary>
        /// returns the encoding of a tablecell.
        /// Provides several backup functions in case
        /// there is no encoding declared for a certain cell. 
        /// </summary>
        /// <param name="node"></param>
        /// <returns></returns>
        public string GetCellFontEncoding(XmlNode node)
        {
            string encoding = XmlNodeUtil.GetElementValue(node, "Font/Encoding");
            if (encoding == null || encoding == "")
            {
                if (cellType == CellType.HEADER)
                {
                    encoding = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultHeaderCell/Font/Encoding");
                }
                else
                {
                    encoding = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultDataCell/Font/Encoding");
                }
                if (encoding == null || encoding == "")
                {
                    // get font props of parent node
                    encoding = XmlNodeUtil.GetElementValue(node.ParentNode, "DefaultCell/Font/Encoding");
                    if (encoding == null || encoding == "")
                    {
                        // get default font props
                        encoding = XmlNodeUtil.GetElementValue(defaultSettings, "DefaultFont/Encoding");
                    }
                }
            }
            return encoding;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: TableCellUtil.cs,v $
// Revision 1.5  2010-06-22 07:11:04  nydegger
// *** empty log message ***
//
// Revision 1.4  2010-06-10 07:46:04  nydegger
// *** empty log message ***
//
// Revision 1.3  2010-06-10 07:44:01  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-06 22:25:04  nydegger
// *** empty log message ***
//
//
//
#endregion
