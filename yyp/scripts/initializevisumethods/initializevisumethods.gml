function initializeVisuContexts() {

	global.introControllerContext = null;
	global.menuControllerContext = null;
	global.gameControllerContext = null;

	global.audioManagerContext = null;
	global.bossManagerContext = null;
	global.bulletManagerContext = null;
	global.playerManagerContext = null;
	global.shroomManagerContext = null;
	global.shroomEmitterManagerContext = null;
	global.timelineManagerContext = null;
	global.particleManagerContext = null;

	global.handheldRendererContext = null;
	global.gameRendererContext = null;	
	global.gridRendererContext = null;
	global.lyricsRendererContext = null;
}

function initializeVisuEnums() {

enum GridRendererAttributes {
		TOP_LINE_WIDTH,
		TOP_LINE_POSITION,
		BOTTOM_LINE_WIDTH,
		CHANNELS,
		OFFSET_TOP,
		OFFSET_BOTTOM,
		SEPARATOR_SPEED,
		SEPARATOR_FRAME_FREQUENCY,
		PRIMARY_LINES_WIDTH,
		SECONDARY_LINES_WIDTH
	}
	
	enum PlayerStatus {
		INTRO = 0,
		READY = 1,
		OUTRO = 2
	}
	
	enum BulletProducer {
		SHROOM = 0,
		PLAYER = 1,
	}
	
	enum ShroomType {
		DEFAULT = 0,	
	}
	
	enum BossType {
		VISU = 0,
		MID = 1,
	}
	
	enum GridElementInfoType {
		DEFAULT = 0,
		SHROOM = 1,
		RAINBOW = 2,
	}
	
	enum ParticleSystems {
		BACKGROUND = 0,
		FOREGROUND = 1,
	}
	
	enum FadeTypes {
		IN = 0,
		OUT = 1,
	}
	
	enum StarsRenderTypes {
		POINT = 0,
		PARTICLE = 1
	}
	
	enum FontSize {
		SMALL = 0,
		MEDIUM = 1,
		LARGE = 2
	}
}

function initializeVisuException() {

    ///@todo
}

function initializeVisuGlobals() {

	///@type {Number}
	global.shroomSize = 5;
	
	global.isGameplayStarted = false;
	
	global.shroomVisuSpawnHorizontalRange = createTuple(0.0, 1.0);
	global.shroomVisuSpawnSpeedRange = createTuple(0.005, 0.01);
	
	
	global.demo = false;

    ///@todo Remove
	///@type {Boolean}
	global.isHandheldMode = false;

	///@todo Remove
	///@type {FontFace}
	global.jetbrainsmono = [
		asset_font_jetbrains_mono_small,
		asset_font_jetbrains_mono_small,
		asset_font_jetbrains_mono_small
	]
	
	///@todo Remove
	///@type {FontFace}
	global.jetbrainsmonoBold = [
		asset_font_jetbrains_mono_small,
		asset_font_jetbrains_mono_small,
		asset_font_jetbrains_mono_small
	]

	///@todo Remove
	global.gameCounter = 0;
	global.gamepadId = 0;
	global.gameplayTimePrecise = 0;
	
	///@todo Remove
	global.bulletAsset = asset_sprite_joystick_pointer;
	sprite_set_speed(global.bulletAsset, 10, spritespeed_framespersecond);
	
	global.__lyrics = [
		"                                                                                            ",
		"                                                                 ",
		"                                              "
];
	
	global.__deaths = 0;
	global.__score = 0;
	
	global.__GameplayTypes = [
		"platformer",
		"bullethell"
	]
	#macro GameplayTypes global.__GameplayTypes
	
	global.__baseScaleResolution = 2048;
	#macro BASE_SCALE_RESOLUTION global.__baseScaleResolution
}

function initializeVisuMacros() {

	
}

function initializeVisuManagers() {

    var managers = [];
	for (var index = 0; index < getArrayLength(managers); index++) {
	
		var managerPrototype = managers[@ index];
		if (!isEntity(managerPrototype, ManagerPrototype)) {
		
			throwException(
				createException(
					RuntimeException,
					stringParams("Found invalid ManagerPrototype. { \"index\": {0} }", index),
					runtimeExceptionHandler
				)
			)
			continue;
		}
		
		registerManagerPrototype(managerPrototype);
		
		var exception = catchException();
		if (isOptionalPresent(exception)) {
		
			throwException(
				createException(
					RuntimeException,
					stringParams("Unable to register ManagerPrototype. { \"index\": {0} }", index),
					runtimeExceptionHandler
				)
			)
			continue;
		}
	}
}

///@description discord_21:04_15.12.2021
function hardbaSS() {

	print("[{0}] let's talk about sewerslvt", LogType.DEBUG, "@description discord_21:04_15.12.2021");
}
hardbaSS();

