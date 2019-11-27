if not _G.ToD then
	_G.ToD = {}
	ToD.loaded_options = ToD.loaded_options or {}
	ToD.mod_path = ModPath
	ToD.save_path = SavePath
    ToD.OptionsMenu = "ToDOptionsMenu"
    ToD.HeistMenu = "ToDHeistMenu"
    ToD.HeistOptionsMenu = "ToDHeistOptionsMenu"
    
    ToD.night_sky_options = {
        [1] = "tod_" .. "core/environments/skies/sky_2100_moon/sky_2100_moon",
        [2] = "tod_" .. "core/environments/skies/sky_2335_night_moon/sky_2335_night_moon",
        [3] = "tod_" .. "core/environments/skies/sky_0200_night_moon_stars/sky_0200_night_moon_stars",
        [4] = "tod_" .. "core/environments/skies/sky_0902_overcast_dark/sky_0902_overcast_dark",
        [5] = "tod_" .. "core/environments/skies/sky_1313_cloudy_dark/sky_1313_cloudy_dark",
    }

    ToD.day_sky_options = {
        [1] = "tod_" .. "core/environments/skies/sky_cloudy_blue/sky_cloudy_blue",
        [2] = "tod_" .. "core/environments/skies/sky_0927_whispy_clouds/sky_0927_whispy_clouds",
        [3] = "tod_" .. "core/environments/skies/sky_1008_cloudy/sky_1008_cloudy",
        [4] = "tod_" .. "core/environments/skies/sky_1044_overcast_sun/sky_1044_overcast_sun",
        [5] = "tod_" .. "core/environments/skies/sky_1224_clear_sky/sky_1224_clear_sky",
        [6] = "tod_" .. "core/environments/skies/sky_1313_cloudy/sky_1313_cloudy",
        [7] = "tod_" .. "core/environments/skies/sky_2003_dusk_blue/sky_2003_dusk_blue",
        [8] = "tod_" .. "core/environments/skies/sky_1345_clear_sky/sky_1345_clear_sky",
        [9] = "tod_" .. "core/environments/skies/sky_1830_low_sun_clouds/sky_1830_low_sun_clouds",
        [10] = "tod_" .. "core/environments/skies/sky_1930_sunset_heavy_clouds/sky_1930_sunset_heavy_clouds",
        [11] = "tod_" .. "core/environments/skies/sky_1930_twillight/sky_1930_twillight",
        [12] = "tod_" .. "core/environments/skies/sky_1931_low_sun/sky_1931_low_sun",
        [13] = "tod_" .. "core/environments/skies/sky_2003_sunrise/sky_2003_sunrise",
        [14] = "tod_" .. "core/environments/skies/sky_city_clear/sky_city_clear",
        [15] = "tod_" .. "core/environments/skies/sky_0902_overcast/sky_0902_overcast",
        [16] = "tod_" .. "core/environments/skies/sky_csgo_de_bank_cs15_daylight02/sky_csgo_de_bank_cs15_daylight02",
        [17] = "tod_" .. "core/environments/skies/sky_1945_sunset/sky_1945_sunset",
    }

    ToD.weather_options = {
        [1] = "tod_default",
        [2] = "tod_rain",
        [3] = "tod_snow",
    }
end

ToD.dofiles = {
	"Options.lua",
	"HeistDefinitions.lua"
}

Hooks:Add("MenuUpdate", "ToDMenuUpdate", function( t, dt )
	ToD:update(t, dt)
end)

Hooks:Add("GameSetupUpdate", "ToDGameSetupUpdate", function( t, dt )
	ToD:update(t, dt)
	ToD:UpdateEnvironment(t, dt)
end)

Hooks:Add("GameSetupPauseUpdate", "ToDGameSetupPausedUpdate", function(t, dt)
	ToD:UpdateEnvironment(t, dt)
end)

function ToD:UpdateEnvironment(t, dt)
    if managers.viewport and managers.viewport:viewports() and self.NewEnvData then
        for key, data in pairs(self.NewEnvData) do
            for _, viewport in pairs(managers.viewport:viewports()) do
                local handler = viewport._env_handler
                local value = viewport:get_environment_value(key)
                local val_to_save = data.value
                
                if CoreClass.type_name(value) == "Vector3" then
                    local new_value
                    if CoreClass.type_name(data.value) == "number" then
                        new_value = Vector3(data.vtype == "x" and data.value or value.x, data.vtype == "y" and data.value or value.y, data.vtype == "z" and data.value or value.z)
                    else
                        new_value = Vector3(data.value.x or value.x, data.value.y or value.y, data.value.z or value.z)
                    end
                    handler:editor_set_value(key, new_value)
                    val_to_save = new_value
                else
                    handler:editor_set_value(key, data.value)
                end
                
                if data.save then
                    self.ModdedData = self.ModdedData or {}
                    self.ModdedData[data.path] = tostring(val_to_save)
                end                
            end
            self.NewEnvData[key] = nil
        end
	end
