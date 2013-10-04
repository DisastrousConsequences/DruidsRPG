class AbilityLimitBreak extends CostRPGAbility;

static simulated function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local LimitBreakInv lbInv;
	local Inventory Inv;

	local int x;
	local PlayerController PC;
	local LimitBreakInteraction Interaction;

	if (Other.Role != ROLE_Authority)
		return;

	//add inventory
	Inv = Other.FindInventoryType(class'LimitBreakInv');
	if (Inv != None)
		Inv.Destroy();

	lbInv = Other.spawn(class'LimitBreakInv', Other,,,rot(0,0,0));
	lbInv.AbilityLevel = AbilityLevel;
	lbInv.GiveTo(Other);

	//add interaction
	if (Other.Level.NetMode == NM_DedicatedServer)
		return;

	PC = PlayerController(Other.Controller);
	if (PC == None)
		return;

	for (x = 0; x < PC.Player.LocalInteractions.length; x++)
	{
		if (LimitBreakInteraction(PC.Player.LocalInteractions[x]) != None)
		{
			Interaction = LimitBreakInteraction(PC.Player.LocalInteractions[x]);
			break;
		}
	}
	if (Interaction == None)
		AddInteraction(PC,AbilityLevel);
}

static simulated function AddInteraction(PlayerController PC,int AbilityLevel) //modified from MonsterPointsInv.uc
{
	local Player Player;
	local LimitBreakInteraction Interaction;

	Interaction = new class'LimitBreakInteraction';

	Player = PC.Player;
	if (Interaction != None)
	{
		Player.LocalInteractions.Length = Player.LocalInteractions.Length + 1;
		Player.LocalInteractions[Player.LocalInteractions.Length-1] = Interaction;
		Interaction.ViewportOwner = Player;

		// Initialize the Interaction
		Interaction.Initialize();
		Interaction.Master = Player.InteractionMaster;
	}
	else
		Log("Could not create LimitBreakInteraction");

} // AddInteraction

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local LimitBreakInv lbInv;

	if (Injured != Instigator)
	{
		lbInv = LimitBreakInv(Injured.FindInventoryType(class'LimitBreakInv'));
		if (lbInv != None)
		{
			lbInv.AddBreakPoints(Damage);
		}
	}
	Super.HandleDamage(Damage,Injured,Instigator,Momentum,DamageType,bOwnedByInstigator,AbilityLevel);
}


defaultproperties
{
    AbilityName="Limit Break"
    Description="As you play, you earn limit points when you are damaged by the enemy. You earn less points for damage when you are a higher level and when you have more health. After earning a Limit Break, once you fall to critical health, you will unleash a very powerfull maneuver.|Cost (per level): 7, 14, 21"
    StartingCost=7
    CostAddPerLevel=7
    MaxLevel=3
}