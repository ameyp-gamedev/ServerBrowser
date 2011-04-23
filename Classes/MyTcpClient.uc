class MyTcpClient extends TcpLink;

var string TargetHost;
var int TargetPort;
var MyGame TheGame;
var IpAddr IpAddress;

var string message;
var bool bPost;

// @p0 figure out how to return the received response to the calling object

function Initialize(optional string THost, optional int TPort = TargetPort)
{
	TargetHost = THost;
	TargetPort = TPort;
}

function TransmitData(string data, bool bPostData)
{
	self.message = data;
	self.bPost = bPostData;
	`log("[TcpLinkClient] Resolving: "$TargetHost);
	Resolve(TargetHost);
}

event PostBeginPlay()
{
	super.PostBeginPlay();

}

event Resolved(IpAddr Addr)
{
	`log("[TcpLinkClient] resolved to "$ IpAddrToString(Addr));
	Addr.Port = TargetPort;
	self.IpAddress = Addr;
	`log("[TcpLinkClient] Bound port to "$BindPort(Addr.Port));
	ReceiveMode = EReceiveMode.RMODE_Event;
	LinkMode = ELinkMode.MODE_Text;
	if (!Open(IpAddress))
	{
		`log("[TcpLinkClient] Open failed");
	}
}

event Opened()
{
	`log("[TcpLinkClient] event opened");
	
	if (bPost)
	{
		SendText("POST /addserver HTTP/1.0"$chr(13)$chr(10));
		SendText("Host: "$TargetHost$chr(13)$chr(10));
		SendText("User-Agent: MyTcpLink/1.0"$chr(13)$chr(10));
		SendText("Content-Type: application/x-www-form-urlencoded"$chr(13)$chr(10));
		SendText("Content-Length: "$Len(message)$chr(13)$chr(10));
		SendText(chr(13)$chr(10));
		SendText(self.message$chr(13)$chr(10));
	}
	else
	{
		SendText("GET /getserver?"$message$" HTTP/1.0"$chr(13)$chr(10));
		SendText("Host: "$TargetHost$chr(13)$chr(10));
		SendText(chr(13)$chr(10));
	}
	SendText(chr(13)$chr(10));
	SendText(chr(13)$chr(10));

	`log("[TcpLinkClient] end TCP connection");
	//Close();
}

event ResolveFailed()
{
	`log("[TcpLinkClient] Unable to resolve");
}

event Closed()
{
	`log("[TcpLinkClient] event closed");
}

event ReceivedText(string Text)
{
	local MyOnlineServerBrowser OSB;
	`log("[TcpLinkClient] ReceivedText:: "$Text);
	foreach AllActors(class 'MyOnlineServerBrowser', OSB)
	{
		if (OSB != none)
		{
			OSB.response = Text;
		}
	}
}

DefaultProperties
{
}
