using iTextSharp.text;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Pentag.SLIDS.Reports
{
    public class ReportBasePage : BasePage
    {
        /// <summary>
        /// Gets Swisstransplant logo image for document
        /// </summary>
        /// <returns>image</returns>
        internal Image GetSwisstransplantLogoImage()
        {
            Image image = Image.GetInstance(Server.MapPath("~/resources/swt_pdf.png"));
            image.Alignment = Image.UNDERLYING;
            image.SetAbsolutePosition(40, 773);
            image.ScalePercent(30);
            return image;
        }

        /// <summary>
        /// Gets Swisstransplant address image for document
        /// </summary>
        /// <returns>image</returns>
        internal Image GetSwisstransplantAddressImage()
        {

            Image image = Image.GetInstance(Server.MapPath("~/resources/address.png"));
            image.Alignment = Image.UNDERLYING;
            image.SetAbsolutePosition(370, 772);
            image.ScalePercent(45);
            return image;
        }
    }
}