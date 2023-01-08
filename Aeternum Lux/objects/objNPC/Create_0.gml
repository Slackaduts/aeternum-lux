/// @desc Init NPC data
event_inherited();


npcActivationRange = 32;
npcSceneData = [
new scene_dialogue(id, "There is now a system for handling global music, and it can crossfade."),
new scene_dialogue(id, "I'm going to play a sound globally, and in 5 seconds, it'll begin transitioning to another sound."),
new scene_crossfade_global_sound("bgm", 1, sndSineWave1, true),
//new scene_dialogue(id, "Oh yeah, we have timed effects now. I'll talk to you in 5 seconds, after you advance the dialogue."),
//new scene_dialogue(id, "I'll also add some effects to the screen."),
//new async_callback([new scene_timed_ppfx_effects(3, [new pp_mist(true)])]),
//new async_callback([new scene_tween_ppfx_effects(5, 1.5, [new pp_swirl(true, 0, 0), new pp_lens_distortion(true, 0), new pp_chromaber(true, 0)], ["radius", "amount", "intensity"], [0, 0, 0], [1, -1, 35], "EaseIn")]),
new scene_delay(5),
new scene_crossfade_global_sound("bgm", 2, sndSineWave2, true),
new scene_delay(2),
new scene_dialogue(id, "Pretty cool, right?"),
];
//npcSceneData = [
//new scene_dialogue(self.id, "This is a test of the new dialogue handler."),
//new scene_dialogue(global.focusObject, "Wow. This is pretty cool."),
//new scene_dialogue(self.id, "Yeah, it's actually done properly this time."),
//new scene_dialogue(self.id, "This new system will also be useful for combat.", -4),
//new scene_dialogue(self.id, "Oh hey, it's you again."),
//new scene_dialogue(global.focusObject, "Again? You know me?"),
//new scene_dialogue(self.id, "Yeah, this system can handle branching/post-scene dialogue."),
//new scene_dialogue(global.focusObject, "Based.", -4)
//];


npcScene = new scene_manager(npcSceneData);