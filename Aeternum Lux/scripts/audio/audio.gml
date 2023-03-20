/// @desc Handles the playing of audio for a parent object.
/// @param {real} _maxDist Maximum distance from the parent object that audio from it can still be heard
/// @param {real} _falloffDist Distance from the parent object at which audio volume starts to fall off or decrease
/// @param {constant.AudioFalloff} [_falloffModel]=audio_falloff_linear_distance Audio falloff model to use
function SoundManager(_maxDist, _falloffDist, _falloffModel = audio_falloff_linear_distance) constructor {
	emitter = audio_emitter_create();
	sounds = [];
	playing = false;
	maxDist = _maxDist;
	falloffDist = _falloffDist;
	audio_falloff_set_model(_falloffModel);
	audio_emitter_falloff(emitter, falloffDist, maxDist, 1);


	/**
	 * Updates the status of the manager and the position of the emitter.
	 * @param {id.Instance} [_target]=other Audio target object. Will default to the parent object.
	 */
	static update = function(_target = other) {	
		audio_emitter_position(emitter, _target.x, _target.y, 0);

		var _isPlaying = false;
		for (var _index = 0; _index < array_length(sounds); _index++) {
			var _sound = sounds[_index];
			if !audio_is_playing(_sound) array_delete(sounds, _index, 1);
			else _isPlaying = true;
		};
		
		playing = _isPlaying;
	};
	
	/**
	 * Plays a sound on the emitter.
	 * @param {asset.GMSound} _sound Sound asset to use
	 * @param {bool} [_loop]=false Whether the sound should infinitely loop
	 * @param {real} [_priority]=50 Priority of the sound
	 */
	static play = function(_sound, _loop = false, _priority = 50, _gain = 1, _pitch = 1, _offset = 0) {	
		array_push(sounds, audio_play_sound_on(emitter, _sound, _loop, _priority, _gain, _offset, _pitch));
		playing = true;
	};
	
	/**
	 * Destroys this object and properly frees the sounds and emitter from memory before doing so.
	 */
	static destroy = function() {
		audio_emitter_free(emitter);

		for (var _index = 0; _index < array_length(sounds); _index++) {
			audio_stop_sound(sounds[_index]);
		};
	};
};



/**
 * Plays a sound on the emitter of a particular object.
 * @param {any*} _sound Sound asset to play
 * @param {any*} _target Object to play at
 * @param {bool} [_loop]=false Whether audio should loop infinitely
 * @param {real} [_priority]=50 Priority of the audio, default is 50
 * @param {real} [_gain]=1 Volume of the audio, default is 1
 * @param {real} [_pitch]=1 Pitch of the audio, default is 1
 * @param {real} [_offset]=0 Time offset in seconds the audio should begin playback at, defaults to 0
 * @param {real} [_callbackIndex]=0 Index to go to afterwards, see other function docs on usage
 */
function scene_play_sound(_sound, _target, _loop = false, _priority = 50, _gain = 1, _pitch = 1, _offset = 0, _callbackIndex = 0): scene_callback(_target, _callbackIndex) constructor {	
	sound = _sound;
	loop = _loop;
	priority = _priority;
	gain = _gain;
	pitch = _pitch;
	offset = _offset;
	
	static initialize = function() {
		data.soundManager.play(sound, loop, priority, gain, offset, pitch);
	};
};


/**
 * Plays a sound globally.
 * @param {any*} _sound Sound asset to play
 * @param {bool} [_loop]=false Whether audio should loop infinitely
 * @param {real} [_priority]=50 Priority of the audio, default is 50
 * @param {real} [_gain]=1 Volume of the audio, default is 1
 * @param {real} [_pitch]=1 Pitch of the audio, default is 1
 * @param {real} [_offset]=0 Time offset in seconds the audio should begin playback at, defaults to 0
 * @param {real} [_callbackIndex]=0 Index to go to afterwards, see other function docs on usage
 */
function scene_play_global_sound(_sound, _loop = false, _priority = 50, _gain = 1, _pitch = 1, _offset = 0, _callbackIndex = 0): scene_callback(undefined, _callbackIndex) constructor {
	sound = _sound;
	loop = _loop;
	priority = _priority;
	gain = _gain;
	pitch = _pitch;
	offset = _offset;
	soundIndex = undefined;

	static initialize = function() {
		if soundIndex != undefined && audio_is_playing(soundIndex) audio_stop_sound(soundIndex);
		soundIndex = global.sounds.add_item(audio_play_sound(sound, priority, loop, gain, offset, pitch));
	};
};


function scene_crossfade_global_sound(_name, _time, _sound, _loop = false, _priority = 50, _gain = 1, _pitch = 1, _offset = 0, _callbackIndex = 0): scene_play_global_sound(_sound, _loop, _priority, _gain, _pitch, _offset, _callbackIndex) constructor {
	name = _name;
	time = _time;
	//if variable_struct_exists(global.sounds, string(name)) {
	//	oldSound = global.sounds[$ string(name)];
	//} else oldSound = undefined;
	
	static initialize = function() {
		if variable_struct_exists(global.sounds, string(name)) && global.sounds[$ string(name)] != undefined && audio_is_playing(global.sounds[$ string(name)]) {
			oldSound = global.sounds[$ string(name)];
			audio_sound_gain(oldSound, 0, time * 1000);
			var _callback = call_later(time, time_source_units_seconds, function() {
				audio_stop_sound(oldSound);
				oldSound = undefined;
			}, false);
		};
		
		global.sounds[$ string(name)] = audio_play_sound(sound, priority, loop, 0, offset, pitch);
		audio_sound_gain(global.sounds[$ string(name)], gain, time * 1000);
	};
};


function scene_play_temp_local_sound(_x, _y, _falloffDist, _falloffMax, _sound, _loop = false, _priority = 50, _gain = 1, _pitch = 1, _offset = 0, _callbackIndex = 0): scene_play_global_sound(_sound, _loop, _priority, _gain, _pitch, _offset, _callbackIndex) constructor {
	x = _x;
	y = _y;
	falloffDist = _falloffDist;
	falloffMax = _falloffMax;

	static initialize = function() {
		soundIndex = audio_play_sound_at(sound, x, y, 0, falloffDist, falloffMax, 1, loop, priority, gain, offset, pitch);
	};
	
	static run = function() {
		if soundIndex != undefined && !audio_is_playing(soundIndex) {
			soundIndex = undefined;
			finish();
		};
	};
};


/**
 * Plays a Vinyl sound in a scene.
 * @param {asset.GMSound} _sound Sound asset to play
 * @param {bool} [_loop]=false Whether this sound should loop, defaults to false
 * @param {real} [_gain]=1 Volume, default is 1
 * @param {real} [_pitch]=1 Pitch, default is 1
 * @param {real} [_pan]=1 Pan, default is 1
 * @param {real} [_callbackIndex]=0 Index to go to afterwards, see other function docs on usage
 */
function scene_vinyl_play_sound(_sound, _loop = false, _gain = 1, _pitch = 1, _pan = 1, _callbackIndex = 0): scene_callback(_sound, _callbackIndex) constructor {
	voice = undefined;
	
	static initialize = function(_sound = _sound, _loop = _loop, _gain = _gain, _pitch = _pitch, _pan = _pan) {
		voice = VinylPlay(_sound, _loop, _gain, _pitch, _pan);
	};
	
	static run = function() {
		if !VinylExists(voice) finish();
	};
	
	static reset = function() {
		delete voice;
		voice = undefined;
		completed = false;
	};
};








