namespace Pentag.SLIDS.DAL
{
    public partial class OrganCost
    {
        /// <summary>
        ///     Indicates if OrganCost was added to the list automatically depending on settings in OrganCostDistribution.
        ///     This indication is necessary when clearing the list from automatically added OrganCosts so that manual added
        ///     OrganCosts won't be lost after the user changes settings which results in a new automatic OrganCostDistribution
        /// </summary>
        public bool AddedByAutomation { get; set; }

        /// <summary>
        ///     Indicates if OrganCost was automatically added using weight distribution. This will be used for rounding purposes.
        ///     With this indication weight distributed costs can be extracted from OrganCost-List and compared to total amount.
        /// </summary>
        public bool IsDistributedByWeight { get; set; }
    }
}