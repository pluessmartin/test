<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="MailSend.aspx.cs" Inherits="Pentag.SLIDS.MailSend" %>

<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/REC-html40/strict.dtd">


<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SLIDS</title>
    <link href="~/styles/SLIDS.css" rel="stylesheet" type="text/css" />
    <script type="text/javascript" language="javascript">
    function foo()
    {
       window.focus();
    }
    </script>
</head>
<body onload="foo()">
    <form id="form1" runat="server">
        <div>
            <table>
                <tr>
                    <td style="width:60Px;">
                        * <asp:Label ID="lblTo" Text="To" runat="server" AssociatedControlID="txtTo" /></td>
                    <td style="width:500Px;">
                        <asp:RequiredFieldValidator ID="rfvTo" runat="server" ControlToValidate="txtTo" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ToolTip="To is required." ValidationGroup="InputGroup" />
                        <asp:TextBox ID="txtTo" CssClass="largeInputTextBox" runat="server" /></td>
                </tr>
                <tr>
                    <td>
                        * <asp:Label ID="lblSubject" Text="Subject" runat="server" AssociatedControlID="txtSubject" /></td>
                    <td>
                        <asp:RequiredFieldValidator ID="rfvSubject" runat="server" ControlToValidate="txtSubject" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ToolTip="Subject is required." ValidationGroup="InputGroup" />
                        <asp:TextBox ID="txtSubject" CssClass="largeInputTextBox" runat="server" /></td>
                </tr>
                <tr>
                    <td style="vertical-align: top">
                        * <asp:Label ID="lblBody" Text="Body" runat="server" AssociatedControlID="txtBody" /></td>
                    <td>
                        <asp:RequiredFieldValidator ID="rfvBody" runat="server" ControlToValidate="txtBody" ErrorMessage="*" ForeColor="Red" Display="Dynamic" ToolTip="Body is required." ValidationGroup="InputGroup" />
                        <asp:TextBox ID="txtBody" CssClass="largeInputTextBox" Rows="20" TextMode="multiline" runat="server" Width="500Px" /></td>
                </tr>
                <tr>
                    <td colspan="3">
                        <asp:Button ID="btnSend" Text="Send" OnClick="btnSend_Click" CausesValidation="true" CssClass="defaultButton btn btn-default" AccessKey="S" runat="server" /></td>
                </tr>
            </table>
        </div>
    </form>
</body>
</html>
