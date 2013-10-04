class DruidMinigunTurret extends ASTurret_Minigun;

var float LastHealTime;
var array<Controller> Healers;
var array<float> HealersLastLinkTime;
var int NumHealers;
var MutUT2004RPG RPGMut;
var bool IsLockedForSelf;
var Controller PlayerSpawner;
var Material LockOverlay;

replication
{
	reliable if (Role == ROLE_Authority)
		NumHealers;
}

simulated event PostBeginPlay()
{
	local Mutator m;

	DefaultWeaponClassName=string(class'DruidMiniTurretWeapon');

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}
			
	if (Role == ROLE_Authority)		
		SetTimer(1, true);	// for calculating number of healers
}

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
}

function Timer()
{
	// check how many healers we have
	local int i;
	local int validHealers;
	
	if (Role < ROLE_Authority)	
		return;	

	validHealers = 0;
	for(i = 0; i < Healers.length; i++)
	{
		if (HealersLastLinkTime[i] > Level.TimeSeconds-0.5)
		{	// this healer has healed in the last half a second, so keep.
			if (i > validHealers)
			{	// shuffle down to next valid slot
				HealersLastLinkTime[validHealers] = HealersLastLinkTime[i];
				Healers[validHealers] = Healers[i];
			}
			validHealers++;
		}
	}
	Healers.Length = validHealers;		// and get rid of the non-valid healers.
	HealersLastLinkTime.length = validHealers;
	
	// now update the replicated value
	if (NumHealers != validHealers)
		NumHealers = validHealers;

}

function bool HealDamage(int Amount, Controller Healer, class<DamageType> DamageType)
{
	local int i;
	local bool gotit;
	local bool healret;
	local Mutator m;

	// quick check to make sure we got the RPGMut set
	if (RPGMut == None && Level.Game != None)
	{
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}
	}

	// keep a list of who is healing
	gotit = false;
	if (Healer != None && TeamLink(Healer.GetTeamNum()))
	{	
		// check the healer is an engineer
		if (Healer.Pawn != None && ((Healer.Pawn.Weapon != None && RW_EngineerLink(Healer.Pawn.Weapon) != None) || DruidLinkSentinel(Healer.Pawn) != None))
		{

			// now add to list
			for(i = 0; i < Healers.length; i++)
			{
				if (Healers[i] == Healer)
				{
					gotit = true;
					HealersLastLinkTime[i] = Level.TimeSeconds;
					i = Healers.length;
				}
			}
			if (!gotit)
			{
				// add new healer
				Healers[Healers.length] = Healer;
				HealersLastLinkTime[HealersLastLinkTime.length] = Level.TimeSeconds;
			}
		}
	}

	healret = Super.HealDamage(Amount, Healer, DamageType);
	if (healret)
	{
		// healed turret of health, so no damage/xp bonus this second
		LastHealTime = Level.TimeSeconds;
	}
	return healret;
}

function bool TryToDrive(Pawn P)
{
	if ( (P.Controller == None) || !P.Controller.bIsPlayer || Health <= 0 )
		return false;
		
	// Check for Locking by engineer....
	if ( IsEngineerLocked() && P.Controller != PlayerSpawner )
	{
		if (PlayerController(P.Controller) != None)
		{
		    if (PlayerSpawner != None)
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'VehicleEngLockedMessage', 0, PlayerSpawner.PlayerReplicationInfo);
			else
				PlayerController(P.Controller).ReceiveLocalizedMessage(class'VehicleEngLockedMessage', 0);
		}
		return false;
	}
	else
	{
		return super.TryToDrive(P);
	}
}

function EngineerLock()
{
    IsLockedForSelf = True;
	SetOverlayMaterial(LockOverlay, 50000.0, false);
}

function EngineerUnlock()
{
    IsLockedForSelf = False;
	SetOverlayMaterial(LockOverlay, 0.0, false);
}

function bool IsEngineerLocked()
{
    return IsLockedForSelf;
}

simulated function KDriverEnter(Pawn P)
{
	Super.KDriverEnter(P);

    if (Weapon != None && Driver != None && xPawn(Driver) != None && Driver.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, xPawn(Driver).UDamageTime - Level.TimeSeconds, false);

}

