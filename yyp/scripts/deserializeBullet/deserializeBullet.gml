///@function deserializeBullet(jsonString)
///@description Deserialize Bullet from JSON String to Bullet entity.
///@param {String} jsonString
///@return {Bullet} bullet 
///@throws {Exception}
///@generated {2021-08-25T13:56:53.505Z}

function deserializeBullet(jsonString) {

	var jsonObject = decodeJson(jsonString);

	var gridElement = assertNoOptional(getJsonObjectFieldValue(jsonObject, "gridElement", Entity, "GridElement"));
	var angle = assertNoOptional(getJsonObjectFieldValue(jsonObject, "angle"));
	var speedValue = assertNoOptional(getJsonObjectFieldValue(jsonObject, "speedValue"));
	var acceleration = assertNoOptional(getJsonObjectFieldValue(jsonObject, "acceleration"));
	var producer = assertNoOptional(getJsonObjectFieldValue(jsonObject, "producer"));
	var collisionRadius = assertNoOptional(getJsonObjectFieldValue(jsonObject, "collisionRadius"));

	destroyJsonObject(jsonObject);
	
	return createBullet(gridElement, angle, speedValue, acceleration, producer, collisionRadius);
	
}
