/*--------------------------------------------------------------------------------------------------
	Author:			PENTAG,P. Schwaller
	Create date:	13.11.2012
	Description:	Dieses Script fügt statische Daten in die Datenbank SLIDS hinzu.
					Das Script ist mehrfach durchführbar.
					
	Update date:
	Description:			
--------------------------------------------------------------------------------------------------*/


/*--------------------------------------------------------------------------------------------------
	-- Membership bezogene Daten:
--------------------------------------------------------------------------------------------------*/
DECLARE @ApplicationId AS Uniqueidentifier
SET @ApplicationId = (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = 'SLIDS')

-- Insert oder Update Application-Data for Membership
IF @ApplicationId IS NULL
BEGIN
	INSERT INTO aspnet_Applications(ApplicationName, 
									LoweredApplicationName, 
									[Description]) 
	VALUES(	'SLIDS', 
			'slids', 
			'Swisstransplant Logistics and Invoice Documentation System')
	
	SET @ApplicationId = (SELECT ApplicationId FROM aspnet_Applications WHERE ApplicationName = 'SLIDS')
END

-- Insert Roles for Membership
IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'admin')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'Admin', 'admin', 'Administrator')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'tc')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'TC', 'tc', 'Transplantationskoordinator')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'nc')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'NC', 'nc', 'Nationaler Koordinator')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'aaa')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'AAA', 'aaa', 'Alpin Air Ambulance')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'incidentadmin')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'IncidentAdmin', 'incidentadmin', 'Incident Administrator')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'incidentuser')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'IncidentUser', 'incidentuser', 'Incident User')
END

IF NOT EXISTS(SELECT * FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'swisstransplant')
BEGIN
	INSERT INTO aspnet_Roles(ApplicationId, RoleName, LoweredRoleName, [Description])
	VALUES(@ApplicationId, 'Swisstransplant', 'swisstransplant', 'Swisstransplant')
END

-- Insert Users
DECLARE @AdminRole AS UniqueIdentifier
DECLARE @NCRole As UniqueIdentifier
DECLARE @TCRole As UniqueIdentifier
DECLARE @AAARole As UniqueIdentifier
SET @AdminRole = (SELECT RoleId FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'admin')
SET @NCRole = (SELECT RoleId FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'nc')
SET @TCRole = (SELECT RoleId FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'tc')
SET @AAARole = (SELECT RoleId FROM aspnet_Roles WHERE ApplicationId = @ApplicationId AND LoweredRoleName = 'aaa')

DECLARE @UserId AS UniqueIdentifier
DECLARE @UserName AS NVarchar(256)
DECLARE @Email AS NVarchar(256)

-- Insert Administrators
SET @UserName = 'Pentag_User'
SET @Email = 'SLIDS@pentag.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'b/KdjKGpEYXRUiTwjDALlVbQ8c8=', 
			1, 
			'h792T5dLEMvs9LR1Omhwnw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
END

-- Insert National Coordinators including Administrator role
SET @UserName = 'ST-BEF'
SET @Email = 'Franziska.Beyeler@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

-- Insert National Coordinators including Administrator role
SET @UserName = 'ST-COM'
SET @Email = 'Marlies.Corpataux@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-CRT'
SET @Email = 'Tatjana.Crivelli@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-EGD'
SET @Email = 'David.Egger@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-GUD'
SET @Email = 'Danick.Gut@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-HAM'
SET @Email = 'Martin.Haefliger@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-PUJ'
SET @Email = 'Jacqueline.Pulver@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-RUH'
SET @Email = 'Henrik.Rutschmann@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-WAS'
SET @Email = 'Susanna.Waelchli@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @AdminRole)
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

-- Insert National Coordinators (without admin rights)
SET @UserName = 'ST-IMF'
SET @Email = 'Franz.Immer@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-KIB'
SET @Email = 'Beat.Kipfer@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

SET @UserName = 'ST-VED'
SET @Email = 'Dagmar.Vernet@swisstransplant.org'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @NCRole)
END

-- Insert Transplantcoordinators
SET @UserName = 'BE-BER'
SET @Email = 'transplantationskoordination@insel.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BE-BIP'
SET @Email = 'transplantationskoordination@insel.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BE-CHL'
SET @Email = 'transplantationskoordination@insel.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BE-KUM'
SET @Email = 'transplantationskoordination@insel.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BS-BLP'
SET @Email = 'pblaschke@uhbs.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BS-MUU'
SET @Email = 'ulmueller@uhbs.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BS-SPJ'
SET @Email = 'jsprachta@uhbs.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'BS-VOT'
SET @Email = 'tvoegele@uhbs.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-ARH'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-CAN'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-KEM'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-MAE'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-ROF'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'GE-SCP'
SET @Email = 'coordination.transplantation@hcuge.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'SG-ALS'
SET @Email = 'sascha.albert@kssg.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'SG-ENW'
SET @Email = 'wolfgang.ender@kssg.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-BES'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-DEM'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-KLC'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-PIN'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-STK'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'VD-STM'
SET @Email = 'coordination.transplantation@hospvd.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-BNA'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-HES'
SET @Email = 'sandra.kugelmeier@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-MES'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-NAW'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-RES'
SET @Email = 'stefan.regenscheit@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-RET'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-RIR'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'ZH-WEM'
SET @Email = 'transplantationskoordination@usz.ch'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'TI-BOA'
SET @Email = 'bocchiandreina@ticino.com'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END

SET @UserName = 'TI-GHE'
SET @Email = 'evagha7@yahoo.it'
IF NOT EXISTS(SELECT * FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
BEGIN
	INSERT INTO aspnet_Users(ApplicationId, UserName, LoweredUserName, LastActivityDate)
	VALUES(@ApplicationId, @UserName, (SELECT LOWER(@UserName)), GETDATE())
	
	SET @UserId = (SELECT UserId FROM aspnet_Users WHERE ApplicationId = @ApplicationId AND LoweredUserName = (SELECT LOWER(@UserName)))
	
	INSERT INTO aspnet_Membership(	ApplicationId, 
									UserId, 
									[Password], 
									PasswordFormat, 
									PasswordSalt, 
									Email, 
									LoweredEmail, 
									IsApproved, 
									IsLockedOut, 
									CreateDate, 
									LastLoginDate, 
									LastPasswordChangedDate, 
									LastLockoutDate, 
									FailedPasswordAttemptCount, 
									FailedPasswordAttemptWindowStart, 
									FailedPasswordAnswerAttemptCount, 
									FailedPasswordAnswerAttemptWindowStart)
	VALUES(	@ApplicationId, 
			@UserId, 
			'fhCMkg4VkOmuJcFiTnNfMziB3N8=', 
			1, 
			'CpWbAOre5KSwrbmrKdaYLw==', 
			@Email, 
			(SELECT LOWER(@Email)), 
			1, 
			0, 
			GETDATE(), 
			GETDATE(), 
			GETDATE(),
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000', 
			0, 
			'1754/01/01 00:00:00.000')
	
	INSERT INTO aspnet_UsersInRoles(UserId, RoleId)
	VALUES(@UserId, @TCRole)
END


-- insert Data in table Language
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'German')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('German', 'de')
END
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'French')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('French', 'fr')
END
IF NOT EXISTS (SELECT * FROM [dbo].[Language] WHERE [LanguageName] = 'Italian')
BEGIN
	INSERT INTO [dbo].[Language]([LanguageName], [LanguageShort]) VALUES('Italian', 'it')
END


