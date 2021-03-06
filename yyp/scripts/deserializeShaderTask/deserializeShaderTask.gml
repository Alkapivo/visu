///@function deserializeShaderTask(jsonString)
///@description Deserialize ShaderTask from JSON String to ShaderTask entity.
///@param {String} jsonString
///@return {ShaderTask} shaderTask 
///@throws {Exception}
///@generated {2021-08-25T13:56:53.703Z}

function deserializeShaderTask(jsonString) {

	var jsonObject = decodeJson(jsonString);

	var shader = assertNoOptional(getJsonObjectFieldValue(jsonObject, "shader"));
	var countdown = assertNoOptional(getJsonObjectFieldValue(jsonObject, "countdown"));
	var state = assertNoOptional(getJsonObjectFieldValue(jsonObject, "state", Map));
	var alpha = assertNoOptional(getJsonObjectFieldValue(jsonObject, "alpha"));
	var cooldown = assertNoOptional(getJsonObjectFieldValue(jsonObject, "cooldown"));

	destroyJsonObject(jsonObject);
	
	return createShaderTask(shader, countdown, state, alpha, cooldown);
	
}
