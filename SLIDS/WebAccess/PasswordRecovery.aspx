<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="PasswordRecovery.aspx.cs" Inherits="Pentag.SLIDS.WebAccess.PasswordRecovery" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <br/>
    <asp:UpdatePanel ID="PwRecoveryPanel" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="btnPwRecovery" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlPwRecovery" GroupingText="Password reset" DefaultButton="btnPwRecovery" runat="server">
                <p>
                    <table class="margin10px">
                        <tr>
                            <td>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="UserNameLabel" runat="server" AssociatedControlID="UserName">Username:</asp:Label>
                                        </td>
                                        <td>
                                            <asp:RequiredFieldValidator ID="rfvUserName" ControlToValidate="UserName" ForeColor="Red" ErrorMessage="*" ToolTip="Username is required." Display="Dynamic" ValidationGroup="vgUserName" runat="server" />
                                            <asp:TextBox ID="UserName" runat="server" Width="150px"></asp:TextBox>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="color: Red;">
                                            <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2" style="color: Green;">
                                            <asp:Literal ID="SuccessText" runat="server" EnableViewState="False"></asp:Literal>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:Button ID="btnPwRecovery" CssClass="btn btn-default" runat="server" Text="Send password recovery link" OnClick="btnPwRecovery_Click" CausesValidation="true" ValidationGroup="vgUserName" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="2">
                                            <asp:LinkButton ID="lbBackToLogin" runat="server" Text="Back to login" PostBackUrl="~/WebAccess/Login.aspx"></asp:LinkButton>
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