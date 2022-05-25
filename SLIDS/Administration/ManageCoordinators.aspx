<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageCoordinators.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageCoordinators" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>
<%@ Register TagPrefix="adr" TagName="Address" Src="~/Controls/ucAddresses.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Coordinator List -->
    <asp:UpdatePanel ID="CoordinatorOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvCoordinator" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewCoordinator" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive coordinators" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
                <tr>
                    <td>
                        <br />
                        <asp:TextBox ID="FilterText" runat="server" placeholder="Search text" AutoPostBack="true"></asp:TextBox>
                    </td>
                </tr>
            </table>
            <asp:Panel ID="pnlCoordinator" GroupingText="Coordinators" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvCoordinator" runat="server" ItemType="Pentag.SLIDS.DAL.Coordinator" SelectMethod="gvCoordinator_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvCoordinator_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Lastname" SortExpression="Lastname">  
                            <ItemTemplate> <%# Item.LastName ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Firstname" SortExpression="Firstname">  
                            <ItemTemplate> <%# Item.FirstName ?? String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                         <asp:TemplateField HeaderText="Code" SortExpression="Code">  
                            <ItemTemplate> <%# Item.Code ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Hospital">  
                            <ItemTemplate> <%# Item.HospitalID != null ? Item.Hospital.Display : String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is NC" SortExpression="IsNC" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsNC" runat="server" Enabled="false" Checked='<%# Item.IsNC %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is TC" SortExpression="IsTC" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate> 
                                <asp:CheckBox ID="cbIsTC" runat="server" Enabled="false" Checked='<%# Item.IsTC %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:HiddenField ID="hidPageIndex" Value="0" runat="server" />
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewCoordinator" runat="server" Text="Add New..." OnClick="btnAddNewCoordinator_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="CoordinatorDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvCoordinator" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlCoordinatorDetails" GroupingText="Coordinator detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidCoordinatorID" Value="0" runat="server" />
                <table id="tblCoordinatorDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblLastName" Text="*Lastname" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvLastName" ControlToValidate="txtLastName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtLastName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                        <td><asp:Label ID="lblHospital" Text="Hospital" runat="server" /></td>
                        <td><asp:DropDownList ID="ddlHospital" CssClass="defaultDropDownList" runat="server" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblFirstName" Text="*Firstname" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvFirstName" ControlToValidate="txtFirstName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtFirstName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                        <td><asp:Label ID="lblCode" Text="*Code" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvCode" ControlToValidate="txtCode" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtCode" CssClass="defaultInputTextBox" MaxLength="16" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4"><asp:CheckBox ID="cbIsNC" Text="is NC" runat="server" /></td>
                    </tr>
                    <tr>
                        <td colspan="4"><asp:CheckBox ID="cbIsTC" Text="is TC" runat="server" /></td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <adr:Address ID="ucAddressControl" runat="server" />
                        </td>
                    </tr>
                </table>
                <table style="width:100%">
                     <tr>
                        <td><asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server"  /></td>
                        <td colspan="3" class="alignRight"><asp:Button ID="btnActiveHandling" OnClick="btnActiveHandling_Click" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