simulated function bool KDriverLeave( bool bForceLeave )
{
	// sort out the Udamage overlay
	if (Weapon != None && Controller != None && xPawn(Controller.Pawn) != None && Controller.Pawn.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Controller.Pawn).UDamageWeaponMaterial, 0, false);

	return Super.KDriverLeave(bForceLeave);
}

function DriverDied()
{
	if (Weapon != None && xPawn(Driver) != None && Driver.HasUDamage())
		Weapon.SetOverlayMaterial(xPawn(Driver).UDamageWeaponMaterial, 0, false);

	Super.DriverDied();
}

function bool HasUDamage()
{
	return (Driver != None && Driver.HasUDamage());
}

// TakeDamage taken from ASVehicle and modified to force eject rather than crash
function TakeDamage( int Damage, Pawn instigatedBy, Vector hitlocation,
						Vector momentum, class<DamageType> damageType)
{
	local int			actualDamage;
	local bool			bAlreadyDead;
	local Controller	Killer;

	if ( Role < ROLE_Authority )
	{
		log(self$" client damage type "$damageType$" by "$instigatedBy);
		return;
	}

	if ( Level.Game == None )
		return;

	// Spawn Protection: Cannot be destroyed by a player until possessed
	if ( bSpawnProtected && instigatedBy != None && instigatedBy != Self )
		return;

	// Prevent multiple damage the same tick (for splash damage deferred by turret bases for example)
	if ( Level.TimeSeconds == DamLastDamageTime && instigatedBy == DamLastInstigator )
		return;

	DamLastInstigator = instigatedBy;
	DamLastDamageTime = Level.TimeSeconds;

	if ( damagetype == None )
		DamageType = class'DamageType';

	Damage		*= DamageType.default.VehicleDamageScaling;
	momentum	*= DamageType.default.VehicleMomentumScaling * MomentumMult;
	bAlreadyDead = (Health <= 0);
	NetUpdateTime = Level.TimeSeconds - 1; // force quick net update

    if ( Weapon != None )
        Weapon.AdjustPlayerDamage( Damage, InstigatedBy, HitLocation, Momentum, DamageType );
    if ( (InstigatedBy != None) && InstigatedBy.HasUDamage() )
        Damage *= 2;

	actualDamage = Level.Game.ReduceDamage(Damage, self, instigatedBy, HitLocation, Momentum, DamageType);

	if ( DamageType.default.bArmorStops && (actualDamage > 0) )
		actualDamage = ShieldAbsorb( actualDamage );

    if ( bShowDamageOverlay && DamageType.default.DamageOverlayMaterial != None && actualDamage > 0 )
        SetOverlayMaterial( DamageType.default.DamageOverlayMaterial, DamageType.default.DamageOverlayTime, true );

	Health -= actualDamage;

	if ( HitLocation == vect(0,0,0) )
		HitLocation = Location;
	if ( bAlreadyDead )
		return;

	PlayHit(actualDamage,InstigatedBy, hitLocation, damageType, Momentum);
	if ( Health <= 0 )
	{

		if ( Driver != None )
	       	KDriverLeave( false );

		// pawn died
		if ( instigatedBy != None )
			Killer = instigatedBy.GetKillerController();
		else if ( (DamageType != None) && DamageType.default.bDelayedDamage )
			Killer = DelayedDamageInstigatorController;

		Health = 0;

		TearOffMomentum = momentum;

		Died(Killer, damageType, HitLocation);
	}
	else
	{
		if ( Controller != None )
			Controller.NotifyTakeHit(instigatedBy, HitLocation, actualDamage, DamageType, Momentum);
	}

	MakeNoise(1.0);
}

simulated function Destroyed_HandleDriver()
{
	Driver.LastRenderTime = LastRenderTime;
	if ( Role != ROLE_Authority )
		if ( Driver.DrivenVehicle == self )
			Driver.StopDriving(self);
}

defaultproperties
{
	DefaultWeaponClassName=""	// class'DruidMiniTurretWeapon'
	bRemoteControlled=false		
	DriverDamageMult=0.0		// reduce player damage in turret to reduce chance of pawn dying in the turret. 
	IsLockedForSelf=False
	LockOverlay=Shader'DCText.DomShaders.PulseRedShader'
}
