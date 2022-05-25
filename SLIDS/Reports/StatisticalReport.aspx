<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="StatisticalReport.aspx.cs" Inherits="Pentag.SLIDS.Reports.StatisticalReport" %>

<%@ Register TagPrefix="stat" TagName="Statistic" Src="~/Controls/ucStatisticDateSearchFilter.ascx" %>
<%@ Register Assembly="Microsoft.ReportViewer.WebForms, Version=11.0.0.0, Culture=neutral, PublicKeyToken=89845dcd8080cc91" Namespace="Microsoft.Reporting.WebForms" TagPrefix="rsweb" %>

<asp:Content ID="Content2" ContentPlaceHolderID="StatsContentPlaceHolder" runat="server">
    
   <asp:UpdatePanel ID="upFilter" runat="server" UpdateMode="Conditional">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnCreate"/>
            <asp:AsyncPostBackTrigger ControlID="ucStatisticDateSearchFilterControl"/>
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlSearchFilter" runat="server" GroupingText="Search Filter">
               <table>
                    <tr>
                        <td>
                            <stat:Statistic ID="ucStatisticDateSearchFilterControl" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <table width="100%">
                                <tr>
                                    <td class="alignRight">
                                        <asp:Button ID="btnCreate" runat="server" Text="Create" OnClick="btnCreate_Click" CssClass="defaultButton btn btn-default" />
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

    <br />
    
    <asp:UpdatePanel ID="upStatisticalReport" runat="server" UpdateMode="Conditional">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnCreate"/>
            <asp:AsyncPostBackTrigger ControlID="rvStatisticalReport"/>
            <asp:AsyncPostBackTrigger ControlID="ucStatisticDateSearchFilterControl"/>
        </Triggers>
        <ContentTemplate>
            <asp:PlaceHolder runat="server" ID="phReports">
                <asp:HiddenField runat="server" ID="hidOrganGroupHeart" />
                <asp:HiddenField runat="server" ID="hidOrganGroupLung" />
                <asp:HiddenField runat="server" ID="hidOrganGroupLiver" />
                <asp:HiddenField runat="server" ID="hidOrganGroupKidney" />
                <asp:HiddenField runat="server" ID="hidOrganGroupPancreas" />
                <asp:HiddenField runat="server" ID="hidOrganGroupSmallBowel" />
                
                <asp:HiddenField runat="server" ID="hidOrganItemGroupType" />
                <asp:HiddenField runat="server" ID="hidTransportItemGroupType" />

                <rsweb:ReportViewer ID="rvStatisticalReport" runat="server" 
                                    InteractivityPostBackMode="AlwaysSynchronous" 
                                    Width="100%" SizeToReportContent="true"
                                    AsyncRendering="False"
                                    ProcessingMode="Local"
                                    ShowParameterPrompts="False"
                                    BackColor="#F8F8F8" Font-Size="8pt" WaitMessageFont-Size="14pt"
                                    ShowFindControls="false" ShowZoomControl="false">
                    <LocalReport ReportPath="Reports\StatisticalReport.rdlc" EnableHyperlinks="true">
                        <DataSources>
                            <rsweb:ReportDataSource DataSourceId="dsFilterDataValue" Name="DataSetFilterDataValue" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerRemovedOrganOverall" Name="DataSetTransportCostPerRemovedOrganOverall" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehicleOverall" Name="DataSetTransportCostPerVehicleOverall" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerHeart" Name="DataSetTransportCostPerVehiclePerHeart" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerLung" Name="DataSetTransportCostPerVehiclePerLung" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerLiver" Name="DataSetTransportCostPerVehiclePerLiver" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerKidney" Name="DataSetTransportCostPerVehiclePerKidney" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerPancreas" Name="DataSetTransportCostPerVehiclePerPancreas" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerVehiclePerSmallBowel" Name="DataSetTransportCostPerVehiclePerSmallBowel" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportCostPerItemGroup" Name="DataSetTransportCostPerItemGroup" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportPerOrganItemGroupAndVehicle" Name="DataSetTransportPerOrganItemGroupAndVehicle" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportPerTransportItemGroupAndVehicle" Name="DataSetTransportPerTransportItemGroupAndVehicle" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportDuration" Name="DataSetTransportDuration" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportDurationChart" Name="DataSetTransportDurationChart" />
                            <rsweb:ReportDataSource DataSourceId="dsStatisticNumbersPerMonth" Name="DataSetStatisticNumbersPerMonth" />
                            <rsweb:ReportDataSource DataSourceId="dsStatisticNumbersOverall" Name="DataSetStatisticNumbersOverall" />
                            <rsweb:ReportDataSource DataSourceId="dsWaitingDurationPerVehicle" Name="DataSetWaitingDurationPerVehicle" />
                            <rsweb:ReportDataSource DataSourceId="dsProcurementPerTeam" Name="DataSetProcurementPerTeam" />
                            <rsweb:ReportDataSource DataSourceId="dsBloodTransportDuration" Name="DataSetBloodTransportDuration" />
                            <rsweb:ReportDataSource DataSourceId="dsTransportDelay" Name="DataSetTransportDelay" />
                        </DataSources>
                    </LocalReport>
                </rsweb:ReportViewer>
                
                <asp:ObjectDataSource ID="dsFilterDataValue" runat="server" SelectMethod="GetFilterDataValue" TypeName="Pentag.SLIDS.Reports.DAL.FilterData">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>

                <asp:ObjectDataSource ID="dsTransportCostPerRemovedOrganOverall" runat="server" SelectMethod="GetTransportCostPerRemovedOrganOverall" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehicleOverall" runat="server" SelectMethod="GetTransportCostPerVehicleOverall" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerHeart" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupHeart" Name="organItemGroupID" PropertyName="Value" DefaultValue="1" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerLung" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupLung" Name="organItemGroupID" PropertyName="Value" DefaultValue="2" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerLiver" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupLiver" Name="organItemGroupID" PropertyName="Value" DefaultValue="3" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerKidney" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupKidney" Name="organItemGroupID" PropertyName="Value" DefaultValue="4" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerPancreas" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupPancreas" Name="organItemGroupID" PropertyName="Value" DefaultValue="5" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
        
                <asp:ObjectDataSource ID="dsTransportCostPerVehiclePerSmallBowel" runat="server" SelectMethod="GetTransportCostPerVehiclePerOrgan" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganGroupSmallBowel" Name="organItemGroupID" PropertyName="Value" DefaultValue="6" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportCostPerItemGroup" runat="server" SelectMethod="GetTransportCostPerItemGroup" TypeName="Pentag.SLIDS.Reports.DAL.TransportCost">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportPerOrganItemGroupAndVehicle" runat="server" SelectMethod="GetNumberOfTransportsPerItemGroupAndVehicle" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidOrganItemGroupType" Name="itemGroupType" PropertyName="Value" DefaultValue="1" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportPerTransportItemGroupAndVehicle" runat="server" SelectMethod="GetNumberOfTransportsPerItemGroupAndVehicle" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="hidTransportItemGroupType" Name="itemGroupType" PropertyName="Value" DefaultValue="2" Type="Int32" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportDuration" runat="server" SelectMethod="GetTransportDuration" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportDurationChart" runat="server" SelectMethod="GetTransportDurationChart" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsStatisticNumbersPerMonth" runat="server" SelectMethod="GetStatisticNumbersPerMonth" TypeName="Pentag.SLIDS.Reports.DAL.StatisticNumbers">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsStatisticNumbersOverall" runat="server" SelectMethod="GetStatisticNumbersOverall" TypeName="Pentag.SLIDS.Reports.DAL.StatisticNumbers">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsWaitingDurationPerVehicle" runat="server" SelectMethod="GetWaitingDurationPerVehicle" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsProcurementPerTeam" runat="server" SelectMethod="GetProcurementPerTeam" TypeName="Pentag.SLIDS.Reports.DAL.Procurement">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsBloodTransportDuration" runat="server" SelectMethod="GetBloodTransportDuration" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
                
                <asp:ObjectDataSource ID="dsTransportDelay" runat="server" SelectMethod="GetTransportDelay" TypeName="Pentag.SLIDS.Reports.DAL.Transport">
                    <SelectParameters>
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateFrom" PropertyName="DateFrom" DefaultValue="" Type="DateTime" />
                        <asp:ControlParameter ControlID="ucStatisticDateSearchFilterControl" Name="procurementDateTo" PropertyName="DateTo" DefaultValue="" Type="DateTime" />
                    </SelectParameters>
                </asp:ObjectDataSource>
            </asp:PlaceHolder>  
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
