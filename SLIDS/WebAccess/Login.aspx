<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="Login.aspx.cs" Inherits="Pentag.SLIDS.WebAccess.Login" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <br/>
    <asp:UpdatePanel ID="LoginPanel" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="myLogin" />
        </Triggers>
        <ContentTemplate>
            <asp:Login ID="myLogin" runat="server"
                RememberMeSet="False" 
                TitleText="" 
                UserNameLabelText="Username:" 
                OnAuthenticate="myLogin_Authenticate"
                OnLoginError="myLogin_LoginError">
                <LayoutTemplate>
                    <asp:Panel ID="pnlLogin" GroupingText="Login" DefaultButton="btnLogin" runat="server">
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
                                                    <asp:RequiredFieldValidator ID="rfvUserName" ControlToValidate="UserName" ForeColor="Red" ErrorMessage="*" ToolTip="User Name is required." Display="Dynamic" ValidationGroup="myLogin" runat="server" />
                                                    <asp:TextBox ID="UserName" runat="server" Width="150px"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="Password">Password:</asp:Label>
                                                </td>
                                                <td>
                                                    <asp:RequiredFieldValidator ID="rfvPassword" ControlToValidate="Password" ForeColor="Red" ErrorMessage="*" ToolTip="Password is required." Display="Dynamic" ValidationGroup="myLogin" runat="server" />
                                                    <asp:TextBox ID="Password" runat="server" TextMode="Password" Width="150px"></asp:TextBox>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td colspan="2" style="color:Red;">
                                                    <asp:Literal ID="FailureText" runat="server" EnableViewState="False"></asp:Literal>
                                                </td>
                                            </tr>
                                            <tr>
                                                <td>
                                                    <asp:LinkButton ID="lbPwReset" runat="server" Text="Forgot password" PostBackUrl="~/WebAccess/PasswordRecovery.aspx"></asp:LinkButton>
                                                </td>
                                                <td style="text-align:right">
                                                    <asp:Button ID="btnLogin" CssClass="btn btn-default" runat="server" CommandName="Login" Text="Log In" ValidationGroup="myLogin" />
                                                </td>
                                            </tr>
                                        </table>
                                    </td>
                                </tr>
                            </table>
                        </p>
                    </asp:Panel>
                </LayoutTemplate>
            </asp:Login>
            </ContentTemplate>
        </asp:UpdatePanel>
</asp:Content>