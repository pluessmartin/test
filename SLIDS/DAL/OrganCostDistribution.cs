//------------------------------------------------------------------------------
// <auto-generated>
//    This code was generated from a template.
//
//    Manual changes to this file may cause unexpected behavior in your application.
//    Manual changes to this file will be overwritten if the code is regenerated.
// </auto-generated>
//------------------------------------------------------------------------------

namespace Pentag.SLIDS.DAL
{
    using System;
    using System.Collections.Generic;
    
    public partial class OrganCostDistribution
    {
        public int ID { get; set; }
        public int OrganID { get; set; }
        public int CostDistributionID { get; set; }
        public Nullable<int> Weight { get; set; }
        public Nullable<decimal> Const { get; set; }
        public Nullable<decimal> ConstPerKm { get; set; }
    
        public virtual CostDistribution CostDistribution { get; set; }
        public virtual Organ Organ { get; set; }
    }
}