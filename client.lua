------------------------------------------------------------------------
------------------------------------------------------------------------
--			DO NOT EDIT IF YOU DON'T KNOW WHAT YOU'RE DOING			  --
--     							 									  --
--	   For support join my discord: https://discord.gg/jtYt2pBdPW	  --
------------------------------------------------------------------------
------------------------------------------------------------------------

-- variables
local shown = false -- is the radar on the screen
local zoomed = false -- looking in the scope
local isFreeAiming = false -- is player free aiming
local hasRadarGun = false -- check if the player is holding a radargun.
local fov_max = 70.0
local fov_min = 5.0 -- max zoom level (smaller fov is more zoom)
local zoomspeed = 10.0 -- camera zoom speed
local speed_lr = 8.0 -- speed by which the camera pans left-right
local speed_ud = 8.0 -- speed by which the camera pans up-down
local scope = false
local fov = (fov_max+fov_min)*0.5
local speedlimit = 65

-- Keymapping
RegisterKeyMapping("IncreaseRadarRange", "Radargun: Increase range", "keyboard", "right")
RegisterKeyMapping("DecreaseRadarRange", "Radargun: Decrease range", "keyboard", "left")
RegisterKeyMapping("AimRadarGun", "Radargun: Aim", "keyboard", "Q")

RegisterCommand("IncreaseRadarRange", function()
	config.defaultRange = config.defaultRange + 10.0
	print("Distance set to: " .. config.defaultRange)
end, false)

RegisterCommand("DecreaseRadarRange", function()
	config.defaultRange = config.defaultRange - 10.0
	print("Distance set to: " .. config.defaultRange)
end, false)

RegisterCommand("AimRadarGun", function()
	zoomButtonPressed = true
	Citizen.Wait(1)
	zoomButtonPressed = false
end, false)

Citizen.CreateThread(function()
	-- Aiming animation
	zoomAimhash = GetHashKey("FirstPersonAiming") -- load amimation
	normalAimhash = GetHashKey("Default") -- load animation

	while true do
		ped = PlayerPedId()
		Player = PlayerId()
		isFreeAiming = IsPlayerFreeAiming(Player)
		hasRadarGun = GetSelectedPedWeapon(ped) == GetHashKey(config.radarGun)
		
		-- Measuring
		if hasRadarGun and isFreeAiming then
			if zoomed then
				currentAimHash = zoomAimhash
				coordA = GetOffsetFromEntityInWorldCoords(ped, 0.0, 1.0, 1.0)
				coordB = GetOffsetFromEntityInWorldCoords(ped, 0.0, config.defaultRange / 1.268, 0.0) -- the default range / 1.268 to make it in ft.
				frontcar = StartShapeTestCapsule(coordA, coordB, 3.0, 10, ped, 7)
				shapeTestHandle, hit, endCoords, surfaceNormal, entityHit = GetShapeTestResult(frontcar)
				pos = GetEntityCoords(entityHit)
			elseif shown then
				currentAimHash = normalAimhash
				hit, coords, entityHit = RayCastGamePlayCamera(config.defaultRange / 0.7)
			end
			SetWeaponAnimationOverride(ped, currentAimHash)
		end

		-- remove the radargun from players hand if they're getting in the vehicle without a radargun.
		if not hasRadarGun then
			veh = GetVehiclePedIsEntering(ped)
			inVeh = IsPedInVehicle(ped, veh, true)
			if inVeh then
				Wait(1000)
				SetCurrentPedWeapon(ped, 0xA2719263, false)
			end
		end
		Citizen.Wait(50)
	end
end)

-- Rectile and disable shooting.
Citizen.CreateThread(function()
	while true do
		if shown and isFreeAiming and config.enableCrosshair then
			text("~w~.")
		end
		if hasRadarGun then
			DisableControlAction( 0, 24, true )
			DisablePlayerFiring(ped, true )
			DisableControlAction( 0, 142, true )
		end
		Citizen.Wait(0)
	end
end)

Citizen.CreateThread(function()
    while true do
        if hasRadarGun then
            SetPoliceIgnorePlayer(Player, true)
            SetEveryoneIgnorePlayer(Player, true)
            SetPlayerCanBeHassledByGangs(Player, false)
            SetIgnoreLowPriorityShockingEvents(Player, true)
            
            for key,pedNpc in pairs(GetAllPeds()) do
                SetBlockingOfNonTemporaryEvents(pedNpc,true)
                SetPedFleeAttributes(pedNpc, 0, 0)
                SetPedCombatAttributes(pedNpc, 17, 1)
                if(GetPedAlertness(pedNpc) ~= 0) then
                    SetPedAlertness(pedNpc,0)
                end
            end
        end

		Citizen.Wait(500)
    end
end)

