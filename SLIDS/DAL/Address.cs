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
    
    public partial class Address
    {
        public Address()
        {
            this.Coordinator = new HashSet<Coordinator>();
            this.Hospital = new HashSet<Hospital>();
            this.Hospital1 = new HashSet<Hospital>();
        }
    
        public int ID { get; set; }
        public string Address1 { get; set; }
        public string Address2 { get; set; }
        public string Address3 { get; set; }
        public string Address4 { get; set; }
        public string Zip { get; set; }
        public string City { get; set; }
        public string CountryISO { get; set; }
        public string Phone { get; set; }
        public string Fax { get; set; }
        public string Email { get; set; }
        public byte[] ModificationVersion { get; set; }
        public string ContactPerson { get; set; }
    
        public virtual ICollection<Coordinator> Coordinator { get; set; }
        public virtual ICollection<Hospital> Hospital { get; set; }
        public virtual ICollection<Hospital> Hospital1 { get; set; }
    }
}