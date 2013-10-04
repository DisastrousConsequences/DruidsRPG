class DruidArtifactMakeMagicWeapon extends RPGArtifact;

var MutUT2004RPG RPGMut;
var float AdrenalineUsed;
var() Sound BrokenSound;

var Weapon ActivatedOldWeapon;

static function bool ArtifactIsAllowed(GameInfo Game)
{
	if(instr(caps(string(Game.class)), "SKAARJFEST") > -1)
		return false;
	if(instr(caps(string(Game.class)), "WTFSKAARJ") > -1)
		return false;

	return true;
}

function PostBeginPlay()
{
	local Mutator m;

	Super.PostBeginPlay();

	if (Level.Game != None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}
	}
}

function BotConsider()
{
	local RPGWeapon RW;

	if (bActive)
		return;

	if (Instigator.Controller.Adrenaline < getCost())
		return;

	RW = RPGWeapon(Instigator.Weapon);
	if(RW != None && RW.Modifier >= RW.MaxModifier - 1)
		return;		// already a decent weapon

	if ( !bActive && NoArtifactsActive() && FRand() < 0.3 )	
		Activate();
}


function Activate()
{
	local Weapon OldWeapon;
	
	if (bActive)
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 4000, None, None, Class);
		GotoState('');
		ActivatedOldWeapon = None;
		return;
	}

	if (Instigator != None)
	{
		if(Instigator.Controller.Adrenaline < getCost())
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, getCost(), None, None, Class);
			GotoState('');
			bActive = false;
			ActivatedOldWeapon = None;
			return;
		}

		if (RW_EngineerLink(Instigator.Weapon) != None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 6000, None, None, Class);
			GotoState('');
			bActive = false;
			ActivatedOldWeapon = None;
			return;
		}

		OldWeapon = Instigator.Weapon;
		ActivatedOldWeapon = OldWeapon;
		if(RPGWeapon(OldWeapon) != None)
			OldWeapon = RPGWeapon(OldWeapon).ModifiedWeapon;
		
		if(OldWeapon != None)
		{

			if
			(
				(
					OldWeapon.default.FireModeClass[0] != None && 
					OldWeapon.default.FireModeClass[0].default.AmmoClass != None && 
					OldWeapon.AmmoClass[0] != None&&
					OldWeapon.AmmoClass[0].default.MaxAmmo > 0 &&
					class'MutUT2004RPG'.static.IsSuperWeaponAmmo(OldWeapon.default.FireModeClass[0].default.AmmoClass)
				) ||
				(
					OldWeapon.default.FireModeClass[1] != None && 
					OldWeapon.default.FireModeClass[1].default.AmmoClass != None && 
					OldWeapon.AmmoClass[1] != None &&
					OldWeapon.AmmoClass[1].default.MaxAmmo > 0 &&
					class'MutUT2004RPG'.static.IsSuperWeaponAmmo(OldWeapon.default.FireModeClass[1].default.AmmoClass)
				)
			)
			{

				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				GotoState('');
				ActivatedOldWeapon = None;
				bActive = false;
				return;
			}
		}
		
		If(OldWeapon != None)
			Super.Activate();
		else
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}
	}
	else
	{
		Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
		GotoState('');
		ActivatedOldWeapon = None;
		bActive = false;
		return;
	}
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 2000)
		return "Unable to generate magic weapon";
	if (Switch == 3000)
		return "Unable to generate super weapon magic weapons";
	if (Switch == 4000)
		return "Already constructing magic weapon";
	if (Switch == 5000)
		return "Your charm has broken";
	if (Switch == 6000)
		return "You cannot convert this weapon";
	else
		return Switch@"Adrenaline is required to generate a magic weapon";
}

function DoEffect();

