<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Authenticate.aspx.cs" Inherits="Pentag.SLIDS.WebAccess.Authenticate" %>


<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <br/>
    <asp:UpdatePanel ID="AuthenticatePanel" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnAuthenticate" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlAuthenticate" GroupingText="2-Factor-Authentication" DefaultButton="btnAuthenticate" runat="server">
                <p>
                    <table class="margin10px">
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="InfoLabel" runat="server">E-mail with token has been sent to:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:Label ID="EmailLabel" runat="server"></asp:Label>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="TokenLabel" runat="server" AssociatedControlID="Token">Token:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:RequiredFieldValidator ID="rfvToken" ControlToValidate="Token" ForeColor="Red" ErrorMessage="*" ToolTip="Token is required." Display="Dynamic" ValidationGroup="Authenticate" runat="server" />
                                            <asp:TextBox ID="Token" runat="server" Width="150px" TextMode="Password" autocomplete="new-password" AutoCompleteType="None"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="color: Red;">
                                            <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:LinkButton ID="lbResendToken" runat="server" Text="Send e-mail again" OnClick="lbResendToken_Click"/>
                                        </td>
                                        <td style="text-align: right">
                                            <asp:Button ID="btnAuthenticate" CssClass="btn btn-default" runat="server" Text="Authenticate" OnClick="btnAuthenticate_Click" CausesValidation="true" ValidationGroup="Authenticate"/>
                                        </td>
                                    </tr>
                                </table>
                            </td>
                        </tr>
                    </table>
                </p>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
