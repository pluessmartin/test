<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageCreditors.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageCreditors" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    
    <!-- Creditor List -->
    <asp:UpdatePanel ID="CreditorOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvCreditor" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewCreditor" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive creditors" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
            </table>
            <asp:Panel ID="pnlCreditor" GroupingText="Creditors" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvCreditor" runat="server" ItemType="Pentag.SLIDS.DAL.Creditor" SelectMethod="gvCreditor_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvCreditor_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Creditor" SortExpression="CreditorName">  
                            <ItemTemplate> <%# Item.CreditorName ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:HiddenField ID="hidPageIndex" Value="0" runat="server" />
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewCreditor" runat="server" Text="Add New..." OnClick="btnAddNewCreditor_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="CreditorDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvCreditor" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlCreditorDetails" GroupingText="Creditor detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidCreditorID" Value="0" runat="server" />
                <table id="tblCreditorDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblCreditorName" Text="*Creditor Name" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvCreditorName" ControlToValidate="txtCreditorName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtCreditorName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
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
