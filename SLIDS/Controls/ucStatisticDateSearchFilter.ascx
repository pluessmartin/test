<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucStatisticDateSearchFilter.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucStatisticDateSearchFilter" %>

<table class="statsTable" width="100%">      
    <tr>
        <td><asp:Label ID="lblDateSearch" Text="Procurement date" runat="server" /></td>
        <td><asp:Label ID="lblProcurementDateFrom" Text="from" runat="server" /></td>
        <td class="alignRight">
            <asp:RequiredFieldValidator ID="rfvProcurementDateFrom" ControlToValidate="TxtDateFrom" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
            <asp:TextBox ID="TxtDateFrom" CssClass="smallInputTextBox" MaxLength="10" runat="server" />
            <ajaxToolkit:CalendarExtender ID="ceProcurementDateFrom" Format="dd.MM.yyyy" TargetControlID="TxtDateFrom" runat="server" />
            <ajaxToolkit:TextBoxWatermarkExtender ID="weProcurementDateFrom" runat="server" TargetControlID="TxtDateFrom" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy"></ajaxToolkit:TextBoxWatermarkExtender>
        </td>
        <td>
            <asp:CompareValidator ID="cvProcurementDateFrom" ControlToValidate="TxtDateFrom" runat="server" Operator="DataTypeCheck" Type="Date" Display="Dynamic" ForeColor="Red" ErrorMessage="*Please enter proper date" />
        </td>
    </tr>
    <tr>
        <td></td>
        <td><asp:Label ID="lblProcurementDateTo" Text="to" runat="server" /></td>
        <td class="alignRight">
            <asp:RequiredFieldValidator ID="rfvProcurementDateTo" ControlToValidate="TxtDateTo" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server"></asp:RequiredFieldValidator>
            <asp:TextBox ID="TxtDateTo" CssClass="smallInputTextBox" MaxLength="10" runat="server" />
            <ajaxToolkit:CalendarExtender ID="ceProcurementDateTo" Format="dd.MM.yyyy" TargetControlID="TxtDateTo" runat="server" />
            <ajaxToolkit:TextBoxWatermarkExtender ID="weProcurementDateTo" runat="server" TargetControlID="TxtDateTo" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy"></ajaxToolkit:TextBoxWatermarkExtender>
        </td>
        <td>
            <asp:CompareValidator ID="cvProcurementDateTo" ControlToValidate="TxtDateTo" runat="server" Operator="DataTypeCheck" Type="Date" Display="Dynamic" ForeColor="Red" ErrorMessage="*Please enter proper date" />
        </td>
    </tr>
</table>