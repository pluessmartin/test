<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="TransportCost.aspx.cs" Inherits="Pentag.SLIDS.TransportCost" %>
<%@ Register TagPrefix="uc" TagName="OrganCostAllocation" Src="~/Controls/ucOrganCostAllocation.ascx" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Transport List -->
    <asp:UpdatePanel ID="TransportOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvTransport" />
            <asp:AsyncPostBackTrigger controlid="gvTransportCost" />
            <asp:AsyncPostBackTrigger controlid="btnSave" />
            <asp:AsyncPostBackTrigger controlid="btnDelete" />
            <asp:AsyncPostBackTrigger controlid="btnAddNewTransportCost" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlTransport" GroupingText="Donor Transports" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvTransport" runat="server" ItemType="Pentag.SLIDS.DAL.Transport" SelectMethod="gvTransport_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnRowDataBound="gvTransport_RowDataBound"
                    AllowSorting="true"
                    CssClass="slidsGridNotSelectable"
                    FooterStyle-CssClass="slidsGridPager"
                    ShowFooter="true"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Transported Organs">  
                            <ItemTemplate> <%# GetTransportedElements(Item)%></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Departed from">  
                            <ItemTemplate> <%# Item.DepartureHospitalID != null ? Item.Hospital.Display : Item.OtherDeparture ?? String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Departed" SortExpression="Departure" >  
                            <ItemTemplate> <%# Item.Departure != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Departure) : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                         <asp:TemplateField HeaderText="Destination">  
                            <ItemTemplate> <%# Item.DestinationHospitalID != null ? Item.Hospital1.Display : Item.OtherDestination ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Arrived" SortExpression="Arrival" >  
                            <ItemTemplate> <%# Item.Arrival != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Arrival) : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Vehicle">  
                            <ItemTemplate> <%# Item.VehicleID != null ? Item.Vehicle.Name : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Operations Center">  
                            <ItemTemplate> <%# Item.OperationCenterID != null ? Item.OperationCenter.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Costs">  
                            <ItemTemplate> <%# GetTotalTransportCosts(Item)%></ItemTemplate>
                            <FooterTemplate>
                                <div style="text-align: right;font-weight:bold;">
                                    <asp:Literal ID="lblTotalCosts" runat="server" />
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Transport cost List -->
    <asp:UpdatePanel ID="TransportCostOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvTransportCost" />
            <asp:AsyncPostBackTrigger controlid="btnSave" />
            <asp:AsyncPostBackTrigger controlid="btnDelete" />
            <asp:AsyncPostBackTrigger controlid="btnAddNewTransportCost" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlTransportCostList" GroupingText="Transport Costs" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvTransportCost" runat="server" ItemType="Pentag.SLIDS.DAL.Cost" SelectMethod="gvTransportCost_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvTransportCost_SelectedIndexChanged" OnRowDataBound="gvTransportCost_RowDataBound"
                    AllowSorting="true" EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    FooterStyle-CssClass="slidsGridPager"
                    ShowFooter="true"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Cost Type">  
                            <ItemTemplate> <%# Item.CostTypeID != null ? Item.CostType.Name : String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Amount" SortExpression="Amount">  
                            <ItemTemplate> <%# Item.Amount != null ? Convert.ToDecimal(Item.Amount).ToString("N2") : String.Empty %></ItemTemplate>  
                            <FooterTemplate>
                                <div style="text-align: right;font-weight:bold;">
                                    <asp:Literal ID="lblTotalAmount" runat="server" />
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total organ<br />allocated costs">  
                            <ItemTemplate> <%# GetTotalOrganAllocatedCosts(Item)%></ItemTemplate>
                            <FooterTemplate>
                                <div style="text-align: right;font-weight:bold;">
                                    <asp:Literal ID="lblTotalOrganAllocated" runat="server" />
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice no" SortExpression="InvoiceNo" >  
                            <ItemTemplate> <%# Item.InvoiceNo ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Creditor">  
                            <ItemTemplate> <%# Item.CreditorID != null ? Item.Creditor.CreditorName : Item.KreditorName %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Departed from">  
                            <ItemTemplate> <%# Item.Transport == null ? String.Empty : Item.Transport.DepartureHospitalID != null ? Item.Transport.Hospital.Display : Item.Transport.OtherDeparture ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Destination">  
                            <ItemTemplate> <%# Item.Transport == null ? String.Empty : Item.Transport.DestinationHospitalID != null ? Item.Transport.Hospital1.Display : Item.Transport.OtherDestination ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Transported Organs">  
                            <ItemTemplate> <%# GetTransportedElements(Item.Transport)%></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewTransportCost" runat="server" Text="Add New..." OnClick="btnAddNewTransportCost_Click" CausesValidation="false" CssClass="addNewButton btn btn-default" />

    <asp:UpdatePanel ID="TransportCostDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvTransportCost" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidCostID" Value="0" runat="server" />
            <asp:Panel ID="pnlTransportCostDetails" GroupingText="Transport Cost Details" Visible="false" CssClass="slidsPanel" runat="server">
                <table id="tblTransportCostDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblTransportCostType" Text="*Cost Type" runat="server" /></td>
                        <td>
                            <asp:CustomValidator id="cvTransportCostType" ControlToValidate="ddlTransportCostType" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlTransportCostType" AutoPostBack="true" OnSelectedIndexChanged="ddlTransportCostType_SelectedIndexChanged" CssClass="defaultDropDownList" runat="server" />
                            <asp:HiddenField ID="hidCostTypeID" Value="0" runat="server" />
                            <asp:HiddenField ID="hidTransportSelectionIsMandatory" Value="true" runat="server" />
                        </td>
                        <td><asp:Label ID="lblAmount" Text="*Amount (CHF)" runat="server" /></td>
                        <td colspan="3">
                            <asp:RequiredFieldValidator ID="rfvAmount" ControlToValidate="txtAmount" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:TextBox ID="txtAmount" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="true" OnTextChanged="InitializeOrganCostListWithDefaultOrganCosts" runat="server" />
                            <asp:CompareValidator ID="cvAmount" ControlToValidate="txtAmount"  Operator="DataTypeCheck" Type="Currency" ErrorMessage="Amount value can only be numberic." ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:HiddenField ID="hidAmount" Value="0" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblCostName" Text="Description" runat="server" /></td>
                        <td><asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                        <td style="vertical-align:top"><asp:Label ID="lblComment" Text="Comment" runat="server" /></td>
                        <td rowspan="4" style="vertical-align:top"><asp:TextBox ID="txtComment" MaxLength="256" TextMode="MultiLine" Columns="40" Rows="5" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblInvoiceNo" Text="Invoice number" runat="server" /></td>
                        <td colspan="3" style="vertical-align:top"><asp:TextBox ID="txtInvoiceNo" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                    </tr>
                    <tr>
                        <td style="vertical-align:top"><asp:Label ID="lblCreditor" Text="Creditor" runat="server" /></td>
                        <td colspan="3" style="vertical-align:top"><asp:DropDownList ID="ddlCreditor" runat="server" CssClass="defaultDropDownList" /></td>
                    </tr>
                    <tr>
                        <td style="vertical-align:top"><asp:Label ID="lblKreditorName" Text="Other creditor" runat="server" /></td>
                        <td colspan="3" style="vertical-align:top"><asp:TextBox ID="txtKreditorName" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                    </tr>
                    <tr>
                        <td colspan="2"><asp:CustomValidator ID="cvCreditor" OnServerValidate="cvCreditor_ServerValidate" ErrorMessage="Please select creditor or enter other creditor but not both!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:HiddenField ID="hidTransportIDToSelect" Value="0" runat="server" />
                            <asp:Panel ID="pnlTransportsToSelect" GroupingText="Select Transport" CssClass="slidsPanel" runat="server">
                                <asp:GridView ID="gvTransportsToSelect" runat="server" ItemType="Pentag.SLIDS.DAL.Transport" SelectMethod="gvTransportsToSelect_GetData"
                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                    OnSelectedIndexChanged="InitializeOrganCostListWithDefaultOrganCosts" OnRowDataBound="gvTransportsToSelect_RowDataBound"
                                    AllowSorting="true" EnablePersistedSelection="true"
                                    CssClass="slidsGrid"
                                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                                    <Columns>
                                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                        <asp:TemplateField HeaderText="Transported Organs">  
                                            <ItemTemplate> <%# GetTransportedElements(Item)%></ItemTemplate>  
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Departed from">  
                                            <ItemTemplate> <%# Item.DepartureHospitalID != null ? Item.Hospital.Display : Item.OtherDeparture ?? String.Empty  %></ItemTemplate>  
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Departed" SortExpression="Departure" >  
                                            <ItemTemplate> <%# Item.Departure != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Departure) : String.Empty %></ItemTemplate>  
                                        </asp:TemplateField>
                                         <asp:TemplateField HeaderText="Destination">  
                                            <ItemTemplate> <%# Item.DestinationHospitalID != null ? Item.Hospital1.Display : Item.OtherDestination ?? String.Empty %></ItemTemplate>  
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Arrived" SortExpression="Arrival" >  
                                            <ItemTemplate> <%# Item.Arrival != null ? String.Format("{0:dd.MM.yyyy HH:mm}", Item.Arrival) : String.Empty %></ItemTemplate>  
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Vehicle">  
                                            <ItemTemplate> <%# Item.VehicleID != null ? Item.Vehicle.Name : String.Empty %></ItemTemplate>  
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Operations Center">  
                                            <ItemTemplate> <%# Item.OperationCenterID != null ? Item.OperationCenter.Name : String.Empty %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Total Costs">  
                                            <ItemTemplate> <%# GetTotalTransportCosts(Item)%></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:CustomValidator id="cvTransportsToSelect" OnServerValidate="cvTransportsToSelect_ServerValidate" ErrorMessage="Please select a transport on which the costs are referred to." ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:Panel ID="pnlOrganCostAllocation" GroupingText="Cost allocation" Visible="true" CssClass="slidsPanel" runat="server">
                                <uc:OrganCostAllocation ID="ucOrganCostAllocationControl" runat="server" />
                            </asp:Panel>
                        </td>
                    </tr>
                </table>
                <table style="width:100%">
                     <tr>
                        <td><asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server"  /></td>
                         <td colspan="3" class="alignRight"><asp:Button ID="btnDelete" Text="Delete"  OnClientClick="return confirm('Do you want to delete this transport cost from this donor?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
