<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageLifeports.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageLifeports" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Lifeport List -->
    <asp:UpdatePanel ID="LifeportOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvLifeport" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewLifeport" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive Lifeports" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
            </table>
            <asp:Panel ID="pnlLifeport" GroupingText="Lifeports" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvLifeport" runat="server" ItemType="Pentag.SLIDS.DAL.Lifeport" SelectMethod="gvLifeport_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvLifeport_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Lifeport" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Number ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Sort position" SortExpression="Position">  
                            <ItemTemplate> <%# Item.Position != null ? Item.Position.ToString() : String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewLifeport" runat="server" Text="Add New..." OnClick="btnAddNewLifeport_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="LifeportDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvLifeport" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlLifeportDetails" GroupingText="Lifeport detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidLifeportID" Value="0" runat="server" />
                <table id="tblLifeportDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblName" Text="*Lifeport" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvName" ControlToValidate="txtName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblPosition" Text="Sort position" runat="server" /></td>
                        <td><asp:TextBox ID="txtPosition" CssClass="defaultInputTextBox" onkeydown = "return (!(event.keyCode>=65) && event.keyCode!=32);" runat="server" /></td>
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