--Insert Hospitals
DECLARE @AddressID AS INT
DECLARE @AccountingAddressID AS INT
IF NOT EXISTS(SELECT * FROM [Address] WHERE ID = -1)
BEGIN
SET IDENTITY_INSERT [Address] ON
INSERT INTO [Address] (ID, Address1) VALUES (-1, 'Default Address')
SET IDENTITY_INSERT [Address] OFF
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE ID = -1)
BEGIN
SET IDENTITY_INSERT Hospital ON
INSERT INTO Hospital (ID, Name, Code, Display, AddressID) VALUES (-1, 'FO-Team', 'FO-Team', 'FO-Team', -1)
SET IDENTITY_INSERT Hospital OFF
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-AAHIRS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Schänisweg', '5000', 'Aarau', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schänisweg', '5000', 'Aarau', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('AG-AAHIRS','Hirslanden Klinik Aarau', 'AG-AAHIRS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-AAKSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Tellstrasse 15', '5001', 'Aarau', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Tellstrasse 15', '5001', 'Aarau', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('AG-AAKSPI','Kantonsspital Aarau', 'AG-AAKSPI', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'AG-BAKSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Im Ergel 1', '5404', 'Baden', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Im Ergel 1', '5404', 'Baden', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('AG-BAKSPI','Kantonsspital Baden', 'AG-BAKSPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'AR-KANSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 6', '9100', 'Herisau', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 6', '9100', 'Herisau', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('AR-KANSPI','Kantonsspital Herisau', 'AR-KANSPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-BEAUSI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Schänzlihalde 11', '3000', 'Bern 25', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schänzlihalde 11', '3000', 'Bern 25', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-BEAUSI','Klinik Beau-Site Bern', 'BE-BEAUSI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-BIEL')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Vogelsang 84', '2501', 'Biel', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2,  Zip, City, CountryISO) VALUES('Finanzen', 'Vogelsang 84', 'Postfach', '2501', 'Biel', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-BIEL','Spitalzentrum Biel', 'BE-BIEL', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-EMBURG')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Oberburgstrasse 54', '3400', 'Burgdorf', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Oberburgstrasse 54', '3400', 'Burgdorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-EMBURG','Regionalspital Emmental', 'BE-EMBURG', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-INSEL')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO) VALUES('Inselspital Bern', 'Transplantations-Koordination', 'Notfallstation', 'Freiburgerstrasse 18', '3010', 'Bern', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Buchhaltung', 'Freiburgerstrasse 10', '3010', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-INSEL','Inselspital Bern', 'BE-INSEL', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-INTERL')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Weissenaustrasse 27', '3800', 'Unterseen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Weissenaustrasse 27', '3800', 'Unterseen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-INTERL','Spital Interlaken', 'BE-INTERL', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-LANGEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('St. Urbanstrasse 67', '4901', 'Langenthal', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'St. Urbanstrasse 67', '4901', 'Langenthal', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-LANGEN','Spital Region Oberaargau', 'BE-LANGEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE- LINDEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Bremgartenstrasse 117', '3001', 'Bern', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Bremgartenstrasse 117', 'Postfach', '3001', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE- LINDEN','Lindenhofspital Bern', 'BE- LINDEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-SONNEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Buchserstrasse 30', '3006', 'Bern', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Buchserstrasse 30', '3006', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-SONNEN','Klinik Sonnenhof Bern', 'BE-SONNEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-THUN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Krankenhausstrasse 12', '3600', 'Thun', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Krankenhausstrasse 12', '3600', 'Thun', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-THUN','Spital Thun-Simmental', 'BE-THUN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-TIEFEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Tiefenaustrasse 112', '3004', 'Bern 4', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Tiefenaustrasse 112', 'Postfach 700', '3004', 'Bern 4', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-TIEFEN','Tiefenauspital Bern', 'BE-TIEFEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BE-ZIEGLE')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Morillonstrasse 75', '3001', 'Bern', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Morillonstrasse 75', 'Postfach', '3001', 'Bern', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BE-ZIEGLE','Zieglerspital', 'BE-ZIEGLE', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BL-BRUDER')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES(NULL, '4101', 'Bruderholz', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', NULL, '4101', 'Bruderholz', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BL-BRUDER','Kantonsspital Bruderholz', 'BL-BRUDER', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BL-LIES')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Rheinstrasse 26', '4410', 'Liestal', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Rheinstrasse 26', '4410', 'Liestal', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BL-LIES','Kantonsspital Liestal', 'BL-LIES', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-CLARAS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Kleinriehenstrasse 30', '4058', 'Basel', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Kleinriehenstrasse 30', '4058', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BS-CLARAS','St. Clara Spital Basel', 'BS-CLARAS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-KISPIT')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 33', '4056', 'Basel', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 33', '4056', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BS-KISPIT','Kinderspital Basel', 'BS-KISPIT', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'BS-UNISPIT')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO) VALUES('Universitätsspital Basel', 'Notfallstation', 'Abt. für Nephrologie', 'Petersgraben 4', '4031', 'Basel', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Petersgraben 4', '4031', 'Basel', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('BS-UNISPIT','UHSB Basel', 'BS-UNISPIT', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'FR-HOPCAN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Chemin de Pensionnats 2-6', '1708', 'Fribourg', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Facturation', 'Chemin de Pensionnats 2-6', 'Case postale', '1708', 'Fribourg', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('FR-HOPCAN','Hôpital Cantonal Fribourg', 'FR-HOPCAN', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GE-HUG')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Secteur facturation aux tiers', 'Chemin de Petit-Bel-Air 2', '1225', 'Chène-Bourg', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GE-HUG','Hôpital universitaires de Genève', 'GE-HUG', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GE-LATOUR')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Avenue J.D. Maillard 3', '1217', 'Meyrin', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue J.D. Maillard 3', '1217', 'Meyrin', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GE-LATOUR','Hôpital la Tour Meyrin', 'GE-LATOUR', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GL-GLARUS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Burgstrasse 99', '8750', 'Glarus', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Burgstrasse 99', '8750', 'Glarus', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GL-GLARUS','Kantonsspital Glarus', 'GL-GLARUS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-CHUR')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Loesstrasse 170', '7000', 'Chur', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Loesstrasse 170', '7000', 'Chur', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GR-CHUR','Kantonsspital Graubünden', 'GR-CHUR', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-DAVOS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Promenade 4', '7270', 'Davos', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Promenade 4', '7270', 'Davos', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GR-DAVOS','Spital Davos', 'GR-DAVOS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'GR-SAMED')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES(NULL, '7503', 'Samedan', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', NULL, '7503', 'Samedan', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('GR-SAMED','Spital Oberengadin', 'GR-SAMED', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'JU-DELEMO')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Fbg des Capucins 30', '2800', 'Delémont', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Fbg des Capucins 30', '2800', 'Delémont', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('JU-DELEMO','Hôpital du Jura', 'JU-DELEMO', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-KANSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES(NULL, '6000', 'Luzern 16', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Ambulante Abrechnung', 'Spitalstrasse', '6000', 'Luzern 16', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('LU-KANSPI','Kantonsspital Luzern', 'LU-KANSPI', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-KISPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Kantonsspital', '6000', 'Luzern 16', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Kantonsspital', '6000', 'Luzern 16', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('LU-KISPI','Kinderspital Luzern', 'LU-KISPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-NOTTWI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Guido A. Zäch-Strasse 1', '6207', 'Nottwil', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Guido A. Zäch-Strasse 1', '6207', 'Nottwil', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('LU-NOTTWI','Schweizer Paraplegikerzentrum Nottwil', 'LU-NOTTWI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-STANNA')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('St. Annastrasse 32', '6006', 'Luzern', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'St. Annastrasse 32', '6006', 'Luzern', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('LU-STANNA','Klinik St. Anna', 'LU-STANNA', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'LU-SURSEE')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 16a', '6210', 'Sursee', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 16a', 'Postfach', '6210', 'Sursee', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('LU-SURSEE','Spital Sursee-Wolhusen', 'LU-SURSEE', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'NE-CHAUX')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Chasseral 20', '2300', 'La Chaux-de-Fonds', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chasseral 20', '2300', 'La Chaux-de-Fonds', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('NE-CHAUX','Hôpital de la Chaux-de-Fonds', 'NE-CHAUX', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'NE-NEPOUR')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Maladière 45', '2000', 'Neuchâtel', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Maladière 45', '2000', 'Neuchâtel', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('NE-NEPOUR','Hôpital Pourtalès Neuchâtel', 'NE-NEPOUR', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'NW-NIDWALD')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Ennetmooserstrasse 19', '6370', 'Stans', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Ennetmooserstrasse 19', '6370', 'Stans', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('NW-NIDWALD','Kantonsspital Nidwalden', 'NW-NIDWALD', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-KANSPI')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Zip, City, CountryISO) VALUES('St. Gallen Kantonsspital', 'Zentral Notfallstation', 'Rorschacherstrasse 95', '9007', 'St. Gallen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Rorschacherstrasse 95', '9007', 'St. Gallen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SG-KANSPI','Kantonsspital St. Gallen', 'SG-KANSPI', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-KISPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Claudiusstrasse 6', '9007', 'St. Gallen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Claudiusstrasse 6', '9007', 'St. Gallen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SG-KISPI','Ostschweizer Kinderspital St. Gallen', 'SG-KISPI', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SG-WALENS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 5', '8880', 'Walenstadt', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 5', '8880', 'Walenstadt', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SG-WALENS','Spital Walenstadt', 'SG-WALENS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SH-SCHAFF')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Geissbergstrasse 81', '8208', 'Schaffhausen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Geissbergstrasse 81', '8208', 'Schaffhausen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SH-SCHAFF','Kantonsspital Schaffhausen', 'SH-SCHAFF', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SO-OLKSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Baslerstrasse 150', '4600', 'Olten', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Baslerstrasse 150', '4600', 'Olten', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SO-OLKSPI','Kantonsspital Olten', 'SO-OLKSPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SO-SOBUER')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Schöngrünstrasse 42', '4500', 'Solothurn', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Schöngrünstrasse 42', '4500', 'Solothurn', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SO-SOBUER','Bürgerspital Solothurn', 'SO-SOBUER', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SZ-LACHEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Oberdorfstrasse 41', '8853', 'Lachen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Oberdorfstrasse 41', '8853', 'Lachen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SZ-LACHEN','Spital Lachen', 'SZ-LACHEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'SZ-SCHWYZ')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Waldeggstrasse 10', '6430', 'Schwyz', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Waldeggstrasse 10', '6430', 'Schwyz', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('SZ-SCHWYZ','Spital Schwyz', 'SZ-SCHWYZ', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-FRAUEN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Pfaffenholzstrasse 4', '8501', 'Frauenfeld', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Pfaffenholzstrasse 4', '8501', 'Frauenfeld', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TG-FRAUEN','Kantonsspital Frauenfeld', 'TG-FRAUEN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-KREUZ')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Weinbergstrasse 1', '8280', 'Kreuzlingen 2', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Weinbergstrasse 1', '8280', 'Kreuzlingen 2', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TG-KREUZ','Spital Kreuzlingen', 'TG-KREUZ', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TG-MÜNST')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalcampus 1', '8596', 'Münsterlingen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalcampus 1', '8596', 'Münsterlingen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TG-MÜNST','Kantonsspital Münsterlingen', 'TG-MÜNST', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-BELLIN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES(NULL, '6500', 'Bellinzona', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', NULL, '6500', 'Bellinzona', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TI-BELLIN','Osepedale San Giovanni Bellinzona', 'TI-BELLIN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 3)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LOCARN')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Via all''Ospedale 1', '6600', 'Locarno', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', 'Via all''Ospedale 1', '6600', 'Locarno', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TI-LOCARN','Ospedale La Carità Locarno', 'TI-LOCARN', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 3)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LUCARD')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Via Tesserete 48', '6903', 'Lugano', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Fatturazione', 'Via Tesserete 48', '6903', 'Lugano', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TI-LUCARD','Cardiocentro Lugano', 'TI-LUCARD', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 3)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-LUCIVI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Via Tesserete 46', '6900', 'Lugano', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Servizio Cent. Contabilita e fatturazione', 'Via Lugano 4b', '6501', 'Bellinzona', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TI-LUCIVI','Ospedale Civico Lugano', 'TI-LUCIVI', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 3)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'TI-MENDRI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Via Alfonso Turconi 23', '6850', 'Mendrisio', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Fatturazione', 'Via Turconi 23', 'CP 1652', '6850', 'Mendrisio', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('TI-MENDRI','Ospedale Beata Vergine Mendrisio', 'TI-MENDRI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 3)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'UR-ALKSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 1', '6460', 'Altdorf', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 1', '6460', 'Altdorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('UR-ALKSPI','Kantonsspital Uri', 'UR-ALKSPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-CECIL')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Avenue Louis-Ruchonnet 53', '1003', 'Lausanne', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue Louis-Ruchonnet 53', '1003', 'Lausanne', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-CECIL','Clinique Cécil Lausanne', 'VD-CECIL', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-CHUV')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Zip, City, CountryISO) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', '1011', 'Lausanne', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation opérationelle', 'Rue du Bugnon', '1011', 'Lausanne', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-CHUV','Centre hospitalier universitaire Vaudois', 'VD-CHUV', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-GHOL')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Route de l''Hôpital 26', '1180', 'Rolle', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chemin Monastier 10', '1260', 'Nyon', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-GHOL','Hôpital de Rolle', 'VD-GHOL', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-MORGES')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Chemin du Crêt 2', '1110', 'Morges', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Chemin du Crêt 2', '1110', 'Morges', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-MORGES','Hôpital de Morges', 'VD-MORGES', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-PAYERNE')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Avenue de la Colline 3', '1530', 'Payerne', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Address2, Zip, City, CountryISO) VALUES('Facturation', 'Avenue de la Colline 3', 'Case postale 192', '1530', 'Payerne', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-PAYERNE','Hôpital intercantonal de La Broye', 'VD-PAYERNE', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-POMPAP')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES(NULL, '1318', 'Pompaples', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', NULL, '1318', 'Pompaples', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-POMPAP','Hôpital de Zone de St-Loup', 'VD-POMPAP', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-VEVSAM')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Boulevard Paderewski 3', '1800', 'Vevey', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Boulevard Paderewski 3', '1800', 'Vevey', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-VEVSAM','Hôpital RIVIERA Site du Samaritain', 'VD-VEVSAM', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VD-YVERD')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Rue d''Entremonts 11', '1400', 'Yverdon-les-bains', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Rue d''Entremonts 11', '1400', 'Yverdon-les-bains', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VD-YVERD','Hôpital Yverdon', 'VD-YVERD', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-MONTH')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Route de Morgins', '1870', 'Monthey', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Route de Morgins', '1870', 'Monthey', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VS-MONTH','Hôpital du Chablais-Aigle', 'VS-MONTH', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-OBWS')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Ueberlandstrasse 14', '3900', 'Brig', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Ueberlandstrasse 14', '3900', 'Brig', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VS-OBWS','Spitalzentrum Oberwallis', 'VS-OBWS', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'VS-SION')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Avenue Grand-Champsec 80', '1951', 'Sion', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Facturation', 'Avenue Grand-Champsec 80', '1951', 'Sion', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('VS-SION','CH du centre du Valais', 'VS-SION', @AddressID, @AccountingAddressID, 1, 1, 0, 0, 2)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZG-ZUKSPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Landhausstrasse 11', '6340', 'Baar', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Landhausstrasse 11', '6340', 'Baar', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZG-ZUKSPI','Kantonsspital Zug', 'ZG-ZUKSPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-BÜLACH')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 24', '8180', 'Bülach', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 24', '8180', 'Bülach', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-BÜLACH','Spital Bülach', 'ZH-BÜLACH', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-HIRSLA')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Witellikerstrasse 40', '8008', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Witellikerstrasse 40', '8008', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-HIRSLA','Klinik Hirslanden Zürich', 'ZH-HIRSLA', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-KISPI')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Steinwiesstrasse 75', '8032', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Steinwiesstrasse 75', '8032', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-KISPI','Universitätskinderklinik Zürich', 'ZH-KISPI', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-LIMMAT')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Urdorferstrasse 100', '8952', 'Schlieren', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Urdorferstrasse 100', '8952', 'Schlieren', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-LIMMAT','Spital Limmattal', 'ZH-LIMMAT', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-MÄNNED')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Asylstrasse 10', '8708', 'Männedorf', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Asylstrasse 10', '8708', 'Männedorf', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-MÄNNED','Kreisspital Männedorf', 'ZH-MÄNNED', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-PARK')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Seestrasse 220', '8027', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Seestrasse 220', '8027', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-PARK','Klinik im Park Zürich', 'ZH-PARK', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-TRIEM')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Birmensdorferstrasse 497', '8063', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Birmensdorferstrasse 497', '8063', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-TRIEM','Stadtspital Triemli Zürich', 'ZH-TRIEM', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-USTER')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Brunnenstrasse 42', '8610', 'Uster', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Brunnenstrasse 42', '8610', 'Uster', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-USTER','Spital Uster', 'ZH-USTER', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-USZ')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Stationäre Abrechnung', 'Rämistrasse 100', '8091', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-USZ','Universitätsspital Zürich', 'ZH-USZ', @AddressID, @AccountingAddressID, 1, 1, 1, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WAID')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Tièchestrasse 99', '8037', 'Zürich', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Tièchestrasse 99', '8037', 'Zürich', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-WAID','Stadtspital Waid Zürich', 'ZH-WAID', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WETZ')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Spitalstrasse 60', '8620', 'Wetzikon', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Spitalstrasse 60', '8620', 'Wetzikon', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-WETZ','GZO Spital Wetzikon', 'ZH-WETZ', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-WINTH')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Brauerstrasse 15', '8401', 'Winterthur', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Brauerstrasse 15', '8401', 'Winterthur', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-WINTH','Kantonsspital Winterthur', 'ZH-WINTH', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-ZIMBER')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Asylstrasse 19', '8810', 'Horgen', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Asylstrasse 19', '8810', 'Horgen', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-ZIMBER','Spital Zimmerberg Horgen', 'ZH-ZIMBER', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END
IF NOT EXISTS(SELECT * FROM Hospital WHERE Code = 'ZH-ZOLLIK')
BEGIN
INSERT INTO Address(Address1, Zip, City, CountryISO) VALUES('Trichtenhauserstrasse 20', '8125', 'Zollikerberg', 'CH')
SET @AddressID = @@IDENTITY
INSERT INTO Address(ContactPerson, Address1, Zip, City, CountryISO) VALUES('Finanzen', 'Trichtenhauserstrasse 20', '8125', 'Zollikerberg', 'CH')
SET @AccountingAddressID = @@IDENTITY
INSERT INTO Hospital(Code, Name, Display, AddressID, AccountingAddressID, IsReferral, IsProcurement, IsTransplantation, IsFo, CorrespondanceLanguageID) VALUES('ZH-ZOLLIK','Spital Zollikerberg', 'ZH-ZOLLIK', @AddressID, @AccountingAddressID, 1, 0, 0, 0, 1)
END


