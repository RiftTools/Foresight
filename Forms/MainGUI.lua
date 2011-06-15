local Libra = LibStub:GetLibrary('Libra-alpha', true)
if not Libra then return end

local context = UI.CreateContext("Context")

Foresight_MainGUI = Libra.UI.Timeline:Create(context)
local MainGUI = Foresight_MainGUI 

MainGUI.border.size = 2
MainGUI.multi_timeline = true

MainGUI:SetMax(20)

MainGUI.background:SetBackgroundColor(0,0,0,0.15)

MainGUI.WaitingBox = Libra.UI.SmartGrid:Create(MainGUI)
MainGUI.WaitingBox:SetPoint('BOTTOMLEFT', MainGUI, 'TOPLEFT')
MainGUI.WaitingBox.border.size = 2

MainGUI.ActiveBox = Libra.UI.FrameManager:Create('Active Box Frame', MainGUI)
MainGUI.ActiveBox.background = Libra.UI.FrameManager:Create('Frame', MainGUI.ActiveBox)
MainGUI.ActiveBox:SetBackgroundColor(0,0,0,0.4)
MainGUI.ActiveBox.background:SetBackgroundColor(0.2, 0.2, 0.2, 0.9)
MainGUI.ActiveBox:SetHeight(48 + (MainGUI.border.size*2))
MainGUI.ActiveBox:SetWidth(48 + (MainGUI.border.size*2))
MainGUI.ActiveBox:SetPoint('TOPRIGHT', MainGUI, 'TOPLEFT', 0, (MainGUI:GetHeight() - MainGUI.ActiveBox:GetHeight()) / 2)
MainGUI.ActiveBox.background:SetPoint('TOPLEFT', MainGUI.ActiveBox, 'TOPLEFT', MainGUI.border.size, MainGUI.border.size)
MainGUI.ActiveBox.background:SetPoint('BOTTOMLEFT', MainGUI.ActiveBox, 'BOTTOMLEFT', MainGUI.border.size, MainGUI.border.size)
MainGUI.ActiveBox.background:SetPoint('BOTTOMRIGHT', MainGUI.ActiveBox, 'BOTTOMRIGHT', -MainGUI.border.size, -MainGUI.border.size)
MainGUI.ActiveBox:SetLayer(10)

MainGUI.ActiveBox.background:SetBackgroundColor(0,0,0,0.15)

-- Cache the Refresh methods we plan to override
MainGUI._Refresh = MainGUI.Refresh
MainGUI.WaitingBox._Refresh = MainGUI.WaitingBox.Refresh

-------------------------------------
-- Build the Main window
-------------------------------------

function MainGUI:Show()
	self:SetVisible(true)
end

function MainGUI:Hide()
	self:SetVisible(false)
end

function MainGUI:Refresh()	
	MainGUI:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', Foresight_Config.x, Foresight_Config.y)
	MainGUI:SetWidth(Foresight_Config.width)
	self:_Refresh()
end

function MainGUI.WaitingBox:Add(id, value)
	if not MainGUI.ReadyAbilities[id] then
		MainGUI.ReadyAbilities[id] = value
		MainGUI.ReadyAbilities[id].timestamp = Inspect.System.Time()
		self:Refresh()
	end
end

function MainGUI.WaitingBox:Remove(id)
	if MainGUI.ReadyAbilities[id] then
		MainGUI.ReadyAbilities[id]:SetVisible(false)
		Libra.UI.FrameManager:Recycle(MainGUI.ReadyAbilities[id])
		MainGUI.ReadyAbilities[id] = nil
		self:RemoveCell(id)
	end
	self:_Refresh()
	self:Refresh()
end

function MainGUI.WaitingBox:Refresh()
	local real_waiting_count = 0
	for k,v in pairs(MainGUI.ReadyAbilities) do
		real_waiting_count = real_waiting_count + 1
	end
	if real_waiting_count == 1 then
		self.cell_count = 0
	end

	if self.cell_count > 0 then
		self:SetVisible(true)
	else
		self:SetVisible(false)
	end
	
	local primary_key, primary_val = false, 0
	for k, v in pairs(MainGUI.ReadyAbilities) do
		v.is_primary = false
	end
	for k, v in pairs(MainGUI.ReadyAbilities) do
		if v.timestamp > primary_val then
			v.is_primary = false
			primary_val = v.timestamp
			primary_key = k
		end
	end
	if primary_key then
		MainGUI.ReadyAbilities[primary_key].is_primary = true
	end

	for id, entry in pairs(MainGUI.ReadyAbilities) do
	
		entry:SetVisible(false)
		
		if entry.payload.text then
			Libra.UI.FrameManager:Recycle(entry.payload.text)
			Libra.UI.FrameManager:Recycle(entry.payload.text.shadow)
			entry.payload.text = nil
		end
		
		-- Sanitize the entries
		entry:SetBackgroundColor(0,1,0,1)
		entry.payload:SetPoint('TOPCENTER', entry, 'TOPCENTER')
		entry.payload:SetPoint('BOTTOMCENTER', entry, 'BOTTOMCENTER')
		entry.payload:SetPoint('CENTER', entry, 'CENTER')
		entry.payload:SetAllPoints(entry)
		entry.payload:SetVisible(true)
		
		if entry.is_primary then
			entry:SetParent(MainGUI.ActiveBox.background)
			entry.payload:SetWidth(48)
			entry.payload:SetHeight(48)
			entry:SetAllPoints(MainGUI.ActiveBox.background)
			entry.payload:SetPoint('TOPCENTER', MainGUI.ActiveBox.background, 'TOPCENTER')
			entry.payload:SetPoint('BOTTOMCENTER', MainGUI.ActiveBox.background, 'BOTTOMCENTER')
			entry.payload:SetPoint('CENTER', MainGUI.ActiveBox.background, 'CENTER')
		else
			entry.payload:SetWidth(24)
			entry.payload:SetHeight(24)
			self:AddCell(id, entry)
		end
		
		entry:SetVisible(true)
	end
	
	self:_Refresh()
