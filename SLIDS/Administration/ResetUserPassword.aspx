<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ResetUserPassword.aspx.cs" Inherits="Pentag.SLIDS.Administration.ResetUserPassword" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">
    <asp:UpdatePanel ID="OrganOverview" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <asp:Panel ID="pnlLogin" GroupingText="Reset user password" DefaultButton="btnUpdate" CssClass="smallPanel" runat="server">
                <table class="margin10px">
                    <tr>
                        <td><asp:Label ID="lblUserName" Text="Username:" runat="server" /></td>
                        <td><asp:Label runat="server" ID="UserNameLabel" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblAccountCreated" Text="Account Created:" runat="server" /></td>
                        <td><asp:Label runat="server" ID="CreationDateLabel" /></td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblPasswordLastChanged" Text="Password Last Changed:" runat="server" /></td>
                        <td><asp:Label runat="server" ID="LastPasswordChangedDateLabel" /></td>
                    </tr>
                    <tr>
                        <td colspan="2">&nbsp;</td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblNewPassword" Text="*New Password:" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator runat="server" ID="rfvNewPassword1" ControlToValidate="NewPassword1" Text="*" ForeColor="red" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="NewPassword1" TextMode="Password" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td><asp:Label ID="lblConfirmNewPassword" Text="*Confirm New Password:" runat="server" /></td>
                        <td>
                            <asp:RequiredFieldValidator runat="server" ID="rfvNewPassword2" ControlToValidate="NewPassword2" Text="*" ForeColor="red" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="NewPassword2" TextMode="Password" runat="server"></asp:TextBox><br/>
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
                        <td><asp:Button ID="btnCancel" runat="server" CssClass="btn btn-default" CausesValidation="false" Text="Cancel" OnClientClick="history.go(-1); return true;" /></td>
                        <td style="text-align:right"><asp:Button ID="btnUpdate" CssClass="btn btn-default" runat="server" Text="Update User" onclick="UpdateUser_Click" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