--Insert Transplantation Coordinators
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BE-BER')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Inselspital Bern', 'Transplantations-Koordination', 'Notfallstation', 'Freiburgerstrasse 18', '3010', 'Bern', 'CH', '031 632 83 95', 'transplantationskoordination@insel.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BE-BER','Regula', 'Beck', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BE-INSEL'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BE-BIP')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Inselspital Bern', 'Transplantations-Koordination', 'Notfallstation', 'Freiburgerstrasse 18', '3010', 'Bern', 'CH', '031 632 83 95', 'transplantationskoordination@insel.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BE-BIP','Petra', 'Bischoff', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BE-INSEL'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BE-CHL')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Inselspital Bern', 'Transplantations-Koordination', 'Notfallstation', 'Freiburgerstrasse 18', '3010', 'Bern', 'CH', '031 632 83 95', 'transplantationskoordination@insel.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BE-CHL','Lucienne', 'Christen', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BE-INSEL'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BE-KUM')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Inselspital Bern', 'Transplantations-Koordination', 'Notfallstation', 'Freiburgerstrasse 18', '3010', 'Bern', 'CH', '031 632 83 95', 'transplantationskoordination@insel.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BE-KUM','Marlène', 'Kunz', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BE-INSEL'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BS-BLP')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Basel', 'Notfallstation', 'Abt. für Nephrologie', 'Petersgraben 4', '4031', 'Basel', 'CH', '079 938 11 99', 'pblaschke@uhbs.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BS-BLP','Patricia', 'Blaschke', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BS-UNISPIT'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BS-MUU')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Basel', 'Notfallstation', 'Abt. für Nephrologie', 'Petersgraben 4', '4031', 'Basel', 'CH', '079 573 87 98', 'ulmueller@uhbs.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BS-MUU','Ulrike', 'Müller', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BS-UNISPIT'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BS-SPJ')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Basel', 'Notfallstation', 'Abt. für Nephrologie', 'Petersgraben 4', '4031', 'Basel', 'CH', '079 573 79 97', 'jsprachta@uhbs.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BS-SPJ','Jan', 'Sprachta', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BS-UNISPIT'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'BS-VOT')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Basel', 'Notfallstation', 'Abt. für Nephrologie', 'Petersgraben 4', '4031', 'Basel', 'CH', '079 473 39 76', 'tvoegele@uhbs.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'BS-VOT','Thomas', 'Vögele', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'BS-UNISPIT'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-ARH')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-ARH','Hélène', 'Ara-Somohano', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-CAN')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-CAN','Nadine', 'De Carpentry', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-KEM')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-KEM','Marie-Claude', 'Kempf', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-MAE')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-MAE','Eric', 'Masson', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-ROF')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-ROF','Florence', 'Roch Barrena', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'GE-SCP')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Hôpital Universitaire Genève', 'Coordination transplantation', 'Centre d''accueil d''urgence', 'Rue Gabrielle-Perret-Gentil 4', '1211', 'Genève 14', 'CH', '079 553 41 62/079 615 10 12', 'coordination.transplantation@hcuge.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'GE-SCP','Patricia', 'Schauenburg', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'GE-HUG'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'SG-ALS')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('St. Gallen Kantonsspital', 'Zentral Notfallstation', 'Rorschacherstrasse 95', NULL, '9007', 'St. Gallen', 'CH', '079 784 14 54', 'sascha.albert@kssg.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'SG-ALS','Sascha', 'Albert', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'SG-KANSPI'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'SG-ENW')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('St. Gallen Kantonsspital', 'Zentral Notfallstation', 'Rorschacherstrasse 95', NULL, '9007', 'St. Gallen', 'CH', '079 814 28 18', 'wolfgang.ender@kssg.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'SG-ENW','Wolfgang', 'Ender', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'SG-KANSPI'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-BES')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-BES','Stephanie', 'Bernard', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-DEM')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-DEM','Marie-France', 'Derkenne', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-KLC')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-KLC','Christina', 'Klein-Fonjallaz', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-PIN')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-PIN','Nathalie', 'Pilon', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-STK')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-STK','Karine', 'St-Pierre', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'VD-STM')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Coordination locale de transplantation', 'CHUV-Accueil-PMU', '44, Avenue du Bugnon', NULL, '1011', 'Lausanne', 'CH', '021 314 17 69', 'coordination.transplantation@hospvd.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'VD-STM','Michele', 'Steiner', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'VD-CHUV'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-BNA')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-BNA','Natascha', 'Böhmer', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-HES')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 22 22', 'sandra.kugelmeier@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-HES','Sandra', 'Kugelmeier', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-MES')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-MES','Stefan', 'Meinzer', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-NAW')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-NAW','Werner', 'Naumer', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-RES')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 22 22', 'stefan.regenscheit@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-RES','Stefan', 'Regenscheit', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-RET')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-RET','Therese', 'Reh', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-RIR')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-RIR','Regula', 'Rigort', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ZH-WEM')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Universitätsspital Zürich', 'Z. Hd. Transplantations koordination', 'Notfallstation', 'Schmelzbergstrasse', '8091', 'Zürich', 'CH', '044 255 66 66', 'transplantationskoordination@usz.ch')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'ZH-WEM','Martin', 'Wendt', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'ZH-USZ'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'TI-BOA')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Via Tesserete 46', NULL, NULL, NULL, '6900', 'Lugano', 'CH', NULL, 'bocchiandreina@ticino.com')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'TI-BOA','Andreina', 'Bocchi', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'TI-LUCIVI'
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'TI-GHE')
BEGIN
INSERT INTO Address(Address1, Address2, Address3, Address4, Zip, City, CountryISO, Phone, Email) VALUES('Via Tesserete 46', NULL, NULL, NULL, '6900', 'Lugano', 'CH', NULL, 'evagha7@yahoo.it')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsTC, IsNC, HospitalID) SELECT 'TI-GHE','Eva', 'Ghanfili', @AddressID, 1, 0, ID FROM Hospital WHERE Code = 'TI-LUCIVI'
END

--Insert National Coordinators
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-BEF')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Franziska.Beyeler@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-BEF', 'Franziska', 'Beyeler', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-COM')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Marlies.Corpataux@swisstransplant.org', '+41 31 380 81 44')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-COM', 'Marlies', 'Corpataux', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-CRT')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Tatjana.Crivelli@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-CRT', 'Tatjana', 'Crivelli', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-EGD')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'David.Egger@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-EGD', 'David', 'Egger', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-GUD')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Danick.Gut@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-GUD', 'Danick', 'Gut', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-IMF')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Franz.Immer@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-IMF', 'Franz', 'Immer', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-KEI')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Isabelle.Keel@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-KEI', 'Isabelle', 'Keel', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-KIB')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Beat.Kipfer@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-KIB', 'Beat', 'Kipfer', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-PUJ')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Jacqueline.Pulver@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-PUJ', 'Jacqueline', 'Pulver', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-SEV')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Vanessa.Sedleger@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-SEV', 'Vanessa', 'Sedleger', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-SPC')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Caroline.Spaight@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-SPC', 'Caroline', 'Spaight', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-VED')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Dagmar.Vernet@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-VED', 'Dagmar', 'Vernet', @AddressID, 1, 0)
END
IF NOT EXISTS(SELECT * FROM Coordinator WHERE Code = 'ST-WAS')
BEGIN
INSERT INTO Address(Address1, Address2, Zip, City, CountryISO, Phone, Email, Fax)
VALUES('Swisstransplant', 'Laupenstrasse 37', '3008', 'Bern', 'CH', '+41 79 203 39 09', 'Susanna.Waelchli@swisstransplant.org', '+41 31 380 81 42')
INSERT INTO Coordinator(Code, FirstName, LastName, AddressID, IsNC, IsTC)
VALUES('ST-WAS', 'Susanna', 'Waelchli', @AddressID, 1, 0)
END

--insert Organs
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Heart')
BEGIN
	INSERT INTO Organ(Name) VALUES('Heart')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Lung bilateral')
BEGIN
	INSERT INTO Organ(Name) VALUES('Lung bilateral')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Lung left')
BEGIN
	INSERT INTO Organ(Name) VALUES('Lung left')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Lung right')
BEGIN
	INSERT INTO Organ(Name) VALUES('Lung right')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Liver')
BEGIN
	INSERT INTO Organ(Name) VALUES('Liver')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Liver left lateral graft')
BEGIN
	INSERT INTO Organ(Name) VALUES('Liver left lateral graft')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Liver right extended graft')
BEGIN
	INSERT INTO Organ(Name) VALUES('Liver right extended graft')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Liver right lobe graft')
BEGIN
	INSERT INTO Organ(Name) VALUES('Liver right lobe graft')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Kidney left')
BEGIN
	INSERT INTO Organ(Name) VALUES('Kidney left')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Kidney right')
BEGIN
	INSERT INTO Organ(Name) VALUES('Kidney right')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Both kidneys')
BEGIN
	INSERT INTO Organ(Name) VALUES('Both kidneys')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Kidneys en bloc')
BEGIN
	INSERT INTO Organ(Name) VALUES('Kidneys en bloc')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Pancreas')
BEGIN
	INSERT INTO Organ(Name) VALUES('Pancreas')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Pancreas for islets')
BEGIN
	INSERT INTO Organ(Name) VALUES('Pancreas for islets')
END
IF NOT EXISTS (SELECT * FROM Organ WHERE Name = 'Small bowel')
BEGIN
	INSERT INTO Organ(Name) VALUES('Small bowel')
END




--insert TransportItems
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for Serology/BG/HLA')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for Serology/BG/HLA')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Kidney le')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Kidney le')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Kidney ri')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Kidney ri')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Heart')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Heart')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Lung')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Lung')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Pancreas')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Pancreas')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Blood for X-Match Liver')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Blood for X-Match Liver')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Biopsy')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Biopsy')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Rapid section diagnosis')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Rapid section diagnosis')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Surgical material')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Surgical material')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Solutions')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Solutions')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Other')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Other')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Donor')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Donor')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Transplant Coordinator(s)')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Transplant Coordinator(s)')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Heart Team')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Heart Team')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Thoracic Team')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Thoracic Team')
END
IF NOT EXISTS (SELECT * FROM TransportItem WHERE Name = 'Abdominal Team')
BEGIN
	INSERT INTO TransportItem(Name) VALUES('Abdominal Team')
END

--insert TxStatus
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'REF')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('REF')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'PAT')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('PAT')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'POT')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('POT')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'AGE')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('AGE')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'MED')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('MED')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'NCR')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('NCR')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'NOF')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('NOF')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'REV')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('REV')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'LOG')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('LOG')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'NTX')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('NTX')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'PAC')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('PAC')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'OPI')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('OPI')
END
IF NOT EXISTS (SELECT * FROM TransplantStatus WHERE Name = 'TX')
BEGIN
	INSERT INTO TransplantStatus(Name) VALUES('TX')
END

