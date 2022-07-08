///@description

	super();
	
	#region Fields
///@public:
	
	///@description Index is player number
	///@type {List<Player>}
	players = createList();
	
	///@type {String<GameplayTypes>}
	gameplayType = "bullethell";
	
///@private:

	///@type {Position}
	currentPlayerPosition = createPosition(0.0, 0.0);
	
	///@type {Position}
	mousePosition = createPosition(0, 0);
	
	//@type {Number}
	debugMouseSpeed = 0.1;
	
	#endregion
	
	jumpFactor = getPropertyReal("player.jumpFactor", 0.029);
	gravityFactor = getPropertyReal("player.gravityFactor", 0.0011);

	GMObject = {
		create: method(this, function() {
			
			spawnVisuPlayer("main", createInputHandler(KeyboardInputHandler));
		}),
		bullethell: method(this, function(player) {
			
			var playerState = getVisuPlayerState(player);
			var playerGridElement = getVisuPlayerGridElement(player);
			var playerPosition = getGridElementPosition(playerGridElement);
			var inputHandler = getVisuPlayerInputHandler(player);
			var shrooms = getShroomManager().shrooms;
			
			#region Movement
			var keyboardCheckRight = inputHandler != null ? (
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_RIGHT)) || 
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_D))) : false;
			var keyboardCheckLeft = inputHandler != null ? (
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_LEFT)) || 
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_A))) : false;
			var keyboardCheckUp = inputHandler != null ? (
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_UP)) || 
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_W))) : false;
			var keyboardCheckDown = inputHandler != null ? (
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_DOWN)) || 
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_S))) : false;
			var keyboardCheckBomb = getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_X));
			var keyboardCheckSlow = getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_SHIFT));
			
			var horizontalFriction = getValueFromMap(playerState, "horizontalFriction", 0.001);
			var horizontalMaxSpeed = getValueFromMap(playerState, "horizontalMaxSpeed", 0.01);
			var horizontalSpeed = ((keyboardCheckLeft) || (keyboardCheckRight)) ?
				getVisuPlayerHorizontalSpeed(player) + (keyboardCheckLeft ? -1 : 1) * (getValueFromMap(playerState, "horizontalAcceleration", 0.005) * getDeltaTimeValue()) :
				((abs(getVisuPlayerHorizontalSpeed(player)) - horizontalFriction < 0) ? 0 : getVisuPlayerHorizontalSpeed(player) - sign(getVisuPlayerHorizontalSpeed(player)) * horizontalFriction);
			horizontalSpeed = sign(horizontalSpeed) * clamp(abs(horizontalSpeed), 0, horizontalMaxSpeed);
			horizontalSpeed = keyboardCheckSlow == true
				? horizontalSpeed * 0.67
				: horizontalSpeed;
			
			var horizontalPosition = clamp(getPositionHorizontal(playerPosition) + horizontalSpeed, 0.0, 1.0);
			setPositionHorizontal(playerPosition, horizontalPosition);
			setVisuPlayerHorizontalSpeed(player, horizontalSpeed);
      
			var veticalProjectionScale = fetchVerticalProjectionScale(playerPosition[1]);
			var verticalPositionMin = 0.01;
			var verticalPositionMax = 0.80;
			var verticalFriction = getValueFromMap(playerState, "verticalFriction", 0.001) * veticalProjectionScale; 
			var verticalMaxSpeed = getValueFromMap(playerState, "verticalMaxSpeed", 0.01) * veticalProjectionScale; 
			var verticalSpeed = ((keyboardCheckUp) || (keyboardCheckDown)) ?
				getVisuPlayerVerticalSpeed(player) + (keyboardCheckUp ? -1 : 1) * (getValueFromMap(playerState, "verticalAcceleration", 0.005) * veticalProjectionScale * getDeltaTimeValue()) :
				((abs(getVisuPlayerVerticalSpeed(player)) - verticalFriction < 0) ? 0 : getVisuPlayerVerticalSpeed(player) - sign(getVisuPlayerVerticalSpeed(player)) * verticalFriction);
			verticalSpeed = sign(verticalSpeed) * clamp(abs(verticalSpeed), 0, verticalMaxSpeed);
			var verticalSpeed = keyboardCheckSlow == true
				? verticalSpeed * 0.69 
				: verticalSpeed;
			var verticalPosition = clamp(getPositionVertical(playerPosition) + verticalSpeed, verticalPositionMin, verticalPositionMax);
			setPositionVertical(playerPosition, verticalPosition);
			setVisuPlayerVerticalSpeed(player, verticalSpeed);
			#endregion
		
			#region Shooting
			var keyboardCheckAction = inputHandler != null ? (
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_SPACE)) || 
				getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_Z))) : false;
		
			var bulletsCooldown = getValueFromMap(playerState, "bulletsCooldown", 0);
			if ((keyboardCheckAction)
				&& (bulletsCooldown == 0)) {

				bulletsCooldown = 9;
				spawnBullet(createPosition(
						getPositionHorizontal(playerPosition) - 0.015, 
						getPositionVertical(playerPosition)),
					BulletProducer.PLAYER,
					90 + 7
				);
				spawnBullet(createPosition(
						getPositionHorizontal(playerPosition), 
						getPositionVertical(playerPosition)),
					BulletProducer.PLAYER
				);
				spawnBullet(createPosition(
						getPositionHorizontal(playerPosition) + 0.015, 
						getPositionVertical(playerPosition)),
					BulletProducer.PLAYER,
					90 - 7
				);
			}
			
			bulletsCooldown = clamp(bulletsCooldown - applyDeltaTime(1), 0, MAX_NUMBER);
			Core.Collections._Map.set(playerState, "bulletsCooldown", bulletsCooldown);
			#endregion

			#region Collision
			var isCollision = false;
			var shroomsSize = getListSize(shrooms);
			for (var shroomIndex = 0; shroomIndex < shroomsSize; shroomIndex++) {
				var shroom = shrooms[| shroomIndex];
				var shroomGridElement = getShroomGridElement(shroom);
				var shroomGridElementPosition = getGridElementPosition(shroomGridElement);
				isCollision = (shroomGridElementPosition[1] < playerPosition[1]) && checkCirclesCollision( //@todo replace arrays with getters
					shroomGridElementPosition,
					getShroomRadius(shroom),
					playerPosition,
					getVisuPlayerCollisionRadius(player));
				
				if (isCollision) {
					var shroomState = getShroomState(shroom);
					Core.Collections._Map.set(shroomState, "status", "end");
					Core.Collections._Map.set(shroomState, "instantKill", true);
					global.__deaths++;
					continue;
				}
			}
			#endregion
			
			#region Bomb
			var bombTimer = getValueFromMap(playerState, "bombTimer", 0.0);
			var bombTimerDuration = getValueFromMap(playerState, "bombTimerDuration", 3.0);
			if (!timerFinished(bombTimer)) {
			
				bombTimer = incrementTimer(bombTimer, bombTimerDuration);
			}
			
			if ((timerFinished(bombTimer))
				&& (keyboardCheckBomb)) {
				
				bombTimer = incrementTimer(bombTimer, bombTimerDuration);
				getGridRenderer().cameraShake = 64;
				clearList(getShroomManager().shrooms);
				
				var gameController = getGameController();
				gameController.godMode = incrementTimer(gameController.godMode, gameController.godModeDuration);
				
				var shaderEvent = createShaderEvent(
					"Magnify",
					bombTimerDuration,
					createMap(
						[ "positionX", [ 0.5 ] ],
						[ "positionY", [ 0.5 ] ],
						[ "radius", [ 0.06, 0.70, 0.007 ] ],
						[ "minZoom", [ 0.16, 0.41, 0.002 ] ],
						[ "maxZoom", [ 0.41, 0.8, 0.002] ]
					)
				);
				logger("Sending shaderEvent: {0}", LogType.INFO, getShaderEventName(shaderEvent));
				sendShaderEvent(shaderEvent)
			}
			
			Core.Collections._Map.set(playerState, "bombTimer", bombTimer);
			#endregion
			
			sendGridElementRenderRequest(playerGridElement);
		}),
		platformer: method(this, function(player) {
			
			var playerState = getVisuPlayerState(player);
			var playerGridElement = getVisuPlayerGridElement(player);
			var playerPosition = getGridElementPosition(playerGridElement);
			var inputHandler = getVisuPlayerInputHandler(player);
			var shrooms = getShroomManager().shrooms;
			var input = {
				keyboardCheckRight: inputHandler != null ? (
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_RIGHT)) || 
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_D))) : false,
				keyboardCheckLeft: inputHandler != null ? (
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_LEFT)) || 
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_A))) : false,
				keyboardCheckUp: inputHandler != null ? (
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_UP)) || 
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_W))) : false,
				keyboardCheckDown: inputHandler != null ? (
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_DOWN)) || 
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_S))) : false,
				keyboardCheckAction: inputHandler != null ? (
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_UP)) || 
					getKeyStateCheck(getInputHandlerKeyState(inputHandler, KeyboardKeyType.KEY_SPACE))) : false			
			}
					
			var horizontalPosition = getPositionHorizontal(playerPosition);
			var horizontalFriction = getValueFromMap(playerState, "horizontalFriction", 0.001);
			var horizontalMaxSpeed = getValueFromMap(playerState, "horizontalMaxSpeed", 0.01);
			var horizontalSpeed = ((input.keyboardCheckLeft) || (input.keyboardCheckRight)) ?
				getVisuPlayerHorizontalSpeed(player) + (input.keyboardCheckLeft ? -1 : 1) * (getValueFromMap(playerState, "horizontalAcceleration", 0.005) * getDeltaTimeValue()) :
				((abs(getVisuPlayerHorizontalSpeed(player)) - horizontalFriction < 0) ? 0 : getVisuPlayerHorizontalSpeed(player) - sign(getVisuPlayerHorizontalSpeed(player)) * horizontalFriction);
			horizontalSpeed = sign(horizontalSpeed) * clamp(abs(horizontalSpeed), 0, horizontalMaxSpeed);
			var horizontalPosition = clamp(getPositionHorizontal(playerPosition) + horizontalSpeed, 0.0, 1.0);
			setPositionHorizontal(playerPosition, horizontalPosition);
			setVisuPlayerHorizontalSpeed(player, horizontalSpeed);
			
			//var gridSpeed = getInstanceVariable(getGridRenderer(), "separatorSpeed") / 0.008; //@todo remove magic number
			
			var verticalPosition = getPositionVertical(playerPosition);
			var verticalSpeed = getVisuPlayerVerticalSpeed(player);
			var verticalSpeedMax = 1.0;
			var _gravityFactor = applyDeltaTime(gravityFactor);
			
			verticalSpeed += _gravityFactor;
			verticalSpeed = sign(verticalSpeed) * clamp(abs(verticalSpeed), 0.0, verticalSpeedMax);
			var verticalPositionMin = -0.12;
			var verticalPositionMax = 0.80;
			verticalPosition = clamp(verticalPosition + verticalSpeed, verticalPositionMin, verticalPositionMax);
			verticalSpeed = verticalPosition == verticalPositionMin ? 0.0 : verticalSpeed;
			verticalSpeed = verticalPosition == verticalPositionMax ? 0.0 : verticalSpeed;
			setVisuPlayerVerticalSpeed(player, verticalSpeed);
			
			var movedVerticalPosition = fetchMovedVerticalPositionOnGrid(
				verticalPosition, 
	 			verticalSpeed
			);
			setPositionVertical(playerPosition, movedVerticalPosition);
			
			
			if ((input.keyboardCheckAction)
				&& (verticalPosition >= verticalPositionMax)) {

				setVisuPlayerVerticalSpeed(player, -jumpFactor);
				Core.Collections._Map.set(playerState, "doubleJump", true);
				Core.Collections._Map.set(playerState, "doubleJumpReleased", false);
			}
			
			var doubleJump = Core.Collections._Map.get(playerState, "doubleJump");
			var doubleJumpReleased = Core.Collections._Map.get(playerState, "doubleJumpReleased");
			if (doubleJump) {
			
				if (input.keyboardCheckAction) {
				
					if (doubleJumpReleased) {
					
						setVisuPlayerVerticalSpeed(player, -jumpFactor);
						setInMap(playerState, "doubleJump", false);
					}
				} else {
				
					doubleJumpReleased = true;
					Core.Collections._Map.set(playerState, "doubleJumpReleased", doubleJumpReleased);
				}
			}
			
			var isCollision = false;
			var shroomsSize = getListSize(shrooms);
			for (var shroomIndex = 0; shroomIndex < shroomsSize; shroomIndex++) {
				var shroom = shrooms[| shroomIndex];
				var shroomGridElement = getShroomGridElement(shroom);
				var shroomGridElementPosition = getGridElementPosition(shroomGridElement);
				isCollision = checkCirclesCollision(
					shroomGridElementPosition,
					getShroomRadius(shroom),
					playerPosition,
					getVisuPlayerCollisionRadius(player)
				);
				
				if ((verticalSpeed >= 0.0)
					&& (isCollision)) {
					
					var stayOnShroom = function(player, shroom, playerState, jumpFactor, input) {
						
						var playerGridElement = getVisuPlayerGridElement(player);
						var playerPosition = getGridElementPosition(playerGridElement)
						var speedValue = getShroomSpeedValue(shroom);
						var gridSpeed = getInstanceVariable(getGridRenderer(), "separatorSpeed");
						speedValue = speedValue * (gridSpeed / 0.005);
									
						setVisuPlayerVerticalSpeed(player, 0.0);
						Core.Collections._Map.set(playerState, "landedOnShroom", true);
						
						Core.Collections._Map.set(getShroomState(shroom), "playerLanded", true);
						
						var shroomHorizontalSpeed = Core.Collections._Map.get(getShroomState(shroom), "horizontalSpeed");
						var movedHorizontalPosition = getPositionHorizontal(playerPosition) + applyDeltaTime(shroomHorizontalSpeed);
						setPositionHorizontal(playerPosition, movedHorizontalPosition);
						
						var calcVerticalPosition = getPositionVertical(playerPosition)
							+ ((getPositionVertical(getGridElementPosition(getShroomGridElement(shroom))) - getPositionVertical(playerPosition))
								/ 1.33)
						var movedVerticalPosition = fetchMovedVerticalPositionOnGrid(
							calcVerticalPosition,
				 			speedValue 
						);
						setPositionVertical(playerPosition, movedVerticalPosition);
						
						if (input.keyboardCheckAction) {
							///@todo shroom.kill();
							var shroomState = getShroomState(shroom);
							Core.Collections._Map.set(shroomState, "status", "end");
							Core.Collections._Map.set(shroomState, "instantKill", true);
					
							///@todo player.jump(factor);
							setVisuPlayerVerticalSpeed(player, -1.0 * jumpFactor);
							Core.Collections._Map.set(playerState, "doubleJump", true);
							Core.Collections._Map.set(playerState, "doubleJumpReleased", false);
							
						}
						
						if (input.keyboardCheckDown) {
							
							///@todo shroom.kill();
							var shroomState = getShroomState(shroom);
							Core.Collections._Map.set(shroomState, "status", "end");
							Core.Collections._Map.set(shroomState, "instantKill", true);
						}
					}
					
					//killAndDoubleJump(player, shroom, playerState, jumpFactor);
					stayOnShroom(player, shroom, playerState, jumpFactor, input);
				}
				
				if (!isCollision) {
					
					Core.Collections._Map.get(playerState, "lastPosition", null);
				}
			}

			var landedOnShroom = Core.Collections._Map.get(playerState, "landedOnShroom") == true;
			if ((movedVerticalPosition >= verticalPositionMax)
				&& (!isCollision)
				&& (landedOnShroom)) {
				
				Core.Collections._Map.set(playerState, "landedOnShroom", false)
				respawnVisuPlayer();
			}
			
			sendGridElementRenderRequest(playerGridElement);
		}),
		update: method(this, function() {
			
			super();
			this.GMObject._glow();
			
			var players = this.players;
			var playersSize = getListSize(players);
			for (var index = 0; index < playersSize; index++) {
				
				var player = players[| index];
				var gameplayHandler = getStructVariable(this.GMObject, this.gameplayType);
				if (isOptionalPresent(gameplayHandler)) {
					gameplayHandler(player);
				}
			}
			
			if (keyboard_check_pressed(ord("N"))) {
			
				this.gameplayType = this.gameplayType == "bullethell"
					? "platformer"
					: "bullethell";
							
				var jumbotronEvent = createJumbotronEvent(
					stringParams(
						"  GAME  \n\n>> {0} <<\n\n--------\n",
						string_upper(this.gameplayType)
					),
					"message",
					2.66
				);
				var gameRenderer = getGameRenderer();
				gameRenderer.jumbotronEvent = jumbotronEvent;
				gameRenderer.jumbotronEventTimer = 0.0;
			}
		}),
		cleanUp: method(this, function() {
			for (var index = getListSize(this.players) - 1; index >= 0 ; index--) {
				var player = this.players[| index];
				deregisterPlayer(player);
				destroyVisuPlayer(player);
			}
			destroyDataStructure(this.players, List, "Unable to destroy players");
	
			super();
		}),
		_glow: method(this, function() {
			
			try {
				var player = Core.Collections._List.get(this.players, 0);
				var state = getVisuPlayerState(player);
				var color = getValueFromMap(state, "blendColor", { red: 0.25, green: 0.0, blue: 1.0 });
				var amount = getValueFromMap(state, "glowAmount", 0.001);
				
				color.red = color.red + amount;
				color.green = color.green + amount;
				color.blue = color.blue + amount;
				
				color.red = color.red > 1.0 ? color.red - 1.0 : color.red + applyDeltaTime(amount);
				color.green = color.green > 1.0 ? color.green - 1.0 : color.green + applyDeltaTime(amount);
				color.blue = color.blue > 1.0 ? color.blue - 1.0 : color.blue + applyDeltaTime(amount);
				Core.Collections._Map.set(state, "blendColor", color);

				var spriteBlend = make_color_rgb(color.red * 255, color.green * 255, color.blue * 255);
				Core.Collections._Map.set(state, "spriteBlend", spriteBlend);
				
			} catch (exception) {
				logger(exception.message, LogType.ERROR);
				printStackTrace();
			}
		})
	}
	
	this.GMObject.create();
	
