
#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: nydegger $
//  $Date: 2010-06-28 11:39:34 $
//  $Revision: 1.5 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    using System;
    using System.ComponentModel;

    /// <summary>
    /// utility for different font and type related helper methods.
    /// Basically used to map the strings describing font attributs, e.g Font.BOLD, Element.ALIGN_LEFT to the according int constant values.
    /// </summary>
    public class LayoutHelper
        {
            /// <summary>
            /// returns the int value of the fontstyle as it appears in the xml
            /// </summary>
            /// <param name="fontStyle">the style of the font declared in the xml</param>
            /// <returns>the value of the font style</returns>
            public static int GetFontStyle(string fontStyle)
            {
                return (int)(FontStyle)Enum.Parse(typeof(FontStyle), fontStyle);
            }

            /// <summary>
            /// returns the int value of the element type as it appears in the xml
            /// </summary>
            /// <param name="elementType">the type of element to be created, e.g. IMAGE, TABLE etc.</param>
            /// <returns>the value of the element type</returns>
            public static int GetElementType(string elementType)
            {
                return (int)(ElementType)Enum.Parse(typeof(ElementType), elementType);
            }

            /// <summary>
            /// returns the int value of the alignment property
            /// </summary>
            /// <param name="alignment">the image alignment property as string declared in the xml</param>
            /// <returns>the value of the image alignment property</returns>
            public static int GetImageAlignment(string alignment)
            {
                return (int)(ImageAlignment)Enum.Parse(typeof(ImageAlignment), alignment);
            }

            /// <summary>
            /// returns the string value of the font name
            /// </summary>
            /// <param name="fontName">the fontname declared in the xml</param>
            /// <returns>the fontname used as const in the iTextsharp classes</returns>
            public static string GetFontName(string fontName)
            {
                FontName fn = (FontName)Enum.Parse(typeof(FontName), fontName);
                return GetEnumDescription(fn);
            }

            /// <summary>
            /// returns the string value of the encoding
            /// </summary>
            /// <param name="encoding">the encoding declared in the xml</param>
            /// <returns>the encoding used as const in the itextsharp classes</returns>
            public static string GetEncoding(string encoding)
            {
                Encoding enc = (Encoding)Enum.Parse(typeof(Encoding), encoding);
                return GetEnumDescription(enc);
            }

            /// <summary>
            /// returns the int value of the border property
            /// </summary>
            /// <param name="border">the border property as string declared in the xml</param>
            /// <returns>the value of the border property</returns>
            public static int GetBorder(string border)
            {
                return (int)(Border)Enum.Parse(typeof(Border), border);
            }

            /// <summary>
            /// returns the int value of the tableheader location property
            /// </summary>
            /// <param name="border">the tableheader location property as string declared in the xml</param>
            /// <returns>the value of the tableheader location property</returns>
            public static int GetTableHeaderLocation(string loc)
            {
                return (int)(TableHeaderLocation)Enum.Parse(typeof(TableHeaderLocation), loc);
            }

            /// <summary>
            /// gets the description of an enum value
            /// </summary>
            /// <param name="value">an enum</param>
            /// <returns>description of an enum value as string</returns>
            public static string GetEnumDescription(Enum value)
            {
                var fi = value.GetType().GetField(value.ToString());
                var attributes = (DescriptionAttribute[])fi.GetCustomAttributes(typeof(DescriptionAttribute), false);
                if (attributes.Length > 0)
                    return attributes[0].Description;
                else
                    return "";
            }
        }
}

#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: LayoutHelper.cs,v $
// Revision 1.5  2010-06-28 11:39:34  nydegger
// *** empty log message ***
//
// Revision 1.4  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
// Revision 1.3  2010-06-07 13:53:30  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-06 22:25:04  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-03 18:49:07  nydegger
// *** empty log message ***
//
//
#endregion