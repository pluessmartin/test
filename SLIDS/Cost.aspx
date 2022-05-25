<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Cost.aspx.cs" Inherits="Pentag.SLIDS.Cost" %>
<%@ Register TagPrefix="uc" TagName="OrganCostAllocation" Src="~/Controls/ucOrganCostAllocation.ascx" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    
    <!-- Organ Overview -->
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvTransplantOrgan" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlOrgan" GroupingText="Organs" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvTransplantOrgan" runat="server" ItemType="Pentag.SLIDS.DAL.TransplantOrgan" SelectMethod="gvTransplantOrgan_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    AllowSorting="true"
                    CssClass="slidsGridNotSelectable"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText=" Organ">  
                            <ItemTemplate> <%# Item.Organ.Name %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Transplant Center">  
                            <ItemTemplate> <%# Item.TransplantCenterID != null ? Item.Hospital1.Display : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="TC">  
                            <ItemTemplate> <%# Item.TCID != null ? Item.Coordinator.Code ?? (Item.Coordinator.LastName ?? String.Empty) : String.Empty%></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Graft Box No" SortExpression="GraftBoxNo">  
                            <ItemTemplate> <%# Item.GraftBoxNo %></ItemTemplate>  
                        </asp:TemplateField>
                            <asp:TemplateField HeaderText="Procurement Team">  
                            <ItemTemplate> <%# Item.ProcurementTeamID != null ? Item.Hospital.Display : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Procurement Surgeon" SortExpression="ProcurementSurgeon">  
                            <ItemTemplate> <%# Item.ProcurementSurgeon %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">  
                            <ItemTemplate> <%# Item.TransplantStatusID != null ? Item.TransplantStatus.Name : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Received Procurement-Report<br />within 5 days" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate> <%# Item.ReceivedNecroReportWithin5Days == null ? String.Empty : Item.ReceivedNecroReportWithin5Days == true ? "Yes" : "No" %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <!-- Cost List -->
    <asp:UpdatePanel ID="CostOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvCost" />
            <asp:AsyncPostBackTrigger controlid="btnSave" />
            <asp:AsyncPostBackTrigger controlid="btnDelete" />
            <asp:AsyncPostBackTrigger controlid="btnAddNewCost" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlCostList" GroupingText="General Costs" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvCost" runat="server" ItemType="Pentag.SLIDS.DAL.Cost" SelectMethod="gvCost_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvCost_SelectedIndexChanged" OnRowDataBound="gvCost_RowDataBound"
                    AllowSorting="true" EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    FooterStyle-CssClass="slidsGridPager"
                    ShowFooter="true"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Cost Group">  
                            <ItemTemplate> <%# Item.CostType.CostGroup != null ? Item.CostType.CostGroup.Name : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
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
                            <ItemTemplate> <%# GetTotalOrganAllocatedCosts(Item) %></ItemTemplate>
                            <FooterTemplate>
                                <div style="text-align: right;font-weight:bold;">
                                    <asp:Literal ID="lblTotalAllocated" runat="server" />
                                </div>
                            </FooterTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Invoice no" SortExpression="InvoiceNo">  
                            <ItemTemplate> <%# Item.InvoiceNo ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Kreditor">  
                            <ItemTemplate> <%# Item.KreditorHospitalID != null ? Item.Hospital.Display : Item.KreditorName %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewCost" runat="server" Text="Add New..." OnClick="btnAddNewCost_Click" CausesValidation="false" CssClass="addNewButton btn btn-default" />

    <asp:UpdatePanel ID="CostDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="gvCost" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidCostID" Value="0" runat="server" />
            <asp:Panel ID="pnlCostDetails" GroupingText="Cost Details" Visible="false" CssClass="slidsPanel" runat="server">
                <table id="tblCostDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblCostType" Text="*Cost Type" runat="server" /></td>
                        <td>
                            <asp:CustomValidator id="cvCostType" ControlToValidate="ddlCostType" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlCostType" AutoPostBack="true" OnSelectedIndexChanged="ddlCostType_SelectedIndexChanged" CssClass="largeDropDownList" runat="server" />
                            <asp:HiddenField ID="hidCostTypeID" Value="0" runat="server" />
                        </td>
                        <td><asp:Label ID="lblAmount" Text="*Amount (CHF)" runat="server" /></td>
                        <td colspan="3">
                            <asp:RequiredFieldValidator ID="rfvAmount" ControlToValidate="txtAmount" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:TextBox ID="txtAmount" CssClass="smallInputTextBox" MaxLength="10" runat="server" />
                            <asp:CompareValidator ID="cvAmount" ControlToValidate="txtAmount" Operator="DataTypeCheck" Type="Currency" ErrorMessage="Amount value can only be numberic." ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />

                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblCostName" Text="Description" runat="server" /></td>
                        <td><asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                        <td style="vertical-align:top"><asp:Label ID="lblComment" Text="Comment" runat="server" /></td>
                        <td rowspan="4" style="vertical-align:top"><asp:TextBox ID="txtComment" TextMode="MultiLine" Columns="40" Rows="5" MaxLength="256" runat="server"></asp:TextBox></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblInvoiceNo" Text="Invoice number" runat="server" /></td>
                        <td colspan="3"><asp:TextBox ID="txtInvoiceNo" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                    </tr>
                    <tr>
                        <td style="vertical-align:top"><asp:Label ID="lblKreditorHospital" Text="Creditor" runat="server" /></td>
                        <td colspan="3" style="vertical-align:top"><asp:DropDownList ID="ddlKreditorHospital" runat="server" CssClass="defaultDropDownList" /></td>
                    </tr>
                    <tr>
                        <td style="vertical-align:top"><asp:Label ID="lblKreditorName" Text="Other creditor" runat="server" /></td>
                        <td colspan="3" style="vertical-align:top"><asp:TextBox ID="txtKreditorName" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
                    </tr>
                    <tr>
                        <td colspan="2"><asp:CustomValidator ID="cvKreditor" OnServerValidate="cvKreditor_ServerValidate" ErrorMessage="Please select creditor or enter other creditor but not both!" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" /></td>
                        <td colspan="2"></td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <uc:OrganCostAllocation ID="ucOrganCostAllocationControl" runat="server" />
                        </td>
                    </tr>
                </table>
                <table style="width:100%; height:100%">
                     <tr>
                        <td><asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server"  /></td>
                         <td colspan="3" class="alignRight"><asp:Button ID="btnDelete" Text="Delete"  OnClientClick="return confirm('Do you want to delete this cost from this donor?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
    
</asp:Content>
