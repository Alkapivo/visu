///@description Draw debug overlay

	var handheldRenderer = getHandheldRenderer();
	var screenWidth = isHandheld() ? global.viewWidth : global.guiWidth;
	var screenHeight = isHandheld() ? global.viewHeight : global.guiHeight;
	
	gpu_set_texfilter(true);
	
	guardSurface(id, applicationSurface, "applicationSurface", global.guiWidth, global.guiHeight, true);
	guardSurface(id, screenSurface, "screenSurface", screenWidth, screenHeight, true);
	guardSurface(id, guiSurface, "guiSurface", screenWidth, screenHeight, true);
	guardSurface(id, jumbotronSurface, "jumbotronSurface", screenWidth, screenHeight, true);
	guardSurface(id, gameSurface, "gameSurface", global.viewWidth, global.viewHeight, true);

	#region Draw to guiSurface
	gpuSetSurfaceTarget(guiSurface);
	
	hudDrawClearTimer = incrementTimer(hudDrawClearTimer, 15, 1);
	if (hudDrawClearTimer > 9) {
		drawClear(COLOR_TRANSPARENT);	
	}

	var viewWidth = screenWidth;
	var viewHeight = screenHeight;
	var hudYAnchor = hudLocation == "top" ? 0.14 : 0.86;
	
	#region Score
	var scoreValue = getGameplayScore();
	var scoreValuePositionX = viewWidth - (0.1 * viewWidth);
	var scoreValuePositionY = hudYAnchor * viewHeight;
	
	#region Score title	
	var gridColor = colorToGMColor(getGridRenderer().colorGridWheelTopRight); 
	var positionX = viewWidth - (0.1 * viewWidth);
	var positionY = hudYAnchor * viewHeight;
	var fontSize = screenWidth > 600 ? FontSize.LARGE: FontSize.MEDIUM;
	var font = global.jetbrainsmonoBold[fontSize];
	draw_set_font(font);
	draw_set_halign(fa_right);
	draw_set_valign(fa_bottom);
				
	var text = stringParams("SHROOMS: {0}", global.shroomSize);
	var fontColorTopLeft = c_white;
	var fontColorTopRight= gridColor;
	var fontColorBottomRight = c_white;
	var fontColorBottomLeft = c_fuchsia;
	
	/*
	draw_text_color(
		positionX,
		positionY, 
		text,
		fontColorTopLeft,
		fontColorTopRight,
		fontColorBottomRight,
		fontColorBottomLeft,
		1.0);
	*/
	#endregion
		
	#region Score value
	if (hudDrawClearTimer <= 9) {
		var fontSize = screenWidth > 600 ? FontSize.LARGE: FontSize.MEDIUM;
		var font = global.jetbrainsmonoBold[fontSize];
		draw_set_font(font);
		draw_set_halign(fa_right);
		draw_set_valign(fa_top);
		
		var text = floor(random(9999) + 10000 * random(9));
		var fontColorTopLeft = c_black;
		var fontColorTopRight= c_white;
		var fontColorBottomLeft = c_silver;
		var fontColorBottomRight = c_fuchsia;
		/*
		draw_text_color(
			positionX,
			positionY, 
			text,
			fontColorTopLeft,
			fontColorTopRight,
			fontColorBottomRight,
			fontColorBottomLeft,
			choose(0.2, 0.2, 0.2, 0.3, 0.3, 0.4, 0.5));
			*/
	}
		
	var fontSize = screenWidth > 600 ? FontSize.LARGE: FontSize.MEDIUM;
	var font = global.jetbrainsmonoBold[fontSize];
	draw_set_font(font);
	draw_set_halign(fa_right);
	draw_set_valign(fa_top);
	
	var text = string(getGameplayScore());
	var fontColorTopLeft = colorHashToGMColor("#ff005a");
	var fontColorTopRight= c_white
	var fontColorBottomLeft = c_white;
	var fontColorBottomRight = c_white;
	draw_text_color(
		positionX,
		positionY, 
		text,
		fontColorTopLeft,
		fontColorTopRight,
		fontColorBottomRight,
		fontColorBottomLeft,
		1.0);
	#endregion
		
	#region Previous score value
	if (scoreValue != previousScoreValue) {
		var textWidth = string_width(text);
		var textHeight = string_height(text);
		var positionBegin = createPosition(
			((scoreValuePositionX - textWidth) / viewWidth),
			(scoreValuePositionY / viewHeight));
		var positionEnd = createPosition(
			(scoreValuePositionX / viewWidth),
			((scoreValuePositionY + textHeight) / viewHeight));
		var randomPosition = createPosition(
			positionBegin[0] + (((random(positionEnd[0] - positionBegin[0]) * 1000) / 1000)),
			positionBegin[1] + (((random(positionEnd[1] - positionBegin[1]) * 1000) / 1000)))
		
	}
	previousScoreValue = scoreValue;
	#endregion
		
	#region scoreNotifyEffectPipeline
	var destroyScoreNotifyEffectPipeline = [];
	var scoreNotifyEffectPipelineSize = getListSize(scoreNotifyEffectPipeline);
	for (var index = 0; index < scoreNotifyEffectPipelineSize; index++) {
		var task = scoreNotifyEffectPipeline[| index];

		var text = task[0];
		var time = task[1];
		time = incrementTimer(time, 90);
		var position = task[2];
		var alpha = (90 - time) / 70;
		var positionX = position[0] * viewWidth;
		var positionY = position[1] * viewHeight - (time * (text == "+" ? 1 : -1))
		var font = global.jetbrainsmonoBold[FontSize.LARGE];
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		var fontColorTopLeft = text == "+" ? c_lime : c_red;
		var fontColorTopRight= fontColorTopLeft;
		var fontColorBottomLeft = fontColorTopLeft;
		var fontColorBottomRight = fontColorTopLeft;
		draw_text_color(
			positionX,
			positionY, 
			text,
			fontColorTopLeft,
			fontColorTopRight,
			fontColorBottomRight,
			fontColorBottomLeft,
			alpha);
		
		if (time == 0.0) {
			pushArray(destroyScoreNotifyEffectPipeline, index);	
		}
			
		task[@ 1] = time;
	}
	var destroyScoreNotifyEffectPipelineSize = getArrayLength(destroyScoreNotifyEffectPipeline);
	for (var index = 0; index < destroyScoreNotifyEffectPipelineSize; index++) {
		var scoreNotifyEffectPipelineIndex = destroyScoreNotifyEffectPipeline[index];
		scoreNotifyEffectPipeline[| scoreNotifyEffectPipelineIndex] = null;
	}
	
	if (destroyScoreNotifyEffectPipelineSize > 0) {
		reduceList(scoreNotifyEffectPipeline, null);	
	}
	#endregion
		
	#region HUD: Draw bullets 
	var player = findPlayerByIndex(0);
	if (player != null && hudVisible) {
		var playerState = getVisuPlayerState(player);
		var bullets = getValueFromMap(playerState, "bullets", 0);
		var bulletSprite = global.bulletAsset;
		var bulletSpriteWidth = sprite_get_width(bulletSprite);
		var bulletSpriteTargetWidth = ceil(screenWidth * 0.0833);
		var bulletScale = (bulletSpriteTargetWidth / bulletSpriteWidth) * 0.8;
		for (var index = 0; index < bullets; index++) {
			var bulletXPosition = (screenWidth * 0.08) + ((bulletSpriteWidth * (0.4 * bulletScale)) * index);
			// commented by krulig in favour to next line
			//var bulletYPosition = screenHeight - (screenHeight * 0.12);
			var bulletYPosition = hudYAnchor * viewHeight;
			draw_sprite_ext(
				bulletSprite, 
				0, 
				bulletXPosition, 
				bulletYPosition,
				bulletScale, 
				bulletScale, 
				choose(1, 1, -1) * random(3),
				c_white, 
				1.0);
		}
	}
	#endregion
		
	#endregion
	
	#region Progress bar
	if (enableProgressBar) {
		var currentTime = getGameplayTime();
		var maxTime = 168.5; // hardcoded value
		var percentageTime = clamp(currentTime/maxTime, 0.0, 1.0);
		var barLength = global.guiWidth * 0.8;
		var barThickness = global.guiHeight * 0.04;
		var xAnchor = (global.guiWidth - barLength) / 2.0;
		var yAnchor = (global.guiHeight * 0.1) - (barThickness / 2.0);
		draw_set_alpha(0.6);
		draw_set_color(c_red);
		draw_line_width(
			xAnchor,
			yAnchor,
			xAnchor + (barLength * percentageTime),
			yAnchor,
			barThickness * choose(0.8, 0.9, 1.0, 1.0)
		);
		draw_set_color(c_yellow);
		draw_line_width(
			xAnchor,
			yAnchor,
			xAnchor + (barLength * percentageTime),
			yAnchor,
			0.4 * barThickness * choose(0.8, 0.9, 1.0, 1.0)
		);
		draw_set_color(c_white);
		draw_line_width(
			xAnchor,
			yAnchor,
			xAnchor + (barLength * percentageTime),
			yAnchor,
			0.1 * barThickness * choose(0.8, 0.9, 1.0, 1.0)
		);
		draw_set_alpha(1.0);
		
		var barPointerScale = (barThickness * 2) / sprite_get_width(getSpriteAssetIndex(barPointer))
		drawSprite(barPointer, xAnchor + (barLength * percentageTime), yAnchor,
			barPointerScale,
			barPointerScale,
			1.0,
			270);
	}
	#endregion
	
	gpuResetSurfaceTarget();
	#endregion

	#region Draw to jumbotronSurface
	gpuSetSurfaceTarget(jumbotronSurface);
	if (jumbotronEvent != null) {
		drawClear([ 0.77, 0.0, 0.21, 0.4]); // TODO getJumbotronEventBackgroundColor
		var jumbotronHandlerName = getJumbotronEventHandlerName(jumbotronEvent)
		switch (jumbotronHandlerName) {
			case "message":
				#region
				var gridColor = colorToGMColor(getGridRenderer().colorGridWheelTopLeft); 
				var positionX = 0.5 * screenWidth;
				var positionY = 0.5 * screenHeight;
				var fontSize = screenWidth > 600 ? FontSize.LARGE : FontSize.MEDIUM;
				var font = asset_font_jetbrains_mono_small9
				draw_set_font(font);
				draw_set_halign(fa_middle);
				draw_set_valign(fa_center);
				
				var text = getJumbotronEventMessage(jumbotronEvent);
				var fontColorTopLeft = c_white;
				var fontColorTopRight= gridColor;
				var fontColorBottomRight = c_white;
				var fontColorBottomLeft = c_fuchsia;
				draw_text_color(
					positionX,
					positionY, 
					text,
					fontColorTopLeft,
					fontColorTopRight,
					fontColorBottomRight,
					fontColorBottomLeft,
					1.0);
				#endregion
				break;
			case "scoreboard":
				#region
				var gridColor = colorToGMColor(getGridRenderer().colorGridWheelTopLeft); 
				var positionX = 0.5 * screenWidth;
				var positionY = 0.2 * screenHeight;
				
				var fontSize = screenWidth > 600 ? FontSize.LARGE : FontSize.MEDIUM;
				var font = global.jetbrainsmonoBold[fontSize];
				draw_set_font(font);
				draw_set_halign(fa_middle);
				draw_set_valign(fa_center);
				
				var text = wordwrapString(getJumbotronEventMessage(jumbotronEvent), screenWidth * 0.8, "\n", 1);
				var fontColorTopLeft = c_white;
				var fontColorTopRight= gridColor;
				var fontColorBottomLeft = c_fuchsia;
				var fontColorBottomRight = c_white;
				draw_text_color(
					positionX,
					positionY, 
					text,
					fontColorTopLeft,
					fontColorTopRight,
					fontColorBottomRight,
					fontColorBottomLeft,
					1.0);
				
				var gridColor = colorToGMColor(getGridRenderer().colorGridWheelTopLeft); 
				var positionX = 0.5 * screenWidth;
				var positionY = 0.35 * screenHeight;
				
				var font = global.jetbrainsmonoBold[FontSize.LARGE];
				draw_set_font(font);
				draw_set_halign(fa_middle);
				draw_set_valign(fa_center);
				
				var text = string(getGameplayScore());
				var fontColorTopLeft = c_white;
				var fontColorTopRight= gridColor;
				var fontColorBottomLeft = c_fuchsia;
				var fontColorBottomRight = c_white;
				draw_text_color(
					positionX,
					positionY, 
					text,
					fontColorTopLeft,
					fontColorTopRight,
					fontColorBottomRight,
					fontColorBottomLeft,
					1.0);
				#endregion
				
				jumbotronScoreboardHandler(jumbotronState);
				break;
		}

		var duration = getJumbotronEventDuration(jumbotronEvent);
		jumbotronEventTimer = incrementTimer(jumbotronEventTimer, duration);
		if (timerFinished(jumbotronEventTimer)) {
			jumbotronEventTimer = 0.0;
			jumbotronEvent = createEmptyOptional();
		}
	} else {
		drawClear(COLOR_TRANSPARENT);	
	}

	gpuResetSurfaceTarget();
	#endregion

	#region Draw to screenSurface
	gpuSetSurfaceTarget(screenSurface);
	var verticalScreens = clamp(getGridRenderer().verticalScreens, 1.0, 32.0);
	var verticalScreensSize = ceil(verticalScreens);
	var horizontalScreens = clamp(getGridRenderer().horizontalScreens, 1.0, 32.0);	
	var horizontalScreensSize = ceil(horizontalScreens);
	for (var yIndex = 0; yIndex < verticalScreensSize; yIndex++) {
		for (var xIndex = 0; xIndex < horizontalScreensSize; xIndex++) {
			var applicationSurfaceWidth = round(screenWidth / horizontalScreens);
			var applicationSurfaceHeight = round(screenHeight / verticalScreens);
			drawSurfaceStretched(gameSurface, 
				xIndex * applicationSurfaceWidth,
				yIndex * applicationSurfaceHeight,
				applicationSurfaceWidth,
				applicationSurfaceHeight);
		}
	}
	
	var lyricsRenderer = getLyricsRenderer();
	if (isOptionalPresent(lyricsRenderer)) {
		if (lyricsRenderer.enableLyricsRenderer) {
			var lyricsSurface = lyricsRenderer.lyricsSurface;
			draw_set_alpha(lyricsRenderer.alpha)
			drawSurfaceStretched(lyricsSurface, 0, 0, screenWidth, screenHeight);
			draw_set_alpha(1.0);
		}
	}
	drawSurfaceStretched(guiSurface, 0, 0, screenWidth, screenHeight);
	drawSurfaceStretched(jumbotronSurface, 0, 0, screenWidth, screenHeight);
	gpuResetSurfaceTarget();
	#endregion
	
	#region Draw to applicationSurface
	gpuSetSurfaceTarget(applicationSurface);
	if (enableShaderCRT) {
		
		shaderCRTTimer = incrementTimer(shaderCRTTimer, 10, 1 / GAME_FPS)
		gpuSetShader(shaderCRT);
		gpuSetShaderUniformFloat(shaderCRTUniformEnableScanlines, shaderCRTUniformValueEnableScanlines);
	    gpuSetShaderUniformFloat(shaderCRTUniformSize, screenWidth, screenHeight, screenWidth, screenHeight);
		gpuSetShaderUniformFloat(shaderCRTUniformDistortionAmount, shaderCRTUniformValueDistortionAmount);
		gpuSetShaderUniformFloat(shaderCRTUniformCornerSize, shaderCRTUniformValueCornerSize);
		gpuSetShaderUniformFloat(shaderCRTUniformCornerSmoothness, shaderCRTUniformValueCornerSmoothness);
		gpuSetShaderUniformFloat(shaderCRTUniformBrightness, shaderCRTUniformValueBrightness);
		gpuSetShaderUniformFloat(shaderCRTUniformNoiseSize, shaderCRTUniformValueNoiseSize);
	    gpuSetShaderUniformFloat(shaderCRTUniformTimer, shaderCRTTimer);
			
		if (isHandheld()) {
			var handheldOrientation = getHandheldRendererOrientation(handheldRenderer);
			var handheldBarWidth = getHandheldRendererBarWidth(handheldRenderer);
			var handheldBarHeight = getHandheldRendererBarHeight(handheldRenderer);
			
			switch (handheldOrientation) {
				case ScreenOrientation.HORIZONTAL:
					var screenSurfaceXPosition = handheldBarWidth;
					var screenSurfaceYPosition = 0;
					var screenSurfaceRelativeWidth = global.guiWidth - (2 * handheldBarWidth);
					var screenSurfaceRelativeHeight = global.guiHeight;
					drawSurfaceStretched(screenSurface, 
						screenSurfaceXPosition,
						screenSurfaceYPosition,
						screenSurfaceRelativeWidth,
						screenSurfaceRelativeHeight);
					break;
				case ScreenOrientation.VERTICAL:
					var screenSurfaceXPosition = 0;
					var screenSurfaceYPosition = 0;
					var screenSurfaceRelativeWidth = global.guiWidth;
					var screenSurfaceRelativeHeight = global.guiHeight - handheldBarHeight;
					drawSurfaceStretched(screenSurface, 
						screenSurfaceXPosition,
						screenSurfaceYPosition,
						screenSurfaceRelativeWidth,
						screenSurfaceRelativeHeight);
					break;
			}
		} else {
			
			/*
			var _alpha = draw_get_alpha();
			var factor = 0.037;
			draw_set_alpha(factor);
			draw_rectangle_color(0, 0, GuiWidth, GuiHeight, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(_alpha);
			*/
			//drawSurfaceStretched(screenSurface, getMouseGuiX() - (GuiWidth / 2.0), getMouseGuiY() - (GuiHeight / 2.0), global.guiWidth, global.guiHeight);	
			drawSurfaceStretched(screenSurface, 0, 0, global.guiWidth, global.guiHeight);
		}
		gpuResetShader();
	} else {
		if (isHandheld()) {
			var handheldOrientation = getHandheldRendererOrientation(handheldRenderer);
			var handheldBarWidth = getHandheldRendererBarWidth(handheldRenderer);
			var handheldBarHeight = getHandheldRendererBarHeight(handheldRenderer);
			
			switch (handheldOrientation) {
				case ScreenOrientation.HORIZONTAL:
					var screenSurfaceXPosition = handheldBarWidth;
					var screenSurfaceYPosition = 0;
					var screenSurfaceRelativeWidth = global.guiWidth - (2 * handheldBarWidth);
					var screenSurfaceRelativeHeight = global.guiHeight;
					drawSurfaceStretched(screenSurface, 
						screenSurfaceXPosition,
						screenSurfaceYPosition,
						screenSurfaceRelativeWidth,
						screenSurfaceRelativeHeight);
					break;
				case ScreenOrientation.VERTICAL:
					var screenSurfaceXPosition = 0;
					var screenSurfaceYPosition = 0;
					var screenSurfaceRelativeWidth = global.guiWidth;
					var screenSurfaceRelativeHeight = global.guiHeight - handheldBarHeight;
					drawSurfaceStretched(screenSurface, 
						screenSurfaceXPosition,
						screenSurfaceYPosition,
						screenSurfaceRelativeWidth,
						screenSurfaceRelativeHeight);
					break;
			}
		} else {
			
			/*
			var _alpha = draw_get_alpha();
			var factor = 0.037;
			draw_set_alpha(factor);
			draw_rectangle_color(0, 0, GuiWidth, GuiHeight, c_black, c_black, c_black, c_black, false);
			draw_set_alpha(_alpha);
			*/
			//drawSurfaceStretched(screenSurface, getMouseGuiX() - (GuiWidth / 2.0), getMouseGuiY() - (GuiHeight / 2.0), global.guiWidth, global.guiHeight);	
			drawSurfaceStretched(screenSurface, 0, 0, global.guiWidth, global.guiHeight);
			
			
		}
	}

	if (isHandheld()) {
		var handheldSurface = getHandheldRendererSurface(handheldRenderer);
		drawSurface(handheldSurface, 0, 0);
	}
	
	gpuResetSurfaceTarget();
	#endregion
	
	#region Render applicationSurface
	//gpuSetShader(shaderAbberation);

	bktglitch_activate(GuiWidth, GuiHeight);
	__bktgtlich_pass_uniforms_from_ui();
	/*
	// Quickly setting all parameters at once using a preset
	bktglitch_config_preset(BktGlitchPreset.B);

	// Additional tweaking
	bktglitch_set_jumbleness(0.5);
	bktglitch_set_jumble_speed(2.5);
	bktglitch_set_jumble_resolution(random_range(0.2, 0.4));
	bktglitch_set_jumble_shift(random_range(0.2, 0.4));
	bktglitch_set_channel_shift(0.01);
	bktglitch_set_channel_dispersion(.05);

	// Setting the overall intensity of the effect, adding a bit when the ball bounces.
	bktglitch_set_intensity(0.025);
	*/

		drawSurfaceStretched(applicationSurface, 0, 0, RealWidth, RealHeight);

	// Done with the shader (this is really just shader_reset)!
	bktglitch_deactivate();

	//gpuResetShader();
	#endregion
	
	
	if (global.isGameplayStarted) {
		
		var midiMatrixController = getInstanceVariable(getGameController(), "midiMatrixController");
		if (isStruct(midiMatrixController)) {
	
			var surface = midiMatrixController.surface;
			if (isSurfaceValid(surface)) {
			
				renderSurface(surface);
			}
		}
	
		var midiController = getGameController().midiMatrixController;
		var currentRecording = midiController.eventsRecorder.getCurrentRecording(midiController.eventsRecorder);
		if (isStruct(currentRecording)) {
		
			draw_rectangle_color(
				0.0 + 32,
				RealHeight - 32 - 24,
				0.0 + 32 + 24,
				RealHeight - 32,
				c_fuchsia,
				c_fuchsia,
				c_fuchsia,
				c_fuchsia,
				false
			)
		} else {
	
			draw_set_halign(fa_left);
			draw_set_valign(fa_bottom);
			draw_set_font(font_ibm_ps2thin4);
			var gameplayData = getGameController().gameplayData;
			var text = stringParams(
				"Shroom counter:    {0}\n" +
				"Respawn counter:   {1}\n" +
				"Active shaders:    {2}\n",
				gameplayData.shroomCounter,
				gameplayData.respawnCounter,
				this.shaderPipeCurrentSize
			);
			renderText(text,  32, RealHeight - 32);
		}

		var recording = midiController.eventsPlayer.recording;
		var currentRecording = midiController.eventsRecorder.getCurrentRecording(midiController.eventsRecorder);
		if (isStruct(currentRecording)) {
			recording = currentRecording;	
		}
		if (isStruct(recording)) {
				
			var soundInstanceId = global.__soundInstanceId;
			if (isAudio(soundInstanceId)) {
			
				var currentLength = recording.timer;
				var audioLength = audio_sound_length(soundInstanceId);
				
				var barLength = (GuiWidth / 3);
				
				draw_set_color(c_white);
				draw_set_alpha(0.4);
				drawLine(
					(GuiWidth / 2) - (barLength / 2),
					GuiHeight - 32,
					(GuiWidth / 2) + (barLength / 2),
					GuiHeight - 32,
					1
				);
				
				draw_set_font(font_ibm_ps2thin4);
				draw_set_halign(fa_right);
				draw_set_valign(fa_middle);
				
				var minutes = string(currentLength div 60);
				var seconds = string(currentLength mod 60);
				minutes = string_length(minutes) == 1
					? stringParams("0{0}", minutes) 
					: minutes
				seconds = floor(currentLength mod 60) < 10
					? stringParams("0{0}", seconds) 
					: seconds
				
				renderText(stringParams("{0}:{1}", minutes,seconds), (GuiWidth / 2) - (barLength / 2), GuiHeight - 32);
				
				draw_set_alpha(0.7);
				draw_set_color(c_fuchsia);
				drawLine(
					(GuiWidth / 2) - (barLength / 2),
					GuiHeight - 35,
					(GuiWidth / 2) - (barLength / 2) + (barLength * (currentLength / audioLength)),
					GuiHeight - 35,
					4
				);
				
				draw_set_alpha(1);
			}
		}
	}
	
	if (!global.isGameplayStarted) {
	
		var __color = draw_get_color();
		var __alpha = draw_get_alpha();
	
		draw_set_color(c_black);
		draw_set_alpha(0.9);
		draw_rectangle(0, 0, RealWidth, RealHeight, false);
		
		draw_set_halign(fa_center);
		draw_set_valign(fa_middle);
		draw_set_font(asset_font_jetbrains_mono_small9);
		draw_set_color(choose(c_white, c_white, c_white, c_white, c_white, c_white, c_fuchsia));
		draw_set_alpha(1.0);
		
		// length 30
		                
		var title =		"      Downcasted/Enmity      ";
		var subtitle =	"         Butterflies         ";
		
		var text = stringParams(
			"{0}\n{1}\n\n{2}        {3}\n\n{4}\n{5}",
			title,
			subtitle,
			"MOUSE CLICK TO",
			getRandomValueFromArray([
				"play    ", " play   ", "  play  ", "   play ", "    play"
			]),
			"MOVE:           ARROWS OR WSAD",
			"SHOOT/JUMP:         SPACE OR Z"
		);
		draw_text(
			(RealWidth / 2.0) + irandom(2), 
			(RealHeight / 2.0) + irandom(2), 
			text
		);
		
		draw_set_color(__color);
		draw_set_alpha(__alpha);
	}
	
	//this.bpmController.render(this.bpmController);
	
	
	var cameraData = getGridRenderer().cameraData;
	var circleSize = 32;
	/*
	draw_set_alpha(0.6);
	draw_circle_color(
		cameraData.guiX,
		cameraData.guiY,
		32,
		c_red,
		c_lime,
		true
	);
	draw_circle_color(
		cameraData.guiX,
		cameraData.guiY,
		32 - 2,
		c_fuchsia,
		c_red,
		true
	);
	draw_circle_color(
		cameraData.guiX,
		cameraData.guiY,
		32 - 4,
		c_orange,
		c_blue,
		true
	);
	draw_set_alpha(1.0);
	*/
	
