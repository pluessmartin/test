<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="IncidentLexicon.aspx.cs" Inherits="Pentag.SLIDS.IncidentLexicon" %>

<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <asp:Panel ID="pnlIncidentsLexiconHelp" GroupingText="Incidents Lexicon / Help" CssClass="slidsPanel" runat="server">

        <asp:UpdatePanel ID="IncidentLexiconOverview" UpdateMode="Conditional" runat="server">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="gvLexicons" />
                <asp:AsyncPostBackTrigger ControlID="btnSave" />
                <asp:AsyncPostBackTrigger ControlID="btnDelete" />
                <asp:AsyncPostBackTrigger ControlID="btnAddNew" />
            </Triggers>
            <ContentTemplate>
                <asp:GridView ID="gvLexicons" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentLexicon"
                    SelectMethod="gvLexicons_GetData" OnRowDataBound="gvLexicons_RowDataBound" OnSelectedIndexChanged="gvLexicons_SelectedIndexChanged"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Definition">
                            <ItemTemplate><%# Item.Definition %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description">
                            <ItemTemplate><%# Item.Description %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Documents">
                            <ItemTemplate><%# GetIncidentLexiconDocuments(Item) %> </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Panel>
    <table>
        <tbody>
            <tr>
                <td>
                    <asp:Button ID="btnAddNew" Text="Add New..." OnClick="btnAddNew_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" />
                </td>
            </tr>
        </tbody>
    </table>

    <asp:UpdatePanel ID="LexiconAdd" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvLexicons" />
        </Triggers>
        <ContentTemplate>
            <div id="divIncidentsLexiconHelpAdd" style="visibility: hidden;" runat="server">
                <asp:Panel ID="pnlIncidentsLexiconHelpAdd" GroupingText="Incidents Lexicon / Help" CssClass="slidsPanel" runat="server">
                    <table>
                        <tbody>
                            <tr>
                                <td style="vertical-align:top;">
                                    <asp:HiddenField ID="hidIncidentLexiconID" Value="0" runat="server" />
                                    <table>
                                        <tbody>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="lblDefinition" Text="Definition" runat="server" /></td>
                                                <td>
                                                    <asp:TextBox ID="txtDefinition" CssClass="largeInputTextBox" runat="server" Enabled="false" /></td>
                                            </tr>
                                            <tr>
                                                <td style="vertical-align: top; padding-top: 9Px;">
                                                    <asp:Label ID="lblDescription" Text="Description" runat="server" /></td>
                                                <td>
                                                    <asp:TextBox ID="txtDescription" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                            </tr>
                                            <tr>
                                                <td style="vertical-align: top; padding-top: 9Px;">
                                                    <asp:Label ID="lblInfoDescription" Text="Info Description" runat="server" /></td>
                                                <td>
                                                    <asp:TextBox ID="txtInfoDescription" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </td>
                                <td style="vertical-align:top;">
                                    <asp:Panel ID="pnlDocuments" GroupingText="Documents" CssClass="slidsPanel" runat="server">
                                        <asp:UpdatePanel ID="upDocuments" runat="server" UpdateMode="Conditional">
                                            <Triggers>
                                                <asp:AsyncPostBackTrigger ControlID="gvLexicons" />
                                                <asp:PostBackTrigger ControlID="btnUpload" />
                                            </Triggers>
                                            <ContentTemplate>
                                                <asp:GridView ID="gvDocuments" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentLexiconDocument"
                                                    SelectMethod="gvDocuments_GetData" OnRowDataBound="gvDocuments_RowDataBound"
                                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                                    DeleteMethod="gvDocuments_DeleteItem"
                                                    AllowSorting="true"
                                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                                    CssClass="slidsGrid"
                                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                                    PagerStyle-CssClass="slidsGridPager">
                                                    <Columns>
                                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                                        <asp:TemplateField HeaderText="Definition">
                                                            <ItemTemplate>
                                                                <a href="<%# String.Format("ViewDocument.aspx?incidentLexiconDocument={0}", Item.ID) %>" target="_blank">
                                                                    <img alt="down" src="resources/file_download.png" /></a> <%# Item.IncidentLexiconDocumentName %>
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField ShowHeader="False">
                                                            <ItemTemplate>
                                                                <asp:ImageButton ID="btnDeleteDocument" runat="server" CausesValidation="False" Text="Delete" ImageUrl="~/resources/entry_delete.png" CommandName="delete" />
                                                                <ajaxToolkit:ConfirmButtonExtender ID="cbeDeleteDocumentConfirmation" runat="server" ConfirmText="Are you sure you want to delete this document?" TargetControlID="btnDeleteDocument" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                                <asp:FileUpload ID="fuDocument" runat="server" />
                                                <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
                                            </ContentTemplate>
                                        </asp:UpdatePanel>
                                    </asp:Panel>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                    <table style="width: 100%">
                        <tr>
                            <td>
                                <asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" /></td>
                            <td class="alignRight">
                                <asp:Button ID="btnDelete" Text="Delete" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" />
                                <ajaxToolkit:ConfirmButtonExtender ID="cbeDeleteConfirmation" runat="server" ConfirmText="Do you want to delete this incident lexicon?" TargetControlID="btnDelete" />
                            </td>
                        </tr>
                    </table>
                </asp:Panel>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
