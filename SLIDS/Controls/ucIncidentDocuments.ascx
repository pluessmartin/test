<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucIncidentDocuments.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucIncidentDocuments" %>

<asp:Panel ID="PanelDocuments" GroupingText="Documents" CssClass="slidsPanel" runat="server">
    <asp:UpdatePanel ID="upDocuments" UpdateMode="Conditional" runat="server" >
        <Triggers>
            <asp:PostBackTrigger ControlID="btnUpload" />
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidIncidentID" Value="0" runat="server" />
            <asp:HiddenField ID="hidOriginalIncidentID" Value="0" runat="server" />
            <asp:HiddenField ID="hidGUID" Value="0" runat="server" />
            <asp:GridView ID="gvDocuments" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentDocument"
                SelectMethod="gvDocuments_GetData" OnRowDataBound="gvDocuments_RowDataBound" DeleteMethod="gvDocuments_DeleteItem"
                DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                AllowSorting="true"
                AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                CssClass="slidsGridOverview"
                SelectedRowStyle-CssClass="slidsGridSelected"
                PagerStyle-CssClass="slidsGridPager">
                <Columns>
                    <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                    <asp:TemplateField HeaderText="Documents">
                        <ItemTemplate><a href="<%# String.Format("ViewDocument.aspx?incidentDocument={0}", Item.ID) %>" target="_blank">
                                                        <img alt="down" src="resources/file_download.png" /></a> <%# Item.IncidentDocumentName %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField ShowHeader="False">
                        <ItemTemplate>
                            <asp:ImageButton ID="btnDeleteDocument" runat="server" Text="Delete" CausesValidation="true" ValidationGroup="InputDoc" ImageUrl="~/resources/entry_delete.png" CommandName="delete" />
                            <ajaxToolkit:ConfirmButtonExtender ID="cbeDeleteDocumentConfirmation" runat="server" ConfirmText="Are you sure you want to delete this document?" TargetControlID="btnDeleteDocument" />
                        </ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
            <asp:FileUpload ID="fuDocument" runat="server" />
            <asp:Button ID="btnUpload" runat="server" Text="Upload" OnClick="btnUpload_Click" />
            <div style="color:red;"><asp:Literal ID="litErrorMessage" runat="server"></asp:Literal></div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Panel>
