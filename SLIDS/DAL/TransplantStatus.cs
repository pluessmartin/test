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
    
    public partial class TransplantStatus
    {
        public TransplantStatus()
        {
            this.TransplantOrgan = new HashSet<TransplantOrgan>();
        }
    
        public int ID { get; set; }
        public string Name { get; set; }
        public Nullable<int> Position { get; set; }
        public bool isActive { get; set; }
    
        public virtual ICollection<TransplantOrgan> TransplantOrgan { get; set; }
    }
}
