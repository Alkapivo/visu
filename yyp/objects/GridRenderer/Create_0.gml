
///@description create()

	global.screensFactorValues = [ 0.001, 0.002, 0.003, 0.05, 1 ];
	global.topLinePositionFactorValues = [ 0.001, 0.002, 0.003, 0.05, 1 ];
	global.bottomLinePositionFactorValues = [ 0.001, 0.002, 0.003, 0.05, 1 ];

	#macro DEFAULT_FIELD_MODIFIER_DURATION 1.0

	registerContext(this);
	
	initializeShaderWave(this);
	
	#region Fields
	
	#macro GridRenderer_gridEventPipeline "gridEventPipeline"
	#macro GridRenderer_colorTransformPipeline "colorTransformPipeline"
	
///@public:

	///@type {Boolean}
	enableGridRendering = true;

	///@type {Boolean}
	enableGridElementsRendering = true;
	
	///@type {Boolean}
	enableSeparatorsRenderering = true;
	
	///@type {Boolean}
	enableSurfaceRendering = true;
	
	///@type {Surface}
	gridSurface = createSurface(ViewWidth, ViewHeight, false);
	
	///@type {Surface}
	gridWireSurface = createSurface(ViewWidth, ViewHeight, false);
	
	///@type {Surface}
	gridWireframeSurface = createSurface(ViewWidth, ViewHeight, false);
	
	///@type {Number}
	gridWireframeSurfaceAlpha = 1.0;

	///@type {Surface}
	gridElementSurface = createSurface(ViewWidth, ViewHeight, false);
	
	///@type {PriorityQueue<GridElement>}
	gridElementPipeline = createPriorityQueue();
	
	///@type {Pipeline<GridEvent>}
	gridEventPipeline = generatePipeline(GridRenderer_gridEventPipeline, Stack, GridEvent);
	
	#region Grid Event
	///@type {Number} normalized
	topLineWidth = 0.612;//0.462;//0.712;
	
	///@type {Number} normalized
	topLinePosition = 0.5;
	
	///@type {Number}
	topLinePositionFactor = global.topLinePositionFactorValues[0];

	///@type {Number} normalized
	bottomLineWidth = 0.681;//0.533;//0.786;
	
	///@type {Number} normalized
	bottomLinePosition = 0.5;

	///@type {Number}
	bottomLinePositionFactor = global.bottomLinePositionFactorValues[0];

	///@type {Number}
	channels = 1;
	
	///@type {Number} normalized
	offsetTop = 0.0;
	
	///@type {Number} normalized
	offsetBottom = 0.0;

	///@type {Number} const, normalized
	separatorSpeed = 0.005;
	
	///@type {Number} unit is Hz
	separatorFrameFrequency = 0.33;
	
	///@type {Color}
	colorPrimaryLines = colorHashToColor("#9d23ad");
	
	///@type {Color}
	colorSecondaryLines = colorHashToColor("#a31049");
	
	///@type {Color}
	colorGridBackground = c_black;
	
	///@type {Number}
	primaryLinesWidth = 8.0;
	
	///@type {Number}
	secondaryLinesWidth = 5.0;
	
	///@type {Number} degrees
	angle = 360.0 * 6;
	
	///@type {Number}
	angleFactor = 1.0;
	
	///@type {Number}
	xScale = 0.95;
	
	///@type {Number}
	yScale = 0.95;
	
	///@type {Boolean}
	isGridWheelEnabled = false;
	
	///@type {Boolean}
	isGridFrameCleaned = true;
	
	///@type {Boolean}
	gridWheelSpeed = 0.01;
	
	///@type {Color}
	colorGridWheelTopLeft = colorHashToColor("#ff0000");
	
	///@type {Color}
	colorGridWheelTopRight = colorHashToColor("#6e1037");
	
	///@type {Color}
	colorGridWheelBottomRight = colorHashToColor("#ff0000");
	
	///@type {Color}
	colorGridWheelBottomLeft = colorHashToColor("#1f010a");
	
	///@type {Boolean}
	swingGrid = false;
	
	///@type {Number}
	screens = 1.0;
	
	///@type {Number}
	screensFactor = global.screensFactorValues[0];
	
	///@type {Number}
	verticalScreens = 1.0;
	
	///@type {Number}
	horizontalScreens = 1.0;
	
	///@type {Number}
	wavePulseAmount = 0.0;
	
	///@type {Number}
	wavePulseMinAmount = 20.0;
	
	///@type {Number}
	wavePulseFriction = 2.5;
	
	///@type {Number}
	wavePulseDistortion = 180.0;
	
	///@type {Number}
	wavePulseSpeed = 1.0;
	
	///@type {Number}
	cameraShake = 0.0;
	
	///@type {Number}
	cameraShakeFactor = 0.5;
	
	///@type {Boolean}
	isFlat = false;

	try {
		
		logger("Load \"{0}\" function", LogType.INFO, "visu-default-timeline");
		visuTrackDefaultHandler();
		
		
		var functionName = getPropertyString("base-timeline-function", "visuTrackDefaultHandler");
		var baseTimelineFunction = getAssetIndex(
			functionName,
			AssetScript
		);
		
		logger("Load \"{0}\" base function", LogType.INFO, functionName);
		baseTimelineFunction();
	} catch (exception) {
		
		logger("{0}", LogType.ERROR, exception.message);
		printStackTrace();
	}
	#endregion
	
	#region Grid Event templates
	gridEventTemplates = [
    {
        name: "topLineWidth",
        type: "Number",
        values: [ 0.1, 0.11, 0.12, 0.13, 0.14, 0.2, 0.3, 0.4, 0.8, 0.9 ],
        durations: [ 0.001, 0.002, 0.003, 0.03, 0.05 ]
    },
    {
        name: "bottomLineWidth",
        type: "Number",
        values: [ 0.3, 0.4, 0.5, 0.6, 0.8, 0.9, 0.91, 0.92, 0.94 ],
        durations: [ 0.001, 0.002, 0.003, 0.03, 0.05 ]
    },
    {
        name: "topLinePosition",
        type: "Number",
        values: [ 0.3, 0.33, 0.4, 0.5, 0.5, 0.5, 0.5, 0.6, 0.66, 0.66, 0.7 ],
        durations: [ 0.001, 0.002, 0.003, 0.03, 0.05 ]
    },
    {
        name: "channels",
        type: "Number",
        values: [ 5, 6, 6, 7, 8, 9, 10, 11, 12, 20, 44, 50, 64, 88, 120 ],
        durations: [ 0.001, 0.002, 0.003, 0.03, 0.05 ]
    },
    {
        name: "angle",
        type: "Number",
        values: [ 0, 0, 0, 0, 0, 0, 0, 1, 22, 48, 50, 70, 90, 110, 135, 150, 180, 180, 180, 180, 200, 220, 225, 260, 270, 270, 270, 270, 300, 340, 359, 359, 359],
        durations: [ 0.1, 0.2, 0.3, 0.3, 0.5 ]
    },
    {
        name: "isGridWheelEnabled",
        type: "Boolean",
        values: [ false, false, false, true, true ],
        durations: [ 1 ]
    },
    {
        name: "isGridFrameCleaned",
        type: "Boolean",
        values: [ false, false, true, true, true ],
        durations: [ 1 ]
    },
    {
        name: "gridWheelSpeed",
        type: "Number",
        values: [ 0.01, 0.011, 0.012, 0.02, 0.03, 0.04, 0.05 ],
        durations: [ 0.001, 0.002, 0.003, 0.03, 0.05 ]
    },
	{
        name: "swingGrid",
        type: "Boolean",
        values: [ false, false, true, true, true ],
        durations: [ 1 ]
    },
	{
		name: "verticalScreens",
        type: "Number",
        values: [ 1, 1, 1, 2, 3 ],
        durations: [ 0.003, 0.004, 0.01 ]
    },
	{
		name: "colorGridBackground",
		type: "Number",
		values: [
			c_black,
			colorHashToGMColor("#9A6795"),
			colorHashToGMColor("#371F75"),
			colorHashToGMColor("#8E1550"),
			c_black,
			c_fuchsia,
			colorHashToGMColor("#4B2665"),
			colorHashToGMColor("#83232B"),
			colorHashToGMColor("#142F49"),
			colorHashToGMColor("#988DDE"),
			c_fuchsia,
			colorHashToGMColor("#933F4B"),
			colorHashToGMColor("#000000")
		],
		durations: [ c_white ]
	}
];

	
	#endregion
