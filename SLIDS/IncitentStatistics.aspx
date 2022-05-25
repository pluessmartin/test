<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="IncitentStatistics.aspx.cs" MasterPageFile="~/SLIDS.Master" Inherits="Pentag.SLIDS.IncitentStatistics" %>
<%@ Register TagPrefix="stat" TagName="Statistic" Src="~/Controls/ucStatisticDateSearchFilter.ascx" %>

<asp:Content ID="Content2" ContentPlaceHolderID="StatsContentPlaceHolder" runat="server">

     <asp:Panel ID="pnlSearchFilter" runat="server" GroupingText="Filter">
        <table class="statsTable">
            <tr>
                <td>
                    <stat:Statistic ID="ucStatisticDateSearchFilterControl" runat="server" />
                </td>
            </tr>
            <tr>
                <td>
                    <table class="statsTable" width="100%" >
                        <tr>
                            <td class="alignRight">
                                <asp:Button ID="btnCreate" runat="server" Text="Download" OnClick="btnCreate_Click" CssClass="defaultButton btn btn-default" />
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
        </table>
    </asp:Panel>
</asp:Content>