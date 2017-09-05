local toc, KL = ...
local AddonId = toc.identifier
local Lang = Library.Translate

function KL.buttonMover(buttonName, parentFrame, imgRootUp, imgNameUp, imgRootDown, imgNameDown, KL_mouseDataX, KL_mouseDataY, KL_buttonActive)
    local   buttonName = UI.CreateFrame("Texture", buttonName, parentFrame)
    if not MINIMAPDOCKER then
        buttonName:SetPoint("TOPLEFT", parentFrame, "TOPLEFT", KL_mouseDataX, KL_mouseDataY)
	end


            if imgNameDown then
                buttonName:SetTexture(imgRootDown, imgNameDown)
            end

            if KL_buttonActive == true then
                buttonName:SetVisible(true)
            else                
                buttonName:SetVisible(false)
            end

            buttonName:EventAttach(Event.UI.Input.Mouse.Left.Click, function(self)
                if imgNameUp then
                    self:SetTexture(imgRootUp, imgNameUp)
                end
                if not KL.frame:GetVisible() then
                    KL.show()
                else
                    KL.hide()
                end
            end, "dragLeftClick")

            buttonName:EventAttach(Event.UI.Input.Mouse.Cursor.In, function(self)
                if imgNameUp then
                    self:SetTexture(imgRootUp, imgNameUp)
                end
            end, "dragCursorIn")

            buttonName:EventAttach(Event.UI.Input.Mouse.Cursor.Out, function(self)
                if imgNameDown then
                    self:SetTexture(imgRootDown, imgNameDown)
                end
            end, "dragCursorOut") 

            if MINIMAPDOCKER then
                MINIMAPDOCKER.Register(AddonId, buttonName)
            else
                KL.buttonMovable(buttonName, parentFrame)
            end

    return buttonName
end

function KL.buttonMovable(buttonName, parentFrame)
    if parentFrame == nil then
        parentFrame    = buttonName
    end

    function buttonName.Event:RightDown()
        InspectMouse    = Inspect.Mouse()
        self.MouseDown  = true
        self.MyStartX   = parentFrame:GetLeft()
        self.MyStartY   = parentFrame:GetTop()
        self.StartX     = KL_mouseData.x - self.MyStartX
        self.StartY     = KL_mouseData.y - self.MyStartY
    end

    function buttonName.Event:MouseMove(mouseX, mouseY)
        if self.MouseDown then
            parentFrame:SetPoint("TOPLEFT", UIParent, "TOPLEFT", (mouseX - self.StartX), (mouseY - self.StartY))
            -- Nouvelles coordonnées à enregistrer --
            KL_mouseData.x = mouseX
            KL_mouseData.y = mouseY
        end
    end

    function buttonName.Event:RightUp()
        self.MouseDown  = false
    end
end

function KL.PopUp(DialogContext, DialogText, DialogSize, DialogCmd)
    local   PopUpContext = UI.CreateContext(DialogContext)
            PopUpContext:SetPoint("CENTER", UIParent, "CENTERTOP", 0, 100)
            PopUpContext:SetStrata("topmost")

            -- Création de la barre permanente --
            PopUpdialog = UI.CreateFrame("Texture", AddonId.."_PopUpdialog", PopUpContext)
            PopUpdialog:SetVisible(true)
            PopUpdialog:SetWidth(350)
            PopUpdialog:SetHeight(100)
            PopUpdialog:SetTexture("Rift", "ItemToolTip_I75.dds")
            PopUpdialog:SetPoint("CENTER", UIParent, "CENTERTOP", 0, 100)

            PopUpText = UI.CreateFrame("Text", AddonId.."_ChannelText", PopUpdialog)
            PopUpText:SetText(DialogText)
            PopUpText:SetFontSize(DialogSize)
            PopUpText:SetPoint("TOPCENTER", PopUpdialog, "TOPCENTER", 0, 15)

            PopUpButtonYes = UI.CreateFrame("RiftButton", AddonId.."_PopUpButtonYes", PopUpdialog)
            PopUpButtonYes:SetText(Lang.YES)
            PopUpButtonYes:SetPoint("BOTTOMLEFT", PopUpdialog, "BOTTOMLEFT", 20, -10)

            PopUpButtonNo = UI.CreateFrame("RiftButton", AddonId.."_PopUpButtonNo", PopUpdialog)
            PopUpButtonNo:SetText(Lang.NO)
            PopUpButtonNo:SetPoint("BOTTOMRIGHT", PopUpdialog, "BOTTOMRIGHT", -20, -10)

            PopUpContext:SetSecureMode("restricted")
            PopUpdialog:SetSecureMode("restricted")
            PopUpButtonYes:SetSecureMode("restricted")

            PopUpButtonYes:EventAttach(Event.UI.Button.Left.Press, function(self)
                PopUpContext:SetVisible(false)
                self:EventMacroSet(Event.UI.Input.Mouse.Left.Click, DialogCmd)
            end, "Event.UI.Button.Left.Press")

            PopUpButtonNo:EventAttach(Event.UI.Button.Left.Press, function()
                PopUpContext:SetVisible(false)
            end, "Event.UI.Button.Left.Press")
end