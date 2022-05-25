namespace Pentag.SLIDS.Constants
{
    public class ViewName
    {
        public static string StatsDonor = "StatsDonor";
        public static string StatsOrgans = "StatsOrgans";
        public static string StatsTransports = "StatsTransports";
        public static string StatsGeneralCosts = "StatsGeneralCosts";
        public static string StatsTransportCosts = "StatsTransportCosts";
        public static string StatsDonorWhiteTransporttime = "StatsDonorWhiteTransporttime";
    }

    /// <summary>
    ///     Keys for SessionObjects
    /// </summary>
    public class SessionObjects
    {
        // basic - those are kept when ClearAllTreatmentSessionData (BasePage) is called
        public static string SessionTimedOut = "SessionTimedOut";

        // general
        public static string Message = "Message";
    }

    /// <summary>
    ///     Status messages after save, update or delete
    /// </summary>
    public class StatusMessages
    {
        public const string MsgSaveSuccess = "Data has been saved!";
        public const string MsgSaveError = "Data could not be saved!";

        public const string MsgDeleteSuccess = "Data has been deleted!";
        public const string MsgDeleteError = "Data could not be deleted!";

        public const string MsgNoDataModified = "No data has been modified";

        // Administration messages
        public const string MsgNoLeadingOrTrailingSpaces = "The username cannot contain leading or trailing spaces.";
        public const string MsgUsernameInPasswordNotAllowed = "The username may not appear anywhere in the password.";
        public const string MsgSelectUsernameInDropDownList = "You must select a username from the dropdown list.";
        public const string MsgSelectRoleInDropDownList = "You must select a role from the dropdown list.";
        public const string MsgUsernameAlreadyExists = "This username already exists. Please choose a different one.";

        // CostType allocation message
        public const string MsgNumberOfTransplantOrgansDontMatchRequirementsOfCostDistribution =
            "The number of available transplantorgans don't meet the criteria for this cost type!";

        // Concurrency message
        public const string MsgConcurrencyException =
            "The current record you were about to modify was modified by an other user in the meantime.<br>" +
            "Your operation has been cancelled and the current values have been reloaded from the database.<br>" +
            "Please modify the record again using these current values.";

        public const string MsgConcurrencyNullException =
            "The current record you were about to modify was deleted by an other user in the meantime.<br>" +
            "Your operation could not be excecuted. The page has been refreshed.";

        public const string MsgConcurrencyDeleteNullException =
            "The current record you were about to delete was deleted by an other user in the meantime.<br>" +
            "Your operation could not be excecuted. The page has been refreshed.";

        public const string MsgConcurrencyInactiveNullException =
            "The current record you were about to inactivate was inactivated by an other user in the meantime.<br>" +
            "Your operation could not be excecuted. The page has been refreshed.";

        // Incident
        public const string MsgIncidentOpenTasks = "There are open Tasks releated to this incident. Status change has not been saved.";
    }

    /// <summary>
    ///     Default value for DropDownLists
    /// </summary>
    public class DropDownDefaultValue
    {
        public const string DDL_DEFAULT_TEXT = "Please select...";
        public const string DDL_DEFAULT_VALUE = "0";
    }
}