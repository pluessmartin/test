using System;
using System.Xml;
using iTextSharp.text;
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
//  $Date: 2010-06-28 11:47:33 $
//  $Revision: 1.3 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// this class represents an image element
    /// </summary>
    public class ImageElement : GenericElement
    {

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">the default settings</param>
        /// <param name="node">the XmlNode containing the date used to paint this element</param>
        /// <param name="cb">the canvas where this element is painted</param>
        public ImageElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb)
            : base(document, defaultSettings, node, cb)
        {
        }

        /// <summary>
        /// adds the image to the document
        /// </summary>
        public override void Paint()
        {
            string imgName = XmlNodeUtil.GetElementValue(node, "Name");
            string imgData = XmlNodeUtil.GetElementValue(node, "ImageData");
            string alignment = XmlNodeUtil.GetElementValue(node, "Alignment");
            float scalePercent = XmlNodeUtil.GetElementValueAsFloat(node, "ScalePercent");
            float xPos = XmlNodeUtil.GetElementValueAsFloat(node, "Position/XPos");
            float yPos = XmlNodeUtil.GetElementValueAsFloat(node, "Position/YPos");
            byte[] img = Convert.FromBase64String(imgData);
            Image jpg = Image.GetInstance(img);
            jpg.ScalePercent(scalePercent);
            jpg.Alignment = LayoutHelper.GetImageAlignment(alignment);
            jpg.SetAbsolutePosition(xPos, yPos);
            document.Add(jpg);
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: ImageElement.cs,v $
// Revision 1.3  2010-06-28 11:47:33  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-28 11:17:03  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion
