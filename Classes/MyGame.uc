class MyGame extends UTTeamGame;

var string ServerGameName;
var string ServerPassword;
var string ServerMaplist;
var int ServerGameType;
var int ServerRanked;
var int ServerCurrentPlayerCount;
var int ServerMaxPlayerCount;
var int ServerPort;

event PostLogin ( playerController NewPlayer )
{
	super.PostLogin(NewPlayer);
	ServerPort = GetServerPort();
	ServerCurrentPlayerCount = GetNumPlayers();
}

defaultproperties
{
	ServerGameName = "Testserver"
	ServerGameType = 1
	ServerPassword = ""
	ServerMaplist = "TestMap"
	ServerMaxPlayerCount = 32
	ServerRanked = 0

	PlayerControllerClass=class'MyGame.MyPlayerController'

	Name="Default__MyGame"
}
