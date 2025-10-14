function init(port, clientId)
%This function uses relative path when current directory is %userprofile%\Dropbox\Matlab\IB4m
%	Default clientId is previous port number of the same session; if that does not exist, default is 2. (Differentiating different Matlab instances programmatically does not make sense. It is time consuming to check number of existing Matlab instances.)
%	Currently using init() to reconnect as well.

if ~exist('port','var')
	port=7497;
end
global ClientID
if exist('clientId','var')
	ClientID=clientId;	% conform to existing clientId
elseif isempty(ClientID)
	ClientID=2;	% default for first time use of init()
end

Ver=version('-release');
if str2double(Ver(1:4))<2018 || strcmpi(Ver,'2018a')
	if ~any(cell2mat(strfind(javaclasspath('-all'),'TWS973.jar')))	% specify dimension in case two 'TWS973.jar' is defined
		javaaddpath(fullfile(pwd,'Jar','TWS973.jar'));
	end
else
	if ~any(cell2mat(strfind(javaclasspath('-all'),'TWS973.jar')),'all')
		javaaddpath(fullfile(pwd,'Jar','TWS973.jar'));
	end
end

global session session_port
if isempty(session)
    session = TWS.Session.getInstance();
elseif isConnected(session.eClientSocket)
	session.eClientSocket.eDisconnect;
end
session.eClientSocket.eConnect('127.0.0.1',port,ClientID);
session_port = port;	% temporary work around. The port number of an established connection should be stored in session and controlled by .eClientSocket.eConnect and .eDisconnect

if session.eClientSocket.isConnected
	com.mathworks.mlservices.MatlabDesktopServices.getDesktop.getMainFrame.setTitle(['Matlab R',Ver,' - IB Gateway port ',num2str(port),' clientId ',num2str(ClientID),' - PID ',num2str(feature('getpid'))])
end

end

