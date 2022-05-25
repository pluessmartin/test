using System;

namespace Pentag.SLIDS
{
    /// <summary>
    ///     WarmUp page to be called after recycle of AppPool to Initialize what cen be inizialized.
    /// </summary>
    public partial class WarmUp : BasePage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            logger.Trace("WarmUp Started");
            GetCoordinators();
            GetCosts();
            GetDelays();
            GetDonors();
            GetHospitals();
            GetOrgans();
            GetSwissHospitals();
            GetTransplantOrgans();
            GetTransportItems();
            GetTransports();
            GetVehicles();
            logger.Trace("WarmUp Done");
        }
    }
}