--!strict

export type Widget = {
    Root: Instance,
    Flag: string?,
    Value: any,
    SetValue: (Widget, any, boolean?) -> (),
    Destroy: (Widget) -> (),
}

return {}

