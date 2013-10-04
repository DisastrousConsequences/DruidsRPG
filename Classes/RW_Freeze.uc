class RW_Freeze extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var Sound FreezeSound;
var config float DamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;
	}

	Super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
}

function AdjustTargetDamage(out int Damage, Actor Victim, Vector HitLocation, out Vector Momentum, class<DamageType> DamageType)
{
	local FreezeInv Inv;
	local Pawn P;
	Local Actor A;

	if (!bIdentified)
		Identify();

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	if(damage > 0)
	{
		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));
		Momentum *= 1.0 + DamageBonus * Modifier;

		P = Pawn(Victim);
		if (P != None && canTriggerPhysics(P))
		{
			if (!bIdentified)
				Identify();
		
			Inv = FreezeInv(P.FindInventoryType(class'FreezeInv'));
			//dont add to the time a pawn is already frozen. It just wouldn't be fair.
			if (Inv == None)
			{
				Inv = spawn(class'FreezeInv', P,,, rot(0,0,0));
				Inv.Modifier = Modifier;
				Inv.LifeSpan = Modifier;
				Inv.GiveTo(P);
				if(Victim.isA('Pawn'))
				{
					A = P.spawn(class'IceSmoke', P,, P.Location, P.Rotation);
					if (A != None)
						A.PlaySound(FreezeSound,,2.5*Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
				}
			}
		}
	}
}

static function bool canTriggerPhysics(Pawn victim)
{
	local DruidGhostInv dgInv;
	local GhostInv gInv;

	if(victim == None)
		return true;
	
	//cant heal the dead...
	dgInv = DruidGhostInv(Victim.FindInventoryType(class'DruidGhostInv'));
	if(dgInv != None && !dgInv.bDisabled)
		return false;

	//cant heal the dead...
	gInv = GhostInv(Victim.FindInventoryType(class'GhostInv'));
	if(gInv != None && !gInv.bDisabled)
		return false;

	if(Victim.PlayerReplicationInfo != None && Victim.PlayerReplicationInfo.HasFlag != None)
		return false;
	
	return true;
}

defaultproperties
{
	DamageBonus=0.050000
	FreezeSound=Sound'Slaughtersounds.Machinery.Heavy_End'
	ModifierOverlay=Shader'DCText.DomShaders.PulseGreyShader'
	MinModifier=3
	MaxModifier=6
	AIRatingBonus=0.025000
	PrefixPos="Freezing "
}
