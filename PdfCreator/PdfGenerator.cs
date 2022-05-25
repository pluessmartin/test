using System;
using System.IO;
using System.Reflection;
using System.Collections.Generic;
using NLog;
using iTextSharp.text.pdf;
using iTextSharp.text;

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// generates a pdf and fill in the acroform fields
    /// Works for pdf templates generated with acrobat Pro using acroforms.
    /// Can't be used for xfa forms generated with LiveCycle Designer
    /// </summary>
    public class PdfGenerator : GenericGenerator
    {
        /// <summary>
        /// the logger
        /// </summary>
        public static Logger logger = LogManager.GetCurrentClassLogger();

        private bool flattenForm { get; set; }

        private delegate void ProcessFieldDelegate(KeyValuePair<string, string> item, AcroFields af, PdfStamper ps, AcroFields.FieldPosition fieldPosition, PdfContentByte cb);

        /// <summary>
        /// default constructor
        /// </summary>
        public PdfGenerator()
        {
            this.flattenForm = true;
        }

        /// <summary>
        /// constructor
        /// </summary>
        /// <param name="flattenForm">true if the form fields should be flattened e.g. cannot be edited anymore, false if pdf will not be flattened</param>
        public PdfGenerator(bool flattenForm)
        {
            this.flattenForm = flattenForm;
        }

        /// <summary>
        /// generates a pdf as bytestream from a given pdf template
        /// </summary>
        /// <param name="template">the pdf template with the formfields</param>
        /// <param name="dict">dictionary containing the form field names and the corresponding values</param>
        /// <returns>a byte array containing the generated pdf</returns>
        public override byte[] Generate(byte[] template, Dictionary<string, string> dict)
        {
            PdfReader reader = new PdfReader(template);

            BaseFont STF_Helvetica = BaseFont.CreateFont(BaseFont.HELVETICA, BaseFont.CP1252, BaseFont.NOT_EMBEDDED);
            Font fontNormal = new Font(STF_Helvetica, 12, Font.NORMAL);

            MemoryStream output = new MemoryStream();
            PdfStamper ps = new PdfStamper(reader, output);

            // retrieve properties of PDF form w/AcroFields object
            AcroFields af = ps.AcroFields;
            af.AddSubstitutionFont(STF_Helvetica);

            // iterate over dictionary and fill out the form fields
            foreach (KeyValuePair<string, string> item in dict)
            {
                //Special fields for Barcode
                if (item.Key.StartsWith("BC") && !String.IsNullOrEmpty(item.Value) && item.Key.Contains("{") && item.Key.Contains("}"))
                {
                    ProcessField(item, af, ps, FillBarcodeField);
                }
                else if (item.Key.StartsWith("IMG") && !String.IsNullOrEmpty(item.Value))
                {
                    ProcessField(item, af, ps, FillImageField);
                }
                else
                {
                    ProcessField(item, af, ps, FillTextField);                  
                }
            }

            // formflattening makes the pdf file readonly 
            ps.FormFlattening = this.flattenForm;
            ps.FreeTextFlattening = true;

            // close readers and streams
            ps.Close();
            reader.Close();
            output.Close();
            return output.ToArray();
        }

        private void FillTextField(KeyValuePair<string, string> item, AcroFields af, PdfStamper ps, AcroFields.FieldPosition fieldPosition, PdfContentByte pdfContentByte)
        {
            af.SetField(item.Key, item.Value);
        }

        private void FillImageField(KeyValuePair<string, string> item, AcroFields af, PdfStamper ps, AcroFields.FieldPosition fieldPosition, PdfContentByte pdfContentByte)
        {
            ps.AcroFields.RemoveField(item.Key);

            // item value is the image encoded in a base64 string
            Image image = Image.GetInstance(Convert.FromBase64String(item.Value));            
            image.ScaleToFit(fieldPosition.position.Width, fieldPosition.position.Height);
            // vertical middle the image if the scaled height is less than the original field height
            image.SetAbsolutePosition(fieldPosition.position.Left, fieldPosition.position.Bottom + (fieldPosition.position.Height - image.ScaledHeight) / 2);
            pdfContentByte.AddImage(image);
        }

        /// <summary>
        /// add a barcode to a field
        /// </summary>
        /// <param name="item">Key Value Pair with field name and Data</param>
        /// <param name="af">pdfs AcroFields</param>
        /// <param name="pdfContentByte">cb of PDF to write to</param>
        private void FillBarcodeField(KeyValuePair<string, string> item, AcroFields af, PdfStamper ps, AcroFields.FieldPosition fieldPosition, PdfContentByte pdfContentByte)
        {
            Image image = null;

            int start = item.Key.IndexOf("{") + 1;
            int end = item.Key.IndexOf("}");

            if (start >= 0 && end >= 0)
            {
                string barcodeType = item.Key.Substring(start, end - start);

                switch (barcodeType)
                {

                    case "BarcodeDatamatrix":
                        BarcodeDatamatrix dmbc = new BarcodeDatamatrix();
                        dmbc.Generate(item.Value);
                        image = Image.GetInstance(dmbc.CreateImage());
                        break;
                    default: // any 'normal' (not 2D) Barcode"
                        /*BarcodePostnet
                        BarcodeEANSUPP
                        BarcodeInter25
                        BarcodeEAN
                        BarcodeCodabar
                        Barcode39
                        Barcode128*/

                        Barcode bc = GetCorrectBarcode(barcodeType);

                        bc.Code = item.Value;
                        bc.StartStopText = false;
                        //bc.X = 0.25F;                 commented as those 2 parameters are responsible for the wrong displayed barcodes not from the ISBT Lable Service
                        //bc.BarHeight = 1.0F;

                        if (item.Key.Substring(2, 4).ToLower() == "only")
                        {
                            //create Barcode only
                            image = Image.GetInstance(bc.CreateDrawingImage(System.Drawing.Color.Black, System.Drawing.Color.White),
                                                      System.Drawing.Imaging.ImageFormat.Jpeg);
                        }
                        else
                        {
                            //create Barcode with text
                            image = bc.CreateImageWithBarcode(pdfContentByte, null, null);
                        }

                        break;
                }

                image.ScaleAbsolute(fieldPosition.position.Width, fieldPosition.position.Height);
                image.SetAbsolutePosition(fieldPosition.position.Left, fieldPosition.position.Bottom);
                pdfContentByte.AddImage(image);
            }
        }


        /// <summary>
        /// Generates a Barcode of the type defined in the Field Key Name
        /// if not found Code128
        /// </summary>
        /// <param name="field">Field name containing Barcode Type in curly brackets  (BC{Barcode128}_UPN)</param>
        /// <returns>Barcode of specified Type</returns>
        private Barcode GetCorrectBarcode(string field)
        {

            Type t = typeof(Barcode);
            Assembly ass = Assembly.GetAssembly(t);
            Type[] types = ass.GetTypes();
            foreach (Type type in types)
            {
                if (type.Name == field)
                {
                    foreach (ConstructorInfo ci in type.GetConstructors())
                    {
                        if (ci.GetParameters().Length == 0)
                        {
                            return (Barcode)ci.Invoke(null);
                        }
                    }
                }
            }
            //default
            return new Barcode128();
        }

        private void ProcessField(KeyValuePair<string, string> item, AcroFields af, PdfStamper ps, ProcessFieldDelegate Callback)
        {
            IList<AcroFields.FieldPosition> fieldPositions = af.GetFieldPositions(item.Key);
            if (fieldPositions != null && fieldPositions.Count > 0)
            {
                Callback(item, af, ps, fieldPositions[0], ps.GetOverContent(fieldPositions[0].page));
            }
            else
            {
                logger.Info("Field " + item.Key + " not found in template ");
            }
        }
    }
}