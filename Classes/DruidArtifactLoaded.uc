class DruidArtifactLoaded extends RPGDeathAbility
	config(UT2004RPG) 
	abstract;

var config Array< class<RPGArtifact> > Level1Artifact;
var config Array< class<RPGArtifact> > Level2Artifact;
var config Array< class<RPGArtifact> > Level3Artifact;
var config Array< class<RPGArtifact> > Level4Artifact;
var config Array< class<RPGArtifact> > Level5Artifact;

var config float WeaponDamage;
var config float AdrenalineDamage;
var config float AdrenalineUsage;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local int x;
	local LoadedInv LoadedInv;
	local bool Enhance;
	local RPGStatsInv StatsInv;

	LoadedInv = LoadedInv(Other.FindInventoryType(class'LoadedInv'));

	if(LoadedInv != None)
	{
		if(LoadedInv.bGotLoadedArtifacts && LoadedInv.LAAbilityLevel == AbilityLevel)
			return;
	}
	else
	{
		LoadedInv = Other.spawn(class'LoadedInv');
		LoadedInv.giveTo(Other);
	}

	if(LoadedInv == None)
		return;

	LoadedInv.bGotLoadedArtifacts = true;
	LoadedInv.LAAbilityLevel = AbilityLevel;

	if(AbilityLevel >= 2)
		LoadedInv.ProtectArtifacts = true;
	else
		LoadedInv.ProtectArtifacts = false;
		
	if(AbilityLevel > 4)
		Enhance = true;
	else
		Enhance = false;

	for(x = 0; x < default.Level1Artifact.length; x++)
		if (default.Level1Artifact[x] != None)
			giveArtifact(other, default.Level1Artifact[x], Enhance);

	if(AbilityLevel > 1)
		for(x = 0; x < default.Level2Artifact.length; x++)
			if (default.Level2Artifact[x] != None)
				giveArtifact(other, default.Level2Artifact[x], Enhance);

	if(AbilityLevel > 2)
		for(x = 0; x < default.Level3Artifact.length; x++)
			if (default.Level3Artifact[x] != None)
				giveArtifact(other, default.Level3Artifact[x], Enhance);

	if(AbilityLevel > 3)
		for(x = 0; x < default.Level4Artifact.length; x++)
			if (default.Level4Artifact[x] != None)
				giveArtifact(other, default.Level4Artifact[x], Enhance);

	if(AbilityLevel > 4)
	{
		for(x = 0; x < default.Level5Artifact.length; x++)
			if (default.Level5Artifact[x] != None)
				giveArtifact(other, default.Level5Artifact[x], Enhance);
		Other.Controller.Adrenaline = Other.Controller.AdrenalineMax;	// extreme starts maxed
	}
		
	if(AbilityLevel >= 2)
	{
		// now check if we get the other hybrid artifacts
		StatsInv = RPGStatsInv(Other.FindInventoryType(class'RPGStatsInv'));

		for (x = 0; StatsInv != None && x < StatsInv.Data.Abilities.length; x++)
		{
			if (StatsInv.Data.Abilities[x] == class'AbilityShieldHealing')
			{
			    // give them the shieldblast
			    giveArtifact(other, class'ArtifactShieldBlast', Enhance);
			}
			if (StatsInv.Data.Abilities[x] == class'AbilityLoadedHealing' && StatsInv.Data.AbilityLevels[x] >= 2)
			{
			    // give them the healingblast
			    giveArtifact(other, class'ArtifactHealingBlast', Enhance);
			}
		}
	}

// I'm guessing that NextItem is here to ensure players don't start with
// no item selected.  So the if should stop wierd artifact scrambles.
	if(Other.SelectedItem == None)
		Other.NextItem();
}

static function giveArtifact(Pawn other, class<RPGArtifact> ArtifactClass, bool Enhance)
{
	local RPGArtifact Artifact;

	if(Other.IsA('Monster'))
		return;
	if(Other.findInventoryType(ArtifactClass) != None)
		return; //they already have one
		
	Artifact = Other.spawn(ArtifactClass, Other,,, rot(0,0,0));
	if(Artifact != None)
	{
		if (Enhance && EnhancedRPGArtifact(Artifact) != None)
			EnhancedRPGArtifact(Artifact).EnhanceArtifact(default.AdrenalineUsage);
		Artifact.giveTo(Other);
	}
}

