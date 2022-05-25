<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageVehicles.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageVehicles" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Vehicle List -->
    <asp:UpdatePanel ID="VehicleOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvVehicle" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewVehicle" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive Vehicles" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
            </table>
            <asp:Panel ID="pnlVehicle" GroupingText="Vehicles" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvVehicle" runat="server" ItemType="Pentag.SLIDS.DAL.Vehicle" SelectMethod="gvVehicle_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvVehicle_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Vehicle" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Sort position" SortExpression="Position">  
                            <ItemTemplate> <%# Item.Position != null ? Item.Position.ToString() : String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewVehicle" runat="server" Text="Add New..." OnClick="btnAddNewVehicle_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="VehicleDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvVehicle" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlVehicleDetails" GroupingText="Vehicle detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidVehicleID" Value="0" runat="server" />
                <table id="tblVehicleDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblName" Text="*Vehicle" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvName" ControlToValidate="txtName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblPosition" Text="Sort position" runat="server" /></td>
                        <td><asp:TextBox ID="txtPosition" CssClass="defaultInputTextBox" runat="server" /></td>
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
