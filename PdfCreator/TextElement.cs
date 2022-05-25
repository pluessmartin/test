using iTextSharp.text.pdf;
using System.Xml;
using iTextSharp.text;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: nydegger $
//  $Date: 2010-06-10 07:44:01 $
//  $Revision: 1.2 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// represents a text element
    /// </summary>
    public class TextElement : GenericElement
    {

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="node">the XmlNode</param>
        /// <param name="cb">the canvas</param>
        public TextElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb)
            : base(document, defaultSettings, node, cb)
        {
        }


        /// <summary>
        /// paints the text element on the canvas
        /// </summary>
        public override void Paint()
        {
            // we tell the ContentByte we're ready to draw text
            cb.BeginText();

            string fontName = XmlNodeUtil.GetElementValue(node, "Font/Name");
            int fontSize = XmlNodeUtil.GetElementValueAsInt(node, "Font/Size");
            if (fontSize == 0)
            {
                fontSize = XmlNodeUtil.GetElementValueAsInt(defaultSettings, "Font/Size");
            }
            string encoding = XmlNodeUtil.GetElementValue(node, "Font/Encoding");

            // create the needed font
            BaseFont font = FontUtil.CreateBaseFont(defaultSettings, fontName, encoding);
            cb.SetFontAndSize(font, fontSize);

            // read the text
            string text = XmlNodeUtil.GetElementValue(node, "Data/Value");
            // read the positioning data
            float xPos = XmlNodeUtil.GetElementValueAsFloat(node, "Position/XPos");
            float yPos = XmlNodeUtil.GetElementValueAsFloat(node, "Position/YPos");
            // finally paint the text
            cb.ShowTextAligned(Element.ALIGN_LEFT, text, xPos, yPos, 0);
            // we tell the ContentByte we're tired to draw more text
            cb.EndText();
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: TextElement.cs,v $
// Revision 1.2  2010-06-10 07:44:01  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion
