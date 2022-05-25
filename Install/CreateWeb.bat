
cd "%~dp0"

mkdir "D:\SLIDS\log\IIS\FailedRequests"


mkdir "D:\Inetpub\SLIDS"
pause

%windir%\system32\inetsrv\AppCmd add apppool /name:"SLIDSPool" /managedRuntimeVersion:v4.0

%windir%\system32\inetsrv\AppCmd add site /name:"SLIDSWeb" /logFile.directory:"D:\SLIDS\log\IIS" /traceFailedRequestsLogging.directory:"D:\SLIDS\log\IIS\FailedRequests" /applicationDefaults.applicationPool:"SLIDSPool" /applicationDefaults.enabledProtocols:"http" /physicalPath:"D:\Inetpub\SLIDS" /bindings:http/*:8010: 

pause

netsh advfirewall firewall add rule name="SLIDS" dir=in action=allow protocol=TCP localport=8010

pause