--insert Vehicle
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Helicopter')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Helicopter')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Jet')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Jet')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Scheduled flight')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Scheduled flight')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Ambulance')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Ambulance')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Ambulance with blue light')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Ambulance with blue light')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Taxi')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Taxi')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'Patrol vehicle TCS')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('Patrol vehicle TCS')
END
IF NOT EXISTS (SELECT * FROM Vehicle WHERE Name = 'SBB')
BEGIN
	INSERT INTO Vehicle(Name) VALUES('SBB')
END

--insert OperationCenters
IF NOT EXISTS (SELECT * FROM OperationCenter WHERE Name = 'AAA')
BEGIN
	INSERT INTO OperationCenter(Name) VALUES('AAA')
END
IF NOT EXISTS (SELECT * FROM OperationCenter WHERE Name = 'Others')
BEGIN
	INSERT INTO OperationCenter(Name) VALUES('Others')
END

--insert Organizations
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Agence de la Biomédecine (ABM), FRA')
BEGIN
	INSERT INTO Organization(Name) VALUES('Agence de la Biomédecine (ABM), FRA')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, AUT')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, AUT')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, BEL')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, BEL')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, DEU')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, DEU')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, HRV')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, HRV')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, LUX')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, LUX')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, NLD')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, NLD')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'EuroTransplant, SVN')
BEGIN
	INSERT INTO Organization(Name) VALUES('EuroTransplant, SVN')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Hellenic Transplant')
BEGIN
	INSERT INTO Organization(Name) VALUES('Hellenic Transplant')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Italian Gate (IG), ITA')
BEGIN
	INSERT INTO Organization(Name) VALUES('Italian Gate (IG), ITA')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Nord Italia Transplant (NITp), ITA')
BEGIN
	INSERT INTO Organization(Name) VALUES('Nord Italia Transplant (NITp), ITA')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Org. Catalana de Transpl. (OCATT), ESP')
BEGIN
	INSERT INTO Organization(Name) VALUES('Org. Catalana de Transpl. (OCATT), ESP')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Org. National de Transpl. (ONT), ESP')
BEGIN
	INSERT INTO Organization(Name) VALUES('Org. National de Transpl. (ONT), ESP')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Org. Portug. de Transpl. (OPT), PRT')
BEGIN
	INSERT INTO Organization(Name) VALUES('Org. Portug. de Transpl. (OPT), PRT')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Scandiatransplant, DNK')
BEGIN
	INSERT INTO Organization(Name) VALUES('Scandiatransplant, DNK')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Scandiatransplant, FIN')
BEGIN
	INSERT INTO Organization(Name) VALUES('Scandiatransplant, FIN')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Scandiatransplant, ISL')
BEGIN
	INSERT INTO Organization(Name) VALUES('Scandiatransplant, ISL')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Scandiatransplant, NOR')
BEGIN
	INSERT INTO Organization(Name) VALUES('Scandiatransplant, NOR')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'Scandiatransplant, SWE')
BEGIN
	INSERT INTO Organization(Name) VALUES('Scandiatransplant, SWE')
END
IF NOT EXISTS (SELECT * FROM Organization WHERE Name = 'UK-Transplant, GBR')
BEGIN
	INSERT INTO Organization(Name) VALUES('UK-Transplant, GBR')
END

--insert Distances
DECLARE @Hospital1ID AS INT -- Procurement hospital
DECLARE @Hospital2ID AS INT	-- Transplantation hospital

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GE%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VD%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 71  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BE%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 157  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 248  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'ZH%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 282  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 361  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 396  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 266  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 237  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 433  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 163  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VD%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BE%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 101  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 200  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'ZH%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 226  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 305  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 340  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 210  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 181  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 377  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 98  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BE%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 99  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'ZH%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 133  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 207  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 243  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 111  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 84  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 278  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 156  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'BS%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'ZH%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 88  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 170  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 206  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 99  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 59  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 265  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 255  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'ZH%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 86  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 120  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 52  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 50  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 205  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 280  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Transplantation hospital
SET @Hospital2ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'SG%' AND IsTransplantation = 1), 0)

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'GR%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 101  
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'LU%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 143
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'AG%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 129
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'TI%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 244
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

-- Set Procurement hospital
SET @Hospital1ID = ISNULL((SELECT TOP 1 ID FROM Hospital WHERE Code LIKE 'VS%' AND IsProcurement = 1), 0)

IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital1ID AND Hospital2ID = @Hospital2ID)
BEGIN
	INSERT	INTO Distance(Hospital1ID, Hospital2ID, Km)
					SELECT	h1.ID, h2.ID, 359
					FROM	Hospital h1, Hospital h2
					WHERE	h1.ID = @Hospital1ID
					AND		h2.ID = @Hospital2ID
END
--und rückwärts...
IF NOT EXISTS (SELECT * FROM Distance WHERE Hospital1ID = @Hospital2ID AND Hospital2ID = @Hospital1ID)
BEGIN
	INSERT INTO Distance (Hospital1ID, Hospital2ID, km) 
					SELECT	Hospital2ID, Hospital1ID, km 
					FROM	Distance 
					WHERE	Hospital1ID = @Hospital1ID 
					AND		Hospital2ID = @Hospital2ID
END

--insert CostGroups
IF NOT EXISTS (Select * FROM CostGroup WHERE Name = 'Transport')
BEGIN
	INSERT INTO CostGroup (Name) VALUES ('Transport')
END
IF NOT EXISTS (Select * FROM CostGroup WHERE Name = 'Donor')
BEGIN
	INSERT INTO CostGroup (Name) VALUES ('Donor')
END
IF NOT EXISTS (Select * FROM CostGroup WHERE Name = 'TransportGlobal')
BEGIN
	INSERT INTO CostGroup (Name) VALUES ('TransportGlobal')
END

--insert CostTypes
IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Transport')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Transport', ID FROM CostGroup Where Name = 'Transport'
END

--insert CostTypes
IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Waiting Time')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Waiting Time', ID FROM CostGroup Where Name = 'Transport'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Dossier Costs')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Dossier Costs', ID FROM CostGroup Where Name = 'TransportGlobal'
END


declare @costDitributionID int
declare @CostTypeID int

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Flat charges IC')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Flat charges IC', ID FROM CostGroup Where Name = 'Donor'
		INSERT INTO CostDistribution (CostTypeID, Name, CalcTotal) VALUES (@@Identity, 'Flat charges IC' , 1) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2000 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2000 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 4000 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 4000 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1000 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1000 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Flat charges OR')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Flat charges OR', ID FROM CostGroup Where Name = 'Donor'
		INSERT INTO CostDistribution (CostTypeID, Name, CalcTotal) VALUES (@@Identity, 'Flat charges OR' , 1) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 1500 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 3000 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Const) SELECT ID, @costDitributionID, 2500 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Basic Amount IC')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Basic Amount IC', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, MinOrganCount, MaxOrganCount, ReferOnlyOnTransplantedOrgans, TotalConst) VALUES (@CostTypeID, 'Basic Amount IC 0' , 0, 0, 1, 8000) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'

		INSERT INTO CostDistribution (CostTypeID, Name, MinOrganCount, MaxOrganCount, ReferOnlyOnTransplantedOrgans, TotalConst) VALUES (@CostTypeID, 'Basic Amount IC 1-3' , 1, 3, 1, 5500) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'

		INSERT INTO CostDistribution (CostTypeID, Name, MinOrganCount, MaxOrganCount, ReferOnlyOnTransplantedOrgans, TotalConst) VALUES (@CostTypeID, 'Basic Amount IC 4+' , 4, 99, 1, 3000) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'

