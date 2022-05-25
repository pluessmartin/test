using System;
using System.IO;

#region header
//==========================================
//
//  PENTAG Informatik AG, 3000 Bern
//           www.pentag.ch
//
//==========================================
//
//  $Author: kracher $
//  $Date: 2010-07-23 05:56:09 $
//  $Revision: 1.4 $
//
//==========================================
#endregion

namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// Helper class containing some more or less useful methods for I/O operations
    /// obsolete
    /// </summary>
    public class FileUtil
    {
        /// <summary>
        /// Function to read a file and store it in a bytearray
        /// </summary>
        /// <param name="fileName">Filename of the file</param>
        /// <returns>bytearray representation of the current file</returns>
        public static byte[] ReadByteArrayFromFile(string fileName)
        {
            byte[] buff = null;
            FileStream fs = new FileStream(fileName, FileMode.Open, FileAccess.Read);
            BinaryReader br = new BinaryReader(fs);
            long numBytes = new FileInfo(fileName).Length;
            buff = br.ReadBytes((int)numBytes);
            return buff;
        }

        /// <summary>
        /// Function to save byte array to a file
        /// </summary>
        /// <param name="FileName">File name to save byte array</param>
        /// <param name="ByteArray">Byte array to save to external file</param>
        /// <returns>Return true if byte array save successfully, if not return false</returns>
        public static bool ByteArrayToFile(string FileName, byte[] ByteArray)
        {
            try
            {
                // Open file for reading
                FileStream FileStream = new FileStream(FileName, FileMode.Create, FileAccess.Write);
                // Writes a block of bytes to this stream using data from a byte array.
                FileStream.Write(ByteArray, 0, ByteArray.Length);
                // close file stream
                FileStream.Close();
                return true;
            }
            catch (Exception)
            {
                return false;
            }
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: FileUtil.cs,v $
// Revision 1.4  2010-07-23 05:56:09  kracher
// *** empty log message ***
//
// Revision 1.3  2010-06-28 11:39:34  nydegger
// *** empty log message ***
//
// Revision 1.2  2010-06-08 17:03:09  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-05-30 16:23:08  nydegger
// *** empty log message ***
//
// Revision 1.1  2010-05-27 13:21:59  nydegger
// *** empty log message ***
//
//
//
#endregion
