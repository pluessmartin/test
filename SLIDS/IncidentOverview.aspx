<%@ Page Title="" Language="C#" MasterPageFile="~/SLIDS.Master" AutoEventWireup="true" CodeBehind="IncidentOverview.aspx.cs" Inherits="Pentag.SLIDS.IncidentOverview" %>

<%@ Register TagPrefix="inc" TagName="Incident" Src="~/Controls/ucIncident.ascx" %>
<%@ Register TagPrefix="inc" TagName="IncidentDocuments" Src="~/Controls/ucIncidentDocuments.ascx" %>
<%@ Register TagPrefix="inc" TagName="IncidentDonor" Src="~/Controls/ucIncidentDonor.ascx" %>
<%@ MasterType VirtualPath="~/SLIDS.Master" %>

<asp:Content ID="Content1" ContentPlaceHolderID="MainContentPlaceHolder" runat="server">

    <asp:Panel ID="panelSearchFilter" GroupingText="Search filter" CssClass="slidsPanel" runat="server">
        <table>
            <tr>
                <td>
                    <asp:Label ID="lblSTRSFONo" Text="ST/RS/FO No" runat="server" /></td>
                <td>
                    <asp:TextBox ID="txtSTRSFONo" CssClass="defaultInputTextBox" MaxLength="16" AutoPostBack="True" runat="server" OnTextChanged="txtSearchField_TextChanged" /></td>
                <td>
                    <asp:Label ID="lblDateFrom" Text="Date from" runat="server" /></td>
                <td>
                    <asp:TextBox ID="txtDateFrom" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="True" runat="server" TabIndex="3" OnTextChanged="txtSearchField_TextChanged" />
                    <ajaxToolkit:CalendarExtender ID="ceDateOfEvent" Format="dd.MM.yyyy" TargetControlID="txtDateFrom" runat="server" />
                    <ajaxToolkit:TextBoxWatermarkExtender ID="weDateOfEvent" runat="server" TargetControlID="txtDateFrom" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                </td>
                <td>
                    <asp:Label ID="lblDateTo" Text="to" runat="server" /></td>
                <td>
                    <asp:TextBox ID="txtDateTo" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="True" runat="server" TabIndex="3" OnTextChanged="txtSearchField_TextChanged" />
                    <ajaxToolkit:CalendarExtender ID="ceDateTo" Format="dd.MM.yyyy" TargetControlID="txtDateTo" runat="server" />
                    <ajaxToolkit:TextBoxWatermarkExtender ID="weDateTo" runat="server" TargetControlID="txtDateTo" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                </td>
            </tr>
            <tr>
                <td>
                    <asp:Label ID="lblProcess" Text="Process" runat="server" /></td>
                <td>
                    <asp:DropDownList ID="ddlProcess" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="txtSearchField_TextChanged" /></td>
                <td>
                    <asp:Label ID="lblCategory" Text="Category" runat="server" /></td>
                <td>
                    <asp:DropDownList ID="ddlCategory" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="txtSearchField_TextChanged" /></td>
                <td>
                    <asp:Label ID="lblState" Text="State" runat="server" /></td>
                <td>
                    <asp:DropDownList ID="ddlState" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="txtSearchField_TextChanged" /></td>
            </tr>
            <tr>
                <td colspan="2">
                    <asp:CheckBox ID="chkIncludeArchives" Text="Include archives" AutoPostBack="true" runat="server" OnCheckedChanged="txtSearchField_TextChanged" /></td>
                <td colspan="2">
                    <asp:CheckBox ID="chkShowOverdueFollowUpTasksOnly" Text="Show overdue follow up tasks only" AutoPostBack="true" runat="server" OnCheckedChanged="txtSearchField_TextChanged" /></td>
              <td>
                    <asp:Label ID="lblRiskScale" Text="Risk scale" runat="server" /></td>
                <td>
                    <asp:TextBox ID="txtRiskScale" CssClass="defaultInputTextBox" MaxLength="2"  runat="server" onkeydown = "return (!(event.keyCode>=65) && event.keyCode!=32);" AutoPostBack="true"  OnTextChanged="txtSearchField_TextChanged" /></td>

            
            </tr>
        </table>
    </asp:Panel>
    <asp:Panel ID="panelIncidentList" GroupingText="Incident List" CssClass="slidsPanel" runat="server">
        <asp:UpdatePanel ID="upIncidentView" UpdateMode="Conditional" runat="server">
            <Triggers>
                <asp:AsyncPostBackTrigger ControlID="gvIncidents" />
                <asp:AsyncPostBackTrigger ControlID="txtSTRSFONo" />
                <asp:AsyncPostBackTrigger ControlID="txtDateFrom" />
                <asp:AsyncPostBackTrigger ControlID="txtDateTo" />
                <asp:AsyncPostBackTrigger ControlID="ddlProcess" />
                <asp:AsyncPostBackTrigger ControlID="ddlCategory" />
                <asp:AsyncPostBackTrigger ControlID="ddlState" />
                <asp:AsyncPostBackTrigger ControlID="chkIncludeArchives" />
                <asp:AsyncPostBackTrigger ControlID="txtRiskScale" />
                <asp:AsyncPostBackTrigger ControlID="chkShowOverdueFollowUpTasksOnly" />
            </Triggers>
            <ContentTemplate>
                <asp:GridView ID="gvIncidents" runat="server" ItemType="Pentag.SLIDS.DAL.Incident"
                    SelectMethod="gvIncidents_GetData" OnRowDataBound="gridView_RowDataBound" OnSelectedIndexChanged="gvIncidents_SelectedIndexChanged"
                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                    AllowSorting="true"
                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                    CssClass="slidsGrid"
                    SelectedRowStyle-CssClass="slidsGridSelected"
                    PagerStyle-CssClass="slidsGridPager">
                    <Columns>
                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                        <asp:TemplateField HeaderText="Incident No">
                            <ItemTemplate><%# Item.IncidentNo %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="ST/RS/FO Number">
                            <ItemTemplate><%# Item.DonorNumber %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Date">
                            <ItemTemplate><%# Item.CreationDate %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Description">
                            <ItemTemplate>
                                <%# Item.DamageDescription == null ? String.Empty : Item.DamageDescription.Length > 80 ? Item.DamageDescription.Substring(0, 80) + "..." : Item.DamageDescription %>
                            </ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Process">
                            <ItemTemplate><%# Item.IncidentProcess == null ? String.Empty : Item.IncidentProcess.Description %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Category">
                            <ItemTemplate><%# Item.IncidentCategory == null ? String.Empty : Item.IncidentCategory.Description %></ItemTemplate>
                        </asp:TemplateField>
                        <asp:TemplateField HeaderText="Status">
                            <ItemTemplate><%# Item.IncidentState.Description %></ItemTemplate>
                        </asp:TemplateField>
                    </Columns>
                </asp:GridView>
            </ContentTemplate>
        </asp:UpdatePanel>
    </asp:Panel>

    <asp:UpdatePanel ID="upTabs" UpdateMode="Conditional" runat="server">
        <Triggers>
            <asp:AsyncPostBackTrigger ControlID="gvIncidents" />
        </Triggers>
        <ContentTemplate>
            <div id="divIncidentsLexiconHelpAdd" style="display: none;" runat="server" class="slidsPanel">
                <ajaxToolkit:TabContainer ID="tcTabs" runat="server" CssClass="slidsTab">
                    <ajaxToolkit:TabPanel ID="tpIncident" runat="server" HeaderText="Incident">
                        <ContentTemplate>
                            <table>
                                <tbody>
                                    <tr>
                                        <td>
                                            <asp:Panel ID="pnlDeclarer" GroupingText="Declarer" CssClass="slidsPanel" runat="server">
                                                <table>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblUserName" Text="User Name" runat="server" /></td>
                                                        <td colspan="3">
                                                            <asp:TextBox ID="txtUserName" CssClass="smallInputTextBox" runat="server" Enabled="False" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblEmail" Text="Email" runat="server" /></td>
                                                        <td colspan="3">
                                                            <asp:TextBox ID="txtEmail" CssClass="largeInputTextBox" runat="server" Enabled="False" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblHospital" Text="Hospital" runat="server" /></td>
                                                        <td colspan="3">
                                                            <asp:TextBox ID="txtHospital" CssClass="largeInputTextBox" runat="server" Enabled="False" /></td>
                                                        <td>
                                                            <asp:Label ID="lblHospitalTel" Text="Tel." runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtHospitalTel" CssClass="defaultInputTextBox" runat="server" Enabled="False" /></td>
                                                    </tr>
                                                    <tr>
                                                        <td>
                                                            <asp:Label ID="lblCreationDate" Text="Creation Date" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtCreationDate" CssClass="smallInputTextBox" runat="server" Enabled="False" /></td>
                                                        <td>
                                                            <asp:Label ID="lblCreationTime" Text="Creation Time" runat="server" /></td>
                                                        <td>
                                                            <asp:TextBox ID="txtCreationTime" CssClass="tinyInputTextBox" runat="server" Enabled="False" /></td>
                                                    </tr>
                                                </table>
                                            </asp:Panel>
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:CheckBox ID="chkShowOriginalDeclaration" Text="Show Original Declaration" OnCheckedChanged="chkShowOriginalDeclaration_CheckedChanged" runat="server" AutoPostBack="True" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <inc:Incident ID="icIncidentControl" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <inc:IncidentDocuments ID="icIncidentDocumentsControl" runat="server" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <inc:IncidentDonor ID="icIncidentDonorControl" runat="server" />
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                            <table style="width: 100%">
                                <tr>
                                    <td>
                                        <asp:Button ID="btnIncidentSave" Text="Save" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" OnClick="btnIncidentSave_Click" />
                                        <asp:HyperLink ID="btnIncidentReport" Target="_blank" Text="Report" CssClass="defaultButton btn btn-default"  AccessKey="R" runat="server" />
                                    </td>
                                        <asp:PlaceHolder ID="placeholder" runat="server"></asp:PlaceHolder>
                                    <td class="alignRight">
                                        <asp:Button ID="btnIncidentDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this incident?');" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" OnClick="btnIncidentDelete_Click" />
                                    </td>
                                </tr>
                            </table>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tpProcessing" runat="server" HeaderText="Processing">
                        <ContentTemplate>
                            <asp:Label ID="lblStateOfIncident" Text="State of Incident" runat="server" />
                            <asp:DropDownList ID="ddlStateOfIncident" CssClass="defaultDropDownList" runat="server" />
                            <asp:Panel ID="pnlDamage" GroupingText="Damage" CssClass="slidsPanel" runat="server">
                                
                                    <asp:Literal ID="litState" runat="server"></asp:Literal>
                                <table>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblLikelihoodToRepeat" Text="* Likelihood to Repeat" runat="server" /></td>
                                        <td>
                                            <asp:CustomValidator ID="cvLikelihoodToRepeat" ControlToValidate="ddlLikelihoodToRepeat" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroupProcessing" runat="server" />
                                            <asp:DropDownList ID="ddlLikelihoodToRepeat" CssClass="defaultDropDownList" runat="server" OnSelectedIndexChanged="ddlLikelihoodToRepeat_SelectedIndexChanged" AutoPostBack="true" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblDamageCategory" Text="* Damage Category" runat="server" /></td>
                                        <td>
                                            <asp:CustomValidator ID="cvDamageCategory" ControlToValidate="ddlDamageCategory" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroupProcessing" runat="server" />
                                            <asp:DropDownList ID="ddlDamageCategory" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLikelihoodToRepeat_SelectedIndexChanged" /></td>
                                        <td>
                                            <asp:Label ID="lblRiskScalingNumber" Text="Risk scaling number" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtRiskScalingNumber" CssClass="tinyInputTextBox" runat="server" Enabled="false" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblPotentialDamage" Text="* Detectability" runat="server" /></td>
                                        <td>
                                            <asp:CustomValidator ID="cvPotentialDamage" ControlToValidate="ddlPotentialDamage" OnServerValidate="cvDropDownList_ServerValidate" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ValidationGroup="InputGroupProcessing" runat="server" />
                                            <asp:DropDownList ID="ddlPotentialDamage" CssClass="defaultDropDownList" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlLikelihoodToRepeat_SelectedIndexChanged" /></td>
                                        <td>
                                            <asp:Label ID="lblPotentialRiskNumber" Text="Potential risk number" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtPotentialRiskNumber" CssClass="tinyInputTextBox" runat="server" Enabled="false" /></td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <asp:Label ID="lblDamageDescription" Text="Damage Description" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtDamageDescription" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                </table>
                            </asp:Panel>
                            <asp:Panel ID="pnlAction" GroupingText="Action" CssClass="slidsPanel" runat="server">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <asp:Label ID="lblCorrectiveAction" Text="Corrective action" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtCorrectiveAction" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <asp:Label ID="lblPreventiveAction" Text="Preventive action" runat="server" /></td>
                                        <td colspan="3">
                                            <asp:TextBox ID="txtPreventiveAction" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                </table>
                            </asp:Panel>

                            <asp:Button ID="btnIncidentProcessingSave" Text="Save" CausesValidation="true" ValidationGroup="InputGroupProcessing" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" OnClick="btnIncidentProcessingSave_Click" />
                            <asp:Panel ID="pnlAnalysis" GroupingText="Analysis" CssClass="slidsPanel" runat="server">
                                <asp:GridView ID="gvAnalysis" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentAnalysis"
                                    SelectMethod="gvAnalysis_GetData" OnRowDataBound="gridView_RowDataBound"
                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true" OnSelectedIndexChanged="gvAnalysis_SelectedIndexChanged"
                                    AllowSorting="true"
                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                    CssClass="slidsGrid"
                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                    PagerStyle-CssClass="slidsGridPager">
                                    <Columns>
                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                        <asp:TemplateField HeaderText="Creation Date">
                                            <ItemTemplate><%# Item.CreationDate.ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Analyse">
                                            <ItemTemplate><%# Item.Analysis %></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>
                            <table style="width: 100%">
                                <tr>
                                    <td>
                                        <asp:Button ID="btnAnalysisAdd" Text="Add New" OnClick="btnAnalysisAdd_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" />
                                    </td>
                                </tr>
                            </table>
                             <asp:Panel ID="pnlAnalyse" GroupingText="Analyse" CssClass="slidsPanel" runat="server" Visible="false">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <asp:Label ID="lblAnalysis" Text="Analysis" runat="server" /></td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtAnalysis_" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblACreationDate" Text="Creation Date" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtACreationDate" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="True" runat="server" TabIndex="3" />
                                            <ajaxToolkit:CalendarExtender ID="CalendarExtender1" Format="dd.MM.yyyy" TargetControlID="txtACreationDate" runat="server" />
                                            <ajaxToolkit:TextBoxWatermarkExtender ID="TextBoxWatermarkExtender1" runat="server" TargetControlID="txtACreationDate" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                        </td>
                                    </tr>
                                </table>
                                <table style="width: 100%">
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnAnalysisSave" Text="Save" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" OnClick="btnAnalysisSave_Click" /></td>
                                        <td class="alignRight">
                                            <asp:Button ID="btnAnalysisDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this analysis?');" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" OnClick="btnAnalysisDelete_Click" Enabled="false" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tpFollowUp" runat="server" HeaderText="Follow up">
                        <ContentTemplate>
                            <asp:Panel ID="pnlTasks" GroupingText="Tasks" CssClass="slidsPanel" runat="server">
                                <asp:GridView ID="gvTasks" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentTask"
                                    SelectMethod="gvTasks_GetData" OnRowDataBound="gridView_RowDataBound" OnSelectedIndexChanged="gvTasks_SelectedIndexChanged"
                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                    AllowSorting="true"
                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                    CssClass="slidsGrid"
                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                    PagerStyle-CssClass="slidsGridPager">
                                    <Columns>
                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                        <asp:TemplateField HeaderText="Creation Date">
                                            <ItemTemplate><%# Item.CreationDate.ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="To do">
                                            <ItemTemplate><%# Item.Description %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Deadline">
                                            <ItemTemplate><%# Item.Deadline == null ? String.Empty : ((DateTime)Item.Deadline).ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Done">
                                            <ItemTemplate><%# Item.IsDone ? "<img src=\"images/done.png\">" : "" %></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>
                            <table style="width: 100%">
                                <tr>
                                    <td>
                                        <asp:Button ID="btnTaskAdd" Text="Add New" OnClick="btnTaskAdd_Click" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" />
                                    </td>
                                </tr>
                            </table>
                            <asp:Panel ID="pnlTask" GroupingText="Task" CssClass="slidsPanel" runat="server" Visible="false">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <asp:Label ID="lblToDo" Text="To do" runat="server" /></td>
                                        <td colspan="2">
                                            <asp:TextBox ID="txtToDo" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <asp:Label ID="lblDeadline" Text="Deadline" runat="server" /></td>
                                        <td>
                                            <asp:TextBox ID="txtDeadline" CssClass="smallInputTextBox" MaxLength="10" AutoPostBack="True" runat="server" TabIndex="3" />
                                            <ajaxToolkit:CalendarExtender ID="ceDeadline" Format="dd.MM.yyyy" TargetControlID="txtDeadline" runat="server" />
                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weDeadline" runat="server" TargetControlID="txtDeadline" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                        </td>
                                        <td>
                                            <asp:CheckBox ID="chkDone" Text="done" runat="server" />
                                        </td>
                                    </tr>
                                </table>
                                <table style="width: 100%">
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnTaskSave" Text="Save" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" OnClick="btnTaskSave_Click" /></td>
                                        <td class="alignRight">
                                            <asp:Button ID="btnTaskDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this task?');" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" OnClick="btnTaskDelete_Click" Enabled="false" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                    <ajaxToolkit:TabPanel ID="tpAlerts" runat="server" HeaderText="Alerts">
                        <ContentTemplate>
                            <asp:Panel ID="pnlIncidentAlerts" GroupingText="Alerts" CssClass="slidsPanel" runat="server">
                                <asp:GridView ID="gvAlerts" runat="server" ItemType="Pentag.SLIDS.DAL.IncidentAlert"
                                    SelectMethod="gvAlerts_GetData" OnRowDataBound="gridView_RowDataBound" OnSelectedIndexChanged="gvAlerts_SelectedIndexChanged"
                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                    AllowSorting="true"
                                    AllowPaging="true" EnablePersistedSelection="true" PageSize="10"
                                    CssClass="slidsGrid"
                                    SelectedRowStyle-CssClass="slidsGridSelected"
                                    PagerStyle-CssClass="slidsGridPager">
                                    <Columns>
                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                        <asp:TemplateField HeaderText="Creation Date">
                                            <ItemTemplate><%# Item.CreationDate.ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Alert Banner Message">
                                            <ItemTemplate><%# Item.AlertMessage %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Start date">
                                            <ItemTemplate><%# Item.StartDate.ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="End date">
                                            <ItemTemplate><%# Item.EndDate.ToShortDateString() %></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                            </asp:Panel>

                            <table style="width: 100%">
                                <tr>
                                    <td>
                                        <asp:Button ID="btnAlertAdd" Text="Add New" CausesValidation="true" ValidationGroup="InputGroup" CssClass="defaultButton btn btn-default" AccessKey="A" runat="server" OnClick="btnAlertAdd_Click" />
                                    </td>
                                </tr>
                            </table>
                            <asp:Panel ID="pnlAlertBannerMessage" GroupingText="Alert Banner Message" CssClass="slidsPanel" runat="server" Visible="false">
                                <table>
                                    <tr>
                                        <td style="vertical-align: top; padding-top: 9Px;">
                                            <div style="float: left;">
                                                <asp:Label ID="lblAlertMessage" Text="* Alert Message" runat="server" /></div>
                                            <div style="float: right;">
                                                <asp:RequiredFieldValidator ID="rfvAlertMessage" ControlToValidate="txtAlertMessage" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroupAlert" /></div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtAlertMessage" CssClass="largeInputTextBox" Rows="3" TextMode="multiline" runat="server" /></td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div style="float: left;">
                                                <asp:Label ID="lblStartDate" Text="* Start date" runat="server" /></div>
                                            <div style="float: right;">
                                                <asp:RequiredFieldValidator ID="rfvStartDate" ControlToValidate="txtStartDate" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroupAlert" /></div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtStartDate" CssClass="smallInputTextBox" MaxLength="10" runat="server" TabIndex="3" />
                                            <ajaxToolkit:CalendarExtender ID="ceStartDate" Format="dd.MM.yyyy" TargetControlID="txtStartDate" runat="server" />
                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weStartDate" runat="server" TargetControlID="txtStartDate" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                        </td>
                                    </tr>
                                    <tr>
                                        <td>
                                            <div style="float: left;">
                                                <asp:Label ID="lblEndDate" Text="* End Date" runat="server" /></div>
                                            <div style="float: right;">
                                                <asp:RequiredFieldValidator ID="rfvEndDate" ControlToValidate="txtEndDate" ForeColor="Red" ErrorMessage="*" Display="Dynamic" runat="server" ValidationGroup="InputGroupAlert" /></div>
                                        </td>
                                        <td>
                                            <asp:TextBox ID="txtEndDate" CssClass="smallInputTextBox" MaxLength="10" runat="server" TabIndex="3" />
                                            <ajaxToolkit:CalendarExtender ID="ceEndDate" Format="dd.MM.yyyy" TargetControlID="txtEndDate" runat="server" />
                                            <ajaxToolkit:TextBoxWatermarkExtender ID="weEndDate" runat="server" TargetControlID="txtEndDate" WatermarkCssClass="smallWatermarked" WatermarkText="dd.mm.yyyy" />
                                        </td>
                                    </tr>
                                </table>
                                <asp:Label ID="lblAlertVisibleTo" Text="Alert visible to" runat="server" />
                                <asp:GridView ID="gvHospitalVisible" runat="server" ItemType="Pentag.SLIDS.DAL.Hospital"
                                    SelectMethod="gvHospitalVisible_GetData" OnRowDataBound="gvHospitalVisible_RowDataBound" OnPreRender="chkSelect_CheckedChanged"
                                    DataKeyNames="ID" AutoGenerateColumns="False" ShowHeaderWhenEmpty="true"
                                    AllowSorting="true" EnablePersistedSelection="true"
                                    CssClass="slidsGridOverview">
                                    <Columns>
                                        <asp:CommandField SelectText="Select" ShowSelectButton="true" ItemStyle-CssClass="HideButton" HeaderStyle-CssClass="HideButton" />
                                        <asp:TemplateField>
                                            <HeaderTemplate>
                                                <asp:CheckBox ID="chkboxSelectAll" runat="server" OnCheckedChanged="chkboxSelectAll_CheckedChanged" AutoPostBack="true" />
                                                Select All
                                            </HeaderTemplate>
                                            <ItemTemplate>
                                                <asp:CheckBox ID="chkSelect" runat="server" OnCheckedChanged="chkSelect_CheckedChanged" AutoPostBack="true" />
                                            </ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Code">
                                            <ItemTemplate><%# Item.Code %></ItemTemplate>
                                        </asp:TemplateField>
                                        <asp:TemplateField HeaderText="Name">
                                            <ItemTemplate><%# Item.Name %></ItemTemplate>
                                        </asp:TemplateField>
                                    </Columns>
                                </asp:GridView>
                                <table style="width: 100%">
                                    <tr>
                                        <td>
                                            <asp:Button ID="btnAlertSave" Text="Save" CssClass="defaultButton btn btn-success" AccessKey="S" runat="server" OnClick="btnAlertSave_Click" CausesValidation="true" ValidationGroup="InputGroupAlert" /></td>
                                        <td class="alignRight">
                                            <asp:Button ID="btnAlertDelete" Text="Delete" OnClientClick="return confirm('Do you want to delete this alert?');" CssClass="defaultButton btn btn-danger" AccessKey="D" runat="server" OnClick="btnAlertDelete_Click" Enabled="false" />
                                        </td>
                                    </tr>
                                </table>
                            </asp:Panel>
                        </ContentTemplate>
                    </ajaxToolkit:TabPanel>
                </ajaxToolkit:TabContainer>
            </div>
        </ContentTemplate>
    </asp:UpdatePanel>
</asp:Content>
