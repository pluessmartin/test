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
    
    public partial class Incident
    {
        public Incident()
        {
            this.Incident1 = new HashSet<Incident>();
            this.IncidentAlert = new HashSet<IncidentAlert>();
            this.IncidentTask = new HashSet<IncidentTask>();
            this.IncidentDocument = new HashSet<IncidentDocument>();
            this.IncidentDonorRelatedDelay = new HashSet<IncidentDonorRelatedDelay>();
            this.IncidentDonorRelatedOrgan = new HashSet<IncidentDonorRelatedOrgan>();
            this.IncidentDonorRelatedTransport = new HashSet<IncidentDonorRelatedTransport>();
            this.IncidentAnalysis = new HashSet<IncidentAnalysis>();
        }
    
        public int ID { get; set; }
        public Nullable<int> OriginalID { get; set; }
        public Nullable<int> IncidentStateID { get; set; }
        public string CreatorUserName { get; set; }
        public string CreatorEmail { get; set; }
        public string CreatorCenter { get; set; }
        public string CreatorPhone { get; set; }
        public System.DateTime CreationDate { get; set; }
        public Nullable<int> IncidentProcessID { get; set; }
        public Nullable<int> IncidentCategoryID { get; set; }
        public string DonorNumber { get; set; }
        public Nullable<System.DateTime> DateTimeOfIncident { get; set; }
        public string Location { get; set; }
        public string IncidentDescription { get; set; }
        public string PersonsInvolved { get; set; }
        public string Impact { get; set; }
        public string Suggestions { get; set; }
        public Nullable<int> IncidentDamageCategoryID { get; set; }
        public Nullable<int> IncidentPotentialDamageID { get; set; }
        public Nullable<int> IncidentLikelihoodToRepeatID { get; set; }
        public string DamageDescription { get; set; }
        public string CorrectiveAction { get; set; }
        public string PreventiveAction { get; set; }
        public bool IsArchived { get; set; }
        public bool IsDeleted { get; set; }
        public Nullable<System.DateTime> ModificationDate { get; set; }
        public byte[] ModificationVersion { get; set; }
        public int IncidentNo { get; set; }
        public string CategoryOther { get; set; }
    
        public virtual ICollection<Incident> Incident1 { get; set; }
        public virtual Incident Incident2 { get; set; }
        public virtual IncidentCategory IncidentCategory { get; set; }
        public virtual IncidentDamageCategory IncidentDamageCategory { get; set; }
        public virtual IncidentLikelihoodToRepeat IncidentLikelihoodToRepeat { get; set; }
        public virtual IncidentPotentialDamage IncidentPotentialDamage { get; set; }
        public virtual IncidentProcess IncidentProcess { get; set; }
        public virtual IncidentState IncidentState { get; set; }
        public virtual ICollection<IncidentAlert> IncidentAlert { get; set; }
        public virtual ICollection<IncidentTask> IncidentTask { get; set; }
        public virtual ICollection<IncidentDocument> IncidentDocument { get; set; }
        public virtual ICollection<IncidentDonorRelatedDelay> IncidentDonorRelatedDelay { get; set; }
        public virtual ICollection<IncidentDonorRelatedOrgan> IncidentDonorRelatedOrgan { get; set; }
        public virtual ICollection<IncidentDonorRelatedTransport> IncidentDonorRelatedTransport { get; set; }
        public virtual ICollection<IncidentAnalysis> IncidentAnalysis { get; set; }
    }
}
