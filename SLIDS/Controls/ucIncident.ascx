<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ucIncident.ascx.cs" Inherits="Pentag.SLIDS.Controls.ucIncident" %>

<asp:Panel ID="PanelIncident" GroupingText="Incident" CssClass="slidsPanel" runat="server">

    <asp:UpdatePanel ID="upAlert" runat="server" UpdateMode="Conditional">
        <Triggers></Triggers>
        <ContentTemplate>
            <div class="alert alert-dismissable alert-danger" id="alert" style="display: none;" runat="server">
                ST/RS/FO No could nod be found.
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
    <asp:HiddenField ID="hidCreationDate" Visible="False" runat="server"/>
    <table>
        <tr>
            <td>
                <asp:Label ID="lblIncidentNo" Text="Incident No" runat="server" /></td>
            <td>
                <asp:TextBox ID="txtIncidentNo" CssClass="defaultInputTextBox" runat="server" TabIndex="1" Enabled="false" /></td>
            <td rowspan="2" style="vertical-align: top; padding-top: 9Px;">
                <div style="float: left;">
                    <asp:Label ID="lblIncidentDescription" Text="* Incident Description" runat="server" />
                </div>
                <div style="float: right;">
                    <asp:RequiredFieldValidator ID="rfvIncidentDescription" ControlToValidate="txtIncidentDescription" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                </div>
            </td>
            <td rowspan="2">
                <asp:TextBox ID="txtIncidentDescription" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" Width="500" runat="server" TabIndex="6" /></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblSTRSFONo" Text="* ST/RS/FO No" runat="server" /></td>
            <td>
                <asp:RequiredFieldValidator ID="rfvSTRSFONo" ControlToValidate="txtSTRSFONo" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                <asp:TextBox ID="txtSTRSFONo" CssClass="defaultInputTextBox" runat="server" TabIndex="2" AutoPostBack="true" OnTextChanged="txtSTRSFONo_TextChanged" /></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblDateOfEvent" Text="* Date of Event" runat="server" /></td>
            <td>
                <asp:RequiredFieldValidator ID="rfvDateOfEvent" ControlToValidate="txtDateOfEvent" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                <asp:CustomValidator ID="cvDateOfEvent" ControlToValidate="txtDateOfEvent" OnServerValidate="cvDateOfEvent_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroup" runat="server" />
                <asp:TextBox ID="txtDateOfEvent" CssClass="smallInputTextBox" MaxLength="10" runat="server" TabIndex="3" />
                <ajaxToolkit:CalendarExtender ID="ceDateOfEvent" Format="dd.MM.yyyy" TargetControlID="txtDateOfEvent" runat="server" />
                <ajaxToolkit:TextBoxWatermarkExtender ID="weDateOfEvent" runat="server" TargetControlID="txtDateOfEvent" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
            </td>
            <td rowspan="2" style="vertical-align: top; padding-top: 9Px;">
                <asp:Label ID="lblPersonsInvolved" Text="Persons Involved" runat="server" /></td>
            <td rowspan="2">
                <asp:TextBox ID="txtPersonsInvolved" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" Width="500" runat="server" TabIndex="7" /></td>
        </tr>
        <tr>
            <td>
                <asp:Label ID="lblTimeOfEvent" Text="Time of Event" runat="server" /></td>
            <td>
                <asp:TextBox ID="txtTimeOfEvent" CssClass="tinyInputTextBox" MaxLength="5" runat="server" TabIndex="4" />
                <ajaxToolkit:MaskedEditExtender ID="StartTimeMaskedEdit" runat="server" TargetControlID="txtTimeOfEvent" Mask="99:99" MessageValidatorTip="true" MaskType="Time" InputDirection="RightToLeft" ErrorTooltipEnabled="True" />
                <ajaxToolkit:MaskedEditValidator ID="StartTimeMaskedEditValidator" runat="server" ControlExtender="StartTimeMaskedEdit" ControlToValidate="txtTimeOfEvent" IsValidEmpty="false" MaximumValue="23:59" MinimumValue="00:00" EmptyValueBlurredText="*" />
            </td>
        </tr>
        <tr>
            <td style="vertical-align: top; padding-top: 9Px;">
                <asp:Label ID="lblLocation" Text="Location" runat="server" /></td>
            <td>
                <asp:TextBox ID="txtLocation" CssClass="defaultInputTextBox" Rows="3" TextMode="multiline" runat="server" TabIndex="5" /></td>
            <td style="vertical-align: top; padding-top: 9Px;">
                <asp:Label ID="lblImpact" Text="* Impact" runat="server" />
                <div style="float: right;">
                    <asp:RequiredFieldValidator ID="rfvImpact" ControlToValidate="txtImpact" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroup" />
                </div>
            </td>
            <td>
                <asp:TextBox ID="txtImpact" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" Width="500" runat="server" TabIndex="8" /></td>
        </tr>
        <tr>
            <td style="vertical-align: top; padding-top: 9Px;">
                <asp:Label ID="lblSuggestionsPropositions" Text="Suggestions / Propositions" runat="server" /></td>
            <td colspan="3">
                <asp:TextBox ID="txtSuggestionsPropositions" CssClass="defaultInputTextBox" Rows="3" TextMode="multiline" Width="843" runat="server" TabIndex="8" /></td>
        </tr>
    </table>
</asp:Panel>
<asp:Panel ID="PanelCategorisation" GroupingText="Categorisation" CssClass="slidsPanel" runat="server">
    <asp:UpdatePanel ID="uPanel" runat="server" UpdateMode="Conditional">
        <Triggers>
            <asp:PostBackTrigger ControlID="ddlProcess" />
            <asp:PostBackTrigger ControlID="ddlCategory" />
        </Triggers>
        <ContentTemplate>
            <table>
                <tr>
                    <td>
                        <asp:Label ID="lblProcess" Text="Process" runat="server" /></td>
                    <td>
                        <asp:DropDownList ID="ddlProcess" CssClass="defaultDropDownList" OnSelectedIndexChanged="ddlProcess_SelectedIndexChanged" AutoPostBack="true" runat="server" TabIndex="10" /></td>
                </tr>
                <tr>
                    <td>
                        <asp:Label ID="lblCategory" Text="Category" runat="server" /></td>
                    <td>
                        <asp:DropDownList ID="ddlCategory" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlCategory_SelectedIndexChanged" TabIndex="11" />
                        <asp:TextBox ID="txtCategoryOther" CssClass="defaultInputTextBox" runat="server" TabIndex="12" Visible="false" />
                    </td>
                </tr>
            </table>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Panel>
