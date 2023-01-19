function rotate_point_x(_originX, _originY, _pointX, _pointY, _theta) {
	var _radians = degtorad(_theta);
	var _cos = cos(_radians);
	var _sin = sin(_radians);
	var _yDiff = _pointY - _originY;
	var _xDiff = _pointX - _originX;
	return _cos * _xDiff - _sin * _yDiff + _originX;
	
};

function rotate_point_y(_originX, _originY, _pointX, _pointY, _theta) {
	var _radians = degtorad(_theta);
	var _cos = cos(_radians);
	var _sin = sin(_radians);
	var _yDiff = _pointY - _originY;
	var _xDiff = _pointX - _originX;
	return _sin * _xDiff + _cos * _yDiff + _originY;
	
};


function pathfindToXY(_x, _y) {
	var _pastX = x;
	var _pastY = y;
	var _foundStep = mp_potential_step_object(_x, _y, spdWalk, objCollision); // instance_nearest(_x, _y, objCollision
	if square_distance(_x, _y, x, y) == 0 exit;
	inputDirection = point_direction(_pastX, _pastY, x, y);
	if inputDirection mod 90 == 0 inputDirection += 1;
	inputMagnitude = 1;
	x = _pastX;
	y = _pastY;
};


function pathfindToObj(_obj) {
	if _obj != undefined && combatLiveStates.controlState == controlStates.FOLLOWING {
		pathfindToXY(_obj.x, _obj.y);
	};
};



///// @description Returns whether the x, y coordinates passed overlaps any of the collision layers
///// @param _x The x coordinate to test
///// @param _y The y coordinate to test
//function pointMeetingLayers(_x, _y)
//{
//	var localCollided = false;
	
//	//for (var currLayer = 0; currLayer < array_length(global.collisionLayers); currLayer += 1) {
//	//	var tileSetName = global.collisionTileSets[currLayer];
//	//	var checkerOBJ = asset_get_index(tileSetName);
//	//	if checker == undefined checker = instance_create_depth(0,0,0,checkerOBJ);
//	//	else if !instance_exists(checker) checker = instance_create_depth(0,0,0,checkerOBJ);

//	//	if tile_meeting_precise(_x, _y, global.collisionLayers[currLayer]) {
//	//		localCollided = true;
//	//		break;
//	//	};
//	//	instance_destroy(checker, false);
//	//};

//	return (localCollided || place_meeting(_x, _y, objCollision));
//};



///@description tile_meeting_precise(x,y,layer)
///@param x
///@param y
///@param layer
function tile_meeting_precise()
{
var _layer = argument2,
    _tm = layer_tilemap_get_id(_layer);
 
if(_tm == -1 || layer_get_element_type(_tm) != layerelementtype_tilemap) {
  show_debug_message("Checking collision for non existent layer / tilemap") 
  return false;
}
 
var _x1 = tilemap_get_cell_x_at_pixel(_tm, bbox_left + (argument0 - x), y),
    _y1 = tilemap_get_cell_y_at_pixel(_tm, x, bbox_top + (argument1 - y)),
    _x2 = tilemap_get_cell_x_at_pixel(_tm, bbox_right + (argument0 - x), y),
    _y2 = tilemap_get_cell_y_at_pixel(_tm, x, bbox_bottom + (argument1 - y));
 
for(var _x = _x1; _x <= _x2; _x += 1){
  for(var _y = _y1; _y <= _y2; _y += (bbox_bottom - bbox_top) / 2){
    var _tile = tilemap_get(_tm, _x, _y);
    if(_tile){
      if(_tile == 1) return true;
 
      checker.x = _x * tilemap_get_tile_width(_tm);
      checker.y = _y * tilemap_get_tile_height(_tm);
      checker.image_index = _tile;
 
      if(place_meeting(argument0,argument1,checker))
        return true;
    }
  }
}
 
return false;
};

