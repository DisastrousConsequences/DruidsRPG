class ArtifactSphereDamage extends EnhancedRPGArtifact
		config(UT2004RPG);

var config int AdrenalineRequired;
var config float KillXPPerc;
var config int AdrenalinePerSecond;
var config float EffectRadius;	// should be 500, 700, 900 or 1100

var RPGRules Rules;
var vector SpawnLocation;
var Material EffectOverlay;

function BotConsider()
{
	if (bActive && (Instigator.Controller.Enemy == None || !Instigator.Controller.CanSee(Instigator.Controller.Enemy)))
	{
		Activate();
		return;
	}
		
	if (Instigator.Controller.Adrenaline < AdrenalineRequired*2)
		return;

	if ( !bActive && Instigator.Controller.Enemy != None
		   && Instigator.Controller.CanSee(Instigator.Controller.Enemy) && NoArtifactsActive() && !Instigator.HasUDamage() && FRand() < 0.6 )
		Activate();
}

simulated function PostBeginPlay()
{
	CostPerSec = AdrenalinePerSecond*AdrenalineUsage;

	super.PostBeginPlay();

	CheckRPGRules();
}

function EnhanceArtifact(float Adusage)
{
	Super.EnhanceArtifact(AdUsage);
	
	CostPerSec = AdrenalinePerSecond * (AdrenalineUsage + 1.0) / 2.0;   // part of the benefit goes towards the bigger sphere
	EffectRadius=1100;
}

function CheckRPGRules()
{
	Local GameRules G;

	if (Level.Game == None)
		return;		//try again later

	for(G = Level.Game.GameRulesModifiers; G != None; G = G.NextGameRules)
	{
		if(G.isA('RPGRules'))
		{
			Rules = RPGRules(G);
			break;
		}
	}

	if(Rules == None)
		Log("WARNING: Unable to find RPGRules in GameRules. EXP will not be properly awarded");
}

function SetTeamDamage(vector CoreLocation)
{
	Local Controller C;
	Local DamageInv Inv;

	C = Level.ControllerList;
	while (C != None)
	{
		// loop round finding all players on same team
		if ( C.Pawn != None && vehicle(C.Pawn) == None && C.Pawn != Instigator && C.Pawn.Health > 0 && C.SameTeamAs(Instigator.Controller)
		     && VSize(C.Pawn.Location - CoreLocation) < EffectRadius && !C.Pawn.HasUDamage() && RedeemerWarhead(C.Pawn) == None)
		{
			if(HardCoreInv(C.Pawn.FindInventoryType(class'HardCoreInv')) == None )
			{
				// no got udamage is false so can't already have this set yet
				Inv = spawn(class'DamageInv', C.Pawn,,, rot(0,0,0));
				if(Inv != None)
				{
					Inv.CoreLocation = CoreLocation;
					Inv.Rules = Rules;
					Inv.KillXPPerc = KillXPPerc;
					Inv.EffectRadius = EffectRadius;
					Inv.DamagePlayerController = Instigator.Controller;
					Inv.EstimatedRunTime = 3*Instigator.Controller.Adrenaline / CostPerSec;
					Inv.GiveTo(C.Pawn);
				}
			}
		}
		C = C.NextController;
	}
}

state Activated
{
	function BeginState()
	{	local Vehicle V;

		if(Rules == None)
			CheckRPGRules();

		if ((Instigator != None) && (Instigator.Controller != None))
		{
			if(Instigator.Controller.Adrenaline < (AdrenalineRequired*AdrenalineUsage))
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, AdrenalineRequired*AdrenalineUsage, None, None, Class);
				bActive = false;
				GotoState('');
				return;
			}
		
			V = Vehicle(Instigator);
			if (V != None )
			{
				Instigator.ReceiveLocalizedMessage(MessageClass, 3000, None, None, Class);
				bActive = false;
				GotoState('');
				return;	// can't use in a vehicle

			}

			// change the guts of it
			SpawnLocation = Instigator.Location;
			switch (EffectRadius) 
			{
			case 500:
				spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
				break;
			case 700:
				spawn(class'SphereDamage700r', Instigator.Controller,,SpawnLocation);
				break;
			case 900:
				spawn(class'SphereDamage900r', Instigator.Controller,,SpawnLocation);
				break;
			case 1100:
				spawn(class'SphereDamage1100r', Instigator.Controller,,SpawnLocation);
				break;
			Default:
				Log("ArtifactSphereDamage invalid radius used. Should be 500, 700, 900 or 1100");
				spawn(class'SphereDamage900r', Instigator.Controller,,SpawnLocation);
				break;
			}
			Instigator.EnableUDamage(9999.0);
			Instigator.SetOverlayMaterial(EffectOverlay, 2*Instigator.Controller.Adrenaline / CostPerSec, true);
			bActive = true;

			// now let's add to the people around us
			SetTeamDamage(SpawnLocation);
			SetTimer(0.5, true);
		}
	}
	function Timer()
	{
		if (bActive)
		{
			if (Instigator.Controller == None)
			{
				// probably ghosting. Can't deduct adrenaline anyway
				bActive = false;
				if (Instigator != None)
				{
					Instigator.DisableUDamage();
					Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
				}
				GotoState('');
				return;	
			}
			switch (EffectRadius) 
			{
			case 500:
				spawn(class'SphereDamage500r', Instigator.Controller,,SpawnLocation);
				break;
			case 700:
				spawn(class'SphereDamage700r', Instigator.Controller,,SpawnLocation);
				break;
			case 900:
				spawn(class'SphereDamage900r', Instigator.Controller,,SpawnLocation);
				break;
			case 1100:
				spawn(class'SphereDamage1100r', Instigator.Controller,,SpawnLocation);
				break;
			Default:
				spawn(class'SphereDamage900r', Instigator.Controller,,SpawnLocation);
				break;
			}
			SetTeamDamage(SpawnLocation);
		}
	}
	function EndState()
	{
		SetTimer(0, false);
		if (Instigator != None)
		{
			Instigator.DisableUDamage();
			Instigator.SetOverlayMaterial(EffectOverlay, -1, true);
		}
		bActive = false;
		// perhaps ought to put a check in to ensure no glitches. Check everyone that has UDamage set and check there is a reason for it. However, haven't got many clues for the DD pickup.
		
	}
}

exec function TossArtifact()
{
	//do nothing. This artifact cant be thrown
}

function DropFrom(vector StartLocation)
{
	if (bActive)
		GotoState('');
	bActive = false;

	Destroy();
	Instigator.NextItem();
}

static function string GetLocalString(optional int Switch, optional PlayerReplicationInfo RelatedPRI_1, optional PlayerReplicationInfo RelatedPRI_2)
{
	if (Switch == 3000)
		return "Cannot use this artifact inside a vehicle";
	else if (Switch == 0)
		return "Your adrenaline has run out.";
	else
		return switch @ "Adrenaline is required to use this artifact";
}

defaultproperties
{
     AdrenalineRequired=40		// 4 seconds worth
     KillXPPerc=0.5
     AdrenalinePerSecond=10
     CostPerSec=10
     PickupClass=Class'ArtifactSphereDamagePickup'
     IconMaterial=Texture'DCText.Icons.SphereDamage'	
     ItemName="Damage Sphere"
     EffectRadius=900.000000	// note if you change this, you need to change SphereDamage to set the sphere size
     EffectOverlay=Shader'XGameShaders.PlayerShaders.WeaponUDamageShader'
}
