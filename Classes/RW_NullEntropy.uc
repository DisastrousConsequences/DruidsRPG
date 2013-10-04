class RW_NullEntropy extends OneDropRPGWeapon
	HideDropDown
	CacheExempt
	config(UT2004RPG);

var config float DamageBonus;

function NewAdjustTargetDamage(out int Damage, int OriginalDamage, Actor Victim, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local Pawn P;
	Local NullEntropyInv Inv;

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

		if(Victim != None && Victim.isA('Vehicle'))
			return;

		P = Pawn(Victim);
		if(P == None || !class'RW_Freeze'.static.canTriggerPhysics(P))
			return;

		if(P.FindInventoryType(class'NullEntropyInv') != None)
			return ;

		Inv = spawn(class'NullEntropyInv', P,,, rot(0,0,0));
		if(Inv == None)
			return; //wow

		Inv.LifeSpan = (0.1 * Modifier) + Modifier;
		Inv.Modifier = Modifier;
		Inv.GiveTo(P);

		Momentum.X = 0;
		Momentum.Y = 0;
		Momentum.Z = 0;
	}
}

defaultproperties
{
	DamageBonus=0.050000
	ModifierOverlay=Shader'MutantSkins.Shaders.MutantGlowShader'
	MinModifier=1
	MaxModifier=6
	PrefixPos="Null Entropy "
}