-- Speed limits
Citizen.CreateThread(function()
    while true do
		if shown or zoomed then
			local playerloc = GetEntityCoords(ped)
			local streethash = GetStreetNameAtCoord(playerloc.x, playerloc.y, playerloc.z)
			street = GetStreetNameFromHashKey(streethash)

			if street == "Joshua Rd" then
				speedlimit = 50
			elseif street == "East Joshua Road" then
				speedlimit = 50
			elseif street == "Marina Dr" then
				speedlimit = 35
			elseif street == "Alhambra Dr" then
				speedlimit = 35
			elseif street == "Niland Ave" then
				speedlimit = 35
			elseif street == "Zancudo Ave" then
				speedlimit = 35
			elseif street == "Armadillo Ave" then
				speedlimit = 35
			elseif street == "Algonquin Blvd" then
				speedlimit = 35
			elseif street == "Mountain View Dr" then
				speedlimit = 35
			elseif street == "Cholla Springs Ave" then
				speedlimit = 35
			elseif street == "Panorama Dr" then
				speedlimit = 40
			elseif street == "Lesbos Ln" then
				speedlimit = 35
			elseif street == "Calafia Rd" then
				speedlimit = 30
			elseif street == "North Calafia Way" then
				speedlimit = 30
			elseif street == "Cassidy Trail" then
				speedlimit = 25
			elseif street == "Seaview Rd" then
				speedlimit = 35
			elseif street == "Grapeseed Main St" then
				speedlimit = 35
			elseif street == "Grapeseed Ave" then
				speedlimit = 35
			elseif street == "Joad Ln" then
				speedlimit = 35
			elseif street == "Union Rd" then
				speedlimit = 40
			elseif street == "O'Neil Way" then
				speedlimit = 25
			elseif street == "Senora Fwy" then
				speedlimit = 65
			elseif street == "Catfish View" then
				speedlimit = 35
			elseif street == "Great Ocean Hwy" then
				speedlimit = 60
			elseif street == "Paleto Blvd" then
				speedlimit = 35
			elseif street == "Duluoz Ave" then
				speedlimit = 35
			elseif street == "Procopio Dr" then
				speedlimit = 35
			elseif street == "Cascabel Ave" then
				speedlimit = 30
			elseif street == "Procopio Promenade" then
				speedlimit = 25
			elseif street == "Pyrite Ave" then
				speedlimit = 30
			elseif street == "Fort Zancudo Approach Rd" then
				speedlimit = 25
			elseif street == "Barbareno Rd" then
				speedlimit = 30
			elseif street == "Ineseno Road" then
				speedlimit = 30
			elseif street == "West Eclipse Blvd" then
				speedlimit = 35
			elseif street == "Playa Vista" then
				speedlimit = 30
			elseif street == "Bay City Ave" then
				speedlimit = 30
			elseif street == "Del Perro Fwy" then
				speedlimit = 65
			elseif street == "Equality Way" then
				speedlimit = 30
			elseif street == "Red Desert Ave" then
				speedlimit = 30
			elseif street == "Magellan Ave" then
				speedlimit = 25
			elseif street == "Sandcastle Way" then
				speedlimit = 30
			elseif street == "Vespucci Blvd" then
				speedlimit = 40
			elseif street == "Prosperity St" then
				speedlimit = 30
			elseif street == "San Andreas Ave" then
				speedlimit = 40
			elseif street == "North Rockford Dr" then
				speedlimit = 35
			elseif street == "South Rockford Dr" then
				speedlimit = 35
			elseif street == "Marathon Ave" then
				speedlimit = 30
			elseif street == "Boulevard Del Perro" then
				speedlimit = 35
			elseif street == "Cougar Ave" then
				speedlimit = 30
			elseif street == "Liberty St" then
				speedlimit = 30
			elseif street == "Bay City Incline" then
				speedlimit = 40
			elseif street == "Conquistador St" then
				speedlimit = 25
			elseif street == "Cortes St" then
				speedlimit = 25
			elseif street == "Vitus St" then
				speedlimit = 25
			elseif street == "Aguja St" then
				speedlimit = 25
			elseif street == "Goma St" then
				speedlimit = 25
			elseif street == "Melanoma St" then
				speedlimit = 25
			elseif street == "Palomino Ave" then
				speedlimit = 35
			elseif street == "Invention Ct" then
				speedlimit = 25
			elseif street == "Imagination Ct" then
				speedlimit = 25
			elseif street == "Rub St" then
				speedlimit = 25
			elseif street == "Tug St" then
				speedlimit = 25
			elseif street == "Ginger St" then
				speedlimit = 30
			elseif street == "Lindsay Circus" then
				speedlimit = 30
			elseif street == "Calais Ave" then
				speedlimit = 35
			elseif street == "Adam's Apple Blvd" then
				speedlimit = 40
			elseif street == "Alta St" then
				speedlimit = 40
			elseif street == "Integrity Way" then
				speedlimit = 30
			elseif street == "Swiss St" then
				speedlimit = 30
			elseif street == "Strawberry Ave" then
				speedlimit = 40
			elseif street == "Capital Blvd" then
				speedlimit = 30
			elseif street == "Crusade Rd" then
				speedlimit = 30
			elseif street == "Innocence Blvd" then
				speedlimit = 40
			elseif street == "Davis Ave" then
				speedlimit = 40
			elseif street == "Little Bighorn Ave" then
				speedlimit = 35
			elseif street == "Roy Lowenstein Blvd" then
				speedlimit = 35
			elseif street == "Jamestown St" then
				speedlimit = 30
			elseif street == "Carson Ave" then
				speedlimit = 35
			elseif street == "Grove St" then
				speedlimit = 30
			elseif street == "Brouge Ave" then
				speedlimit = 30
			elseif street == "Covenant Ave" then
				speedlimit = 30
			elseif street == "Dutch London St" then
				speedlimit = 40
			elseif street == "Signal St" then
				speedlimit = 30
			elseif street == "Elysian Fields Fwy" then
				speedlimit = 50
			elseif street == "Plaice Pl" then
				speedlimit = 30
			elseif street == "Chum St" then
				speedlimit = 40
			elseif street == "Chupacabra St" then
				speedlimit = 30
			elseif street == "Miriam Turner Overpass" then
				speedlimit = 30
			elseif street == "Autopia Pkwy" then
				speedlimit = 35
			elseif street == "Exceptionalists Way" then
				speedlimit = 35
			elseif street == "La Puerta Fwy" then
				speedlimit = 60
			elseif street == "New Empire Way" then
				speedlimit = 30
			elseif street == "Runway1" then
				speedlimit = "--"
			elseif street == "Greenwich Pkwy" then
				speedlimit = 35
			elseif street == "Kortz Dr" then
				speedlimit = 30
			elseif street == "Banham Canyon Dr" then
				speedlimit = 40
			elseif street == "Buen Vino Rd" then
				speedlimit = 40
			elseif street == "Route 68" then
				speedlimit = 55
			elseif street == "Zancudo Grande Valley" then
				speedlimit = 40
			elseif street == "Zancudo Barranca" then
				speedlimit = 40
			elseif street == "Galileo Rd" then
				speedlimit = 40
			elseif street == "Mt Vinewood Dr" then
				speedlimit = 40
			elseif street == "Marlowe Dr" then
				speedlimit = 40
			elseif street == "Milton Rd" then
				speedlimit = 35
			elseif street == "Kimble Hill Dr" then
				speedlimit = 35
			elseif street == "Normandy Dr" then
				speedlimit = 35
			elseif street == "Hillcrest Ave" then
				speedlimit = 35
			elseif street == "Hillcrest Ridge Access Rd" then
				speedlimit = 35
			elseif street == "North Sheldon Ave" then
				speedlimit = 35
			elseif street == "Lake Vinewood Dr" then
				speedlimit = 35
			elseif street == "Lake Vinewood Est" then
				speedlimit = 35
			elseif street == "Baytree Canyon Rd" then
				speedlimit = 40
			elseif street == "North Conker Ave" then
				speedlimit = 35
			elseif street == "Wild Oats Dr" then
				speedlimit = 35
			elseif street == "Whispymound Dr" then
				speedlimit = 35
			elseif street == "Didion Dr" then
				speedlimit = 35
			elseif street == "Cox Way" then
				speedlimit = 35
			elseif street == "Picture Perfect Drive" then
				speedlimit = 35
			elseif street == "South Mo Milton Dr" then
				speedlimit = 35
			elseif street == "Cockingend Dr" then
				speedlimit = 35
			elseif street == "Mad Wayne Thunder Dr" then
				speedlimit = 35
			elseif street == "Hangman Ave" then
				speedlimit = 35
			elseif street == "Dunstable Ln" then
				speedlimit = 35
			elseif street == "Dunstable Dr" then
				speedlimit = 35
			elseif street == "Greenwich Way" then
				speedlimit = 35
			elseif street == "Greenwich Pl" then
				speedlimit = 35
			elseif street == "Hardy Way" then
				speedlimit = 35
			elseif street == "Richman St" then
				speedlimit = 35
			elseif street == "Ace Jones Dr" then
				speedlimit = 35
			elseif street == "Los Santos Freeway" then
				speedlimit = 65
			elseif street == "Senora Rd" then
				speedlimit = 40
			elseif street == "Nowhere Rd" then
				speedlimit = 25
			elseif street == "Smoke Tree Rd" then
				speedlimit = 35
			elseif street == "Cholla Rd" then
				speedlimit = 35
			elseif street == "Cat-Claw Ave" then
				speedlimit = 35
			elseif street == "Senora Way" then
				speedlimit = 40
			elseif street == "Palomino Fwy" then
				speedlimit = 60
			elseif street == "Shank St" then
				speedlimit = 25
			elseif street == "Macdonald St" then
				speedlimit = 35
			elseif street == "Route 68 Approach" then
				speedlimit = 55
			elseif street == "Vinewood Park Dr" then
				speedlimit = 35
			elseif street == "Vinewood Blvd" then
				speedlimit = 40
			elseif street == "Mirror Park Blvd" then
				speedlimit = 35
			elseif street == "Glory Way" then
				speedlimit = 35
			elseif street == "Bridge St" then
				speedlimit = 35
			elseif street == "West Mirror Drive" then
				speedlimit = 35
			elseif street == "Nikola Ave" then
				speedlimit = 35
			elseif street == "East Mirror Dr" then
				speedlimit = 35
			elseif street == "Nikola Pl" then
				speedlimit = 25
			elseif street == "Mirror Pl" then
				speedlimit = 35
			elseif street == "El Rancho Blvd" then
				speedlimit = 40
			elseif street == "Olympic Fwy" then
				speedlimit = 60
			elseif street == "Fudge Ln" then
				speedlimit = 25
			elseif street == "Amarillo Vista" then
				speedlimit = 25
			elseif street == "Labor Pl" then
				speedlimit = 35
			elseif street == "El Burro Blvd" then
				speedlimit = 35
			elseif street == "Sustancia Rd" then
				speedlimit = 45
			elseif street == "South Shambles St" then
				speedlimit = 30
			elseif street == "Hanger Way" then
				speedlimit = 30
			elseif street == "Orchardville Ave" then
				speedlimit = 30
			elseif street == "Popular St" then
				speedlimit = 40
			elseif street == "Buccaneer Way" then
				speedlimit = 45
			elseif street == "Abattoir Ave" then
				speedlimit = 35
			elseif street == "Voodoo Place" then
				speedlimit = 30
			elseif street == "Mutiny Rd" then
				speedlimit = 35
			elseif street == "South Arsenal St" then
				speedlimit = 35
			elseif street == "Forum Dr" then
				speedlimit = 35
			elseif street == "Morningwood Blvd" then
				speedlimit = 35
			elseif street == "Dorset Dr" then
				speedlimit = 40
			elseif street == "Caesars Place" then
				speedlimit = 25
			elseif street == "Spanish Ave" then
				speedlimit = 30
			elseif street == "Portola Dr" then
				speedlimit = 30
			elseif street == "Edwood Way" then
				speedlimit = 25
			elseif street == "San Vitus Blvd" then
				speedlimit = 40
			elseif street == "Eclipse Blvd" then
				speedlimit = 35
			elseif street == "Gentry Lane" then
				speedlimit = 30
			elseif street == "Las Lagunas Blvd" then
				speedlimit = 40
			elseif street == "Power St" then
				speedlimit = 40
			elseif street == "Mt Haan Rd" then
				speedlimit = 40
			elseif street == "Elgin Ave" then
				speedlimit = 40
			elseif street == "Hawick Ave" then
				speedlimit = 35
			elseif street == "Meteor St" then
				speedlimit = 30
			elseif street == "Alta Pl" then
				speedlimit = 30
			elseif street == "Occupation Ave" then
				speedlimit = 35
			elseif street == "Carcer Way" then
				speedlimit = 40
			elseif street == "Eastbourne Way" then
				speedlimit = 30
			elseif street == "Rockford Dr" then
				speedlimit = 35
			elseif street == "Abe Milton Pkwy" then
				speedlimit = 35
			elseif street == "Laguna Pl" then
				speedlimit = 30
			elseif street == "Sinners Passage" then
				speedlimit = 30
			elseif street == "Atlee St" then
				speedlimit = 30
			elseif street == "Sinner St" then
				speedlimit = 30
			elseif street == "Supply St" then
				speedlimit = 30
			elseif street == "Amarillo Way" then
				speedlimit = 35
			elseif street == "Tower Way" then
				speedlimit = 35
			elseif street == "Decker St" then
				speedlimit = 35
			elseif street == "Tackle St" then
				speedlimit = 25
			elseif street == "Low Power St" then
				speedlimit = 35
			elseif street == "Clinton Ave" then
				speedlimit = 35
			elseif street == "Fenwell Pl" then
				speedlimit = 35
			elseif street == "Utopia Gardens" then
				speedlimit = 25
			elseif street == "Cavalry Blvd" then
				speedlimit = 35
			elseif street == "South Boulevard Del Perro" then
				speedlimit = 35
			elseif street == "Americano Way" then
				speedlimit = 25
			elseif street == "Sam Austin Dr" then
				speedlimit = 25
			elseif street == "East Galileo Ave" then
				speedlimit = 35
			elseif street == "Galileo Park" then
				speedlimit = 35
			elseif street == "West Galileo Ave" then
				speedlimit = 35
			elseif street == "Tongva Dr" then
				speedlimit = 40
			elseif street == "Zancudo Rd" then
				speedlimit = 35
			elseif street == "Movie Star Way" then
				speedlimit = 35
			elseif street == "Heritage Way" then
				speedlimit = 35
			elseif street == "Perth St" then
				speedlimit = 25
			elseif street == "Chianski Passage" then
				speedlimit = 30
			elseif street == "Lolita Ave" then
				speedlimit = 35
			elseif street == "Meringue Ln" then
				speedlimit = 35
			elseif street == "Strangeways Dr" then
				speedlimit = 30
			elseif street == "Mt Haan Dr" then
				speedlimit = 35
			elseif street == "Peaceful St" then
				speedlimit = 25
			elseif street == "Steele Way" then
				speedlimit = 25
			elseif street == "York St" then
				speedlimit = 25
			elseif street == "Tangerine St" then
				speedlimit = 25
			elseif street == "Dorset Pl" then
				speedlimit = 25
			else
				speedlimit = 15
			end
		end
		Citizen.Wait(10000)
	end
end)

