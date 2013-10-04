class RW_Knockback extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var Sound KnockbackSound;

var config float DamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	Local KnockbackInv Inv;
	Local Vector newLocation;

	if (!class'OneDropRPGWeapon'.static.CheckCorrectDamage(ModifiedWeapon, DamageType))
		return;

	super.NewAdjustTargetDamage(Damage, OriginalDamage, Victim, HitLocation, Momentum, DamageType);
	if (!bIdentified)
		Identify();

	if(damage > 0)
	{
		if (Damage < (OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent))
			Damage = OriginalDamage * class'OneDropRPGWeapon'.default.MinDamagePercent;

		Damage = Max(1, Damage * (1.0 + DamageBonus * Modifier));

		if(Instigator == None)
			return;

		P = Pawn(Victim);
		if(P == None || !class'RW_Freeze'.static.canTriggerPhysics(P))
			return;

		if(P.FindInventoryType(class'KnockbackInv') != None)
			return ;

		Inv = spawn(class'KnockbackInv', P,,, rot(0,0,0));
		if(Inv == None)
			return; //wow
	
		Inv.LifeSpan = (MaxModifier + 1) - Modifier;
		Inv.Modifier = Modifier;
		Inv.GiveTo(P);

		// if they're not walking, falling, or hovering, 
		// the momentum won't affect them correctly, so make them hover.
		// this effect will end when the KnockbackInv expires.
		if(P.Physics != PHYS_Walking && P.Physics != PHYS_Falling && P.Physics != PHYS_Hovering)
			P.SetPhysics(PHYS_Hovering);

		//I check the x,y, and z to see if this projectile has no momentum (some weapons have none)
		if
		(
			(
				Momentum.X == 0 && 
				Momentum.Y == 0 && 
				Momentum.Z == 0
			) || 
			ClassIsChildOf(DamageType, class'DamTypeSniperShot') || 
			ClassIsChildOf(DamageType, class'DamTypeClassicSniper') ||
			ClassIsChildOf(DamageType, class'DamTypeLinkShaft') ||
			ClassIsChildOf(DamageType, class'DamTypeONSAVRiLRocket') ||
			instr(caps(string(DamageType)), "AVRIL") > -1 //hack for vinv avril
		)
		{
			if(Instigator == Victim)
				 Momentum = Instigator.Location - HitLocation;
			else
				 Momentum = Instigator.Location - Victim.Location;
			Momentum = Normal(Momentum);
			Momentum *= -200;

			// if they're walking, I need to bump them up 
			// in the air a bit or they won't be knocked back 
			// on no momentum weapons.
			if(P.Physics == PHYS_Walking)
			{
				newLocation = P.Location;
				newLocation.z += 10;
				P.SetLocation(newLocation);
			}
		}

		Momentum *= Max(2.0, Max(Modifier * 0.5, Damage * 0.1)); //kawham!
		P.SetOverlayMaterial(ModifierOverlay, 1.0, false);
		if(PlayerController(P.Controller) != None)
		 		PlayerController(P.Controller).ReceiveLocalizedMessage(class'KnockbackConditionMessage', 0);
		P.PlaySound(KnockbackSound,,1.5 * Victim.TransientSoundVolume,,Victim.TransientSoundRadius);
	}
}

defaultproperties
{
	DamageBonus=0.030000
	KnockbackSound=Sound'WeaponSounds.Misc.ballgun_launch'
	ModifierOverlay=Shader'DCText.DomShaders.PulseRedShader'
	MinModifier=2
	MaxModifier=6
	PostfixPos=" of Knockback"
}