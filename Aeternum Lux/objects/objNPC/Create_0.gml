/// @desc Init NPC data
event_inherited();


npcActivationRange = 32;
npcSceneData = [
new scene_dialogue(id, "Oh yeah, we have delays now. I'll talk to you in 3 seconds, after you advance the dialogue."),
new scene_delay(3),
new scene_dialogue(id, "Pretty cool, right?"),
];

npcScene = new scene_manager(npcSceneData);