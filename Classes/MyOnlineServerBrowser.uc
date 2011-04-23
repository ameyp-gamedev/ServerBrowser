class MyOnlineServerBrowser extends Actor;

var MyTcpClient ConnClient;
var string response;

function Initialize()
{
	ConnClient = Spawn(class'MyTcpClient');
	ConnClient.Initialize("myapp.appspot.com",80);
}

/*
 * Returns a list of running servers based on filters
 * ServerGameType: 0 - All, 1 - Capture the Keep
 * ServerPassword: 0 - No password, 1 - Has password, 2 - Both
 * ServerRanked: 0 - Not ranked, 1 - Ranked, 2 - Both
 * ServerFilled: 0 - Not filled, 1 - Full, 2 - Both
 * 
 * ServerList stored inside global string response
 */

function GetServerList(string FilterGameType, int FilterPassword, 
							  int FilterRanked, int FilterFilled)
{
	`log("franked="$FilterRanked);
	ConnClient.TransmitData(
							"GameType="$FilterGameType$"&"
							$"bProtected="$FilterPassword$"&"
							$"bRanked="$FilterRanked$"&"
							$"bFilled="$FilterFilled$"&"
							$"bInGame=True",
							false
							);
}

/*
 * Adds current server to serverlist if not already present
 * Otherwise updates its status
 */
function AddToServerList(int ServerPort, string ServerGameName, int ServerGameType, string ServerPassword, 
						 string ServerMaplist, int ServerRanked, int ServerCurrentPlayerCount,
						 int ServerMaxPlayerCount)
{
	ConnClient.TransmitData(
							"Port="$ServerPort$"&"
							$"Name="$ServerGameName$"&"
							$"Password="$ServerPassword$"&"
							$"GameType="$ServerGameType$"&"
							$"Maplist="$ServerMapList$"&"
							$"Port="$ServerPort$"&"
							$"CurrentPlayers="$ServerCurrentPlayerCount$"&"
							$"MaxPlayers="$ServerMaxPlayerCount$"&"
							$"bRanked="$ServerRanked$"&"
							$"bInGame=True",
							true
							);
}

DefaultProperties
{
	response = "";
}
