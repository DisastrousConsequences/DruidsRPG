//-----------------------------------------------------------
//
//-----------------------------------------------------------
class LoadedInv extends Inventory;

// extended to allow multiple loaded skills to be held at the same time
var bool bGotLoadedWeapons;
var bool bGotLoadedArtifacts;
var bool bGotLoadedMonsters;
var bool bGotLoadedEngineer;

var int LWAbilityLevel;
var int LAAbilityLevel;
var int LMAbilityLevel;
var int LEAbilityLevel;

var bool ProtectArtifacts;
var bool DirectMonsters;

DefaultProperties
{
     RemoteRole=ROLE_DumbProxy
     bOnlyRelevantToOwner=False
     bAlwaysRelevant=True
     bReplicateInstigator=True
}
