using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Pentag.SLIDS.Common
{
    public static class StringExtensions
    {
        public static bool ContainsCaseInsensitive(this string source, string toCheck, StringComparison comp = StringComparison.OrdinalIgnoreCase)
        {
            if (string.IsNullOrEmpty(source))
            {
                return false;
            }
            return source.IndexOf(toCheck, comp) >= 0;
        }
    }
}