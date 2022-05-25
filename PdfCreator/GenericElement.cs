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
//  $Date: 2010-06-08 17:03:09 $
//  $Revision: 1.1 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{

    /// <summary>
    /// abstract class for element types. a concrete type should be subclassed from this abstract class.
    /// element types can be for example TextElement, TableElement, ImageElement and so on 
    /// </summary>
    public abstract class GenericElement
    {
        /// <summary>
        /// the document
        /// </summary>
        protected Document document;
        /// <summary>
        /// the default settings containing informations about document size, default fonts etc.
        /// </summary>
        protected XmlNode defaultSettings;
        /// <summary>
        /// the XmlNode containing the data used to paint this element 
        /// </summary>
        protected XmlNode node;
        /// <summary>
        /// the canvas where the element is painted
        /// </summary>
        protected PdfContentByte cb;

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="document">the document</param>
        /// <param name="defaultSettings">the default settings</param>
        /// <param name="node">the XmlNode containing the date used to paint this element</param>
        /// <param name="cb">the canvas where this element is painted</param>
        public GenericElement(Document document, XmlNode defaultSettings, XmlNode node, PdfContentByte cb)
        {
            this.document = document;
            this.defaultSettings = defaultSettings;
            this.node = node;
            this.cb = cb;
        }

        /// <summary>
        /// paints the element, what a surprise ;-)
        /// </summary>
        public abstract void Paint();
    }
}

#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: GenericElement.cs,v $
// Revision 1.1  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
//
//
#endregion
