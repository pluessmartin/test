using Pentag.Jacie.PdfCreator;
using Pentag.SLIDS.DAL;
using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Web;

namespace Pentag.SLIDS.Common
{
    public class Document
    {
        private class TransportDocFields
        {
            public const string Organ_Blood = "Organ_Blood";
            public const string Organ_Blood_Text = "Organ_Blood_Text";
            public const string Organs = "Organs";
            public const string DonorNo = "DonorNo";
            public const string NC = "NC";
            public const string ProcurementDate = "ProcurementDate";
            public const string ProcurementHospital = "ProcurementHospital";
            public const string Departure = "Departure";
            public const string Vehicle = "Vehicle";
            public const string FlightNo = "FlightNo";
            public const string AirwayCompany = "AirwayCompany";
            //public const string GraftboxYes = "GraftboxYes";
            //public const string SWTGraftboxNumber = "SWTGraftboxNumber";
            //public const string PerfusionMachineYes = "PerfusionMachineYes";
            //public const string PerfusionMachinNumber = "PerfusionMachinNumber";
            public const string BoxName = "BoxText";
            public const string BoxNumber = "BoxNumber";
            public const string TC = "TC";
            public const string Address1 = "Address1";
            public const string Address2 = "Address2";
            public const string Address3 = "Address3";
            public const string Address4 = "Address4";
            public const string City = "City";

        }

        public static byte[] CreateDeliverySlip(int transportID)
        {
            using (Entities ctx = new Entities())
            {
                List<Dictionary<string, DictionaryValue>> dicts = new List<Dictionary<string, DictionaryValue>>();
                DAL.Transport transport = ctx.Transport.FirstOrDefault(t => t.ID == transportID);
                if (transport != null)
                {
                    string ncName = transport.Donor.Coordinator1 == null
                                        ? String.Empty
                                        : transport.Donor.Coordinator1.Address == null
                                              ? transport.Donor.Coordinator1.FirstName + " " + transport.Donor.Coordinator1.LastName
                                              : transport.Donor.Coordinator1.FirstName + " " + transport.Donor.Coordinator1.LastName + " / " +
                                                transport.Donor.Coordinator1.Address.Phone;

                    string procDate = transport.Donor.ProcurementDate == null ? string.Empty : ((DateTime)transport.Donor.ProcurementDate).ToString("dd.MM.yyyy");
                    Dictionary<string, DictionaryValue> fields;

                    foreach (TransportedOrgan transportOrgan in transport.TransportedOrgan)
                    {
                        TransplantOrgan tOrgan = transportOrgan.TransplantOrgan;

                        fields = new Dictionary<string, DictionaryValue>();
                        fields.Add(TransportDocFields.Organ_Blood, new DictionaryValue() { Text = "ORGAN", ReadProtected = false });
                        fields.Add(TransportDocFields.Organ_Blood_Text, new DictionaryValue() { Text = tOrgan.Organ.Name, ReadProtected = false });
                        fields.Add(TransportDocFields.Organs, new DictionaryValue() { Text = "", ReadProtected = false });
                        fields.Add(TransportDocFields.DonorNo, new DictionaryValue() { Text = transport.Donor.DonorNumber, ReadProtected = false });
                        fields.Add(TransportDocFields.NC, new DictionaryValue() { Text = ncName, ReadProtected = true });
                        fields.Add(TransportDocFields.ProcurementDate, new DictionaryValue() { Text = procDate, ReadProtected = false });
                        fields.Add(TransportDocFields.ProcurementHospital, new DictionaryValue() { Text = transport.Donor.Hospital1.Display, ReadProtected = false });
                        string departure = transport.Departure == null ? string.Empty : ((DateTime)transport.Departure).ToString("dd.MM.yyyy");
                        fields.Add(TransportDocFields.Departure, new DictionaryValue() { Text = departure, ReadProtected = false });
                        fields.Add(TransportDocFields.Vehicle, new DictionaryValue() { Text = transport.Vehicle == null ? String.Empty : transport.Vehicle.Name, ReadProtected = false });
                        fields.Add(TransportDocFields.FlightNo, new DictionaryValue() { Text = transport.FlightNumber, ReadProtected = false });
                        fields.Add(TransportDocFields.AirwayCompany, new DictionaryValue() { Text = transport.Provider, ReadProtected = false });
                        PerfusionMachineFields(fields, tOrgan);

                        if (tOrgan.Coordinator != null)
                        {
                            string tcName;
                            if (tOrgan.Coordinator.Address != null)
                            {
                                tcName = tOrgan.Coordinator.FirstName + " " + tOrgan.Coordinator.LastName + " / " + tOrgan.Coordinator.Address.Phone;
                                fields.Add(TransportDocFields.Address1, new DictionaryValue() { Text = tOrgan.Coordinator.Address.Address1.ToUpper(), ReadProtected = false });
                                fields.Add(TransportDocFields.Address2, new DictionaryValue() { Text = tOrgan.Coordinator.Address.Address2, ReadProtected = false });
                                fields.Add(TransportDocFields.Address3, new DictionaryValue() { Text = tOrgan.Coordinator.Address.Address3, ReadProtected = false });
                                fields.Add(TransportDocFields.Address4, new DictionaryValue() { Text = tOrgan.Coordinator.Address.Address4, ReadProtected = false });
                                fields.Add(TransportDocFields.City, new DictionaryValue() { Text = tOrgan.Coordinator.Address.Zip + " " + tOrgan.Coordinator.Address.City, ReadProtected = false });
                            }
                            else
                            { // no Coordinator Address -> FO use Hospital Address
                                tcName = tOrgan.Coordinator.FirstName + " " + tOrgan.Coordinator.LastName + " / " + tOrgan.Hospital1.Address1.Phone;
                                fields.Add(TransportDocFields.Address1, new DictionaryValue() { Text = tOrgan.Hospital1.Name, ReadProtected = false });
                                fields.Add(TransportDocFields.Address2, new DictionaryValue() { Text = tOrgan.Hospital1.Address1.Address1, ReadProtected = false });
                                fields.Add(TransportDocFields.Address3, new DictionaryValue() { Text = tOrgan.Hospital1.Address1.Address2, ReadProtected = false });
                                fields.Add(TransportDocFields.Address4, new DictionaryValue() { Text = tOrgan.Hospital1.Address1.Address3 + " " + tOrgan.Hospital1.Address1.Address4, ReadProtected = false });
                                fields.Add(TransportDocFields.City, new DictionaryValue() { Text = tOrgan.Hospital1.Address1.Zip + " " + tOrgan.Hospital1.Address1.City, ReadProtected = false });
                            }
                            fields.Add(TransportDocFields.TC, new DictionaryValue() { Text = tcName, ReadProtected = false });
                        }
                        dicts.Add(fields);
                    }
                    foreach (TransportItem tItem in transport.TransportItem)
                    {
                        fields = new Dictionary<string, DictionaryValue>();
                        fields.Add(TransportDocFields.Organ_Blood, new DictionaryValue() { Text = "", ReadProtected = false });
                        fields.Add(TransportDocFields.Organ_Blood_Text, new DictionaryValue() { Text = "", ReadProtected = false });
                        fields.Add(TransportDocFields.Organs, new DictionaryValue() { Text = tItem.Name, ReadProtected = false });
                        fields.Add(TransportDocFields.DonorNo, new DictionaryValue() { Text = transport.Donor.DonorNumber, ReadProtected = false });
                        fields.Add(TransportDocFields.NC, new DictionaryValue() { Text = ncName, ReadProtected = true });
                        fields.Add(TransportDocFields.ProcurementDate, new DictionaryValue() { Text = procDate, ReadProtected = false });
                        if (transport.Donor.Hospital1 != null)
                        {
                            fields.Add(TransportDocFields.ProcurementHospital, new DictionaryValue() { Text = transport.Donor.Hospital1.Display, ReadProtected = false });
                        }
                        else
                        {
                            throw new Exception("Procurement Hospital on Donor is empty.");
                        }
                        string departure = transport.Departure == null ? string.Empty : ((DateTime)transport.Departure).ToString("dd.MM.yyyy");
                        fields.Add(TransportDocFields.Departure, new DictionaryValue() { Text = departure, ReadProtected = false });
                        fields.Add(TransportDocFields.Vehicle, new DictionaryValue() { Text = transport.Vehicle == null ? String.Empty : transport.Vehicle.Name, ReadProtected = false });
                        fields.Add(TransportDocFields.FlightNo, new DictionaryValue() { Text = transport.FlightNumber, ReadProtected = false });
                        fields.Add(TransportDocFields.AirwayCompany, new DictionaryValue() { Text = transport.Provider, ReadProtected = false });
                        fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "", ReadProtected = false });
                        fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = "", ReadProtected = false });
                        if (transport.Hospital1 != null && transport.Hospital1.Address != null)
                        {
                            fields.Add(TransportDocFields.Address1, new DictionaryValue() { Text = transport.Hospital1.Address1.Address1.ToUpper(), ReadProtected = false });
                            fields.Add(TransportDocFields.Address2, new DictionaryValue() { Text = transport.Hospital1.Address1.Address2, ReadProtected = false });
                            fields.Add(TransportDocFields.Address3, new DictionaryValue() { Text = transport.Hospital1.Address1.Address3, ReadProtected = false });
                            fields.Add(TransportDocFields.Address4, new DictionaryValue() { Text = transport.Hospital1.Address1.Address4, ReadProtected = false });
                            fields.Add(TransportDocFields.City, new DictionaryValue() { Text = transport.Hospital1.Address1.Zip + " " + transport.Hospital1.Address1.City, ReadProtected = false });
                        }
                        else
                        {
                            fields.Add(TransportDocFields.Address1, new DictionaryValue() { Text = "", ReadProtected = false });
                            fields.Add(TransportDocFields.Address2, new DictionaryValue() { Text = transport.OtherDestination, ReadProtected = false });
                            fields.Add(TransportDocFields.Address3, new DictionaryValue() { Text = "", ReadProtected = false });
                            fields.Add(TransportDocFields.Address4, new DictionaryValue() { Text = "", ReadProtected = false });
                            fields.Add(TransportDocFields.City, new DictionaryValue() { Text = "", ReadProtected = false });
                        }

