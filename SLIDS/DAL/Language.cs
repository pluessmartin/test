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
    
    public partial class Language
    {
        public Language()
        {
            this.Hospital = new HashSet<Hospital>();
            this.ReminderLetter = new HashSet<ReminderLetter>();
        }
    
        public int ID { get; set; }
        public string LanguageName { get; set; }
        public string LanguageShort { get; set; }
        public bool isActive { get; set; }
        public byte[] ModificationVersion { get; set; }
    
        public virtual ICollection<Hospital> Hospital { get; set; }
        public virtual ICollection<ReminderLetter> ReminderLetter { get; set; }
    }
}