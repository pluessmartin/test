<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="ManageUserAndRoleAllocation.aspx.cs" Inherits="Pentag.SLIDS.Administration.ManageUserAndRoleAllocation" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <asp:UpdatePanel ID="OrganOverview" UpdateMode="Always" runat="server">
        <ContentTemplate>
            <asp:Panel id="pnlManageUserAndRoleAllocations" GroupingText="Manage user and role allocations" CssClass="slidsPanel" runat="server" >

                <table>
                    <tr>
                        <td style="vertical-align:top">
                            <asp:panel id="PanelRolesAllocatedToUser" GroupingText="Manage roles allocated to user" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td><asp:Label ID="lblSelectUser" Text="Select a User:" Font-Bold="true" Width="10em" runat="server" /></td>
                                        <td><asp:DropDownList ID="UserList" runat="server" AutoPostBack="True" DataTextField="UserName" DataValueField="UserName" OnSelectedIndexChanged="UserList_SelectedIndexChanged" CssClass="defaultDropDownList" /></td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align:top"><asp:Label ID="lblAllocatedRoles" Text="Allocated roles:" runat="server" /></td>
                                        <td style="vertical-align:top">
                                            <asp:Repeater ID="RolesAllocatedToUser" runat="server">
                                                <ItemTemplate>
                                                    <asp:CheckBox ID="RoleAllocatedToUserCheckBox" runat="server" AutoPostBack="true" Text='<%# Container.DataItem %>' OnCheckedChanged="RoleAllocatedToUserCheckBox_CheckChanged" />
                                                    <br />
                                                </ItemTemplate>
                                            </asp:Repeater>
                                        </td>
                                    </tr>
                                </table>
                            </asp:panel>
                        </td>
                        <td style="vertical-align:top">
                            <asp:panel id="PanelUsersAllocatedToRole" GroupingText="Manage users allocated to role" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td><asp:Label ID="lblSelectRole" Text="Select a Role:" Font-Bold="true" Width="10em" runat="server" /></td>
                                        <td><asp:DropDownList ID="RoleList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="RoleList_SelectedIndexChanged" CssClass="defaultDropDownList" /></td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align:top"><asp:Label ID="lblAllocatedUsers" Text="Allocated users:" runat="server" /></td>
                                        <td style="vertical-align:top">
                                            <asp:GridView ID="UsersAllocatedToRolesList" runat="server" 
                                                AutoGenerateColumns="False" 
                                                EmptyDataText="No users belong to this role." 
                                                OnRowDeleting="UsersAllocatedToRolesList_RowDeleting"
                                                CssClass="slidsGrid">
                                                <Columns>
                                                    <asp:CommandField DeleteText="Remove" ShowDeleteButton="True" ItemStyle-Width="60" />
                                                    <asp:TemplateField HeaderText="Users" HeaderStyle-HorizontalAlign="Left" ItemStyle-Width="140">
                                                        <ItemTemplate>
                                                            <asp:Label runat="server" id="UserNameLabel" Text='<%# Container.DataItem %>'></asp:Label>
                                                        </ItemTemplate>
                                                    </asp:TemplateField>
                                                </Columns>
                                            </asp:GridView>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td><b>UserName:</b></td>
                                        <td><asp:DropDownList ID="UserToAllocateToRoleList" runat="server" AutoPostBack="False" DataTextField="UserName" DataValueField="UserName" CssClass="defaultDropDownList" /></td>
                                    </tr>
                                    <tr>
                                        <td></td>
                                        <td><asp:Button ID="Button1" runat="server" Text="Allocate User to Role" onclick="UserToAllocateToRoleButton_Click" /></td>
                                    </tr>
                                </table>
                            </asp:panel>
                        </td>
                    </tr>
                </table>
            </asp:Panel>

        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
