Class HealableDamageGameRules extends GameRules
	config(UT2004RPG);

var config int MaxHealthBonus;

function int NetDamage(int OriginalDamage, int Damage, pawn injured, pawn instigatedBy, vector HitLocation, out vector Momentum, class<DamageType> DamageType)
{
	local int DamageRV;

	DamageRV = Super.NetDamage(OriginalDamage, Damage, injured, instigatedBy, HitLocation, Momentum, DamageType);

	//swap vehicles out for their drivers.
	if(Injured != None && Injured.isA('Vehicle'))
		Injured = Vehicle(Injured).Driver;
	if(instigatedBy != None && instigatedBy.isA('Vehicle'))
		instigatedBy = Vehicle(instigatedBy).Driver;

	if(instigatedBy == None || injured == None)
		return DamageRV; // Not EXP Healable

	if(Injured.Controller == None || instigatedBy.Controller == None)
		return DamageRV; // Not EXP Healable
	
	if(Injured.isA('Monster') && !Injured.Controller.isA('FriendlyMonsterController'))
		return DamageRV; // No tracking for not friendly monsters.

	if(Injured.GetTeam() == None || instigatedBy.GetTeam() != Injured.GetTeam())
	{
		doHealableDamage(DamageRV, injured);
		return DamageRV;
	}
	else
		return DamageRV;
}

function doHealableDamage(int damage, Pawn Injured)
{
	Local HealableDamageInv Inv;
	Inv = HealableDamageInv(injured.FindInventoryType(class'HealableDamageInv'));
	if(Inv == None)
	{
		Inv = injured.spawn(class'HealableDamageInv');
		Inv.giveTo(injured);
	}

	Inv.Damage += Damage;
	
	if(Inv.Damage > Injured.HealthMax + MaxHealthBonus)
		Inv.Damage = Injured.HealthMax + MaxHealthBonus;
}

defaultproperties
{
     MaxHealthBonus=250
}