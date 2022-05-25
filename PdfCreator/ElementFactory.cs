using System;
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
//  $Date: 2010-06-08 17:03:09 $
//  $Revision: 1.1 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// Factory for creating the different element types
    /// </summary>
    public class ElementFactory
    {

        /// <summary>
        /// creates an element type
        /// </summary>
        /// <param name="type">the element type to be created</param>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">default settings of the document</param>
        /// <param name="node">the XmlNode containing </param>
        /// <param name="cb">the canvas where the element will be painted</param>
        /// <returns></returns>
        public static GenericElement GetInstance(int type, Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb)
        {
            GenericElement ge = null;
            switch (type)
            {
                case (int)ElementType.IMAGE:
                    ge = new ImageElement(document, defaultSettings, node, cb);
                    break;
                case (int)ElementType.RECTANGLE:
                    ge = new RectangleElement(document, defaultSettings, node, cb);
                    break;
                case (int)ElementType.TEXT:
                    ge = new TextElement(document, defaultSettings,node, cb);
                    break;
                case (int)ElementType.TABLE:
                    ge = new TableElement(document, defaultSettings, node, cb);
                    break;
                case (int)ElementType.CELL:
                    ge = new CellElement(document, defaultSettings, node, cb);
                    break;
                default:
                    {
                        string msg = "element type " + type + " is not supported \n allowed element types are:";
                        foreach (string nameEnum in Enum.GetNames(typeof(ElementType)))
                        {
                            msg += "\n" + nameEnum + " : " + (int)Enum.Parse(typeof(ElementType), nameEnum);
                        }
                        Exception ex = new Exception(msg);
                        throw ex;
                    }
            }
            return ge;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: ElementFactory.cs,v $
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion
