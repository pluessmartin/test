<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Transport.aspx.cs" Inherits="Pentag.SLIDS.Transport" %>

<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Transports List -->
    <asp:UpdatePanel ID="TransportOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransport" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnDelete" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewTransport" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlTransport" GroupingText="Donor Transports" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvTransport" runat="server" ItemType="Pentag.SLIDS.DAL.Transport" SelectMethod="gvTransport_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvTransport_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true" EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Transported Organs">
                            <ItemTemplate><%# GetTransportedElements(Item)%></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Departed from">
                            <ItemTemplate><%# Item.DepartureHospitalID != null ? Item.Hospital.Display : Item.OtherDeparture ?? String.Empty  %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Departed" SortExpression="Departure">
                            <ItemTemplate><%# Item.Departure != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Departure) : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Destination">
                            <ItemTemplate><%# Item.DestinationHospitalID != null ? Item.Hospital1.Display : Item.OtherDestination ?? String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Arrived" SortExpression="Arrival">
                            <ItemTemplate><%# Item.Arrival != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Arrival) : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Vehicle">
                            <ItemTemplate><%# Item.VehicleID != null ? Item.Vehicle.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Operations Center">
                            <ItemTemplate><%# Item.OperationCenterID != null ? Item.OperationCenter.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Doc">
                            <ItemTemplate>
                                <a href="<%# String.Format("ViewPDF.aspx?tID={0}", Item.ID) %>" target="_blank">
                                    <img alt="down" src="resources/file_download.png" /></a>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>


    <table style="width: 100%">
        <tr>
            <td>
                <asp:Button ID="btnAddNewTransport" runat="server" Text="Add New..." OnClick="btnAddNewTransport_Click" CausesValidation="false" CssClass="addNewButton btn btn-default" />

            </td>
            <td>
                <a class="addNewButton btn btn-default" href="ViewPDF.aspx?tID=-1" target="_blank">Blank Doc</a>
            </td>
            <td class="alignRight">
                <asp:Button ID="btnIncidentCreate" Text="Register Incident" CssClass="largeButton btn btn-default" AccessKey="I" runat="server" OnClick="btnIncidentCreate_Click" />
            </td>





        </tr>
    </table>

    <asp:UpdatePanel ID="TransportDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransport" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidTransportID" Value="0" runat="server" />
            <asp:Panel ID="pnlTransportDetails" GroupingText="Transport details" Visible="false" CssClass="slidsPanel" runat="server">
                <table id="tblTransportDetails" runat="server">
                    <tr>
                        <td colspan="4">
                            <table>
                                <tr>
                                    <td>
                                        <asp:Label ID="lblOperationCenter" Text="Operation Center" runat="server" /></td>
                                    <td>
                                        <asp:DropDownList ID="ddlOperationCenter" CssClass="defaultDropDownList" runat="server" /></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:CustomValidator ID="cvTransportElements" OnServerValidate="cvTransportElements_ServerValidate" ErrorMessage="Please select at least an organ or a related element" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2" style="vertical-align: top">
                            <asp:Panel ID="pnlTransportedOrgans" GroupingText="Organs" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top">
                                            <asp:Repeater ID="repTransplantOrgans" ItemType="Pentag.SLIDS.DAL.TransplantOrgan" runat="server">
                                                <ItemTemplate>
                                                    <div style="float: left;">
                                                        <asp:CheckBox ID="cbTransplantOrgan" Text='<%# Item.Organ.Name %>' AutoPostBack="true" OnCheckedChanged="cbTransportElement_CheckedChanged" runat="server" />
                                                        <asp:HiddenField ID="hidTransplantOrganID" Value='<%# Item.ID %>' runat="server" />
                                                    </div>
                                                      <div style="float: right; padding-left: 20Px;">
                                                        <asp:Label ID="lblTransplantOrgan" Text="<%#Item.PrefusionMachineNumber  %>" runat="server" />
                                                    </div>
                                                    <div style="clear: both;"></div>
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                        <td colspan="2">
                            <asp:Panel ID="pnlTransportedItems" GroupingText="Related elements" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top">
                                            <asp:Repeater ID="repTransportItems" ItemType="Pentag.SLIDS.DAL.TransportItem" runat="server">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="cbTransportItem" Text='<%# Item.Name %>' AutoPostBack="true" OnCheckedChanged="cbTransportElement_CheckedChanged" runat="server" />
                                                    <asp:HiddenField ID="hidTransportItemID" Value='<%# Item.ID %>' runat="server" />
                                                    <br />
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                      
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:Panel ID="pnlTravel" GroupingText="Travel" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td colspan="2">
                                            <asp:Panel ID="pnlDeparture" GroupingText="Departure" CssClass="slidsPanel" runat="server">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblDepartureHospital" Text="(*)Departure Hospital" runat="server" /></td>
                                                        <td>
                                                            <asp:DropDownList ID="ddlDepartureHospital" OnSelectedIndexChanged="ddlDepartureOrDestinationHospital_SelectedIndexChanged" AutoPostBack="true" CssClass="defaultDropDownList" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblOtherDeparture" Text="(*)Other departure" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtOtherDeparture" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <asp:CustomValidator ID="cvDeparture" OnServerValidate="cvDeparture_ServerValidate" ErrorMessage="Please choose or enter one departure location!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblDepartureDate" Text="Departure date" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtDepartureDate" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="true" OnTextChanged="txtDepartureDate_TextChanged" runat="server" />
                                                            <ajaxToolkit:CalendarExtender ID="ceDepartureDateTime" Format="dd.MM.yyyy" TargetControlID="txtDepartureDate" runat="server" />
                                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weDepartureDateTime" runat="server" TargetControlID="txtDepartureDate" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblDepartureTime" Text="Departure time" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtDepartureTime" CssClass="tinyInputTextBox" MaxLength="5" runat="server" />
                                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weDepartureTime" runat="server" TargetControlID="txtDepartureTime" WatermarkCssClass="tinyWatermarked" WatermarkText="hh:mm" />
                                                            <ajaxToolkit:MaskedEditExtender ID="meeDepartureTime" TargetControlID="txtDepartureTime" Mask="99:99" MaskType="Time" AcceptAMPM="false" InputDirection="LeftToRight" runat="server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <asp:CustomValidator ID="cvDepartureDateTime" ControlToValidate="txtDepartureDate" OnServerValidate="cvDate_ServerValidate" ErrorMessage="Please enter correct date and time format!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                        <td colspan="2">
                                            <asp:Panel ID="pnlArrival" GroupingText="Destination" CssClass="slidsPanel" runat="server">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblDestinationHospital" Text="(*)Destination Hospital" runat="server" /></td>
                                                        <td>
                                                            <asp:DropDownList ID="ddlDestinationHospital" OnSelectedIndexChanged="ddlDepartureOrDestinationHospital_SelectedIndexChanged" AutoPostBack="true" CssClass="defaultDropDownList" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblOtherDestination" Text="(*)Other destination" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtOtherDestination" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <asp:CustomValidator ID="cvDestination" OnServerValidate="cvDestination_ServerValidate" ErrorMessage="Please choose or enter one destination location!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblArrivalDate" Text="Arrival date" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtArrivalDate" CssClass="smallInputTextBox" MaxLength="10" runat="server" />
                                                            <ajaxToolkit:CalendarExtender ID="ceArrivalDateTime" Format="dd.MM.yyyy" TargetControlID="txtArrivalDate" runat="server" />
                                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weArrivalDateTime" runat="server" TargetControlID="txtArrivalDate" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblArrivalTime" Text="Arrival time" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtArrivalTime" CssClass="tinyInputTextBox" MaxLength="5" runat="server" />
                                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weArrivalTime" runat="server" TargetControlID="txtArrivalTime" WatermarkCssClass="tinyWatermarked" WatermarkText="hh:mm" />
                                                            <ajaxToolkit:MaskedEditExtender ID="meeArrivalTime" TargetControlID="txtArrivalTime" Mask="99:99" MaskType="Time" AcceptAMPM="false" InputDirection="LeftToRight" runat="server" />
                                                        </td>
                                                    </tr>
                                                    <tr>
                                                        <td colspan="2">
                                                            <asp:CustomValidator ID="cvArrivalDateTime" ControlToValidate="txtArrivalDate" OnServerValidate="cvDate_ServerValidate" ErrorMessage="Please enter correct date and time format!" ForeColor="Red" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                                                        </td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblDistance" Text="Distance (km)" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtDistance" CssClass="smallInputTextBox" runat="server" /></td>
                                        <td colspan="2"></td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:CompareValidator ID="cvDistance" ControlToValidate="txtDistance" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Distance value can only be numeric!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:Panel ID="pnlTransportation" GroupingText="Transportation" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblVehicle" Text="Vehicle" CssClass="defaultLabel" runat="server" /></td>
                                        <td>
                                            <asp:DropDownList ID="ddlVehicle" CssClass="defaultDropDownList" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblImmatriculation" Text="Immatriculation" CssClass="defaultLabel" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtImmatriculation" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:CheckBox ID="cbPoliceEscort" Text="Police Escort" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblFlightNo" Text="Flight number" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFlightNo" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="2"></td>
                                        <td>
                                            <asp:Label ID="lblProvider" Text="Provider" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtProvider" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:Panel ID="pnlTimeMgmt" GroupingText="Time management" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblForeWarning" Text="Forewarning (min)" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtForeWarning" onkeydown="return (!(event.keyCode>=65) && event.keyCode!=32);" runat="server" CssClass="smallInputTextBox" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:CompareValidator ID="cvForeWarning" ControlToValidate="txtForeWarning" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Forewarning value can only be numeric!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblWaitingTime" Text="Waiting time (min)" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtWaitingTime" onkeydown="return (!(event.keyCode>=65) && event.keyCode!=32);" runat="server" CssClass="smallInputTextBox" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:CompareValidator ID="cvWaitinTime" ControlToValidate="txtWaitingTime" Operator="DataTypeCheck" Type="Integer" ErrorMessage="Waiting time value can only be numeric!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                        <td colspan="2">
                            <table>
                                <tr>
                                    <td style="vertical-align: top">
                                        <asp:Label ID="lblComment" Text="Comment" runat="server" /></td>
                                    <td rowspan="3" style="vertical-align: top">
                                        <asp:TextBox ID="txtComment" TextMode="MultiLine" Columns="50" Rows="5" MaxLength="256" runat="server"></asp:TextBox></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
                <table style="width: 100%">
                    <tr>
                        <td>
                            <asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" /></td>
                        <td colspan="3" class="alignRight">
                            <asp:Button ID="btnDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this transport from this donor?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
