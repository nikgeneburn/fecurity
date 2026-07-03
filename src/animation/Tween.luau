--!strict

local TweenService = game:GetService("TweenService")

local Tween = {}

function Tween.Play(Object: Instance, Time: number, Props: { [string]: any }, Style: Enum.EasingStyle?, Direction: Enum.EasingDirection?)
    local Info = TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out)
    local Created = TweenService:Create(Object, Info, Props)
    Created:Play()
    return Created
end

function Tween.Press(Object: GuiObject, Color: Color3, Base: Color3)
    Tween.Play(Object, 0.08, { BackgroundColor3 = Color })
    task.delay(0.1, function()
        if Object and Object.Parent then
            Tween.Play(Object, 0.12, { BackgroundColor3 = Base })
        end
    end)
end

return Tween

