class DruidCounterShove extends CostRPGAbility
	abstract;

static function HandleDamage(int Damage, Pawn Injured, Pawn Instigator, out vector Momentum, class<DamageType> DamageType, bool bOwnedByInstigator, int AbilityLevel)
{
	local float MomentumMod;
	local vector CounterShoveValue;

	if (bOwnedByInstigator || DamageType == class'DamTypeRetaliation' || Injured == Instigator || Instigator == None || Injured == None ||  VSize(Momentum) == 0)
		return;

	if (Instigator.Controller == None || Injured.Controller == None)
		return;

	if (Instigator.Health <= 0)	// already dead, so no point pushing
		return;
		
	if (TeamGame(Injured.Level.Game) != None && TeamGame(Injured.Level.Game).FriendlyFireScale == 0 && Instigator.Controller.SameTeamAs(Injured.Controller))
	 		return; 	// on same team
	
	//negative values to reverse direction
	MomentumMod = - (200 * (AbilityLevel+1));

	// the Instigator will get back Momentum sufficient to send him back at a reasonable speed
	CounterShoveValue = (Normal(Momentum) * Instigator.Mass * MomentumMod);
	
	if (TeamGame(Injured.Level.Game) != None && Instigator.Controller.SameTeamAs(Injured.Controller) && TeamGame(Injured.Level.Game).FriendlyFireScale > 0)
		CounterShoveValue *= TeamGame(Injured.Level.Game).FriendlyFireScale;		// since this attack is pure momentum, then we ought to scale it down

	Instigator.TakeDamage(0, Injured, Instigator.Location, CounterShoveValue, class'DamTypeRetaliation');
}

static function int BotBuyChance(Bot B, RPGPlayerDataObject Data, int CurrentLevel)
{
		return 0;	// stop bots from trying to buy
}

defaultproperties
{
     AbilityName="CounterShove"
     Description="Whenever you are damaged by another player, some of the momentum per level is also done to the player who hurt you. Will not CounterShove a CounterShove. You must have a Damage Reduction of at least 50 to purchase this ability. (Max Level: 5)"
     StartingCost=15
     MaxLevel=5
     
     MinDR=50
}
