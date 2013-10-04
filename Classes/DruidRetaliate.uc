class DruidRetaliate extends CostRPGAbility
	abstract;

static function HandleDamage(out int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	if (bOwnedByInstigator)
	{	// the retaliation damage going out
		// do not allow this ability to kill another player. Should already have adjusted for a harm weapon, and for DB/DR differences
		if (DamageType == class'DamTypeRetaliation' && Damage >= Injured.Health + Injured.GetShieldStrength() )
		{
			Damage = Max(1,Injured.Health + Injured.GetShieldStrength() - 1);	// just do one damage. If they notice they can stop firing
		}
		return;
	}
	
	// the initial damage which causes the retaliation to occur
	if (DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None || Instigator.Health <= 0)
		return;		// can't retaliate
		
	Instigator.TakeDamage(int(float(Damage) * (0.05 * AbilityLevel)), Injured, Instigator.Location, vect(0,0,0), class'DamTypeRetaliation');

	//finally check if we killed it. May happen if we have a DD or triple running
	if (Instigator == None || Instigator.Health <= 0 )
		class'ArtifactLightningBeam'.static.AddArtifactKill(Injured, class'WeaponRetaliate');
}

defaultproperties
{
	AbilityName="Retaliation"
	Description="Whenever you are damaged by another player, 5% of the damage per level is also done to the player that hurt you. Your Damage Bonus stat and your opponent's Damage Reduction stat are applied to this extra damage. You can't retaliate to retaliation damage and retaliation damage will not kill the enemy by itself. You must have a Damage Reduction of at least 50 to purchase this ability. (Max Level: 10)"
	StartingCost=10
	CostAddPerLevel=5
	MaxLevel=10
	MinDR=50
}
