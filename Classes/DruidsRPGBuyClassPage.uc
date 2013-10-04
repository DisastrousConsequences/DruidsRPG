//Confirm the player really, really wants to sell all his non-class abilities
class DruidsRPGBuyClassPage extends GUIPage;

var GiveItemsInv GiveItems;
var RPGStatsInv StatsInv;

var GUIListBox Classes;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	Classes = GUIListBox(Controls[3]);

	OnClose=MyOnClose;
}

function InitFor()
{
	local int x, Cost;
	local RPGPlayerDataObject TempDataObject;
	
	Controls[1].MenuStateChange(MSAT_Disabled);

	//Fill the subclass listbox
	Classes.List.Clear();
	
	if (GiveItems == None || StatsInv == None)
		return;
		
	// first lets find if they already have a class. just a check.
	for (x = 0; x < StatsInv.Data.Abilities.length; x++)
		if (ClassIsChildOf(StatsInv.Data.Abilities[x], class'RPGClass'))
		{
			//found a subclass. Can't buy another
			return;
		}
	
	// on a client, the data object doesn't exist, so make a temporary one for calling the abilities' functions
	if (StatsInv.Role < ROLE_Authority)
	{
		TempDataObject = RPGPlayerDataObject(StatsInv.Level.ObjectPool.AllocateObject(class'RPGPlayerDataObject'));
		TempDataObject.InitFromDataStruct(StatsInv.Data);
	}
	else
	{
		TempDataObject = StatsInv.DataObject;
	}

	// ok now add the classes 
	for (x = 0; x < StatsInv.AllAbilities.length; x++)
	{
		if (ClassIsChildOf(StatsInv.AllAbilities[x], class'RPGClass'))
		{	
			Cost = StatsInv.AllAbilities[x].static.Cost(TempDataObject, 0);

			if (Cost <= 0)
				Classes.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$class'DruidsRPGStatsMenu'.default.CantBuyText$")", StatsInv.AllAbilities[x], string(Cost));
			else
				Classes.List.Add(StatsInv.AllAbilities[x].default.AbilityName@"("$class'DruidsRPGStatsMenu'.default.CostText@Cost$")", StatsInv.AllAbilities[x], string(Cost));
		}
	}
	// free the temporary data object on clients
	if (StatsInv.Role < ROLE_Authority)
	{
		StatsInv.Level.ObjectPool.FreeObject(TempDataObject);
	}
}

function bool UpdateClassButtons(GUIComponent Sender)
{
	local int Cost;

	Cost = int(Classes.List.GetExtra());
	if (Cost <= 0 || Cost > StatsInv.Data.PointsAvailable)
		Controls[1].MenuStateChange(MSAT_Disabled);
	else
		Controls[1].MenuStateChange(MSAT_Blurry);

	return true;
}

function bool BuyClass(GUIComponent Sender)
{
	local GUIController OldController;

	Controls[1].MenuStateChange(MSAT_Disabled);
	
	OldController = Controller;	
	GiveItems.AbilityConfigs.Length = 0;		// reset the abilities available
	GiveItems.InitializedAbilities = False;

	StatsInv.ServerAddAbility(class<RPGAbility>(Classes.List.GetObject()));
	Controller.CloseMenu(false);
	OldController.CloseMenu(false);
	
	return true;
}

function bool CloseClick(GUIComponent Sender)
{
	Controller.CloseMenu(false);

	return true;
}


function MyOnClose(optional bool bCanceled)
{
	StatsInv = None;
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
     Controls(0)=GUIButton'DruidsRPGBuyClassPage.QuitBackground'

     Begin Object Class=GUIButton Name=ClassBuyButton
         Caption="Buy"
         WinTop=0.850000
         WinLeft=0.350000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuyClassPage.BuyClass
         OnKeyEvent=ClassBuyButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'DruidsRPGBuyClassPage.ClassBuyButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.850000
         WinLeft=0.700000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuyClassPage.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'DruidsRPGBuyClassPage.CloseButton'

     Begin Object Class=GUIListBox Name=ClassList
         bVisibleWhenEmpty=True
         OnCreateComponent=ClassList.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="These are the classes you can purchase."
         WinTop=0.250000
         WinLeft=0.200000
         WinWidth=0.600000
         WinHeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuyClassPage.UpdateClassButtons
     End Object
     Controls(3)=GUIListBox'DruidsRPGBuyClassPage.ClassList'

     Begin Object Class=GUILabel Name=SelectText
         Caption="Choose a class:"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.100000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=GUILabel'DruidsRPGBuyClassPage.SelectText'

     WinTop=0.150000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.700000
}
