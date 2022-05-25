using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Pentag.SLIDS.DAL;

namespace Pentag.SLIDS.Reports.DAL
{
    #region reports data structures

    public class ProcurementPerTeam
    {
        public string OrganGroup { get; set; }
        public string Team { get; set; }
        public int Intern { get; set; }
        public int Extern { get; set; }
        public int OrganGroupSort { get; set; }

        public ProcurementPerTeam(string team, string organGroup, int intern, int @extern, int organGroupSort)
        {
            Team = team;
            OrganGroup = organGroup;
            Intern = intern;
            Extern = @extern;
            OrganGroupSort = organGroupSort;
        }
    }

    public class BadQualityProcurement
    {
        public string DonorNumber { get; set; }
        public string OrganGroup { get; set; }
        public string QualityOfProcurement { get; set; }
        public decimal? BadQualityProcurementRatio { get; set; }
        public string ProcurementTeam { get; set; }
        public string ProcurementSurgeon { get; set; }

        public BadQualityProcurement(string donorNumber, string organGroup, string qualityOfProcurement, decimal? badQualityProcurementRatio, string procurementTeam, string procurementSurgeon)
        {
            DonorNumber = donorNumber;
            OrganGroup = organGroup;
            QualityOfProcurement = qualityOfProcurement;
            BadQualityProcurementRatio = badQualityProcurementRatio;
            ProcurementTeam = procurementTeam;
            ProcurementSurgeon = procurementSurgeon;
        }
    }

    #endregion

    public class Procurement : Common
    {
        public enum ProcurementUse
        {
            Intern = 1,
            Extern = 2
        };

        private const string TOTAL = "Total";
        private const string BAD = "Bad";

        /// <summary>
        /// Used for report "Procured organs per team"
        /// Gets Procurement Teams and displays how many procurements were done for intern or extern use
        /// </summary>
        /// <param name="procurementDateFrom">procurement date from</param>
        /// <param name="procurementDateTo">procurement date to</param>
        /// <returns>returns list of Procurement teams and shows how many procurements were done for own use and how many were done for other teams</returns>
        public List<ProcurementPerTeam> GetProcurementPerTeam(DateTime? procurementDateFrom, DateTime? procurementDateTo)
        {
            try
            {
                if (procurementDateFrom == null && procurementDateTo == null) return new List<ProcurementPerTeam>();

                List<ProcurementPerTeam> listProcurementPerTeam = new List<ProcurementPerTeam>();
                
                // get all organ item groups
                List<ItemGroup> organGroups = GetOrganItemGroups();
                
                // Get all procurement teams and get count for intern and extern use per team and item group
                List<Hospital> transplantationHospitals = GetTransplantationHospitals();
                foreach (Hospital transplantationHospital in transplantationHospitals)
                {
                    string team = transplantationHospital.Display;

                    foreach (ItemGroup organGroup in organGroups)
                    {
                        string organGroupName = organGroup.Name;
                        int organGroupSort = organGroup.ID;

                        List<TransplantOrgan> transplantOrgans = GetTransplantOrgansByItemGroupID(organGroup.ID,
                                                                                                  transplantationHospital.ID,
                                                                                                  procurementDateFrom,
                                                                                                  procurementDateTo);
                        // Don't add to list if no organs were transplanted
                        if(transplantOrgans.Count == 0) continue;

                        int internUserCount = GetNumberOfOrgansAccordingToProcurementUse(transplantOrgans, ProcurementUse.Intern);
                        int externUseCount = GetNumberOfOrgansAccordingToProcurementUse(transplantOrgans, ProcurementUse.Extern);

                        ProcurementPerTeam procurementPerTeam = new ProcurementPerTeam(team, organGroupName, internUserCount, externUseCount, organGroupSort);

                        listProcurementPerTeam.Add(procurementPerTeam);
                    }
                }

                return listProcurementPerTeam;
            }
            catch (Exception ex)
            {
                logger.Error("Failed loading procurement per team report data due to an error: " + ex.Message);
            }

            return new List<ProcurementPerTeam>();
        }

        #region Privates

        #region ProcurementPerTeam
        /// <summary>
        /// Gets number of transplant organs (CountableAs attribute of organ as count) which were either used for own purpose (procurement team = transplansplant center)
        /// or were used for other teams (procurement team != transplant center
        /// </summary>
        /// <param name="transplantOrgans">list of TransplantOrgans</param>
        /// <param name="procurementUse">procurement use (intern or extern)</param>
        /// <returns>returns number of procured organs for intern or extern use</returns>
        private int GetNumberOfOrgansAccordingToProcurementUse(List<TransplantOrgan> transplantOrgans, ProcurementUse procurementUse)
        {
            return transplantOrgans
                .Where((to => (procurementUse == ProcurementUse.Intern
                               && to.ProcurementTeamID != null
                               && to.TransplantCenterID != null
                               && to.ProcurementTeamID == to.TransplantCenterID)
                              ||
                              (procurementUse == ProcurementUse.Extern
                               && to.ProcurementTeamID != null
                               && to.TransplantCenterID != null
                               && to.ProcurementTeamID != to.TransplantCenterID)))
                .Where(to => to.Organ.CountableAs != null)
                .Sum(to => Convert.ToInt32(to.Organ.CountableAs));
        }
        #endregion

        /// <summary>
        /// Adds total row data (number of bad quality of procurements, percentage) to listBadQualityProcurement
        /// </summary>
        /// <param name="listBadQualityProcurement">list BadQualityProcurement</param>
        /// <param name="totalTransplantOrganCount">number of bad procurements of transplant organs</param>
        private void AddTotalRowToBadQualityProcurementList(List<BadQualityProcurement> listBadQualityProcurement, int totalTransplantOrganCount)
        {
            int badProcurementCount = listBadQualityProcurement.Count;
            decimal? badQualityRatio = totalTransplantOrganCount > 0
                                       && badProcurementCount > 0
                                           ? (badProcurementCount/(decimal) totalTransplantOrganCount)
                                           : (decimal?) null;

            BadQualityProcurement badQualityProcurement = new BadQualityProcurement(TOTAL,
                                                                                    String.Empty,
                                                                                    badProcurementCount.ToString(CultureInfo.InvariantCulture),
                                                                                    badQualityRatio,
                                                                                    String.Empty,
                                                                                    String.Empty);

            listBadQualityProcurement.Add(badQualityProcurement);
        }
        #endregion
    }
}