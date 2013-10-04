class ArtifactSphereHealing extends EnhancedRPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;
var config int AdrenalinePerSecond;
var config int HealthPerSecond;
var config float EffectRadius;	// 500, 700, 900 or 1100

var RPGRules Rules;
var vector SpawnLocation;
var Material EffectOverlay;
var float EXPMultiplier;
var int MaxHealth;
var ArtifactMakeSuperHealer AMSH; //set on construction. Used to obtain health and exp bonus numbers.

function BotConsider()
{
	if (bActive && Instigator.Health > 200)
	{
		Activate();		// switch off when not required
		return;
	}
		
	if (Instigator.Controller.Adrenaline < AdrenalineRequired*2)	// to give people time to get there
		return;

	if ( !bActive && Instigator.Health < 125 && NoArtifactsActive() && FRand() < 0.6 )
		Activate();
}

function PreBeginPlay()
{
	local GameRules G;
	Local HealableDamageGameRules SG;
	super.PreBeginPlay();

	if (Level.Game == None)
		return;

	if ( Level.Game.GameRulesModifiers == None )
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if(SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for Sphere of healing. EXP for Healing will not occur.");
		else
			Level.Game.GameRulesModifiers = SG;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('HealableDamageGameRules'))
			{
				SG = HealableDamageGameRules(G);
				break;
			}
			if(G.NextGameRules == None)
			{
				SG = Level.Game.Spawn(class'HealableDamageGameRules');
				if(SG == None)
				{
					log("Warning: Unable to spawn HealableDamageGameRules for Sphere of healing. Healing for EXP will not occur.");
					return; //try again next time?
				}

				//this will also add it after UT2004RPG, which will be necessary.
				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
}

simulated function PostBeginPlay()
{

	CostPerSec = AdrenalinePerSecond*AdrenalineUsage;

	super.PostBeginPlay();

	CheckRPGRules();
}

function EnhanceArtifact(float Adusage)
{
	Super.EnhanceArtifact(AdUsage);
	
	CostPerSec = AdrenalinePerSecond * AdrenalineUsage;
}

function CheckRPGRules()
{
	Local GameRules G;

	if (Level.Game == None)
		return;		//try again later

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			Rules = RPGRules(G);
			break;
		}
	}

	if(Rules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function HealTeam(vector CoreLocation)
{
	Local Controller C;
	Local Pawn P;
	Local int HealthGiven;
	Local int localMaxHealth;
	Local XPawn xP;

	// lets heal ourselves
	HealthGiven =
		Min
		(
			(Instigator.HealthMax + MaxHealth) - Instigator.Health,
			HealthPerSecond/2
		);
	if (HealthGiven > 0)
	{	// room for some health
		Instigator.GiveHealth(HealthGiven, Instigator.HealthMax + MaxHealth);
	}

	// now lets heal everyone else
	C = Level.ControllerList;
	while (C != None)
	{
		// loop round finding all players on same team
		if ( C.Pawn != None && C.Pawn != Instigator && C.Pawn.Health > 0 && C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - CoreLocation) < EffectRadius && HardCoreInv(C.Pawn.FindInventoryType(class'HardCoreInv')) == None )
		{

			P = C.Pawn;

			localMaxHealth = MaxHealth;
			// limit if booster in progress
			xP = xPawn(P);
			if ( xP != None && xP.CurrentCombo != None && xP.CurrentCombo.Name == 'ComboDefensive' )
				localMaxHealth = class'RW_Healer'.default.MaxHealth;	// in booster, lets not mess it up

			if(P != None && P.isA('Vehicle'))
				P = Vehicle(P).Driver;
			if (P != None && ( 
					 (P.Controller != None && P.Controller.IsA('FriendlyMonsterController') && FriendlyMonsterController(P.Controller).Master == Instigator.Controller)
					|| (P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None) ) )
			{
				HealthGiven = HealthPerSecond/2;	// 2 ticks a second
			
				HealthGiven =
					Min
					(
						(P.HealthMax + localMaxHealth) - P.Health,
						HealthGiven
					);
				
				if(HealthGiven > 0)
				{
					P.GiveHealth(HealthGiven, P.HealthMax + localMaxHealth);
					P.SetOverlayMaterial(EffectOverlay, 0.5, false);
					if(Instigator != P)
					{
						if(P.Controller != None && !P.Controller.isA('FriendlyMonsterController'))
							doHealed(HealthGiven, P, localMaxHealth);	// no exp for healing pets
					}
				}

				if(HealthGiven > 0 && P != None && P.Controller != None && PlayerController(P.Controller) != None)	
				{
					PlayerController(P.Controller).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, Instigator.PlayerReplicationInfo);

					P.PlaySound(sound'PickupSounds.HealthPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
				}
			}
		}
		C = C.NextController;
	}
}

