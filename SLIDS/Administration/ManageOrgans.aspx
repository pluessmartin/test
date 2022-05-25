<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageOrgans.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageOrgans" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Organ List -->
    <asp:UpdatePanel ID="OrganOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvOrgan" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewOrgan" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive organs" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
            </table>
            <asp:Panel ID="pnlOrgan" GroupingText="Organs" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvOrgan" runat="server" ItemType="Pentag.SLIDS.DAL.Organ" SelectMethod="gvOrgan_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvOrgan_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Organ" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Organ count" SortExpression="Name">  
                            <ItemTemplate> <%# Item.CountableAs ?? 0 %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Sort position" SortExpression="Position">  
                            <ItemTemplate> <%# Item.Position != null ? Item.Position.ToString() : String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewOrgan" runat="server" Text="Add New..." OnClick="btnAddNewOrgan_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="OrganDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvOrgan" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlOrganDetails" GroupingText="Organ detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidOrganID" Value="0" runat="server" />
                <table id="tblOrganDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblItemGroup" Text="*Group" runat="server" /></td>
                        <td>
                            <asp:CustomValidator id="cvItemGroup" ControlToValidate="ddlItemGroup" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlItemGroup" CssClass="defaultDropDownList" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblName" Text="*Organ" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvName" ControlToValidate="txtName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblCountableAs" Text="*Organ count" ToolTip="Number of organs this organ is countable for" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvCountableAs" ControlToValidate="txtCountableAs" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtCountableAs" CssClass="defaultInputTextBox" runat="server" />
                            <asp:CompareValidator ID="cvCountableAs" ControlToValidate="txtCountableAs" Type="Integer" Operator="DataTypeCheck" ForeColor="Red" ErrorMessage="Please only enter numbers" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
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
