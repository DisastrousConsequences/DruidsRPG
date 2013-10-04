class DruidDefenseSentinelController extends Controller
	config(UT2004RPG);

var Controller PlayerSpawner;
var RPGStatsInv StatsInv;
var MutUT2004RPG RPGMut;

var config float TimeBetweenShots;
var config float TargetRadius;
var config float XPPerHit;      // the amount of xp the summoner gets per projectile taken out
var config float XPPerHealing;      // the amount of xp the summoner gets per projectile taken out
var config int HealFreq;        // how often to go through the healing loop. 2 means every other time.

var float DamageAdjust;		// set by AbilityLoadedEngineer

var class<xEmitter> HitEmitterClass;        // for standard defense sentinel
var class<xEmitter> ShieldEmitterClass;
var class<xEmitter> HealthEmitterClass;
var class<xEmitter> AdrenalineEmitterClass;
var class<xEmitter> ResupplyEmitterClass;
var class<xEmitter> ArmorEmitterClass;

var Material HealingOverlay;

var bool bHealing;
var int DoHealCount;


simulated event PostBeginPlay()
{
	local Mutator m;

	super.PostBeginPlay();

	if (Level.Game != None)
		for (m = Level.Game.BaseMutator; m != None; m = m.NextMutator)
			if (MutUT2004RPG(m) != None)
			{
				RPGMut = MutUT2004RPG(m);
				break;
			}
}

function SetPlayerSpawner(Controller PlayerC)
{
	PlayerSpawner = PlayerC;
	if (PlayerSpawner.PlayerReplicationInfo != None && PlayerSpawner.PlayerReplicationInfo.Team != None )
	{
		if (PlayerReplicationInfo == None)
			PlayerReplicationInfo = spawn(class'PlayerReplicationInfo', self);
		PlayerReplicationInfo.PlayerName = PlayerSpawner.PlayerReplicationInfo.PlayerName$"'s Sentinel";
		PlayerReplicationInfo.bIsSpectator = true;
		PlayerReplicationInfo.bBot = true;
		PlayerReplicationInfo.Team = PlayerSpawner.PlayerReplicationInfo.Team;
		PlayerReplicationInfo.RemoteRole = ROLE_None;

		// adjust the fire rate according to weapon speed
		StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
		if (StatsInv != None)
			TimeBetweenShots = (default.TimeBetweenShots * 100)/(100 + StatsInv.Data.WeaponSpeed);
		if (DamageAdjust > 0.1)
			TimeBetweenShots = TimeBetweenShots / DamageAdjust;		// cant adjust damage for DamageAdjust, so update fire frequency
	}
	SetTimer(TimeBetweenShots, true);
}

