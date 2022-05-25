using iTextSharp.text;
using iTextSharp.text.pdf;
using NLog;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Pentag.Jacie.PdfCreator
{
    public class PdfGeneratorTextFieldDynamicProtected
    {
        public static Logger logger = LogManager.GetCurrentClassLogger();

        public PdfGeneratorTextFieldDynamicProtected()
        {

        }

        public byte[] Generate(byte[] pdfTemplate, List<Dictionary<string, DictionaryValue>> listOfDict)
        {
            return ManipulatePdf(pdfTemplate, listOfDict);
        }

        public static byte[] ManipulatePdf(byte[] src, List<Dictionary<string, DictionaryValue>> listOfDict)
        {
            MemoryStream output = new MemoryStream();

            Document document = new Document();
            PdfCopy copy = new PdfSmartCopy(document, output);
            copy.SetMergeFields();
            document.Open();
            List<PdfReader> readers = new List<PdfReader>();
            for (int i = 0; i < listOfDict.Count; i++)
            {
                PdfReader reader = new PdfReader(RenameFields(src, i + 1, listOfDict[i]));
                readers.Add(reader);
                copy.AddDocument(reader);
            }
            document.Close();
            foreach (PdfReader reader in readers)
            {
                reader.Close();
            }
            return output.ToArray();
        }

        public static byte[] RenameFields(byte[] src, int i, Dictionary<string, DictionaryValue> dict)
        {
            MemoryStream baos = new MemoryStream();
            PdfReader reader = new PdfReader(src);
            PdfStamper stamper = new PdfStamper(reader, baos);
            AcroFields form = stamper.AcroFields;

            AcroFields pdfFormFields = stamper.AcroFields;

            foreach (KeyValuePair<string, DictionaryValue> item in dict)
            {
                pdfFormFields.SetField(item.Key, item.Value.Text);
                if (!item.Value.ReadProtected)
                {
                    pdfFormFields.SetFieldProperty(item.Key, "setfflags", PdfFormField.FF_READ_ONLY, null);
                }
            }

            HashSet<String> keys = new HashSet<String>(form.Fields.Keys);

            foreach (String key in keys)
            {
                form.RenameField(key, key + i.ToString());
            }

            stamper.Close();
            reader.Close();
            return baos.ToArray();
        }
    }
}
