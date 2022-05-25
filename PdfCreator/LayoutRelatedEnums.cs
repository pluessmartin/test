using System.ComponentModel;

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
//  $Revision: 1.6 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// enum containing all valid fontnames
    /// </summary>
    public enum FontName
    {
        [Description("Courier")]
        COURIER,
        [Description("Courier-Bold")]
        COURIER_BOLD,
        [Description("Courier-BoldOblique")]
        COURIER_BOLDOBLIQUE,
        [Description("Courier-Oblique")]
        COURIER_OBLIQUE,
        [Description("Helvetica")]
        HELVETICA,
        [Description("Helvetica-Bold")]
        HELVETICA_BOLD,
        [Description("Helvetica-BoldOblique")]
        HELVETICA_BOLDOBLIQUE,
        [Description("Symbol")]
        SYMBOL,
        [Description("Times")]
        TIMES,
        [Description("Times-Bold")]
        TIMES_BOLD,
        [Description("Times-BoldItalic")]
        TIMES_BOLDITALIC,
        [Description("Times-Italic")]
        TIMES_ITALIC,
        [Description("Times-Roman")]
        TIMES_ROMAN,
        [Description("ZapfDingbats")]
        ZAPFDINGBATS,
    }

    /// <summary>
    /// enum containing all valid alignment properties for an element
    /// </summary>
    public enum ElementAlignment
    {
        ALIGN_BASELINE = 7,
        ALIGN_BOTTOM = 6,
        ALIGN_CENTER = 1,
        ALIGN_JUSTIFIED = 3,
        ALIGN_JUSTIFIED_ALL = 8,
        ALIGN_LEFT = 0,
        ALIGN_MIDDLE = 5,
        ALIGN_RIGHT = 2,
        ALIGN_TOP = 4,
        ALIGN_UNDEFINED = -1,
    }

    /// <summary>
    /// enum containing all valid image alignment options
    /// </summary>
    public enum ImageAlignment
    {
        LEFT_ALIGN = 0,
        MIDDLE_ALIGN = 1,
        RIGHT_ALIGN = 2,
        TEXTWRAP = 4,
        UNDERLYING = 8,
    }

    /// <summary>
    /// enum containing all valid font style properties
    /// </summary>
    public enum FontStyle
    {
        BOLD = 1,
        BOLDITALIC = 3,
        DEFAULTSIZE = 12,
        ITALIC = 2,
        NORMAL = 0,
        STRIKETHRU = 8,
        UNDEFINED = -1,
        UNDERLINE = 4,
    }

    /// <summary>
    /// enum containing all possible element types
    /// </summary>
    public enum ElementType
    {
        TABLE = 1,
        IMAGE = 2,
        TEXT = 3,
        RECTANGLE = 4,
        CELL = 5,
    }

    /// <summary>
    /// enum containing all possible encodings
    /// </summary>
    public enum Encoding
    {
        [Description("Cp1252")]
        CP1252,
        [Description("Cp1250")]
        CP1250,
        [Description("Cp1257")]
        CP1257,
        [Description("Cp1252")]
        WINANSI,
    }

    /// <summary>
    /// enum containing all valid border options for a table cell
    /// </summary>
    public enum Border
    {
        TOP_BORDER = 1,
        BOTTOM_BORDER = 2,
        LEFT_BORDER = 4,
        RIGHT_BORDER = 8,
        NO_BORDER = 0,
        BOX = TOP_BORDER + BOTTOM_BORDER + LEFT_BORDER + RIGHT_BORDER,
    }

    /// <summary>
    /// enum containing all location options for a table header
    /// </summary>
    public enum TableHeaderLocation
    {
        TOP = 1,
        LEFT = 2,
        RIGHT = 3,
    }

    /// <summary>
    /// enum containing all cell types
    /// </summary>
    public enum CellType
    {
        HEADER = 1,
        DATA = 2,
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: LayoutRelatedEnums.cs,v $
// Revision 1.6  2010-06-25 12:55:32  nydegger
// *** empty log message ***
//
// Revision 1.5  2010-06-10 07:44:01  nydegger
// *** empty log message ***
//
// Revision 1.4  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
// Revision 1.3  2010-06-07 13:53:30  nydegger
// *** empty log message ***
//
//
//
//
#endregion