///@private:

	///@type {Number}
	gridAngle = 0.0;
			
	///@type {Integer}
	separatorFrameTimer = 0;
	
	///@type {Stack<Number>}
	separators = createStack();
	
	///@type {Stack<Number>}
	separatorsBuffer = createStack();
	
	///@type {List<ColorTransformTask>
	colorTransformPipeline = createList();

	///@type {Color[]}
	gridColorWheel = [
		cloneArray(colorGridWheelTopLeft),
		cloneArray(colorGridWheelTopRight),
		cloneArray(colorGridWheelBottomRight),
		cloneArray(colorGridWheelBottomLeft)
	];
	
	///@type {Color[]}
	gridColorWheelTable = [
		colorGridWheelTopLeft,
		colorGridWheelTopRight,
		colorGridWheelBottomRight,
		colorGridWheelBottomLeft
	]
	
	///@type {Integer[]}
	gridColorWheelPointers = [ 1, 2, 3, 0 ];
	
	angleTheta = 0.0;
	
	///@type {Sprite}
	markerGood = createSprite(asset_texture_marker_good, 0.0, 1.0, 1.0, 1.0, 0.0, c_white);
	
	///@type {Sprite}
	markerBad = createSprite(asset_texture_marker_bad, 0.0, 1.0, 1.0, 1.0, 0.0, c_white);
	#endregion
	
	#region Methods
	
	blendModes = [
	    bm_zero,
	    bm_one,
	    bm_src_colour,
	    bm_inv_src_colour,
	    bm_src_alpha,
	    bm_inv_src_alpha,
	    bm_dest_alpha,
	    bm_inv_dest_alpha,
	    bm_dest_colour,
	    bm_inv_dest_colour,
	    bm_src_alpha_sat,
	]

	firstBlendPointer = 1;
	secondBlendPointer = 3;
	blendModesLength = getArrayLength(blendModes);
	
	cameraData = {
		guiX: GuiWidth / 2,
		guiY: GuiHeight / 2,
		zoom: 1.0
	}
	
	playerGridElement = null;
	
	gridEventPipelineDispatcher = method(this, function(pipeline) {
		
		for (var gridEvent = getPipelineFirstElement(pipeline);
			 iteratorFinish(gridEvent);
			 gridEvent = getPipelineNextElement(pipeline)) {
	
			var fields = getGridEventFields(gridEvent);
			if (isDataStructure(fields, Map)) {
				
				var fieldsSize = getMapSize(fields);
				for (var fieldName = mapFirst(fields);
					 iteratorFinish(fieldName);
					 fieldName = mapNext(fields, fieldName)) {

					var fieldModifier = fields[? fieldName];
					if (!isEntity(fieldModifier, FieldModifier)) {

					    logger("Found invalid FieldModifier at index {0}.", LogType.WARNING, index);
						continue;
					}
			
					switch (getFieldModifierType(fieldModifier)) {

						#region Number
					    case "Number":

					        var fieldModifierDuration = getFieldModifierDuration(fieldModifier);
					        fieldModifierDuration = isNumber(fieldModifierDuration) ? 
								fieldModifierDuration : DEFAULT_FIELD_MODIFIER_DURATION;
					
							var fieldModifierValue = getFieldModifierValue(fieldModifier);
							if (isNumber(fieldModifierValue)) {
					
								sendFieldModifierTask(createFieldModifierTask(
									getGridRenderer(), 
									getFieldModifierName(fieldModifier), 
									fieldModifierValue,
									fieldModifierDuration, 
									1, 
									0
								));
							} else {
						
								logger("Found invalid FieldModifier.type Number. { \"value\": \"{0}\" }", LogType.WARNING, getFieldModifierValue(fieldModifier));
							}
					        break;
						#endregion
						#region Color
					    case "Color":

					        var fieldModifierDuration = getFieldModifierDuration(fieldModifier);
					        fieldModifierDuration = isNumber(fieldModifierDuration) ? 
								fieldModifierDuration : DEFAULT_FIELD_MODIFIER_DURATION;
							fieldModifierValue = colorHashToColor(getFieldModifierValue(fieldModifier));
							if (isEntity(fieldModifierValue, Color)) {
					
								sendGridRendererColorTransformTask(
									createColorTransformTask(
										getFieldModifierName(fieldModifier), 
										fieldModifierValue, 
										fieldModifierDuration
									)
								);
							} else {
						
								logger("Found invalid FieldModifier.type Color. { \"value\": \"{0}\" }", LogType.WARNING, getFieldModifierValue(fieldModifier));
							}
					        break;
						#endregion
						#region Boolean
					    case "Boolean":

					        setInstanceVariable(getGridRenderer(), getFieldModifierName(fieldModifier), getFieldModifierValue(fieldModifier));
					        break;
						#endregion
						default:
				
							logger("Found unsupported FieldModifier.type. { \"type\": \"{0}\" }", LogType.WARNING, getFieldModifierType(fieldModifier))
							break;
					}
				}
			}
			
			destroyGridEvent(gridEvent);
		}
	});
	
	preRender = method(this, function() {

		var viewWidth = ViewWidth;
		var viewHeight = ViewHeight;
		var pixelOffsetTop = offsetTop * viewHeight;
		var pixelOffsetBottom = offsetBottom * viewHeight;	
		var pixelTopLineWidth = topLineWidth * viewWidth;
		var pixelBottomLineWidth = bottomLineWidth * viewWidth;
		var lineTopXCenter = viewWidth * topLinePosition;
		var lineTopXBegin = lineTopXCenter - (pixelTopLineWidth * 0.5);
		var lineTopXEnd = lineTopXCenter + (pixelTopLineWidth * 0.5);
		var lineBottomXCenter = viewWidth * bottomLinePosition;
		var lineBottomXBegin = lineBottomXCenter - (pixelBottomLineWidth * 0.5);
		var lineBottomXEnd = lineBottomXCenter + (pixelBottomLineWidth * 0.5);
		var pathYBegin = pixelOffsetTop;
		var pathYEnd = viewHeight - pixelOffsetBottom;
		var gridHeight = viewHeight - pixelOffsetTop - pixelOffsetBottom;
		var gridAngleLeft = gridHeight / (lineTopXCenter - ((viewWidth - pixelBottomLineWidth) * 0.5) - (pixelTopLineWidth * 0.5));
		var gridAngleRight = gridHeight / (viewWidth - lineTopXCenter - ((viewWidth - pixelBottomLineWidth) * 0.5) - (pixelTopLineWidth * 0.5));
		
		#region Surface Target: gridWireframeSurface
		guardSurface(this, gridWireframeSurface, "gridWireframeSurface", viewWidth, viewHeight, false);
		gpuSetSurfaceTarget(gridWireframeSurface);
		if (isGridFrameCleaned) {
			draw_clear_alpha(c_black, 0.0);
		}
		
		if (enableGridRendering) {
	
			#region Top line
			gpuSetColorInScope(isGridWheelEnabled ? COLOR_WHITE : colorPrimaryLines);
			drawLine(
				lineTopXBegin, 
				pixelOffsetTop, 
				lineTopXEnd, 
				pixelOffsetTop,
				primaryLinesWidth);
			#endregion
		
			#region Down line
			gpuSetColorInScope(isGridWheelEnabled ? COLOR_WHITE : colorPrimaryLines);
			drawLine(
				lineBottomXBegin, 
				viewHeight - pixelOffsetBottom, 
				lineBottomXEnd, 
				viewHeight - pixelOffsetBottom,
				primaryLinesWidth);
			#endregion
	
			#region Channels
			gpuSetColorInScope(isGridWheelEnabled ? COLOR_WHITE : colorPrimaryLines);
			var topChannelWidth = pixelTopLineWidth / channels;
			var bottomChannelWidth = pixelBottomLineWidth / channels;
			for (var index = 0; index < channels; index++) {
				drawLine(
					lineTopXBegin + index * topChannelWidth,
					pixelOffsetTop,
					lineBottomXBegin + index * bottomChannelWidth,
					viewHeight - pixelOffsetBottom,
					primaryLinesWidth);
			}
			drawLine(
				lineTopXEnd,
				pixelOffsetTop,
				lineBottomXEnd,
				viewHeight - pixelOffsetBottom,
				primaryLinesWidth);
			#endregion

			#region Separators

			gpuSetColorInScope(isGridWheelEnabled ? COLOR_WHITE : colorSecondaryLines);
				
			#region Separators Timer
			var normalizedFrequency = separatorFrameFrequency * GAME_FPS;
			separatorFrameTimer = incrementTimer(separatorFrameTimer, normalizedFrequency, 1.0);
			if ((separatorFrameTimer == 0.0) ||
				(isStackEmpty(separators))) {
		
				pushStack(separators, sign(separatorSpeed) == 1.0 ? 1.0 / viewHeight : 1.0);
			}
			#endregion
	
			#region Draw separators
			var separatorsSize = getStackSize(separators);
			var verticalProjectionPowerFactor = clamp(1 + gridAngle, 1.0, 2.0);
			repeat (separatorsSize) {
				var separator = popStack(separators);
				separator = fetchMovedVerticalPositionOnGrid(separator, separatorSpeed);

				var separatorProjectedPosition = power(separator, verticalProjectionPowerFactor);
				if ((separator > 0.0) &&
					(separator < 1.0)) {
					pushStack(separatorsBuffer, separator);
					///@bug html5
					//logger("yyyyy {0}  {1}", LogType.DEBUG, separator * 10000, ((separator > 0.0) && (separator < 1.0)))
					var pixelSeparator = separatorProjectedPosition * viewHeight;
					if (enableSeparatorsRenderering) {
						if ((pixelSeparator >= pixelOffsetTop) &&
							(pixelSeparator <= viewHeight - pixelOffsetBottom)) {
							drawLine(
								lineTopXCenter - ((pixelSeparator - pixelOffsetTop) / gridAngleLeft) - (pixelTopLineWidth * 0.5),
								pixelSeparator,
								lineTopXCenter + ((pixelSeparator - pixelOffsetTop) / gridAngleRight) + (pixelTopLineWidth * 0.5),
								pixelSeparator,
								secondaryLinesWidth
							);
						}	
					}
				}
			}
			#endregion
	
			copyStack(separators, separatorsBuffer);
			clearStack(separatorsBuffer);

			#endregion
	
		}
		
		gpuResetSurfaceTarget();
		#endregion
	
		#region Surface Target: gridWireSurface
		guardSurface(this, gridWireSurface, "gridWireSurface", viewWidth, viewHeight, false);
		gpuSetSurfaceTarget(gridWireSurface);
		
		if (wavePulseAmount > wavePulseMinAmount) {
			
			drawClear(COLOR_TRANSPARENT);
			gpuSetShader(shaderWave);
			
				gpuSetShaderUniformFloat(shaderWaveUniformAmount, wavePulseAmount);
				gpuSetShaderUniformFloat(shaderWaveUniformDistortion, wavePulseDistortion);
				gpuSetShaderUniformFloat(shaderWaveUniformSpeed, wavePulseSpeed);
				gpuSetShaderUniformFloat(shaderWaveUniformTime, global.gameplayTimePrecise);
				renderSurface(gridWireframeSurface, 0.0, 0.0, 1.0, 1.0, 0.0, gridWireframeSurfaceAlpha);
			gpuResetShader();
		} else {
			
			drawClear(COLOR_TRANSPARENT);
			renderSurface(gridWireframeSurface, 0.0, 0.0, 1.0, 1.0, 0.0, gridWireframeSurfaceAlpha);
		}
		
		gpuResetSurfaceTarget();
		#endregion
	
		#region Surface Target: gridSurface
		guardSurface(this, gridSurface, "gridSurface", viewWidth, viewHeight, false);
		gpuSetSurfaceTarget(gridSurface);
		
			drawClear(COLOR_TRANSPARENT);
	
			#region Render grid
			if (isGridWheelEnabled) {
		
				#region Transform colors in gridColorWheel
				var gridColorWheelLength = getArrayLength(gridColorWheel);
				for (var index = 0; index < gridColorWheelLength; index++) {
					var colorPointer = gridColorWheelPointers[index];
					if (transformColor(gridColorWheel[@ index], gridColorWheelTable[colorPointer], gridWheelSpeed)) {
						gridColorWheelPointers[index] = colorPointer + 1 > 3 ? 0 : colorPointer + 1;
					}	
				}
				#endregion
		
				#region Destructuring gridColorWheel
				var colors = [
					colorToGMColor(gridColorWheel[0]),
					colorToGMColor(gridColorWheel[1]),
					colorToGMColor(gridColorWheel[2]),
					colorToGMColor(gridColorWheel[3])
				]
				#endregion
		
				drawSurface(gridWireSurface, 0, 0, 1.0, 1.0, 0.0, 1.0, colors);
			} else {
			
				drawSurface(gridWireSurface, 0, 0);
			}
			#endregion
	
			#region GridElement Pipeline
		
			if (enableGridElementsRendering) {
			
				if (keyboard_check_pressed(ord("I"))) {
					firstBlendPointer = clamp(firstBlendPointer + 1, 0, blendModesLength - 1);
					logger("firstBlendPointer {0}", LogType.DEBUG, firstBlendPointer);
				}
				if (keyboard_check_pressed(ord("K"))) {
					firstBlendPointer = clamp(firstBlendPointer- 1, 0, blendModesLength - 1);
					logger("firstBlendPointer {0}", LogType.DEBUG, firstBlendPointer);
				}
					
				if (keyboard_check_pressed(ord("O"))) {
					secondBlendPointer = clamp(secondBlendPointer + 1, 0, blendModesLength - 1);
					logger("secondBlendPointer {0}", LogType.DEBUG, secondBlendPointer);
				}
				if (keyboard_check_pressed(ord("L"))) {
					secondBlendPointer = clamp(secondBlendPointer - 1, 0, blendModesLength - 1);
					logger("secondBlendPointer {0}", LogType.DEBUG, secondBlendPointer);
				}

				var restoreBlendMode = false;
				gpu_set_blendmode_ext(blendModes[firstBlendPointer], blendModes[secondBlendPointer]);
				var dimension = max(viewWidth, viewHeight);
				var gridElementPipelineSize = getPriorityQueueSize(gridElementPipeline);
				for (var index = 0; index < gridElementPipelineSize; index++) {
		
					var gridElement = popMinPriorityQueue(gridElementPipeline);
					
					if (restoreBlendMode) {
						restoreBlendMode = false;
						gpu_set_blendmode_ext(blendModes[firstBlendPointer], blendModes[secondBlendPointer]);
					}
						
					#region Calculate GridElement Coordinates
					var position = getGridElementPosition(gridElement);
					var pathXBegin = (getPositionHorizontal(position) * pixelTopLineWidth) + lineTopXBegin;
					var pathXEnd = (getPositionHorizontal(position) * pixelBottomLineWidth) + lineBottomXBegin;
					var pathLength = getDistanceBetweenCoords(pathXBegin, pathYBegin, pathXEnd, pathYEnd);
					var pathDirection = getAngleBetweenCoords(pathXBegin, pathYBegin, pathXEnd, pathYEnd);
				
					var sprite = getGridElementSprite(gridElement);
					var spriteAsset = getSpriteAssetIndex(sprite);
					var pixelSpriteWidth = getSpriteAssetWidth(spriteAsset);
					var pixelSpriteHeight = getSpriteAssetHeight(spriteAsset);
					var spriteWidth = pixelSpriteWidth / BASE_SCALE_RESOLUTION;
					var spriteHeight = pixelSpriteHeight / BASE_SCALE_RESOLUTION;
					
					if (spriteAsset == asset_sprite_spaceship) {
						restoreBlendMode = true;
						gpu_set_blendmode(bm_normal)
					}
		
					var verticalProjectionPowerFactor = clamp(gridAngle, 0.0, 1.0)		
					var targetScaleFactor = power(position[1], verticalProjectionPowerFactor);
			
					var targetHeight = (spriteHeight * gridHeight) * targetScaleFactor;
					var targetXBegin = pathXBegin + getXOnCircle(pathLength * getPositionVertical(position), pathDirection);
					var targetYBegin = pathYBegin + getYOnCircle(pathLength * getPositionVertical(position), pathDirection);
					var targetXEnd = targetXBegin + getXOnCircle(targetHeight, pathDirection);
					var targetYEnd = targetYBegin + getYOnCircle(targetHeight, pathDirection);
					var targetTopWidth = (
						(lineTopXCenter + ((targetYBegin - pixelOffsetTop) / gridAngleRight) + (pixelTopLineWidth * 0.5)) - 
						(lineTopXCenter - ((targetYBegin - pixelOffsetTop) / gridAngleLeft) - (pixelTopLineWidth * 0.5))) 
						* spriteWidth
					var targetBottomWidth = (
						(lineTopXCenter + ((targetYEnd - pixelOffsetTop) / gridAngleRight) + (pixelTopLineWidth * 0.5)) - 
						(lineTopXCenter - ((targetYEnd - pixelOffsetTop) / gridAngleLeft) - (pixelTopLineWidth * 0.5))) 
						* spriteWidth
					#endregion 
		
					#region Draw GridElement
					var polygon2D = [
					    [ targetXBegin - (targetTopWidth * 0.5),  targetYBegin ],
					    [ targetXBegin + (targetTopWidth * 0.5),  targetYBegin ],
					    [ targetXEnd + (targetBottomWidth * 0.5), targetYEnd   ],
					    [ targetXEnd - (targetBottomWidth * 0.5), targetYEnd   ]
					];
    
					var spriteScale = targetScaleFactor * (1.0 - (offsetTop + offsetBottom));
			
					var verticalPosition = getPositionVertical(getGridElementPosition(gridElement));
					var equation = (gridAngle * 2.0) * power(verticalPosition, 2) - gridAngle + 1.0;
			
					var tempSimpleSpriteScale = position[1] + 0.5;
					var scaleFactor = 0.9;
					var simpleSpriteScale = min(1.0, max(1 + scaleFactor - position[1], 0.0));
					var spriteBlend = c_white;
					if (restoreBlendMode) {
						
						renderTexture(
							asset_texture_spaceship_glow,
							targetXBegin + ((targetXEnd - targetXBegin) / 2.0),
							targetYEnd,
							0,
							simpleSpriteScale,
							simpleSpriteScale,
							1.0
						);
						
						this.cameraData.guiX = targetXBegin + ((targetXEnd - targetXBegin) / 2.0);
						this.cameraData.guiY = targetYEnd;
					}
					
					if (isFlat) {
					
						drawSprite(
							sprite,
							targetXBegin + ((targetXEnd - targetXBegin) / 2.0),
							targetYEnd,
							simpleSpriteScale,
							simpleSpriteScale,
							1.0,
							0.0,
							c_white
						);
					} else {
					
						drawSpritePolygon(
							sprite,
							polygon2D,
							1.0
						);
					}
					#endregion
				}
				gpu_set_blendmode(bm_normal);
			}
			
			#endregion
	
		gpuResetSurfaceTarget();
		#endregion
	
	});
	
	updateBegin = method(this, function() {
		
		try {
			
			this.colorGridBackground = colorToGMColor(this.gridColorWheel[0]);
				
		} catch (exception) {
			logger(exception.message, LogType.ERROR);
			printStackTrace();
		}

		if (mouse_wheel_down()) {
			
			this.xScale -= 0.01;
			this.yScale = xScale
			print("xscale down", xScale);
		}
		
		if (mouse_wheel_up()) {
			
			this.xScale += 0.01;
			this.yScale = xScale;
			print("xscale up", xScale);
		}

		var gameRenderer = getGameRenderer();
		if ((gameRenderer != null) && 
			(getRendererResizeState(gameRenderer) == RendererResizeState.RESIZED)) {
			clearStack(separators);
		}
		
		verticalScreens = screens;
		horizontalScreens = screens;
		angleSwing = 0.0;
		if (swingGrid) {
			angleTheta = incrementTimer(angleTheta, pi * 2, 0.005 * getDeltaTimeValue());
			angleSwing = sin(angleTheta) * 6;
		}
		
		gridAngle = dcos(
			getAngleBetweenCoords(
				0.5 - (bottomLineWidth * 0.5), 
				1.0 - offsetBottom,
				0.5 - (topLineWidth * 0.5),
				offsetTop
			)
		);
		
		#region ColorTransformPipeline reactor
		var destroyColorTransformTasks = [];
		var colorTransformPipelineSize = getListSize(colorTransformPipeline);
		for (var index = 0; index < colorTransformPipelineSize; index++) {
			var	colorTransformTask = colorTransformPipeline[| index];
			var fieldName = getColorTransformTaskFieldName(colorTransformTask);
			var color = instanceVariableExists(id, fieldName) ? getInstanceVariable(id, fieldName) : null;
		
			if (color == null) {
				continue;	
			}
		
			if (transformColor(color, 
				getColorTransformTaskTargetColor(colorTransformTask),
				getColorTransformTaskChangeFactor(colorTransformTask))) {
			
				destroyColorTransformTasks = pushArray(destroyColorTransformTasks, index);
			}
		}
	
		removeItemsFromList(colorTransformPipeline, destroyColorTransformTasks, destroyColorTransformTask);
		#endregion
	
		var key = createInstanceFieldModifierTaskKey(id, "wavePulseAmount");
		var pipeline = getSystemInstanceFieldModifierTaskPipeline();
		if (!mapContains(pipeline, key)) {
			wavePulseAmount = clamp(wavePulseAmount - (wavePulseFriction * getDeltaTimeValue()), 
				wavePulseMinAmount, 512);		
		}

		if (cameraShake > 0) {
			cameraShake = clamp(cameraShake - (cameraShakeFactor * getDeltaTimeValue()), 
				0, BASE_SCALE_RESOLUTION)
		}
		
		gridEventPipelineDispatcher(gridEventPipeline);
		
		#region demo
		if (global.demo) {
		
			var gridEventTimer = injectInstanceVariable(this, "papaj", 0);
			setInstanceVariable(this, "papaj", incrementTimer(gridEventTimer, 4.20))
			if (timerFinished(gridEventTimer)) {
	
				var gridEventFields = createMap();
				var gridEventTemplatesSize = getArrayLength(gridEventTemplates);
				for (var index = 0; index < gridEventTemplatesSize; index++) {
		
					var gridEventTemplate = gridEventTemplates[@ index];
					var isValid = (irandom(100) / 100.0) > 0.3;
					isValid = true;
					if (isValid) {
			
						var fieldModifier = createFieldModifier(
							gridEventTemplate.name,
							gridEventTemplate.type,
							getRandomValueFromArray(gridEventTemplate.values),
							getRandomValueFromArray(gridEventTemplate.durations)
						);
						addToMap(gridEventFields, gridEventTemplate.name, fieldModifier);
						logger("Added {0}", LogType.INFO,
							stringParams(
								"name: {0} type: {1} value: {2} duration: {3}",
								gridEventTemplate.name,
								gridEventTemplate.type,
								getFieldModifierValue(fieldModifier),
								getFieldModifierDuration(fieldModifier)
							)
						);
					}
				}
			
				var appliedTemplates = []
				for (var fieldName = mapFirst(gridEventFields);
					 iteratorFinish(fieldName);
					 fieldName = mapNext(gridEventFields, fieldName)) {
		
					appliedTemplates = pushArray(appliedTemplates, stringParams("{0} - {1}: {2}", fieldName, "value", getFieldModifierValue(gridEventFields[? fieldName])))
				}
				setInstanceVariable(getSceneRenderer(), "__appliedTemplates", appliedTemplates);
			
				if (getMapSize(gridEventFields) > 0) {
		
					var gridEvent = createGridEvent(gridEventFields);
					sendGridEvent(gridEvent);
				} else {
		
					destroyMap(gridEventFields);
				}
			}
		
		}
		#endregion
		
		#region Sewerslvt discord demo
		var gamemakerAfter20YearsIntroducedFunctionKeyword = function(context, fieldName, key, value, isClamp) {
			
			if (keyboard_check(ord(key))) {
			
				var variableValue = getInstanceVariable(context, fieldName);
				var factor = 0.0;
				if (isClamp) {
					factor = clamp(
						0.0,
						variableValue + applyDeltaTime(value),
						1.0
					);
				} else {
					factor = variableValue + applyDeltaTime(value);
				}
				
				logger("Motherfucker: { \"factor\": {0} }", 
					LogType.INFO, variableValue + (sign(value) * applyDeltaTime(value)));
				
				setInstanceVariable(
					context,
					fieldName,
					factor
				);
			}
		}
		var acc = 0.00420;
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "topLineWidth", "T", 1.0 * acc, true);
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "topLineWidth", "G", -1.0 * acc, true);
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "bottomLineWidth", "Y", 1.0 * acc, true);
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "bottomLineWidth", "H", -1.0 * acc, true);
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "angle", "U", 1.0, false);
		gamemakerAfter20YearsIntroducedFunctionKeyword(this, "angle", "J", -1.0, false);
		#endregion
	});
	
	cleanUp = method(this, function() {
		
		deregisterContext(this);
		
		destroySurface(gridSurface);
		destroySurface(gridWireSurface);
		destroySurface(gridWireframeSurface);
		destroySurface(gridElementSurface);
	
		destroyPipeline(gridEventPipeline);
	
		for (var index = 0; index < getPriorityQueueSize(gridElementPipeline); index++) {
			var gridElement = findMaxInPriorityQueue(gridElementPipeline);
			destroyGridElement(gridElement);
		}
		destroyDataStructure(gridElementPipeline, PriorityQueue, "Unable to destroy gridElementPipeline");

		destroyDataStructure(separators, Stack, "Unable to destroy separators stack");
		destroyDataStructure(separatorsBuffer, Stack, "Unable to destroy separatorsBuffer stack");
	
		for (var index = 0; index < getListSize(colorTransformPipeline); index++) {
			var colorTransformTask = colorTransformPipeline[| index];
			destroyColorTransformTask(colorTransformTask);	
		}
		destroyDataStructure(colorTransformPipeline, List, "Unable to destroy colorTransformPipeline");
	});
	
	#endregion
	/*
	class GridRenderer extends Renderer {
		
		prerender: function() { ... },
		updateBegin: function() { ... },
		render: function() { ... }
	}
	*/
	
	
	
