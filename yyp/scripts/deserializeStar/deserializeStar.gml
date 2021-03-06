///@function deserializeStar(jsonString)
///@description Deserialize Star from JSON String to Star entity.
///@param {String} jsonString
///@return {Star} star 
///@throws {Exception}
///@generated {2021-08-25T13:56:53.810Z}

function deserializeStar(jsonString) {

	var jsonObject = decodeJson(jsonString);

	var position = assertNoOptional(getJsonObjectFieldValue(jsonObject, "position", Entity, "Position"));
	var target = assertNoOptional(getJsonObjectFieldValue(jsonObject, "target", Entity, "Position"));
	var sprite = assertNoOptional(getJsonObjectFieldValue(jsonObject, "sprite", Entity, "Sprite"));
	var speedValue = assertNoOptional(getJsonObjectFieldValue(jsonObject, "speedValue"));
	var scale = assertNoOptional(getJsonObjectFieldValue(jsonObject, "scale"));
	var alpha = assertNoOptional(getJsonObjectFieldValue(jsonObject, "alpha"));

	destroyJsonObject(jsonObject);
	
	return createStar(position, target, sprite, speedValue, scale, alpha);
	
}
