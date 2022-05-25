<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="FinancialReport.aspx.cs" Inherits="Pentag.SLIDS.Reports.FinancialReport" %>
<%@ Register TagPrefix="stat" TagName="Statistic" Src="~/Controls/ucStatisticDateSearchFilter.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    
    <asp:UpdatePanel ID="SearchFilter" UpdateMode="Conditional" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlSearchFilter" runat="server" GroupingText="Search Filter">
                <table>
                    <tr>
                        <td>
                            <stat:Statistic ID="ucStatisticDateSearchFilterControl" runat="server" ValidationGroup="Input" />
                            <asp:HiddenField runat="server" ID="hidRegisterDateFrom" Value="" />
                            <asp:HiddenField runat="server" ID="hidRegisterDateTo" Value="" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td class="alignRight">
                                        <asp:Button ID="btnSearch" runat="server" Text="Search" OnClick="btnSearch_Click" CssClass="defaultButton btn btn-default" />
                                    </td>
                                    <td></td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
    
    <asp:UpdatePanel ID="ProcurementHospitalOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="btnSearch" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlProcurementHospital" GroupingText="Financial Reports" Visible="False" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvProcurementHospital" runat="server" ItemType="Pentag.SLIDS.Reports.DAL.ProcurementHospitalWithCosts" 
                    SelectMethod="gvProcurementHospital_GetProcurementHospital"
                    OnRowDataBound="gvProcurementHospital_RowDataBound"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid" 
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Procurement Hospital" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Hospital Code" SortExpression="Display">  
                            <ItemTemplate> <%# Item.Display %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Costs IC"> 
                            <ItemTemplate><%# Eval("ICCosts", "{0:c}") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Costs OR">  
                            <ItemTemplate> <%# Eval("OCCosts", "{0:c}") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Total Costs IC/OR">  
                            <ItemTemplate> <%# Eval("TotalCosts", "{0:c}") %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Doc">
                            <ItemTemplate>  <a href="<%# String.Format("FinancialReportViewPDF.aspx?hID={0}&procDateFrom={1}&procDateTo={2}", Item.ID, Convert.ToDateTime(RegisterDateFrom).ToShortDateString(), Convert.ToDateTime(RegisterDateTo).ToShortDateString()) %>" target="_blank"><img alt="down" src="../resources/file_download.png" /></a> </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
    
    <asp:UpdatePanel ID="UpdatePanel1" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="btnSearch" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlReminderLetter" GroupingText="Reminder letter" Visible="False" CssClass="slidsPanel" runat="server">
                <asp:GridView ID="gvReminderLetter" runat="server" ItemType="Pentag.SLIDS.DAL.Hospital" 
                    SelectMethod="gvReminderLetter_GetProcurementHospital"
                    OnRowDataBound="gvReminderLetter_RowDataBound"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid" 
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    EnableViewState="False"
                    PagerStyle-CssClass="slidsGridPager"> 
                    <Columns>
                        <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Procurement Hospital" SortExpression="Name">  
                            <ItemTemplate> <%# Item.Name %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Hospital Code" SortExpression="Display">  
                            <ItemTemplate> <%# Item.Display %></ItemTemplate>  
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Doc">
                            <ItemTemplate>
                                  <a href="<%# String.Format("ReminderLetterViewPDF.aspx?hID={0}&lang={1}&procDateFrom={2}&procDateTo={3}", Item.ID, Item.Language != null ? Item.Language.LanguageShort : String.Empty, Convert.ToDateTime(RegisterDateFrom).ToShortDateString(), Convert.ToDateTime(RegisterDateTo).ToShortDateString()) %>" target="_blank"><img alt="down" src="../resources/file_download.png" /></a> 
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
