local ids_rain_post_processor = Idstring("rain_post_processor")
local ids_rain_ripples = Idstring("rain_ripples")
local ids_rain_off = Idstring("rain_off")
local ripple_fix = false
if not Global.load_level then 
	return
end
local map = Global.game_settings.level_id
--lazy terrible fix for these levels having droplets indoors
--causes droplets to pop in but what the fuck else can i do?
if map == "fish" or map == "arena" or map == "mus" or map == "red2" or map == "pbr" or map == "big" or map == "hox_2" or map == "vit" then
	ids_rain_off = Idstring("rain_inside")
	ripple_fix = true
end
local inside = false
local outside = false
local _raineffectloopdelay = 0
local inside_delay = 1

function RainEffect:update(t, dt)
	local vp = managers.viewport:first_active_viewport()
	if vp and self._vp ~= vp then
		vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_ripples)
		if alive(self._vp) then
			self._vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_off)
		end
		self._vp = vp
	end
	local c_rot = managers.environment_effects:camera_rotation()
	if not c_rot then
		return
	end
	local c_pos = managers.environment_effects:camera_position()
	if not c_pos then
		return
	end
	local normal = math.UP
	local mvec_to = Vector3()
	mvector3.set(mvec_to, -normal)
	mvector3.multiply( mvec_to, 20000000000 )
	mvector3.add(mvec_to, c_pos)
	local col_rayy = World:raycast("ray", c_pos + Vector3(0, 0, 5000000), mvec_to, "slot_mask", managers.slot:get_mask("bullet_impact_targets" ))
	if col_rayy and mvector3.distance_sq(col_rayy.hit_position, c_pos) < 22000 then
	--player is outside in the rain
		--probably the dumbest way possible to do it but idc, if outside set our inside timer to current time + 1
			inside_delay = t + 1
		--probably overthought this but this makes sure it only plays the sound once, when the player goes in/outside
		if outside == false then
			if Utils:IsInHeist() and Utils:IsInCustody() == false and game_state_machine then
				managers.player:player_unit():sound():play("ambience_ext_heavy_rain_storm_asphalt", nil, false)
				if ripple_fix then
					vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_ripples)
				end
				outside = true
				inside = false
			end
		end
	else
	--player is inside, not in the rain
	--check our delay of 1 second to make sure it doesn't trigger from running over terrain, which restarts the sound
	--again, only start playing the sound once
	if not (inside_delay > t) then 
			if inside == false then
				inside_delay = t + 1
				if Utils:IsInHeist() and Utils:IsInCustody() == false and game_state_machine then
					managers.player:player_unit():sound():play("ambience_ext_heavy_rain_storm_tarp", nil, false)
					if ripple_fix then
						vp:vp():set_post_processor_effect("World", ids_rain_post_processor, ids_rain_off)
					end
					outside = false
					inside = true
				end
			end
	end
		return
	end
	World:effect_manager():move_rotate(self._effect, c_pos, c_rot)
end