///@func use_tdmc([place meeting func = place_meeting], [corner slip = 16], [corner slip speed = .5], [sprite catchup factor = .5])
function use_tdmc(
  _placeMeeting = function(_x, _y){
	//return tile_meeting_precise(_x, _y, "Collisions");
    return place_meeting(_x, _y, objCollision); //Replace objWall with your object 
  }, 
  _cornerSlip = 24,
  _slipSpd = .5, 
  _catchupFactor = .5) {
    
  return {
    drawX: id.x,
    drawY: id.y,
    againstWall: { hori: 0, vert: 0 },
    
    __iXSpdLeft: 0,
    __iYSpdLeft: 0,
    __iCornerSlip: _cornerSlip,
    __iCornerSlipSpeedFactor: _slipSpd,
    __iOwner: id,
    __iIgnoreCollision: false,
    __iSpriteCatchupFactor: _catchupFactor,
    
    __iPlaceMeeting: _placeMeeting,
    
    __iCornerSlipVert: function(_dir) {
    	for(var _i = 1; _i <= __iCornerSlip; _i++) {
    		if(!__iPlaceMeeting(__iOwner.x + _dir, __iOwner.y - _i)) return -1;	
        if(!__iPlaceMeeting(__iOwner.x + _dir, __iOwner.y + _i)) return 1;
      }
    	return 0;
    },

    __iCornerSlipHori: function(_dir) {
    	for(var _i = 1; _i <= __iCornerSlip; _i++) {
    		if(!__iPlaceMeeting(__iOwner.x - _i, __iOwner.y + _dir)) return -1;	
        if(!__iPlaceMeeting(__iOwner.x + _i, __iOwner.y + _dir)) return 1;
      }
    	return 0;
    },
    
    __iApproach: function(_start, _target, _step) {
    	if (_start < _target)
    	    return min(_start + _step, _target); 
    	else
    	    return max(_start - _step, _target);
    },
    
    __iUpdateDrawPos: function() {
      drawX = lerp(drawX, __iOwner.x, __iSpriteCatchupFactor);
      drawY = lerp(drawY, __iOwner.y, __iSpriteCatchupFactor);
    },
    
    __iGtfo: function() {
      var _precision = 1; //Feel free to adjust this to be higher. 1 is a bit extreme
      if(!__iPlaceMeeting(__iOwner.x, __iOwner.y)) return;
      var _curRad = _precision;
      var _startX = __iOwner.x;
      var _startY = __iOwner.y;
      while(true) {
        for(var _x = -_curRad; _x <= _curRad; _x += _precision) {
          for(var _y = -_curRad; _y <= _curRad; _y += _precision) {
            if(_x > _curRad && _y > _curRad && _x < _curRad && _y < _curRad) continue;
            __iOwner.x = _startX + _x; 
            __iOwner.y = _startY + _y;
            if(!__iPlaceMeeting(__iOwner.x, __iOwner.y)) {
              show_debug_message("Got the F out after " + string(_curRad / _precision) + " iterations");  
              return;
            }
          }
        }
        _curRad += _precision
      }
    },
    
    ///@func spdDir(speed, direction)
    spdDir: function(_spd, _dir) {
      xSpdYSpd(lengthdir_x(_spd, _dir), lengthdir_y(_spd, _dir))
    },
    
    ///@func xSpdYSpd(x speed, y speed)
    xSpdYSpd: function(_xSpd, _ySpd) {
      __iGtfo();
    	
      againstWall.hori = 0; againstWall.vert = 0;
      
      __iXSpdLeft += _xSpd;
      __iYSpdLeft += _ySpd;
      
      var _againstVert = 0, _againstHori = 0;
      var _timeout = ceil(abs(__iXSpdLeft) + abs(__iYSpdLeft)) * 10;
      var _timeoutTimer = 0;
	    while(abs(__iXSpdLeft) >= 1 || abs(__iYSpdLeft) >= 1) {
    		
        //Hori
        if(abs(__iXSpdLeft) >= 1) {
          var _dir = sign(__iXSpdLeft);
          __iXSpdLeft = __iApproach(__iXSpdLeft, 0, 1);
          if(__iIgnoreCollision || !__iPlaceMeeting(__iOwner.x + _dir, __iOwner.y)) {
            __iOwner.x += _dir;
            _againstHori = 0;
          } else {
            _againstHori = _dir;
            if(!__iPlaceMeeting(__iOwner.x + _dir, __iOwner.y - 1))
              __iYSpdLeft -= 1;
    				else if(!__iPlaceMeeting(__iOwner.x + _dir, __iOwner.y + 1))
    					__iYSpdLeft += 1;
            else
              againstWall.hori = _dir;  
          }
        } 
        
    		//Vert
        if(abs(__iYSpdLeft) >= 1) {
          var _dir = sign(__iYSpdLeft);
          __iYSpdLeft = __iApproach(__iYSpdLeft, 0, 1);
          if(__iIgnoreCollision || !__iPlaceMeeting(__iOwner.x, __iOwner.y + _dir)) {
            __iOwner.y += _dir;
            _againstVert = 0;
          } else {
            _againstVert = _dir;
            if(!__iPlaceMeeting(__iOwner.x - 1, __iOwner.y + _dir))
              __iXSpdLeft -= 1;
    				else if(!__iPlaceMeeting(__iOwner.x + 1, __iOwner.y + _dir))
    					__iXSpdLeft += 1;	
            else
              againstWall.vert = _dir;  
          }
        } 
        _timeoutTimer++;
        if(_timeoutTimer > _timeout) {
          __iXSpdLeft = 0;
          __iYSpdLeft = 0;
          break;  
        }
    	}
      
      //Go around Corners
      if(againstWall.hori != 0 && againstWall.vert == 0) {
          __iYSpdLeft += (__iCornerSlipVert(againstWall.hori) * __iCornerSlipSpeedFactor);
      }
      
      if(againstWall.vert != 0 && againstWall.hori == 0) {
          __iXSpdLeft += (__iCornerSlipHori(againstWall.vert) * __iCornerSlipSpeedFactor);
      }
      
      if(_againstVert != 0 || _againstHori != 0) {
        againstWall.hori = _againstHori;
        againstWall.vert = _againstVert;
      }
      __iUpdateDrawPos();
    }
  }
}