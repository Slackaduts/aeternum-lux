/// @desc Destroy particle system and emitters
part_emitter_destroy_all(partSystem);
part_system_destroy(partSystem);
emitters = [];


VinylEmitterDestroy(soundEmitter);
soundEmitter = undefined;
//soundManager.destroy();