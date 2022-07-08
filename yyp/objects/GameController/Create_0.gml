///@description create()

	#macro TIANANMEN_SQUARE null

	super();
	
	registerSceneController(this);
	
	#region Fields
///@public:

	enableReplay = getPropertyBoolean("GameController.enableReplay", false);

	///@type {?InputHandler}
	inputHandler = createInputHandler(isHandheld() ? TouchInputHandler : KeyboardInputHandler);

	///@type {Number}
	gameplayTime = 0;
	
	///@type {Struct<MidiMatrixController>}
	#region
	
	global.isGameplayStarted = false;
	global.__deaths = 0;
	global.__score = 0;
	global.__launchapdEvents = 0;
	
	function buttonIsEnabled(button) {
		
		var isEnabled = getStructVariable(button, "isEnabled") == true;
		setStructVariable(button, "isEnabled", !isEnabled)
	}
	
	midiMatrixController = createMidiMatrixController(
		createMapFromTupleArray(
			[
			    //top left
			    createTuple(
			        "0x0",
			        {
						displayName: "screens_0x0",
			            keyboardMapping: [ "1", "5"],
			            pressed: function(button, key) {
							
							var screens = 1.0;
							logger("Set screens: {0}", LogType.INFO, screens);
							setScreensTarget(screens);	
			            }
			        }
			    ),
			    createTuple(
			        "1x0",
			        {
						displayName: "screens_0x1",
			            keyboardMapping: [ "2", "5"],
			            pressed: function(button, key) {
							
							var screens = 2.0;
							logger("Set screens: {0}", LogType.INFO, screens);
							setScreensTarget(screens);	
			            }
			        }
			    ),
			    createTuple(
			        "2x0",
			        {
						displayName: "screens_0x2",
			            keyboardMapping: [ "3", "5" ],
			            pressed: function(button, key) {
							
							var screens = 3.0;
							logger("Set screens: {0}", LogType.INFO, screens);
							setScreensTarget(screens);
			            }
			        }
			    ),
			    createTuple(
			        "3x0",
			        {
						displayName: "top-line_0x3",
			            keyboardMapping: [ "4", "5" ],
			            pressed: function(button, key) {
							
							var screens = 4.0;
							logger("Set screens: {0}", LogType.INFO, screens);
							setScreensTarget(screens);
			            }
			        }
			    ),
			    createTuple(
			        "0x1",
			        {
						displayName: "screens_0x1",
			            keyboardMapping: [ "Q", "5" ],
			            pressed: function () {
							
							var previousFactor = getScreensFactor();
							var screenFactor = 0.001;
							logger("Set screens factor: {0}", LogType.INFO, previousFactor, screenFactor);
							setScreensFactor(screenFactor);	
			            }
			        }
			    ),
			    createTuple(
			        "1x1",
			        {
						displayName: "screens_1x1",
			            keyboardMapping: [ "W", "5" ],
			            pressed: function () {
							
							var previousFactor = getScreensFactor();
							var screenFactor = 0.004;
							logger("Set screens factor: {0}", LogType.INFO, previousFactor, screenFactor);
							setScreensFactor(screenFactor);
			            }
			        }
			    ),
			    createTuple(
			        "2x1",
			        {
						displayName: "screens_2x1",
			            keyboardMapping: [ "E", "5" ],
			            pressed: function () {
							
							var previousFactor = getScreensFactor();
							var screenFactor = 0.04;
							logger("Set screens factor: {0}", LogType.INFO, previousFactor, screenFactor);
							setScreensFactor(screenFactor);
			            }
			        }
			    ),
			    createTuple(
			        "3x1",
			        {
						displayName: "empty_0x0",
			            keyboardMapping: [ "R", "5" ],
			            pressed: function () {

							var previousFactor = getScreensFactor();
							var screenFactor = 0.1;
							logger("Set screens factor: {0}", LogType.INFO, previousFactor, screenFactor);
							setScreensFactor(screenFactor);
			            }
			        }
			    ),
			    createTuple(
			        "0x2",
			        {
						displayName: "angle_0x0",
			            keyboardMapping: [ "A", "5" ],
			            pressed: function () {

							var factor = 90;
							var angle = getGridRenderer().angle;
							var target = (sign(angle) * ((angle div 45) * 45)) + factor;
							logger("Set angle target: {0}", LogType.INFO, target);
							setAngleTarget(target);
			            }
			        }
			    ),
			    createTuple(
			        "1x2",
			        {
						displayName: "angle_1x0",
			            keyboardMapping: [ "S", "5" ],
			            pressed: function () {
							
							var factor = -90;
							var angle = getGridRenderer().angle;
							var target = (sign(angle) * ((angle div 45) * 45)) + factor;
							logger("Set angle target: {0}", LogType.INFO, target);
							setAngleTarget(target);
			            }
			        }
			    ),
			    createTuple(
			        "2x2",
			        {
			            keyboardMapping: [ "D", "5" ],
			            pressed: function () {
							
							var factor = 45;
							var angle = getGridRenderer().angle;
							var target = (sign(angle) * ((angle div 45) * 45)) + factor;
							logger("Set angle target: {0}", LogType.INFO, target);
							setAngleTarget(target);
			            }
			        }
			    ),
			    createTuple(
			        "3x2",
			        {
			            keyboardMapping: [ "F", "5" ],
			            pressed: function () {
							
							var factor = -45;
							var angle = getGridRenderer().angle;
							var target = (sign(angle) * ((angle div 45) * 45)) + factor;
							logger("Set angle target: {0}", LogType.INFO, target);
							setAngleTarget(target);
			            }
			        }
			    ),
			    createTuple(
			        "0x3",
			        {
			            keyboardMapping: [ "Z", "5" ],
			            pressed: function () {
							
							var factor = 0.11;
							logger("Set angle factor: {0}", LogType.INFO, factor);
							setAngleFactor(factor);
			            }
			        }
			    ),
			    createTuple(
			        "1x3",
			        {
			            keyboardMapping: [ "X", "5" ],
			            pressed: function () {
							
							var factor = 0.33;
							logger("Set angle factor: {0}", LogType.INFO, factor);
							setAngleFactor(factor);
			            }
			        }
			    ),
			    createTuple(
			        "2x3",
			        {
			            keyboardMapping: [ "C", "5" ],
			            pressed: function () {
							
							var factor = 0.77
							logger("Set angle factor: {0}", LogType.INFO, factor);
							setAngleFactor(factor);
			            }
			        }
			    ),
			    createTuple(
			        "3x3",
			        {
			            keyboardMapping: [ "V", "5" ],
			            pressed: function () {
							
							var factor = 1.61
							logger("Set angle factor: {0}", LogType.INFO, factor);
							setAngleFactor(factor);
			            }
			        }
			    ),

			    //top right
			    createTuple(
			        "4x0",
			        {
			            keyboardMapping: [ "1", "6"],
			            pressed: function () {
							
							var value = !getGridRendererEnableGridRendering()
							logger("Set enable-grid-rendering: {0}", LogType.INFO, value ? "true" : "false");
							setGridRendererEnableGridRendering(value);
			            }
			        }
			    ),
			    createTuple(
			        "5x0",
			        {
			            keyboardMapping: [ "2", "6"],
			            pressed: function () {
							
							logger("Update enableLyricsRenderer", LogType.INFO);
							getLyricsRenderer().enableLyricsRenderer = !getLyricsRenderer().enableLyricsRenderer;
			            }
			        }
			    ),
			    createTuple(
			        "6x0",
			        {
			            keyboardMapping: [ "3", "6" ],
			            pressed: function () {
							
							try {
								
								var eventsRecorder = getGameController().midiMatrixController.eventsRecorder;
								var text = Core.File.read({ withDialog: true });
								var eventsRecording = eventsRecorder.parseRecording(eventsRecorder, text);
								var eventsPlayer = getGameController().midiMatrixController.eventsPlayer;
								eventsPlayer.play(eventsPlayer, eventsRecording);
							} catch(exception) {
								logger(exception.message, LogType.INFO);
								printStackTrace();
							}
			            }
			        }
			    ),
			    createTuple(
			        "7x0",
			        {
			            keyboardMapping: [ "4", "6" ],
			            pressed: function () {
							
							try {
								
								var eventsRecorder = getGameController().midiMatrixController.eventsRecorder;
								if isStruct(eventsRecorder.getCurrentRecording(eventsRecorder)) {
								
									eventsRecorder.stopRecording(eventsRecorder);	
								} else {
								
									eventsRecorder.startRecording(eventsRecorder);	
								}
								
								global.isGameplayStarted = true;
								global.__hackWithRecorder = true;
								getGameController().isGameplayStarted = global.isGameplayStarted;
							} catch(exception) {
								logger(exception.message, LogType.INFO);
								printStackTrace();
							}
			            }
			        }
			    ),
			    createTuple(
			        "4x1",
			        {
			            keyboardMapping: [ "Q", "6" ],
			            pressed: function () {

							var value = !getGridRendererIsGridFrameCleaned();
							logger("Set grid-frame-cleaned: {0}", LogType.INFO, value ? "true" : "false");
							setGridRendererIsGridFrameCleaned(value);
			            }
			        }
			    ),
			    createTuple(
			        "5x1",
			        {
			            keyboardMapping: [ "W", "6" ],
			            pressed: function () {

							var value = !getGridRendererIsGridWheelEnabled();
							logger("Set grid-wheel-enabled: {0}", LogType.INFO, value ? "true" : "false");
							setGridRendererIsGridWheelEnabled(value);
			            }
			        }
			    ),
			    createTuple(
			        "6x1",
			        {
			            keyboardMapping: [ "E", "6" ],
			            pressed: function () {

							/*
							var swingGrid = getInstanceVariable(getGridRenderer(), "swingGrid");
							logger("Set swingGrid: {0}", LogType.INFO, swingGrid ? "true" : "false");
							setInstanceVariable(getGridRenderer(), "swingGrid", !(swingGrid == true));
							*/
							
							var gameplayType = getPlayerManager().gameplayType;
							gameplayType = gameplayType == "bullethell"
								? "platformer"
								: "bullethell";
							setInstanceVariable(getPlayerManager(), "gameplayType", gameplayType);
							
							global.__baseScaleResolution = gameplayType == "bullethell"
								? 3072
								: 2048
							
							var jumbotronEvent = createJumbotronEvent(
								stringParams(
									"  GAME  \n\n>> {0} <<\n\n--------\n",
									string_upper(gameplayType)
								),
								"message",
								2.66
							);
							var gameRenderer = getGameRenderer();
							gameRenderer.jumbotronEvent = jumbotronEvent;
							gameRenderer.jumbotronEventTimer = 0.0;
							
							getGameController().godMode = incrementTimer(getGameController().godMode, getGameController().godModeDuration);
			            }
			        }
			    ),
			    createTuple(
			        "7x1",
			        {
			            keyboardMapping: [ "R", "6" ],
			            pressed: function () {
							
							logger("Remove shader from pipeline main", LogType.INFO);
							popStack(getShaderPipelinePipe(fetchShaderPipelineByName("main")))
			            }
			        }
			    ),
			    createTuple(
			        "4x2",
			        {
			            keyboardMapping: [ "A", "6" ],
			            pressed: function () {

							var topLineWidth = 0.38;
							var bottomLineWidth = 0.39;
							logger("Set topLineWidth: {0}. bottomLineWidth: {1}", LogType.INFO, topLineWidth, bottomLineWidth);
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "topLineWidth", topLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
							
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "bottomLineWidth", bottomLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
			            }
			        }
			    ),
			    createTuple(
			        "5x2",
			        {
			            keyboardMapping: [ "S", "6" ],
			            pressed: function () {
							
							var topLineWidth = 0.47;
							var bottomLineWidth = 0.69;
							logger("Set topLineWidth: {0}. bottomLineWidth: {1}", LogType.INFO, topLineWidth, bottomLineWidth);
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "topLineWidth", topLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
							
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "bottomLineWidth", bottomLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
			            }
			        }
			    ),
			    createTuple(
			        "6x2",
			        {
			            keyboardMapping: [ "D", "6" ],
			            pressed: function () {

							var topLineWidth = 0.75;
							var bottomLineWidth = 0.96;
							logger("Set topLineWidth: {0}. bottomLineWidth: {1}", LogType.INFO, topLineWidth, bottomLineWidth);
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "topLineWidth", topLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
							
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "bottomLineWidth", bottomLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
			            }
			        }
			    ),
			    createTuple(
			        "7x2",
			        {
			            keyboardMapping: [ "F", "6" ],
			            pressed: function () {

							var topLineWidth = 1.0;
							var bottomLineWidth = 1.0;
							logger("Set topLineWidth: {0}. bottomLineWidth: {1}", LogType.INFO, topLineWidth, bottomLineWidth);
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "topLineWidth", topLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
							
							var fieldModifierTask = createFieldModifierTask(getGridRenderer(), "bottomLineWidth", bottomLineWidth, 0.001, 1, 0)
							sendFieldModifierTask(fieldModifierTask);
			            }
			        }
			    ),
			    createTuple(
			        "4x3",
			        {
			            keyboardMapping: [ "Z", "6" ],
			            pressed: function () {
							
							var gridSpeed = 0.001;
							logger("Set gridSpeed to: {0}", LogType.INFO, gridSpeed);
							setInstanceVariable(getGridRenderer(), "separatorSpeed", gridSpeed);
			            }
			        }
			    ),
			    createTuple(
			        "5x3",
			        {
			            keyboardMapping: [ "X", "6" ],
			            pressed: function () {
							
							var gridSpeed = 0.002;
							logger("Set gridSpeed to: {0}", LogType.INFO, gridSpeed);
							setInstanceVariable(getGridRenderer(), "separatorSpeed", gridSpeed);
			            }
			        }
			    ),
			    createTuple(
			        "6x3",
			        {
			            keyboardMapping: [ "C", "6" ],
			            pressed: function () {

							var gridSpeed = 0.005;
							logger("Set gridSpeed to: {0}", LogType.INFO, gridSpeed);
							setInstanceVariable(getGridRenderer(), "separatorSpeed", gridSpeed);
			            }
			        }
			    ),
			    createTuple(
			        "7x3",
			        {
			            keyboardMapping: [ "V", "6" ],
			            pressed: function () {

							var gridSpeed = 0.008;
							logger("Set gridSpeed to: {0}", LogType.INFO, gridSpeed);
							setInstanceVariable(getGridRenderer(), "separatorSpeed", gridSpeed);
			            }
			        }
			    ),

			    //bottom left
			    createTuple(
			        "0x4",
			        {
			            displayName: "Wave",
			            keyboardMapping: [ "1", "7"],
			            pressed: function () {

			                var shaderEvent = createShaderEvent(
								"Mosaic",
								3.6,
								createMap(
									createTuple("amount", [ 96, 1024, 0.8, 0.002 ])
								)
							);
							
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent)
			            }
			        }
			    ),
			    createTuple(
			        "1x4",
			        {
			            keyboardMapping: [ "2", "7"],
			            pressed: function () {

			                var shaderEvent = createShaderEvent(
								"Wave",
								4.2,
								createMap(
									[ "amount", [ 0, 15, 0.05 ] ],
									[ "distortion", [ 7, 60, 0.08 ] ],
									[ "speed", [ 2.1 ] ],
									[ "time",  [ 0, 1000, 0.01 ] ]
								)
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent)
			            }
			        }
			    ),
			    createTuple(
			        "2x4",
			        {
			            keyboardMapping: [ "3", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Revert",
								1.6,
								createMap()
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent)
			            }
			        }
			    ),
			    createTuple(
			        "3x4",
			        {
			            keyboardMapping: [ "4", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Magnify",
								3.3,
								createMap(
									[ "positionX", [ 0.5 ] ],
									[ "positionY", [ 0.5 ] ],
									[ "radius", [ 0.06, 0.70, 0.006 ] ],
									[ "minZoom", [ 0.20, 0.50, 0.002 ] ],
									[ "maxZoom", [ 0.50, 0.9, 0.002] ]
								)
							);
							
							
							
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent)
			            }
			        }
			    ),
			    createTuple(
			        "0x5",
			        {
			            keyboardMapping: [ "Q", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Ripple",
								7.8,
								createMap(
									[ "positionX", 0.5 ],
						            [ "positionY", 0.5 ],
						            [ "amount", [ 1, 160, 0.2 ] ],
						            [ "distortion", 40, 600, 0.16 ],
						            [ "speed", [ 2, 10, 0.001 ] ],
						            [ "time", [ 0, 1000, 0.1 ] ]
								)
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent);
			            }
			        }
			    ),
			    createTuple(
			        "1x5",
			        {
			            keyboardMapping: [ "W", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Wave",
								7.9,
								createMap(
									[ "amount", [ 0, 15, 0.05 ] ],
									[ "distortion", [ 30, 45, 0.04 ] ],
									[ "speed", [ 1.6 ] ],
									[ "time",  [ 0, 1000, 0.01 ] ]
								)
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent);
			            }
			        }
			    ),
			    createTuple(
			        "2x5",
			        {
			            keyboardMapping: [ "E", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Thermal",
								7.4,
								createMap()
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent);
			            }
			        }
			    ),
			    createTuple(
			        "3x5",
			        {
			            keyboardMapping: [ "R", "7" ],
			            pressed: function () {

							var shaderEvent = createShaderEvent(
								"Ripple",
								3.8,
								createMap(
									[ "positionX", 0.5 ],
						            [ "positionY", [ 0.3, 0.8, 0.002 ] ],
						            [ "amount", [ 30, 40, 0.2 ] ],
						            [ "distortion", 40, 400, 0.2 ],
						            [ "speed", [ 1, 5, 0.02 ] ],
						            [ "time", [ 0, 1000, 0.1 ] ]
								)
							);
							logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
							sendShaderEvent(shaderEvent);
			            }
			        }
			    ),
			    createTuple(
			        "0x6",
			        {
			            keyboardMapping: [ "A", "7" ],
			            pressed: function () {

							var spawnMargin = 0.05;
							global.shroomVisuSpawnHorizontalRange = createTuple(0.0 + spawnMargin, 0.25 - spawnMargin);
							logger("Update spawn position");
			            }
			        }
			    ),
			    createTuple(
			        "1x6",
			        {
			            keyboardMapping: [ "S", "7" ],
			            pressed: function () {

							var spawnMargin = 0.05;
							global.shroomVisuSpawnHorizontalRange = createTuple(0.25 + spawnMargin, 0.5 - spawnMargin);
							logger("Update spawn position");
			            }
			        }
			    ),
			    createTuple(
			        "2x6",
			        {
			            keyboardMapping: [ "D", "7" ],
			            pressed: function () {

							var spawnMargin = 0.05;
							global.shroomVisuSpawnHorizontalRange = createTuple(0.5 + spawnMargin, 0.75 - spawnMargin);
							logger("Update spawn position");
			            }
			        }
			    ),
			    createTuple(
			        "3x6",
			        {
			            keyboardMapping: [ "F", "7" ],
			            pressed: function () {

							var spawnMargin = 0.05;
							global.shroomVisuSpawnHorizontalRange = createTuple(0.75 + spawnMargin, 1.0 - spawnMargin);
							logger("Update spawn position");							
			            }
			        }
			    ),
			    createTuple(
			        "0x7",
			        {
			            keyboardMapping: [ "Z", "7" ],
			            pressed: function () {

							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_01,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.006
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: true,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: false,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "1x7",
			        {
			            keyboardMapping: [ "X", "7" ],
			            pressed: function () {
							
							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_02,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: false,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: false,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "2x7",
			        {
			            keyboardMapping: [ "C", "7" ],
			            pressed: function () {
							
							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_03,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: false,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: false,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "3x7",
			        {
			            keyboardMapping: [ "V", "7" ],
			            pressed: function () {

							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_04,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: false,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: true,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),

			    //bottom right
			    createTuple(
			        "4x4",
			        {
			            displayName: "Background",
			            keyboardMapping: [ "1", "8"],
			            pressed: function () {

							var value = 150;
							logger("Send wavePulse: {0}", LogType.INFO, value);
							setInstanceVariable(getGridRenderer(), "wavePulseAmount", value); 
			            }
			        }
			    ),
			    createTuple(
			        "5x4",
			        {
						displayName: "Background",
			            keyboardMapping: [ "2", "8"],
			            pressed: function () {

			                var value = 60;
							logger("Send wavePulse: {0}", LogType.INFO, value);
							setInstanceVariable(getGridRenderer(), "wavePulseAmount", value); 
			            }
			        }
			    ),
			    createTuple(
			        "6x4",
			        {
						displayName: "Background",
			            keyboardMapping: [ "3", "8" ],
			            pressed: function () {

							var value = ceil(getInstanceVariable(getGridRenderer(), "channels"));
							value = clamp(value - 1, 0, 1000);
							logger("Set channels target: {0}", LogType.INFO, value);
							setChannelsTarget(value);	
			            }
			        }
			    ),
			    createTuple(
			        "7x4",
			        {
						displayName: "Background",
			            keyboardMapping: [ "4", "8" ],
			            pressed: function () {

							var value = ceil(getInstanceVariable(getGridRenderer(), "channels"));
							value = clamp(value + 1, 0, 1000);
							logger("Set channels target: {0}", LogType.INFO, value);
							setChannelsTarget(value);						
			            }
			        }
			    ),
			    createTuple(
			        "4x5",
			        {
			            keyboardMapping: [ "Q", "8" ],
			            pressed: function () {

							var color = getGridRenderer().background_color_01;
							logger("Set colorGridBackground to: {0}", LogType.INFO, gmColorToColorHash(color));
							setInstanceVariable(getGridRenderer(), "colorGridBackground", color);
							setInstanceVariable(getGameRenderer(), "background", getRandomValueFromArray([
								createSprite(
									getGridRenderer().background_texture_01, 
									irandom(sprite_get_number(getGridRenderer().background_texture_01)), 
									1.0, 
									1.0, 
									1.0, 
									0.0, 
									c_white
								)
							]));
			            }
			        }
			    ),
			    createTuple(
			        "5x5",
			        {
			            keyboardMapping: [ "W", "8" ],
			            pressed: function () {
							
							var color = getGridRenderer().background_color_02;
							logger("Set colorGridBackground to: {0}", LogType.INFO, gmColorToColorHash(color));
							setInstanceVariable(getGridRenderer(), "colorGridBackground", color);
							setInstanceVariable(getGameRenderer(), "background", getRandomValueFromArray([
								createSprite(
									getGridRenderer().background_texture_02, 
									irandom(sprite_get_number(getGridRenderer().background_texture_02)), 
									1.0, 
									1.0, 
									1.0, 
									0.0, 
									c_white
								)
							]));
							
							

			            }
			        }
			    ),
			    createTuple(
			        "6x5",
			        {
			            keyboardMapping: [ "E", "8" ],
			            pressed: function () {

							var color = getGridRenderer().background_color_03;
							logger("Set colorGridBackground to: {0}", LogType.INFO, gmColorToColorHash(color));
							setInstanceVariable(getGridRenderer(), "colorGridBackground", color);
							setInstanceVariable(getGameRenderer(), "background", getRandomValueFromArray([
								createSprite(
									getGridRenderer().background_texture_03, 
									irandom(sprite_get_number(getGridRenderer().background_texture_03)), 
									1.0, 
									1.0, 
									1.0, 
									0.0, 
									c_white
								)
							]));
			            }
			        }
			    ),
			    createTuple(
			        "7x5",
			        {
			            keyboardMapping: [ "R", "8" ],
			            pressed: function () {

							var color = getGridRenderer().background_color_04;
							logger("Set colorGridBackground to: {0}", LogType.INFO, gmColorToColorHash(color));
							setInstanceVariable(getGridRenderer(), "colorGridBackground", color);
							setInstanceVariable(getGameRenderer(), "background", getRandomValueFromArray([
								createSprite(
									getGridRenderer().background_texture_04, 
									irandom(sprite_get_number(getGridRenderer().background_texture_04)), 
									1.0, 
									1.0, 
									1.0, 
									0.0, 
									c_white
								)
							]));
			            }
			        }
			    ),
			    createTuple(
			        "4x6",
			        {
			            keyboardMapping: [ "A", "8" ],
			            pressed: function () {
							
							global.shroomVisuSpawnHorizontalRange = createTuple(0.0, 1.0);
							logger("Update spawn position");
			            }
			        }
			    ),
			    createTuple(
			        "5x6",
			        {
			            keyboardMapping: [ "S", "8" ],
			            pressed: function () {

							global.shroomVisuSpawnSpeedRange = createPosition(0.002, 0.003);
							logger("Update spawn speed");
			            }
			        }
			    ),
			    createTuple(
			        "6x6",
			        {
			            keyboardMapping: [ "D", "8" ],
			            pressed: function () {
							
							global.shroomVisuSpawnSpeedRange = createPosition(0.006, 0.007);
							logger("Update spawn speed");
			            }
			        }
			    ),
			    createTuple(
			        "7x6",
			        {
			            keyboardMapping: [ "F", "8" ],
			            pressed: function () {
														
							logger("Sending bkt glitch event", LogType.INFO);
							setInstanceVariable(getGameRenderer(), "__isKeyPressed", true);
			            }
			        }
			    ),
			    createTuple(
			        "4x7",
			        {
			            keyboardMapping: [ "Z", "8" ],
			            pressed: function () {

							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_05,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: true,
									bulletFollowPlayer: true,
									slideAwayAfterLanding: false,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "5x7",
			        {
			            keyboardMapping: [ "X", "8" ],
			            pressed: function () {
							
							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_06,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: true,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: false,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "6x7",
			        {
			            keyboardMapping: [ "C", "8" ],
			            pressed: function () {
							
							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_07,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: true,
									bulletFollowPlayer: false,
									slideAwayAfterLanding: true,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    ),
			    createTuple(
			        "7x7",
			        {
			            keyboardMapping: [ "V", "8" ],
			            pressed: function () {

							var horizontalRange = global.shroomVisuSpawnHorizontalRange;
							var from = getTupleKey(horizontalRange) * 100.0;
							var to = getTupleValue(horizontalRange) * 100.0;
							var speedRange = global.shroomVisuSpawnSpeedRange;
							var shroomConfig = {
								texture: getGridRenderer().shroom_texture_08,
								position: createPosition(
									(from + irandom(to - from)) / 100.0,
									0.003
								),
								horizontalSpeed: choose(1, -1) * choose(0.00001, 0.0001),
								verticalSpeed: random_range(getPositionHorizontal(speedRange), getPositionVertical(speedRange)),
								features: {
									isShooting: true,
									bulletFollowPlayer: true,
									slideAwayAfterLanding: true,
								}
							}
							
							logger("Spawn shroom: { x: {0}, y: {1}  }", LogType.INFO, 
								getPositionHorizontal(shroomConfig.position), 
								getPositionVertical(shroomConfig.position), 
								getAssetName(shroomConfig.texture, AssetTexture)
							);
							spawnVisuShroom(shroomConfig)
			            }
			        }
			    )
			]
		)
	);
	#endregion

	///@type {String}
	baseRecording = "{}";
	if (isHtml5()) {
		baseRecording = html5EmbeddedTrackJson();
	} else {
		var base = getPropertyString("base-timeline", "base.json");
		baseRecording = Core.File.read({ path: "data", filename: base, withDialog: false });
	}

	///@type {Struct} 
	gameplayData = {
		shroomCounter: 0,
		respawnCounter: 0,
	}
	
	///@type {Timer}
	godMode = 0.0;
	
	///@type {Number}
	godModeDuration = 3.0;
	
///@private:

	///@type {Number} in seconds
	isGameplayStarted = false;
	
	mouseCounter = 0;
	
	///@type {Boolean}
	isOSTResolved = false;
	
	#endregion
	
	#region Dependencies
	inject(BossManager);
	inject(LyricsRenderer);
	inject(GridRenderer);
	inject(HandheldRenderer);
	inject(ShroomManager);
	inject(BulletManager);
	inject(PlayerManager);
	inject(ShroomEmitterManager);
	inject(GameRenderer);
	
	jsUtilBootComplete(); // hide loading div
	
	pushStack(
		getLyricsRenderer().lyricsTaskPipeline,
		createLyricsEvent(
			global.__lyrics,
			4096, 
			0.11
		)
	);
	#endregion	
	
