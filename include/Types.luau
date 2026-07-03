--!strict

export type Callback = (...any) -> ()

export type WindowOptions = {
    Title: string?,
    Subtitle: string?,
    Size: UDim2?,
    Accent: Color3?,
    Theme: string?,
    MenuKey: any?,
    ToggleKey: any?,
}

export type TabOptions = {
    Icon: string?,
}

export type Window = {
    AddTab: (Window, string, TabOptions?) -> any,
    SetMenuKey: (Window, any) -> Window,
    Open: (Window) -> boolean,
    Close: (Window) -> boolean,
    Toggle: (Window) -> boolean,
    Destroy: (Window) -> (),
}

export type Library = {
    Flags: { [string]: any },
    CreateWindow: (Library, WindowOptions) -> Window,
    Notify: (Library, { [string]: any }) -> any?,
    AddWarning: (Library, { [string]: any }) -> any?,
    SaveConfig: (Library, string) -> boolean,
    LoadConfig: (Library, string, boolean?) -> boolean,
    GetConfigs: (Library) -> { string },
    SetAccent: (Library, Color3) -> (),
    SetTheme: (Library, any) -> boolean,
    SetAssetBaseUrl: (Library, string) -> boolean,
    Open: (Library) -> (),
    Close: (Library) -> (),
    Toggle: (Library) -> (),
    Unload: (Library) -> (),
}

export type WidgetOptions = {
    Text: string?,
    Hint: string?,
    Flag: string?,
    Default: any?,
    Value: any?,
    Callback: Callback?,
    Changed: Callback?,
    OnChanged: Callback?,
    OnPressed: Callback?,
    SkipFlag: boolean?,
}

return {}