//this function does no healing. it serves to figure out the correct amount of exp to grant to the player, and grants it.
function doHealed(int HealthGiven, Pawn Victim, int localMaxHealth)
{
	Local HealableDamageInv Inv;
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;
	
	Inv = HealableDamageInv(Victim.FindInventoryType(class'HealableDamageInv'));
	if(Inv != None)
	{
		ValidHealthGiven = Min(HealthGiven, Inv.Damage);
		if(ValidHealthGiven > 0)
		{
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
			{
				log("Warning: No stats inv found. Healing exp not granted.");
				return;
			}

			GrantExp = EXPMultiplier * float(ValidHealthGiven);

			Inv.Damage -= ValidHealthGiven;
			
			Rules.ShareExperience(StatsInv, GrantExp);
		}

		//help keep things in check so a player never has surplus damage in storage.
		if(Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health); //never let it go negative.
	}
}

state Activated
{
	function BeginState()
	{	local Vehicle V;

		if(Rules == None)
			CheckRPGRules();

		if ((Instigator != None) && (Instigator.Controller != None))
		{
			if(Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
		
			V = Vehicle(Instigator);
			if (V != None )
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				bActive = false;
				GotoState('');
				return;	// can't use in a vehicle

			}

			// change the guts of it
			SpawnLocation = Instigator.Location;
			switch (EffectRadius) 
			{
			case 500:
				spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
				break;
			case 700:
				spawn(class'SphereHealing700r', Instigator.Controller,,SpawnLocation);
				break;
			case 900:
				spawn(class'SphereHealing900r', Instigator.Controller,,SpawnLocation);
				break;
			case 1100:
				spawn(class'SphereHealing1100r', Instigator.Controller,,SpawnLocation);
				break;
			Default:
				Log("ArtifactSphereHealing invalid radius used. Should be 500, 700, 900 or 1100");
				spawn(class'SphereHealing900r', Instigator.Controller,,SpawnLocation);
				break;
			}
			bActive = true;

			// see what our max is, and what xp we get
			ExpMultiplier = getExpMultiplier();
			MaxHealth = getMaxHealthBonus();

			// now let's add to the people around us
			HealTeam(SpawnLocation);
			SetTimer(0.5, true);
		}
	}
	function Timer()
	{
		if (bActive)
		{
			if (Instigator.Controller == None)
			{
				// probably ghosting. Can't deduct adrenaline anyway
				bActive = false;
				GotoState('');
				return;	
			}
			switch (EffectRadius) 
			{
			case 500:
				spawn(class'SphereHealing500r', Instigator.Controller,,SpawnLocation);
				break;
			case 700:
				spawn(class'SphereHealing700r', Instigator.Controller,,SpawnLocation);
				break;
			case 900:
				spawn(class'SphereHealing900r', Instigator.Controller,,SpawnLocation);
				break;
			case 1100:
				spawn(class'SphereHealing1100r', Instigator.Controller,,SpawnLocation);
				break;
			Default:
				spawn(class'SphereHealing900r', Instigator.Controller,,SpawnLocation);
				break;
			}
			HealTeam(SpawnLocation);
		}
	}
	function EndState()
	{
		SetTimer(0, false);
		bActive = false;
	}
}

function int getMaxHealthBonus()
{
	if(AMSH == None)
		AMSH = ArtifactMakeSuperHealer(Instigator.FindInventoryType(class'ArtifactMakeSuperHealer'));
	if(AMSH != None)
		return AMSH.MaxHealth;
	else
		return class'RW_Healer'.default.MaxHealth;
}

function float getExpMultiplier()
{
	if(AMSH == None)
		AMSH = ArtifactMakeSuperHealer(Instigator.FindInventoryType(class'ArtifactMakeSuperHealer'));
	if(AMSH != None)
		return AMSH.EXPMultiplier;
	else
		return class'RW_Healer'.default.EXPMultiplier;
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 0)
		return "Your adrenaline has run out.";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=28		// 4 seconds worth
     AdrenalinePerSecond=7
     HealthPerSecond=15
     CostPerSec=7
     PickupClass=Class'ArtifactSphereHealingPickup'
     IconMaterial=Texture'DCText.Icons.SphereHealing'	
     ItemName="Healing Sphere"
     EffectRadius=900.000000	// note if you change this, you need to change SphereHealing to set the sphere size
     EffectOverlay=Shader'UTRPGTextures2.Overlays.PulseBlueShader1'
}
