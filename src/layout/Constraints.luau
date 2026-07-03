--!strict

local Constraints = {}

function Constraints.Fixed(Parent: Instance, Min: Vector2?, Max: Vector2?)
    local Constraint = Instance.new("UISizeConstraint")
    if Min then
        Constraint.MinSize = Min
    end
    if Max then
        Constraint.MaxSize = Max
    end
    Constraint.Parent = Parent
    return Constraint
end

return Constraints

