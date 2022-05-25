<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="PasswordResetWithToken.aspx.cs" Inherits="Pentag.SLIDS.WebAccess.PasswordResetWithToken" %>

<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <asp:UpdatePanel ID="PasswordResetOverview" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlPasswordReset" GroupingText="Reset user password" DefaultButton="btnUpdate" CssClass="smallPanel" runat="server">
                <table class="margin10px">
                    <tr>
                        <td>
                            <asp:Label ID="lblNewPassword" Text="*New Password:" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator runat="server" ID="rfvNewPassword1" ControlToValidate="NewPassword1" Text="*" ForeColor="red" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="NewPassword1" TextMode="Password" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Label ID="lblConfirmNewPassword" Text="*Confirm New Password:" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator runat="server" ID="rfvNewPassword2" ControlToValidate="NewPassword2" Text="*" ForeColor="red" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="NewPassword2" TextMode="Password" runat="server"></asp:TextBox><br />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:CompareValidator ID="PwdCompareValidator" runat="server"
                                ControlToCompare="NewPassword1"
                                ControlToValidate="NewPassword2"
                                Type="String"
                                Display="Dynamic"
                                Text="The entered password values do not match."
                                ForeColor="red"
                                ValidationGroup="InputGroup"
                                EnableClientScript="false">
                            </asp:CompareValidator>
                        </td>
                    </tr>
                    <tr>
                        <td>
                            <asp:LinkButton ID="lbBackToLogin" runat="server" Text="To login" PostBackUrl="~/WebAccess/Login.aspx"></asp:LinkButton>
                        </td>
                        <td style="text-align: right">
                            <asp:Button ID="btnUpdate" CssClass="btn btn-default" runat="server" Text="Update Password" OnClick="UpdateUser_Click" />
                        </td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