                        string tcName = "";

                        // Set TC details in document if TC of associated organ is at Destination Hospital
                        foreach (OrganToTransportItemAssociation organToTransportItemAssociation in tItem.OrganToTransportItemAssociation.Where(ot => ot.OrganID != null))
                        {
                            int organID = Convert.ToInt32(organToTransportItemAssociation.OrganID);
                            TransplantOrgan tOrgan = organToTransportItemAssociation.Organ.TransplantOrgan
                                                                                    .Where(to => to.OrganID == organID && !to.IsDeleted)
                                                                                    .SingleOrDefault(to => to.DonorID == transport.DonorID);

                            if (tOrgan == null || tOrgan.Coordinator == null || transport.Hospital1 == null) continue;

                            if (tOrgan.Coordinator.HospitalID != transport.Hospital1.ID) continue;

                            // set phone details. If Address of Coordinator is null then use address of FO Hospital (in this case it's an FO hospital per se)
                            string phone = tOrgan.Coordinator.Address != null ? tOrgan.Coordinator.Address.Phone : tOrgan.Hospital1.Address1.Phone;

                            tcName = tOrgan.Coordinator.FirstName + " " + tOrgan.Coordinator.LastName + " / " + phone;
                            break; // leave foreach loop once details of a coordinator could be found.
                        }
                        fields.Add(TransportDocFields.TC, new DictionaryValue() { Text = tcName, ReadProtected = false });
                        dicts.Add(fields);
                    }
                }
                PdfGeneratorTextFieldDynamicProtected creator = new PdfGeneratorTextFieldDynamicProtected();
                byte[] template = File.ReadAllBytes(Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "resources\\TransportForm.pdf"));

                return creator.Generate(template, dicts);
            }
        }

        private static void PerfusionMachineFields(Dictionary<string, DictionaryValue> fields, TransplantOrgan tOrgan)
        {
            bool fieldsFilled = false;
            if (tOrgan.GraftBoxNo != null
                || tOrgan.Organ.Name.ToLower().Contains("kidney")
                || tOrgan.Organ.Name.ToLower().Contains("lung")
                )
            {

                if (tOrgan.Organ.Name.ToLower().Contains("lung"))
                {
                    fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "Perfusion Machine Ex Vivo", ReadProtected = false });
                    fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = "", ReadProtected = false });
                    fieldsFilled = true;
                }
                else
                {
                    if ((bool)tOrgan.PrefusionMachine)
                    {
                        fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "Perfusion Machine", ReadProtected = false });
                        var pm = String.IsNullOrEmpty(tOrgan.PrefusionMachineNumber) ? "" : tOrgan.PrefusionMachineNumber;
                        fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = pm, ReadProtected = false });
                        fieldsFilled = true;
                    }
                    else if (!String.IsNullOrEmpty(tOrgan.GraftBoxNo.ToString()))
                    {
                        fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "Graftbox", ReadProtected = false });
                        fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = tOrgan.GraftBoxNo.ToString(), ReadProtected = false });
                        fieldsFilled = true;
                    }
                }
            }

            if (!fieldsFilled)
            {
                fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "", ReadProtected = false });
                fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = "", ReadProtected = false });
            }
        }

        public static byte[] CreateDeliverySlipBlank()
        {
            using (Entities ctx = new Entities())
            {
                List<Dictionary<string, DictionaryValue>> dicts = new List<Dictionary<string, DictionaryValue>>();
                Dictionary<string, DictionaryValue> fields;

                fields = new Dictionary<string, DictionaryValue>();
                fields.Add(TransportDocFields.Organ_Blood, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Organ_Blood_Text, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Organs, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.DonorNo, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.NC, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.ProcurementDate, new DictionaryValue() { Text = "", ReadProtected = true });

                fields.Add(TransportDocFields.ProcurementHospital, new DictionaryValue() { Text = "", ReadProtected = true });

                fields.Add(TransportDocFields.Departure, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Vehicle, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.FlightNo, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.AirwayCompany, new DictionaryValue() { Text = "", ReadProtected = true });
                /*fields.Add(TransportDocFields.GraftboxYes, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.SWTGraftboxNumber, new DictionaryValue() { Text = "", ReadProtected = true });

                fields.Add(TransportDocFields.PerfusionMachineYes, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.PerfusionMachinNumber, new DictionaryValue() { Text = "", ReadProtected = true });*/
                fields.Add(TransportDocFields.BoxName, new DictionaryValue() { Text = "", ReadProtected = false });
                fields.Add(TransportDocFields.BoxNumber, new DictionaryValue() { Text = "", ReadProtected = false });

                fields.Add(TransportDocFields.Address1, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Address2, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Address3, new DictionaryValue() { Text = "", ReadProtected = true });
                fields.Add(TransportDocFields.Address4, new DictionaryValue() { Text = "", ReadProtected = true }); ;
                fields.Add(TransportDocFields.City, new DictionaryValue() { Text = "", ReadProtected = true });

                fields.Add(TransportDocFields.TC, new DictionaryValue() { Text = "", ReadProtected = true });
                dicts.Add(fields);

                PdfGeneratorTextFieldDynamicProtected creator = new PdfGeneratorTextFieldDynamicProtected();
                byte[] template = File.ReadAllBytes(Path.Combine(HttpContext.Current.Request.PhysicalApplicationPath, "resources\\Transportform.pdf"));

                return creator.Generate(template, dicts);
            }
        }
    }
}