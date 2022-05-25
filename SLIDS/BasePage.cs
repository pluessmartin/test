using NLog;
using Pentag.SLIDS.Controls;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.Configuration;
using System.Globalization;
using System.Linq;
using System.Net;
using System.Net.Mail;
using System.Reflection;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace Pentag.SLIDS
{
    public class BasePage : Page
    {
        #region Constants
        public const string FlatChargesIC = "Flat charges IC";
        public const string FlatChargesOR = "Flat charges OR";
        public const string BasicAmountIC = "Basic Amount IC";
        public const string BasicAmountOR = "Basic Amount OR";
        public const string FlatChargesICDetectionHospital = "Flat charges IC detection Hospital";
        public const string FlatChargesICReferraHospital = "Flat charges IC referral Hospital";
        #endregion

        #region Enums
        public enum CostGroup
        {
            Transport = 1,
            Donor = 2,
            TransportGlobal = 3
        };

        public enum TransplantStatus
        {
            REF = 1,
            PAT = 2,
            POT = 3,
            AGE = 4,
            MED = 5,
            NCR = 6,
            NOF = 7,
            REV = 8,
            LOG = 9,
            NTX = 10,
            PAC = 11,
            OPI = 12,
            TX = 13
        };

        public enum ItemGroupType
        {
            Undefined = 0,
            Organ = 1,
            TransportItem = 2
        };

        public enum ItemGroupValue
        {
            Heart = 1,
            Lung = 2,
            Liver = 3,
            Kidney = 4,
            Pancreas = 5,
            SmallBowel = 6,
            Blood = 7,
            Biopsy = 8,
            Teams = 9,
            TransplantCoordinator = 10,
            Donor = 11,
            Other = 12,
            Empty = 13,
            Lifeport = 14
        };
        #endregion

        #region Data Entities
        private Entities data;

        public Entities Data
        {
            get
            {
                if (data == null)
                {
                    if (Session["DataContext"] == null)
                    {
                        Session["DataContext"] = new Entities();
                    }
                    data = (Entities)Session["DataContext"];
                }
                return data;
            }
            set { data = value; }
        }
        #endregion

        #region Logger handling
        protected static Logger logger = LogManager.GetCurrentClassLogger();

        protected void WriteErrorLog(Exception ex, string additionalMessage)
        {
            logger.Error(additionalMessage + ": " + ex.Message);
            while (ex.InnerException != null)
            {
                ex = ex.InnerException;
                logger.Error(ex.Message);
            }
        }
        #endregion

        #region Donor Methods
        /// <summary>
        ///     Returns IQueryable of Donors which are not deleted
        /// </summary>
        /// <returns>Donor Datarows</returns>
        public IQueryable<Donor> GetDonors()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Donor
                           .Where(d => !d.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select Donor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Donor Datarow according to provided ID
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <returns>Donor Datarow</returns>
        public Donor GetDonorByID(int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Donor rowDonor;

            try
            {
                rowDonor = GetDonors().SingleOrDefault(d => d.ID == donorID);
            }
            catch (Exception ex)
            {
                const string message = "Select Donor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowDonor;
        }

        /// <summary>
        ///     Retrieves information if Donor is archived or not
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <returns>true when Donor is archived, false otherwise</returns>
        public bool DonorIsArchived(int donorID)
        {
            Donor d = GetDonorByID(donorID);
            if (d == null) throw new ArgumentNullException(String.Format("Donor with ID {0} could not be found!", donorID));

            return d.IsArchived;
        }
        #endregion

        #region ItemGroup Methods
        /// <summary>
        ///     Returns IQueryable of ItemGroups
        /// </summary>
        /// <returns>ItemGroup Datarows</returns>
        public IQueryable<ItemGroup> GetItemGroups()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.ItemGroup;
            }
            catch (Exception ex)
            {
                const string message = "Select ItemGroup failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of ItemGroups
        /// </summary>
        /// <param name="type">ItemGroup Type (either Organ or TransportItem)</param>
        /// <returns>ItemGroup Datarows</returns>
        public IQueryable<ItemGroup> GetItemGroupsByType(int type)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.ItemGroup.Where(ig => ig.Type == type);
            }
            catch (Exception ex)
            {
                const string message = "Select ItemGroup by type failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns ItemGroup Datarow according to provided ID
        /// </summary>
        /// <param name="itemGroupID">ItemGroup ID</param>
        /// <returns>ItemGroup Datarow</returns>
        public ItemGroup GetItemGroupByID(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            ItemGroup rowItemGroup;

            try
            {
                rowItemGroup = GetItemGroups().SingleOrDefault(o => o.ID == itemGroupID);
            }
            catch (Exception ex)
            {
                const string message = "Select ItemGroup failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowItemGroup;
        }
        #endregion

        #region Organ Methods
        /// <summary>
        ///     Returns IQueryable of Organs (ordered by position)
        /// </summary>
        /// <returns>Organ Datarows</returns>
        public IQueryable<DAL.Organ> GetOrgans()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Organ.OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select Organ failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Organs according to provided itemGroupID (ordered by position)
        /// </summary>
        /// <returns>Organ Datarows</returns>
        public IQueryable<DAL.Organ> GetOrgansByItemGroup(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Organ
                           .Where(o => o.ItemGroupID == itemGroupID)
                           .Where(o => o.isActive)
                           .OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select Organ by ItemGroupID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Organ Datarow according to provided ID
        /// </summary>
        /// <param name="organID">Organ ID</param>
        /// <returns>Organ Datarow</returns>
        public DAL.Organ GetOrganByID(int organID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.Organ rowOrgan;

            try
            {
                rowOrgan = GetOrgans().SingleOrDefault(o => o.ID == organID);
            }
            catch (Exception ex)
            {
                const string message = "Select Organ failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowOrgan;
        }

        /// <summary>
        ///     Returns IQueryable of TransplantOrgans which are not deleted
        /// </summary>
        /// <returns>TransplantOrgan Datarows</returns>
        public IQueryable<TransplantOrgan> GetTransplantOrgans()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.TransplantOrgan
                           .Where(to => !to.IsDeleted)
                           .Where(to => !to.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select TransplantOrgan failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns TransplantOrgan Datarow according to provided ID
        /// </summary>
        /// <param name="transplantOrganID">TransplantOrgan ID</param>
        /// <returns>TransplantOrgan Datarow</returns>
        public TransplantOrgan GetTransplantOrganByID(int transplantOrganID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            TransplantOrgan rowTransplantOrgan;

            try
            {
                rowTransplantOrgan = GetTransplantOrgans().SingleOrDefault(to => to.ID == transplantOrganID);
            }
            catch (Exception ex)
            {
                const string message = "Select TransplantOrgan failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowTransplantOrgan;
        }

        /// <summary>
        ///     Returns a list of TransplantOrgan according to provided donorID
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <returns>TransplantOrgan Datarow</returns>
        public List<TransplantOrgan> GetTransplantOrgansByDonorID(int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            List<TransplantOrgan> rowsTransplantOrgan;

            try
            {
                rowsTransplantOrgan = GetTransplantOrgans()
                    .Where(to => to.DonorID == donorID).ToList();
            }
            catch (Exception ex)
            {
                const string message = "Select TransplantOrgan failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowsTransplantOrgan;
        }

        /// <summary>
        ///     Returns a list of TransplantOrgan according to provided itemGroupID
        /// </summary>
        /// <param name="itemGroupID">ItemGroup ID</param>
        /// <returns>TransplantOrgan Datarow</returns>
        public List<TransplantOrgan> GetTransplantOrgansByItemGroupID(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            List<TransplantOrgan> rowsTransplantOrgan;

            try
            {
                rowsTransplantOrgan = GetTransplantOrgans()
                    .Where(to => to.Organ.ItemGroupID == itemGroupID).ToList();
            }
            catch (Exception ex)
            {
                const string message = "Select TransplantOrgan by item group ID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowsTransplantOrgan;
        }
        #endregion

        #region Transport Methods
        /// <summary>
        ///     Returns IQueryable of Transports which are not deleted
        /// </summary>
        /// <returns>Transport Datarows</returns>
        public IQueryable<DAL.Transport> GetTransports()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Transport
                           .Where(t => !t.IsDeleted)
                           .Where(t => !t.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select Transport failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Transports of Donor which are not deleted
        /// </summary>
        /// <param name="donorID">Donor ID</param>
        /// <returns>Transport Datarows</returns>
        public IQueryable<DAL.Transport> GetTransportsByDonorID(int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetTransports()
                    .Where(t => t.DonorID == donorID);
            }
            catch (Exception ex)
            {
                const string message = "Select Transport by Donor-ID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Transports of Vehicle
        /// </summary>
        /// <param name="vehicleID">Vehicle ID</param>
        /// <returns>Transport Datarows</returns>
        public IQueryable<DAL.Transport> GetTransportsByVehicleID(int vehicleID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetTransports()
                    .Where(t => t.VehicleID == vehicleID);
            }
            catch (Exception ex)
            {
                const string message = "Select Transport by Vehicle-ID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of TransportItems (ordered by position)
        /// </summary>
        /// <returns>TransportItem Datarows</returns>
        public IQueryable<TransportItem> GetTransportItems()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.TransportItem.OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select TransportItem failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of TransportItems according to provided itemGroupID
        /// </summary>
        /// <returns>TransportItem Datarows</returns>
        public List<TransportItem> GetTransportItemsByItemGroupID(int itemGroupID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetTransportItems().Where(ti => ti.ItemGroupID == itemGroupID).ToList();
            }
            catch (Exception ex)
            {
                const string message = "Select TransportItem by item group ID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Transport Datarow according to provided ID
        /// </summary>
        /// <param name="transportID">Transport ID</param>
        /// <returns>Transport Datarow</returns>
        public DAL.Transport GetTransportByID(int transportID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.Transport rowTransport;

            try
            {
                rowTransport = GetTransports().SingleOrDefault(t => t.ID == transportID);
            }
            catch (Exception ex)
            {
                const string message = "Select Transport failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowTransport;
        }

        /// <summary>
        ///     Returns TransportItem Datarow according to provided ID
        /// </summary>
        /// <param name="transportItemID">TransportItem ID</param>
        /// <returns>TransportItem Datarow</returns>
        public TransportItem GetTransportItemByID(int transportItemID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            TransportItem rowTransportItem;

            try
            {
                rowTransportItem = GetTransportItems().SingleOrDefault(ti => ti.ID == transportItemID);
            }
            catch (Exception ex)
            {
                const string message = "Select TransportItem failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowTransportItem;
        }

        /// <summary>
        ///     Returns transported organs and items in a string, separated by a semicolon
        /// </summary>
        /// <param name="t">Transport item</param>
        /// <returns>string with transported organs and items to this transport item</returns>
        public string GetTransportedElements(DAL.Transport t)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            String elements = String.Empty;

            try
            {
                if (t == null) return String.Empty;

                foreach (TransportedOrgan to in t.TransportedOrgan.Where(to => !to.TransplantOrgan.IsDeleted))
                {
                    string addon = String.Empty;
                    if ((bool)to.TransplantOrgan.PrefusionMachine)
                    {
                        if (!String.IsNullOrEmpty(to.TransplantOrgan.PrefusionMachineNumber))
                        {
                            addon = " (" + to.TransplantOrgan.PrefusionMachineNumber + ")";
                        }
                    }
                    elements += to.TransplantOrgan.Organ.Name + addon + ", ";
                }

                foreach (TransportItem ti in t.TransportItem)
                {
                    elements += ti.Name + ", ";
                }
            }
            catch (Exception ex)
            {
                const string message = "Collecting transported organs and items failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return elements.Length > 1 ? elements.Substring(0, elements.Length - 2) : String.Empty;
        }

        /// <summary>
        ///     Returns Distance between hosptialID1 and hospitalID2
        /// </summary>
        /// <remarks>
        ///     hospitalID2 needs to a transplantation hospital, data is otherwise not available
        /// </remarks>
        /// <param name="hospitalID1">Departure hospital</param>
        /// <param name="hospitalID2">Destination hospital (must be a transplantation hospital)</param>
        /// <returns>Distance of km (as int)</returns>
        public int GetTransportDistance(int hospitalID1, int hospitalID2)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            int distance = 0;

            try
            {
                Distance rowDistance = Data.Distance
                                           .Where(d => d.Hospital1ID == hospitalID1)
                                           .Where(d => d.Hospital2ID == hospitalID2).SingleOrDefault();

                if (rowDistance != null)
                {
                    distance = Convert.ToInt32(rowDistance.Km);
                    return distance;
                }

                // Check the other way round if no data was found
                rowDistance = Data.Distance
                                  .Where(d => d.Hospital1ID == hospitalID2)
                                  .Where(d => d.Hospital2ID == hospitalID1).SingleOrDefault();

                if (rowDistance != null)
                {
                    distance = Convert.ToInt32(rowDistance.Km);
                    return distance;
                }
            }
            catch (Exception ex)
            {
                const string message = "Select Distance failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return distance;
        }
        #endregion

        #region Vehicle Methods
        /// <summary>
        ///     Returns IQueryable of Vehicle (ordered by position)
        /// </summary>
        /// <returns>Vehicle Datarows</returns>
        public IQueryable<Vehicle> GetVehicles()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Vehicle.OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select Vehicle failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Vehicle Datarow according to provided ID
        /// </summary>
        /// <param name="vehicleID">Vehicle ID</param>
        /// <returns>Vehicle Datarow</returns>
        public Vehicle GetVehicleByID(int vehicleID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Vehicle rowVehicle;

            try
            {
                rowVehicle = GetVehicles().SingleOrDefault(o => o.ID == vehicleID);
            }
            catch (Exception ex)
            {
                const string message = "Select Vehicle failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowVehicle;
        }
        #endregion

        #region Lifeport Methods
        /// <summary>
        ///     Returns IQueryable of Lifeport (ordered by position)
        /// </summary>
        /// <returns>Lifport Datarows</returns>
        public IQueryable<Lifeport> GetLifeports()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Lifeport.Where(o => o.isActive).OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select Lifeport failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Lifeport (ordered by position)
        /// </summary>
        /// <returns>Lifport Datarows</returns>
        public IQueryable<Lifeport> GetAllLifeports()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Lifeport.OrderBy(o => o.Position);
            }
            catch (Exception ex)
            {
                const string message = "Select All Lifeport failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Vehicle Datarow according to provided ID
        /// </summary>
        /// <param name="vehicleID">Vehicle ID</param>
        /// <returns>Vehicle Datarow</returns>
        public Lifeport GetLifeportByID(int lifeportID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Lifeport rowLifeport;

            try
            {
                rowLifeport = GetLifeports().SingleOrDefault(o => o.ID == lifeportID);
            }
            catch (Exception ex)
            {
                const string message = "Select Lifeport failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowLifeport;
        }
        #endregion

        #region Coordinator Methods
        /// <summary>
        ///     Returns IQueryable of Coordinators
        /// </summary>
        /// <returns>Coordinator Datarows</returns>
        public IQueryable<Coordinator> GetCoordinators()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Coordinator.OrderBy(c => c.Code);
            }
            catch (Exception ex)
            {
                const string message = "Select Coordinator failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Coordinator Datarow according to provided ID
        /// </summary>
        /// <param name="coordID">Coordinator ID</param>
        /// <returns>Coordinator Datarow</returns>
        public Coordinator GetCoordinatorByID(int coordID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Coordinator rowCoordinator;

            try
            {
                rowCoordinator = GetCoordinators().SingleOrDefault(c => c.ID == coordID);
            }
            catch (Exception ex)
            {
                const string message = "Select Coordinator failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCoordinator;
        }

        #endregion


        #region DonationPathway
        /// <summary>
        ///     Returns IQueryable of DonationPathway
        /// </summary>
        /// <param name="includeFOTeam">Select Hospitals including FO-Team, yes or no?</param>
        /// <returns>Hospital Datarows</returns>
        public IQueryable<DonationPathway> GetDonationPathway()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.DonationPathway;
            }
            catch (Exception ex)
            {
                const string message = "Select DonationPathway failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        #endregion

        #region Hospital Methods
        /// <summary>
        ///     Returns IQueryable of Hospitals
        /// </summary>
        /// <param name="includeFOTeam">Select Hospitals including FO-Team, yes or no?</param>
        /// <returns>Hospital Datarows</returns>
        public IQueryable<Hospital> GetHospitals(bool includeFOTeam = false)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Hospital
                           .Where(h => h.ID != 0 || includeFOTeam);
            }
            catch (Exception ex)
            {
                const string message = "Select Hospital failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Swiss Hospitals whith the exception of alternateHospitalID
        /// </summary>
        /// <returns>Swiss Hospital Datarows</returns>
        public IQueryable<Hospital> GetSwissHospitals()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetHospitals()
                    .Where(h => !h.IsFo);
            }
            catch (Exception ex)
            {
                const string message = "Select Swiss Hospitals failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Swiss Hospitals whith the exceptions of alternateHospitals which can be FO-Hospitals
        /// </summary>
        /// <param name="alternateHospitals">list of alternate hospital IDs which could be FO-Hospitals but should be selectable nevertheless</param>
        /// <returns>Swiss Hospital Datarows with exception of possible alternate FO-Hospitals</returns>
        public IQueryable<Hospital> GetSwissHospitals(List<int?> alternateHospitals)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetHospitals()
                    .Where(h => !h.IsFo || alternateHospitals.Count > 0 && alternateHospitals.Contains(h.ID));
            }
            catch (Exception ex)
            {
                const string message = "Select Swiss Hospitals failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Hospital Datarow according to provided ID
        /// </summary>
        /// <param name="hospitalID">Hospital ID</param>
        /// <returns>Hospital Datarow</returns>
        public Hospital GetHospitalByID(int hospitalID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Hospital rowHospital;

            try
            {
                rowHospital = GetHospitals().SingleOrDefault(h => h.ID == hospitalID);
            }
            catch (Exception ex)
            {
                const string message = "Select Hospital failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowHospital;
        }

        /// <summary>
        ///     Returns Hospital Datarow according to provided TransplantCoordinator ID
        /// </summary>
        /// <param name="tcID">TransplantCoordinator ID</param>
        /// <returns>Hospital Datarow</returns>
        public Hospital GetHospitalByTCID(int tcID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Hospital rowHospital = null;

            try
            {
                Coordinator c = GetCoordinatorByID(tcID);

                if (c != null)
                {
                    rowHospital = GetHospitals().SingleOrDefault(h => h.ID == c.HospitalID);
                }
            }
            catch (Exception ex)
            {
                const string message = "Select Hospital via TransplantCoordinator-ID failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowHospital;
        }

        /// <summary>
        ///     Returns true or false if provided hospital ID is a FO hospital
        /// </summary>
        /// <param name="hospitalID">Hospital ID</param>
        /// <returns>true if hospital is FO hospital, false otherwise</returns>
        public bool HospitalIsFO(int hospitalID)
        {
            Hospital h = GetHospitalByID(hospitalID);
            if (h == null) return false;

            return h.IsFo;
        }

        /// <summary>
        ///     Returns true or false if provided hospital ID is a Transplantation hospital
        /// </summary>
        /// <param name="hospitalID">Hospital ID</param>
        /// <returns>true if hospital is transplantation hospital, false otherwise</returns>
        public bool HospitalIsTransplantation(int hospitalID)
        {
            Hospital h = GetHospitalByID(hospitalID);
            return h != null && h.IsTransplantation;
        }
        #endregion

        #region Address Methods
        /// <summary>
        ///     Returns IQueryable of Hospitals
        /// </summary>
        /// <returns>Hospital Datarows</returns>
        public IQueryable<Address> GetAddresses()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Address
                           .Where(h => h.ID > 0);
            }
            catch (Exception ex)
            {
                const string message = "Select Address failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        public Address GetAddressByID(int addressID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Address rowAddress;

            try
            {
                rowAddress = GetAddresses().SingleOrDefault(c => c.ID == addressID);
            }
            catch (Exception ex)
            {
                const string message = "Select TransplantOrgan failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowAddress;
        }
        #endregion

        #region Cost Methods
        /// <summary>
        ///     Returns IQueryable of Costs which are not deleted
        /// </summary>
        /// <returns>Cost Datarows</returns>
        public IQueryable<DAL.Cost> GetCosts()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Cost
                           .Where(c => !c.IsDeleted)
                           .Where(c => !c.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select Cost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Costs of creditor hospital for donor
        /// </summary>
        /// <returns>Cost Datarows</returns>
        public IQueryable<DAL.Cost> GetCostsOfKreditorHospitalByDonorID(int hospitalID, int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetCosts()
                    .Where(c => c.DonorID == donorID)
                    .Where(c => c.KreditorHospitalID == hospitalID);
            }
            catch (Exception ex)
            {
                const string message = "Select Cost of creditor hospital for donor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Costs for financial report which are not deleted
        /// </summary>
        /// <remarks>
        /// Only costs of cost type Basic Amount IC, Basic Amount OR, Flat charges IC, Flat charges OR and Flat charges IC detection hospitals are returned
        /// </remarks>
        /// <returns>Cost Datarows</returns>
        public IQueryable<DAL.Cost> GetFinancialReportCosts(int hospitalID, int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetCosts()
                    .Where(c => c.DonorID == donorID)
                    .Where(c => c.KreditorHospitalID == hospitalID)
                    .Where(c => c.CostType.Name == FlatChargesIC
                                || c.CostType.Name == FlatChargesOR
                                || c.CostType.Name == BasicAmountIC
                                || c.CostType.Name == BasicAmountOR
                                || c.CostType.Name == FlatChargesICDetectionHospital
                                || c.CostType.Name == FlatChargesICReferraHospital);
            }
            catch (Exception ex)
            {
                const string message = "Select Financial Report Cost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Total Amount IC of given hospital during periode dateFrom and dateTo
        /// </summary>
        /// <param name="hospital">Hospital</param>
        /// <param name="dateFrom">date from</param>
        /// <param name="dateTo">date to</param>
        /// <param name="returnFraction">returns amount with decimal .00 if set to true or no decimal part if set to false</param>
        /// <returns>Amount of Total Amount IC costs in string format</returns>
        public String GetTotalICAmount(Hospital hospital, DateTime dateFrom, DateTime dateTo, bool returnFraction = true)
        {
            decimal totalAmount = 0;

            List<Donor> donors = GetDonors()
                .Where(d => d.ProcurementHospitalID == hospital.ID || d.ReferralHospitalID == hospital.ID || d.DetectionHospitalID == hospital.ID)
                .Where(d => !d.IsDeleted)
                .Where(d => d.RegisterDate != null && d.RegisterDate >= dateFrom)
                .Where(d => d.RegisterDate != null && d.RegisterDate <= dateTo)
                .ToList();

            foreach (Donor donor in donors)
            {
                List<DAL.Cost> costs = GetFinancialReportICCosts(hospital.ID, donor.ID).ToList();

                totalAmount += Convert.ToDecimal(costs.Sum(c => c.Amount));
            }

            return returnFraction
                       ? totalAmount.ToString("N2")
                       : totalAmount.ToString("N0");
        }

        /// <summary>
        ///     Returns Total Amount OR of given hospital during periode dateFrom and dateTo
        /// </summary>
        /// <param name="hospital">Hospital</param>
        /// <param name="dateFrom">date from</param>
        /// <param name="dateTo">date to</param>
        /// <param name="returnFraction">returns amount with decimal .00 if set to true or no decimal part if set to false</param>
        /// <returns>Amount of Total Amount OR costs in string format</returns>
        public String GetTotalORAmount(Hospital hospital, DateTime dateFrom, DateTime dateTo, bool returnFraction = true)
        {
            decimal totalAmount = 0;

            List<Donor> donors = GetDonors()
                .Where(d => d.ProcurementHospitalID == hospital.ID || d.ReferralHospitalID == hospital.ID || d.DetectionHospitalID == hospital.ID)
                .Where(d => !d.IsDeleted)
                .Where(d => d.RegisterDate != null && d.RegisterDate >= dateFrom)
                .Where(d => d.RegisterDate != null && d.RegisterDate <= dateTo)
                .ToList();

            foreach (Donor donor in donors)
            {
                List<DAL.Cost> costs = GetFinancialReportORCosts(hospital.ID, donor.ID).ToList();

                totalAmount += Convert.ToDecimal(costs.Sum(c => c.Amount));
            }

            return returnFraction
                       ? totalAmount.ToString("N2")
                       : totalAmount.ToString("N0");
        }

        /// <summary>
        ///     Returns Total Amount IC and OR of given hospital during periode dateFrom and dateTo
        /// </summary>
        /// <param name="hospital">Hospital</param>
        /// <param name="dateFrom">date from</param>
        /// <param name="dateTo">date to</param>
        /// <param name="returnFraction">returns amount with decimal .00 if set to true or no decimal part if set to false</param>
        /// <returns>Amount of Total Amount IC and OR costs in string format</returns>
        public String GetTotalICORAmount(Hospital hospital, DateTime dateFrom, DateTime dateTo, bool returnFraction = true)
        {
            decimal totalAmount = 0;

            List<Donor> donors = GetDonors()
                .Where(d => d.ProcurementHospitalID == hospital.ID || d.ReferralHospitalID == hospital.ID || d.DetectionHospitalID == hospital.ID)
                .Where(d => !d.IsDeleted)
                .Where(d => d.RegisterDate != null && d.RegisterDate >= dateFrom)
                .Where(d => d.RegisterDate != null && d.RegisterDate <= dateTo)
                .ToList();

            foreach (Donor donor in donors)
            {
                List<DAL.Cost> costs = GetFinancialReportCosts(hospital.ID, donor.ID).ToList();

                totalAmount += Convert.ToDecimal(costs.Sum(c => c.Amount));
            }

            return returnFraction
                       ? totalAmount.ToString("N2")
                       : totalAmount.ToString("N0");
        }

        /// <summary>
        ///     Returns IQueryable of IC Costs for financial report which are not deleted
        /// </summary>
        /// <remarks>
        /// Only costs of cost type Basic Amount IC, Flat charges IC, and Flat charges IC detection hospitals are returned
        /// </remarks>
        /// <returns>Cost Datarows</returns>
        public IQueryable<DAL.Cost> GetFinancialReportICCosts(int hospitalID, int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetCosts()
                    .Where(c => c.DonorID == donorID)
                    .Where(c => c.KreditorHospitalID == hospitalID)
                    .Where(c => c.CostType.Name == FlatChargesIC
                                || c.CostType.Name == BasicAmountIC
                                || c.CostType.Name == FlatChargesICDetectionHospital
                                || c.CostType.Name == FlatChargesICReferraHospital);
            }
            catch (Exception ex)
            {
                const string message = "Select Financial Report IC Cost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of Costs for financial report which are not deleted
        /// </summary>
        /// <remarks>
        /// Only costs of cost type Basic Amount IC, Basic Amount OR, Flat charges IC, Flat charges OR and Flat charges IC detection hospitals are returned
        /// </remarks>
        /// <returns>Cost Datarows</returns>
        public IQueryable<DAL.Cost> GetFinancialReportORCosts(int hospitalID, int donorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return GetCosts()
                    .Where(c => c.DonorID == donorID)
                    .Where(c => c.KreditorHospitalID == hospitalID)
                    .Where(c => c.CostType.Name == FlatChargesOR
                                || c.CostType.Name == BasicAmountOR);
            }
            catch (Exception ex)
            {
                const string message = "Select Financial Report OR Cost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Cost Datarow according to provided CostType ID
        /// </summary>
        /// <param name="costTypeID">CostType ID</param>
        /// <returns>CostGroup Datarow</returns>
        public DAL.CostGroup GetCostGroupByCostTypeID(int costTypeID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.CostGroup rowCostGroup;

            try
            {
                CostType ct = GetCostTypeByID(costTypeID);
                if (ct == null) return null;

                rowCostGroup = Data.CostGroup.SingleOrDefault(cg => cg.ID == ct.CostGroupID);
            }
            catch (Exception ex)
            {
                const string message = "Select CostGroup failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCostGroup;
        }

        /// <summary>
        ///     Checks if CostType ID is part of Transport CostGroup
        /// </summary>
        /// <param name="costTypeID">CostType ID</param>
        /// <returns>true if CostType ID is part of Transport CostGroup, else false </returns>
        public bool CostTypeIDisPartOfTransportCostGroup(int costTypeID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.CostGroup rowCostGroup;

            try
            {
                CostType ct = GetCostTypeByID(costTypeID);

                rowCostGroup = Data.CostGroup.SingleOrDefault(cg => cg.ID == ct.CostGroupID);
            }
            catch (Exception ex)
            {
                const string message = "Select CostGroup failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCostGroup != null && rowCostGroup.Name == "Transport";
        }

        /// <summary>
        ///     Returns CostType Datarow according to provided ID
        /// </summary>
        /// <param name="costTypeID">CostType ID</param>
        /// <returns>CostType Datarow</returns>
        public CostType GetCostTypeByID(int costTypeID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            CostType rowCostType;

            try
            {
                rowCostType = Data.CostType.SingleOrDefault(c => c.ID == costTypeID);
            }
            catch (Exception ex)
            {
                const string message = "Select CostType failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCostType;
        }

        /// <summary>
        ///     Returns Cost Datarow according to provided ID
        /// </summary>
        /// <param name="costID">Cost ID</param>
        /// <returns>Cost Datarow</returns>
        public DAL.Cost GetCostByID(int costID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.Cost rowCost;

            try
            {
                rowCost = GetCosts().SingleOrDefault(c => c.ID == costID);
            }
            catch (Exception ex)
            {
                const string message = "Select Cost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCost;
        }

        /// <summary>
        ///     Returns IQueryable of OrganCosts which are not deleted
        /// </summary>
        /// <returns>OrganCost Datarows</returns>
        public IQueryable<OrganCost> GetOrganCosts()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.OrganCost
                           .Where(oc => !oc.Cost.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select OrganCost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns IQueryable of OrganCosts of a specific cost ID which are not deleted
        /// </summary>
        /// <returns>OrganCost Datarows</returns>
        public IQueryable<OrganCost> GetOrganCostsByCostID(int costID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.OrganCost
                           .Where(oc => oc.CostID == costID)
                           .Where(oc => !oc.Cost.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select OrganCost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns OrganCost Datarow according to provided ID
        /// </summary>
        /// <param name="organCostID">OrganCost ID</param>
        /// <returns>OrganCost Datarow</returns>
        public OrganCost GetOrganCostByID(int organCostID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            OrganCost rowOrganCost;

            try
            {
                rowOrganCost = Data.OrganCost.SingleOrDefault(oc => oc.ID == organCostID);
            }
            catch (Exception ex)
            {
                const string message = "Select OrganCost failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowOrganCost;
        }

        /// <summary>
        ///     Returns OrganCostDistribution Datarow according to provided OrganID and CostDistributionID
        /// </summary>
        /// <param name="organID">Organ ID</param>
        /// <param name="costDistributionID">CostDistribution ID</param>
        /// <returns>OrganCostDistribution Datarow</returns>
        public OrganCostDistribution GetOrganCostDistributionByOrganIDAndCostDistributionID(int organID,
                                                                                            int costDistributionID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            OrganCostDistribution rowOrganCostDistribution;

            try
            {
                rowOrganCostDistribution = Data.OrganCostDistribution
                                               .Where(ocd => ocd.OrganID == organID)
                                               .SingleOrDefault(ocd => ocd.CostDistributionID == costDistributionID);
            }
            catch (Exception ex)
            {
                const string message = "Select OrganCostDistribution failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowOrganCostDistribution;
        }

        /// <summary>
        ///     Returns Total amount (converted in string) of costs allocated to organs
        /// </summary>
        /// <param name="c">Cost</param>
        /// <returns>Total amount of costs allocated to organs (converted to string)</returns>
        public string GetTotalOrganAllocatedCosts(DAL.Cost c)
        {
            Decimal totalOrganCostAmount = 0;
            foreach (OrganCost oc in c.OrganCost.Where(c2 => !c2.Cost.IsDeleted))
            {
                Decimal organCostAmount = 0;

                if (oc.Amount != null) organCostAmount = Convert.ToDecimal(oc.Amount);
                totalOrganCostAmount += organCostAmount;
            }

            return totalOrganCostAmount.ToString("N2");
        }

        /// <summary>
        ///     Returns Total amount of transport costs
        /// </summary>
        /// <param name="t">Transport</param>
        /// <returns>Total amount of transport costs (converted to string)</returns>
        public string GetTotalTransportCosts(DAL.Transport t)
        {
            Decimal totalAmount = 0;
            foreach (DAL.Cost c in t.Cost.Where(c => !c.IsDeleted))
            {
                Decimal transportAmount = 0;

                if (c.Amount != null) transportAmount = Convert.ToDecimal(c.Amount);
                totalAmount = totalAmount + transportAmount;
            }

            return totalAmount.ToString("N2");
        }
        #endregion

        #region Delay Methods
        /// <summary>
        ///     Returns IQueryable of Delays which are not deleted
        /// </summary>
        /// <returns>Delay Datarows</returns>
        public IQueryable<DAL.Delay> GetDelays()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Delay
                           .Where(d => !d.IsDeleted)
                           .Where(d => !d.Transport.IsDeleted)
                           .Where(d => !d.Transport.Donor.IsDeleted);
            }
            catch (Exception ex)
            {
                const string message = "Select Delay failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Delay Datarow according to provided ID
        /// </summary>
        /// <param name="delayID">Delay ID</param>
        /// <returns>Delay Datarow</returns>
        public DAL.Delay GetDelayByID(int delayID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            DAL.Delay rowDelay;

            try
            {
                rowDelay = GetDelays().SingleOrDefault(d => d.ID == delayID);
            }
            catch (Exception ex)
            {
                const string message = "Select Delay failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowDelay;
        }

        /// <summary>
        ///     Returns delays of a transport in a string, separated by a semicolon
        /// </summary>
        /// <param name="t">Transport item</param>
        /// <returns>string with transported organs and items to this transport item</returns>
        public string GetDelays(DAL.Transport t)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            String delays = String.Empty;

            try
            {
                foreach (DAL.Delay d in t.Delay.Where(d => !d.IsDeleted))
                {
                    delays += d.DelayReason.Reason + ", ";
                }
            }
            catch (Exception ex)
            {
                const string message = "Collecting transported organs and items failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return delays.Length > 1 ? delays.Substring(0, delays.Length - 2) : String.Empty;
        }

        /// <summary>
        ///     Returns total duration of delays of a transport in a formatted string (HH:mm)
        /// </summary>
        /// <param name="t">Transport item</param>
        /// <returns>string of total duration of delays to this transport</returns>
        public string GetDelayDuration(DAL.Transport t)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            TimeSpan? duration = null;
            DateTime? myDate;

            try
            {
                foreach (DAL.Delay d in t.Delay.Where(d => !d.IsDeleted))
                {
                    duration = duration == null ? d.Duration : duration + d.Duration;
                }

                if (duration == null) return String.Empty;

                TimeSpan myTimeSpan = TimeSpan.Parse(duration.ToString());
                myDate = new DateTime(myTimeSpan.Ticks);
            }
            catch (Exception ex)
            {
                const string message = "Collecting total duration of delays failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return String.Format("{0:HH:mm}", myDate);
        }

        /// <summary>
        ///     Returns true if a delay to this transport caused the organ loss
        /// </summary>
        /// <param name="t">Transport item</param>
        /// <returns>true when a single delay of this transport caused the organ loss</returns>
        public bool DelayCausedOrganLoss(DAL.Transport t)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            bool delayCausedOrganLoss = false;

            try
            {
                foreach (DAL.Delay d in t.Delay.Where(d => !d.IsDeleted))
                {
                    // if a single delay to this transport caused an organ loss, mark as true
                    if (d.IsOrganLost) delayCausedOrganLoss = true;
                }
            }
            catch (Exception ex)
            {
                const string message = "Collecting total duration of delays failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return delayCausedOrganLoss;
        }
        #endregion

        #region Creditor Methods
        /// <summary>
        ///     Returns IQueryable of Creditors
        /// </summary>
        /// <returns>Creditor Datarows</returns>
        public IQueryable<Creditor> GetCreditors()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Creditor.OrderBy(c => c.CreditorName);
            }
            catch (Exception ex)
            {
                const string message = "Select Creditor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Creditor Datarow according to provided ID
        /// </summary>
        /// <param name="creditorID">Creditor ID</param>
        /// <returns>Creditor Datarow</returns>
        public Creditor GetCreditorByID(int creditorID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Creditor rowCreditor;

            try
            {
                rowCreditor = GetCreditors().SingleOrDefault(c => c.ID == creditorID);
            }
            catch (Exception ex)
            {
                const string message = "Select Creditor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowCreditor;
        }

        #endregion

        #region Language Methods
        /// <summary>
        ///     Returns IQueryable of Language
        /// </summary>
        /// <returns>Language Datarows</returns>
        public IQueryable<Language> GetLanguages()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.Language;
            }
            catch (Exception ex)
            {
                const string message = "Select Language failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns Language Datarow according to provided ID
        /// </summary>
        /// <param name="languageID">Language ID</param>
        /// <returns>Language Datarow</returns>
        public Language GetLanguageByID(int languageID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            Language rowLanguage;

            try
            {
                rowLanguage = GetLanguages().SingleOrDefault(o => o.ID == languageID);
            }
            catch (Exception ex)
            {
                const string message = "Select Language failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowLanguage;
        }
        #endregion

        #region ReminderLetter Methods
        /// <summary>
        ///     Returns Reminder Letter Datarow according to provided LanguageID
        /// </summary>
        /// <param name="languageID">Language ID</param>
        /// <returns>Reminder Letter Datarow</returns>
        public ReminderLetter GetReminderLetterByLanguageID(int languageID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            ReminderLetter rowReminderLetter;

            try
            {
                rowReminderLetter = Data.ReminderLetter.SingleOrDefault(rl => rl.LanguageID == languageID);
            }
            catch (Exception ex)
            {
                const string message = "Select Reminder Letter failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowReminderLetter;
        }

        /// <summary>
        ///     Returns Reminder Letter Datarow according to provided LanguageID
        /// </summary>
        /// <param name="languageShort">Language short indication ("de", "fr" or "it")</param>
        /// <returns>Reminder Letter Datarow</returns>
        public ReminderLetter GetReminderLetterByLanguageShort(string languageShort)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            ReminderLetter rowReminderLetter;

            try
            {
                rowReminderLetter = Data.ReminderLetter.SingleOrDefault(rl => rl.Language.LanguageShort == languageShort);
            }
            catch (Exception ex)
            {
                const string message = "Select Reminder Letter failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowReminderLetter;
        }
        #endregion

        #region OrganToTransportItemAssociation Methods
        /// <summary>
        ///     Returns IQueryable of OrganToTransportItemAssociations
        /// </summary>
        /// <returns>OrganToTransportItemAssociation Datarows</returns>
        public IQueryable<OrganToTransportItemAssociation> GetOrganToTransportItemAssociations()
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            try
            {
                return Data.OrganToTransportItemAssociation.OrderBy(ot => ot.Organ.Name);
            }
            catch (Exception ex)
            {
                const string message = "Select OrganToTransportItemAssociation failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }
        }

        /// <summary>
        ///     Returns OrganToTransportItemAssociation Datarow according to provided ID
        /// </summary>
        /// <param name="organToTransportItemAssociationID">OrganToTransportItemAssociation ID</param>
        /// <returns>OrganToTransportItemAssociation Datarow</returns>
        public OrganToTransportItemAssociation GetOrganToTransportItemAssociationByID(int organToTransportItemAssociationID)
        {
            logger.Trace(MethodBase.GetCurrentMethod().Name + " started");

            OrganToTransportItemAssociation rowOrganToTransportItemAssociation;

            try
            {
                rowOrganToTransportItemAssociation = GetOrganToTransportItemAssociations().SingleOrDefault(ot => ot.ID == organToTransportItemAssociationID);
            }
            catch (Exception ex)
            {
                const string message = "Select Creditor failed! ";
                WriteErrorLog(ex, MethodBase.GetCurrentMethod().Name + " " + message);
                throw new Exception(MethodBase.GetCurrentMethod().Name + message, ex);
            }
            finally
            {
                logger.Trace(MethodBase.GetCurrentMethod().Name + " done");
            }

            return rowOrganToTransportItemAssociation;
        }
        #endregion

        #region Incidents
        /// <summary>
        ///     Returns IQueryable of IncidentCategories
        /// </summary>
        /// <returns>IncidentCategories Datarows</returns>
        public IQueryable<IncidentCategory> GetIncidentCategories()
        {
            return (new DataService<IncidentCategory>(Data)).GetAll().OrderBy(incCategory => incCategory.Position);
        }
        /// <summary>
        ///     Returns IQueryable of IncidentCategories
        /// </summary>
        /// <returns>IncidentCategories Datarows</returns>
        public IQueryable<IncidentCategory> GetIncidentCategories(int processId)
        {
            return (new DataService<IncidentCategory>(Data)).GetAll().Where(cat => cat.IncidentProcessToCategory.Count<IncidentProcessToCategory>(ptc => ptc.IncidentProcessID == processId) > 0).OrderBy(incCategory => incCategory.Position);
        }

        /// <summary>
        ///     Returns IQueryable of IncidentProcesses
        /// </summary>
        /// <returns>IncidentProcesses Datarows</returns>
        public IQueryable<IncidentProcess> GetIncidentProcesses()
        {
            return (new DataService<IncidentProcess>(Data)).GetAll().OrderBy(incProcess => incProcess.Position);
        }

        /// <summary>
        ///     Returns IQueryable of IncidentStates
        /// </summary>
        /// <returns>IncidentStates Datarows</returns>
        public IQueryable<IncidentState> GetIncidentStates()
        {
            return (new DataService<IncidentState>(Data)).GetAll().OrderBy(incState => incState.Position);
        }

        /// <summary>
        ///     Returns IQueryable of IncidentStates
        /// </summary>
        /// <returns>IncidentStates Datarows</returns>
        public IQueryable<Incident> GetIncident(DateTime from, DateTime to)
        {
            return (new DataService<Incident>(Data)).GetAll().Where(l=>l.CreationDate >= from && l.CreationDate<= to).OrderBy(i => i.IncidentNo);
        }


        #endregion

        /// <summary>
        /// Use for dropdownlist validate
        /// </summary>
        public void cvDropDownList_ServerValidate(object source, ServerValidateEventArgs args)
        {
            // Validate if something is selected in Dropdownlist
            args.IsValid = Convert.ToInt32(args.Value) > 0;
        }

        public void cvDate_ServerValidate(object source, ServerValidateEventArgs args)
        {
            DateTime d;
            args.IsValid = DateTime.TryParseExact(args.Value, "dd.MM.yyyy", CultureInfo.InvariantCulture,
                                                  DateTimeStyles.None, out d);
        }

        /// <summary>
        /// Selects row in DataGrid with given ID
        /// </summary>
        public static bool SelectRowInGridView(GridView gridView, int ID)
        {
            gridView.DataBind();
            for (gridView.PageIndex = 0; gridView.PageIndex < gridView.PageCount; gridView.PageIndex++)
            {
                gridView.DataBind();
                for (int i = 0; i < gridView.Rows.Count; i++)
                {
                    var dataKey = gridView.DataKeys[i];
                    if (dataKey == null || ID != Convert.ToInt32(dataKey.Value)) continue;

                    gridView.SelectRow(i);
                    return true;
                }
            }
            gridView.SelectedIndex = -1;
            gridView.PageIndex = 0;
            return false;
        }

        /// <summary>
        /// Selects row in DataGrid with given nullable ID
        /// </summary>
        public static bool SelectRowInGridView(GridView gridView, int? ID)
        {
            if (ID == null)
            {
                return false;
            }
            else
            {
                return SelectRowInGridView(gridView, (int)ID);
            }
        }



        /// <summary>
        /// Enables or disables controls recursively inside given control
        /// </summary>
        /// <param name="control">Control</param>
        /// <param name="doEnable">enable or disable? true=enable, false=disable</param>
        public static void EnableOrDisableControls(Control control, bool doEnable)
        {
            EnableOrDisableControls(control, doEnable, new List<string>());
        }
        /// <summary>
        /// Enables or disables controls recursively inside given control
        /// </summary>
        /// <param name="control">Control</param>
        /// <param name="doEnable">enable or disable? true=enable, false=disable</param>
        public static void EnableOrDisableControls(Control control, bool doEnable, List<string> excludedControls)
        {
            // Static methode für alle?
            foreach (Control pnlControl in control.Controls)
            {
                if (!excludedControls.Contains(pnlControl.ID))
                {
                    bool enableChildControls = true;
                    if (pnlControl is TextBox)
                    {
                        ((TextBox)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is Button)
                    {
                        ((Button)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is RadioButtonList)
                    {
                        ((RadioButtonList)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is ImageButton)
                    {
                        ((ImageButton)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is CheckBox)
                    {
                        ((CheckBox)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is DropDownList)
                    {
                        ((DropDownList)pnlControl).Enabled = doEnable;
                    }
                    else if (pnlControl is HyperLink)
                    {
                        ((HyperLink)pnlControl).Enabled = doEnable;
                    }
                    // User Controls
                    else if (pnlControl is ucIncident)
                    {
                        ((ucIncident)pnlControl).AllowEnable = doEnable;
                        ((ucIncident)pnlControl).Enabled = doEnable;
                        enableChildControls = false;
                    }
                    else if (pnlControl is ucIncidentDocuments)
                    {
                        ((ucIncidentDocuments)pnlControl).Enabled = doEnable;
                        enableChildControls = false;
                    }
                    else if (pnlControl is ucIncidentDonor)
                    {
                        ((ucIncidentDonor)pnlControl).Enabled = doEnable;
                        enableChildControls = false;
                    }

                    if (pnlControl.HasControls() && enableChildControls)
                    {
                        EnableOrDisableControls(pnlControl, doEnable, excludedControls);
                    }
                }
            }
        }

        /// <summary>
        /// Set Oncklick Event on row-click
        /// </summary>
        public void gridView_RowDataBound(object sender, GridViewRowEventArgs e)
        {
            // Set Oncklick Event on row-click
            if (e.Row.RowType == DataControlRowType.DataRow)
            {
                e.Row.Attributes["onclick"] = ClientScript.GetPostBackClientHyperlink((GridView)sender, "Select$" + e.Row.RowIndex);
            }
        }


        /// <summary>
        /// Get contenttype from file extension
        /// </summary>
        internal static string GetContentType(string extension)
        {
            String contenttype = String.Empty;

            switch (extension.ToLower())
            {
                case ".doc":
                case ".docx":
                    contenttype = "application/vnd.ms-word";
                    break;
                case ".xls":
                case ".xlsx":
                case ".xlsm":
                    contenttype = "application/vnd.ms-excel";
                    break;
                case ".jpg":
                case ".jpeg":
                case ".jpe":
                    contenttype = "image/jpg";
                    break;
                case ".png":
                    contenttype = "image/png";
                    break;
                case ".gif":
                    contenttype = "image/gif";
                    break;
                case ".pdf":
                    contenttype = "application/pdf";
                    break;
                case ".tif":
                case ".tiff":
                    contenttype = "image/tiff";
                    break;
                case ".zip":
                    contenttype = "application/zip";
                    break;
                case ".msg":
                    contenttype = "application/octet-stream";
                    break;
                default:
                    contenttype = String.Empty;
                    break;
            }
            return contenttype;
        }

        /// <summary>
        /// Returns a formated DateTime object out of two textboxes (date & time)
        /// </summary>
        internal DateTime? FormatDateTime(TextBox txtDate, TextBox txtTime)
        {
            DateTime myDateTime;

            if (!String.IsNullOrWhiteSpace(txtDate.Text) && !String.IsNullOrWhiteSpace(txtTime.Text))
            {
                myDateTime = Convert.ToDateTime(txtDate.Text + " " + txtTime.Text);
                return Convert.ToDateTime(String.Format("{0:dd.MM.yyyy HH:mm}", myDateTime));
            }

            if (!String.IsNullOrWhiteSpace(txtDate.Text))
            {
                myDateTime = Convert.ToDateTime(txtDate.Text);
                return Convert.ToDateTime(String.Format("{0:dd.MM.yyyy}", Convert.ToDateTime(myDateTime)));
            }

            // If no Date was entered, set Today as default date
            if (!String.IsNullOrWhiteSpace(txtTime.Text))
            {
                String today = String.Format("{0:dd.MM.yyyy}", DateTime.Today);
                myDateTime = Convert.ToDateTime(today + " " + txtTime.Text);
                return Convert.ToDateTime(String.Format("{0:dd.MM.yyyy HH:mm}", myDateTime));
            }

            // If both texboxes are empty return null
            return null;
        }

        #region LabelToolTip
        /// <summary>
        /// Lazy loading Lexicon
        /// </summary>
        private List<DAL.IncidentLexicon> _Lexicons;
        public List<DAL.IncidentLexicon> Lexicons
        {
            get
            {
                if (_Lexicons == null)
                {
                    _Lexicons = new DataService<DAL.IncidentLexicon>(Data).GetAll().Where(t => t.InfoDescription != null && t.InfoDescription != String.Empty).ToList();
                }
                return _Lexicons;
            }
        }

        /// <summary>
        /// Setting the ToolTipps for all Page Controls
        /// </summary>
        public void SetToolTipps()
        {
            foreach (Control control in Page.Controls)
            {
                SetToolTipps(control);
            }
        }

        /// <summary>
        /// Setting the ToolTipps for given Controls
        /// </summary>
        public void SetToolTipps(Control control)
        {
            if (control is Label)
            {
                Label label = (Label)control;
                if (Lexicons.Any(il => il.Definition == label.Text.Replace("* ", String.Empty)))
                {
                    ((Label)control).ToolTip = Lexicons.Find(il => il.Definition == label.Text.Replace("* ", String.Empty)).InfoDescription;
                    ((Label)control).Text = "<img src=\"images/info.png\"> " + ((Label)control).Text;
                }
            }

            if (control.HasControls())
            {
                foreach (Control child in control.Controls)
                {
                    SetToolTipps(child);
                }
            }
        }
        #endregion


        public void SendMail(string subject, string body, string toAddress)
        {
            SendMail(subject, body, toAddress, String.Empty);
        }

        /// <summary>
        /// Sends a mail with the given parameters
        /// </summary>
        public void SendMail(string subject, string body, string toAddress, string replyTo)
        {
            System.Net.ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;
            if (toAddress != string.Empty)
            {
                using (MailMessage mailMessage = new MailMessage())
                {
                    mailMessage.From = new MailAddress(ConfigurationManager.AppSettings["smtpSender"]);
                    mailMessage.Subject = subject;
                    mailMessage.Body = body;
                    mailMessage.IsBodyHtml = true;
                    if (replyTo != String.Empty)
                    {
                        foreach (string mailAddress in replyTo.Split(','))
                        {
                            mailMessage.ReplyToList.Add(new MailAddress(mailAddress));
                        }
                    }
                    foreach (string mailAddress in toAddress.Split(','))
                    {
                        mailMessage.To.Add(new MailAddress(mailAddress));
                    }
                    SmtpClient smtp = new SmtpClient();
                    smtp.Host = ConfigurationManager.AppSettings["smtpHost"];
                    smtp.Port = 587;
                    smtp.UseDefaultCredentials = false;
                    smtp.EnableSsl = true;

                    NetworkCredential basicCredential = new NetworkCredential(ConfigurationManager.AppSettings["smtpUser"], ConfigurationManager.AppSettings["smtpPassword"]);
                    smtp.Credentials = basicCredential;
                    smtp.Send(mailMessage);
                }
            }
            else
            {
                throw new Exception("To Address not definied");
            }
        }

        /// <summary>
        /// Creates Creating E-Mail to Incident Admins and Creator
        /// </summary>
        internal List<String> SendMail(Incident incident)
        {
            logger.Debug("Sending mail to incident no" + incident.ID.ToString());
            List<String> retVal = new List<string>();

            string incidentAdminMail = ConfigurationManager.AppSettings["incidentAdminMail"];
            if (incidentAdminMail == string.Empty)
            {
                throw new Exception("No Incident Admin Mail declared");
            }

            // Get Mails
            IQueryable<IncidentMail> mails = from incMail in Data.IncidentMail
                                             where incMail.IncidentStateID == incident.IncidentStateID
                                             select incMail;

            foreach (IncidentMail mail in mails)
            {
                if (mail.blnEditBefore)
                {
                    retVal.Add(String.Format("MailSend.aspx?IncidentId={0}&IncidentMailId={1}", incident.ID, mail.ID));
                }
                else
                {
                    SendMail(
                        mail.Subject,
                        mail.BodyText.Replace("{IncidentNumber}", incident.IncidentNo.ToString()),
                        mail.To.Replace("{Creator}", incident.CreatorEmail).Replace("{Admin}", incidentAdminMail),
                        mail.ReplyTo.Replace("{Creator}", incident.CreatorEmail).Replace("{Admin}", incidentAdminMail)
                        );
                }
            }
            return retVal;
        }

        // Nested E-Mail Class
        private class coordMail
        {
            public string FirstName { get; set; }
            public string LastName { get; set; }
            public string Email { get; set; }
        }
    }
}