Citizen.CreateThread(function()
	while true do
		-- if player has a radar it will set everything to 0
		if not started then
			if config.enableALPR then
				plateNr = "00000000"
			else
				plateNr = ""
			end
			if config.metric == true then
				SendNUIMessage({
					speed = "00",
					range = "00",
					speedPrefix = "kmh",
					rangePrefix = "m",
					fastsl = "",
					slowsl = "▼",
					triggeredSpeed = "00",
					plateNr = plateNr
				})
			else
				SendNUIMessage({
					speed = "00",
					range = "00",
					speedPrefix = "mph",
					rangePrefix = "ft",
					fastsl = "",
					slowsl = "▼",
					triggeredSpeed = "00",
					plate = plateNr
				})
			end
		end
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while true do
		-- open the ui when player has the radargun.
		if hasRadarGun then
			if not zoomed then
				SendNUIMessage({
					action = "open",
				})
				shown = true
			elseif zoomed then
				SendNUIMessage({
					action = "close",
				})
				shown = false
			end
		else
			SendNUIMessage({
				action = "close",
				zoom = "close",
			})
			shown = false
			zoomed = false
			scope = false
		end
		Citizen.Wait(100)
	end
end)

Citizen.CreateThread(function()
	while true do
		-- using the scope or zooming in idk what to call that stuff smh
		if hasRadarGun and zoomButtonPressed then
			if not zoomed then
				SendNUIMessage({
					zoom = "open",
					action = "close",
				})
				zoomed = true
				scope = true
				shown = false
			elseif zoomed then
				SendNUIMessage({
					zoom = "close",
					action = "open",
				})
				zoomed = false
				scope = false
				shown = true
			end
		end
		Citizen.Wait(10)
	end
end)

