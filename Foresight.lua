local Libra = LibStub:GetLibrary('Libra-alpha', true)
if not Libra then
	print('Foresight Dependancy Missing: [Libra]')
	return
end

local MainGUI    = Foresight_MainGUI
local OptionsGUI = Foresight_OptionsGUI


MainGUI.ReadyAbilities = {}

Foresight_Config = {
	x = 500,
	y = 500,
	width = 220,
	own_timelines = true,
	ignore_list = { a = true, b = false},
	hold_time = 15
}

OptionsGUI.form.barwidth:SetValue(Foresight_Config.width)
OptionsGUI.form.window_x:SetValue(Foresight_Config.x)
OptionsGUI.form.window_y:SetValue(Foresight_Config.y)
OptionsGUI.form.own_timelines:Toggle(Foresight_Config.own_timelines)

---------------------------------
-- OptionsGUI Functions
---------------------------------
function OptionsGUI.form.bt_Save.Event:LeftDown()
	print('Applied settings')
	Foresight_Config.width = OptionsGUI.form.barwidth:GetValue()
	Foresight_Config.x = OptionsGUI.form.window_x:GetValue()
	Foresight_Config.y = OptionsGUI.form.window_y:GetValue()
	Foresight_Config.own_timelines = OptionsGUI.form.own_timelines:GetValue()
	Foresight_Config.hold_time = OptionsGUI.form.hold_time:GetValue()
	MainGUI.multi_timeline = OptionsGUI.form.own_timelines:GetValue()
	MainGUI:Refresh()
end

function OptionsGUI:Show()
	OptionsGUI.form.barwidth:SetValue(Foresight_Config.width or 0)
	OptionsGUI.form.window_x:SetValue(Foresight_Config.x or 0)
	OptionsGUI.form.window_y:SetValue(Foresight_Config.y or 0)
	OptionsGUI.form.own_timelines:Toggle(Foresight_Config.own_timelines or true)
	OptionsGUI.form.hold_time:SetValue(Foresight_Config.hold_time or 0)
	OptionsGUI:_Show()
end

-- 
-- 
--
local function _DestroyWaiting(id)
	-- Less then ideal, but sometimes an ability gets removed 
	-- (by using it) before it's timer is up, in this case, it's 
	-- already recycled and removed.
	if id then
		MainGUI.WaitingBox:Remove(id)
	end
end

--
-- This handles checking our trackers
--
local _refresh_counter = 0
local _debug_counter = 0
local function _RefreshService()
	local now = Inspect.System.Time()
	
	if now >= _refresh_counter then
		if Libra.Utils.Registry.Entries['CACHE_ABILITIES'] then
			for id, ability in pairs(Libra.Utils.Registry.Entries['CACHE_ABILITIES']) do
				if MainGUI.Entries[id] then
					MainGUI:UpdateCooldown(id)
				end
			end
		end
		_refresh_counter = now + 0.1--0.1
	end
	
	if Inspect.System.Time() > _debug_counter then
		for name, value in pairs(Libra.Utils.Registry.Entries['STAT_FRAME_MANAGER']) do
			--print('FM: [' .. name .. '] [' .. value .. ']')
		end
		_debug_counter = now + 30
	end
	
	MainGUI:Refresh()
end

--MainGUI.WaitingBox:_Refresh()
MainGUI.WaitingBox:Refresh()
MainGUI:Show()

-- Register our service
table.insert(Event.System.Update.Begin, { _RefreshService, 'Foresight', 'RefreshService' })

function _MonitorAbilityCooldowns(cooldowns)
	
	for id, cooldown in pairs(cooldowns) do
		-- TODO - delay this caching
		local ability = Inspect.Ability.Detail(id)
		
		if ((ability.cooldown ~= nil) and 
		(ability.currentCooldown <= ability.cooldown + 0.0001) and
		(ability.currentCooldown >= ability.cooldown - 0.0001)) then
		
			MainGUI:AddCooldown(id, true)

			if not Libra.Utils.Registry:Set('CACHE_ABILITIES', id) then
				Libra.Utils.Registry:Set('CACHE_ABILITIES', id, ability)
			end
		
		end
	end
end

function _ShowReadyCooldowns(cooldowns)
	for id, cooldown in pairs(cooldowns) do
		if MainGUI.Entries[id] then
			local tmp = MainGUI.Entries[id]
			MainGUI:RemoveEntry(id)
			-- Add a timer to it so we know when to get rid of it
			tmp.timer = Libra.Utils.Timer:Create(id, Foresight_Config.hold_time or 15, _DestroyWaiting, id)
			MainGUI.WaitingBox:Add(id, tmp)
		end		
	end
end

table.insert(Event.Ability.Cooldown.Begin, { _MonitorAbilityCooldowns, "Foresight", 'CooldownDetection' })
table.insert(Event.Ability.Cooldown.End, { _ShowReadyCooldowns, "Foresight", 'CooldownDetection' })

-- Register our slash command
local function _SlashCommand(args)
	OptionsGUI:Show()
end
table.insert(Command.Slash.Register("Foresight"), { _SlashCommand, "Foresight", 'config' })
