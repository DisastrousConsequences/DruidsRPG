class RPGScoreBoardInvasion extends ScoreBoardInvasion;

var ClientHudInv myClient;
var color AMOrangeColor, WMPurpleColor, MMBlueColor, GenGreenColor;
var int iClientCheckCount;

// client side copy
struct CopyXPValue
{
	Var String PlayerName;
	var int PlayerClass;       // 0 none, 1 WM, 2 AM, 3 MM, 4 Eng, 5 Gen
	var int XPGained;
	var string SubClass;
};
var Array<CopyXPValue> CopyXPs;

simulated function DrawSubClass (Canvas Canvas, string text, float x, float y)
{
	local Font saveFont;
	local float xw, yw;

	saveFont = Canvas.Font;
	Canvas.DrawColor = HUDClass.default.BlackColor;
	Canvas.Font = Canvas.TinyFont;
	Canvas.TextSize( text, xw, yw ); 
	Canvas.SetPos(x - (xw/2), y);
	Canvas.DrawText(text,true);
	Canvas.Font = saveFont;
}

simulated function DrawXP (Canvas Canvas, int PlayerIndex, int PTypeXPos, int XPXPos, int YPos, int YPlayerBox, int YL)
{
	local int j;
	local int XPValue;
	local int NewYPos;
    
	// YL is height of letters. Use this for scaling size of images.
	// YPos is the position to start drawing at, and is the top of the playerbox, which has height YPlayerBox.
    
	XPValue = -1;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	NewYPos = YPos;
	// first find player in CopyXPs list
	for (j=0; j<CopyXPs.length; j++)
		if (CopyXPs[j].PlayerName == PRIArray[PlayerIndex].PlayerName)
		{
			XPValue = CopyXPs[j].XPGained;
			Canvas.SetPos(PTypeXPos, NewYPos );
			if (CopyXPs[j].PlayerClass == 1)
			{	//WM
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL,YL,8,178,64,64);
				if (CopyXps[j].SubClass != "" && CopyXps[j].SubClass != "None")
					DrawSubClass (Canvas, CopyXps[j].SubClass, PTypeXPos + (YL/2), NewYPos);
				Canvas.DrawColor = WMPurpleColor;
			}
			else if (CopyXPs[j].PlayerClass == 2)
			{	//AM
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL,YL,106,44,62,62);
				if (CopyXps[j].SubClass != "" && CopyXps[j].SubClass != "None")
					DrawSubClass (Canvas, CopyXps[j].SubClass, PTypeXPos + (YL/2), NewYPos);
				Canvas.DrawColor = AMOrangeColor;
			}
			else if (CopyXPs[j].PlayerClass == 3)
			{	//MM
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL,YL,76,166,50,50);
				if (CopyXps[j].SubClass != "" && CopyXps[j].SubClass != "None")
					DrawSubClass (Canvas, CopyXps[j].SubClass, PTypeXPos + (YL/2), NewYPos);
				Canvas.DrawColor = MMBlueColor;
			}
			else if (CopyXPs[j].PlayerClass == 4)
			{	//Eng
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL,YL,8,246,64,64);
				if (CopyXps[j].SubClass != "" && CopyXps[j].SubClass != "None")
					DrawSubClass (Canvas, CopyXps[j].SubClass, PTypeXPos + (YL/2), NewYPos);
				Canvas.DrawColor = HUDClass.default.GoldColor;
			}
			else if (CopyXPs[j].PlayerClass == 5)
			{	//General
				Canvas.SetPos(PTypeXPos, NewYPos );
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL/2,YL/2,8,178,64,64);
				Canvas.SetPos(PTypeXPos+(YL/2), NewYPos );
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL/2,YL/2,106,44,62,62);
				Canvas.SetPos(PTypeXPos, NewYPos+(YL/2) );
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL/2,YL/2,76,166,50,50);
				Canvas.SetPos(PTypeXPos+(YL/2), NewYPos+(YL/2) );
				Canvas.DrawTile(Material'HUDContent.Generic.HUD',YL/2,YL/2,8,246,64,64);
				if (CopyXps[j].SubClass != "" && CopyXps[j].SubClass != "None")
					DrawSubClass (Canvas, CopyXps[j].SubClass, PTypeXPos + (YL/2), NewYPos);
				Canvas.DrawColor = GenGreenColor;
			}
	    }
	// now draw the XP value in the set color
	if (XPValue >= 0)
	{
	    Canvas.SetPos(XPXPos, YPos);
	    Canvas.DrawText(XPValue,true);
	}
}

