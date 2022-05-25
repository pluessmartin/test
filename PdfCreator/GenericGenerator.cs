using System;
using System.Collections.Generic;
using System.IO;
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
//  $Date: 2010-06-07 13:53:30 $
//  $Revision: 1.4 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// interface for the pdf generation
    /// </summary>
    public abstract class GenericGenerator
    {
        /// <summary>
        /// generate a pdf from a template and fills in the form fields with the given values
        /// </summary>
        /// <param name="pdfTemplate">the pdf template</param>
        /// <param name="dict">the dictionary containing the mapping fieldname-value</param>
        /// <returns>generated document as Byte Array</returns>
        public abstract byte[] Generate(byte[] pdfTemplate, Dictionary<string, string> dict);

        /// <summary>
        /// generate a multipage pdf from a template and fills in the form fields with the given values
        /// </summary>
        /// <param name="pdfTemplate">the pdf template</param>
        /// <param name="listOfDict">the dictionarys containing the mapping fieldname-value</param>
        /// <returns>generated document as Byte Array</returns>
        public byte[] Generate(byte[] pdfTemplate, List<Dictionary<string, string>> listOfDict)
        {
            List<byte[]> pages = new List<byte[]>();
            foreach (Dictionary<string, string> dict in listOfDict)
            {
                pages.Add(Generate(pdfTemplate, dict));
            }
            return MergeFiles(pages);

        }

        /// <summary>
        /// Merge pdf files.
        /// </summary>
        /// <param name="sourceFiles">PDF files being merged.</param>
        /// <returns></returns>
        public static byte[] MergeFiles(List<byte[]> sourceFiles)
        {
            Document document = new Document();
            MemoryStream output = new MemoryStream();

            try
            {
                // Initialize pdf writer
                PdfWriter writer = PdfWriter.GetInstance(document, output);

                // Open document to write
                document.Open();
                PdfContentByte content = writer.DirectContent;

                // Iterate through all pdf documents
                for (int fileCounter = 0; fileCounter < sourceFiles.Count; fileCounter++)
                {
                    // Create pdf reader
                    PdfReader reader = new PdfReader(sourceFiles[fileCounter]);
                    int numberOfPages = reader.NumberOfPages;

                    // Iterate through all pages
                    for (int currentPageIndex = 1; currentPageIndex <=
                                       numberOfPages; currentPageIndex++)
                    {
                        // Determine page size for the current page
                        document.SetPageSize(
                           reader.GetPageSizeWithRotation(currentPageIndex));

                        // Create page
                        document.NewPage();
                        PdfImportedPage importedPage =
                          writer.GetImportedPage(reader, currentPageIndex);


                        // Determine page orientation
                        int pageOrientation = reader.GetPageRotation(currentPageIndex);
                        if ((pageOrientation == 90) || (pageOrientation == 270))
                        {
                            content.AddTemplate(importedPage, 0, -1f, 1f, 0, 0,
                               reader.GetPageSizeWithRotation(currentPageIndex).Height);
                        }
                        else
                        {
                            content.AddTemplate(importedPage, 1f, 0, 0, 1f, 0, 0);
                        }
                    }
                }
            }
            catch (Exception exception)
            {
                throw new Exception("There has an unexpected exception" +
                      " occured during the pdf merging process.", exception);
            }
            finally
            {
                document.Close();
            }
            return output.GetBuffer();
        }


    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: GenericGenerator.cs,v $
// Revision 1.4  2010-06-07 13:53:30  nydegger
// *** empty log message ***
//
//
//
//
#endregion