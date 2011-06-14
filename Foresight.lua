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
	hide_when_done = true
}


TEMPCOUNTER = 0

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
local function _RefreshService()
	if Libra.Utils.Registry.Entries['CACHE_ABILITIES'] then
		for id, ability in pairs(Libra.Utils.Registry.Entries['CACHE_ABILITIES']) do
			if MainGUI.Entries[id] then
				MainGUI:UpdateCooldown(id)
			end
		end
	end
	
	if Inspect.System.Time() > TEMPCOUNTER + 30 then
		for name, value in pairs(Libra.Utils.Registry.Entries['STAT_FRAME_MANAGER']) do
			print('FM: [' .. name .. '] [' .. value .. ']')
		end
		TEMPCOUNTER = Inspect.System.Time()
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
			tmp.timer = Libra.Utils.Timer:Create(id, 15, _DestroyWaiting, id)
			MainGUI.WaitingBox:Add(id, tmp)
		end		
	end
end

table.insert(Event.Ability.Cooldown.Begin, { _MonitorAbilityCooldowns, "Foresight", 'CooldownDetection' })
table.insert(Event.Ability.Cooldown.End, { _ShowReadyCooldowns, "Foresight", 'CooldownDetection' })

-- Register our slash command
local function _SlashCommand(args)
	local cmd = args:match("(%a+)")
	cmd = tostring(cmd)
	
	if cmd == 'width' then
		if not x then
			print("Example: /foresight width 220")
		end
		Foresight_Config.width = x
		
	elseif cmd == 'pos' then
		if x and y then
			Foresight_Config.x = x
			Foresight_Config.y = y
		else
			print("Example: /foresight pos 200 100")	
		end
	elseif cmd == 'add' then
			
	end
end
table.insert(Command.Slash.Register("Foresight"), { _SlashCommand, "Foresight", 'config' })
