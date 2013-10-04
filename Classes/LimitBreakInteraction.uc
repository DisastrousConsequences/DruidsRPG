class LimitBreakInteraction extends Interaction;

var LimitBreakInv lbInv;
var Font TextFont;
var color LimitBarColor, WhiteColor, RedTeamTint, BlueTeamTint;
var localized string LimitText;
var int dummyi;

event Initialized()
{
	TextFont = Font(DynamicLoadObject("UT2003Fonts.jFontSmall", class'Font'));
	super.Initialized();
}

//Find local player's stats inventory item
function FindlbInv()
{
	local Inventory Inv;
	local LimitBreakInv FoundlbInv;

	for (Inv = ViewportOwner.Actor.Inventory; Inv != None; Inv = Inv.Inventory)
	{
		FoundlbInv = LimitBreakInv(Inv);
		if (FoundlbInv != None)
		{
			if (FoundlbInv.Owner == ViewportOwner.Actor || FoundlbInv.Owner == ViewportOwner.Actor.Pawn)
				lbInv = FoundlbInv;
			return;
		}
		else
		{
			//atrocious hack for Jailbreak's bad code in JBTag (sets its Inventory property to itself)
			if (Inv.Inventory == Inv)
			{
				Inv.Inventory = None;
				foreach ViewportOwner.Actor.DynamicActors(class'LimitBreakInv', FoundlbInv)
				{
					if (FoundlbInv.Owner == ViewportOwner.Actor || FoundlbInv.Owner == ViewportOwner.Actor.Pawn)
					{
						lbInv = FoundlbInv;
						Inv.Inventory = lbInv;
						break;
					}
				}
				return;
			}
		}
	}
}

function PostRender(Canvas Canvas)
{
	local float XL, YL, XLSmall, YLSmall, LimitBarX, LimitBarY;
	local string pText;

	if ( ViewportOwner == None || ViewportOwner.Actor == None || ViewportOwner.Actor.Pawn == None || ViewportOwner.Actor.Pawn.Health <= 0
	     || (ViewportOwner.Actor.myHud != None && ViewportOwner.Actor.myHud.bShowScoreBoard)
	     || ViewportOwner.Actor.myHud.bHideHUD )
		return;

	if(ViewportOwner.Actor != ViewportOwner.Actor.Level.GetLocalPlayerController())
		return; //this is a spectating player.

	if (lbInv == None)
		FindlbInv();
	if (lbInv == None)
		return;

	if (TextFont != None)
		Canvas.Font = TextFont;
	Canvas.FontScaleX = Canvas.ClipX / 1024.f;
	Canvas.FontScaleY = Canvas.ClipY / 768.f;

	Canvas.FontScaleX *= 0.75; //make it smaller
	Canvas.FontScaleY *= 0.75;

	Canvas.TextSize(LimitText, XL, YL);

	// increase size of the display if necessary for really high levels
	XL = FMax(XL + 9.f * Canvas.FontScaleX, 135.f * Canvas.FontScaleX);

	Canvas.Style = 5;
	Canvas.DrawColor = LimitBarColor;

	LimitBarX = Canvas.ClipX - XL - 1.f;
	LimitBarY = Canvas.ClipY * 0.75 - YL * 2.5; //used to be 1.75. 

	Canvas.SetPos(LimitBarX, LimitBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL * lbInv.LimitPoints / lbInv.LimitPointsForLimitBreak, 15.0 * Canvas.FontScaleY * 1.25, 836, 454, -386 * lbInv.LimitPoints / lbInv.LimitPointsForLimitBreak, 36);

	if ( ViewportOwner.Actor.PlayerReplicationInfo == None || ViewportOwner.Actor.PlayerReplicationInfo.Team == None
	     || ViewportOwner.Actor.PlayerReplicationInfo.Team.TeamIndex != 0 )
		Canvas.DrawColor = BlueTeamTint;
	else
		Canvas.DrawColor = RedTeamTint;
	Canvas.SetPos(LimitBarX, LimitBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 15.0 * Canvas.FontScaleY * 1.25, 836, 454, -386, 36);
	Canvas.DrawColor = WhiteColor;
	Canvas.SetPos(LimitBarX, LimitBarY);
	Canvas.DrawTile(Material'InterfaceContent.Hud.SkinA', XL, 16.0 * Canvas.FontScaleY * 1.25, 836, 415, -386, 38);

	Canvas.Style = 2;
	Canvas.DrawColor = WhiteColor;

	Canvas.SetPos(LimitBarX + 9.f * Canvas.FontScaleX, Canvas.ClipY * 0.75 - YL * 3.7); //used to be 3
	Canvas.DrawText(LimitText);

	pText = lbInv.LimitPoints$"/"$lbInv.LimitPointsForLimitBreak;
	Canvas.TextSize(pText, XLSmall, YLSmall);
	Canvas.SetPos(Canvas.ClipX - XL * 0.5 - XLSmall * 0.5, Canvas.ClipY * 0.75 - YL * 2.5 + 12.5 * Canvas.FontScaleY - YLSmall * 0.5); //used to be 3.75
	Canvas.DrawText(pText);

	Canvas.FontScaleX = Canvas.default.FontScaleX;
	Canvas.FontScaleY = Canvas.default.FontScaleY;
	super.PostRender(Canvas);
}

defaultproperties
{
     LimitBarColor=(B=0,G=215,R=255,A=255)
     WhiteColor=(B=255,G=255,R=255,A=255)
     RedTeamTint=(R=100,A=100)
     BlueTeamTint=(B=102,G=66,R=37,A=150)
     LimitText="Limit Points:"
     //AdrenalineText="Adrenaline:"
     //PointsText="Points:"
     bVisible=True
}