Citizen.CreateThread(function()
	while true do
		-- all the radar features
		if hasRadarGun then
			if IsEntityAVehicle(entityHit) then
				if isFreeAiming then
					if config.metric == true then
						local vehSpeed = math.ceil(GetEntitySpeed(entityHit)*3.6)
						local vehRange = math.ceil(GetDistanceBetweenCoords(GetEntityCoords(ped),GetEntityCoords(entityHit), true) / 3,281)
						if config.enableALPR then
							plateNr = GetVehicleNumberPlateText(entityHit)
						else
							plateNr = ""
						end
						if vehSpeed > speedlimit*1.6 then
							PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false)
							fastsl = "▲"
							slowsl = ""
						elseif vehSpeed < speedlimit then
							fastsl = ""
							slowsl = "▼"
						end
						if shown then
							started = true
							SendNUIMessage({
								speed = vehSpeed,
								range = vehRange,
								speedPrefix = "kmh",
								rangePrefix = "m",
								fastsl = fastsl,
								slowsl = slowsl,
								triggeredSpeed = speedlimit*1.6,
								plate = plateNr
							})
						elseif zoomed then
							started = true
							SendNUIMessage({
								speed = vehSpeed,
							})
						else
							started = true
						end
					else
						local vehSpeed = math.ceil(GetEntitySpeed(entityHit)*2.23694)
						local vehRange = math.ceil(GetDistanceBetweenCoords(GetEntityCoords(ped),GetEntityCoords(entityHit), true))
						if config.enableALPR then
							plateNr = GetVehicleNumberPlateText(entityHit)
						else
							plateNr = ""
						end
						if vehSpeed > speedlimit then
							PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false)
							fastsl = "▲"
							slowsl = ""
						elseif vehSpeed < speedlimit then
							fastsl = ""
							slowsl = "▼"
						end
						if shown then
							started = true
							SendNUIMessage({
								speed = vehSpeed,
								range = vehRange,
								speedPrefix = "mph",
								rangePrefix = "ft",
								fastsl = fastsl,
								slowsl = slowsl,
								triggeredSpeed = speedlimit,
								plate = plateNr
							})
						elseif zoomed then
							started = true
							SendNUIMessage({
								speed = vehSpeed,
							})
						else
							started = true
						end
					end
				end
			end
		end
		Citizen.Wait(80)
	end
