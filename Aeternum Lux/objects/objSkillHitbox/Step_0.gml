/// @desc Run Scene Pool, check for hit number
scenePool.run();

//Destroy self if we hit the max number of targets hit 
if destroyAfterHits > 0 && array_length(hitInstances) >= destroyAfterHits {
	instance_destroy(id, true);	
};