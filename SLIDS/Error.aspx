<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Error.aspx.cs" Inherits="Pentag.SLIDS.Error" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <asp:UpdatePanel ID="TransportOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger controlid="showErrorDetails" />
        </Triggers>

        <ContentTemplate>
            <div>
                <h1><asp:Literal ID="litErrorOccured" runat="server" Text="Oops! ...an unexpected error has occured!" /></h1>
                <br />

                <asp:LinkButton ID="showErrorDetails" Text="Show/hide error detail" OnClick="showErrorDetails_Click" runat="server" />
                <br />

                <asp:Literal ID="litErrorMessage" runat="server" Visible="false" />
                <br /><br />
        
                <asp:LinkButton ID="lbBackToHome" runat="server" Text="Back to start page" />
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>

