<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucOrganCostAllocation.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucOrganCostAllocation" %>

    <asp:GridView ID="gvOrganCostAllocation" runat="server" ItemType="Pentag.SLIDS.DAL.OrganCost" 
        DataKeyNames="ID" AutoGenerateColumns="False" 
        ShowHeaderWhenEmpty="True" ShowFooter="False"
        OnRowCommand="gvOrganCostAllocation_RowCommand"
        OnRowCreated="gvOrganCostAllocation_RowCreated"
        OnRowEditing="gvOrganCostAllocation_RowEditing"
        OnRowCancelingEdit="gvOrganCostAllocation_RowCancelingEdit"
        OnRowUpdating="gvOrganCostAllocation_RowUpdating"
        OnRowDeleting="gvOrganCostAllocation_RowDeleting"
        OnRowDataBound="gvOrganCostAllocation_RowDataBound"
        CssClass="slidsGrid"
        SelectedRowStyle-CssClass="slidsGridSelected"> 
        <Columns>
            <asp:TemplateField HeaderText="Organ" SortExpression="Organ.Name">  
                <ItemTemplate>
                    <asp:Label ID="lblOrgan" Text='<%# Item.TransplantOrgan != null ? Item.TransplantOrgan.Organ.Name : String.Empty %>' CssClass="defaultLabel" runat="server" />
                    <asp:HiddenField ID="hidOrganID" Value='<%# Item.TransplantOrganID != null ? Item.TransplantOrganID.ToString() : "0" %>' runat="server" />
                    <asp:HiddenField ID="hidOrganCostID" Value='<%# Item.ID %>' runat="server" />
                    <asp:HiddenField ID="hidAddedByAutomation" Value='<%# Item.AddedByAutomation ? "1" : "0" %>'  runat="server" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:HiddenField ID="hidEditOrganCostID" runat="server" />
                    <asp:HiddenField ID="hidEditTransplantOrganID" runat="server" />
                    <asp:HiddenField ID="hidEditAddedByAutomation" runat="server" />
                    <asp:CustomValidator id="cvEditTransplantOrgan" ControlToValidate="ddlEditTransplantOrgan" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:DropDownList ID="ddlEditTransplantOrgan" CssClass="defaultDropDownList" runat="server" />
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:CustomValidator id="cvFooterTransplantOrgan" ControlToValidate="ddlFooterTransplantOrgan" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:DropDownList ID="ddlFooterTransplantOrgan" CssClass="defaultDropDownList" runat="server" />
                </FooterTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Amount (CHF)" SortExpression="Amount">
                <ItemTemplate>
                    <asp:Label ID="lblAmount" Text='<%# Item.Amount != null ? Convert.ToDecimal(Item.Amount).ToString("N2") : String.Empty %>' CssClass="defaultLabelAlignRight" runat="server" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:RequiredFieldValidator ID="rfvEditAmount" ControlToValidate="txtEditAmount" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:CompareValidator ID="cvEditAmount" ControlToValidate="txtEditAmount" Operator="DataTypeCheck" Type="Currency" ErrorMessage="Amount value can only be numberic" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:RangeValidator ID="rvEditAmount" ControlToValidate="txtEditAmount" Type="Currency" MinimumValue="0" MaximumValue="999999.95" ErrorMessage="Please enter an amount between 0 and 999'999.95" ForeColor="Red"  Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:TextBox ID="txtEditAmount" CssClass="defaultInputDecimalTextBox" MaxLength="10" runat="server" />
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:RequiredFieldValidator ID="rfvFooterAmount" ControlToValidate="txtFooterAmount" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:CompareValidator ID="cvFooterAmount" ControlToValidate="txtFooterAmount" Operator="DataTypeCheck" Type="Currency" ErrorMessage="Amount value can only be numberic" ForeColor="Red" Display="Dynamic" ValidationGroup="OrganCostInputGroup" runat="server" />
                    <asp:TextBox ID="txtFooterAmount" CssClass="defaultInputDecimalTextBox" MaxLength="10" runat="server" />
                </FooterTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Comment">
                <ItemTemplate>
                    <asp:Label ID="lblComment" Text='<%# Item.Comment %>' CssClass="defaultInputTextBox" runat="server" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:TextBox ID="txtEditComment" CssClass="defaultInputTextBox" MaxLength="256" runat="server" />
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:TextBox ID="txtFooterComment" CssClass="defaultInputTextBox" MaxLength="256" runat="server" />
                </FooterTemplate>
            </asp:TemplateField>

            <asp:TemplateField HeaderText="Commands">
                <HeaderTemplate>
                    <asp:Button ID="HeaderAddNew" Text="Add new..." CommandName="HeaderAddNew" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                </HeaderTemplate>
                <ItemTemplate>
                    <asp:Button ID="Edit" Text="Edit" CommandName="Edit" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                    <asp:Button ID="Delete" Text="Delete" CommandName="Delete" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                </ItemTemplate>
                <EditItemTemplate>
                    <asp:Button ID="EditUpdate" Text="Update" CommandName="Update" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                    <asp:Button ID="EditCancel" Text="Cancel" CommandName="Cancel" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                </EditItemTemplate>
                <FooterTemplate>
                    <asp:Button ID="FooterInsert" Text="Insert" CommandName="FooterInsert" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                    <asp:Button ID="FooterCancel" Text="Cancel" CommandName="FooterCancel" CssClass="defaultButton btn btn-default" Visible='<%# Master.IsAdmin || Master.IsNC %>' runat="server" />
                </FooterTemplate>
            </asp:TemplateField>                  
        </Columns>
    </asp:GridView>
    <asp:HiddenField ID="hidCalcTotal" Value="0" runat="server" />
    <asp:HiddenField ID="hidTotalConst" Value="0" runat="server" />
    <asp:HiddenField ID="hidCostTypeID" Value="0" runat="server" />
    <asp:HiddenField ID="hidTransportID" Value="" runat="server" />
    <asp:HiddenField ID="hidAmount" Value="" runat="server" />