simulated event UpdateScoreBoard(Canvas Canvas)
{
	local PlayerReplicationInfo PRI, OwnerPRI;
	local int i, j, FontReduction, OwnerPos, NetXPos, PlayerCount,HeaderOffsetY,HeadFoot, MessageFoot, PlayerBoxSizeY, BoxSpaceY, NameXPos, BoxTextOffsetY, OwnerOffset, ScoreXPos, DeathsXPos, BoxXPos, TitleYPos, BoxWidth, XPXPos, PTypeXPos;
	local float XL,YL, MaxScaling;
	local float deathsXL, scoreXL, netXL, MaxNamePos, XPXL;
	local string playername[MAXPLAYERS];
	local bool bNameFontReduction;
	local string XPText;
	Local ClientHudInv TempCInv;
	
	XPText = "XP";
	
	 // find the ClientHudInv if we havent already got
	 if (myClient == None )
	 {
	 	iClientCheckCount++;
	 	if (iClientCheckCount > 20)		//just to stop check putting too much load on if problems
	 	{
	 		iClientCheckCount = 0;
			if (Owner != None)
			{
				ForEach DynamicActors(class'ClientHudInv',TempCInv)
				{
					if (TempCInv.XPsUpdated)		// only on my ClientHudInv
					{
						myClient = TempCInv;
					}
				}
	 		}
		}
	 }
	 if (myClient != None && myClient.XPsUpdated)
	 {
		// only gets updated once every 15 secs, so do not want to copy every loop
		CopyXPs.length = myClient.CurrentXPs.length;
		for (j=0; j<myClient.CurrentXPs.length; j++)
		{
			CopyXPs[j].PlayerName = myClient.CurrentXPs[j].PlayerName;
			CopyXPs[j].PlayerClass = myClient.CurrentXPs[j].PlayerClass;
			CopyXPs[j].XPGained = myClient.CurrentXPs[j].XPGained;
			CopyXPs[j].SubClass = myClient.CurrentXPs[j].SubClass;
		}
		myClient.XPsUpdated = false;
	 }
	OwnerPRI = PlayerController(Owner).PlayerReplicationInfo;
	PlayerCount = 0;
	for (i=0; i<GRI.PRIArray.Length; i++)
	{
		PRI = GRI.PRIArray[i];
		if ( !PRI.bOnlySpectator && (!PRI.bIsSpectator || PRI.bWaitingPlayer) )
		{
			PRIArray[PlayerCount] = GRI.PRIArray[i];      // just copy valid records into PRIArray
			if ( PRI == OwnerPRI )
				OwnerOffset = PlayerCount;
			PlayerCount++;
		}
	}
	PlayerCount = Min(PlayerCount,MAXPLAYERS);

	// Select best font size and box size to fit as many players as possible on screen
	Canvas.Font = HUDClass.static.GetMediumFontFor(Canvas);
	Canvas.StrLen("Test", XL, YL);
	BoxSpaceY = 0.25 * YL;
	PlayerBoxSizeY = 1.5 * YL;
	HeadFoot = 7*YL;
	MessageFoot = 1.5 * HeadFoot;
	if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
	{
		BoxSpaceY = 0.125 * YL;
		PlayerBoxSizeY = 1.25 * YL;
		if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
		{
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
				PlayerBoxSizeY = 1.125 * YL;
			if ( PlayerCount > (Canvas.ClipY - 1.5 * HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
			{
				FontReduction++;
				Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
				Canvas.StrLen("Test", XL, YL);
				BoxSpaceY = 0.125 * YL;
				PlayerBoxSizeY = 1.125 * YL;
				HeadFoot = 7*YL;
				if ( PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) )
				{
					FontReduction++;
					Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
					Canvas.StrLen("Test", XL, YL);
					BoxSpaceY = 0.125 * YL;
					PlayerBoxSizeY = 1.125 * YL;
					HeadFoot = 7*YL;
					if ( (Canvas.ClipY >= 768) && (PlayerCount > (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY)) )
					{
						FontReduction++;
						Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
						Canvas.StrLen("Test", XL, YL);
						BoxSpaceY = 0.125 * YL;
						PlayerBoxSizeY = 1.125 * YL;
						HeadFoot = 7*YL;
					}
				}
			}
		}
	}
	if ( Canvas.ClipX < 512 )
		PlayerCount = Min(PlayerCount, 1+(Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
	else
		PlayerCount = Min(PlayerCount, (Canvas.ClipY - HeadFoot)/(PlayerBoxSizeY + BoxSpaceY) );
	if ( OwnerOffset >= PlayerCount )
		PlayerCount -= 1;

	if ( FontReduction > 2 )
		MaxScaling = 3;
	else
		MaxScaling = 2.125;
	PlayerBoxSizeY = FClamp((1+(Canvas.ClipY - 0.67 * MessageFoot))/PlayerCount - BoxSpaceY, PlayerBoxSizeY, MaxScaling * YL);

	bDisplayMessages = (PlayerCount <= (Canvas.ClipY - MessageFoot)/(PlayerBoxSizeY + BoxSpaceY));
	HeaderOffsetY = 5 * YL;
	BoxWidth = 0.9375 * Canvas.ClipX;
	BoxXPos = 0.5 * (Canvas.ClipX - BoxWidth);
	BoxWidth = Canvas.ClipX - 2*BoxXPos;
	NameXPos = BoxXPos + 0.0625 * BoxWidth;
	ScoreXPos = BoxXPos + 0.45 * BoxWidth;
	PTypeXPos = BoxXPos + 0.59 * BoxWidth;
	XPXPos = BoxXPos + 0.63 * BoxWidth;
	DeathsXPos = BoxXPos + 0.7475 * BoxWidth;
	NetXPos = BoxXPos + 0.8125 * BoxWidth;

	// draw background boxes
	Canvas.Style = ERenderStyle.STY_Alpha;
	Canvas.DrawColor = HUDClass.default.WhiteColor * 0.5;
	for ( i=0; i<PlayerCount; i++ )
	{
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*i);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
	}

	// draw team score box
	Canvas.StrLen(TeamScoreString$"    "$int(GRI.Teams[0].Score), ScoreXL, YL);
	Canvas.DrawColor = HUDClass.Default.BlueColor;
	Canvas.SetPos(BoxXPos, HeaderOffsetY - 2.75*YL);
	Canvas.DrawTileStretched( BoxMaterial, ScoreXL+ 0.125 * BoxWidth, 1.25 * YL);

	// draw title
	Canvas.Style = ERenderStyle.STY_Normal;
	DrawTitle(Canvas, HeaderOffsetY, (PlayerCount+1)*(PlayerBoxSizeY + BoxSpaceY), PlayerBoxSizeY);

	// draw team score box
	Canvas.SetPos(NameXPos,HeaderOffsetY - 2.5*YL);
	Canvas.DrawText(TeamScoreString$"    "$int(GRI.Teams[0].Score),true);

	// Draw headers
	TitleYPos = HeaderOffsetY - 1.25*YL;
	Canvas.StrLen(PointsText, ScoreXL, YL);
	Canvas.StrLen(XPText, XPXL, YL);
	Canvas.StrLen(DeathsText, DeathsXL, YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NameXPos, TitleYPos);
	Canvas.DrawText(PlayerText,true);
	Canvas.SetPos(ScoreXPos - 0.5*ScoreXL, TitleYPos);
	Canvas.DrawText(PointsText,true);
	Canvas.SetPos(XPXPos, TitleYPos);
	Canvas.DrawText(XPText,true);
	if ( GRI.MaxLives != 1 )
	{
		Canvas.SetPos(DeathsXPos - 0.5*DeathsXL, TitleYPos);
		Canvas.DrawText(DeathsText,true);
	}

	// draw player names
	MaxNamePos = 0.9 * (ScoreXPos - NameXPos);
	for ( i=0; i<PlayerCount; i++ )
	{
		playername[i] = PRIArray[i].PlayerName;
		Canvas.StrLen(playername[i], XL, YL);
		if ( XL > MaxNamePos )
		{
			bNameFontReduction = true;
			break;
		}
	}
	if ( !bNameFontReduction && (OwnerOffset >= PlayerCount) )
	{
		playername[OwnerOffset] = PRIArray[OwnerOffset].PlayerName;
		Canvas.StrLen(playername[OwnerOffset], XL, YL);
		if ( XL > MaxNamePos )
			bNameFontReduction = true;
	}

	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+1);
	for ( i=0; i<PlayerCount; i++ )
	{
		playername[i] = PRIArray[i].PlayerName;
		Canvas.StrLen(playername[i], XL, YL);
		if ( XL > MaxNamePos )
			playername[i] = left(playername[i], MaxNamePos/XL * len(PlayerName[i]));
	}
	if ( OwnerOffset >= PlayerCount )
	{
		playername[OwnerOffset] = PRIArray[OwnerOffset].PlayerName;
		Canvas.StrLen(playername[OwnerOffset], XL, YL);
		if ( XL > MaxNamePos )
			playername[OwnerOffset] = left(playername[OwnerOffset], MaxNamePos/XL * len(PlayerName[OwnerOffset]));
	}

	Canvas.Style = ERenderStyle.STY_Normal;
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(0.5 * Canvas.ClipX, HeaderOffsetY + 4);
	BoxTextOffsetY = HeaderOffsetY + 0.5 * (PlayerBoxSizeY - YL);

	Canvas.DrawColor = HUDClass.default.WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(NameXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(playername[i],true);
		}
	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);

	// draw scores
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(ScoreXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			Canvas.DrawText(int(PRIArray[i].Score),true);
		}

	// draw xp
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
			DrawXP (Canvas, i, PTypeXPos, XPXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY, PlayerBoxSizeY, YL);

	// draw deaths
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	for ( i=0; i<PlayerCount; i++ )
		if ( i != OwnerOffset )
		{
			Canvas.SetPos(DeathsXPos, (PlayerBoxSizeY + BoxSpaceY)*i + BoxTextOffsetY);
			if ( PRIArray[i].bOutOfLives )
				Canvas.DrawText(OutText,true);
			else if ( GRI.MaxLives != 1 )
				Canvas.DrawText(int(PRIArray[i].Deaths),true);
		}

	// draw owner line
	if ( OwnerOffset >= PlayerCount )
	{
		OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*PlayerCount + BoxTextOffsetY;
		// draw extra box
		Canvas.Style = ERenderStyle.STY_Alpha;
		Canvas.DrawColor = HUDClass.default.TurqColor * 0.5;
		Canvas.SetPos(BoxXPos, HeaderOffsetY + (PlayerBoxSizeY + BoxSpaceY)*PlayerCount);
		Canvas.DrawTileStretched( BoxMaterial, BoxWidth, PlayerBoxSizeY);
		Canvas.Style = ERenderStyle.STY_Normal;
	}
	else
		OwnerPos = (PlayerBoxSizeY + BoxSpaceY)*OwnerOffset + BoxTextOffsetY;

	Canvas.DrawColor = HUDClass.default.GoldColor;
	Canvas.SetPos(NameXPos, OwnerPos);
	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction+1);
	Canvas.DrawText(playername[OwnerOffset],true);
	if ( bNameFontReduction )
		Canvas.Font = GetSmallerFontFor(Canvas,FontReduction);
	Canvas.SetPos(ScoreXPos, OwnerPos);
	Canvas.DrawText(int(PRIArray[OwnerOffset].Score),true);

	DrawXP (Canvas, OwnerOffset, PTypeXPos, XPXPos, OwnerPos, PlayerBoxSizeY, YL);
	Canvas.DrawColor = HUDClass.default.GoldColor;

	Canvas.SetPos(DeathsXPos, OwnerPos);
	if ( PRIArray[OwnerOffset].bOutOfLives )
		Canvas.DrawText(OutText,true);
	else if ( GRI.MaxLives != 1 )
		Canvas.DrawText(int(PRIArray[OwnerOffset].Deaths),true);

	if ( Level.NetMode == NM_Standalone )
		return;

	Canvas.StrLen(NetText, NetXL, YL);
	Canvas.DrawColor = HUDClass.default.WhiteColor;
	Canvas.SetPos(NetXPos + 0.5*NetXL, TitleYPos);
	Canvas.DrawText(NetText,true);

	DrawNetInfo(Canvas,FontReduction,HeaderOffsetY,PlayerBoxSizeY,BoxSpaceY,BoxTextOffsetY,OwnerOffset,PlayerCount,NetXPos);
	DrawMatchID(Canvas,FontReduction);
}

defaultproperties
{
	AMOrangeColor=(R=214,G=49,B=3,A=255)
	WMPurpleColor=(R=109,G=4,B=204,A=255)
	MMBlueColor=(R=104,G=178,B=234,A=255)
	GenGreenColor=(R=18,G=161,B=15,A=255)
	iClientCheckCount=18		// so only 3 frames before checking for ClientHudInv
}
