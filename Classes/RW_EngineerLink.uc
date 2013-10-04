class RW_EngineerLink extends RW_EnhancedInfinity
	config(UT2004RPG);

var config Array<float> DamageBonusFromLinks;
var config float ShieldHealingXPPercent;
var config float SpiderGrowthRate;

var int HealingLevel;
var float ShieldHealingPercent;
var float SpiderBoost;

var RPGRules rules;

function PreBeginPlay()
{
	local GameRules G;
	Local HealableDamageGameRules SG;
	super.PreBeginPlay();

	if ( Level.Game == None)
	{
		log("Warning: Game not started. Cannot add HealableDamageGameRules for Druids RW_EngineerLink. Healing for EXP will not occur.");
		return;	
	}

	if ( Level.Game.GameRulesModifiers == None )
	{
		SG = Level.Game.Spawn(class'HealableDamageGameRules');
		if(SG == None)
			log("Warning: Unable to spawn HealableDamageGameRules for Druids RW_EngineerLink. Healing for EXP will not occur.");
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
					log("Warning: Unable to spawn HealableDamageGameRules for Druids RW_EngineerLink. Healing for EXP will not occur.");
					return; //try again next time?
				}

				//this will also add it after UT2004RPG, which will be necessarry.
				Level.Game.GameRulesModifiers.AddGameRules(SG);
				break;
			}
		}
	}
}

function PostBeginPlay()
{
	Super.PostBeginPlay();

	setupRules();
}

function setupRules()
{
	Local GameRules G;
	if(rules != None)
		return;
	if ( Level.Game == None)
		return;	//pick up later

	if ( Level.Game.GameRulesModifiers == None )
	{
		log("Unable to find RPG Rules. Will retry");
		return;
	}
	else
	{
		for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
		{
			if(G.isA('RPGRules'))
				break;
			if(G.NextGameRules == None)
				log("Unable to find RPG Rules. Will retry"); //we'll try again later
		}
	}
	rules = RPGRules(G);
}

static function bool AllowedFor(class<Weapon> Weapon, Pawn Other)
{
	if ( ClassIsChildOf(Weapon.Class,class'LinkGun') )
		return true;

	return false;
}

simulated function bool CanThrow()
{
	return false;
}

simulated function ConstructItemName()
{
	ItemName = PrefixPos$ModifiedWeapon.ItemName$PostfixPos;
}

function DropFrom(vector StartLocation)
{
	Destroy();
}

function HealShield(Pawn P, int ShieldDamage)
{
	local int ShieldGiven;
	local int CurShield;
	local int MaxShield;

	CurShield = P.GetShieldStrength();
	MaxShield = P.GetShieldStrengthMax();
	if (CurShield < MaxShield)
	{
		ShieldGiven = Max(1, ShieldDamage * HealingLevel * ShieldHealingPercent);
		ShieldGiven = Min(MaxShield - CurShield, ShieldGiven );
		P.AddShieldStrength(ShieldGiven);

		if(ShieldGiven > 0 && PlayerController(P.Controller) != None)	
		{
			PlayerController(P.Controller).ReceiveLocalizedMessage(class'HealShieldConditionMessage', 0, Instigator.PlayerReplicationInfo);
			P.PlaySound(sound'PickupSounds.ShieldPack',, 2 * P.TransientSoundVolume,, 1.5 * P.TransientSoundRadius);
		}

		doHealed(ShieldGiven, P);
	}
}

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	Local Pawn P;
	local int BestDamage;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	//sup up the damage a bit. I know set to zero by default, but could be overridden
	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent)) 
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;

		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;
	}

	P = Pawn(Victim);

	// first, lets make sure we do not get countershove off a vehicle we are healing
	if ( ClassIsChildOf(DamageType,class'DamTypeLinkShaft') && P != None && P.isA('Vehicle') 
		&& P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None)
		Momentum = vect(0,0,0);

	// We should only regen shields with the linkfire mode
	if ( !ClassIsChildOf(DamageType,class'DamTypeLinkShaft') || P == None || P.isA('Vehicle') || HealingLevel == 0)
	{
		Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
		return;
	}

	if(HardCoreInv(P.FindInventoryType(class'HardCoreInv')) != None && P != Instigator )
	{
		Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
		return;
	}

	// ok, we have the linkshaft hitting someone
	BestDamage = Max(Damage, OriginalDamage);
	if (BestDamage == 0)
		BestDamage = 10;	// if linking the damage gets set to zero

	if (P != None && BestDamage > 0)
	{
		if ( P.GetTeam() == Instigator.GetTeam() && Instigator.GetTeam() != None )
		{
			// same team
			
			
			HealShield(P,BestDamage);

			Momentum = vect(0,0,0);
			Damage = 0;
		}
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

//this function does no healing. it serves to figure out the correct amount of exp to grant to the player, and grants it.
function doHealed(int ShieldGiven, Pawn Victim)
{
	Local HealableDamageInv Inv;
	local int ValidHealthGiven;
	local float GrantExp;
	local RPGStatsInv StatsInv;
	
	setupRules();
	if(rules == None)
		return;
		
	if(Victim.Controller != None && Victim.Controller.IsA('FriendlyMonsterController'))
		return; //no exp for healing friendly pets. It's already self serving

	if(Instigator == Victim) 
		return; //no exp for self healing. It's already self benificial.

	Inv = HealableDamageInv(Victim.FindInventoryType(class'HealableDamageInv'));
	if(Inv != None)
	{
		ValidHealthGiven = Min(ShieldGiven, Inv.Damage);
		if(ValidHealthGiven > 0)
		{
			StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
			if (StatsInv == None)
			{
				log("Warning: No stats inv found. Healing exp not granted.");
				return;
			}

			GrantExp = HealingLevel * ShieldHealingXPPercent * float(ValidHealthGiven);

			Inv.Damage = Max(0, Inv.Damage - ValidHealthGiven);
			
			rules.ShareExperience(StatsInv, GrantExp);
		}

		//help keep things in check so a player never has surplus damage in storage.
		if(Inv.Damage > (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health)
			Inv.Damage = Max(0, (Victim.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - Victim.Health); //never let it go negative.
	}
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	// dont need this from RW_EnhancedInfinity as we are doing the processing in NewAdjustTargetDamage
}

static function float DamageIncreasedByLinkers(int NumLinkers)
{
	if (NumLinkers <= 0)
		return 1.0;
		
	if (NumLinkers >= default.DamageBonusFromLinks.Length)
		return default.DamageBonusFromLinks[default.DamageBonusFromLinks.Length -1];
	else
		return default.DamageBonusFromLinks[NumLinkers];
}

static function float XPForLinker(float xpGained, int NumLinkers)
{
	local float fDamageDone;
	local float fDamageByAllLinkers;
	local float fDamagePerLinker;
	
	if (xpGained <= 0.0)
		return 0.0;

	// so no linkers gives 100% to turret driver
	// 1 linker is damage 175%, (7-4)/7 of xp to linker
	// 2 linkers is damage 225%, (9-4)/(9*2) = 5/18 of xp to each linker
	// 3 linkers is damage 250%, (10-4)/(10*3) = 6/30 = 1/5 to each linker
	// 4 linkers is damage 250%, (10-4)/(10*4) = 6/40 = 3/20 xp to each linker
	// 5 linkers is damage 250%, (10-4)/(10*5) = 6/50 = 3/25 xp to each linker
	fDamageDone = static.DamageIncreasedByLinkers(NumLinkers);		

	fDamageByAllLinkers = fDamageDone - 1.0;	// driver always gets his 100% share
	if (fDamageByAllLinkers <= 0.0)
		return 0.0;
		
	fDamagePerLinker = fDamageByAllLinkers / NumLinkers;

	//Log("::::::::::::: XPForLinker xpGained:" $ xpGained @ "iNumLinkers:" $ NumLinkers	@ "DamagePerLinker:" $ fDamagePerLinker @ "xpPerLinker:" $ (xpGained * fDamagePerLinker)/fDamageDone @ "total xp given:" $ (xpGained/fDamageDone) + (NumLinkers * (xpGained * fDamagePerLinker)/fDamageDone) @ 1.0+(NumLinkers*fDamagePerLinker));
	return (xpGained * fDamagePerLinker)/fDamageDone;

}

defaultproperties
{
	bCanThrow=false
	DamageBonus=0.000000
	PrefixPos="Engineer "
	PrefixNeg="Engineer "
	PostfixPos=" of Infinity"
	PostfixNeg=" of Infinity"
	bCanHaveZeroModifier=True
	MaxModifier=0
	MinModifier=0
	ModifierOverlay=Shader'DCText.DomShaders.ELinkShader'
	ShieldHealingXPPercent=0.01
	HealingLevel=0
	ShieldHealingPercent=0.0
	DamageBonusFromLinks=(1.0,1.75,2.25,2.5)
	SpiderBoost=0
	SpiderGrowthRate=1.100000
}