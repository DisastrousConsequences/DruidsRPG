DruidsRPG200 - new artifacts 
============================

Moved from DruidsRPGExperimental.


extra artifacts for Artifact Masters
====================================

Adds 10 extra artifacts.

Lightning Bolt - based on the lightning rod, but hits just one opponent for the maximum damage it can do.

Lightning Beam - based on the lightning bolt, but has to be aimed rather than automatically hitting.

MegaBlast - Redeemer/Ultima style explosion a set distance in front of the player, if you have enough adrenaline.

HealingBlast - similar to MegaBlast, does not damage enemies but heals teammates

FreezeBomb - similar to MegaBlast, but does no damage, just Null Entropies opponents for a while.

PoisonBlast - similar to MegaBlast, but damages like poison - taken away over 5 seconds. Doesn't kill.

Repulsion - knocks enemies back from the player

Sphere of Invulnerability - large sphere within which all players are invulnerable

Sphere of Health - large sphere within which all players are healed

Sphere of Damage - large sphere within which all players get double damage



UT2004.ini
==========
none.


UT2004RPG.ini
=============

Add the artifacts to RPGArtifactManager. I suggest the LightningBeam has a chance, the rest no chance - just for AMs.
ArtifactSphereHealth really should be built into the medic class rather than the AM class.
At the moment, just add all of them to the DruidArtifactLoaded section so LAs can play.

[UT2004RPG.RPGArtifactManager]
ArtifactDelay=15
MaxArtifacts=25
MaxHeldArtifacts=0
AvailableArtifacts=(ArtifactClass=Class'UT2004RPG.ArtifactFlight',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'UT2004RPG.ArtifactTeleport',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'UT2004RPG.ArtifactInvulnerability',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidArtifactSpider',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidEnhancedArtifactMonsterSummon',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidArtifactLightningRod',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidArtifactTripleDamage',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidArtifactMakeMagicWeapon',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidMaxModifier',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidDoubleModifier',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.DruidPlusOneModifier',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactLightningBolt',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactLightningBeam',Chance=1)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactMegaBlast',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactHealingBlast',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactFreezeBomb',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactPoisonBlast',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactRepulsion',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactSphereInvulnerability',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactSphereHealth',Chance=0)
AvailableArtifacts=(ArtifactClass=Class'DruidsRPG200.ArtifactSphereDamage',Chance=0)

Add to the DruidArtifactLoaded, so AMs get automatically.
[DruidsRPG200.DruidArtifactLoaded]
SlowArtifact=Class'UT2004RPG.ArtifactFlight'
SlowArtifact=Class'UT2004RPG.ArtifactTeleport'
SlowArtifact=Class'DruidsRPG200.DruidArtifactSpider'
SlowArtifact=Class'DruidsRPG200.DruidArtifactMakeMagicWeapon'
QuickArtifact=Class'DruidsRPG200.DruidDoubleModifier'
QuickArtifact=Class'DruidsRPG200.DruidMaxModifier'
QuickArtifact=Class'DruidsRPG200.DruidPlusOneModifier'
QuickArtifact=Class'UT2004RPG.ArtifactInvulnerability'
QuickArtifact=Class'DruidsRPG200.DruidsArtifactTripleDamage'
QuickArtifact=Class'DruidsRPG200.DruidArtifactLightningRod'
QuickArtifact=Class'UT2004RPG.ArtifactTripleDamage'
QuickArtifact=Class'DruidsRPG200.ArtifactLightningBolt'
QuickArtifact=Class'DruidsRPG200.ArtifactMegaBlast'
QuickArtifact=Class'DruidsRPG200.ArtifactFreezeBomb'
QuickArtifact=Class'DruidsRPG200.ArtifactPoisonBlast'
QuickArtifact=Class'DruidsRPG200.ArtifactRepulsion'
QuickArtifact=Class'DruidsRPG200.ArtifactLightningBeam'
QuickArtifact=Class'DruidsRPG200.ArtifactSphereInvulnerability'
QuickArtifact=Class'DruidsRPG200.ArtifactSphereDamage'

Then set any required tweaking of the configuration. Add the following, and tweak as required:

[DruidsRPG200.ArtifactMegaBlast]
AdrenalineRequired=200
BlastDistance=1500
Damage=1200.000000
DamageRadius=1600.000000

[DruidsRPG200.ArtifactHealingBlast]
AdrenalineRequired=50
BlastDistance=1500
MaxHealing=400.0
MinHealing=50.0
HealingRadius=2200.000000

[DruidsRPG200.ArtifactPoisonBlast]
AdrenalineRequired=200
BlastDistance=1500
MaxDrain=30.0
MinDrain=15.0
DrainTime=5.0
DamageRadius=2200.0

[DruidsRPG200.ArtifactFreezeBomb]
AdrenalineRequired=100
BlastDistance=1500
MaxFreezeTime=15.0
FreezeRadius=2000.0

[DruidsRPG200.ArtifactLightningBolt]
DamagePerAdrenaline=4
TargetRadius=2000.0

[DruidsRPG200.ArtifactLightningBeam]
DamagePerAdrenaline=6
MaxRange=3000.0

[DruidsRPG200.ArtifactRepulsion]
AdrenalineRequired=50
BlastRadius=2500.0
MaxKnockbackMomentum=3000.0
MinKnockbackMomentum=1000.0
MaxKnockbackTime=5.0

[DruidsRPG200.ArtifactSphereInvulnerability]
AdrenalineRequired=100
ExpPerSecond=1.0
AdrenalinePerSecond=20
EffectRadius=900

[DruidsRPG200.ArtifactSphereHealing]
AdrenalineRequired=50
AdrenalinePerSecond=10
EffectRadius=900

[DruidsRPG200.ArtifactSphereDamage]
AdrenalineRequired=100
ExpPerSecond=1.0
AdrenalinePerSecond=20
EffectRadius=900

Explanation of values:
BlastDistance - the distance in front of the player that the explosion occurs. If something is in the way nearer
   than that, then it will explode on the surface of the blocking object.
AdrenalineRequired - how much adrenaline it uses. I suggest the FreezeBomb has a significantly lower value than the
   other two bombs. A frozen titan still throws rocks!
DamageRadius/FreezeRadius/BlastRadius/TargetRadius/HealingRadius - the extent of the effect from the blast point. The effect is stronger closer to the centre
   of the blast.
MaxFreezeTime - how long in seconds something at the very centre of the blast will be frozen for.
Damage - the maximum damage done at the very centre of the explosion. Drops off fairly quickly.
DrainTime - how many times the drain effect occurs.
Max/MinDrain is the drain % at the centre/edge of the blast. So something in the centre will lose 30% of it's health
   5 times e.g. a titan 900 health will lose 270,189,132,92,65 ending up with 152 health. At the edge it will lose 15% 
   health each time, so will lose 135,114,97,83,70 ending up with 401 health.
DamagePerAdrenaline - a value of 5 with 100 adrenaline will try to do 500 damage to the healthiest enemy near to you.
   If it only does 200 damage (either due to damage reduction or it died), then you only use 200/5 = 40 adrenaline.
Min/MaxKnockBackMomentum - The range of values of Momentum given in the BlastRadius
Min/MaxHealing - The range of values of Healing given in the BlastRadius
MaxKnockbackTime - the maximum time for the knockback effect.
AdrenalinePerSecond - on slow drain artifacts, how much adrenaline gets used up each second
EffectRadius - for the spheres, is the radius of the sphere. Needs to be 500, 700, 900 or 1100.


Basically, I think the idea is - 
let's evaluate, and tweak. 
