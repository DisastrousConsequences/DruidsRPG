class AbilityRapidBuild extends EngineerAbility
	abstract;

var float ReduceRate;

static function ModifyPawn(Pawn Other, int AbilityLevel)
{
	local EngineerPointsInv EInv;

	EInv = class'AbilityLoadedEngineer'.static.GetEngInv(Other);
	if (EInv != None)
		EInv.FastBuildPercent = 1.0 - (AbilityLevel*Default.ReduceRate);

}

defaultproperties
{
     AbilityName="Constructions: Rapid Build"
     Description="Reduces the delay before you can buld the next item. Each level takes 10% health off your recovery time. |Cost (per level): 4,5,6,7,8..."
     StartingCost=4
     CostAddPerLevel=1
     MaxLevel=10
     ReduceRate=0.100000
}