end)

-- the scope when zoomed in.
Citizen.CreateThread(function()
	while true do
		local vehicle = GetVehiclePedIsIn(ped)

		if scope then
			scope = true
			SetTimecycleModifier("default")
			SetTimecycleModifierStrength(0.3)

			local vehicle = GetVehiclePedIsIn(ped)
			local cam = CreateCam("DEFAULT_SCRIPTED_FLY_CAMERA", true)

			AttachCamToEntity(cam, ped, 0.0,0.0,1.0, true)
			SetCamRot(cam, 0.0,0.0,GetEntityHeading(ped))
			SetCamFov(cam, fov)
			RenderScriptCams(true, false, 0, 1, 0)

			while scope and not IsEntityDead(ped) and (GetVehiclePedIsIn(ped) == vehicle) and true do
				if IsControlJustPressed(0, storeBinoclarKey) then -- Toggle scope
					PlaySoundFrontend(-1, "SELECT", "HUD_FRONTEND_DEFAULT_SOUNDSET", false)
					ClearPedTasks(Player)
					scope = false
				end

				local zoomvalue = (1.0/(fov_max-fov_min))*(fov-fov_min)
				CheckInputRotation(cam, zoomvalue)

				HandleZoom(cam)
				HideHUDThisFrame()

				Citizen.Wait(0)
			end

			scope = false
			ClearTimecycleModifier()
			fov = (fov_max+fov_min)*0.5
			RenderScriptCams(false, false, 0, 1, 0)
			DestroyCam(cam, false)
			SetNightvision(false)
			SetSeethrough(false)
		end

		Citizen.Wait(100)
	end
end)

