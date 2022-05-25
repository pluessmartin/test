using System;
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
//  $Date: 2010-06-28 11:56:37 $
//  $Revision: 1.2 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// This class represents a a rectangle element
    /// </summary>
    public class RectangleElement : GenericElement
    {

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">the default settings</param>
        /// <param name="node">the XmlNode containing the date used to paint this element</param>
        /// <param name="cb">the canvas where this element is painted</param>
        public RectangleElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb) : base(document, defaultSettings, node, cb)
        {
        }

        /// <summary>
        /// paints the rectangle on the canvas
        /// </summary>
        public override void Paint()
        {
            float posNode = XmlNodeUtil.GetElementValueAsFloat(node, "LineWidth");
            float llxNode = XmlNodeUtil.GetElementValueAsFloat(node, "LLX");
            float llyNode = XmlNodeUtil.GetElementValueAsFloat(node, "LLY");
            float urxNode = XmlNodeUtil.GetElementValueAsFloat(node, "URX");
            float uryNode = XmlNodeUtil.GetElementValueAsFloat(node, "URY");

            // set the linewidth
            cb.SetLineWidth((float)Convert.ToDouble(posNode));
            // finally paint the rectangle
            cb.Rectangle(llxNode, llyNode, urxNode, uryNode);
            cb.Stroke();
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: RectangleElement.cs,v $
// Revision 1.2  2010-06-28 11:56:37  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion

