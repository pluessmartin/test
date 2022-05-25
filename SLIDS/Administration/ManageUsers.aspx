<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageUsers.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageUsers" %>

<%@ MasterType VirtualPath="~/SLIDS.Master" %>
<%@ Register TagPrefix="adr" TagName="Address" Src="~/Controls/ucAddresses.ascx" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <!-- Users List -->
    <asp:UpdatePanel ID="UserOverview" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvUser" />
            <asp:AsyncPostBackTrigger ControlID="btnSave" />
            <asp:AsyncPostBackTrigger ControlID="btnDelete" />
            <asp:AsyncPostBackTrigger ControlID="btnAddNewUser" />
        </Triggers>

        <ContentTemplate>
            <asp:Panel ID="pnlUser" GroupingText="Users" CssClass="slidsPanel" runat="server">

                <table>
                    <tr>
                        <td>
                            <asp:CheckBox ID="cbIncludeInactive" Text="Include inactive users" AutoPostBack="true" OnCheckedChanged="cbIncludeInactive_CheckedChanged" runat="server" Visible ="false" /></td>
                    </tr>
                    <tr>
                        <td>
                            <br />
                            <asp:TextBox ID="FilterText" runat="server" placeholder="Search text" AutoPostBack="true"></asp:TextBox>
                        </td>
                    </tr>
                </table>
                <asp:GridView ID="gvUser" runat="server"
                    DataKeyNames="UserName"
                    AutoGenerateColumns="False" ShowHeaderWhenEmpty="true" SelectMethod="gvUser_GetData"
                    OnSelectedIndexChanged="gvUser_SelectedIndexChanged" OnRowDataBound="gridView_RowDataBound"
                    AllowSorting="true"
                    AllowPaging="true" PageSize="10"
                    EnablePersistedSelection="true"
                    CssClass="slidsGrid" SelectedRowStyle-CssClass="slidsGridSelected" PagerStyle-CssClass="slidsGridPager">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:BoundField DataField="UserName" HeaderText="UserName" ReadOnly="true" />
                        <asp:BoundField DataField="Email" HeaderText="Email" ReadOnly="true" />
                        <asp:BoundField DataField="LastLoginDate" DataFormatString="{0:d}" HeaderText="Last Login" HtmlEncode="False" ReadOnly="True" />
                        <asp:TemplateField HeaderText="Locked Out?" ItemStyle-HorizontalAlign="Center" SortExpression="IsLockedOut">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbIsLockedOut" Enabled="false" Checked='<%# Eval("IsLockedOut") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Active" ItemStyle-HorizontalAlign="Center" SortExpression="IsApproved">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbIsApproved" Enabled="false" Checked='<%# Eval("IsApproved") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:BoundField DataField="Comment" HeaderText="Comment" ReadOnly="true" />
                        <asp:TemplateField HeaderText="AAA" ItemStyle-HorizontalAlign="Center" SortExpression="IsAAA">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbAAA" Enabled="false" Checked='<%# Eval("IsAAA") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Admin" ItemStyle-HorizontalAlign="Center" SortExpression="IsAdmin">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbAdmin" Enabled="false" Checked='<%# Eval("IsAdmin") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Incident Admin" ItemStyle-HorizontalAlign="Center" SortExpression="IsIncidentAdmin">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbIncidentAdmin" Enabled="false" Checked='<%# Eval("IsIncidentAdmin") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Incident User" ItemStyle-HorizontalAlign="Center" SortExpression="IsIncidentUser">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbIncidentUser" Enabled="false" Checked='<%# Eval("IsIncidentUser") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="NC" ItemStyle-HorizontalAlign="Center" SortExpression="IsNC">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbNC" Enabled="false" Checked='<%# Eval("IsNC") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Swisstransplant" ItemStyle-HorizontalAlign="Center" SortExpression="IsSwisstransplant">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbSwisstransplant" Enabled="false" Checked='<%# Eval("IsSwisstransplant") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="TC" ItemStyle-HorizontalAlign="Center" SortExpression="IsTC">
                            <ItemTemplate>
                                <asp:CheckBox runat="server" ID="cbTC" Enabled="false" Checked='<%# Eval("IsTC") %>'></asp:CheckBox>
                            </ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

    <asp:Button ID="btnAddNewUser" runat="server" Text="Add New..." CssClass="largeAddNewButton btn btn-default" OnClick="btnAddNewUser_Click" CausesValidation="false" />

    <asp:UpdatePanel ID="UserDetails" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvUser" />
        </Triggers>
        <ContentTemplate>
            <asp:Panel ID="pnlUserDetails" GroupingText="User detail" Visible="false" CssClass="slidsPanel" runat="server">
                <asp:HiddenField ID="hidUserName" Value="" runat="server" />
                <table id="tblUserDetails" runat="server">
                    <tr>
                        <td>*
                            <asp:Label ID="lblUserName" Text="Username" runat="server" /></td>
                        <td>
                            <asp:TextBox ID="txtUserName" CssClass="defaultInputTextBox" Enabled="false" runat="server" /></td>
                        <td style="vertical-align: top">
                            <asp:Label ID="lblComment" Text="Comment" runat="server" /></td>
                        <td rowspan="3" style="vertical-align: top">
                            <asp:TextBox ID="txtComment" TextMode="MultiLine" Columns="40" Rows="3" runat="server"></asp:TextBox>
                        </td>
                    </tr>
                    <tr>
                        <td>*
                            <asp:Label ID="lblEmail" Text="Email" runat="server" /></td>
                        <td colspan="3" style="vertical-align: top">
                            <asp:RequiredFieldValidator ID="rfvEmail" ControlToValidate="txtEmail" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                            <asp:TextBox ID="txtEmail" CssClass="defaultInputTextBox" MaxLength="256" runat="server" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:RegularExpressionValidator ID="RegularExpressionValidator1" runat="server"
                                ControlToValidate="txtEmail"
                                Display="Dynamic"
                                ErrorMessage="The email address you have entered is not valid. Please fix this and try again."
                                SetFocusOnError="True"
                                ValidationExpression="\w+([-+.']\w+)*@\w+([-.]\w+)*\.\w+([-.]\w+)*"
                                ValidationGroup="InputGroup">
                            </asp:RegularExpressionValidator>
                        </td>
                        <td colspan="2"></td>
                    </tr>
                    <tr id="trPW">
                        <td>*
                            <asp:Label ID="PasswordLabel" runat="server" AssociatedControlID="txtPassword" Text="Password:" /></td>
                        <td>
                            <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" CssClass="defaultInputTextBox" />
                            <asp:RequiredFieldValidator ID="PasswordRequired" runat="server" ControlToValidate="txtPassword" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ToolTip="Password is required." ValidationGroup="InputGroup" />
                        </td>
                    </tr>
                    <tr id="trConfirmPW">
                        <td>*
                            <asp:Label ID="ConfirmPasswordLabel" runat="server" AssociatedControlID="txtConfirmPassword" CssClass="defaultLabel" Text="Confirm Password:" /></td>
                        <td>
                            <asp:TextBox ID="txtConfirmPassword" runat="server" TextMode="Password" CssClass="defaultInputTextBox" />
                            <asp:RequiredFieldValidator ID="ConfirmPasswordRequired" runat="server" ControlToValidate="txtConfirmPassword" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ToolTip="Confirm Password is required." ValidationGroup="InputGroup" />
                        </td>
                    </tr>
                    <tr>
                        <td colspan="2">
                            <asp:CompareValidator ID="PasswordCompare" runat="server" ControlToCompare="txtPassword" ForeColor="Red" ControlToValidate="txtConfirmPassword" Display="Dynamic" ErrorMessage="The Password and Confirmation Password must match." ValidationGroup="InputGroup"></asp:CompareValidator>
                        </td>
                    </tr>
                    <tr>
                        <td colspan="4" style="vertical-align: top">
                            <asp:CheckBox ID="cbIsLockedOut" Text="User is locked out" runat="server" /></td>
                    </tr>
                    <tr>
                        <td>
                            <asp:Button ID="btnResetPassword" Text="Reset password" OnClick="btnResetPassword_Click" CssClass="largeButton btn btn-default" AccessKey="R" runat="server" /></td>
                    </tr>
                </table>
                <table>
                    <tr>
                        <td style="vertical-align: top;">
                            <asp:Panel ID="pnlRoles" GroupingText="Roles" CssClass="slidsPanel" runat="server">
                                <asp:CheckBoxList ID="cblRoles" runat="server" OnSelectedIndexChanged="cblRoles_SelectedIndexChanged" AutoPostBack="true" />
                            </asp:Panel>
                        </td>
                        <td>
                            <asp:Panel ID="pnlCoordinator" GroupingText="Coordinator" CssClass="slidsPanel" runat="server">

                                <asp:HiddenField ID="hidCoordinatorID" Value="0" runat="server" />
                                <table id="tblCoordinatorDetails" runat="server">
                                    <tr>
                                        <td>*
                                            <asp:Label ID="lblLastName" Text="Lastname" runat="server" /></td>
                                        <td>
                                            <asp:RequiredFieldValidator ID="rfvLastName" ControlToValidate="txtLastName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                                            <asp:TextBox ID="txtLastName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                                        </td>
                                        <td>*
                                            <asp:Label ID="lblHospital" Text="Hospital" runat="server" /></td>
                                        <td>
                                            <asp:DropDownList ID="ddlHospital" CssClass="defaultDropDownList" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>*
                                            <asp:Label ID="lblFirstName" Text="Firstname" runat="server" /></td>
                                        <td>
                                            <asp:RequiredFieldValidator ID="rfvFirstName" ControlToValidate="txtFirstName" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                                            <asp:TextBox ID="txtFirstName" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td colspan="4">
                                            <adr:Address ID="ucAddressControl" runat="server" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </td>
                    </tr>
                </table>
                <table style="width: 100%">
                    <tr>
                        <td>
                            <asp:Button ID="btnSave" Text="Save" OnClick="btnSave_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" /></td>
                        <td colspan="3" class="alignRight">
                            <asp:Button ID="btnActiveHandling" OnClick="btnActiveHandling_Click" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" Visible="false" />
                            <asp:Button ID="btnDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this user?');" OnClick="btnDelete_Click" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" /></td>
                    </tr>
                </table>
            </asp:Panel>
        </ContentTemplate>
    </asp:UpdatePanel>

</asp:Content>
