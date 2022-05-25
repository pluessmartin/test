using System;
using System.Collections.Generic;
using System.Xml;

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
//  $Revision: 1.3 $
//
//==========================================
#endregion
namespace Pentag.Jacie.PdfCreator
{
    /// <summary>
    /// this class provides several XmlNode related methods like sorting an XmlNodeList and returning the sorted nodes in an SortedList or a SortedDictionary.
    /// In addition it provides helper methods to read Node values and return their values in the appropriate datatype
    /// </summary>
    public class XmlNodeUtil
    {

        /// <summary>
        /// sorts an XmlNode list
        /// </summary>
        /// <param name="nodeList">XmlNodeList</param>
        /// <param name="orderCriteria">the the order criteria as XmlElement</param>
        /// <returns>returns a sorted list</returns>
        public static SortedList<int, XmlNode> SortNodeList(XmlNodeList nodeList, string orderCriteria)
        {
            SortedList<int, XmlNode> list = new SortedList<int, XmlNode>();
            foreach (XmlNode v in nodeList)
            {
                //  Select the user-specified element as the key:
                int sKey = XmlNodeUtil.GetElementValueAsInt((XmlNode)(v), orderCriteria);
                list.Add(sKey, v);
            }
            return list;
        }


        /// <summary>
        /// sorts an XmlNode list
        /// </summary>
        /// <param name="nodeList">XmlNodeList</param>
        /// <param name="orderCriteria">the the order criteria as XmlElement</param>
        /// <returns>returns a sorted dictionary</returns>
        public static SortedDictionary<int, XmlNode> SortNodeListWithDictionary(XmlNodeList nodeList, string orderCriteria)
        {
            SortedDictionary<int, XmlNode> sortedDict = new SortedDictionary<int, XmlNode>();
            foreach (XmlNode v in nodeList)
            {
                //  Select the user-specified element as the key:
                int sKey = XmlNodeUtil.GetElementValueAsInt((XmlNode)(v), orderCriteria);
                sortedDict.Add(sKey, v);
            }
            return sortedDict;
        }

        /// <summary>
        /// returns the value of an XmlNode
        /// </summary>
        /// <param name="node">the "root" node</param>
        /// <param name="xPath">xpath expression for the wanted node</param>
        /// <returns>the InnerText of the wanted node</returns>
        public static string GetElementValue(XmlNode node, string xPath)
        {
            string value = null;
            XmlNode wantedNode = node.SelectSingleNode(xPath);
            if (wantedNode != null)
            {
                value = wantedNode.InnerText;
            }
            return value;
        }
        /// <summary>
        /// returns the float value of an XmlNode
        /// </summary>
        /// <param name="node">the "root" node</param>
        /// <param name="xPath">xpath expression for the wanted node</param>
        /// <returns>the value as float of the innertext from the wanted node</returns>
        public static float GetElementValueAsFloat(XmlNode node, string xPath)
        {
            string value = GetElementValue(node, xPath);
            return (float)Convert.ToDouble(value);
        }

        /// <summary>
        /// returns the boolean value of an XmlNode
        /// </summary>
        /// <param name="node">the "root" node</param>
        /// <param name="xPath">xpath expression for the wanted node</param>
        /// <returns>the value as boolean of the innertext from the wanted node</returns>
        public static bool GetElementValueAsBool(XmlNode node, string xPath)
        {
            string value = GetElementValue(node, xPath);
            return Convert.ToBoolean(value);
        }

        /// <summary>
        /// returns the int value of an XmlNode
        /// </summary>
        /// <param name="node">the "root" node</param>
        /// <param name="xPath">xpath expression for the wanted node</param>
        /// <returns>the value as float of the innertext from the wanted node</returns>
        public static int GetElementValueAsInt(XmlNode node, string xPath)
        {
            int res;
            string value = GetElementValue(node, xPath);
            res = Convert.ToInt32(value);
            return res;
        }
    }
}
#region footer
//----------------------
//  Revision Log:
//----------------------
// $Log: XmlNodeUtil.cs,v $
// Revision 1.3  2010-07-23 05:56:09  kracher
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
