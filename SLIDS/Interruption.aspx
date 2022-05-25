<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Interruption.aspx.cs" Inherits="Pentag.SLIDS.Interruption" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <title>SLIDS</title>
    <link href="~/styles/SLIDS.css" rel="stylesheet" type="text/css" />
</head>
<body>
    <form id="form1" runat="server">
        <asp:ScriptManager ID="ScriptManager1" runat="server" AsyncPostBackTimeout ="360000" />
        <div id="topContent">
            <div id="header">
                <div id="headerContent">
                    <table class="slidsNoBorder">
                        <tr>
                            <td><asp:Image ID="imgLogo" runat="server" ImageUrl="~/resources/swisstransplant.jpg"/></td>
                            <td><asp:Label ID="lblTitle" runat="server" Text="SLIDS" CssClass="slidsTitleProd" /></td>
                            <td><asp:Label ID="lblTitleInfo" runat="server" Text="Swisstransplant logistics and <br /> invoice documentation system" CssClass="slidsTitleInfoProd" /></td>
                        </tr>
                    </table>
                </div>
            </div>
        </div>
        
        <div id="content">
            SLIDS is currently unavailable due to updates which are taking place right now. Please try again in a while.
        </div>
    </form>
</body>
</html>
