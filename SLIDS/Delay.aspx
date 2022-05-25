<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Delay.aspx.cs" Inherits="Pentag.SLIDS.Delay" %>

<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Transport List -->
    <asp:UpdatePanel ID="TransportOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransport" />
            <asp:AsyncPostBackTrigger ControlID="gvDelay" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnDelete" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewDelay" />
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
                        <asp:TemplateField HeaderText="Waiting Time (min)" SortExpression="WaitingTime">
                            <ItemTemplate><%# Item.WaitingTime != null ? Item.WaitingTime.ToString() : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Vehicle">
                            <ItemTemplate><%# Item.VehicleID != null ? Item.Vehicle.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Operations Center">
                            <ItemTemplate><%# Item.OperationCenterID != null ? Item.OperationCenter.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Delay">
                            <ItemTemplate><%# GetDelays(Item) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Duration">
                            <ItemTemplate><%# GetDelayDuration(Item) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Organ loss">
                            <ItemTemplate><%# DelayCausedOrganLoss(Item) ? "Yes" : "No" %></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Transport cost List -->
    <asp:UpdatePanel ID="DelayOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransport" />
            <asp:AsyncPostBackTrigger ControlID="gvDelay" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnDelete" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewDelay" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlDelayList" GroupingText="Delays" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvDelay" runat="server" ItemType="Pentag.SLIDS.DAL.Delay" SelectMethod="gvDelay_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvDelay_SelectedIndexChanged"
                    AllowSorting="true" EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Delay reason" SortExpression="DelayReasonID">
                            <ItemTemplate><%# Item.DelayReasonID != null ? Item.DelayReason.Reason : Item.OtherReason ?? String.Empty  %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Duration" SortExpression="Duration">
                            <ItemTemplate><%# GetFormattedDuration(Item.Duration) %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Organ loss" SortExpression="IsOrganLost" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsOrganLost" runat="server" Enabled="false" Checked='<%# Item.IsOrganLost %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Comment" SortExpression="Comment">
                            <ItemTemplate><%# Item.Comment ?? String.Empty  %></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>

            <table style="width: 100%">
                <tr>
                    <td>
                        <asp:Button ID="btnAddNewDelay" runat="server" Text="Add New..." OnClick="btnAddNewDelay_Click" CausesValidation="false" CssClass="addNewButton btn btn-default" /></td>
                    <td class="alignRight">
                        <asp:Button ID="btnIncidentCreate" Text="Register Incident" CssClass="largeButton btn btn-default" AccessKey="I" runat="server" OnClick="btnIncidentCreate_Click" />
                    </td>
                </tr>
            </table>

        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:UpdatePanel ID="DelayDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvDelay" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidDelayID" Value="0" runat="server" />
            <asp:HiddenField ID="hidTransportID" Value="0" runat="server" />
            <asp:Panel ID="pnlDelayDetails" GroupingText="Delay Details" Visible="false" CssClass="slidsPanel" runat="server">
                <table id="tblDelayDetails" runat="server">
                    <tr>
                        <td>
                            <asp:Label ID="lblDelayReason" Text="(*)Delay reason" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlDelayReason" CssClass="largeDropDownList" runat="server" />
                        </td>
                        <td style="vertical-align: top">
                            <asp:Label ID="lblComment" Text="Comment" runat="server" />
                            <asp:CustomValidator ID="cvComment" OnServerValidate="cvComment_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                        </td>
                        <td rowspan="4">
                            <asp:TextBox ID="txtComment" TextMode="MultiLine" Columns="40" Rows="5" MaxLength="256" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblOtherDelayReason" Text="(*)Other delay reason" runat="server" /></td>
                        <td colspan="3" style="vertical-align: top">
                            <asp:TextBox ID="txtOtherDelayReason" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /><br />
                            <asp:CustomValidator ID="cvDelayReason" OnServerValidate="cvDelayReason_ServerValidate" ErrorMessage="Please choose or enter a delay reason!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblDuration" Text="*Duration" runat="server" /></td>
                        <td colspan="3" style="vertical-align: top">
                            <asp:RequiredFieldValidator ID="rfvDuration" ControlToValidate="txtDuration" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:TextBox ID="txtDuration" CssClass="tinyInputTextBox" MaxLength="5" runat="server" />
                            <ajaxToolkit:TextBoxWatermarkExtender ID="weDepartureTime" runat="server" TargetControlID="txtDuration" WatermarkCssClass="tinyWatermarked" WatermarkText="hh:mm" />
                            <ajaxToolkit:MaskedEditExtender ID="meeDepartureTime" TargetControlID="txtDuration" Mask="99:99" MaskType="Time" AcceptAMPM="false" InputDirection="LeftToRight" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:CustomValidator ID="cvDuration" ControlToValidate="txtDuration" OnServerValidate="cvDuration_ServerValidate" ErrorMessage="Please enter correct time format!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td colspan="4" style="vertical-align: top">
                            <asp:CheckBox ID="cbIsOrganLost" Text="Delay caused organ loss" runat="server" /></td>
                    </tr>
                </table>
                <table style="width: 100%">
                    <tr>
                        <td>
                            <asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" /></td>
                        <td colspan="3" class="alignRight">
                            <asp:Button ID="btnDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this delay from this transport?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
