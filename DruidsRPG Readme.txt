This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

DruidsRPG200

Mutator for UT2004RPG

Created by TheDruidXpawX and Shantara

Available at 
http://www.disastrousconsequences.com

Forums at
http://www.disastrousconsequences.com/dcforum/

This Requires UT2004RPG v2.2 Available at
http://mysterial.linuxgangster.org/UTRPG/

To install extract it to your UT2004 folder. By default that's C:\UT2004. 
(NOTE: If you have any data in your UT2004.ini that you want to keep, back it up first.) 

DruidsRPG is a set of modifications and changes to the base UT2004RPG system. 
These changes add a class-based system, additional artifacts, skills, & weapons.

The class-based system allows a player to pick one of 3 RPG Classes to play as:
Healer / Monster Master
Weapons Master
Adrenaline Master


DruidsRPG includes the following:

New Weapons
http://www.disastrousconsequences.com/dc/weapontypes.jsp

Other enhanced weapons
Shaders to differentiate the weapons, and also adds a + or - to 
many of them

New Artifacts
http://www.disastrousconsequences.com/dc/artifacts.jsp

New Skills
http://www.disastrousconsequences.com/dc/rpgskills.jsp
	

DruidsRPG contains an optional score fixing mutator 
so that you can do a per gametype set of xp awards:

The class name for this mutator is DruidsRPG200.MutAScoreFix
See the ScoreFix.ini for samples on how to configure these options.


DruidsRPG contains an RPG HUD Mutator that will show pets 
in different colors on the HUD as well as helping the player
ascertain the difficulty of surrounding monsters.
The class name for this mutator is DruidsRPG200.MutRPGHUD


Server Administrators:
If you add this package to your server, you must add the add the following to the 
Engine.GameEngine section of the UT2004.ini: 

ServerPackages=UT2004RPG
ServerPackages=DruidsRPG200


** Migrating from base UT2004RPG data:
If you're upgrading from the base UT2004RPG to DruidsRPG, you must compare Mysterial's
ability/weapon/artifact lists to the ones included in DruidsRPG. Wherever a class from the 
UT2004RPG is replaced, you must perform the search and replace in your data.

** Upgrading from an older version of DruidsRPG:
You must compare your current ability/weapon/artifact lists to the latest ones included 
in DruidsRPG, and perform the search and replace in your data. You must also replace the
package name DruidsRPG1xx to DruidsRPG200

** If you have a UT2004RPG.ini produced with a version of DruidsRPG with a release number
lower than 181, or are migrating existing data from Mysterial's UT2004RPG please use the 
DruidsRPG200.MutDruidUpgrade in this package. This upgrade mutator will make the best 
attempt possible to choose the users class based upon their current abilities list.

** We cannot stress strongly enough, If you're upgrading old data, carefully evaluate 
the differences between the included UT2004RPG.ini and your previous one. 
Make sure and keep a backup!

Additional help with upgrading or the mutator in general may be available via 
community effort at the disastrousconsequences.com forums.

As always, we couldn't and wouldn't do this without Mysterial's UT2004RPG. 
We, the disastrousconsequences.com community would like to thank Mysterial
for a great mutator, an extensible system, and all the support and help he has given us.