function DoHealing()
{
	local Controller C;
	local xEmitter HitEmitter;
	Local Pawn LoopP, RealP;
	Local DruidDefenseSentinel DefPawn;
	Local float NumHelped;
	Local HealableDamageInv HDInv;
	local Mutator m;
	
	if (Pawn == None || Pawn.Health <= 0 || DruidDefenseSentinel(Pawn) == None)
	    return;
	DefPawn = DruidDefenseSentinel(Pawn);
	    
	if (DefPawn.ShieldHealingLevel==0 && DefPawn.HealthHealingLevel==0 && DefPawn.AdrenalineHealingLevel==0 && DefPawn.ResupplyLevel==0 && DefPawn.ArmorHealingLevel == 0)
	    return;

    NumHelped = 0.0;

	if (bHealing)
	{
	    Log("=================!!!!! bHealing still set ");      // just in case the cpu gets too busy
	    return;
	}
    bHealing = true;
    
   // loop through all the pawns in range. Can't use controllers as blocks and unmanned turrets/vehicles do not have controllers.
	foreach DynamicActors(class'Pawn', LoopP)
	{
	// first check if the pawn is anywhere near
	    if (LoopP != None && VSize(LoopP.Location - DefPawn.Location) < TargetRadius && FastTrace(LoopP.Location, DefPawn.Location))
	    {
			// ok, let's go for it
			C = LoopP.Controller;

			if ( C != None && DefPawn != None && LoopP != DefPawn && LoopP.Health > 0 && C.SameTeamAs(self) )
			{
				//ok lets see if we can help.
				RealP = LoopP;
				if (LoopP != None && LoopP.isA('Vehicle'))
					RealP = Vehicle(LoopP).Driver;

				if (RealP != None && XPawn(RealP) != None && HardCoreInv(RealP.FindInventoryType(class'HardCoreInv')) == None)  // only interested in health/shields/ammo/adren for player pawns
		        {
					//first check shield healing
					if (DefPawn.ShieldHealingLevel > 0 && RealP.GetShieldStrength() < RealP.GetShieldStrengthMax())
					{
					    // can add some shield
						RealP.AddShieldStrength((DefPawn.ShieldHealingAmount * DefPawn.ShieldHealingLevel * RealP.GetShieldStrengthMax())/100.0);

						HitEmitter = spawn(ShieldEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if(PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealShieldConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.ShieldPack',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						HDInv = HealableDamageInv(RealP.FindInventoryType(class'HealableDamageInv'));
						if(HDInv != None)
						{
							//help keep things in check so a player never has surplus damage in storage. But don't claim any for this.
							if(HDInv.Damage > (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health)
								HDInv.Damage = Max(0, (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health); //never let it go negative.
						}
						if (PlayerSpawner != C)
							NumHelped += (DefPawn.ShieldHealingLevel * 2);  // score double for shields
					}
					else    // try health healing

					if (DefPawn.HealthHealingLevel > 0 && RealP.Health < (RealP.HealthMax + 100))
					{
					    // can add some health
						RealP.GiveHealth(max(1,(DefPawn.HealthHealingAmount * DefPawn.HealthHealingLevel * (RealP.HealthMax + 100))/100.0), RealP.HealthMax + 100);
						RealP.SetOverlayMaterial(HealingOverlay, 1.0, false);

						HitEmitter = spawn(HealthEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if(PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealedConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.HealthPack',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						HDInv = HealableDamageInv(RealP.FindInventoryType(class'HealableDamageInv'));
						if(HDInv != None)
						{
							//help keep things in check so a player never has surplus damage in storage. But don't use any for this healing
							if(HDInv.Damage > (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health)
								HDInv.Damage = Max(0, (RealP.HealthMax + Class'HealableDamageGameRules'.default.MaxHealthBonus) - RealP.Health); //never let it go negative.
						}
						if(PlayerSpawner != C)
							NumHelped += (DefPawn.HealthHealingLevel * 3);  // score triple for health;
					}
					else    // try adding adrenaline
					if (DefPawn.AdrenalineHealingLevel > 0 && C.Adrenaline < C.AdrenalineMax && !RealP.InCurrentCombo() && !class'ActiveArtifactInv'.static.hasActiveArtifact(RealP))
					{
					    // can add some adrenaline
						C.AwardAdrenaline((DefPawn.AdrenalineHealingAmount * DefPawn.AdrenalineHealingLevel * C.AdrenalineMax)/100.0);

						HitEmitter = spawn(AdrenalineEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if(PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealAdrenalineConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.AdrenelinPickup',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						if(PlayerSpawner != C)
							NumHelped += DefPawn.AdrenalineHealingLevel;
					}
					else    // try resupply
					if (DefPawn.ResupplyLevel > 0 && RealP.Weapon != None && RealP.Weapon.AmmoClass[0] != None && !class'MutUT2004RPG'.static.IsSuperWeaponAmmo(RealP.Weapon.AmmoClass[0])
						&& !RealP.Weapon.AmmoMaxed(0))
					{
					    // can add some ammo
						RealP.Weapon.AddAmmo(max(1,(DefPawn.ResupplyAmount * DefPawn.ResupplyLevel * RealP.Weapon.AmmoClass[0].default.MaxAmmo)/100.0), 0);

						HitEmitter = spawn(ResupplyEmitterClass,,, DefPawn.Location, rotator(RealP.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = RealP.Location;

						if(PlayerController(C) != None)
						{
							PlayerController(C).ReceiveLocalizedMessage(class'HealAmmoConditionMessage', 0, PlayerReplicationInfo);
							RealP.PlaySound(sound'PickupSounds.AssaultAmmoPickup',, 2 * RealP.TransientSoundVolume,, 1.5 * RealP.TransientSoundRadius);
						}

						if(PlayerSpawner != C)
							NumHelped += DefPawn.ResupplyLevel;
					}
				}
			}

	 		// ok now lets see if we are healing armor (and buildings). But no xp for this. (xp for healing blocks of concrete?)
		    if (DefPawn != None && DefPawn.ArmorHealingLevel > 0)
		    {
				// check for what the pawn is
				if (LoopP != None && LoopP != DefPawn && LoopP.Health > 0)
				{
				    if (Vehicle(LoopP) != None || DruidBlock(LoopP) != None || DruidExplosive(LoopP) != None || DruidEnergyWall(LoopP) != None)
				    {
						// looking good so far. Now let's check if on same team
						if (LoopP.GetTeamNum() == DefPawn.GetTeamNum() && LoopP.Health < LoopP.HealthMax)
						{
						    // can add some health
							LoopP.GiveHealth(max(1,(DefPawn.ArmorHealingAmount * DefPawn.ArmorHealingLevel * LoopP.HealthMax)/100.0), LoopP.HealthMax);
							HitEmitter = spawn(ArmorEmitterClass,,, DefPawn.Location, rotator(LoopP.Location - DefPawn.Location));
							if (HitEmitter != None)
								HitEmitter.mSpawnVecA = LoopP.Location;

						}
					}
				}
			}
		}
    }

	if ((XPPerHealing > 0) && (NumHelped > 0) && PlayerSpawner != None && PlayerSpawner.Pawn != None)
	{
		// now give xp according to number healped.
		if (StatsInv == None)
	        StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
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
		if ((StatsInv != None) && (StatsInv.DataObject != None) && (RPGMut != None))
		{
			StatsInv.DataObject.AddExperienceFraction(XPPerHealing * NumHelped, RPGMut, PlayerSpawner.Pawn.PlayerReplicationInfo);
		}
	}

    bHealing = false;

}

function Timer()
{
	// lets target some enemies
	local Projectile P;
	local xEmitter HitEmitter;
	local Projectile ClosestP;
	local Projectile BestGuidedP;
	local Projectile BestP;
	local int ClosestPdist;
	local int BestGuidedPdist;
	local Mutator m;
	Local DruidDefenseSentinel DefPawn;
	local ONSMineProjectile Mine;

	if (PlayerSpawner == None || PlayerSpawner.Pawn == None || Pawn == None || Pawn.Health <= 0 || DruidDefenseSentinel(Pawn) == None)
		return;		// going to die soon.

	DefPawn = DruidDefenseSentinel(Pawn);

	// look for projectiles in range
	ClosestP = None;
	BestGuidedP = None;
	ClosestPdist = TargetRadius+1;
	BestGuidedPdist = TargetRadius+1;
	ForEach DynamicActors(class'Projectile',P)
	{
		if (P != None && FastTrace(P.Location, Pawn.Location) && TranslocatorBeacon(P) == None && VSize(Pawn.Location - P.Location) <= TargetRadius)
		{
			if ((P.InstigatorController == None ||
				(P.InstigatorController != None &&
					((TeamGame(Level.Game) != None && !P.InstigatorController.SameTeamAs(PlayerSpawner))	// not same team
					 || (TeamGame(Level.Game) == None && P.InstigatorController != PlayerSpawner)))))	// or just not me
			{
			    // its an enemy projectile
				// we prefer to target a server guided projectile, so it can be destroyed client side as well
				// otherwise just go for the closest
				if ( BestGuidedPdist > VSize(Pawn.Location - P.Location) && P.bNetTemporary == false && !P.bDeleteMe)
				{
					BestGuidedP = P;
					BestGuidedPdist = VSize(Pawn.Location - P.Location);
				}
				if ( ClosestPdist > VSize(Pawn.Location - P.Location) && !P.bDeleteMe)
				{
					ClosestP = P;
					ClosestPdist = VSize(Pawn.Location - P.Location);
				}

			}
			else
			{
			    // its a friendly projectile. Lets see if it is a mine and we can boost it
				if (DefPawn.SpiderBoostLevel > 0 && DefPawn.ResupplyLevel > 0 && ONSMineProjectile(P) != None)
				{
					Mine = ONSMineProjectile(P);
					if (Mine.Damage < ((1 + DefPawn.SpiderBoostLevel) * Mine.default.Damage))
					{
					    class'EngineerLinkFire'.static.BoostMine(Mine,(10.0 + DefPawn.ResupplyLevel)/10.0);      // increase by 1.1 to 1.5 depending on how much resupply
						HitEmitter = spawn(ResupplyEmitterClass,,, DefPawn.Location, rotator(P.Location - DefPawn.Location));
						if (HitEmitter != None)
							HitEmitter.mSpawnVecA = P.Location;
					}
				}
			}
		}
	}
	if (BestGuidedP != None)
		BestP = BestGuidedP;
	else
		BestP = ClosestP;

	if (BestP != None && !BestP.bDeleteMe)
	{
		HitEmitter = spawn(HitEmitterClass,,, Pawn.Location, rotator(BestP.Location - Pawn.Location));
		if (HitEmitter != None)
			HitEmitter.mSpawnVecA = BestP.Location;

		BestP.NetUpdateTime = Level.TimeSeconds - 1;
		BestP.bHidden = true;
		if (BestP.Physics != PHYS_None)	// to stop attacking an exploding redeemer
		{
		    // destroy it
			BestP.Explode(BestP.Location,vect(0,0,0));
			
			// ok, lets see if the initiator gets any xp
       		if (StatsInv == None && PlayerSpawner != None && PlayerSpawner.Pawn != None)
	            StatsInv = RPGStatsInv(PlayerSpawner.Pawn.FindInventoryType(class'RPGStatsInv'));
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
			if ((XPPerHit > 0) && (StatsInv != None) && (StatsInv.DataObject != None) && (RPGMut != None) && (PlayerSpawner != None) && (PlayerSpawner.Pawn != None))
			{
				StatsInv.DataObject.AddExperienceFraction(XPPerHit, RPGMut, PlayerSpawner.Pawn.PlayerReplicationInfo);
			}

		}
	}
	else
	{
	    // no projectile to shoot down. Let's see if there is anything else we can do. Try healing - but only in teamgames
	    if ((TeamGame(Level.Game) != None))
	    {
	        DoHealCount++;
	        if (DoHealCount >= HealFreq)
	        {
	            DoHealCount = 0;    // reset
	    		DoHealing();
			}
		}
	}

}

function Destroyed()
{
	if (PlayerReplicationInfo != None)
		PlayerReplicationInfo.Destroy();

	Super.Destroyed();
}

defaultproperties
{
	TargetRadius=700.000000
	HitEmitterClass=Class'DefenseBoltEmitter'
	TimeBetweenShots=0.6
	XPPerHit=0.066
	XPPerHealing=0.02
	HealFreq=4

	DamageAdjust=1.0

	ShieldEmitterClass=Class'GoldBoltEmitter'        		// yellow for shield
	HealthEmitterClass=Class'LightningBeamEmitter'          // blue for healing
	AdrenalineEmitterClass=Class'LightningBoltEmitter'      // white for adrenaline
	ResupplyEmitterClass=Class'RedBoltEmitter'              // red for resupply
	ArmorEmitterClass=Class'BronzeBoltEmitter'              // bronze for armor
	HealingOverlay=Shader'UTRPGTextures2.Overlays.PulseBlueShader1'
}