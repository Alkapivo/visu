///@description

	var screenWidth = isHandheld() ? global.viewWidth : global.guiWidth;
	var screenHeight = isHandheld() ? global.viewHeight : global.guiHeight;

	guardSurface(id, shaderSurface, "shaderSurface", global.viewWidth, global.viewHeight, true);
	guardSurface(id, gameSurface, "gameSurface", global.viewWidth, global.viewHeight, true);
	guardSurface(id, screenSurface, "screenSurface", screenWidth, screenHeight, true);
	
	#region Draw to gameSurface
	gpuSetSurfaceTarget(gameSurface);
	var gridRenderer = getGridRenderer();
	draw_clear_alpha(gridRenderer.colorGridBackground, 1.0);

	var backgroundScale = RealWidth > RealHeight 
		? RealWidth / getTextureWidth(getSpriteAssetIndex(background)) 
		: RealHeight / getTextureHeight(getSpriteAssetIndex(background)
	);

	drawSprite(
		background,
		RealWidth / 2.0,
		RealHeight / 2.0,
		backgroundScale,
		backgroundScale,
		0.75,
		0.0,
		c_white
	);

	#region Render stars particles
		
	if (gridRenderer != null) {
			
		var spriteNumber = sprite_get_number(asset_sprite_star);
			
		switch (starsRenderType) {
			case StarsRenderTypes.POINT:
			
				var invertedColorGridBackground = c_black;
				var colorGridBackground = getInstanceVariable(
					getGridRenderer(), 
					"colorGridBackground"
				);

				if (isNumber(colorGridBackground)) { // in gamemaker color is a number :)
	
					var red = clamp(255 - color_get_red(colorGridBackground), 0, 255);
					var green = clamp(255 - color_get_green(colorGridBackground), 0, 255);
					var blue = clamp(255 - color_get_blue(colorGridBackground), 0, 255);
					var invertedColorGridBackground = make_color_rgb(red, green, blue);
				}
			
				var intersectPosition = getLinesIntersectionPosition(
					[ gridRenderer.topLinePosition - (gridRenderer.topLineWidth * 0.5), gridRenderer.offsetTop ], 
					[ 0.5 - (gridRenderer.bottomLineWidth * 0.5), 1.0 - gridRenderer.offsetBottom ],
					[ gridRenderer.topLinePosition + (gridRenderer.topLineWidth * 0.5), gridRenderer.offsetTop ], 
					[ 0.5 + (gridRenderer.bottomLineWidth * 0.5), 1.0 - gridRenderer.offsetBottom ]);
							
				for (var index = 0; index < getArrayLength(stars); index++) {
					var star = stars[index];
							
					var starPosition = star[0];
					if (intersectPosition != null) {
						intersectPosition[@ 1] = intersectPosition[1] < -0.5 ? -0.5 : intersectPosition[1];
						var angle = getAngleBetweenPoints(star[0], intersectPosition) + 180;
						starPosition[0] += getXOnCircle(star[1], angle);
						starPosition[1] += getYOnCircle(star[1], angle);
					} else {
						starPosition[1] += 0.001;
					}
					if (starPosition[1] > 1.2) {
						star[3] = 0.2;
						starPosition = createPosition(
							((global.viewWidth * 0.5) + (random((global.viewWidth * 0.2) * 1000) / 1000) * choose(1, -1)) / global.guiWidth,
							(random((global.viewHeight * 0.2) * 1000) / 1000) / global.guiHeight);
					}
					star[0] = starPosition;
					if (star[3] < star[4]) {
						star[3] += 0.004;	
					}
							
					var starSize = star[2];
					var starAlpha = star[3];
					draw_sprite_ext(
						asset_sprite_star, 
						/*
						clamp(
							clamp(spriteNumber * starSize, 0.0, 1.0) -
							clamp(spriteNumber * starAlpha, 0.0, 1.0),
							0.0,
							1.0
						),
						*/
						0,//floor(random(spriteNumber)),
						starPosition[0] * ViewWidth, 
						starPosition[1] * ViewHeight,
						starSize,
						starSize,
						0,
						invertedColorGridBackground,
						starAlpha
					);
							
					stars[index] = star;
				}
				break;
		}
				
	}
	#endregion

	#region Render gridSurface
	var gridSurface = getGridRendererSurface();
	if (isOptionalPresent(gridSurface)) {
		var cameraShake = getGridRenderer().cameraShake;
			
		var xDirection = cos(cameraShake) > 0 ? 1 : -1;
		var yDirection = sin(cameraShake) > 0 ? 1 : -1;
		var xCameraShake = cameraShake > 0 ? 
			(random(cameraShake * 0.7) + (cameraShake * 0.3)) * xDirection :
			0.0;
		var yCameraShake = cameraShake > 0 ?
			(random(cameraShake * 0.7) + (cameraShake * 0.3)) * yDirection :
			0.0;
			
		gpuSetShader(shaderAbberation);
		
		var mousePositionFactor = 0.008;
		mouseXPosition = lerp(mouseXPosition, getMouseGuiX(), mousePositionFactor)
		mouseYPosition = lerp(mouseYPosition, getMouseGuiY(), mousePositionFactor)
		mouseXPosition = GuiWidth / 2.0;
		mouseYPosition = GuiHeight / 2.0;
		
		drawSurface(
			gridSurface,
			xCameraShake + (mouseXPosition - (GuiWidth / 2.0)),
			yCameraShake + (mouseYPosition - (GuiHeight / 2.0)),
			getGridRendererXScale(),
			getGridRendererYScale(),
			getGridRendererAngle() + gridRenderer.angleSwing,
			1.0,
			c_white,
			createPosition(0.5, 0.5));
		gpuResetShader();
	}
	#endregion

	#region Render bossManager.bossSurface
	var bossSurface = getBossManager().bossSurface;
	gpuSetShader(shaderAbberation);
	if (isSurfaceValid(bossSurface)) {
		drawSurface(
			bossSurface,
			0,
			0,
			getGridRendererXScale(),
			getGridRendererYScale(),
			getGridRendererAngle(),
			1.0,
			c_white,
			createPosition(0.5, 0.5));
	}
	gpuResetShader();
	#endregion
			
	gpuResetSurfaceTarget();
			
	#endregion

	#region Draw to shaderSurface
	var shaderPipelinesNamesSize = getListSize(shaderPipelinesNames);
	for (var index = 0; index < shaderPipelinesNamesSize; index++) {
		var shaderPipelineName = shaderPipelinesNames[| index];
		var shaderPipeline = shaderPipelines[? shaderPipelineName];
		
		var pipe = getShaderPipelinePipe(shaderPipeline);
		var buffer = getShaderPipelineBuffer(shaderPipeline);
		
		var pipeSize = getStackSize(pipe);
		for (var taskIndex = 0; taskIndex < pipeSize; taskIndex++) {
			var task = popStack(pipe);
			var state = getShaderTaskState(task);
			var shader = getShaderTaskShader(task);
			var uniformSetter = fetchShaderTaskUniformSetter(shader);
				
			if (uniformSetter != null) {
				
				var alpha = getShaderTaskAlpha(task);
				if (alpha > 0) {						
					// Render shader to texture
					gpuSetSurfaceTarget(shaderSurface);
					drawClear(COLOR_TRANSPARENT);
					gpuSetShader(shader);
						
					runScript(uniformSetter, this, state, gridSurface);
					//renderSurface(gameSurface);
					
					var mousePositionFactor = 0.001;
					mouseXPosition = lerp(mouseXPosition, getMouseGuiX(), mousePositionFactor)
					mouseYPosition = lerp(mouseYPosition, getMouseGuiY(), mousePositionFactor)
					mouseXPosition = GuiWidth / 2.0;
					mouseYPosition = GuiHeight / 2.0;
					
					drawSurface(
						gameSurface,
						xCameraShake + (mouseXPosition - (GuiWidth / 2.0)),
						yCameraShake + (mouseYPosition - (GuiHeight / 2.0)),
						getGridRendererXScale(),
						getGridRendererYScale(),
						0,//getGridRendererAngle() + gridRenderer.angleSwing,
						1.0,
						c_white,
						createPosition(0.5, 0.5)
					);
					
						
					gpuResetShader();
					gpuResetSurfaceTarget();
				} else {						
					gpuSetSurfaceTarget(shaderSurface);
						
					drawClear(COLOR_TRANSPARENT);
					drawSurface(gameSurface, 0, 0);
						
					gpuResetSurfaceTarget();
				}

				// Render texture
				gpuSetSurfaceTarget(gameSurface);
				drawSurface(shaderSurface, 0, 0, 1.0, 1.0, 0.0, alpha, c_white, [ 0.5, 0.5 ]);
				global.shaderPipeLimit = 2;
				if (pipeSize > global.shaderPipeLimit) {
						
					var gridRendererSurface = getGridRendererSurface();
					gpu_set_blendmode(bm_add);
					renderSurface(
						gridRendererSurface, 
						xCameraShake + (mouseXPosition - (GuiWidth / 2.0)),
						yCameraShake + (mouseYPosition - (GuiHeight / 2.0)),
						getGridRendererXScale(),
						getGridRendererYScale(), 
						getGridRendererAngle() + gridRenderer.angleSwing, 
						0.2,
						c_white,
						createPosition(0.5, 0.5)
					);
					gpu_set_blendmode(bm_normal);
				}
				gpuResetSurfaceTarget();
						
				pushStack(buffer, task);	
			}
		}
		
			
		// Push buffer to pipe
		var bufferSize = getStackSize(buffer);
		for (var taskIndex = 0; taskIndex < bufferSize; taskIndex++) {
			var task = popStack(buffer);
			pushStack(pipe, task);	
		}
	}
	#endregion
	