end

--
-- Formats a number for time
--
function MainGUI:FormatTime(time_val)
	local result = false

	if time_val then
		if time_val > 3600 then
			result = string.format("%d:%02d:%02d", time_val / 3600, time_val / 60 % 60, time_val % 60)
		elseif time_val > 60 then
			result = string.format("%d:%02d", time_val / 60, time_val % 60)
		elseif time_val > 10 then
			result = string.format("%2d", time_val % 60)
		else
			result = string.format("%.1f", time_val)
		end
	else
		result = tostring(0)
	end
	
	return result
end

--
-- Add a Cooldown tracker
--
-- @param   id      id        Id of the ability
function MainGUI:AddCooldown(id)
	local ability = Inspect.Ability.Detail(id)
	
	if not self.Entries[id] and not self.ReadyAbilities[id] then
		-- Adding
		local icon = Libra.UI.FrameManager:Create('Texture', MainGUI.background)
		local text = Libra.UI.FrameManager:Create('Text', MainGUI.background)
		text.shadow = Libra.UI.FrameManager:Create('Text', MainGUI.background)
		
		icon:SetTexture('Rift', ability.icon)
		icon:SetHeight(34)
		icon:SetWidth(34)
		icon:SetLayer(4)
		icon.text = text
		text.shadow:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 0, 2)
		text:SetPoint('BOTTOMRIGHT', text.shadow, 'BOTTOMRIGHT', -1, -1)
		text:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		text.shadow:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		text.shadow:SetParent(icon)
		text:SetParent(text.shadow)
		text:SetFontSize(12)
		text.shadow:SetFontSize(12)
		text:ResizeToText()
		text.shadow:ResizeToText()
		text.shadow:SetFontColor(0,0,0,1)
		MainGUI:AddEntry(id, icon, ability.currentCooldownRemaining, 0, ability.cooldown)

	elseif not self.Entries[id] and self.ReadyAbilities[id] then
		-- Move from waiting to on cooldown
		self.WaitingBox:Remove(id)
		local icon = Libra.UI.FrameManager:Create('Texture', MainGUI.background)
		local text = Libra.UI.FrameManager:Create('Text', MainGUI.background)
		text.shadow = Libra.UI.FrameManager:Create('Text', MainGUI.background)
		icon:SetTexture('Rift', ability.icon)
		icon:SetHeight(34)
		icon:SetWidth(34)
		icon:SetLayer(4)
		icon.text = text
		text.shadow:SetPoint('BOTTOMRIGHT', icon, 'BOTTOMRIGHT', 0, 2)
		text:SetPoint('BOTTOMRIGHT', text.shadow, 'BOTTOMRIGHT', -1, -1)
		text:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		text.shadow:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		text.shadow:SetParent(icon)
		text:SetParent(text.shadow)
		text:SetFontSize(12)
		text.shadow:SetFontSize(12)
		text:ResizeToText()
		text.shadow:ResizeToText()
		text.shadow:SetFontColor(0,0,0,1)
		MainGUI:AddEntry(id, icon, ability.currentCooldownRemaining, 0, ability.cooldown)
		
	elseif self.Entries[id] and not self.ReadyAbilities[id] then
		self.Entries[id].value = ability.currentCooldownRemaining
		self.Entries[id].payload.text:SetText(ability.currentCooldownRemaining)
		self.Entries[id].payload.text.shadow:SetText(ability.currentCooldownRemaining)
		self.Entries[id].payload.text:ResizeToText()
		self.Entries[id].payload.text.shadow:ResizeToText()
	end
end

--
-- Update a Cooldown tracker
--
-- @param   id      id        Id of the ability
function MainGUI:UpdateCooldown(id)
	if MainGUI.Entries[id] then
		local ability = Inspect.Ability.Detail(id)
		self.Entries[id].value = ability.currentCooldownRemaining
		self.Entries[id].payload.text:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		self.Entries[id].payload.text.shadow:SetText( self:FormatTime(ability.currentCooldownRemaining) )
		self.Entries[id].payload.text:ResizeToText()
		self.Entries[id].payload.text.shadow:ResizeToText()
	end
end