end

Hooks:Add("BeardLibCreateCustomNodesAndButtons", "ToD_SetupCustomMenus", function(menu_manager, nodes)
    local option_node = MenuHelperPlus:NewNode(nil, {
        name = ToD.OptionsMenu
    })
    MenuHelperPlus:AddButton({
		id = "heist_options",
		title = "heist",
		desc = "heist_desc",
		next_node = ToD.HeistMenu,
        node = option_node,
	})
    
    local heist_node = MenuHelperPlus:NewNode(nil, {
        name = ToD.HeistMenu
    })
    
    local heist_opt_node = MenuHelperPlus:NewNode(nil, {
        name = ToD.HeistOptionsMenu
    })
    
    local heists = deep_clone(tweak_data.levels._level_index)
	for p, k in pairs(heists) do
        if k == "welcome_to_the_jungle_1_night" or k == "election_day_3_skip1" or k == "election_day_3_skip2" or k == "watchdogs_1_night" or k == "watchdogs_2_day" or k == "mia2_new" or k == "crojob3_night" or k == "escape_overpass_night" or k == "escape_cafe_day" or k == "escape_park_day" or k == "driving_escapes_city_day" then
            table.remove(heists, p)
        end
	end
	
	for p, k in pairs(heists) do
        if k == "driving_escapes_industry_day" then
            table.remove(heists, p)
        end
	end
    
    MenuCallbackHandler.night_sky_callback = function(this, item)
		ToD.loaded_options[ToD.CurrentHeist].night_sky_option = item:value()
		ToD:Save()
	end
    
	MenuCallbackHandler.day_sky_callback = function(this, item)
		ToD.loaded_options[ToD.CurrentHeist].day_sky_option = item:value()
		ToD:Save()
    end
    
    MenuCallbackHandler.weather_options_callback = function(this, item)
		ToD.loaded_options[ToD.CurrentHeist].weather_option = item:value()
		ToD:Save()
    end

    MenuCallbackHandler.disable_ToD_clbk = function(this, item)
		ToD.loaded_options[ToD.CurrentHeist].disable_ToD = item:value() == "on" and true or false
		ToD:Save()
    end
    
    MenuCallbackHandler.start_at_day_clbk = function(this, item)
		ToD.loaded_options[ToD.CurrentHeist].start_at_day = item:value() == "on" and true or false
        ToD._set_start_at_day = false
		ToD:Save()
	end
    
    MenuCallbackHandler.reset_heist_options = function(this, item)
        --ToD._set_start_at_day = false
        
        --heist_opt_node:item("night_sky"):set_value(1)
        --heist_opt_node:item("day_sky"):set_value(1)
        heist_opt_node:item("weather"):set_value(1)
        local reset_start_at_day_val = true
        
        local heist = ToD.CurrentHeist
        if ToD.HeistSpecificValues[heist] and ToD.HeistSpecificValues[heist].start_at_day ~= nil then
            reset_start_at_day_val = ToD.HeistSpecificValues[heist].start_at_day
        end
        
        heist_opt_node:item("start_at_day"):set_value(reset_start_at_day_val and "on" or "off")

        
        ToD.loaded_options[ToD.CurrentHeist].start_at_day = heist_opt_node:item("start_at_day"):value() == "on" and true or false

        if ToD.HeistSpecificValues[heist] and ToD.HeistSpecificValues[heist].disable_ToD ~= nil then
            reset_disable_ToD_val = ToD.HeistSpecificValues[heist].disable_ToD
        end
        
        heist_opt_node:item("disable_ToD"):set_value(reset_disable_ToD_val and "on" or "off")

        
        ToD.loaded_options[ToD.CurrentHeist].disable_ToD = heist_opt_node:item("disable_ToD"):value() == "on" and true or false
        ToD:Save()
    end
    
    MenuCallbackHandler.heist_selected_callback = function(this, item)
        ToD.CurrentHeist = item:name()
        --Add Items to new menu
        heist_opt_node:clean_items()
        
        --[[MenuHelperPlus:AddMultipleChoice({
            id = "night_sky",
            title = "night_sky_option",
            desc = "night_sky_desc",
            callback = "night_sky_callback",
            items = ToD.night_sky_options,
            value = ToD.loaded_options[ToD.CurrentHeist].night_sky_option or 1,
            node = heist_opt_node
        })
        
        MenuHelperPlus:AddMultipleChoice({
            id = "day_sky",
            title = "day_sky_option",
            desc = "day_sky_desc",
            callback = "day_sky_callback",
            items = ToD.day_sky_options,
            value = ToD.loaded_options[ToD.CurrentHeist].day_sky_option or 1,
            node = heist_opt_node
        })]]--

        MenuHelperPlus:AddToggle({
            id = "disable_ToD",
            title = "ToD_Disable",
            desc = "disable_desc",
            callback = "disable_ToD_clbk",
            value = ToD.loaded_options[ToD.CurrentHeist].disable_ToD,
            node = heist_opt_node
        })
        
        MenuHelperPlus:AddToggle({
            id = "start_at_day",
            title = "ToD_StartAtDay",
            desc = "dayornight_desc",
            callback = "start_at_day_clbk",
            value = ToD.loaded_options[ToD.CurrentHeist].start_at_day,
            node = heist_opt_node
        })

        MenuHelperPlus:AddMultipleChoice({
            id = "weather",
            title = "weather_option",
            desc = "weather_desc",
            callback = "weather_options_callback",
            items = ToD.weather_options,
            value = ToD.loaded_options[ToD.CurrentHeist].weather_option or 1,
            node = heist_opt_node
        })
        
        MenuHelperPlus:AddButton({
            id = "heist_reset_options",
            title = "heist_reset",
            desc = "heist_reset_desc",
            callback = "reset_heist_options",
            node = heist_opt_node
        })
        
	end
    
	for _, heist in pairs(heists) do
        ToD.loaded_options[heist] = ToD.loaded_options[heist] or {}
        if ToD.loaded_options[heist].disable_ToD == nil then
            ToD.loaded_options[heist].disable_ToD = false
        end
        
        if ToD.loaded_options[heist].start_at_day == nil then
            if ToD.HeistSpecificValues[heist] and ToD.HeistSpecificValues[heist].start_at_day ~= nil then
                ToD.loaded_options[heist].start_at_day = ToD.HeistSpecificValues[heist].start_at_day
            else
                ToD.loaded_options[heist].start_at_day = true
            end
        end

        if ToD.loaded_options[heist].weather_option == 1 then
            return
        elseif ToD.loaded_options[heist].weather_option == 2 then
            if not PackageManager:loaded("packages/narr_glace") then
                PackageManager:load( "packages/narr_glace" )
            end
            -- for _, heist in ipairs(heists) do
                tweak_data.levels[heist].environment_effects = {
                    "rain",
                    "lightning"
                }
                tweak_data.levels[heist].player_style = "raincoat"
            -- end
        elseif ToD.loaded_options[heist].weather_option == 3 then
            if not PackageManager:loaded("packages/lvl_wwh") then
                PackageManager:load( "packages/lvl_wwh" )
            end
            tweak_data.levels[heist].environment_effects = {
                "snow"
            }
            tweak_data.levels[heist].player_style = "winter_suit"
        end
    
         if tweak_data.levels[heist] then
			MenuHelperPlus:AddButton({
				id = heist,
				title = tweak_data.levels[heist].name_id,
				desc = "heist_desc",
				callback = "heist_selected_callback",
				next_node = ToD.HeistOptionsMenu,
				node = heist_node
			})
		end
	end
    
end)

