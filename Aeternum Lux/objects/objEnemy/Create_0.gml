/// @desc Set Enemy Stats/Name
event_inherited();
combatant.name = "TestMob"

combatant.baseStats.maxHp = 100;
combatant.baseStats.hp =  100;
combatant.baseStats.maxTp = 100;
combatant.baseStats.resilience = 5;
combatant.baseStats.fortitude = 5;
combatant.baseStats.affinity = 10;
combatant.baseStats.vigor = 10;

combatant.liveStats = combatant.baseStats;