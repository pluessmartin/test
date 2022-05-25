<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Organ.aspx.cs" Inherits="Pentag.SLIDS.Organ" %>

<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Organ List -->
    <asp:UpdatePanel ID="OrganOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransplantOrgan" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnDelete" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewOrgan" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlOrgan" GroupingText="Organs" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvTransplantOrgan" runat="server" ItemType="Pentag.SLIDS.DAL.TransplantOrgan" SelectMethod="gvTransplantOrgan_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvTransplantOrgan_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true" EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText=" Organ" SortExpression="OrganID">
                            <ItemTemplate><%# Item.Organ.Name %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Transplant Center">
                            <ItemTemplate><%# Item.TransplantCenterID != null ? Item.Hospital1.Display : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="TC">
                            <ItemTemplate><%# Item.TCID != null ? Item.Coordinator.Code ?? (Item.Coordinator.LastName ?? String.Empty) : String.Empty%></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Procurement Team">
                            <ItemTemplate><%# Item.ProcurementTeamID != null ? Item.Hospital.Display : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Procurement Surgeon" SortExpression="ProcurementSurgeon">
                            <ItemTemplate><%# Item.ProcurementSurgeon %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate><%# Item.TransplantStatusID != null ? Item.TransplantStatus.Name : String.Empty %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Received Procurement Report<br>within 5 days" SortExpression="ReceivedNecroReportWithin5Days" ItemStyle-HorizontalAlign="Center">
                            <ItemTemplate><%# Item.ReceivedNecroReportWithin5Days == null ? String.Empty : Convert.ToBoolean(Item.ReceivedNecroReportWithin5Days) ? "Yes" : "No" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Graft Box No" SortExpression="GraftBoxNo">
                            <ItemTemplate><%# Item.GraftBoxNo %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Perfusion machine" SortExpression="PrefusionMachine">
                            <ItemTemplate><%# (Item.PrefusionMachine.HasValue ? (bool)Item.PrefusionMachine : false) ? "<img src=\"images/done.png\">" : "" %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Perfusion machine<br />number" SortExpression="PrefusionMachineNumber">
                            <ItemTemplate><%# Item.PrefusionMachineNumber %></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <table style="width: 100%">
        <tr>
            <td>
                <asp:Button ID="btnAddNewOrgan" runat="server" Text="Add New..." OnClick="btnAddNewOrgan_Click" CausesValidation="false" CssClass="addNewButton btn btn-default" /></td>
            <td class="alignRight">
                <asp:Button ID="btnIncidentCreate" Text="Register Incident" CssClass="largeButton btn btn-default" AccessKey="I" runat="server" OnClick="btnIncidentCreate_Click" />
            </td>
        </tr>
    </table>

    <asp:UpdatePanel ID="TransplantOrganDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransplantOrgan" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlTransplantOrganDetails" GroupingText="Organ" Visible="false" CssClass="slidsPanel" runat="server">
                <table id="tblTransplantOrganDetails" runat="server">
                    <tr>
                        <td>
                            <asp:Label ID="lblOrgan" Text="*Organ" runat="server" />
                            <asp:HiddenField ID="hidTransplantOrganID" Value="0" runat="server" />
                        </td>
                        <td>
                            <asp:CustomValidator ID="cvOrgan" ControlToValidate="ddlOrgan" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlOrgan" CssClass="defaultDropDownList" AutoPostBack="true" OnSelectedIndexChanged="ddlOrgan_SelectedIndexChanged" runat="server" />
                        </td>
                        <td>
                            <asp:Label ID="lblStatus" Text="Status" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlStatus" CssClass="defaultDropDownList" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblProcurementSurgeon" Text="Procurement surgeon" runat="server" /></td>
                        <td>
                            <asp:TextBox ID="txtProcurementSurgeon" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                        <td>
                            <asp:Label ID="lblGraftBoxNo" Text="Graftbox SWTx" runat="server" /></td>
                        <td>
                            <asp:TextBox ID="txtGraftBoxNo" CssClass="smallInputTextBox" runat="server" />
                            <asp:RegularExpressionValidator ID="revGraftBoxNo" ControlToValidate="txtGraftBoxNo" ValidationExpression="^\d*" ErrorMessage="Enter a valid number" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                        </td>
                    </tr>
                    <tr id="trPerfusionMachine" runat="server">
                        <td>
                            <asp:Label ID="lblPerfusionmachine" Text="Perfusion machine" runat="server" /></td>
                        <td>
                            <asp:CheckBox ID="chkPerfusionmachine" runat="server" AutoPostBack="true" OnCheckedChanged="cbPerfusionmachine_CheckedChanged" /></td>
                        <td>
                            <asp:Label ID="lblPerfusionmachineNumber" Text="Perfusion machine number" runat="server" /></td>
                        <td>
                             
                            <asp:DropDownList ID="ddlLifeport" runat="server" />
                             
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblProcurementTeam" Text="Procurement team" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlProcurementTeam" CssClass="defaultDropDownList" runat="server" /></td>
                        <td>
                            <asp:Label ID="lblReceivedNecroReportWithin5Days" Text="Received Procurement Report within 5 days" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlReceivedNecroReportWithin5Days" runat="server" CssClass="defaultDropDownList" /></td>

                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblTC" Text="Transplantation coordinator" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlTC" runat="server" CssClass="defaultDropDownList" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblTransplantCenter" Text="Transplant center" runat="server" /></td>
                        <td>
                            <asp:DropDownList ID="ddlTransplantCenter" CssClass="defaultDropDownList" AutoPostBack="true" OnSelectedIndexChanged="ddlTransplantCenter_SelectedIndexChanged" runat="server" />
                            <asp:HiddenField ID="hidIsFO" Value="False" runat="server" />
                        </td>
                        <td colspan="4">
                            <asp:CheckBox ID="cbForeignTransplantCenter" Text="FO" AutoPostBack="true" OnCheckedChanged="cbForeignTransplantCenter_CheckedChanged" runat="server" />
                            <asp:Button ID="btnAddNewFOTransplantCenter" Text="Add new..." OnClick="btnAddNewFOTransplantCenter_Click" CssClass="defaultButton btn btn-default" Visible="false" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <asp:Panel ID="pnlFOTransplantCenter" GroupingText="FO Transplant Center" Visible="false" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterName" Text="*Hospital Name" runat="server" /></td>
                                        <td>
                                            <asp:RequiredFieldValidator ID="rfvFOTransplantCenterName" ControlToValidate="txtFOTransplantCenterName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                                            <asp:TextBox ID="txtFOTransplantCenterName" MaxLength="128" runat="server" />
                                        </td>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterDisplay" ToolTip="Name of Hospital which will be shown as selectables in lists" Text="Display" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterDisplay" MaxLength="128" ToolTip="Name of Hospital which will be shown as selectables in lists" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterAddress1" Text="Address 1" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterAddress1" MaxLength="64" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterPhone" Text="Phone" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterPhone" MaxLength="32" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterAddress2" Text="Address 2" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterAddress2" MaxLength="64" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterFax" Text="Fax" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterFax" MaxLength="32" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterAddress3" Text="Address 3" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterAddress3" MaxLength="64" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterEmail" Text="Email" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterEmail" MaxLength="64" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterAddress4" Text="Address 4" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtFOTransplantCenterAddress4" MaxLength="64" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterZip" Text="Zip" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtFOTransplantCenterZip" CssClass="smallInputTextBox" MaxLength="12" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterCity" Text="City" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterCity" MaxLength="64" runat="server" /></td>
                                        <td>
                                            <asp:Label ID="lblFOTransplantCenterCountryISO" Text="Country ISO" ToolTip="Country abbreviation (e.g. CH for Switzerland)" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtFOTransplantCenterCountryISO" CssClass="smallInputTextBox" MaxLength="2" ToolTip="Country abbreviation (e.g. CH for Switzerland)" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <asp:Panel ID="pnlFOTC" GroupingText="FO Transplantation Coordinator" CssClass="slidsPanel" runat="server">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblFOTCFirstname" Text="Firstname" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtFOTCFirstname" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblFOTCLastname" Text="Lastname" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtFOTCLastname" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                    <tr>
                        <td style="vertical-align: top; padding-top: 9Px;">
                            <asp:Label ID="lblRemark" Text="Remark" runat="server" /></td>
                        <td colspan="3">
                            <asp:TextBox ID="txtRemark" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                    </tr>
                </table>
                <table style="width: 100%">
                    <tr>
                        <td>
                            <asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" /></td>
                        <td colspan="3" class="alignRight">
                            <asp:Button ID="btnDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this organ from this donor?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
