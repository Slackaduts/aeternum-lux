/// @desc Declare NPC variables
event_inherited();

activationRange = 64;
combatant.states.controlState = controlStates.STATIC;
npcScenes = [
//[1, false, cutscene_toggle_movement, [id]],
[1, true, cutscene_dialogue, [id, id, "This is a test of dialogue in the Scene Manager, and for YUI and Scribble."]],
[2, true, cutscene_dialogue, [id, global.focusInstance, "It can handle changes in speaker, although dynamic window placement isn't implemented yet."]],
[3, true, cutscene_dialogue, [id, id, "Damn. This is pretty cool."]],
[4, true, cutscene_dialogue, [id, global.focusInstance, "Yeah, it was a complete pain in the ass."]],
[5, true, cutscene_dialogue, [id, id, "You can say that again..."]],
[6, true, cutscene_dialogue, [id, global.focusInstance, "Soon this'll have speaker name support and party member support as well."]],
[7, true, cutscene_dialogue, [id, id, "Nice."]],
//[9, false, cutscene_toggle_movement, [id]];
];

sceneManager = new scene_manager(npcScenes);
startingScene = 0;
direction = 270;

dataToSave = array_concat(dataToSave, ["sceneManager", "startingScene"])