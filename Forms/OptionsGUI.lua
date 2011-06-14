local Libra = LibStub:GetLibrary('Libra-alpha', true)
if not Libra then return end

Foresight_OptionsGUI = Libra.UI.Window:Create(UIParent)
local OptionsGUI = Foresight_OptionsGUI

-------------------------------------
-- Build the Options window
-------------------------------------
OptionsGUI:SetTitle('Foresight - Options')
OptionsGUI.content.padding = 15

local form = Libra.UI.FrameManager:Create('Frame', OptionsGUI.content)

form.row1 = Libra.UI.FrameManager:Create('Frame', form)
form.row2 = Libra.UI.FrameManager:Create('Frame', form)
form.row3 = Libra.UI.FrameManager:Create('Frame', form)
form.row4 = Libra.UI.FrameManager:Create('Frame', form)
form.row5 = Libra.UI.FrameManager:Create('Frame', form)

form.row1:SetHeight(44)
form.row2:SetHeight(44)
form.row3:SetHeight(44)
form.row4:SetHeight(44)
form.row5:SetHeight(44)

form.row1.label = Libra.UI.FrameManager:Create('Text', form.row1)
form.row1.label:SetText('Bar Width:')
form.row1.label:SetFontSize(18)
form.row1.label:ResizeToText()
form.barwidth = Libra.UI.NumberBox:Create(form.row1)
form.barwidth:SetPoint('TOPRIGHT', form.row1, 'TOPRIGHT')

form.row2.label = Libra.UI.FrameManager:Create('Text', form.row2)
form.row2.label:SetText('Window Position X:')
form.row2.label:SetFontSize(18)
form.row2.label:ResizeToText()
form.window_x = Libra.UI.NumberBox:Create(form.row2)
form.window_x:SetPoint('TOPRIGHT', form.row2, 'TOPRIGHT')

form.row3.label = Libra.UI.FrameManager:Create('Text', form.row3)
form.row3.label:SetText('Window Position Y:')
form.row3.label:SetFontSize(18)
form.row3.label:ResizeToText()
form.window_y = Libra.UI.NumberBox:Create(form.row3)
form.window_y:SetPoint('TOPRIGHT', form.row3, 'TOPRIGHT')

form.row4.label = Libra.UI.FrameManager:Create('Text', form.row4)
form.row4.label:SetText('Hide timers when finished?')
form.row4.label:SetFontSize(18)
form.row4.label:ResizeToText()
form.hide_when_done = Libra.UI.Toggle:Create(form.row4)

form.bt_Save = Libra.UI.Button:Create(form.row5)
form.bt_Save:SetPoint('CENTER', form.row5, 'CENTER', 0, 6)
form.bt_Save:SetText(' Apply ')

form:SetPoint('TOPLEFT', OptionsGUI.content, 'TOPLEFT')
form:SetPoint('BOTTOMRIGHT', OptionsGUI.content, 'BOTTOMRIGHT')

form.row1:SetPoint('TOPLEFT', form, 'TOPLEFT')
form.row1:SetPoint('TOPRIGHT', form, 'TOPRIGHT')
form.row1.label:SetPoint('TOPLEFT', form.row1, 'TOPLEFT', 0, (form.row1:GetHeight() - form.row1.label:GetHeight()) / 2)
form.row2:SetPoint('TOPLEFT', form.row1, 'BOTTOMLEFT')
form.row2:SetPoint('TOPRIGHT', form.row1, 'BOTTOMRIGHT')
form.row2.label:SetPoint('TOPLEFT', form.row2, 'TOPLEFT', 0, (form.row2:GetHeight() - form.row2.label:GetHeight()) / 2)
form.row3:SetPoint('TOPLEFT', form.row2, 'BOTTOMLEFT')
form.row3:SetPoint('TOPRIGHT', form.row2, 'BOTTOMRIGHT')
form.row3.label:SetPoint('TOPLEFT', form.row3, 'TOPLEFT', 0, (form.row3:GetHeight() - form.row3.label:GetHeight()) / 2)
form.row4:SetPoint('TOPRIGHT', form.row3, 'BOTTOMRIGHT')
form.row4:SetPoint('TOPLEFT', form.row3, 'BOTTOMLEFT')
form.row4.label:SetPoint('TOPLEFT', form.row4, 'TOPLEFT', 0, (form.row4:GetHeight() - form.row4.label:GetHeight()) / 2)
form.row5:SetPoint('TOPLEFT', form.row4, 'BOTTOMLEFT')
form.row5:SetPoint('TOPRIGHT', form.row4, 'BOTTOMRIGHT')

form.hide_when_done:SetPoint('TOPRIGHT', form.row4, 'TOPRIGHT', 0, (form.row4:GetHeight() - form.hide_when_done:GetHeight()) / 2)

OptionsGUI:SetContent(form)
OptionsGUI.form = form
OptionsGUI:Resize( form.row1:GetHeight() + form.row2:GetHeight() + form.row3:GetHeight() + form.row4:GetHeight() + form.row5:GetHeight() +(OptionsGUI.content.padding * 2), 400)
OptionsGUI:SetPoint('TOPLEFT', UIParent, 'TOPLEFT', (UIParent:GetWidth() / 2) - (OptionsGUI:GetWidth() / 2), (UIParent:GetHeight() / 2) - (OptionsGUI:GetHeight() / 2))



---------------------------------
-- OptionsGUI Functions
---------------------------------
function OptionsGUI.form.bt_Save.Event:LeftDown()
	Foresight_Config.width = OptionsGUI.form.barwidth:GetValue()
	Foresight_Config.x = OptionsGUI.form.window_x:GetValue()
	Foresight_Config.y = OptionsGUI.form.window_y:GetValue()
	Foresight_Config.hide_when_done = OptionsGUI.form.hide_when_done:GetValue()
	Refresh()
end