Hooks:Add("MenuManagerBuildCustomMenus", "ToD_CustomMenus", function(menu_manager, nodes)
    MenuHelper:AddMenuItem( nodes["blt_options"], ToD.OptionsMenu, "ToD", "ToD_desc", 1 )
end)

Hooks:Add("LocalizationManagerPostInit", "ToD", function( loc )
	loc:load_localization_file( ToD.mod_path .. "Loc/english.txt")
end)

if not ToD.setup then
	for p, d in pairs(ToD.dofiles) do
		dofile(ModPath .. d)
	end
	ToD:Load_options()
	ToD.setup = true
end

function ToD:TimeCheck(CurrentTime, StartTime, Length)
	if (StartTime + Length) > 24 and (((StartTime + Length) - 24) > CurrentTime or CurrentTime > StartTime) then
		return true
	elseif (StartTime + Length) <= 24 and CurrentTime > StartTime and CurrentTime <  (StartTime + Length) then
		return true
	end
	return false
end

function ToD:GetNewValue(Percentage, day_value, night_value)
	local NewValue
	if CoreClass.type_name(night_value) == "Vector3" then
    
        NewValue = Vector3( (day_value.x * Percentage) + (night_value.x * (1-Percentage)), (day_value.y * Percentage) + (night_value.y * (1-Percentage)), (day_value.z * Percentage) + (night_value.z * (1-Percentage)) )
	else
		NewValue = (day_value * Percentage) + (night_value * (1-Percentage))
	end
	return NewValue