-- Activate scope
RegisterNetEvent("scope:Activate")
AddEventHandler("scope:Activate", function()
	scope = not scope
end)

-- functions
function HideHUDThisFrame()
	HideHelpTextThisFrame()
	HideHudAndRadarThisFrame()
	HideHudComponentThisFrame(1) -- Wanted Stars
	HideHudComponentThisFrame(2) -- Weapon icon
	HideHudComponentThisFrame(3) -- Cash
	HideHudComponentThisFrame(4) -- MP CASH
	HideHudComponentThisFrame(6)
	HideHudComponentThisFrame(7)
	HideHudComponentThisFrame(8)
	HideHudComponentThisFrame(9)
	HideHudComponentThisFrame(13) -- Cash Change
	HideHudComponentThisFrame(11) -- Floating Help Text
	HideHudComponentThisFrame(12) -- more floating help text
	HideHudComponentThisFrame(15) -- Subtitle Text
	HideHudComponentThisFrame(18) -- Game Stream
	HideHudComponentThisFrame(19) -- weapon wheel
end

function CheckInputRotation(cam, zoomvalue)
	local rightAxisX = GetDisabledControlNormal(0, 220)
	local rightAxisY = GetDisabledControlNormal(0, 221)
	local rotation = GetCamRot(cam, 2)
	if rightAxisX ~= 0.0 or rightAxisY ~= 0.0 then
		new_z = rotation.z + rightAxisX*-1.0*(speed_ud)*(zoomvalue+0.1)
		new_x = math.max(math.min(20.0, rotation.x + rightAxisY*-1.0*(speed_lr)*(zoomvalue+0.1)), -89.5)
		SetCamRot(cam, new_x, 0.0, new_z, 2)
	end
