using System;
using System.Security.Cryptography;
using System.Text;
using System.Text.RegularExpressions;

namespace Pentag.SLIDS.Common
{
    public static class Crypto
    {
        public static string GenerateToken(int length)
        {
            const string valid = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890_-!$";
            StringBuilder res = new StringBuilder();
            using (RNGCryptoServiceProvider rng = new RNGCryptoServiceProvider())
            {
                byte[] uintBuffer = new byte[sizeof(uint)];

                while (length-- > 0)
                {
                    rng.GetBytes(uintBuffer);
                    uint num = BitConverter.ToUInt32(uintBuffer, 0);
                    res.Append(valid[(int)(num % (uint)valid.Length)]);
                }
            }

            return res.ToString();
        }

        public static string MaskEmail(string email)
        {
            const string pattern = @"(?<=[\w]{2})[\w-\._\+%]*(?=[\w]{2}@)";
            return Regex.Replace(email, pattern, m => new string('*', m.Length));
        }
    }
}