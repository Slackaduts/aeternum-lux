/// @desc Destroy particle system and emitters

part_emitter_destroy_all(partSystem);
part_system_destroy(partSystem);
emitters = [];

soundManager.destroy();