end

function HandleZoom(cam)
	if not ( IsPedSittingInAnyVehicle( ped ) ) then

		if IsControlJustPressed(0,241) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,242) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05)
	else
		if IsControlJustPressed(0,17) then -- Scrollup
			fov = math.max(fov - zoomspeed, fov_min)
		end
		if IsControlJustPressed(0,16) then
			fov = math.min(fov + zoomspeed, fov_max) -- ScrollDown
		end
		local current_fov = GetCamFov(cam)
		if math.abs(fov-current_fov) < 0.1 then -- the difference is too small, just set the value directly to avoid unneeded updates to FOV of order 10^-5
			fov = current_fov
		end
		SetCamFov(cam, current_fov + (fov - current_fov)*0.05) -- Smoothing of camera zoom
	end
end

function RotationToDirection(rotation)
	local adjustedRotation = 
	{ 
		x = (math.pi / 180) * rotation.x, 
		y = (math.pi / 180) * rotation.y, 
		z = (math.pi / 180) * rotation.z 
	}
	local direction = 
	{
		x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
		z = math.sin(adjustedRotation.x)
	}
	return direction
end

function RayCastGamePlayCamera(distance)
	local cameraRotation = GetGameplayCamRot()
	local cameraCoord = GetGameplayCamCoord()
	local direction = RotationToDirection(cameraRotation)
	local destination = 
	{ 
		x = cameraCoord.x + direction.x * distance, 
		y = cameraCoord.y + direction.y * distance, 
		z = cameraCoord.z + direction.z * distance 
	}
	local a, b, c, d, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, -1, 1))
	return b, c, e
end

function text(text)
	SetTextFont(4)
	SetTextProportional(0)
	SetTextScale(0.5, 0.5)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow(0, 0, 0, 0,255)
	SetTextOutline()
	SetTextJustification(0)
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(0.5, 0.475)
end

function EnumerateEntities(initFunc, moveFunc, disposeFunc)
    return coroutine.wrap(function()
        local iter, id = initFunc()
        if not id or id == 0 then
            disposeFunc(iter)
            return
        end
      
        local enum = {handle = iter, destructor = disposeFunc}
        setmetatable(enum, entityEnumerator)
      
        local next = true
        repeat
            coroutine.yield(id)
            next, id = moveFunc(iter)
        until not next
      
        enum.destructor, enum.handle = nil, nil
        disposeFunc(iter)
    end)
end

function EnumeratePeds()
    return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

function GetAllPeds()
    local peds = {}
    for ped in EnumeratePeds() do
        if DoesEntityExist(ped) and not IsEntityDead(ped) and IsEntityAPed(ped) and IsPedHuman(ped) and not IsPedAPlayer(ped) then
            table.insert(peds, ped)
        end
    end
    return peds
end