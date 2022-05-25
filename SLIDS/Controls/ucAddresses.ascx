<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucAddresses.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucAddresses" %>

<asp:Panel ID="pnlAddressDetails" GroupingText="Address" Visible="true" CssClass="slidsPanel" runat="server">
    <asp:HiddenField ID="hidAddressID" Value="0" runat="server" />

    <table>
        <tr>
            <td><asp:Button ID="btnChooseExisting" Text="Choose existing..." OnClick="btnChooseExisting_Click" CssClass="largeButton btn btn-default" runat="server" /></td>
        </tr>
    </table>

    <asp:Panel ID="pnlExistingAdresses" GroupingText="Existing addresses" Visible="false" CssClass="slidsPanel" runat="server">
        <asp:GridView ID="gvExistingAddress" runat="server" ItemType="Pentag.SLIDS.DAL.Address" SelectMethod="gvExistingAddress_GetData"
            DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
            OnSelectedIndexChanged="gvExistingAddress_SelectedIndexChanged" 
            OnRowDataBound="gvExistingAddress_RowDataBound"
            AllowSorting="true"
            AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
            CssClass="slidsGrid"
            SelectedRowStyle-CssClass="slidsGridSelected"
            PagerStyle-CssClass="slidsGridPager"> 
            <Columns>
                <asp:CommandField SelectText ="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                <asp:TemplateField HeaderText="Contact Person" SortExpression="ContactPerson">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingContactPerson" Text='<%# Item.ContactPerson ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Address1" SortExpression="Address1">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingAddress1" Text='<%# Item.Address1 ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Address2" SortExpression="Address2">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingAddress2" Text='<%# Item.Address2 ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                    <asp:TemplateField HeaderText="Address3" SortExpression="Address3">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingAddress3" Text='<%# Item.Address3 ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                    <asp:TemplateField HeaderText="Address4" SortExpression="Address4">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingAddress4" Text='<%# Item.Address4 ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Zip" SortExpression="Zip">  
                    <ItemTemplate>
                        <asp:Label ID="lblExistingZip" Text='<%# Item.Zip ?? String.Empty  %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>  
                </asp:TemplateField>
                    <asp:TemplateField HeaderText="City" SortExpression="City">  
                    <ItemTemplate> 
                        <asp:Label ID="lblExistingCity" Text='<%# Item.City ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>  
                </asp:TemplateField>
                <asp:TemplateField Visible="false" SortExpression="Phone">  
                    <ItemTemplate> 
                        <asp:Label ID="lblExistingPhone" Text='<%# Item.Phone ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>  
                </asp:TemplateField>
                <asp:TemplateField Visible="false" SortExpression="Fax">  
                    <ItemTemplate> 
                        <asp:Label ID="lblExistingFax" Text='<%# Item.Fax ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>  
                </asp:TemplateField>
                <asp:TemplateField Visible="false" SortExpression="CountryISO">  
                    <ItemTemplate> 
                        <asp:Label ID="lblExistingCountryISO" Text='<%# Item.CountryISO ?? String.Empty %>' CssClass="defaultLabel" runat="server" />
                    </ItemTemplate>  
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </asp:Panel>

    <table>
        <tr id="trContactPerson" runat="server">
            <td><asp:Label ID="lblContactPerson" Text="Contact Person" runat="server" /></td>
            <td><asp:Textbox ID="txtContactPerson" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
            <td colspan="2">&nbsp;</td>
        </tr>
        <tr>
            <td><asp:Label ID="lblAddress1" Text="*Address 1" runat="server" /></td>
            <td>
                <asp:RequiredFieldValidator ID="rfvAddress1" ControlToValidate="txtAddress1" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                <asp:Textbox ID="txtAddress1" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
            </td>
            <td><asp:Label ID="lblPhone" Text="Phone" runat="server" /></td>
            <td><asp:Textbox ID="txtPhone" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
        </tr>
        <tr>
            <td><asp:Label ID="lblAddress2" Text="Address 2" runat="server" /></td>
            <td><asp:Textbox ID="txtAddress2" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
            <td><asp:Label ID="lblFax" Text="Fax" runat="server" /></td>
            <td><asp:Textbox ID="txtFax" CssClass="defaultInputTextBox" MaxLength="32" runat="server" /></td>
        </tr>
            <tr>
                <td><asp:Label ID="lblAddress3" Text="Address 3" runat="server" /></td>
                <td><asp:Textbox ID="txtAddress3" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
                <td><asp:Label ID="lblEmail" Text="Email" runat="server" /></td>
            <td><asp:Textbox ID="txtEmail" CssClass="largeInputTextBox" MaxLength="64" runat="server" /></td>
        </tr>
        <tr>
            <td><asp:Label ID="lblAddress4" Text="Address 4" runat="server" /></td>
            <td colspan="3"><asp:Textbox ID="txtAddress4" CssClass="defaultInputTextBox" MaxLength="64" runat="server" /></td>
        </tr>
        <tr>
            <td><asp:Label ID="lblZip" Text="Zip" runat="server" /></td>
            <td colspan="3"><asp:Textbox ID="txtZip"  MaxLength="12" CssClass="smallInputTextBox" runat="server" /></td>
        </tr>
        <tr>
            <td><asp:Label ID="lblCity" Text="*City" runat="server" /></td>
            <td>
                <asp:RequiredFieldValidator ID="rfvCity" ControlToValidate="txtCity" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                <asp:Textbox ID="txtCity" CssClass="defaultInputTextBox" MaxLength="64" runat="server" />
            </td>
            <td><asp:Label ID="lblCountryISO" Text="*Country ISO" runat="server" /></td>
            <td>
                <asp:RequiredFieldValidator ID="rfvCountryISO" ControlToValidate="txtCountryISO" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup"></asp:RequiredFieldValidator>
                <asp:Textbox ID="txtCountryISO" CssClass="smallInputTextBox" MaxLength="2" runat="server" />
            </td>
        </tr>
    </table>
</asp:Panel>