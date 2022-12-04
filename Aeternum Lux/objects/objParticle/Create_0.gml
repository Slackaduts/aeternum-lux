/// @description Init particle emitter
event_inherited();
partSystem = part_system_create();
emitters = [];
emitter_types = [];

var _p = part_type_create();
var _partSprite = sprSmokeParticle;
var _partSizeFactor = (sprite_width + (bbox_right - bbox_left)) / 2 / sprite_get_width(_partSprite);
var _minSizeFactor = (_partSizeFactor / 2.0) / 1.1;
var _maxSizeFactor = (_partSizeFactor / 1.9) * 1.1;

part_type_sprite(_p, _partSprite, false, false, false);
part_type_life(_p, 35, 35);
part_type_color3(_p, $0021ff, $003fff, $007fff);
part_type_alpha3(_p, 0.3, 0.2, 0.1);
part_type_gravity(_p, 0.1, 90);
part_type_blend(_p, true);
part_type_size(_p, _minSizeFactor, _maxSizeFactor, 0, 0.0025);
part_type_direction(_p, 0, 360, 0, 10);
part_type_speed(_p, 0.1, 0.2, 0, 0);
ptFire = _p;

var _p2 = part_type_create();

part_type_sprite(_p2, sprite_index, false, false, false);
part_type_life(_p2, 20, 40);
part_type_color3(_p2, $ffffff, $ffffff, $ffffff);
part_type_alpha3(_p2, 0.3, 0.2, 0.1);
part_type_gravity(_p2, 0, 0);
part_type_blend(_p2, true);
part_type_size(_p2, 1, 1, 0, 0);
part_type_direction(_p2, 0, 0, 0, 10);
part_type_speed(_p2, 0, 0, 0, 0);
ptResidual = _p2;