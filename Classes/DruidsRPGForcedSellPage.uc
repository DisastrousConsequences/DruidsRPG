//Confirm the player really, really wants to sell all his non-class abilities
class DruidsRPGForcedSellPage extends GUIPage;

var DruidsRPGStatsMenu StatsMenu;
var GiveItemsInv GiveItems;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);

	OnClose=MyOnClose;
}

function bool InternalOnClick(GUIComponent Sender)
{
	local GUIController OldController;

	if (GiveItems != None)
	{
		OldController = Controller;
		GiveItems.ServerSellData(PlayerOwner().PlayerReplicationInfo,StatsMenu.StatsInv);
		Controller.ViewportOwner.Console.DelayedConsoleCommand("Reconnect");
		Controller.CloseMenu(false);
		OldController.CloseMenu(false);
	}
	else
		Controller.CloseMenu(false);

	return true;
}

function MyOnClose(optional bool bCanceled)
{
	StatsMenu = None;
	GiveItems = None;

	Super.OnClose(bCanceled);
}

defaultproperties
{
     bRenderWorld=True
     bRequire640x480=False
     Begin Object Class=GUIButton Name=QuitBackground
         WinHeight=1.000000
         bBoundToParent=True
         bScaleToParent=True
         bAcceptsInput=False
         bNeverFocus=True
         OnKeyEvent=QuitBackground.InternalOnKeyEvent
     End Object
     Controls(0)=GUIButton'DruidsRPGForcedSellPage.QuitBackground'

     Begin Object Class=GUIButton Name=SellButton
         Caption="Sell SubClass"
         WinTop=0.750000
         WinLeft=0.350000
         WinWidth=0.300000
         bBoundToParent=True
         OnClick=DruidsRPGForcedSellPage.InternalOnClick
         OnKeyEvent=SellButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'DruidsRPGForcedSellPage.SellButton'

     Begin Object Class=GUILabel Name=SellDesc
         Caption="Your current subclass is no longer valid."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.400000
         WinHeight=32.000000
     End Object
     Controls(2)=GUILabel'DruidsRPGForcedSellPage.SellDesc'

     Begin Object Class=GUILabel Name=SellDesc2
         Caption="The subclass will be sold, and you will be automatically reconnected."
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.450000
         WinHeight=32.000000
     End Object
     Controls(3)=GUILabel'DruidsRPGForcedSellPage.SellDesc2'

     WinTop=0.375000
     WinHeight=0.250000
}
