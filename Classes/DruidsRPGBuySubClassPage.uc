//Confirm the player really, really wants to sell all his non-class abilities
class DruidsRPGBuySubClassPage extends GUIPage;

var RPGStatsInv StatsInv;
var GiveItemsInv GiveItems;
var class<RPGClass> curClass;
var string thisSubClass;
var int curLevel;
var string sNone;

var GUIListBox SubClasses;

function InitComponent(GUIController MyController, GUIComponent MyOwner)
{
	Super.InitComponent(MyController, MyOwner);
	SubClasses = GUIListBox(Controls[3]);

	OnClose=MyOnClose;
}

function InitFor(class<RPGClass> thisClass)
{
	local int x;
	
	//Fill the subclass listbox
	SubClasses.List.Clear();
	
	if (GiveItems == None || StatsInv == None || thisClass == None)
		return;
		
	curClass = thisClass;		// save for later
	
	thisSubClass = sNone;
	// first lets find if they already have a subclass
	for (x = 0; x < StatsInv.Data.Abilities.length; x++)
		if (ClassIsChildOf(StatsInv.Data.Abilities[x], class'SubClass'))
		{
			//found a subclass. Can't buy another
			return;
		}
	
	// ok now add the subclasses for this class
	for (x = 0; x < GiveItems.SubClassConfigs.length; x++)
	{
		if (GiveItems.SubClassConfigs[x].AvailableClass == thisClass)
		{	// add subclasses 
			SubClasses.List.Add(GiveItems.SubClassConfigs[x].AvailableSubClass @ "(MinLevel:" $ GiveItems.SubClassConfigs[x].MinLevel $ ")",,GiveItems.SubClassConfigs[x].AvailableSubClass);
		}
	}
}

function bool UpdateSubClassButtons(GUIComponent Sender)
{
	local string selectedSubClass;
	local int i;

	selectedSubClass = SubClasses.List.GetExtra();
	for (i = 0; i < GiveItems.SubClassConfigs.length; i++)
	{
		if (GiveItems.SubClassConfigs[i].AvailableClass == curClass && GiveItems.SubClassConfigs[i].AvailableSubClass == selectedSubClass)
		{	// add subclasses 
			if (curLevel < GiveItems.SubClassConfigs[i].MinLevel)
				Controls[1].MenuStateChange(MSAT_Disabled);
			else
				Controls[1].MenuStateChange(MSAT_Blurry);
		}
	}

	return true;
}

function bool BuySubClass(GUIComponent Sender)
{
	local int x, y;
	local string selectedSubClass;
	local GUIController OldController;
	
	Controls[1].MenuStateChange(MSAT_Disabled);
	selectedSubClass = SubClasses.List.GetExtra();
	
	for (x = 0; x < GiveItems.SubClassConfigs.length; x++)
	{
		if (GiveItems.SubClassConfigs[x].AvailableClass == curClass && GiveItems.SubClassConfigs[x].AvailableSubClass == selectedSubClass)
		{	// valid subclasses. So now find index  in main list
			for (y = 0; y < GiveItems.SubClasses.length; y++)
			{
				if (GiveItems.SubClasses[y] == selectedSubClass)
				{
					GiveItems.AbilityConfigs.Length = 0;		// reset the abilities available
					GiveItems.InitializedAbilities = False;
					
					OldController = Controller;
					StatsInv.ServerAddAbility(class'SubClass');
					GiveItems.ServerSetSubClass(StatsInv, y);
					Controller.CloseMenu(false);
					OldController.CloseMenu(false);
					return true;
				}
		 	}
		}
	}

	Controller.CloseMenu(false);
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
	curClass = None;

	Super.OnClose(bCanceled);
}

defaultproperties
{
     sNone = "None"
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
     Controls(0)=GUIButton'DruidsRPGBuySubClassPage.QuitBackground'

     Begin Object Class=GUIButton Name=SubClassBuyButton
         Caption="Buy"
         WinTop=0.850000
         WinLeft=0.350000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuySubClassPage.BuySubClass
         OnKeyEvent=SubClassBuyButton.InternalOnKeyEvent
     End Object
     Controls(1)=GUIButton'DruidsRPGBuySubClassPage.SubClassBuyButton'

     Begin Object Class=GUIButton Name=CloseButton
         Caption="Close"
         WinTop=0.850000
         WinLeft=0.700000
         WinWidth=0.250000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuySubClassPage.CloseClick
         OnKeyEvent=CloseButton.InternalOnKeyEvent
     End Object
     Controls(2)=GUIButton'DruidsRPGBuySubClassPage.CloseButton'

     Begin Object Class=GUIListBox Name=SubClassList
         bVisibleWhenEmpty=True
         OnCreateComponent=SubClassList.InternalOnCreateComponent
         StyleName="AbilityList"
         Hint="These are the subclasses you can purchase."
         WinTop=0.250000
         WinLeft=0.200000
         WinWidth=0.600000
         WinHeight=0.500000
         bBoundToParent=True
         bScaleToParent=True
         OnClick=DruidsRPGBuySubClassPage.UpdateSubClassButtons
     End Object
     Controls(3)=GUIListBox'DruidsRPGBuySubClassPage.SubClassList'

     Begin Object Class=GUILabel Name=SelectText
         Caption="Choose a subclass:"
         TextAlign=TXTA_Center
         TextColor=(B=0,G=180,R=220)
         TextFont="UT2HeaderFont"
         WinTop=0.100000
         WinHeight=0.100000
         bBoundToParent=True
         bScaleToParent=True
     End Object
     Controls(4)=GUILabel'DruidsRPGBuySubClassPage.SelectText'

     WinTop=0.150000
     WinLeft=0.200000
     WinWidth=0.600000
     WinHeight=0.700000
}
