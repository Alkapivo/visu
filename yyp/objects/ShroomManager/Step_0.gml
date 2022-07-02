///@description

	super();
	
	if (global.demo) {
		
		templateTimer = incrementTimer(templateTimer, 2.66);
		if (timerFinished(templateTimer)) {
			var templateNameIndex = clamp(round(random(getArrayLength(templateNames) - 1)), 0, getArrayLength(templateNames) - 1);								
			currentTemplate = templateNames[templateNameIndex];
			setInstanceVariable(getSceneRenderer(), "__currentTemplate", getInstanceVariable(getShroomManager(), "currentTemplate"));
			logger("Current shroom shader template: {0}", LogType.INFO, currentTemplate);
		}
	}
		
	#region Shroom reactor
	var destroyShrooms = [];
	var shroomsSize = getListSize(shrooms);
	for (var index = 0; index < shroomsSize; index++) {
		var shroom = shrooms[| index];
		var shroomGridElement = getShroomGridElement(shroom);
		var shroomPosition = getGridElementPosition(shroomGridElement);
		
		#region Resovle Status
		var shroomState = getShroomState(shroom);
		var shroomStatus = getValueFromMap(shroomState, "status", "run");
	
		switch (shroomStatus) {
			case "run":
			
				#region Movement
				var speedValue = getShroomSpeedValue(shroom);
				var gridSpeed = getInstanceVariable(getGridRenderer(), "separatorSpeed");
				speedValue = speedValue * (gridSpeed / 0.005);
				
				var movedVerticalPosition = fetchMovedVerticalPositionOnGrid(
					getPositionVertical(shroomPosition), 
	 				speedValue);
				setPositionVertical(shroomPosition, movedVerticalPosition);
								
				var horizontalSpeed = getValueFromMap(shroomState, "horizontalSpeed", choose(1, -1) * (random(6.66) / 1000));
				var movedHorizontalPosition = getPositionHorizontal(shroomPosition) + applyDeltaTime(horizontalSpeed);
				setPositionHorizontal(shroomPosition, movedHorizontalPosition);
				
				if ((movedVerticalPosition >= -1.5) &&
					(movedVerticalPosition <= 1.5)) {
						
					sendGridElementRenderRequest(shroomGridElement);
				} else {
					destroyShrooms = pushArray(destroyShrooms, index);
				}
				#endregion
						
				if (getPlayerManager().gameplayType == "bullethell") {
				
					var isShooting = getValueFromMap(shroomState, "isShooting", false);
					Core.Collections._Map.set(shroomState, "isShooting", isShooting);
					if (isShooting) {
						
						var bulletTimer = getValueFromMap(shroomState, "bulletTimer", 0);
						var bulletTimerDuration = getValueFromMap(shroomState, "bulletTimerDuration", choose(0.40, 0.50, 0.70));
						bulletTimer = incrementTimer(bulletTimer, bulletTimerDuration);
						if (timerFinished(bulletTimer)) {
					
							var shootDummyBullet = function(shroomState, shroomPosition) {
								
								var bulletAngleRange = getValueFromMap(shroomState, "bulletAngleRange", choose(0.008, 0.009));
								var bulletSpeed = getValueFromMap(shroomState, "bulletSpeed", choose(0.009, 0.01));
								spawnBullet(
									createPosition(
										getPositionHorizontal(shroomPosition),
										getPositionVertical(shroomPosition)
									), 
									BulletProducer.SHROOM, 
									270 + (choose(1, -1) * random(bulletAngleRange)), 
									createSprite(asset_texture_bullet_shroom_01, 0, 1.0, 1.0, 1.0, 0.0, c_white),
									bulletSpeed, 
									0.0008
								);
							}
							
							var shootBulletThatWillFollowPlayer = function(shroomState, shroomPosition) {
							
								if (getPositionVertical(shroomPosition) < 0.77) {
									
									var playerPosition = getGridElementPosition(getVisuPlayerGridElement(fetchPlayers()[| 0]));
									var bulletSpeed = getValueFromMap(shroomState, "bulletSpeed", choose(0.007, 0.008));
									spawnBullet(
										createPosition(
											getPositionHorizontal(shroomPosition),
											getPositionVertical(shroomPosition)
										), 
										BulletProducer.SHROOM, 
										180 + getAngleBetweenPoints(playerPosition, shroomPosition), 
										createSprite(asset_texture_bullet_shroom_01, 0, 1.0, 1.0, 1.0, 0.0, c_white),
										bulletSpeed, 
										0.0008
									);
								}
							}
					
							var bulletFollowPlayer = getValueFromMap(shroomState, "bulletFollowPlayer", false) == true;
							if (bulletFollowPlayer) {
								
								shootBulletThatWillFollowPlayer(shroomState, shroomPosition);
							} else {
								
								shootDummyBullet(shroomState, shroomPosition);
							}
						}
				
						Core.Collections._Map.set(shroomState, "bulletTimer", bulletTimer);
					}
				}
				
				if (getPlayerManager().gameplayType == "platformer") {
				
					var isSlidingAwayAfterLanding = function(shroom) {
						
						var shroomState = getShroomState(shroom);
						var isFeatureEnabled = getValueFromMap(shroomState, "slideAwayAfterLanding", false) == true;
						if (isFeatureEnabled) {
							
							var playerLanded = Core.Collections._Map.get(shroomState, "playerLanded") == true;
							if (playerLanded) {
						
								var horizontalPosition = getPositionHorizontal(getGridElementPosition(getShroomGridElement(shroom)));
								var horizontalDirection = horizontalPosition < 0.5 ? 1 : -1;
								
								Core.Collections._Map.set(shroomState, "slideAwayAfterLanding", false);
								Core.Collections._Map.set(shroomState, "horizontalSpeed", getShroomSpeedValue(shroom) * 0.75 * horizontalDirection);
								setShroomSpeedValue(shroom, getShroomSpeedValue(shroom) * 0.66);
							}
						}
					}
					
					isSlidingAwayAfterLanding(shroom, shroomState, speedValue);
				}
				break;
			case "end":
			
				getGameController().gameplayData.shroomCounter++;
			
				var instantKill = getValueFromMap(shroomState, "instantKill", false);
				if (instantKill) {
				
					destroyShrooms = pushArray(destroyShrooms, index);
					break;
				}
			
				var dieTimer = getValueFromMap(shroomState, "dieTimer", 0);
				var dieTimerDuration = getValueFromMap(shroomState, "dieTimerDuration", 0);
				var bulletTaken = shroomState[? "bulletTaken"]
				dieTimer = incrementTimer(dieTimer, dieTimerDuration);
				if ((timerFinished(dieTimer)) ||
					(bulletTaken > 0)) { //3
					
					if (bulletTaken > 0) { //3
						
						destroyShrooms = pushArray(destroyShrooms, index);
						break;
					} else {
					
						setInMap(shroomState, "status", "run");
					}
				}
				shroomState[? "dieTimer"] = dieTimer;
			
				#region Movement
				var speedValue = getShroomSpeedValue(shroom) / (bulletTaken + 1.5);
				var gridSpeed = getInstanceVariable(getGridRenderer(), "separatorSpeed");
				speedValue = speedValue * (gridSpeed / 0.005);
				
				var movedVerticalPosition = fetchMovedVerticalPositionOnGrid(
					getPositionVertical(shroomPosition), 
	 				speedValue);
				setPositionVertical(shroomPosition, movedVerticalPosition);
				
				var horizontalSpeed = getValueFromMap(shroomState, "horizontalSpeed", choose(1, -1) * (random(6.66) / 1000));
				var movedHorizontalPosition = getPositionHorizontal(shroomPosition) + applyDeltaTime(horizontalSpeed);
				setPositionHorizontal(shroomPosition, movedHorizontalPosition);
				
				if ((movedVerticalPosition >= -1.5) &&
					(movedVerticalPosition <= 1.5)) {
						
					sendGridElementRenderRequest(shroomGridElement);
				} else {
					destroyShrooms = pushArray(destroyShrooms, index);
				}
				#endregion
							
				break;
		}

		#endregion
	}
	
	removeItemsFromList(shrooms, destroyShrooms, destroyShroom);
	#endregion
	
