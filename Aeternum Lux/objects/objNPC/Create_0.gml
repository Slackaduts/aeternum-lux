/// @desc Init NPC data
event_inherited();
npcSceneData = [
new scene_dialogue(self.id, "This is a test of the new dialogue handler."),
new scene_dialogue(global.focusObject, "Wow. This is pretty cool."),
new scene_dialogue(self.id, "Yeah, it's actually done properly this time."),
new scene_dialogue(self.id, "This new system will also be useful for combat.", -4),
new scene_dialogue(self.id, "Oh hey, it's you again."),
new scene_dialogue(global.focusObject, "Again? You know me?"),
new scene_dialogue(self.id, "Yeah, this system can handle branching/post-scene dialogue."),
new scene_dialogue(global.focusObject, "Based.", -4)
];

npcScene = new scene_manager(npcSceneData);