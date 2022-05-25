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
    
    public partial class Delay
    {
        public Delay()
        {
            this.IncidentDonorRelatedDelay = new HashSet<IncidentDonorRelatedDelay>();
        }
    
        public int ID { get; set; }
        public int TransportID { get; set; }
        public Nullable<int> DelayReasonID { get; set; }
        public string OtherReason { get; set; }
        public Nullable<System.TimeSpan> Duration { get; set; }
        public bool IsOrganLost { get; set; }
        public string Comment { get; set; }
        public bool IsDeleted { get; set; }
        public byte[] ModificationVersion { get; set; }
    
        public virtual DelayReason DelayReason { get; set; }
        public virtual ICollection<IncidentDonorRelatedDelay> IncidentDonorRelatedDelay { get; set; }
        public virtual Transport Transport { get; set; }
    }
}
