<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageTransportItems.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageTransportItems" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- TransportItem List -->
    <asp:UpdatePanel ID="TransportItemOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransportItem" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewTransportItem" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td><asp:CheckBox ID="cbIncludeInactive" Text="Include inactive transport items" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" /></td>
                </tr>
            </table>
            <asp:Panel ID="pnlTransportItem" GroupingText="Transport items" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvTransportItem" runat="server" ItemType="Pentag.SLIDS.DAL.TransportItem" SelectMethod="gvTransportItem_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvTransportItem_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    EnablePersistedSelection="true"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Transport item" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Transport item count" SortExpression="Name">  
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

    <asp:Button ID="btnAddNewTransportItem" runat="server" Text="Add New..." OnClick="btnAddNewTransportItem_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="TransportItemDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvTransportItem" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlTransportItemDetails" GroupingText="Transport item detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidTransportItemID" Value="0" runat="server" />
                <table id="tblTransportItemDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblItemGroup" Text="*Group" runat="server" /></td>
                        <td>
                            <asp:CustomValidator id="cvItemGroup" ControlToValidate="ddlItemGroup" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlItemGroup" CssClass="defaultDropDownList" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblName" Text="*Transport item" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator ID="rfvName" ControlToValidate="txtName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                            <asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblCountableAs" Text="*Transport item count" ToolTip="Number of transport items this transport item is countable for" runat="server" /></td>
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
                    <tr>
                        <td colspan="2">
                            <asp:Panel ID="pnlAssociatedOrgans" GroupingText="Associated Organs" CssClass="slidsPanel" runat="server">

                                <asp:GridView ID="gvOrganToTransportItemAssociation" runat="server" ItemType="Pentag.SLIDS.DAL.OrganToTransportItemAssociation" 
                                    DataKeyNames="ID" AutoGenerateColumns="False" 
                                    ShowHeaderWhenEmpty="True" ShowFooter="False"
                                    OnRowCommand="gvOrganToTransportItemAssociation_RowCommand"
                                    OnRowCreated="gvOrganToTransportItemAssociation_RowCreated"
                                    OnRowEditing="gvOrganToTransportItemAssociation_RowEditing"
                                    OnRowCancelingEdit="gvOrganToTransportItemAssociation_RowCancelingEdit"
                                    OnRowUpdating="gvOrganToTransportItemAssociation_RowUpdating"
                                    OnRowDeleting="gvOrganToTransportItemAssociation_RowDeleting"
                                    OnRowDataBound="gvOrganToTransportItemAssociation_RowDataBound"
                                    CssClass="slidsGrid"
                                    SelectedRowStyle-CssClass="slidsGridSelected"> 
                                    <Columns>
                                        <asp:TemplateField HeaderText="Organ" SortExpression="Organ.Name">  
                                            <ItemTemplate>
                                                <asp:Label ID="lblOrgan" Text='<%# Item.Organ != null ? Item.Organ.Name : String.Empty %>' CssClass="defaultLabel" runat="server" />
                                                <asp:HiddenField ID="hidOrganID" Value='<%# Item.OrganID != null ? Item.OrganID.ToString() : "0"  %>' runat="server" />
                                                <asp:HiddenField ID="hidOrganToTransportItemAssociationID" Value='<%# Item.ID %>'  runat="server" />
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:HiddenField ID="hidEditOrganToTransportItemAssociationID" runat="server" />
                                                <asp:HiddenField ID="hidEditOrganID" runat="server" />
                                                <asp:CustomValidator id="cvEditOrgan" ControlToValidate="ddlEditOrgan" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganToTransportItemAssociationInputGroup" runat="server" />
                                                <asp:DropDownList ID="ddlEditOrgan" CssClass="defaultDropDownList" runat="server" />
                                            </EditItemTemplate>
                                            <FooterTemplate>
                                                <asp:CustomValidator id="cvFooterOrgan" ControlToValidate="ddlFooterOrgan" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganToTransportItemAssociationInputGroup" runat="server" />
                                                <asp:DropDownList ID="ddlFooterOrgan" CssClass="defaultDropDownList" runat="server" />
                                            </FooterTemplate>
                                        </asp:TemplateField>

                                        <asp:TemplateField HeaderText="Commands">
                                            <HeaderTemplate>
                                                <asp:Button ID="HeaderAddNew" Text="Add new..." CommandName="HeaderAddNew" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:Button ID="Edit" Text="Edit" CommandName="Edit" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                                <asp:Button ID="Delete" Text="Delete" CommandName="Delete" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                            </ItemTemplate>
                                            <EditItemTemplate>
                                                <asp:Button ID="EditUpdate" Text="Update" CommandName="Update" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                                <asp:Button ID="EditCancel" Text="Cancel" CommandName="Cancel" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                            </EditItemTemplate>
                                            <FooterTemplate>
                                                <asp:Button ID="FooterInsert" Text="Insert" CommandName="FooterInsert" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                                <asp:Button ID="FooterCancel" Text="Cancel" CommandName="FooterCancel" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                                            </FooterTemplate>
                                        </asp:TemplateField>                  
                                    </Columns>
                                </asp:GridView>

                            </asp:Panel>
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
