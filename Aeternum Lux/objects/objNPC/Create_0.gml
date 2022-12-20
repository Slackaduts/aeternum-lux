/// @desc Init NPC data
event_inherited();


npcActivationRange = 32;
npcSceneData = [
new scene_dialogue(self.id, "This is a test of the new dialogue handler."),
new scene_dialogue(global.focusObject, "Wow. This is pretty cool."),
new scene_dialogue(self.id, "Yeah, it's actually done properly this time."),
new scene_dialogue(self.id, "This new system will also be useful for combat.", -4),
new scene_dialogue(self.id, "Oh hey, it's you again."),
new scene_dialogue(global.focusObject, "Again? You know me?"),
new scene_dialogue(self.id, "Yeah, this system can handle branching/post-scene dialogue."),
new scene_dialogue(global.focusObject, "Sounds based.", -8),
new scene_dialogue(self.id, "Damn. You're really persistent."),
new scene_dialogue(self.id, "People don't normally come up and continually ask for conversation.", -8),
];

npcScene = new scene_manager(npcSceneData);