static function GenuineDeath(Pawn Killed, Controller Killer, class<DamageType> DamageType, vector HitLocation, int AbilityLevel)
{
	Local Inventory inv;

// If we end up with some wierdness here, it would be because we haven't
// ejected the player.  However, we shouldn't have to worry about that
// any more; it should be handled elsewhere, if needed.
	if(Killed.isA('Vehicle'))
	{
		Killed = Vehicle(Killed).Driver;
	}
// Wierdness - looks like sometimes PD called twice, particularly in VINV?
// Killed can become "None" somewhere along the line.
	if(Killed == None)
	{
		return;
	}

	for (inv=Killed.Inventory ; inv != None ; inv=inv.Inventory)
	{
		if(ClassIsChildOf(inv.class, class'UT2004RPG.RPGArtifact'))
		{
// Important note: *NO* artifact currently in possession will get dropped!
			inv.PickupClass = None;
		}
	}

	return;
}

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if(!bOwnedByInstigator)
		return;
	if(Damage > 0 && AbilityLevel > 4)
	{
		if (ClassIsChildOf(DamageType, class'WeaponDamageType') || ClassIsChildOf(DamageType, class'VehicleDamageType'))
			Damage *= default.WeaponDamage;
		else
			Damage *= default.AdrenalineDamage;
	}
}

static function bool OverridePickupQuery(Pawn Other, Pickup item, out byte bAllowPickup, int AbilityLevel)
{
	if (ClassIsChildOf(item.InventoryType, class'EnhancedRPGArtifact'))
	{
		if(Other.findInventoryType(item.InventoryType) != None)
		{
			bAllowPickup = 0;	// not allowed
			return true; 		//they already have one, and ours is probably enhanced already
		}
	}
	return false;		// don't know, so let someone else decide
}


DefaultProperties
{
	AbilityName="Loaded Artifacts"
	Description="When you spawn:|Level 1: You are granted all slow drain artifacts, a magic weapon maker and the invulnerability globe.|Level 2: You are granted the triple, max, fireball and remote artifacts, and breakable artifacts are made unbreakable.|Level 3: You get the rod, blasts and some other artifacts.|Level 4: You get bolt, beam, chain and the spheres.|Extreme level 5 reduces adrenaline used in offensive attacks, but reduces damage from weapons|Cost (per level): 6,8,10,12,14"
	
	StartingCost=6
	CostAddPerLevel=2
	MaxLevel=5
	
	WeaponDamage=0.5
	AdrenalineDamage=1.66
	AdrenalineUsage=0.6

	Level1Artifact[0]=class'DruidArtifactFlight'
	Level1Artifact[1]=class'DruidArtifactTeleport'
	Level1Artifact[2]=class'DruidArtifactSpider'
	Level1Artifact[3]=class'DruidArtifactMakeMagicWeapon'
	Level1Artifact[4]=class'UT2004RPG.ArtifactInvulnerability'
	Level1Artifact[5]=class'ArtifactPlusAddon'

	Level2Artifact[0]=class'DruidArtifactTripleDamage'
	Level2Artifact[1]=class'DruidMaxModifier'
	Level2Artifact[2]=Class'ArtifactFireBall'
	Level2Artifact[3]=Class'ArtifactRemoteDamage'
	Level2Artifact[4]=Class'ArtifactRemoteInvulnerability'
	Level2Artifact[5]=Class'ArtifactRemoteMax'

	Level3Artifact[0]=class'DruidArtifactLightningRod'
	Level3Artifact[1]=class'DruidDoubleModifier'
	Level3Artifact[2]=class'DruidPlusOneModifier'
	Level3Artifact[3]=Class'ArtifactMegaBlast'
	Level3Artifact[4]=Class'ArtifactPoisonBlast'

	Level4Artifact[0]=Class'ArtifactLightningBolt'
	Level4Artifact[1]=Class'ArtifactLightningBeam'
	Level4Artifact[2]=Class'ArtifactChainLightning'
	Level4Artifact[3]=Class'ArtifactRepulsion'
	Level4Artifact[4]=Class'ArtifactSphereInvulnerability'
	Level4Artifact[5]=Class'ArtifactSphereDamage'
}