state Activated
{
	function BeginState()
	{
		if(Instigator.Controller.Adrenaline < getCost())
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, getCost(), None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}
		AdrenalineUsed = getCost();
		bActive = true;
	}

	simulated function Tick(float deltaTime)
	{
		local float Cost;

		Cost = FMin(AdrenalineUsed, deltaTime * CostPerSec);
		AdrenalineUsed -= Cost;
		if (AdrenalineUsed <= 0.f)
		{
			//take the last bit of adrenaline from the player
			//add a tiny bit extra to fix float precision issues
			Instigator.Controller.Adrenaline -= Cost - 0.001;
			DoEffect();
		}
		else
		{
			Global.Tick(deltaTime);
		}
	}

	function DoEffect()
	{
		local inventory Copy;
		local RPGStatsInv StatsInv;
		local class<RPGWeapon> NewWeaponClass;
		local class<Weapon> OldWeaponClass;
		local int x;
		local LoadedInv LoadedInv;

		if(ActivatedOldWeapon == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}
		if(Instigator == None)
		{
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return; //nothing to do and no one to tell.
		}

		constructingNew();

		//in this case, use the new weapon class anyway.
		
		if(RPGWeapon(ActivatedOldWeapon) != None)
		{
			if(RPGWeapon(ActivatedOldWeapon).ModifiedWeapon == None)
			{
				//wha wha what?
				Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
				GotoState('');
				ActivatedOldWeapon = None;
				bActive = false;
				return;
			}
			
			OldWeaponClass = RPGWeapon(ActivatedOldWeapon).ModifiedWeapon.class;
		}
		else
			OldWeaponClass = ActivatedOldWeapon.class;

		if(OldWeaponClass == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}

		for(x = 0; x < 10; x++)
		{
			NewWeaponClass = GetRandomWeaponModifier(OldWeaponClass, Instigator);

			if(NewWeaponClass == None)
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
				GotoState('');
				ActivatedOldWeapon = None;
				bActive = false;
				return;
			}

			if(NewWeaponClass == ActivatedOldWeapon.class)
				continue; //Try not to make the same thing. That's a drag. If they do it on an existing super healer, this will iterate 10 times, but that's not so bad.
			else
				break;
		}

		Copy = spawn(NewWeaponClass, Instigator,,, rot(0,0,0));

		if(Copy == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}

		StatsInv = RPGStatsInv(Instigator.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
		{
			for (x = 0; x < StatsInv.OldRPGWeapons.length; x++)
			{
				if(ActivatedOldWeapon == StatsInv.OldRPGWeapons[x].Weapon)
				{
					StatsInv.OldRPGWeapons.Remove(x, 1);
					break;
				}
			}
		}

		if(RPGWeapon(Copy) == None)
		{
			Instigator.ReceiveLocalizedMessage(MessageClass, 2000, None, None, Class);
			GotoState('');
			ActivatedOldWeapon = None;
			bActive = false;
			return;
		}

		//try to generate a positive weapon.
		for(x = 0; x < 50; x++)
		{
			RPGWeapon(Copy).Generate(None);
			if(RPGWeapon(Copy).Modifier > -1)
				break;
		}

		RPGWeapon(Copy).SetModifiedWeapon(spawn(OldWeaponClass, Instigator,,, rot(0,0,0)), true);
		//stupid hack for speedy weapons since I can't seem to get them to work with DetachFromPawn correctly. :P
		if(ActivatedOldWeapon.isA('RW_Speedy'))
			(RW_Speedy(ActivatedOldWeapon)).deactivate();
		ActivatedOldWeapon.DetachFromPawn(Instigator);
		if(ActivatedOldWeapon.isA('RPGWeapon'))
		{
			RPGWeapon(ActivatedOldWeapon).ModifiedWeapon.Destroy();
			RPGWeapon(ActivatedOldWeapon).ModifiedWeapon = None;
		}
		ActivatedOldWeapon.Destroy();
		ActivatedOldWeapon = None;

		constructionFinished(RPGWeapon(Copy));

		Copy.GiveTo(Instigator);

		LoadedInv = LoadedInv(Instigator.FindInventoryType(class'LoadedInv'));
		if(LoadedInv == None || !LoadedInv.ProtectArtifacts)
		{
			if(shouldBreak())
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 5000, None, None, Class);
				if( PlayerController(Instigator.Controller) != None )
			        	PlayerController(Instigator.Controller).ClientPlaySound(BrokenSound);
				bActive = false;
				Destroy();
				Instigator.NextItem();
			}
		}

		ActivatedOldWeapon = None;
		GotoState('');
		bActive = false;
	}

	function EndState()
	{
		ActivatedOldWeapon = None;
		bActive = false;
	}
}

function constructingNew()
{

}

function constructionFinished(RPGWeapon result)
{

}

function int getCost()
{
	return 100;
}

function bool shouldBreak()
{
	return rand(3) == 0;
}

function class<RPGWeapon> GetRandomWeaponModifier(class<Weapon> WeaponType, Pawn Other)
{
	local int x, Chance;

	Chance = Rand(RPGMut.TotalModifierChance);
	for (x = 0; x < RPGMut.WeaponModifiers.Length; x++)
	{
		Chance -= RPGMut.WeaponModifiers[x].Chance;
		if (Chance < 0 && RPGMut.WeaponModifiers[x].WeaponClass.static.AllowedFor(WeaponType, Other))
			return RPGMut.WeaponModifiers[x].WeaponClass;
	}

	return class'RPGWeapon';
}

defaultproperties
{
	  CostPerSec=25
	  MinActivationTime=0.000001
	  PickupClass=Class'DruidArtifactMakeMagicWeaponPickup'
	  IconMaterial=Texture'XGameTextures.SuperPickups.Udamage'
	  ItemName="Magic Weapon Maker"
}
