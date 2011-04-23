class MyPlayerController extends UTPlayerController;

var MyTcpClient ConnClient;
var MyGame TheGame;
var MyOnlineServerBrowser ServerBrowser;

simulated function PostBeginPlay()
{
	super.PostBeginPlay();
	if (MyGame(WorldInfo.Game) != none)
		TheGame = MyGame(WorldInfo.Game);

	ServerBrowser = Spawn(class'MyOnlineServerBrowser');
	ServerBrowser.Initialize();
	
	if (self.IsServer())
	{
		ServerBrowser.AddToServerList(TheGame.ServerPort,
									  TheGame.ServerGameName,
									  TheGame.ServerGameType,
									  TheGame.ServerPassword,
									  TheGame.ServerMaplist,
									  TheGame.ServerRanked,
									  TheGame.ServerCurrentPlayerCount,
									  TheGame.ServerMaxPlayerCount);
	}
}

exec function ServerList(optional string FilterGameType="", optional int FilterPassword=2, 
						 optional int FilterRanked=2, optional int FilterFilled=2)
{
	ServerBrowser.GetServerList(FilterGameType,FilterPassword,FilterRanked,FilterFilled);
}

defaultproperties
{
	Name="Default__MyPlayerController"
}
