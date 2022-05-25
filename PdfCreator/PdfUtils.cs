using System.Collections.Generic;
using iTextSharp.text.pdf;
using System.Collections;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: nydegger $
//  $Date: 2010-06-07 13:53:30 $
//  $Revision: 1.5 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// Utility class for pdf related stuff
    /// </summary>
    public class PdfUtils
    {
        /// <summary>
        /// returns the list of all form field names in a given template
        /// </summary>
        /// <param name="pdfTemplate">the pdf template as stream</param>
        /// <returns>a list with all form field names in the pdf template</returns>
        public static IList ListFieldNames(byte[] pdfTemplate)
        {
            PdfReader pdfReader = new PdfReader(pdfTemplate);
            IList lst = new ArrayList();

            foreach (KeyValuePair<string, AcroFields.Item> de in pdfReader.AcroFields.Fields)
            {
                lst.Add(de.Key);
            }
            pdfReader.Close();
            return lst;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: PdfUtils.cs,v $
// Revision 1.5  2010-06-07 13:53:30  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-06-06 22:25:04  nydegger
// *** empty log message ***
//
//
//
#endregion
