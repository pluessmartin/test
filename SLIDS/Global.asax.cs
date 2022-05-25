using System;
using System.Security.Principal;
using System.Web;
using System.Web.Security;
using System.Web.UI;
using NLog;
using Pentag.SLIDS.Constants;

namespace Pentag.SLIDS
{
    public class Global : HttpApplication
    {
        /// <summary>
        /// logger object
        /// </summary>
        private static NLog.Logger logger;

        protected void Application_Start(object sender, EventArgs e)
        {
            ScriptManager.ScriptResourceMapping.AddDefinition("jquery",
                                                              new ScriptResourceDefinition
                                                                  {
                                                                      Path = "~/scripts/jquery-1.4.1.min.js",
                                                                      DebugPath = "~/scripts/jquery-1.4.1.min.js",
                                                                      CdnPath =
                                                                          "http://ajax.microsoft.com/ajax/jQuery/jquery-1.4.1.min.js",
                                                                      CdnDebugPath =
                                                                          "http://ajax.microsoft.com/ajax/jQuery/jquery-1.4.1.js"
                                                                  });

            Pentag.NLogAddOn.ExceptionDetailsRenderer.Register();
            logger = NLog.LogManager.GetCurrentClassLogger();
        }

        protected void Application_AuthenticateRequest(object sender, EventArgs e)
        {
            // If we are dealing with an authenticated forms authentication request
            if (Request.IsAuthenticated)
            {
                Context.User = new GenericPrincipal(Context.User.Identity, Roles.GetAllRoles());
            }
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            Exception ex = Server.GetLastError();
            string text = string.Empty;
            if (ex != null)
            {
                if (!ex.Message.Contains("UnhandledException"))
                {
                    text = ex.Message;
                }
                Exception inner = ex.InnerException;
                while (inner != null)
                {
                    text += "\r\n";
                    text += inner.Message;
                    inner = inner.InnerException;
                }

                logger.ErrorException(text, ex);
                logger.Error(text);

                if (HttpContext.Current.Session != null)
                {
                    Session.Add(SessionObjects.Message, text);
                }

                // this explains the following three lines: https://blogs.msdn.com/b/tmarq/archive/2009/06/25/correct-use-of-system-web-httpresponse-redirect.aspx?Redirected=true
                Response.Redirect("~/Error.aspx", false);
                Context.ApplicationInstance.CompleteRequest();
            }
            Server.ClearError();
        }
    }
}