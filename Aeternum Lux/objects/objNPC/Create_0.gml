/// @desc Init NPC data
event_inherited();


npcActivationRange = 32;
npcSceneData = [
//new scene_dialogue(self.id, "This is a test of the new dialogue handler."),
//new scene_dialogue(global.focusObject, "Wow. This is pretty cool."),
//new scene_dialogue(self.id, "Yeah, it's actually done properly this time."),
//new scene_dialogue(self.id, "This new system will also be useful for combat.", -4),
//new scene_dialogue(self.id, "Oh hey, it's you again."),
//new scene_dialogue(global.focusObject, "Again? You know me?"),
//new scene_dialogue(self.id, "Yeah, this system can handle branching/post-scene dialogue."),
//new scene_dialogue(global.focusObject, "Sounds based.", -8),
new scene_dialogue(self.id, "Oh yeah, we have delays now. I'll talk to you in 5 seconds, after you advance the dialogue."),
//new async_callback(self.id, [new scene_dialogue(self.id, "This works")]),
new scene_delay(5),
new scene_dialogue(self.id, "Pretty cool, right?"),
];

npcScene = new scene_manager(npcSceneData);