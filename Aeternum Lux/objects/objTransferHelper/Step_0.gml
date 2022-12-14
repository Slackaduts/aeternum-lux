/// @desc Non-transfer logic

if skipTransfer {
	//Modify our saved location in the player data to match the desired one
	for (var _index = 0; _index < array_length(global.saveData.partyData); _index++) {
		global.saveData.partyData[_index].x = targetX;
		global.saveData.partyData[_index].y = targetY;
	};
	
	load_player_data();
	instance_destroy(id, true);

};