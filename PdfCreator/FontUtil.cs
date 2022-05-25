using System.Collections.Generic;
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
//  $Date: 2010-06-25 12:55:32 $
//  $Revision: 1.3 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// this class provides several methods for creating fonts.
    /// </summary>
    public class FontUtil
    {
        public static Dictionary<string, BaseFont> embededFonts = new Dictionary<string, BaseFont>();

        /// <summary>
        /// Creates a font
        /// </summary>
        /// <param name="node">XmlNode containing all needed font properties</param>
        /// <param name="fontName">the font name</param>
        /// <param name="encoding">the encoding</param>
        /// <param name="style">the font style</param>
        /// <param name="size">the size of the font</param>
        /// <returns>a Font object</returns>
        public static Font CreateFont(XmlNode node, string fontName, string encoding, string style, int size)
        {
            Font font = null;
            // if the font name is empty, we'll take the default font
            if (fontName == null || fontName == "")
            {
                fontName = XmlNodeUtil.GetElementValue(node, "DefaultFont/Name");
            }
            if (encoding == null || encoding == "")
            {
                encoding = XmlNodeUtil.GetElementValue(node, "DefaultFont/Encoding");
            }
            if (style == null || style == "")
            {
                style = XmlNodeUtil.GetElementValue(node, "DefaultFont/Style");
                if (style == null || style == "")
                {
                    style = "NORMAL";
                }
            }

            if (embededFonts.ContainsKey(fontName))
            {
                font = new Font(embededFonts[fontName], (float)size, LayoutHelper.GetFontStyle(style));
            }
            else
            {
                font = FontFactory.GetFont(LayoutHelper.GetFontName(fontName), LayoutHelper.GetEncoding(encoding), size, LayoutHelper.GetFontStyle(style));
            }
            return font;
        }

        /// <summary>
        /// creates a BaseFont
        /// </summary>
        /// <param name="node">XmlNode containing all needed font properties</param>
        /// <param name="fontName">the font name</param>
        /// <param name="encoding">the encoding</param>
        /// <returns></returns>
        public static BaseFont CreateBaseFont(XmlNode node, string fontName, string encoding)
        {
            string style = null;
            BaseFont bf = null;
            // if the font name is empty, we'll take the default font
            if (fontName == null || fontName == "")
            {
                fontName = XmlNodeUtil.GetElementValue(node, "DefaultFont/Name");
            }
            if (encoding == null || encoding == "")
            {
                encoding = XmlNodeUtil.GetElementValue(node, "DefaultFont/Encoding");
            }
            if (style == null || style == "")
            {
                style = XmlNodeUtil.GetElementValue(node, "DefaultFont/Style");
            }
            // TODO: verify
            // if style is bold, we need to chooose another font as e.g. HELVETICA bold is the font HELVETICA_BOLD
            if (style == "BOLD")
            {
                fontName += "_" + style;
            }

            if (embededFonts.ContainsKey(fontName))
            {
                bf = embededFonts[fontName];
                //bf = new Font(embededFonts[fontName], (float)size, LayoutHelper.GetFontStyle(style));
            }
            else
            {
                try
                {
                    bf = BaseFont.CreateFont(LayoutHelper.GetFontName(fontName), LayoutHelper.GetEncoding(encoding), BaseFont.NOT_EMBEDDED);
                }
                catch
                {
                    //Create Default Font
                    fontName = XmlNodeUtil.GetElementValue(node, "DefaultFont/Name");
                    encoding = XmlNodeUtil.GetElementValue(node, "DefaultFont/Encoding");
                    style = XmlNodeUtil.GetElementValue(node, "DefaultFont/Style");

                    bf = BaseFont.CreateFont(LayoutHelper.GetFontName(fontName), LayoutHelper.GetEncoding(encoding), BaseFont.NOT_EMBEDDED);
                }
            }

            return bf;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: FontUtil.cs,v $
// Revision 1.3  2010-06-25 12:55:32  nydegger
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
