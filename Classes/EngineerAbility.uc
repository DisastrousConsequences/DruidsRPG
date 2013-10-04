class EngineerAbility extends CostRPGAbility
	abstract;

//called by EngineerPointsInv when the construction is created _instead_ of ModifyPawn
static simulated function ModifyConstruction(Pawn Other, int AbilityLevel);