END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Basic Amount OR')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Basic Amount OR', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, MinOrganCount, MaxOrganCount, ReferOnlyOnTransplantedOrgans, TotalConst) VALUES (@CostTypeID, 'Basic Amount OR 0' , 0, 0, 1, 5000) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'

		INSERT INTO CostDistribution (CostTypeID, Name, MinOrganCount, MaxOrganCount, ReferOnlyOnTransplantedOrgans, TotalConst) VALUES (@CostTypeID, 'Basic Amount OR 1+' , 1, 99, 1, 2500) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'


END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Flat charges IC detection hospital')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Flat charges IC detection Hospital', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Flat charges IC detection hospital' , 2000) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Family approach')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Family approach', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Family approach' , 400) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external heart or lung')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external heart or lung', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external heart or lung' , 1050) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external abdomen')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external abdomen', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external abdomen' , 2100) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external only kidneys')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external only kidneys', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external only kidneys' , 1050) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external only liver')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external only liver', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external only liver' , 1750) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external only pancreas/insel')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external only pancreas/insel', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external only pancreas/insel' , 1050) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team external only small bowel')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team external only small bowel', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team external only small bowel' , 1050) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal heart or lung')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal heart or lung', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal heart or lung' , 350) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal abdomen')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal abdomen', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal abdomen' , 1400) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal only kidneys')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal only kidneys', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal only kidneys' , 350) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal only liver')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal only liver', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal only liver' , 1050) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal only pancreas/insel')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal only pancreas/insel', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal only pancreas/insel' , 350) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
END

IF NOT EXISTS (Select * FROM CostType WHERE Name = 'Explant-team internal only small bowel')
BEGIN
	INSERT INTO CostType (Name, CostGroupID) SELECT 'Explant-team internal only small bowel', ID FROM CostGroup Where Name = 'Donor'
	SELECT @CostTypeID = @@IDENTITY
		INSERT INTO CostDistribution (CostTypeID, Name, TotalConst) VALUES (@CostTypeID, 'Explant-team internal only small bowel' , 350) 
		SELECT @costDitributionID = @@IDENTITY
			INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Dossier Costs')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name) SELECT ct.ID, 'Dossier Costs' from CostType ct WHERE ct.Name = 'Dossier Costs'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Helicopter')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Helicopter' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Helicopter'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Helicopter')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Helicopter' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Helicopter'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Jet')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Jet' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Jet'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Jet')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Jet' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Jet'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Scheduled flight')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Scheduled flight' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Scheduled flight'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, ConstPerKm) SELECT ID, @costDitributionID, 4.6 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Scheduled flight')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Scheduled flight' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Scheduled flight'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Ambulance')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Ambulance' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Ambulance'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Ambulance')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Ambulance' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Ambulance'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Ambulance with blue light')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Ambulance with blue light' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Ambulance with blue light'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Ambulance with blue light')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Ambulance with blue light' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Ambulance with blue light'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Taxi')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Taxi' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Taxi'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Taxi')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Taxi' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Taxi'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport Patrol vehicle TCS')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport Patrol vehicle TCS' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'Patrol vehicle TCS'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime Patrol vehicle TCS')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime Patrol vehicle TCS' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'Patrol vehicle TCS'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'Transport SBB')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'Transport SBB' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Transport' and v.Name = 'SBB'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

IF NOT EXISTS (Select * FROM CostDistribution WHERE Name = 'WaitingTime SBB')
BEGIN
	INSERT INTO CostDistribution (CostTypeID, Name, VehicleID) SELECT ct.ID, 'WaitingTime SBB' , v.ID from CostType ct, Vehicle v WHERE ct.Name = 'Waiting Time' and v.Name = 'SBB'
	SELECT @costDitributionID = @@IDENTITY
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Heart'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung bilateral'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Lung right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver left lateral graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right extended graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Liver right lobe graft'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney left'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidney right'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Both kidneys'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Kidneys en bloc'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Pancreas for islets'
	INSERT INTO OrganCostDistribution (OrganID, CostDistributionID, Weight) SELECT ID, @costDitributionID, 1 FROM Organ WHERE Name = 'Small bowel'
END

-- insert Delay reasons
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Delay at initiation of removal of organ')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Delay at initiation of removal of organ') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Delay at removal of organ')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Delay at removal of organ') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Delayed departure of team')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Delayed departure of team') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Delay at transfer of combinded transports')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Delay at transfer of combinded transports') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Other (comment)')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Other (comment)') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Transporter')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Transporter') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Weather-/Roadconditions')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Weather-/Roadconditions') 
END
IF NOT EXISTS (Select * FROM DelayReason WHERE Reason = 'Communication (comment)')
BEGIN
INSERT INTO DelayReason (Reason) VALUES ('Communication (comment)') 
END

-- insert Creditors
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Bären Taxi AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Bären Taxi AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA EuroMedTrans')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA EuroMedTrans')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA TCS')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA TCS')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Sprenger AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Sprenger AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Skymedia AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Skymedia AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Bahnhof Taxi')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Bahnhof Taxi')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Lions Air')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Lions Air')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = '360° Transports Urgents')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('360° Transports Urgents')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Intermedic AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Intermedic AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Ville de Lausanne')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Ville de Lausanne')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Sanitätspolizei BE')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Sanitätspolizei BE')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA SK Ambulances SA')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA SK Ambulances SA')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Wieland Bus')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Wieland Bus')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA VGS Medicals')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA VGS Medicals')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Hermes Transporting')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Hermes Transporting')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Sprenger AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Sprenger AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA TRS')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA TRS')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Ernst Hess AG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Ernst Hess AG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA V. Janicijevic')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA V. Janicijevic')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA O''key Taxi ZH')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA O''key Taxi ZH')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Elart AG Taxi')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Elart AG Taxi')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Ambulanz Murten')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Ambulanz Murten')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Kantonsspital Obwalden')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Kantonsspital Obwalden')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Herold Taxi')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Herold Taxi')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Taxi Alpina')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Taxi Alpina')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Taxiphone')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Taxiphone')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'AAA Croce Verde Lugano')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('AAA Croce Verde Lugano')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'HUG')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('HUG')
END
IF NOT EXISTS (SELECT * FROM Creditor WHERE CreditorName = 'REGA')
BEGIN
	INSERT INTO Creditor(CreditorName) VALUES('REGA')
END

-- Insert OrganToTransportItemAssociations for 'Blood for Serology', Donor and Transplant Coordinator
------------------------------------------
IF NOT EXISTS (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Blood for Serology/BG/HLA' AND t.isActive = 1)
BEGIN
	INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Blood for Serology/BG/HLA' AND t.isActive = 1 AND o.isActive = 1)
END
IF NOT EXISTS (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Donor' AND t.isActive = 1)
BEGIN
INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Donor' AND t.isActive = 1 AND o.isActive = 1)
END
IF NOT EXISTS (SELECT t.ID FROM TransportItem t INNER JOIN OrganToTransportItemAssociation ota ON t.ID = ota.TransportItemID WHERE t.Name = 'Transplant Coordinator(s)' AND t.isActive = 1)
BEGIN
INSERT INTO OrganToTransportItemAssociation(OrganID, TransportItemID) (SELECT o.ID, t.ID FROM Organ o, TransportItem t WHERE t.Name = 'Transplant Coordinator(s)' AND t.isActive = 1 AND o.isActive = 1)
END
GO

-- Insert ItemGroup data
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Heart' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Heart', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Lung' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Lung', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Liver' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Liver', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Kidney' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Kidney', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Pancreas' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Pancreas', 1)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Small bowel' AND [Type] = 1)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Small bowel', 1)
END

IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Blood' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Blood', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Biopsy' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Biopsy', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Teams' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Teams', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Transplant Coordinator' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Transplant Coordinator', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Donor' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Donor', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Other' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Other', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Empty' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Empty', 2)
END
IF NOT EXISTS (SELECT * FROM [dbo].[ItemGroup] WHERE Name = 'Lifeport' AND [Type] = 2)
BEGIN
	INSERT INTO [dbo].[ItemGroup](Name, [Type]) VALUES('Lifeport', 2)
END
GO

DECLARE @FontID AS INT
-- insert Data in table Font
IF NOT EXISTS (SELECT * FROM [dbo].[Font] WHERE FontName = 'Helvetica' AND FontSize = 11)
BEGIN
	INSERT INTO [dbo].[Font](FontName, FontSize) VALUES('Helvetica', 11)
	SET @FontID = @@IDENTITY
END
ELSE
BEGIN
	SET @FontID = (SELECT ID FROM [dbo].[Font] WHERE FontName = 'Helvetica' AND FontSize = 11)
END

-- insert Data in table ReminderLetter
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 1)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	1, 
						@FontID, 
						'Bern, ', 
						'Sehr geehrte Damen und Herren',
						'Wir bitten Sie gemäss dem Vertrag zwischen Swisstransplant und ihrem Spital, die Pauschalen der unten aufgeführten Positionen zu verrechnen.',
						'Für Fragen steht Ihnen Frau Corpataux gerne zur Verfügung, Tel. 031 380 81 26.',
						'Freundliche Grüsse',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Total')
END
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 2)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	2, 
						@FontID, 
						'Berne, ',
						'Mesdames, Messieurs,',
						'Selon les contrats que votre hôpital a signé avec Swisstransplant, nous vous prions de bien vouloir nous adresser les facturations des actes exécutés et inscrits dans le tableau ci-dessous selon les forfaits établis.',
						'Si vous avez des questions ou souhaitez recevoir de plus amples informations, veuillez-vous adressez à Madame Corpataux au 031 380 81 26.',
						'Meilleures salutations',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Total')
END
IF NOT EXISTS (SELECT * FROM [dbo].[ReminderLetter] WHERE LanguageID = 3)
BEGIN
	INSERT	INTO	[dbo].[ReminderLetter](LanguageID, FontID, Location, SalutationText, TextBlockA, TextBlockB, GreetingText, SignatureText, HeaderDonorNumber, HeaderCostType, HeaderCosts, FooterTotal)
			VALUES	(	3, 
						@FontID, 
						'Berna, ', 
						'Egregi Signora e Signore,',
						'La preghiamo di ben volere inviarci la fatturazione degli atti eseguiti e indicati nella tabella sottostante, secondo i forfait del contratto firmato tra Swisstransplant e il vostro ospedale.',
						'In caso di domande si rivolga alla Signora Corpataux, Tel. 031 380 81 26.',
						'Cordiali saluti',
						'Swisstransplant',
						'Donor Number',
						'Cost type',
						'Costs',
						'Totale')
END
GO

/* Inciden Tool Data Entries */
--insert IncidentState
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'New')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('New', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'In Process')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('In Process', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentState WHERE [Description] = 'Closed')
BEGIN
	INSERT INTO IncidentState([Description], Value, Position) VALUES('Closed', 3, 3)
END

--insert IncidentProcess
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Procurement')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Procurement', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Transport')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Transport', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Donormanagement')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Donormanagement', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Documentation')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Documentation', 4, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Allocation')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Allocation', 5, 5)
END
IF NOT EXISTS (SELECT * FROM IncidentProcess WHERE [Description] = 'Packing')
BEGIN
	INSERT INTO IncidentProcess([Description], Value, Position) VALUES('Packing', 6, 6)
END

--insert IncidentCategory
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Software')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Software', 1, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Means of Transport')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Means of Transport', 2, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Hardware')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Hardware', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Human error')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Human error', 4, 4)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Equipment')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Equipment', 5, 5)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Communication')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Communication', 6, 6)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'SOAS')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('SOAS', 7, 7)
END
IF NOT EXISTS (SELECT * FROM IncidentCategory WHERE [Description] = 'Other')
BEGIN
	INSERT INTO IncidentCategory([Description], Value, Position) VALUES('Other', 8, 8)
END

--insert IncidentDamageCategory
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Catastrophic')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Catastrophic', 7, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Major')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Major', 5, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Moderate')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Moderate', 3, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentDamageCategory WHERE [Description] = 'Minor')
BEGIN
	INSERT INTO IncidentDamageCategory([Description], Value, Position) VALUES('Minor', 1, 4)
END

--insert IncidentPotentialDamage
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'No')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('No', 4, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'Low')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('Low', 3, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'Moderate')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('Moderate', 2, 3)
END
IF NOT EXISTS (SELECT * FROM IncidentPotentialDamage WHERE [Description] = 'High')
BEGIN
	INSERT INTO IncidentPotentialDamage([Description], Value, Position) VALUES('High', 1, 4)
END

--insert IncidentLikelihoodToRepeat
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Frequent')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Frequent', 4, 1)
END
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Occasional')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Occasional', 3, 2)
END
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Rare')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Rare', 2, 3)
END
GO
IF NOT EXISTS (SELECT * FROM IncidentLikelihoodToRepeat WHERE [Description] = 'Exceptional')
BEGIN
	INSERT INTO IncidentLikelihoodToRepeat([Description], Value, Position) VALUES('Exceptional', 1, 4)
END
GO

/*Incident Lexicon Preentries*/
DECLARE @tblEntries TABLE (
	strDefinition varchar(50)
)

INSERT @tblEntries
SELECT 'Incident No' UNION ALL
SELECT 'ST/RS/FO No' UNION ALL
SELECT 'Date of Event' UNION ALL
SELECT 'Time of Event' UNION ALL
SELECT 'Location' UNION ALL
SELECT 'Incident Description' UNION ALL
SELECT 'Persons Involved' UNION ALL
SELECT 'Impact' UNION ALL
SELECT 'Suggestions / Propositions' UNION ALL
SELECT 'Process' UNION ALL
SELECT 'Category' UNION ALL
SELECT 'Documents' UNION ALL
SELECT 'State of Incident' UNION ALL
SELECT 'Damage Category' UNION ALL
SELECT 'Potential Damage' UNION ALL
SELECT 'Likelihood to Repeat' UNION ALL
SELECT 'Damage Descritpion' UNION ALL
SELECT 'Risk scaling number' UNION ALL
SELECT 'Corrective action' UNION ALL
SELECT 'Preventive action'

INSERT IncidentLexicon (
	Definition,
	IsDeleted
)
SELECT
	strDefinition, 
	0 
FROM 
	@tblEntries
WHERE
	NOT strDefinition IN(SELECT Definition FROM IncidentLexicon)
	
INSERT aspnet_UsersInRoles
(
	UserId,
	RoleId
)
SELECT 
	UserId,
	(
		SELECT RoleId FROM aspnet_Roles WHERE LoweredRoleName = 'swisstransplant'
	)
FROM 
	aspnet_Users 
WHERE 
	LoweredUserName LIKE 'ST-%'
	AND
	NOT UserId IN(
		SELECT 
			UserId
		FROM
			aspnet_UsersInRoles
			INNER JOIN aspnet_Roles
				ON aspnet_Roles.RoleId = aspnet_UsersInRoles.RoleId
		WHERE
			aspnet_Roles.LoweredRoleName = 'swisstransplant'
	)