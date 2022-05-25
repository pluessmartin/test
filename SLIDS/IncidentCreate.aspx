<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="IncidentCreate.aspx.cs" Inherits="Pentag.SLIDS.IncidentCreate" %>

<%@ Register TagPrefix="inc" TagName="Incident" Src="~/Controls/ucIncident.ascx" %>
<%@ Register TagPrefix="inc" TagName="IncidentDocuments" Src="~/Controls/ucIncidentDocuments.ascx" %>
<%@ Register TagPrefix="inc" TagName="IncidentDonor" Src="~/Controls/ucIncidentDonor.ascx" %>
<%@ Register Assembly="AjaxControlToolkit" Namespace="AjaxControlToolkit" TagPrefix="ajaxToolkit" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <asp:UpdatePanel ID="upIncidentCreate" runat="server">
        <Triggers>
        </Triggers>
        <ContentTemplate>
            <asp:HiddenField ID="hidIncidentID" Value="0" runat="server" />
            <asp:HiddenField ID="hidGUID" runat="server" />
            <asp:Panel ID="PanelIncidentDeclaration" GroupingText="Incident Declaration" CssClass="slidsPanel" runat="server">
                <table>
                    <tbody>
                        <tr>
                            <td>
                                <inc:Incident ID="icIncidentControl" runat="server" OnDonorNrChanged="icIncidentControl_DonorNrChanged" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <inc:IncidentDocuments ID="icIncidentDocumentsControl" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <inc:IncidentDonor ID="icIncidentDonorControl" runat="server" />
                            </td>
                        </tr>
                        <tr>
                            <td>
                                <asp:Button ID="btnRegister" Text="Register" OnClick="btnSave_Click" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" CausesValidation="true" ValidationGroup="InputGroup" /></td>
                        </tr>
                    </tbody>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
