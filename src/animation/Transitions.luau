--!strict

local Tween = require("@fec/animation/Tween")

local Transitions = {}

function Transitions.FadeIn(Object: GuiObject)
    Object.Visible = true
    Object.BackgroundTransparency = 1
    Tween.Play(Object, 0.15, { BackgroundTransparency = 0 })
end

function Transitions.FadeOut(Object: GuiObject)
    local Created = Tween.Play(Object, 0.15, { BackgroundTransparency = 1 })
    Created.Completed:Once(function()
        if Object and Object.Parent then
            Object.Visible = false
        end
    end)
end

function Transitions.PanelIn(Object: GuiObject, Delay: number?)
    local Target = Object.Position
    Object.Visible = true
    Object.Position = Target + UDim2.fromOffset(0, 7)
    Object.BackgroundTransparency = 1
    task.delay(Delay or 0, function()
        if Object and Object.Parent then
            Tween.Play(Object, 0.16, {
                Position = Target,
                BackgroundTransparency = 0,
            })
        end
    end)
end

function Transitions.PanelOut(Object: GuiObject, Delay: number?)
    local Target = Object.Position
    task.delay(Delay or 0, function()
        if not Object or not Object.Parent then
            return
        end
        local Created = Tween.Play(Object, 0.12, {
            Position = Target + UDim2.fromOffset(0, 7),
            BackgroundTransparency = 1,
        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)
        Created.Completed:Once(function()
            if Object and Object.Parent then
                Object.Visible = false
                Object.Position = Target
                Object.BackgroundTransparency = 0
            end
        end)
    end)
end

return Transitions
