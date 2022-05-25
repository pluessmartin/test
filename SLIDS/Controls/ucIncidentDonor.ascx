<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucIncidentDonor.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucIncidentDonor" %>

<asp:CheckBox ID="chkisplayAddDonorReleatedInformation" Text="Display/add Donor releated Information" runat="server" OnCheckedChanged="chkisplayAddDonorReleatedInformation_CheckedChanged" AutoPostBack="true" Visible="false" />

<asp:UpdatePanel ID="upAddDonorReleatedInformation" runat="server">
    <Triggers>
    </Triggers>
    <ContentTemplate>
        <table>
            <tbody>
                <tr>
                    <td>
                        <asp:Panel ID="panelAddDonorReleatedInformation" GroupingText="Add Donor releated Information" CssClass="slidsPanel" runat="server" Visible="false">
                            <table>
                                <tbody>
                                    <tr>
                                        <td>
                                            <asp:Panel ID="panelOrgans" GroupingText="Organs" CssClass="slidsPanel" runat="server">
                                                <asp:GridView ID="gvOrgans" runat="server" ItemType="Pentag.SLIDS.DAL.TransplantOrgan"
                                                    SelectMethod="gvOrgans_GetData" OnRowDataBound="gridView_RowDataBound"
                                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                                    AllowSorting="true"
                                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                                    CssClass="slidsGrid"
                                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                                    PagerStyle-CssClass="slidsGridPager">
                                                    <Columns>
                                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:CheckBox ID="chkOrganTable" runat="server" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Organ">
                                                            <ItemTemplate><a href="Organ.aspx?donorID=<%# Item.DonorID %>&transplantOrganID=<%# Item.ID %>"><%# Item.Organ.Name %></a></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Transplant Center">
                                                            <ItemTemplate><%# Item.Hospital1 == null ? String.Empty : Item.Hospital1.Display %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="TC">
                                                            <ItemTemplate><%# Item.Coordinator == null ? String.Empty : Item.Coordinator.Code %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Graft Box No">
                                                            <ItemTemplate><%# Item.GraftBoxNo %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Procurement Team">
                                                            <ItemTemplate><%# Item.Hospital == null ? String.Empty : Item.Hospital.Display %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Procurement Surgeon">
                                                            <ItemTemplate><%# Item.ProcurementSurgeon %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Status">
                                                            <ItemTemplate><%# Item.TransplantStatus == null ? String.Empty : Item.TransplantStatus.Name %></ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Panel ID="panelTransports" GroupingText="Transports" CssClass="slidsPanel" runat="server">
                                                <asp:GridView ID="gvTransports" runat="server" ItemType="Pentag.SLIDS.DAL.Transport"
                                                    SelectMethod="gvTransports_GetData" OnRowDataBound="gridView_RowDataBound"
                                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                                    AllowSorting="true"
                                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                                    CssClass="slidsGrid"
                                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                                    PagerStyle-CssClass="slidsGridPager">
                                                    <Columns>
                                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:CheckBox ID="chkTransportTable" runat="server" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Transported Organs">
                                                            <ItemTemplate><a href="Transport.aspx?donorID=<%# Item.DonorID %>&transportID=<%# Item.ID %>"><%# GetTransportedElements(Item) %></a></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Departed from">
                                                            <ItemTemplate><%# Item.Hospital == null ? String.Empty : Item.Hospital.Code %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Departed">
                                                            <ItemTemplate><%# Item.Departure %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Destination">
                                                            <ItemTemplate><%# Item.Hospital1 == null ? String.Empty : Item.Hospital1.Code %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Arrived">
                                                            <ItemTemplate><%# Item.Arrival %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Vehicle">
                                                            <ItemTemplate><%# Item.Vehicle == null ? String.Empty : Item.Vehicle.Name %></ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Panel ID="panelDelays" GroupingText="Delays" CssClass="slidsPanel" runat="server">
                                                <asp:GridView ID="gvDelays" runat="server" ItemType="Pentag.SLIDS.DAL.Delay"
                                                    SelectMethod="gvDelays_GetData" OnRowDataBound="gridView_RowDataBound"
                                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                                    AllowSorting="true"
                                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                                    CssClass="slidsGrid"
                                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                                    PagerStyle-CssClass="slidsGridPager">
                                                    <Columns>
                                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                                        <asp:TemplateField>
                                                            <ItemTemplate>
                                                                <asp:CheckBox ID="chkDelayTable" runat="server" />
                                                            </ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Delay Reason">
                                                            <ItemTemplate><a href="Delay.aspx?donorID=<%# Item.Transport.DonorID %>&delayID=<%# Item.ID %>"><%# Item.DelayReason == null ? String.Empty : Item.DelayReason.Reason %></a></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Duration">
                                                            <ItemTemplate><%# Item.Duration %></ItemTemplate>
                                                        </asp:TemplateField>
                                                        <asp:TemplateField HeaderText="Organ loss">
                                                            <ItemTemplate><%# Item.IsOrganLost %></ItemTemplate>
                                                        </asp:TemplateField>
                                                    </Columns>
                                                </asp:GridView>
                                            </asp:Panel>

                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </asp:Panel>
                    </td>
                </tr>
            </tbody>
        </table>
    </ContentTemplate>
</asp:UpdatePanel>
