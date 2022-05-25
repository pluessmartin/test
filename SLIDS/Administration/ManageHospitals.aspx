<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageHospitals.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageHospitals" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>
<%@ Register TagPrefix="adr" TagName="Address" Src="~/Controls/ucAddresses.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Hospital List -->
    <asp:UpdatePanel ID="HospitalOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvHospital" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnActiveHandling" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewHospital" />
            <asp:AsyncPostBackTrigger ControlID="cbIncludeInactive" />
        </Triggers>

        <ContentTemplate>
            <table>
                <tr>
                    <td>
                        <asp:CheckBox ID="cbIncludeInactive" Text="Include inactive Hospitals" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" />
                    </td>
                </tr>
                <tr>
                    <td>
                        <br />
                        <asp:TextBox ID="FilterText" runat="server" placeholder="Search text" AutoPostBack="true"></asp:TextBox>
                    </td>
                </tr>
            </table>
            <asp:Panel ID="pnlHospital" GroupingText="Hospitals" CssClass="slidsPanel" runat="server">

                <asp:GridView ID="gvHospital" runat="server" ItemType="Pentag.SLIDS.DAL.Hospital" SelectMethod="gvHospital_GetData"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    OnSelectedIndexChanged="gvHospital_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Name" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Code" SortExpression="Code">  
                            <ItemTemplate> <%# Item.Code ?? String.Empty  %></ItemTemplate>  
                        </asp:TemplateField>
                         <asp:TemplateField HeaderText="Display" SortExpression="Display">  
                            <ItemTemplate> <%# Item.Display ?? String.Empty %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Address">  
                            <ItemTemplate> <%# GetAddress(Item) %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is Referral" SortExpression="IsReferral" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsReferral" runat="server" Enabled="false" Checked='<%# Item.IsReferral %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is Procurement" SortExpression="IsProcurement" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsProcurement" runat="server" Enabled="false" Checked='<%# Item.IsProcurement %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is Transplantation" SortExpression="IsTransplantation" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsTransplantation" runat="server" Enabled="false" Checked='<%# Item.IsTransplantation %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Is FO" SortExpression="IsFo" ItemStyle-HorizontalAlign="Center">  
                            <ItemTemplate>
                                <asp:CheckBox ID="cbIsFo" runat="server" Enabled="false" Checked='<%# Item.IsFo %>'></asp:CheckBox>
                            </ItemTemplate>  
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
                <asp:HiddenField ID="hidPageIndex" Value="0" runat="server" />
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewHospital" runat="server" Text="Add New..." OnClick="btnAddNewHospital_Click" CssClass="addNewButton btn btn-default" CausesValidation="false" />

    <asp:UpdatePanel ID="HospitalDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvHospital" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlHospitalDetails" GroupingText="Hospital detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidHospitalID" Value="0" runat="server" />
                <table id="tblHospitalDetails" runat="server">
                    <tr>
                        <td><asp:Label ID="lblName" Text="*Name" runat="server" /></td>
                        <td>
                            <asp:CustomValidator ID="rfvName" OnServerValidate="cvName_ServerValidate" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtName" CssClass="defaultInputTextBox" MaxLength="128" runat="server" />
                        </td>
                        <td><asp:CheckBox ID="cbIsReferral" Text="Is referral" runat="server" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblCode" Text="*Code" runat="server" /></td>
                        <td>
                            <asp:CustomValidator ID="cvCode" OnServerValidate="cvCode_ServerValidate" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtCode" CssClass="defaultInputTextBox" MaxLength="16" runat="server" />
                        </td>
                        <td><asp:CheckBox ID="cbIsProcurement" Text="Is procurement" runat="server" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblDisplay" Text="*Display" runat="server" /></td>
                        <td>
                            <asp:CustomValidator ID="rfvDisplay" OnServerValidate="cvDisplay_ServerValidate" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtDisplay" CssClass="defaultInputTextBox" MaxLength="128" runat="server" />
                        </td>
                        <td><asp:CheckBox ID="cbIsTransplantation" Text="Is transplantation" runat="server" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblLanguage" Text="*Language of correspondance" runat="server" /></td>
                        <td>
                            <asp:CustomValidator id="cvLanguage" ControlToValidate="ddlLanguage" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                            <asp:DropDownList ID="ddlLanguage" CssClass="defaultDropDownList" runat="server" />
                        </td>
                        <td><asp:CheckBox ID="cbIsFo" Text="Is FO" runat="server" /></td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <adr:Address ID="ucAddressControl" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4">
                            <adr:Address ID="ucAcountingAddressControl" runat="server" />
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
