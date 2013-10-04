KeyBinding
==========

Allows you to define keys for accessing artifacts.

You need to make sure you have both the ucl and int, as well as the u file in the system folder. 
In particular, the int file needs the lines

[Public]
Object=(Class=Class,MetaClass=Engine.Mutator,Name=DruidsRPGcvs.DruidsRPGKeysMut,Description="Adds ability to directly select artifacts with keys")
Object=(Class=class,MetaClass=Xinterface.GUIUserKeyBinding,Name=DruidsRPGcvs.DruidsRPGKeyBinding)

at the top.

When starting the game, add the DruidsRPGKeysMut mutator "Key Bindings for RPG Artifacts".

In settings, go and set what keys you want for each of the listed artifacts. 
(You may need to start the game first, then go into Settings - I can't remember)

You can also set up bindings directly in the User.ini file
e.g.
Aliases[37]=(Command="SelectGlobe | OnRelease ActivateItem",Alias="ActivateGlobe")
Aliases[38]=(Command="SelectTriple | OnRelease ActivateItem",Alias="ActivateTriple")
.....
Backslash=ActivateGlobe
.....
Shift=ActivateTriple

The console commands are:
 SelectTriple
 SelectGlobe
 SelectMWM
 SelectDouble
 SelectMax
 SelectPlusOne
 SelectFlight
 SelectMagnet
 SelectTeleport
 SelectRod
 SelectBeam
 SelectBolt
 SelectRepulsion
 SelectFreezeBomb
 SelectPoisonBlast
 SelectMegaBlast
 SelectHealingBlast
 SelectMedic
 SelectSphereInv
 SelectSphereHeal
 SelectSphereDamage

The DruidsRPGInteraction also includes two other commands "DropHealth" and "DropAdrenaline". 
These will cause the player to drop a 25 health pack or a large 25 adrenaline pickup.

In the UT2004RPG.ini, you might want to add
[DruidsRPGcvs.DruidsRPGKeysMut]
ArtifactKeyConfigs=(Alias="SelectTriple",ArtifactClass=Class'DruidsRPGcvs.DruidArtifactTripleDamage')
ArtifactKeyConfigs=(Alias="SelectGlobe",ArtifactClass=Class'UT2004RPG.ArtifactInvulnerability')
ArtifactKeyConfigs=(Alias="SelectMWM",ArtifactClass=Class'DruidsRPGcvs.DruidArtifactMakeMagicWeapon')
ArtifactKeyConfigs=(Alias="SelectDouble",ArtifactClass=Class'DruidsRPGcvs.DruidDoubleModifier')
ArtifactKeyConfigs=(Alias="SelectMax",ArtifactClass=Class'DruidsRPGcvs.DruidMaxModifier')
ArtifactKeyConfigs=(Alias="SelectPlusOne",ArtifactClass=Class'DruidsRPGcvs.DruidPlusOneModifier')
ArtifactKeyConfigs=(Alias="SelectBolt",ArtifactClass=Class'DruidsRPGcvs.ArtifactLightningBolt')
ArtifactKeyConfigs=(Alias="SelectRepulsion",ArtifactClass=Class'DruidsRPGcvs.ArtifactRepulsion')
ArtifactKeyConfigs=(Alias="SelectFreezeBomb",ArtifactClass=Class'DruidsRPGcvs.ArtifactFreezeBomb')
ArtifactKeyConfigs=(Alias="SelectPoisonBlast",ArtifactClass=Class'DruidsRPGcvs.ArtifactPoisonBlast')
ArtifactKeyConfigs=(Alias="SelectMegaBlast",ArtifactClass=Class'DruidsRPGcvs.ArtifactMegaBlast')
ArtifactKeyConfigs=(Alias="SelectHealingBlast",ArtifactClass=Class'DruidsRPGcvs.ArtifactHealingBlast')
ArtifactKeyConfigs=(Alias="SelectMedic",ArtifactClass=Class'DruidsRPGcvs.ArtifactMakeSuperHealer')
ArtifactKeyConfigs=(Alias="SelectFlight",ArtifactClass=Class'UT2004RPG.ArtifactFlight')
ArtifactKeyConfigs=(Alias="SelectMagnet",ArtifactClass=Class'DruidsRPGcvs.DruidArtifactSpider')
ArtifactKeyConfigs=(Alias="SelectTeleport",ArtifactClass=Class'UT2004RPG.ArtifactTeleport')
ArtifactKeyConfigs=(Alias="SelectBeam",ArtifactClass=Class'DruidsRPGcvs.ArtifactLightningBeam')
ArtifactKeyConfigs=(Alias="SelectRod",ArtifactClass=Class'DruidsRPGcvs.DruidArtifactLightningRod')
ArtifactKeyConfigs=(Alias="SelectSphereInv",ArtifactClass=Class'DruidsRPGcvs.ArtifactSphereInvulnerability')
ArtifactKeyConfigs=(Alias="SelectSphereHeal",ArtifactClass=Class'DruidsRPGcvs.ArtifactSphereHealing')
ArtifactKeyConfigs=(Alias="SelectSphereDamage",ArtifactClass=Class'DruidsRPGcvs.ArtifactSphereDamage')

This allows you to define which artifact class is actioned by the command alias.

Note to other developers
========================
If you add new artifacts, you will also need to 
 edit both DruidsRPGKeysInteraction.uc and DruidsRPGKeyBinding.uc