end

local start_at_day = false

function ToD:update(t, dt)
	if not BeardLib then
	return
	end
    local heist_name = managers.job:current_level_id()
    if not self._set_start_at_day and heist_name then
        if ToD.HeistSpecificValues[heist_name] and ToD.HeistSpecificValues[heist_name].start_at_day ~= nil then
            start_at_day = ToD.HeistSpecificValues[heist_name].start_at_day
        end
        
        if ToD.loaded_options[heist_name] then
            start_at_day = ToD.loaded_options[heist_name].start_at_day
        end
        
        self._set_start_at_day = true
    end

    if managers.game_play_central and managers.game_play_central._heist_timer and managers.game_play_central._heist_timer.running then
		ToD.NewEnvData = ToD.NewEnvData or {}
        
        local current_time = Application:time() - managers.game_play_central._heist_timer.start_time + managers.game_play_central._heist_timer.offset_time
		
        local sky_rotation = (current_time / 60) * 9
        if ToD.loaded_options[heist_name] and ToD.loaded_options[heist_name].disable_ToD then 
            
        else 
            ToD.NewEnvData["3c084f67b1da34be"] = {value = sky_rotation, skip_save = true, path = "sky_orientation/rotation"}
        end
        
        local percentage = start_at_day and math.pow(math.cos(sky_rotation * 0.5),2) or math.pow(math.sin(sky_rotation * 0.5),2)
        
        local restricted_time = current_time
        
        while restricted_time > 2400 do
            restricted_time = restricted_time - 2400
        end
        
        local clock_time_24hr = (restricted_time / 100) 
        
        if start_at_day then
            clock_time_24hr = clock_time_24hr + 12
            if clock_time_24hr > 24 then
                clock_time_24hr = clock_time_24hr - 24  
            end
            
        end
        
		local underlays = deep_clone(ToD.Underlays)
		
		if ToD.HeistSpecificValues[heist_name] and ToD.HeistSpecificValues[heist_name].underlays then
			table.merge(underlays, ToD.HeistSpecificValues[heist_name].underlays)
		end
		
		local is_in_underlay
		for i, underlay in pairs(underlays) do
			if i ~= "default" and ToD:TimeCheck(clock_time_24hr, underlay.start_time, underlay.length) then
				--if BeardLib.current_set_underlay ~= i then
                    if managers.dyn_resource then
                        if not managers.dyn_resource:has_resource(Idstring("scene"), Idstring(underlay.path), managers.dyn_resource.DYN_RESOURCES_PACKAGE) then
                            log("not loaded")
                            managers.dyn_resource:load(Idstring("scene"), Idstring(underlay.path), managers.dyn_resource.DYN_RESOURCES_PACKAGE, nil)
                        end
                    end
                    
                    local path  = underlay.path
                    if ToD.loaded_options[heist_name] and ToD.loaded_options[heist_name].disable_ToD then 
                        
                    else
                        ToD.NewEnvData["c268ed7c690ba2b7"] = {value = path, skip_save = true, real_path = "others/underlay", path = "underlay"}
                    end
                    if underlay.global_texture and ToD.loaded_options[heist_name] and ToD.loaded_options[heist_name].disable_ToD then
                        
                    else
						ToD.NewEnvData["c827955ef583d8ce"] = {value = underlay.global_texture, skip_save = true, real_path = "others/global_texture", path = "global_texture"}
					end

					BeardLib.current_set_underlay = i
				--end
				is_in_underlay = true
			end
		end
		
		if ToD.loaded_options[heist_name] and ToD.loaded_options[heist_name].disable_ToD then 
            
        elseif not is_in_underlay then
			ToD.NewEnvData["c268ed7c690ba2b7"] = {value = underlays.default.path, skip_save = true, real_path = "others/underlay", path = "underlay"}
			BeardLib.current_set_underlay = "default"
		end
		
		local variables = deep_clone(ToD.DefaultValues)
		if ToD.HeistSpecificValues[heist_name] and ToD.HeistSpecificValues[heist_name].variables then
			table.merge(variables, ToD.HeistSpecificValues[heist_name].variables)
		end
		
		if underlays[BeardLib.current_set_underlay] and underlays[BeardLib.current_set_underlay].variable_overwrite then
			table.merge(variables, underlays[BeardLib.current_set_underlay].variable_overwrite)
		end
		
		for name, data in pairs(variables) do
			local val_to_set = ToD:GetNewValue(percentage, data.day_value, data.night_value)
			
			local parts = string.split(name, "/")
			if not data.disabled then
				ToD.NewEnvData[data.key] = {value = val_to_set, skip_save = true, real_path = name, path = parts[2]}
			end
		end
    end
end

