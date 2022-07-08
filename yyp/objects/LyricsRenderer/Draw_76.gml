///@description 

	
	guardSurface(id, lyricsSurface, "lyricsSurface", 
		isHandheld() ? global.viewWidth : global.guiWidth, 
		isHandheld() ? global.viewWidth : global.guiHeight, true);

	
	var colorGridBackground = getInstanceVariable(
		getGridRenderer(), 
		"colorGridBackground"
	);
	var invertedColorGridBackground = colorGridBackground;

	if (isNumber(colorGridBackground)) { // in gamemaker color is a number :)
	
		var red = clamp(255 - color_get_red(colorGridBackground), 0, 255);
		var green = clamp(255 - color_get_green(colorGridBackground), 0, 255);
		var blue = clamp(255 - color_get_blue(colorGridBackground), 0, 255);
		var invertedColorGridBackground = make_color_rgb(red, green, blue);
	}
	
	if (enableLyricsRenderer) {
	
		var repeatSize = 1;
		var length = getListSize(lyricsPipeline)
		var textHorizontalLength = textVerticalMargin + length * textHeight;
		var textVerticalLength = 180;

		gpuSetSurfaceTarget(lyricsSurface);
		drawClear(COLOR_TRANSPARENT);
		gpuSetShader(shaderAbberation);
		draw_set_halign(fa_left);
		draw_set_valign(fa_top);
		var fontSize = global.guiWidth > 600 ? FontSize.MEDIUM : FontSize.SMALL;
		var font = global.jetbrainsmonoBold[fontSize];
		draw_set_font(font);
		draw_set_color(invertedColorGridBackground);
		repeat(repeatSize) {
			for (var index = 0; index < length; index++) {
				var sourceCode = lyricsPipeline[| index];
				var line = sourceCode[0];
				var position = sourceCode[1];
				var maxLineLength = string_length(line);
				if (position >= maxLineLength) {
					position = maxLineLength;
					if (index >= length - 1) {
						durationTimer = incrementTimer(durationTimer, duration, 1 / GAME_FPS);
						if (durationTimer == 0.0) {
							var lgt = getArrayLength(global.__lyrics);
							if (index < lgt - 2) {
								var task = [ global.__lyrics[index + 1], 0];
								ds_list_add(lyricsPipeline, task);
							}
						}
					}
				} else {
					position = position + irandom(2);
					sourceCode[@ 1] = sourceCode[@ 1] + irandom(2);
				}
		
				var text = string_copy(line, 0, position);
				var textYPosition = textVerticalMargin + index * textHeight;
				var offset = textHorizontalLength > textVerticalLength ? textHorizontalLength - textVerticalLength : 0
				var luck = choose(0, 0, 1);
				if (luck == 1) {
					var shakeX = random(2);
					var shakeY = random(2);
					draw_text(
						textHorizontalMargin + shakeX,
						textYPosition - offset + shakeY,
						text
					);	
					
				}
		
				draw_text(
					textHorizontalMargin,
					textYPosition - offset,
					text);	
			}	
		}
		draw_set_alpha(1.0);
		
		gpuResetShader();
		gpuResetSurfaceTarget();
	}
	
