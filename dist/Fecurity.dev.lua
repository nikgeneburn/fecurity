local __DARKLUA_BUNDLE_MODULES = {
    cache = {}::any,
}

do
    do
        local function __modImpl()
            local Logger = {}

            Logger.Prefix = '[Fecurity]'
            Logger.Verbose = false
            Logger.LogFile = 'Fecurity/Logs/fecurity.log'
            Logger.MaxLogBytes = 24000

            local function Join(...: any): string
                local Parts = {}

                for Index = 1, select('#', ...)do
                    table.insert(Parts, tostring(select(Index, ...)))
                end

                return table.concat(Parts, ' ')
            end
            local function EnsureLogFolder(): boolean
                if type(isfolder) ~= 'function' or type(makefolder) ~= 'function' then
                    return false
                end

                local function FolderExists(Folder: string): boolean
                    local Ok, Exists = pcall(isfolder, Folder)

                    return Ok and Exists == true
                end
                local function EnsureFolder(Folder: string): boolean
                    if FolderExists(Folder) then
                        return true
                    end

                    local Ok = pcall(makefolder, Folder)

                    return Ok and FolderExists(Folder)
                end

                if not EnsureFolder('Fecurity') then
                    return false
                end
                if not EnsureFolder('Fecurity/Logs') then
                    return false
                end

                return true
            end
            local function Append(Level: string, ...: any)
                if type(writefile) ~= 'function' or type(readfile) ~= 'function' or type(isfile) ~= 'function' then
                    return
                end

                pcall(function()
                    if not EnsureLogFolder() then
                        return
                    end

                    local Existing = ''

                    if isfile(Logger.LogFile) then
                        local Ok, Body = pcall(readfile, Logger.LogFile)

                        if Ok and type(Body) == 'string' then
                            Existing = Body
                        end
                    end

                    local Stamp = os.date('%Y-%m-%d %H:%M:%S')
                    local Line = ('%s %s %s %s\n'):format(Stamp, Logger.Prefix, Level, Join(...))
                    local Next = Existing .. Line

                    if #Next > Logger.MaxLogBytes then
                        Next = string.sub(Next, #Next - Logger.MaxLogBytes + 1)
                    end

                    pcall(writefile, Logger.LogFile, Next)
                end)
            end

            function Logger.SetVerbose(Value: boolean)
                Logger.Verbose = Value
            end
            function Logger.Info(...: any)
                Append('[Info]', ...)
                print(Logger.Prefix, ...)
            end
            function Logger.Warn(...: any)
                Append('[Warn]', ...)
                warn(Logger.Prefix, ...)
            end
            function Logger.Debug(...: any)
                if Logger.Verbose then
                    Append('[Debug]', ...)
                    print(Logger.Prefix, '[Debug]', ...)
                end
            end
            function Logger.Error(Scope: string, Err: any)
                Append('[Error]', Scope, '->', tostring(Err))
                warn(Logger.Prefix, '[Error]', Scope, '->', tostring(Err))
            end

            return Logger
        end

        function __DARKLUA_BUNDLE_MODULES.a(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.a

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.a = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Logger = __DARKLUA_BUNDLE_MODULES.a()
            local Registry = {}
            local Key = '__FECURITY_UI__'

            local function Environment(): {[any]: any}
                if getgenv then
                    local Ok, Env = pcall(getgenv)

                    if Ok and type(Env) == 'table' then
                        return Env
                    end
                end

                return _G
            end

            function Registry.Get(): any?
                return Environment()[Key]
            end
            function Registry.Set(Value: any)
                Environment()[Key] = Value
            end
            function Registry.Clear(Owner: any?)
                local Env = Environment()

                if Owner == nil or Env[Key] == Owner then
                    Env[Key] = nil
                end
            end
            function Registry.Claim(Version: string, Teardown: () -> ()): any
                local Previous = Registry.Get()

                if Previous and Previous.Unload then
                    Logger.Info(('Reloading previous Fecurity session %s'):format(tostring(Previous.Version)))
                    pcall(function()
                        Previous:Unload()
                    end)
                elseif Previous and Previous.Teardown then
                    pcall(Previous.Teardown)
                end

                local Entry = {
                    Version = Version,
                    Teardown = Teardown,
                }

                Registry.Set(Entry)

                return Entry
            end

            return Registry
        end

        function __DARKLUA_BUNDLE_MODULES.b(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.b

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.b = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Logger = __DARKLUA_BUNDLE_MODULES.a()
            local Safety = {}

            function Safety.Try(Scope: string, Fn: (...any) -> ...any, ...): (boolean,...any)
                local Result = table.pack(pcall(Fn, ...))

                if not Result[1] then
                    Logger.Error(Scope, Result[2])

                    return false
                end

                return true, table.unpack(Result, 2, Result.n)
            end
            function Safety.Callback(Scope: string, Fn: ((...any) -> ...any)?, ...)
                if not Fn then
                    return
                end

                local Ok, Err = pcall(Fn, ...)

                if not Ok then
                    Logger.Error(Scope, Err)
                end
            end

            return Safety
        end

        function __DARKLUA_BUNDLE_MODULES.c(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.c

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.c = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Runtime = {}

            function Runtime.GetPlayerGui(): Instance
                local Players = game:GetService('Players')
                local LocalPlayer = Players.LocalPlayer

                return LocalPlayer:WaitForChild('PlayerGui')
            end
            function Runtime.GetGuiParent(): Instance
                local Ok, CoreGui = pcall(function()
                    return game:GetService('CoreGui')
                end)

                if Ok and CoreGui then
                    return CoreGui
                end

                return Runtime.GetPlayerGui()
            end
            function Runtime.AttachGui(Gui: ScreenGui): boolean
                local Ok = pcall(function()
                    Gui.Parent = Runtime.GetGuiParent()
                end)

                if Ok then
                    return true
                end

                local FallbackOk = pcall(function()
                    Gui.Parent = Runtime.GetPlayerGui()
                end)

                return FallbackOk
            end
            function Runtime.FileApi()
                return {
                    IsFolder = isfolder,
                    MakeFolder = makefolder,
                    IsFile = isfile,
                    WriteFile = writefile,
                    ReadFile = readfile,
                    DeleteFile = delfile,
                    ListFiles = listfiles,
                    GetCustomAsset = getcustomasset,
                }
            end
            function Runtime.HasFileApi(): boolean
                return type(isfolder) == 'function' and type(makefolder) == 'function' and type(isfile) == 'function' and type(writefile) == 'function' and type(readfile) == 'function' and type(delfile) == 'function'
            end

            return Runtime
        end

        function __DARKLUA_BUNDLE_MODULES.d(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.d

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.d = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local AssetRegistry = {}
            local DefaultBaseUrl = 'https://raw.githubusercontent.com/nikgeneburn/fecurity/main/'

            local function NormalizeBaseUrl(BaseUrl: string): string
                if string.sub(BaseUrl, -1) ~= '/' then
                    return BaseUrl .. '/'
                end

                return BaseUrl
            end
            local function ReadOverrideBaseUrl(): string
                local Env = _G

                if getgenv then
                    local Ok, Result = pcall(getgenv)

                    if Ok and type(Result) == 'table' then
                        Env = Result
                    end
                end

                local Override = Env.FecurityAssetBaseUrl

                if type(Override) == 'string' and Override ~= '' then
                    return NormalizeBaseUrl(Override)
                end

                return NormalizeBaseUrl(DefaultBaseUrl)
            end

            AssetRegistry.BaseUrl = ReadOverrideBaseUrl()
            AssetRegistry.CacheRoot = 'Fecurity'
            AssetRegistry.Folders = {
                'Fecurity',
                'Fecurity/Assets',
                'Fecurity/Assets/Fonts',
                'Fecurity/Assets/Icons',
                'Fecurity/Assets/Images',
                'Fecurity/Configs',
                'Fecurity/Logs',
            }
            AssetRegistry.Fonts = {
                Main = {
                    Url = AssetRegistry.BaseUrl .. 'assets/fonts/ProximaNova-Semibold.ttf',
                    File = 'Fecurity/Assets/Fonts/ProximaNova-Semibold.ttf',
                    Bytes = 53740,
                    Fallback = Enum.Font.GothamBold,
                },
            }
            AssetRegistry.Icons = {
                assist = {
                    Url = AssetRegistry.BaseUrl .. 'assets/icons/assist.png',
                    File = 'Fecurity/Assets/Icons/assist.png',
                    Bytes = 1982,
                    Fallback = 'A',
                },
                visuals = {
                    Url = AssetRegistry.BaseUrl .. 'assets/icons/visuals.png',
                    File = 'Fecurity/Assets/Icons/visuals.png',
                    Bytes = 2131,
                    Fallback = 'V',
                },
                misc = {
                    Url = AssetRegistry.BaseUrl .. 'assets/icons/misc.png',
                    File = 'Fecurity/Assets/Icons/misc.png',
                    Bytes = 1770,
                    Fallback = 'M',
                },
                colors = {
                    Url = AssetRegistry.BaseUrl .. 'assets/icons/colors.png',
                    File = 'Fecurity/Assets/Icons/colors.png',
                    Bytes = 1234,
                    Fallback = 'C',
                },
                trial = {
                    Url = AssetRegistry.BaseUrl .. 'assets/icons/trial.png',
                    File = 'Fecurity/Assets/Icons/trial.png',
                    Bytes = 1030,
                    Fallback = 'T',
                },
            }
            AssetRegistry.Images = {
                Logo = {
                    Url = AssetRegistry.BaseUrl .. 'assets/images/logo.png',
                    File = 'Fecurity/Assets/Images/logo.png',
                    Bytes = 1650,
                    Fallback = nil,
                },
                HitboxPreview = {
                    Url = AssetRegistry.BaseUrl .. 'assets/images/hitbox-preview.png',
                    File = 'Fecurity/Assets/Images/hitbox-preview.png',
                    Bytes = 211220,
                    Fallback = nil,
                },
            }

            function AssetRegistry.SetBaseUrl(BaseUrl: string)
                BaseUrl = NormalizeBaseUrl(BaseUrl)
                AssetRegistry.BaseUrl = BaseUrl
                AssetRegistry.Fonts.Main.Url = BaseUrl .. 'assets/fonts/ProximaNova-Semibold.ttf'

                for Name, Icon in pairs(AssetRegistry.Icons)do
                    Icon.Url = BaseUrl .. 'assets/icons/' .. Name .. '.png'
                end

                AssetRegistry.Images.Logo.Url = BaseUrl .. 'assets/images/logo.png'
                AssetRegistry.Images.HitboxPreview.Url = BaseUrl .. 'assets/images/hitbox-preview.png'
            end

            return AssetRegistry
        end

        function __DARKLUA_BUNDLE_MODULES.e(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.e

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.e = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Logger = __DARKLUA_BUNDLE_MODULES.a()
            local Runtime = __DARKLUA_BUNDLE_MODULES.d()
            local Registry = __DARKLUA_BUNDLE_MODULES.e()
            local AssetCache = {}

            AssetCache.__index = AssetCache

            function AssetCache.New()
                return setmetatable({
                    Ready = false,
                    Failed = {},
                }, AssetCache)
            end
            function AssetCache:FolderExists(Folder: string): boolean
                if type(isfolder) ~= 'function' then
                    return false
                end

                local Ok, Exists = pcall(isfolder, Folder)

                return Ok and Exists == true
            end
            function AssetCache:FileExists(Path: string): boolean
                if type(isfile) ~= 'function' then
                    return false
                end

                local Ok, Exists = pcall(isfile, Path)

                return Ok and Exists == true
            end
            function AssetCache:EnsureFolders()
                if not Runtime.HasFileApi() then
                    return false
                end

                local Ready = true

                for _, Folder in ipairs(Registry.Folders)do
                    if not self:FolderExists(Folder) then
                        local Ok, Err = pcall(makefolder, Folder)

                        if not Ok then
                            Ready = false

                            Logger.Warn('Asset cache folder failed', Folder, Err)
                        end
                    end
                end

                return Ready
            end
            function AssetCache:Download(Url: string): string?
                local Ok, Body = pcall(function()
                    return game:HttpGet(Url)
                end)

                if Ok and type(Body) == 'string' and #Body > 0 then
                    return Body
                end

                return nil
            end
            function AssetCache:IsValidBody(Asset: {Url: string, File: string, Bytes: number?}, Body: string): boolean
                if #Body <= 0 then
                    return false
                end
                if Asset.Bytes and #Body ~= Asset.Bytes then
                    return false
                end

                return true
            end
            function AssetCache:DeleteBadFile(Path: string)
                if type(delfile) == 'function' then
                    local Ok, Err = pcall(delfile, Path)

                    if not Ok then
                        Logger.Warn('Asset cache delete failed', Path, Err)
                    end
                end
            end
            function AssetCache:EnsureAsset(Asset: {Url: string, File: string, Bytes: number?})
                if not Runtime.HasFileApi() then
                    return nil
                end
                if self:FileExists(Asset.File) then
                    local Ok, Body = pcall(readfile, Asset.File)

                    if Ok and type(Body) == 'string' and self:IsValidBody(Asset, Body) then
                        self.Failed[Asset.File] = nil

                        return Asset.File
                    end

                    self:DeleteBadFile(Asset.File)
                end

                local Body = self:Download(Asset.Url)

                if Body and self:IsValidBody(Asset, Body) then
                    local Ok, Err = pcall(writefile, Asset.File, Body)

                    if Ok then
                        self.Failed[Asset.File] = nil

                        return Asset.File
                    end

                    Logger.Warn('Asset cache write failed', Asset.File, Err)
                end

                self.Failed[Asset.File] = true

                Logger.Warn('Asset download failed', Asset.Url)

                return nil
            end
            function AssetCache:EnsureAll()
                table.clear(self.Failed)

                local Ready = self:EnsureFolders()

                if not self:EnsureAsset(Registry.Fonts.Main) then
                    Ready = false
                end

                for _, Icon in pairs(Registry.Icons)do
                    if not self:EnsureAsset(Icon) then
                        Ready = false
                    end
                end
                for _, Image in pairs(Registry.Images)do
                    if not self:EnsureAsset(Image) then
                        Ready = false
                    end
                end

                self.Ready = Ready

                return Ready
            end
            function AssetCache:GetCustomAsset(Path: string): string?
                if type(getcustomasset) ~= 'function' then
                    return nil
                end
                if not self:FileExists(Path) then
                    return nil
                end

                local Ok, Value = pcall(getcustomasset, Path)

                if Ok then
                    return Value
                end

                return nil
            end

            return AssetCache
        end

        function __DARKLUA_BUNDLE_MODULES.f(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.f

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.f = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Safety = __DARKLUA_BUNDLE_MODULES.c()
            local FlagManager = {}

            FlagManager.__index = FlagManager

            function FlagManager.New()
                return setmetatable({
                    Values = {},
                    Widgets = {},
                    SkipFlags = {},
                }, FlagManager)
            end
            function FlagManager:Register(Flag: string?, Widget: any, Default: any, SkipFlag: boolean?)
                if not Flag then
                    return
                end
                if SkipFlag then
                    self.SkipFlags[Flag] = true
                else
                    self.SkipFlags[Flag] = nil
                    self.Widgets[Flag] = Widget
                end
                if self.Values[Flag] == nil then
                    self.Values[Flag] = Default
                end
            end
            function FlagManager:Unregister(Flag: string?, Widget: any?)
                if not Flag then
                    return
                end
                if Widget == nil or self.Widgets[Flag] == Widget then
                    self.Widgets[Flag] = nil
                end
            end
            function FlagManager:Set(Flag: string?, Value: any)
                if not Flag then
                    return
                end

                self.Values[Flag] = Value
            end
            function FlagManager:Get(Flag: string, Default: any?): any
                local Value = self.Values[Flag]

                if Value == nil then
                    return Default
                end

                return Value
            end
            function FlagManager:Export(): {[string]: any}
                local Values = {}

                for Flag, Value in pairs(self.Values)do
                    if self.SkipFlags[Flag] ~= true then
                        Values[Flag] = Value
                    end
                end

                return Values
            end
            function FlagManager:Load(Values: {[string]: any}, RunCallbacks: boolean?)
                for Flag, Value in pairs(Values)do
                    if self.SkipFlags[Flag] ~= true then
                        self.Values[Flag] = Value

                        local Widget = self.Widgets[Flag]

                        if Widget and Widget.SetValue then
                            Safety.Try('FlagManager.Load', function()
                                Widget:SetValue(Value, RunCallbacks == true)
                            end)
                        end
                    end
                end
            end

            return FlagManager
        end

        function __DARKLUA_BUNDLE_MODULES.g(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.g

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.g = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local HttpService = game:GetService('HttpService')
            local Serializer = {}

            local function Pack(Value: any, Seen: {[any]: boolean}?): any
                local ValueType = typeof(Value)

                if ValueType == 'Color3' then
                    return {
                        __FecurityType = 'Color3',
                        R = Value.R,
                        G = Value.G,
                        B = Value.B,
                    }
                end
                if type(Value) ~= 'table' then
                    return Value
                end

                Seen = Seen or {}

                if Seen[Value] then
                    return nil
                end

                Seen[Value] = true

                local Copy = {}

                for Key, Child in pairs(Value)do
                    Copy[Key] = Pack(Child, Seen)
                end

                Seen[Value] = nil

                return Copy
            end
            local function Unpack(Value: any): any
                if type(Value) ~= 'table' then
                    return Value
                end
                if Value.__FecurityType == 'Color3' then
                    return Color3.new(tonumber(Value.R) or 1, tonumber(Value.G) or 1, tonumber(Value.B) or 1)
                end

                local Copy = {}

                for Key, Child in pairs(Value)do
                    Copy[Key] = Unpack(Child)
                end

                return Copy
            end

            function Serializer.Encode(Value: any): string
                return HttpService:JSONEncode(Pack(Value))
            end
            function Serializer.Decode(Value: string): any?
                local Ok, Result = pcall(function()
                    return HttpService:JSONDecode(Value)
                end)

                if Ok then
                    return Unpack(Result)
                end

                return nil
            end

            return Serializer
        end

        function __DARKLUA_BUNDLE_MODULES.h(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.h

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.h = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Serializer = __DARKLUA_BUNDLE_MODULES.h()
            local Logger = __DARKLUA_BUNDLE_MODULES.a()
            local Runtime = __DARKLUA_BUNDLE_MODULES.d()
            local ConfigManager = {}

            ConfigManager.__index = ConfigManager

            local function CleanName(Name: string): string
                local Clean = string.gsub(tostring(Name or ''), '[^%w_%-%s]', '')

                if Clean == '' then
                    Clean = 'Default'
                end

                return Clean
            end
            local function SortedNames(Names: {[string]: boolean}): {string}
                local Results = {}

                for Name in pairs(Names)do
                    table.insert(Results, Name)
                end

                table.sort(Results)

                return Results
            end

            function ConfigManager.New(Flags: any)
                return setmetatable({
                    Flags = Flags,
                    Folder = 'Fecurity/Configs',
                    IndexFile = 'Fecurity/Configs/index.json',
                    KnownConfigs = {},
                    IndexLoaded = false,
                }, ConfigManager)
            end
            function ConfigManager:FolderExists(Path: string): boolean
                local Ok, Exists = pcall(isfolder, Path)

                return Ok and Exists == true
            end
            function ConfigManager:FileExists(Path: string): boolean
                local Ok, Exists = pcall(isfile, Path)

                return Ok and Exists == true
            end
            function ConfigManager:EnsureFolders()
                if not Runtime.HasFileApi() then
                    return false
                end

                for _, Folder in ipairs({
                    'Fecurity',
                    self.Folder,
                })do
                    if not self:FolderExists(Folder) then
                        local Ok, Err = pcall(makefolder, Folder)

                        if not Ok then
                            Logger.Warn('Config folder failed', Folder, Err)

                            return false
                        end
                    end
                end

                return true
            end
            function ConfigManager:LoadIndex()
                if self.IndexLoaded or not Runtime.HasFileApi() then
                    return
                end

                self.IndexLoaded = true

                if not self:FileExists(self.IndexFile) then
                    return
                end

                local Ok, Body = pcall(readfile, self.IndexFile)

                if not Ok or type(Body) ~= 'string' then
                    Logger.Warn('Config index read failed', self.IndexFile, Body)

                    return
                end

                local Data = Serializer.Decode(Body)

                if type(Data) ~= 'table' then
                    return
                end

                for _, Name in ipairs(Data)do
                    if type(Name) == 'string' then
                        self.KnownConfigs[CleanName(Name)] = true
                    end
                end
            end
            function ConfigManager:SaveIndex()
                if not Runtime.HasFileApi() then
                    return false
                end
                if not self:EnsureFolders() then
                    return false
                end

                local Ok, Err = pcall(writefile, self.IndexFile, Serializer.Encode(SortedNames(self.KnownConfigs)))

                if not Ok then
                    Logger.Warn('Config index write failed', self.IndexFile, Err)

                    return false
                end

                return true
            end
            function ConfigManager:Remember(Name: string): string
                local Clean = CleanName(Name)

                self:LoadIndex()

                self.KnownConfigs[Clean] = true

                self:SaveIndex()

                return Clean
            end
            function ConfigManager:Path(Name: string): string
                return self.Folder .. '/' .. CleanName(Name) .. '.json'
            end
            function ConfigManager:Save(Name: string)
                if not Runtime.HasFileApi() then
                    return false
                end
                if not self:EnsureFolders() then
                    return false
                end

                local Clean = CleanName(Name)
                local Path = self:Path(Clean)
                local Ok, Err = pcall(writefile, Path, Serializer.Encode(self.Flags:Export()))

                if not Ok then
                    Logger.Warn('Config write failed', Path, Err)

                    return false
                end

                self:Remember(Clean)

                return true
            end
            function ConfigManager:Load(Name: string, RunCallbacks: boolean?)
                if not Runtime.HasFileApi() then
                    return false
                end

                local Clean = CleanName(Name)
                local Path = self:Path(Clean)

                if not self:FileExists(Path) then
                    return false
                end

                local Ok, Body = pcall(readfile, Path)

                if not Ok or type(Body) ~= 'string' then
                    Logger.Warn('Config read failed', Path, Body)

                    return false
                end

                local Data = Serializer.Decode(Body)

                if type(Data) ~= 'table' then
                    return false
                end

                self.Flags:Load(Data, RunCallbacks)
                self:Remember(Clean)

                return true
            end
            function ConfigManager:GetConfigs(): {string}
                if not Runtime.HasFileApi() then
                    return {}
                end

                self:LoadIndex()

                if type(listfiles) == 'function' and self:FolderExists(self.Folder) then
                    local Ok, Paths = pcall(listfiles, self.Folder)

                    if Ok and type(Paths) == 'table' then
                        for _, Path in ipairs(Paths)do
                            local Name = string.match(Path, '([^/\\]+)%.json$')

                            if Name and Name ~= 'index' then
                                self.KnownConfigs[CleanName(Name)] = true
                            end
                        end
                    elseif not Ok then
                        Logger.Warn('Config listing failed', self.Folder, Paths)
                    end
                end

                return SortedNames(self.KnownConfigs)
            end

            return ConfigManager
        end

        function __DARKLUA_BUNDLE_MODULES.i(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.i

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.i = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local TweenService = game:GetService('TweenService')
            local Tween = {}

            function Tween.Play(
                Object: Instance,
                Time: number,
                Props: {[string]: any},
                Style: Enum.EasingStyle?,
                Direction: Enum.EasingDirection?
            )
                local Info = TweenInfo.new(Time, Style or Enum.EasingStyle.Quad, Direction or Enum.EasingDirection.Out)
                local Created = TweenService:Create(Object, Info, Props)

                Created:Play()

                return Created
            end
            function Tween.Press(Object: GuiObject, Color: Color3, Base: Color3)
                Tween.Play(Object, 0.08, {BackgroundColor3 = Color})
                task.delay(0.1, function()
                    if Object and Object.Parent then
                        Tween.Play(Object, 0.12, {BackgroundColor3 = Base})
                    end
                end)
            end

            return Tween
        end

        function __DARKLUA_BUNDLE_MODULES.j(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.j

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.j = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Palette = {}

            function Palette.Hex(Hex: string): Color3
                local Clean = string.gsub(Hex, '#', '')
                local R = tonumber(string.sub(Clean, 1, 2), 16) or 255
                local G = tonumber(string.sub(Clean, 3, 4), 16) or 255
                local B = tonumber(string.sub(Clean, 5, 6), 16) or 255

                return Color3.fromRGB(R, G, B)
            end
            function Palette.Darken(Color: Color3, Amount: number): Color3
                return Color3.new(math.clamp(Color.R * (1 - Amount), 0, 1), math.clamp(Color.G * (1 - Amount), 0, 1), math.clamp(Color.B * (1 - Amount), 0, 1))
            end
            function Palette.Lighten(Color: Color3, Amount: number): Color3
                return Color:Lerp(Color3.new(1, 1, 1), Amount)
            end
            function Palette.ToHex(Color: Color3): string
                return string.format('#%02x%02x%02x', math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5))
            end
            function Palette.ParseWithAlpha(Text: string): (Color3?,number?)
                local Clean = string.gsub(Text, '%s+', '')
                local Hex = string.match(Clean, '^#?([%da-fA-F]+)$')

                if Hex and (#Hex == 3 or #Hex == 6 or #Hex == 8) then
                    local Alpha = nil

                    if #Hex == 3 then
                        Hex = string.sub(Hex, 1, 1) .. string.sub(Hex, 1, 1) .. string.sub(Hex, 2, 2) .. string.sub(Hex, 2, 2) .. string.sub(Hex, 3, 3) .. string.sub(Hex, 3, 3)
                    elseif #Hex == 8 then
                        Alpha = (tonumber(string.sub(Hex, 7, 8), 16) or 255) / 255
                    end

                    return Palette.Hex(string.sub(Hex, 1, 6)), Alpha
                end

                local Body = string.match(Clean, '^rgba?%((.+)%)$')

                if not Body then
                    return nil, nil
                end

                local Values = {}

                for Value in string.gmatch(Body, '[%d%.]+')do
                    table.insert(Values, tonumber(Value) or 0)
                end

                if #Values < 3 then
                    return nil, nil
                end

                local Alpha = Values[4]

                if Alpha ~= nil and Alpha > 1 then
                    Alpha = Alpha / 255
                end

                return Color3.fromRGB(math.clamp(math.floor(Values[1] + 0.5), 0, 255), math.clamp(math.floor(Values[2] + 0.5), 0, 255), math.clamp(math.floor(Values[3] + 0.5), 0, 255)), Alpha and math.clamp(Alpha, 0, 1) or nil
            end
            function Palette.Parse(Text: string): Color3?
                local Color = Palette.ParseWithAlpha(Text)

                return Color
            end
            function Palette.ToRgba(Color: Color3, Alpha: number): string
                return string.format('rgba(%d, %d, %d, %.2f)', math.floor(Color.R * 255 + 0.5), math.floor(Color.G * 255 + 0.5), math.floor(Color.B * 255 + 0.5), math.clamp(Alpha, 0, 1))
            end

            return Palette
        end

        function __DARKLUA_BUNDLE_MODULES.k(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.k

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.k = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Palette = __DARKLUA_BUNDLE_MODULES.k()
            local Theme = {}

            Theme.Default = {
                Canvas = Palette.Hex('#0a0a0a'),
                Surface = Palette.Hex('#111111'),
                Selected = Palette.Hex('#1b1b1b'),
                Border = Palette.Hex('#2c2c2c'),
                Text = Palette.Hex('#ffffff'),
                Muted = Palette.Hex('#646464'),
                Hint = Palette.Hex('#575757'),
                Accent = Palette.Hex('#6a62c6'),
                Control = Palette.Hex('#212121'),
                ControlHover = Palette.Hex('#252525'),
                ToggleOff = Palette.Hex('#1d1d1d'),
                ToggleKnobOff = Palette.Hex('#696969'),
                SliderTrack = Palette.Hex('#232323'),
            }
            Theme.Presets = {
                Dark = Theme.Default,
                dark = Theme.Default,
                Fecurity = Theme.Default,
                fecurity = Theme.Default,
                Midnight = {
                    Canvas = Palette.Hex('#050505'),
                    Surface = Palette.Hex('#101012'),
                    Selected = Palette.Hex('#1a1a20'),
                    Border = Palette.Hex('#303039'),
                    Text = Palette.Hex('#ffffff'),
                    Muted = Palette.Hex('#72727a'),
                    Hint = Palette.Hex('#5a5a63'),
                    Accent = Palette.Hex('#6a62c6'),
                    Control = Palette.Hex('#202025'),
                    ControlHover = Palette.Hex('#282831'),
                    ToggleOff = Palette.Hex('#1b1b20'),
                    ToggleKnobOff = Palette.Hex('#707078'),
                    SliderTrack = Palette.Hex('#25252d'),
                },
            }
            Theme.Presets.midnight = Theme.Presets.Midnight

            local function CopyFrom(Source: {[string]: any})
                local Copy = {}

                for Key, DefaultValue in pairs(Theme.Default)do
                    Copy[Key] = Source[Key] or DefaultValue
                end

                return Copy
            end

            function Theme.Clone(Accent: Color3?)
                local Copy = CopyFrom(Theme.Default)

                if Accent then
                    Copy.Accent = Accent
                end

                return Copy
            end
            function Theme.Resolve(Value: any, Accent: Color3?)
                local Base = Theme.Default

                if type(Value) == 'string' then
                    Base = Theme.Presets[Value] or Theme.Presets[string.lower(Value)] or Theme.Default
                elseif type(Value) == 'table' then
                    Base = Value
                end

                local Copy = CopyFrom(Base)

                if Accent then
                    Copy.Accent = Accent
                end

                return Copy
            end
            function Theme.Apply(Target: {[string]: any}, Source: {[string]: any})
                for Key in pairs(Theme.Default)do
                    Target[Key] = Source[Key] or Theme.Default[Key]
                end
            end

            return Theme
        end

        function __DARKLUA_BUNDLE_MODULES.l(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.l

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.l = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tokens = {
                WindowSize = Vector2.new(774, 481),
                SidebarWidth = 67,
                PanelTop = 17,
                PanelHeight = 446,
                PanelWidth = 212,
                PanelGap = 18,
                PanelLeft = 85,
                PanelRight = 16,
                PanelBottom = 18,
                Radius = 0,
                FontSize = 12,
                HeaderSize = 11,
                RowHeight = 40,
                SliderHeight = 52,
                DropdownHeight = 72,
            }

            function Tokens.PanelX(Index: number): number
                return Tokens.PanelLeft + (Index - 1) * (Tokens.PanelWidth + Tokens.PanelGap)
            end
            function Tokens.PanelHeightFor(WindowHeight: number?): number
                local Height = WindowHeight or Tokens.WindowSize.Y

                if Height == Tokens.WindowSize.Y then
                    return Tokens.PanelHeight
                end

                return math.max(80, Height - Tokens.PanelTop - Tokens.PanelBottom)
            end
            function Tokens.PanelLayout(Index: number, Count: number, WindowWidth: number?): (number,number)
                local WidthTarget = WindowWidth or Tokens.WindowSize.X

                if Count == 3 and WidthTarget == Tokens.WindowSize.X then
                    return Tokens.PanelX(Index), Index == 3 and 213 or Tokens.PanelWidth
                end

                local AreaWidth = math.max(1, WidthTarget - Tokens.PanelLeft - Tokens.PanelRight)
                local TotalGap = Tokens.PanelGap * math.max(Count - 1, 0)
                local UsableWidth = math.max(1, AreaWidth - TotalGap)
                local BaseWidth = math.floor(UsableWidth / math.max(Count, 1))
                local Remainder = UsableWidth - BaseWidth * math.max(Count, 1)
                local Width = BaseWidth + (Index == Count and Remainder or 0)
                local X = Tokens.PanelLeft + (Index - 1) * (BaseWidth + Tokens.PanelGap)

                return X, Width
            end

            return Tokens
        end

        function __DARKLUA_BUNDLE_MODULES.m(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.m

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.m = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = {}

            function Elements.New(ClassName: string, Props: {[string]: any}?, Parent: Instance?): Instance
                local Object = Instance.new(ClassName)

                if Props then
                    for Key, Value in pairs(Props)do
                        (Object::any)[Key] = Value
                    end
                end

                Object.Parent = Parent

                return Object
            end
            function Elements.Corner(Parent: Instance, Radius: number?)
                local Corner = Instance.new('UICorner')

                Corner.CornerRadius = UDim.new(0, Radius or 0)
                Corner.Parent = Parent

                return Corner
            end
            function Elements.Stroke(Parent: Instance, Color: Color3, Transparency: number?, Thickness: number?)
                local Stroke = Instance.new('UIStroke')

                Stroke.Color = Color
                Stroke.Transparency = Transparency or 0
                Stroke.Thickness = Thickness or 1
                Stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
                Stroke.Parent = Parent

                return Stroke
            end
            function Elements.Padding(
                Parent: Instance,
                Left: number,
                Top: number,
                Right: number,
                Bottom: number
            )
                local Padding = Instance.new('UIPadding')

                Padding.PaddingLeft = UDim.new(0, Left)
                Padding.PaddingTop = UDim.new(0, Top)
                Padding.PaddingRight = UDim.new(0, Right)
                Padding.PaddingBottom = UDim.new(0, Bottom)
                Padding.Parent = Parent

                return Padding
            end
            function Elements.List(Parent: Instance, Direction: Enum.FillDirection, Padding: number?)
                local Layout = Instance.new('UIListLayout')

                Layout.FillDirection = Direction
                Layout.SortOrder = Enum.SortOrder.LayoutOrder
                Layout.Padding = UDim.new(0, Padding or 0)
                Layout.Parent = Parent

                return Layout
            end

            return Elements
        end

        function __DARKLUA_BUNDLE_MODULES.n(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.n

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.n = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local DragController = {}

            function DragController.Attach(Handle: GuiObject, Target: GuiObject)
                local Dragging = false
                local StartMouse = Vector2.zero
                local StartPos = Target.Position
                local Connections = {}

                table.insert(Connections, Handle.InputBegan:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseButton1 then
                        return
                    end

                    Dragging = true
                    StartMouse = UserInputService:GetMouseLocation()
                    StartPos = Target.Position
                end))
                table.insert(Connections, UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end))
                table.insert(Connections, UserInputService.InputChanged:Connect(function(Input)
                    if not Dragging or Input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end

                    local Delta = UserInputService:GetMouseLocation() - StartMouse

                    Target.Position = UDim2.new(StartPos.X.Scale, StartPos.X.Offset + Delta.X, StartPos.Y.Scale, StartPos.Y.Offset + Delta.Y)
                end))

                return function()
                    for _, Connection in ipairs(Connections)do
                        Connection:Disconnect()
                    end
                end
            end

            return DragController
        end

        function __DARKLUA_BUNDLE_MODULES.o(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.o

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.o = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local KeybindManager = {}

            function KeybindManager.Display(Input: InputObject | Enum.KeyCode | string): string
                if typeof(Input) == 'EnumItem' then
                    return string.gsub((Input::EnumItem).Name, 'Insert', 'INS')
                end
                if typeof(Input) == 'Instance' then
                    local Object = Input::InputObject

                    if Object.UserInputType == Enum.UserInputType.MouseButton1 then
                        return 'M1'
                    elseif Object.UserInputType == Enum.UserInputType.MouseButton2 then
                        return 'M2'
                    elseif Object.KeyCode ~= Enum.KeyCode.Unknown then
                        return KeybindManager.Display(Object.KeyCode)
                    end
                end

                return tostring(Input)
            end
            function KeybindManager.Normalize(Value: any): string
                local Display = KeybindManager.Display(Value)

                Display = string.gsub(Display, '^Enum%.KeyCode%.', '')
                Display = string.gsub(Display, '^Enum%.UserInputType%.MouseButton1$', 'M1')
                Display = string.gsub(Display, '^Enum%.UserInputType%.MouseButton2$', 'M2')
                Display = string.gsub(Display, '^MouseButton1$', 'M1')
                Display = string.gsub(Display, '^MouseButton2$', 'M2')
                Display = string.gsub(Display, '^Insert$', 'INS')

                return Display
            end
            function KeybindManager.IsActivation(Input: InputObject, Value: any): boolean
                local Display = KeybindManager.Display(Input)

                return Display == KeybindManager.Normalize(Value)
            end

            return KeybindManager
        end

        function __DARKLUA_BUNDLE_MODULES.p(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.p

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.p = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Gradients = {}

            function Gradients.AccentVertical(Parent: Instance, Accent: Color3): UIGradient
                local Gradient = Instance.new('UIGradient')

                Gradient.Rotation = 90
                Gradient.Color = Gradients.AccentSequence(Accent)
                Gradient.Parent = Parent

                return Gradient
            end
            function Gradients.AccentSequence(Accent: Color3): ColorSequence
                return ColorSequence.new({
                    ColorSequenceKeypoint.new(0, Accent:Lerp(Color3.new(1, 1, 1), 0.26)),
                    ColorSequenceKeypoint.new(1, Accent:Lerp(Color3.new(0, 0, 0), 0.46)),
                })
            end
            function Gradients.SetAccent(Gradient: UIGradient, Accent: Color3)
                Gradient.Color = Gradients.AccentSequence(Accent)
            end

            return Gradients
        end

        function __DARKLUA_BUNDLE_MODULES.q(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.q

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.q = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Registry = __DARKLUA_BUNDLE_MODULES.e()
            local ImageLoader = {}

            function ImageLoader.Get(Cache: any?, Name: string): string?
                local Asset = Registry.Images[Name]

                if not Asset or not Cache then
                    return nil
                end

                return Cache:GetCustomAsset(Asset.File)
            end
            function ImageLoader.Apply(Object: ImageLabel | ImageButton, Cache: any?, Name: string)
                local Asset = ImageLoader.Get(Cache, Name)

                if Asset then
                    Object.Image = Asset

                    return true
                end

                return false
            end

            return ImageLoader
        end

        function __DARKLUA_BUNDLE_MODULES.r(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.r

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.r = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local TextService = game:GetService('TextService')
            local Styling = {}

            function Styling.ApplyText(Object: TextLabel | TextButton | TextBox, Theme: {[string]: any}, Size: number?, Color: Color3?)
                Object.Font = Enum.Font.GothamBold
                Object.TextSize = Size or 12
                Object.TextColor3 = Color or Theme.Text
                Object.TextXAlignment = Enum.TextXAlignment.Left
                Object.TextYAlignment = Enum.TextYAlignment.Center
                Object.BackgroundTransparency = 1
                Object.TextTruncate = Enum.TextTruncate.AtEnd
            end
            function Styling.FitText(Object: TextLabel | TextButton | TextBox, MaxSize: number?, MinSize: number?)
                local TopSize = MaxSize or Object.TextSize
                local BottomSize = MinSize or 9

                local function Resize()
                    local Width = math.max(Object.AbsoluteSize.X - 6, 4)
                    local Best = BottomSize

                    for Size = TopSize, BottomSize, -1 do
                        local Bounds = TextService:GetTextSize(Object.Text, Size, Object.Font, Vector2.new(math.huge, math.huge))

                        if Bounds.X <= Width then
                            Best = Size

                            break
                        end
                    end

                    Object.TextSize = Best
                end

                task.defer(Resize)
                Object:GetPropertyChangedSignal('Text'):Connect(Resize)
                Object:GetPropertyChangedSignal('AbsoluteSize'):Connect(Resize)

                return Resize
            end

            return Styling
        end

        function __DARKLUA_BUNDLE_MODULES.s(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.s

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.s = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Registry = __DARKLUA_BUNDLE_MODULES.e()
            local FontLoader = {}

            function FontLoader.Apply(Object: TextLabel | TextButton | TextBox, Cache: any?)
                Object.Font = Registry.Fonts.Main.Fallback

                if not Cache then
                    return
                end

                local Asset = Cache:GetCustomAsset(Registry.Fonts.Main.File)

                if not Asset then
                    return
                end

                pcall(function()
                    Object.FontFace = Font.new(Asset, Enum.FontWeight.SemiBold, Enum.FontStyle.Normal)
                end)
            end

            return FontLoader
        end

        function __DARKLUA_BUNDLE_MODULES.t(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.t

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.t = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Registry = __DARKLUA_BUNDLE_MODULES.e()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local IconLoader = {}

            function IconLoader.Apply(Parent: Instance, Name: string, Theme: {[string]: any}, Cache: any?): Instance
                local Icon = Registry.Icons[string.lower(Name)]
                local Asset = Icon and Cache and Cache:GetCustomAsset(Icon.File)

                if Asset then
                    local Image = Instance.new('ImageLabel')

                    Image.Name = 'Icon'
                    Image.BackgroundTransparency = 1
                    Image.Image = Asset
                    Image.ImageColor3 = Theme.Muted
                    Image.Size = UDim2.fromOffset(16, 16)
                    Image.Parent = Parent

                    return Image
                end

                local Label = Instance.new('TextLabel')

                Label.Name = 'IconFallback'
                Label.Size = UDim2.fromOffset(16, 16)
                Label.Text = Icon and Icon.Fallback or string.sub(Name, 1, 1)

                Styling.ApplyText(Label, Theme, 11, Theme.Muted)

                Label.TextXAlignment = Enum.TextXAlignment.Center
                Label.Parent = Parent

                return Label
            end

            return IconLoader
        end

        function __DARKLUA_BUNDLE_MODULES.u(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.u

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.u = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local IconLoader = __DARKLUA_BUNDLE_MODULES.u()
            local TabButton = {}

            TabButton.__index = TabButton

            local SlotY = {
                72,
                139,
                206,
                274,
                340,
            }

            function TabButton.New(Window: any, TabObject: any, Index: number)
                local self = setmetatable({
                    Window = Window,
                    Tab = TabObject,
                    Active = false,
                }, TabButton)
                local Button = Elements.New('TextButton', {
                    Name = TabObject.Name .. 'Tab',
                    AutoButtonColor = false,
                    BackgroundColor3 = Window.Theme.Surface,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, SlotY[Index] or (72 + (Index - 1) * 67)),
                    Size = UDim2.fromOffset(67, 67),
                    Text = '',
                    ZIndex = 25,
                }, Window.Sidebar.Root)::TextButton

                self.Root = Button

                local Content = Elements.New('Frame', {
                    Name = 'Content',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 14),
                    Size = UDim2.fromOffset(67, 38),
                    ZIndex = 26,
                }, Button)::Frame

                self.Content = Content

                local Icon = IconLoader.Apply(Content, TabObject.Icon, Window.Theme, Window.Library.AssetCache)
                local IconObject = Icon::GuiObject

                IconObject.AnchorPoint = Vector2.new(0.5, 0)
                IconObject.Position = UDim2.new(0.5, 0, 0, 0)
                self.Icon = Icon

                local Label = Elements.New('TextLabel', {
                    Name = 'Label',
                    Position = UDim2.fromOffset(0, 22),
                    Size = UDim2.fromOffset(67, 16),
                    Text = string.upper(TabObject.Name),
                    ZIndex = 26,
                }, Content)::TextLabel

                Styling.ApplyText(Label, Window.Theme, 12, Window.Theme.Muted)
                FontLoader.Apply(Label, Window.Library.AssetCache)

                Label.TextXAlignment = Enum.TextXAlignment.Center
                self.Label = Label

                Button.MouseButton1Click:Connect(function()
                    Window:SetActiveTab(TabObject)
                end)

                return self
            end
            function TabButton:SetActive(Value: boolean)
                self.Active = Value

                self:RefreshTheme()
            end
            function TabButton:RefreshTheme()
                local Theme = self.Window.Theme
                local ActiveColor = self.Active and Theme.Accent or Theme.Muted

                self.Root.BackgroundTransparency = self.Active and 0 or 1

                Tween.Play(self.Root, 0.14, {
                    BackgroundColor3 = self.Active and Theme.Selected or Theme.Surface,
                })

                if self.Icon:IsA('ImageLabel') then
                    self.Icon.ImageColor3 = ActiveColor
                elseif self.Icon:IsA('TextLabel') then
                    self.Icon.TextColor3 = ActiveColor
                end

                self.Label.TextColor3 = ActiveColor
            end

            return TabButton
        end

        function __DARKLUA_BUNDLE_MODULES.v(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.v

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.v = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Gradients = __DARKLUA_BUNDLE_MODULES.q()
            local ImageLoader = __DARKLUA_BUNDLE_MODULES.r()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Tokens = __DARKLUA_BUNDLE_MODULES.m()
            local Sidebar = {}

            Sidebar.__index = Sidebar

            function Sidebar.New(Window: any)
                local self = setmetatable({
                    Window = Window,
                    Buttons = {},
                }, Sidebar)
                local Root = Elements.New('Frame', {
                    Name = 'Sidebar',
                    BackgroundColor3 = Window.Theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromOffset(Tokens.SidebarWidth, Tokens.WindowSize.Y),
                    ZIndex = 22,
                }, Window.Root)::Frame

                self.Stroke = Elements.Stroke(Root, Window.Theme.Border, 0, 1)
                self.Root = Root

                local Logo = Elements.New('ImageLabel', {
                    Name = 'Logo',
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(8, 18),
                    Size = UDim2.fromOffset(50, 48),
                    ImageColor3 = Window.Theme.Accent,
                    ZIndex = 24,
                }, Root)::ImageLabel
                local HasLogo = ImageLoader.Apply(Logo, Window.Library.AssetCache, 'Logo')
                local Gradient = Gradients.AccentVertical(Logo, Window.Theme.Accent)

                self.Logo = Logo
                self.LogoGradient = Gradient

                if not HasLogo then
                    local Fallback = Elements.New('TextLabel', {
                        Name = 'LogoFallback',
                        BackgroundTransparency = 1,
                        Position = UDim2.fromOffset(8, 18),
                        Size = UDim2.fromOffset(50, 48),
                        Text = 'F',
                        ZIndex = 25,
                    }, Root)::TextLabel

                    Styling.ApplyText(Fallback, Window.Theme, 28, Window.Theme.Accent)
                    FontLoader.Apply(Fallback, Window.Library.AssetCache)

                    Fallback.TextXAlignment = Enum.TextXAlignment.Center
                    self.LogoFallback = Fallback
                end

                return self
            end
            function Sidebar:AddButton(TabObject: any)
                local Button = __DARKLUA_BUNDLE_MODULES.v().New(self.Window, TabObject, #self.Buttons + 1)

                table.insert(self.Buttons, Button)

                return Button
            end
            function Sidebar:RefreshTheme()
                self.Root.BackgroundColor3 = self.Window.Theme.Surface
                self.Stroke.Color = self.Window.Theme.Border
                self.Logo.ImageColor3 = self.Window.Theme.Accent

                Gradients.SetAccent(self.LogoGradient, self.Window.Theme.Accent)

                if self.LogoFallback then
                    self.LogoFallback.TextColor3 = self.Window.Theme.Accent
                end
            end

            return Sidebar
        end

        function __DARKLUA_BUNDLE_MODULES.w(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.w

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.w = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local RunService = game:GetService('RunService')
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local SnowLayer = {}

            SnowLayer.__index = SnowLayer

            function SnowLayer.New(Window: any, Parent: Instance)
                local self = setmetatable({
                    Window = Window,
                    Flakes = {},
                    Random = Random.new(6206),
                    Visible = true,
                }, SnowLayer)
                local Root = Elements.New('Frame', {
                    Name = 'SnowLayer',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 2,
                }, Parent)::Frame

                self.Root = Root

                for Index = 1, 70 do
                    local Size = self.Random:NextInteger(5, 14)
                    local Label = Elements.New('TextLabel', {
                        Name = 'Flake' .. tostring(Index),
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Size = UDim2.fromOffset(Size, Size),
                        Text = '*',
                        TextColor3 = Color3.new(1, 1, 1),
                        TextTransparency = self.Random:NextNumber(0.1, 0.62),
                        TextSize = Size,
                        Font = Enum.Font.GothamBold,
                        ZIndex = 2,
                    }, Root)::TextLabel

                    table.insert(self.Flakes, {
                        Node = Label,
                        X = self.Random:NextNumber(0, 1),
                        Y = self.Random:NextNumber(-0.2, 1),
                        Speed = self.Random:NextNumber(0.025, 0.105),
                        Drift = self.Random:NextNumber(-22, 22),
                        Spin = self.Random:NextNumber(-35, 35),
                        Phase = self.Random:NextNumber(0, 6.28),
                    })
                end

                self.Connection = RunService.RenderStepped:Connect(function(Delta)
                    self:Step(Delta)
                end)

                return self
            end
            function SnowLayer:Step(Delta: number)
                if not self.Visible then
                    return
                end

                local Size = self.Root.AbsoluteSize

                if Size.X <= 0 or Size.Y <= 0 then
                    return
                end

                local Now = os.clock()

                for _, Flake in ipairs(self.Flakes)do
                    Flake.Y += Flake.Speed * Delta * 60

                    if Flake.Y > 1.08 then
                        Flake.Y = -0.08
                        Flake.X = self.Random:NextNumber(0, 1)
                    end

                    local X = Flake.X * Size.X + math.sin(Now + Flake.Phase) * Flake.Drift
                    local Y = Flake.Y * Size.Y

                    Flake.Node.Position = UDim2.fromOffset(X, Y)

                    Flake.Node.Rotation += Flake.Spin * Delta
                end
            end
            function SnowLayer:SetVisible(Value: boolean)
                self.Visible = Value
                self.Root.Visible = Value
            end
            function SnowLayer:Destroy()
                if self.Connection then
                    self.Connection:Disconnect()
                end
                if self.Root then
                    self.Root:Destroy()
                end
            end

            return SnowLayer
        end

        function __DARKLUA_BUNDLE_MODULES.x(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.x

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.x = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Topbar = {}

            Topbar.__index = Topbar
            Topbar.Height = 0

            function Topbar.New(Window: any, Root: Frame, Options: {[string]: any})
                local self = setmetatable({
                    Window = Window,
                    Root = Root,
                    Title = Options.Title or 'Fecurity',
                    Subtitle = Options.Subtitle or '',
                }, Topbar)

                self:Apply()

                return self
            end
            function Topbar:Apply()
                self.Root:SetAttribute('FecurityTitle', self.Title)
                self.Root:SetAttribute('FecuritySubtitle', self.Subtitle)
            end
            function Topbar:SetTitle(Title: string, Subtitle: string?)
                self.Title = Title

                if Subtitle ~= nil then
                    self.Subtitle = Subtitle
                end

                self:Apply()
            end

            return Topbar
        end

        function __DARKLUA_BUNDLE_MODULES.y(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.y

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.y = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Transitions = {}

            function Transitions.FadeIn(Object: GuiObject)
                Object.Visible = true
                Object.BackgroundTransparency = 1

                Tween.Play(Object, 0.15, {BackgroundTransparency = 0})
            end
            function Transitions.FadeOut(Object: GuiObject)
                local Created = Tween.Play(Object, 0.15, {BackgroundTransparency = 1})

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
        end

        function __DARKLUA_BUNDLE_MODULES.z(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.z

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.z = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local AutoLayout = {}

            function AutoLayout.Vertical(Parent: Instance, Padding: number?)
                local Layout = Elements.List(Parent, Enum.FillDirection.Vertical, Padding or 0)

                Layout.HorizontalAlignment = Enum.HorizontalAlignment.Left

                return Layout
            end
            function AutoLayout.Horizontal(Parent: Instance, Padding: number?)
                local Layout = Elements.List(Parent, Enum.FillDirection.Horizontal, Padding or 0)

                Layout.VerticalAlignment = Enum.VerticalAlignment.Center

                return Layout
            end
            function AutoLayout.ResizeToContent(Frame: GuiObject, Layout: UIListLayout, Extra: number?)
                local function Update()
                    Frame.Size = UDim2.new(Frame.Size.X.Scale, Frame.Size.X.Offset, 0, Layout.AbsoluteContentSize.Y + (Extra or 0))
                end

                Layout:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(Update)
                task.defer(Update)
            end

            return AutoLayout
        end

        function __DARKLUA_BUNDLE_MODULES.A(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.A

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.A = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local BaseWidget = {}

            BaseWidget.__index = BaseWidget

            function BaseWidget.New(Section: any, Options: {[string]: any}, Height: number)
                local self = setmetatable({
                    Section = Section,
                    Window = Section.Window,
                    Library = Section.Window.Library,
                    Options = Options,
                    Flag = Options.Flag,
                    SkipFlag = Options.SkipFlag == true,
                    Value = Options.Default,
                    Callback = Options.Callback,
                    ThemeUnbinds = {},
                }, BaseWidget)

                self.Root = Elements.New('Frame', {
                    Name = Options.Text or 'Widget',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, Height),
                    LayoutOrder = Section:NextOrder(),
                    ZIndex = 30,
                }, Section.Body)::Frame

                if self.Flag then
                    self.Library.FlagManager:Register(self.Flag, self, self.Value, self.SkipFlag)

                    local Stored = self.Library.FlagManager:Get(self.Flag, nil)

                    if Stored ~= nil then
                        self.Value = Stored
                    end
                end

                self.FlagDestroyConnection = self.Root.Destroying:Connect(function()
                    self:UnregisterFlag()
                end)
                self.ThemeDestroyConnection = self.Root.Destroying:Connect(function()
                    self:UnbindTheme()
                end)

                return self
            end
            function BaseWidget:UnbindTheme()
                for _, Unbind in ipairs(self.ThemeUnbinds)do
                    pcall(Unbind)
                end

                table.clear(self.ThemeUnbinds)

                if self.ThemeDestroyConnection then
                    self.ThemeDestroyConnection:Disconnect()

                    self.ThemeDestroyConnection = nil
                end
            end
            function BaseWidget:UnregisterFlag()
                if self.Flag then
                    self.Library.FlagManager:Unregister(self.Flag, self)
                end
                if self.FlagDestroyConnection then
                    self.FlagDestroyConnection:Disconnect()

                    self.FlagDestroyConnection = nil
                end
            end
            function BaseWidget:Commit(Value: any, RunCallback: boolean?)
                self.Value = Value

                self.Library.FlagManager:Set(self.Flag, Value)

                if RunCallback ~= false then
                    self.Library:RunCallback(self.Options.Text or 'Widget', self.Callback, Value, self.Alpha)
                end
            end
            function BaseWidget:SetValue(Value: any, RunCallback: boolean?)
                self:Commit(Value, RunCallback)
            end
            function BaseWidget:Destroy()
                self:UnregisterFlag()
                self:UnbindTheme()

                if self.Root then
                    self.Root:Destroy()
                end
            end
            function BaseWidget:BindTheme(Binding: (any) -> ())
                if self.Window and self.Window.RegisterThemeBinding then
                    local Unbind = self.Window:RegisterThemeBinding(Binding)

                    if Unbind then
                        table.insert(self.ThemeUnbinds, Unbind)
                    end
                end
            end
            function BaseWidget:AddColor(Options: {[string]: any})
                return self.Section:AddColor(Options)
            end
            function BaseWidget:AddBind(Options: {[string]: any})
                return self.Section:AddBind(Options)
            end

            return BaseWidget
        end

        function __DARKLUA_BUNDLE_MODULES.B(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.B

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.B = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Toggle = {}

            Toggle.__index = Toggle

            setmetatable(Toggle, {__index = BaseWidget})

            function Toggle.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Default == true

                local self = BaseWidget.New(Section, Options, 40)

                setmetatable(self, Toggle)

                local Theme = self.Window.Theme
                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.new(1, -44, 0, 16),
                    Text = Options.Text or 'Toggle',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                self.Title = Title

                local Hint = Elements.New('TextLabel', {
                    Name = 'Hint',
                    Position = UDim2.fromOffset(0, 15),
                    Size = UDim2.new(1, -44, 0, 14),
                    Text = Options.Hint or '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Hint, Theme, 11, Theme.Hint)
                FontLoader.Apply(Hint, self.Library.AssetCache)

                self.Hint = Hint

                local Track = Elements.New('Frame', {
                    Name = 'Track',
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -1, 0, 5),
                    Size = UDim2.fromOffset(29, 16),
                    BackgroundColor3 = Theme.ToggleOff,
                    BorderSizePixel = 0,
                    ZIndex = 32,
                }, self.Root)::Frame

                Elements.Corner(Track, 8)

                self.Track = Track

                local Knob = Elements.New('Frame', {
                    Name = 'Knob',
                    Position = UDim2.fromOffset(2, 2),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = Theme.ToggleKnobOff,
                    BorderSizePixel = 0,
                    ZIndex = 33,
                }, Track)::Frame

                Elements.Corner(Knob, 6)

                self.Knob = Knob

                local Hit = Elements.New('TextButton', {
                    Name = 'Hitbox',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    Text = '',
                    ZIndex = 34,
                }, self.Root)::TextButton

                Hit.MouseButton1Click:Connect(function()
                    self:SetValue(not self.Value)
                end)

                self.Hit = Hit

                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    Hint.TextColor3 = NewTheme.Hint
                    Track.BackgroundColor3 = self.Value and NewTheme.Accent or NewTheme.ToggleOff
                    Knob.BackgroundColor3 = self.Value and NewTheme.Text or NewTheme.ToggleKnobOff
                end)
                self:SetValue(self.Value, false)

                return self
            end
            function Toggle:SetValue(Value: any, RunCallback: boolean?)
                local On = Value == true

                self:Commit(On, RunCallback)

                local Theme = self.Window.Theme

                Tween.Play(self.Track, 0.12, {
                    BackgroundColor3 = On and Theme.Accent or Theme.ToggleOff,
                })
                Tween.Play(self.Knob, 0.12, {
                    BackgroundColor3 = On and Theme.Text or Theme.ToggleKnobOff,
                    Position = On and UDim2.fromOffset(15, 2) or UDim2.fromOffset(2, 2),
                })
            end

            return Toggle
        end

        function __DARKLUA_BUNDLE_MODULES.C(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.C

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.C = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Slider = {}

            Slider.__index = Slider

            setmetatable(Slider, {__index = BaseWidget})

            local function Format(Options: {[string]: any}, Value: number): string
                if Options.Suffix then
                    local Text = Options.Decimals and string.format('%.' .. tostring(Options.Decimals) .. 'f', Value) or tostring(math.floor(Value + 0.5))

                    return Text .. (Options.SuffixSpacing == false and '' or ' ') .. Options.Suffix
                end
                if Options.Format == 'percent' then
                    return tostring(math.floor(Value + 0.5)) .. '%'
                elseif Options.Format == 'ms' then
                    return tostring(math.floor(Value + 0.5)) .. ' MS'
                elseif Options.Format == 'coefficient' then
                    return 'x' .. string.format('%.2f', Value)
                elseif Options.Format == 'fixed2' then
                    return string.format('%.2f', Value)
                end

                return tostring(math.floor(Value + 0.5))
            end

            function Slider.New(Section: any, Options: {[string]: any})
                Options.Min = Options.Min or 0
                Options.Max = Options.Max or 100
                Options.Step = Options.Step or 1
                Options.Default = Options.Default or Options.Value or Options.Min

                local self = BaseWidget.New(Section, Options, 52)

                setmetatable(self, Slider)

                self.Connections = {}

                local Theme = self.Window.Theme
                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(0.68, 0, 0, 16),
                    Text = Options.Text or 'Slider',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                self.Title = Title

                local ValueLabel = Elements.New('TextLabel', {
                    Name = 'Value',
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, 0, 0, 0),
                    Size = UDim2.new(0.35, 0, 0, 16),
                    Text = '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(ValueLabel, Theme, 12, Theme.Text)
                FontLoader.Apply(ValueLabel, self.Library.AssetCache)

                ValueLabel.TextXAlignment = Enum.TextXAlignment.Right
                self.ValueLabel = ValueLabel

                local Track = Elements.New('Frame', {
                    Name = 'Track',
                    Position = UDim2.fromOffset(0, 30),
                    Size = UDim2.new(1, 0, 0, 2),
                    BackgroundColor3 = Theme.SliderTrack,
                    BorderSizePixel = 0,
                    ZIndex = 31,
                }, self.Root)::Frame

                self.Track = Track

                local Fill = Elements.New('Frame', {
                    Name = 'Fill',
                    Size = UDim2.fromOffset(0, 2),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 32,
                }, Track)::Frame

                self.Fill = Fill

                local Knob = Elements.New('Frame', {
                    Name = 'Knob',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromOffset(0, 1),
                    Size = UDim2.fromOffset(12, 12),
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    ZIndex = 33,
                }, Track)::Frame

                Elements.Corner(Knob, 6)

                self.Knob = Knob

                local Dragging = false

                local function SetFromMouse()
                    local X = UserInputService:GetMouseLocation().X - Track.AbsolutePosition.X
                    local Ratio = math.clamp(X / math.max(Track.AbsoluteSize.X, 1), 0, 1)
                    local Raw = Options.Min + (Options.Max - Options.Min) * Ratio
                    local Stepped = math.floor((Raw / Options.Step) + 0.5) * Options.Step

                    self:SetValue(math.clamp(Stepped, Options.Min, Options.Max))
                end

                self:Track(Track.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true

                        SetFromMouse()
                    end
                end))
                self:Track(Knob.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = true
                    end
                end))
                self:Track(UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        Dragging = false
                    end
                end))
                self:Track(UserInputService.InputChanged:Connect(function(Input)
                    if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
                        SetFromMouse()
                    end
                end))

                self.DestroyConnection = self.Root.Destroying:Connect(function()
                    self:DisconnectInputs()
                end)

                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    ValueLabel.TextColor3 = NewTheme.Text
                    Track.BackgroundColor3 = NewTheme.SliderTrack
                    Fill.BackgroundColor3 = NewTheme.Accent
                    Knob.BackgroundColor3 = NewTheme.Accent
                end)
                self:SetValue(self.Value, false)

                return self
            end
            function Slider:Track(Connection: RBXScriptConnection)
                table.insert(self.Connections, Connection)

                return Connection
            end
            function Slider:DisconnectInputs()
                for _, Connection in ipairs(self.Connections)do
                    Connection:Disconnect()
                end

                table.clear(self.Connections)

                if self.DestroyConnection then
                    self.DestroyConnection:Disconnect()

                    self.DestroyConnection = nil
                end
            end
            function Slider:SetValue(Value: any, RunCallback: boolean?)
                local Number = tonumber(Value) or self.Options.Min

                Number = math.clamp(Number, self.Options.Min, self.Options.Max)

                self:Commit(Number, RunCallback)

                local Ratio = (Number - self.Options.Min) / math.max(self.Options.Max - self.Options.Min, 1)

                self.Fill.Size = UDim2.new(Ratio, 0, 0, 2)
                self.Knob.Position = UDim2.new(Ratio, 0, 0, 1)
                self.ValueLabel.Text = Format(self.Options, Number)
            end
            function Slider:Destroy()
                self:DisconnectInputs()
                BaseWidget.Destroy(self)
            end

            return Slider
        end

        function __DARKLUA_BUNDLE_MODULES.D(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.D

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.D = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Dropdown = {}

            Dropdown.__index = Dropdown

            setmetatable(Dropdown, {__index = BaseWidget})

            local function Contains(List: {any}, Value: any): boolean
                for _, Item in ipairs(List)do
                    if Item == Value then
                        return true
                    end
                end

                return false
            end
            local function Display(Value: any): string
                if type(Value) == 'table' then
                    return #Value > 0 and table.concat(Value, ', ') or 'None'
                end

                return tostring(Value or 'None')
            end

            function Dropdown.New(Section: any, Options: {[string]: any})
                Options.Values = Options.Values or Options.Options or {}

                local ProvidedDefault = if Options.Default ~= nil then Options.Default else Options.Value

                if Options.Multi then
                    Options.Default = ProvidedDefault

                    if Options.Default == nil then
                        Options.Default = {}
                    elseif type(Options.Default) ~= 'table' then
                        Options.Default = {
                            Options.Default,
                        }
                    end
                else
                    Options.Default = ProvidedDefault or Options.Values[1] or 'None'
                end
                if Options.Multi and type(Options.Default) ~= 'table' then
                    Options.Default = {
                        Options.Default,
                    }
                end

                local self = BaseWidget.New(Section, Options, 72)

                setmetatable(self, Dropdown)

                local Theme = self.Window.Theme
                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = Options.Text or 'Dropdown',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                local Hint = Elements.New('TextLabel', {
                    Name = 'Hint',
                    Position = UDim2.fromOffset(0, 15),
                    Size = UDim2.new(1, 0, 0, 14),
                    Text = Options.Hint or '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Hint, Theme, 11, Theme.Hint)
                FontLoader.Apply(Hint, self.Library.AssetCache)

                local Box = Elements.New('TextButton', {
                    Name = 'Box',
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.Control,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 32),
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = '',
                    ZIndex = 32,
                }, self.Root)::TextButton

                self.Box = Box

                Elements.Stroke(Box, Theme.Border, 0.45, 1)

                local Value = Elements.New('TextLabel', {
                    Name = 'Value',
                    Position = UDim2.fromOffset(18, 0),
                    Size = UDim2.new(1, -42, 1, 0),
                    Text = '',
                    ZIndex = 33,
                }, Box)::TextLabel

                Styling.ApplyText(Value, Theme, 12, Theme.Text)
                FontLoader.Apply(Value, self.Library.AssetCache)
                Styling.FitText(Value, 12, 9)

                self.ValueLabel = Value

                local Arrow = Elements.New('TextLabel', {
                    Name = 'Arrow',
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -14, 0, 0),
                    Size = UDim2.fromOffset(12, 26),
                    Text = 'v',
                    ZIndex = 33,
                }, Box)::TextLabel

                Styling.ApplyText(Arrow, Theme, 12, Theme.Muted)
                FontLoader.Apply(Arrow, self.Library.AssetCache)

                Arrow.TextXAlignment = Enum.TextXAlignment.Center
                self.Arrow = Arrow

                Box.MouseButton1Click:Connect(function()
                    self:ToggleMenu()
                end)
                Box.MouseEnter:Connect(function()
                    Tween.Play(Box, 0.12, {
                        BackgroundColor3 = self.Window.Theme.ControlHover,
                    })
                end)
                Box.MouseLeave:Connect(function()
                    Tween.Play(Box, 0.12, {
                        BackgroundColor3 = self.Window.Theme.Control,
                    })
                end)

                self.DestroyConnection = self.Root.Destroying:Connect(function()
                    self:CloseMenu(true)
                end)

                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    Hint.TextColor3 = NewTheme.Hint
                    Box.BackgroundColor3 = NewTheme.Control
                    Value.TextColor3 = NewTheme.Text
                    Arrow.TextColor3 = NewTheme.Muted

                    self:RefreshRows()
                end)
                self:SetValue(self.Value, false)

                return self
            end
            function Dropdown:CloseMenu(Immediate: boolean?)
                local Menu = self.Menu

                if Menu then
                    self.Menu = nil
                    self.OptionRows = nil

                    if Immediate then
                        Menu:Destroy()
                    else
                        local CloseTween = Tween.Play(Menu, 0.12, {
                            Size = UDim2.fromOffset(Menu.AbsoluteSize.X, 0),
                            BackgroundTransparency = 0.15,
                        }, Enum.EasingStyle.Quad, Enum.EasingDirection.In)

                        CloseTween.Completed:Connect(function()
                            if Menu and Menu.Parent then
                                Menu:Destroy()
                            end
                        end)
                    end
                end
                if self.Window.Dropdown == self then
                    self.Window.Dropdown = nil
                end
                if self.Arrow and self.Arrow.Parent then
                    if Immediate then
                        self.Arrow.Rotation = 0
                    else
                        Tween.Play(self.Arrow, 0.12, {Rotation = 0})
                    end
                end
            end
            function Dropdown:ToggleMenu()
                if self.Menu then
                    self:CloseMenu()
                else
                    self:OpenMenu()
                end
            end
            function Dropdown:OpenMenu()
                if self.Window.Dropdown and self.Window.Dropdown ~= self then
                    self.Window.Dropdown:CloseMenu()
                end
                if self.Options.GetValues then
                    local Ok, Values = pcall(self.Options.GetValues)

                    if Ok and type(Values) == 'table' then
                        self.Options.Values = Values
                    end
                end

                self.Window.Dropdown = self

                local Theme = self.Window.Theme
                local RootPosition = self.Window.Root.AbsolutePosition
                local BoxPosition = self.Box.AbsolutePosition
                local RowHeight = 24
                local OpenHeight = math.max(RowHeight, math.min(#self.Options.Values, 7) * RowHeight)
                local Menu = Elements.New('Frame', {
                    Name = 'DropdownMenu',
                    BackgroundColor3 = Theme.ControlHover,
                    BackgroundTransparency = 0.15,
                    BorderSizePixel = 0,
                    ClipsDescendants = true,
                    Position = UDim2.fromOffset(BoxPosition.X - RootPosition.X, BoxPosition.Y - RootPosition.Y + self.Box.AbsoluteSize.Y + 2),
                    Size = UDim2.fromOffset(self.Box.AbsoluteSize.X, 0),
                    ZIndex = 210,
                }, self.Window.Overlay)::Frame

                Elements.Stroke(Menu, Theme.Border, 0, 1)

                self.Menu = Menu
                self.OptionRows = {}

                Tween.Play(Menu, 0.14, {
                    Size = UDim2.fromOffset(self.Box.AbsoluteSize.X, OpenHeight),
                    BackgroundTransparency = 0,
                })
                Tween.Play(self.Arrow, 0.14, {Rotation = 180})

                local Scroll = Elements.New('ScrollingFrame', {
                    Name = 'Options',
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    CanvasSize = UDim2.fromOffset(0, #self.Options.Values * RowHeight),
                    ScrollBarImageColor3 = Theme.Accent,
                    ScrollBarThickness = #self.Options.Values > 7 and 2 or 0,
                    ScrollingDirection = Enum.ScrollingDirection.Y,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 211,
                }, Menu)::ScrollingFrame

                for Index, Option in ipairs(self.Options.Values)do
                    local Row = Elements.New('TextButton', {
                        Name = 'Option' .. tostring(Index),
                        AutoButtonColor = false,
                        BackgroundColor3 = Theme.ControlHover,
                        BackgroundTransparency = 0.08,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(0, (Index - 1) * RowHeight),
                        Size = UDim2.new(1, -2, 0, RowHeight),
                        Text = '',
                        ZIndex = 211,
                    }, Scroll)::TextButton
                    local Indicator = Elements.New('Frame', {
                        Name = 'Indicator',
                        AnchorPoint = Vector2.new(0, 0.5),
                        BackgroundColor3 = Theme.Accent,
                        BackgroundTransparency = 1,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(9, 12),
                        Size = UDim2.fromOffset(5, 5),
                        ZIndex = 212,
                    }, Row)::Frame

                    Elements.Corner(Indicator, 4)

                    local Label = Elements.New('TextLabel', {
                        Name = 'Label',
                        Position = UDim2.fromOffset(20, 0),
                        Size = UDim2.new(1, -30, 1, 0),
                        Text = tostring(Option),
                        ZIndex = 212,
                    }, Row)::TextLabel

                    Styling.ApplyText(Label, Theme, 12, Theme.Text)
                    FontLoader.Apply(Label, self.Library.AssetCache)

                    self.OptionRows[Index] = {
                        Option = Option,
                        Row = Row,
                        Label = Label,
                        Indicator = Indicator,
                    }

                    Row.MouseEnter:Connect(function()
                        Tween.Play(Row, 0.1, {
                            BackgroundColor3 = Theme.Control,
                        })
                    end)
                    Row.MouseLeave:Connect(function()
                        Tween.Play(Row, 0.12, {
                            BackgroundColor3 = self.Window.Theme.ControlHover,
                        })
                    end)
                    Row.MouseButton1Click:Connect(function()
                        Tween.Press(Row, Theme.Control, Theme.ControlHover)

                        if self.Options.Multi then
                            local Next = table.clone(self.Value)

                            if Contains(Next, Option) then
                                for I = #Next, 1, -1 do
                                    if Next[I] == Option then
                                        table.remove(Next, I)
                                    end
                                end
                            else
                                table.insert(Next, Option)
                            end

                            self:SetValue(Next)
                            self:RefreshRows()
                        else
                            self:SetValue(Option)
                            self:CloseMenu()
                        end
                    end)
                end

                self:RefreshRows()
            end
            function Dropdown:SetValue(Value: any, RunCallback: boolean?)
                if self.Options.Multi and type(Value) ~= 'table' then
                    Value = {Value}
                end

                self:Commit(Value, RunCallback)

                self.ValueLabel.Text = Display(Value)
            end
            function Dropdown:SetValues(Values: {any}, PreferredValue: any?)
                self.Options.Values = Values or {}

                local NextValue = PreferredValue or self.Value

                if self.Options.Multi then
                    local Source = if type(NextValue) == 'table'then NextValue else{NextValue}
                    local Filtered = {}

                    for _, Item in ipairs(Source)do
                        if Contains(self.Options.Values, Item) then
                            table.insert(Filtered, Item)
                        end
                    end

                    self:SetValue(Filtered, false)
                elseif not Contains(self.Options.Values, NextValue) then
                    self:SetValue(self.Options.Values[1] or 'None', false)
                else
                    self:SetValue(NextValue, false)
                end
                if self.Menu then
                    local OldMenu = self.Menu

                    self.Menu = nil
                    self.OptionRows = nil

                    OldMenu:Destroy()
                    self:OpenMenu()
                else
                    self:RefreshRows()
                end
            end
            function Dropdown:RefreshRows()
                if not self.OptionRows then
                    return
                end

                local Theme = self.Window.Theme

                for _, Record in ipairs(self.OptionRows)do
                    local Selected = if self.Options.Multi then Contains(self.Value, Record.Option)else self.Value == Record.Option

                    Record.Indicator.BackgroundColor3 = Theme.Accent
                    Record.Indicator.BackgroundTransparency = Selected and 0 or 1
                    Record.Label.TextColor3 = Selected and Theme.Text or Theme.Muted
                    Record.Row.BackgroundColor3 = Theme.ControlHover
                end

                if self.Menu then
                    self.Menu.BackgroundColor3 = Theme.ControlHover
                end
            end
            function Dropdown:Destroy()
                self:CloseMenu(true)

                if self.DestroyConnection then
                    self.DestroyConnection:Disconnect()

                    self.DestroyConnection = nil
                end

                BaseWidget.Destroy(self)
            end

            return Dropdown
        end

        function __DARKLUA_BUNDLE_MODULES.E(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.E

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.E = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Palette = __DARKLUA_BUNDLE_MODULES.k()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Button = {}

            Button.__index = Button

            setmetatable(Button, {__index = BaseWidget})

            function Button.New(Section: any, Options: {[string]: any})
                local self = BaseWidget.New(Section, Options, Options.Height or 40)

                setmetatable(self, Button)

                local Theme = self.Window.Theme
                local Base = Options.Tone == 'danger' and Color3.fromRGB(166, 34, 24) or Theme.Accent
                local Control = Elements.New('TextButton', {
                    Name = 'Button',
                    AutoButtonColor = false,
                    BackgroundColor3 = Base,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 6),
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = Options.Text or 'BUTTON',
                    ZIndex = 31,
                }, self.Root)::TextButton

                Styling.ApplyText(Control, Theme, 12, Theme.Text)
                FontLoader.Apply(Control, self.Library.AssetCache)

                Control.TextXAlignment = Enum.TextXAlignment.Center

                Styling.FitText(Control, 12, 9)

                self.Control = Control
                self.BaseColor = Base

                Control.MouseButton1Down:Connect(function()
                    Tween.Play(Control, 0.08, {
                        BackgroundColor3 = Palette.Lighten(self.BaseColor, 0.16),
                    })
                end)
                Control.MouseButton1Up:Connect(function()
                    Tween.Play(Control, 0.12, {
                        BackgroundColor3 = self.BaseColor,
                    })
                end)
                Control.MouseLeave:Connect(function()
                    Tween.Play(Control, 0.12, {
                        BackgroundColor3 = self.BaseColor,
                    })
                end)
                Control.MouseButton1Click:Connect(function()
                    self.Library:RunCallback(Options.Text or 'Button', self.Callback)
                end)
                self:BindTheme(function(NewTheme)
                    if Options.Tone ~= 'danger' then
                        self.BaseColor = NewTheme.Accent
                        Control.BackgroundColor3 = self.BaseColor
                    end

                    Control.TextColor3 = NewTheme.Text
                end)

                return self
            end

            return Button
        end

        function __DARKLUA_BUNDLE_MODULES.F(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.F

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.F = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Textbox = {}

            Textbox.__index = Textbox

            setmetatable(Textbox, {__index = BaseWidget})

            function Textbox.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Default or ''

                local self = BaseWidget.New(Section, Options, 52)

                setmetatable(self, Textbox)

                local Theme = self.Window.Theme
                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, 0, 0, 16),
                    Text = Options.Text or 'Textbox',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                local Box = Elements.New('TextBox', {
                    Name = 'Box',
                    BackgroundColor3 = Theme.Control,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Position = UDim2.fromOffset(0, 22),
                    Size = UDim2.new(1, 0, 0, 26),
                    Text = tostring(self.Value),
                    ZIndex = 32,
                }, self.Root)::TextBox

                Styling.ApplyText(Box, Theme, 12, Theme.Text)
                FontLoader.Apply(Box, self.Library.AssetCache)

                Box.TextXAlignment = Enum.TextXAlignment.Left
                self.Box = Box

                Box.FocusLost:Connect(function()
                    self:SetValue(Box.Text)
                end)
                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    Box.BackgroundColor3 = NewTheme.Control
                    Box.TextColor3 = NewTheme.Text
                end)

                return self
            end
            function Textbox:SetValue(Value: any, RunCallback: boolean?)
                self:Commit(tostring(Value or ''), RunCallback)

                if self.Box.Text ~= self.Value then
                    self.Box.Text = self.Value
                end
            end

            return Textbox
        end

        function __DARKLUA_BUNDLE_MODULES.G(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.G

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.G = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local KeybindManager = __DARKLUA_BUNDLE_MODULES.p()
            local Keybind = {}

            Keybind.__index = Keybind

            setmetatable(Keybind, {__index = BaseWidget})

            function Keybind.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Default or Options.Value or 'None'

                local ActivationCallback = Options.Callback or Options.OnPressed

                Options.Callback = Options.Changed or Options.OnChanged

                local self = BaseWidget.New(Section, Options, 40)

                setmetatable(self, Keybind)

                self.ActivationCallback = ActivationCallback

                local Theme = self.Window.Theme
                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, -86, 0, 16),
                    Text = Options.Text or 'Keybind',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                local Hint = Elements.New('TextLabel', {
                    Name = 'Hint',
                    Position = UDim2.fromOffset(0, 15),
                    Size = UDim2.new(1, -86, 0, 14),
                    Text = Options.Hint or '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Hint, Theme, 11, Theme.Hint)
                FontLoader.Apply(Hint, self.Library.AssetCache)

                local Box = Elements.New('TextButton', {
                    Name = 'Box',
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0),
                    BackgroundColor3 = Theme.Control,
                    BorderSizePixel = 0,
                    Position = UDim2.new(1, 0, 0, 1),
                    Size = UDim2.fromOffset(84, 26),
                    Text = tostring(self.Value),
                    ZIndex = 32,
                }, self.Root)::TextButton

                Styling.ApplyText(Box, Theme, 12, Theme.Text)
                FontLoader.Apply(Box, self.Library.AssetCache)

                Box.TextXAlignment = Enum.TextXAlignment.Center

                Styling.FitText(Box, 12, 9)

                self.Box = Box

                Box.MouseButton1Click:Connect(function()
                    self:Listen()
                end)

                self.ActivationConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
                    if Processed or self.Listening then
                        return
                    end
                    if KeybindManager.IsActivation(Input, self.Value) then
                        self.Library:RunCallback(Options.Text or 'Keybind', self.ActivationCallback, self.Value, Input)
                    end
                end)
                self.DestroyConnection = self.Root.Destroying:Connect(function()
                    self:DisconnectInputs()
                end)

                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    Hint.TextColor3 = NewTheme.Hint
                    Box.BackgroundColor3 = NewTheme.Control
                    Box.TextColor3 = NewTheme.Text
                end)
                self:SetValue(self.Value, false)

                return self
            end
            function Keybind:Listen()
                if self.Listening then
                    return
                end

                self.Listening = true
                self.Box.Text = '...'

                if self.ListenConnection then
                    self.ListenConnection:Disconnect()
                end

                self.ListenConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
                    if Processed then
                        return
                    end

                    self.ListenConnection:Disconnect()

                    self.ListenConnection = nil
                    self.Listening = false

                    self:SetValue(KeybindManager.Normalize(Input))
                end)
            end
            function Keybind:SetValue(Value: any, RunCallback: boolean?)
                self:Commit(KeybindManager.Normalize(Value or 'None'), RunCallback)

                self.Box.Text = self.Value
            end
            function Keybind:DisconnectInputs()
                if self.ListenConnection then
                    self.ListenConnection:Disconnect()

                    self.ListenConnection = nil
                end
                if self.ActivationConnection then
                    self.ActivationConnection:Disconnect()

                    self.ActivationConnection = nil
                end
                if self.DestroyConnection then
                    self.DestroyConnection:Disconnect()

                    self.DestroyConnection = nil
                end
            end
            function Keybind:Destroy()
                self:DisconnectInputs()
                BaseWidget.Destroy(self)
            end

            return Keybind
        end

        function __DARKLUA_BUNDLE_MODULES.H(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.H

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.H = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Palette = __DARKLUA_BUNDLE_MODULES.k()
            local ColorPickerUtils = {}

            ColorPickerUtils.Templates = {
                '#ff1412',
                '#5184ec',
                '#dff852',
                '#eab423',
                '#45d2c0',
                '#fee2eb',
                '#e852a7',
                '#ffffff',
            }
            ColorPickerUtils.HueSequence = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 0, 0)),
                ColorSequenceKeypoint.new(0.17, Color3.fromRGB(255, 255, 0)),
                ColorSequenceKeypoint.new(0.33, Color3.fromRGB(0, 255, 0)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(0, 255, 255)),
                ColorSequenceKeypoint.new(0.67, Color3.fromRGB(0, 0, 255)),
                ColorSequenceKeypoint.new(0.83, Color3.fromRGB(255, 0, 255)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 0, 0)),
            })

            function ColorPickerUtils.ToColorAlpha(Value: any): (Color3,number?)
                if typeof(Value) == 'Color3' then
                    return Value, nil
                end
                if type(Value) == 'table' then
                    local Color, Alpha = ColorPickerUtils.ToColorAlpha(Value.Color or Value.Value)

                    return Color, tonumber(Value.Alpha) or Alpha
                end
                if type(Value) == 'string' then
                    local Color, Alpha = Palette.ParseWithAlpha(Value)

                    return Color or Palette.Hex(Value), Alpha
                end

                return Color3.new(1, 1, 1), nil
            end
            function ColorPickerUtils.AddGradient(
                Frame: Frame,
                Color: ColorSequence,
                Transparency: NumberSequence?,
                Rotation: number?
            )
                local Gradient = Instance.new('UIGradient')

                Gradient.Color = Color

                if Transparency then
                    Gradient.Transparency = Transparency
                end

                Gradient.Rotation = Rotation or 0
                Gradient.Parent = Frame

                return Gradient
            end

            return ColorPickerUtils
        end

        function __DARKLUA_BUNDLE_MODULES.I(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.I

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.I = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Palette = __DARKLUA_BUNDLE_MODULES.k()
            local Utils = __DARKLUA_BUNDLE_MODULES.I()
            local ColorPicker = {}

            ColorPicker.__index = ColorPicker

            setmetatable(ColorPicker, {__index = BaseWidget})

            function ColorPicker.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Default or Options.Value or Color3.new(1, 1, 1)

                local self = BaseWidget.New(Section, Options, 40)

                setmetatable(self, ColorPicker)

                local Theme = self.Window.Theme

                self.PopupConnections = {}
                self.Alpha = math.clamp(tonumber(Options.Alpha or Options.DefaultAlpha) or 1, 0, 1)

                if self.Flag then
                    local AlphaFlag = self.Flag .. '.Alpha'

                    self.AlphaFlag = AlphaFlag

                    local StoredAlpha = self.Library.FlagManager:Get(AlphaFlag, nil)

                    if StoredAlpha ~= nil then
                        self.Alpha = math.clamp(tonumber(StoredAlpha) or self.Alpha, 0, 1)
                    end

                    self.Library.FlagManager:Register(AlphaFlag, {
                        SetValue = function(_, Value, RunCallback)
                            self:SetAlpha(Value, RunCallback)
                        end,
                    }, self.Alpha, self.SkipFlag)
                end

                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, -44, 0, 16),
                    Text = Options.Text or 'Color',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, self.Library.AssetCache)

                local Hint = Elements.New('TextLabel', {
                    Name = 'Hint',
                    Position = UDim2.fromOffset(0, 15),
                    Size = UDim2.new(1, -44, 0, 14),
                    Text = Options.Hint or '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Hint, Theme, 11, Theme.Hint)
                FontLoader.Apply(Hint, self.Library.AssetCache)

                local Swatch = Elements.New('TextButton', {
                    Name = 'Swatch',
                    AutoButtonColor = false,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -1, 0, 5),
                    Size = UDim2.fromOffset(15, 15),
                    BackgroundColor3 = (Utils.ToColorAlpha(self.Value)),
                    BorderSizePixel = 0,
                    Text = '',
                    ZIndex = 32,
                }, self.Root)::TextButton

                Elements.Corner(Swatch, 8)
                Elements.Stroke(Swatch, Theme.Border, 0, 1)

                self.Swatch = Swatch

                Swatch.MouseButton1Click:Connect(function()
                    self:TogglePicker()
                end)

                self.DestroyConnection = self.Root.Destroying:Connect(function()
                    self:ClosePicker()

                    if self.AlphaFlag then
                        self.Library.FlagManager:Unregister(self.AlphaFlag)
                    end
                end)

                self:BindTheme(function(NewTheme)
                    Title.TextColor3 = NewTheme.Text
                    Hint.TextColor3 = NewTheme.Hint

                    if self.Popup then
                        self.Popup.BackgroundColor3 = NewTheme.Surface
                    end
                    if self.Apply then
                        self.Apply.BackgroundColor3 = NewTheme.Accent
                        self.Apply.TextColor3 = NewTheme.Text
                    end
                    if self.Hex then
                        self.Hex.BackgroundColor3 = NewTheme.Control
                        self.Hex.TextColor3 = NewTheme.Text
                    end
                end)
                self:SetValue(self.Value, false)

                return self
            end
            function ColorPicker:DisconnectPopup()
                for _, Connection in ipairs(self.PopupConnections)do
                    Connection:Disconnect()
                end

                table.clear(self.PopupConnections)
            end
            function ColorPicker:Track(Connection: RBXScriptConnection)
                table.insert(self.PopupConnections, Connection)

                return Connection
            end
            function ColorPicker:ClosePicker()
                self:DisconnectPopup()

                self.DragTarget = nil

                if self.Popup then
                    self.Popup:Destroy()

                    self.Popup = nil
                    self.Apply = nil
                    self.Hex = nil
                    self.Preview = nil
                    self.Square = nil
                    self.SquareCursor = nil
                    self.HueCursor = nil
                    self.AlphaBar = nil
                    self.AlphaCursor = nil
                end
            end
            function ColorPicker:TogglePicker()
                if self.Popup then
                    self:ClosePicker()
                else
                    self:OpenPicker()
                end
            end
            function ColorPicker:CreateColorSquare(Parent: Instance, Theme: {[string]: any})
                local Square = Elements.New('Frame', {
                    Name = 'ColorSquare',
                    BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(10, 40),
                    Size = UDim2.fromOffset(170, 118),
                    ZIndex = 221,
                }, Parent)::Frame

                self.Square = Square

                local White = Elements.New('Frame', {
                    Name = 'White',
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 222,
                }, Square)::Frame

                Utils.AddGradient(White, ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 0),
                    NumberSequenceKeypoint.new(1, 1),
                }))

                local Black = Elements.New('Frame', {
                    Name = 'Black',
                    BackgroundColor3 = Color3.new(0, 0, 0),
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 223,
                }, Square)::Frame

                Utils.AddGradient(Black, ColorSequence.new(Color3.new(0, 0, 0)), NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                }), 90)

                local Cursor = Elements.New('Frame', {
                    Name = 'Cursor',
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(8, 8),
                    ZIndex = 224,
                }, Square)::Frame

                Elements.Corner(Cursor, 4)

                self.SquareCursor = Cursor

                self:Track(Square.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        self.DragTarget = 'square'

                        self:UpdateFromSquare()
                    end
                end))
            end
            function ColorPicker:CreateHueBar(Parent: Instance, Theme: {[string]: any})
                local Bar = Elements.New('Frame', {
                    Name = 'Hue',
                    BackgroundColor3 = Color3.new(1, 1, 1),
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(10, 168),
                    Size = UDim2.fromOffset(170, 10),
                    ZIndex = 221,
                }, Parent)::Frame

                Utils.AddGradient(Bar, Utils.HueSequence)

                self.HueBar = Bar

                local Cursor = Elements.New('Frame', {
                    Name = 'HueCursor',
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(6, 14),
                    ZIndex = 222,
                }, Bar)::Frame

                Elements.Corner(Cursor, 3)

                self.HueCursor = Cursor

                self:Track(Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        self.DragTarget = 'hue'

                        self:UpdateFromHue()
                    end
                end))
            end
            function ColorPicker:CreateAlphaBar(Parent: Instance, Theme: {[string]: any})
                local Bar = Elements.New('Frame', {
                    Name = 'Alpha',
                    BackgroundColor3 = self.Value,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(10, 184),
                    Size = UDim2.fromOffset(170, 10),
                    ZIndex = 221,
                }, Parent)::Frame

                Utils.AddGradient(Bar, ColorSequence.new(Color3.new(1, 1, 1)), NumberSequence.new({
                    NumberSequenceKeypoint.new(0, 1),
                    NumberSequenceKeypoint.new(1, 0),
                }))

                self.AlphaBar = Bar

                local Cursor = Elements.New('Frame', {
                    Name = 'AlphaCursor',
                    BackgroundColor3 = Theme.Text,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(6, 14),
                    ZIndex = 222,
                }, Bar)::Frame

                Elements.Corner(Cursor, 3)

                self.AlphaCursor = Cursor

                self:Track(Bar.InputBegan:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        self.DragTarget = 'alpha'

                        self:UpdateFromAlpha()
                    end
                end))
            end
            function ColorPicker:CreateTemplates(Parent: Instance)
                for Index, Hex in ipairs(Utils.Templates)do
                    local Button = Elements.New('TextButton', {
                        Name = 'Template' .. tostring(Index),
                        AutoButtonColor = false,
                        BackgroundColor3 = Palette.Hex(Hex),
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(10 + (Index - 1) * 21, 238),
                        Size = UDim2.fromOffset(15, 15),
                        Text = '',
                        ZIndex = 221,
                    }, Parent)::TextButton

                    Elements.Corner(Button, 8)
                    self:Track(Button.MouseButton1Click:Connect(function()
                        self:SetValue(Palette.Hex(Hex))
                    end))
                end
            end
            function ColorPicker:OpenPicker()
                local Theme = self.Window.Theme
                local RootPosition = self.Window.Root.AbsolutePosition
                local BoxPosition = self.Swatch.AbsolutePosition
                local Popup = Elements.New('Frame', {
                    Name = 'ColorPickerPopup',
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(BoxPosition.X - RootPosition.X - 174, BoxPosition.Y - RootPosition.Y + 22),
                    Size = UDim2.fromOffset(190, 264),
                    ZIndex = 220,
                }, self.Window.Overlay)::Frame

                Elements.Stroke(Popup, Theme.Border, 0, 1)

                self.Popup = Popup
                self.Preview = Elements.New('Frame', {
                    Name = 'Preview',
                    BackgroundColor3 = self.Value,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(10, 10),
                    Size = UDim2.fromOffset(170, 20),
                    ZIndex = 221,
                }, Popup)::Frame

                self:CreateColorSquare(Popup, Theme)
                self:CreateHueBar(Popup, Theme)
                self:CreateAlphaBar(Popup, Theme)

                local Hex = Elements.New('TextBox', {
                    Name = 'Hex',
                    BackgroundColor3 = Theme.Control,
                    BorderSizePixel = 0,
                    ClearTextOnFocus = false,
                    Position = UDim2.fromOffset(10, 204),
                    Size = UDim2.fromOffset(104, 24),
                    Text = Palette.ToRgba(self.Value, self.Alpha),
                    ZIndex = 221,
                }, Popup)::TextBox

                Styling.ApplyText(Hex, Theme, 12, Theme.Text)
                FontLoader.Apply(Hex, self.Library.AssetCache)

                self.Hex = Hex

                local Apply = Elements.New('TextButton', {
                    Name = 'Apply',
                    AutoButtonColor = false,
                    BackgroundColor3 = Theme.Accent,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(122, 204),
                    Size = UDim2.fromOffset(58, 24),
                    Text = 'APPLY',
                    ZIndex = 221,
                }, Popup)::TextButton

                Styling.ApplyText(Apply, Theme, 12, Theme.Text)
                FontLoader.Apply(Apply, self.Library.AssetCache)

                Apply.TextXAlignment = Enum.TextXAlignment.Center
                self.Apply = Apply

                self:Track(Apply.MouseButton1Click:Connect(function()
                    local Color, Alpha = Palette.ParseWithAlpha(Hex.Text)

                    self:SetValue({
                        Color = Color or self.Value,
                        Alpha = Alpha,
                    })
                end))
                self:Track(Hex.FocusLost:Connect(function()
                    local Color, Alpha = Palette.ParseWithAlpha(Hex.Text)

                    self:SetValue({
                        Color = Color or self.Value,
                        Alpha = Alpha,
                    })
                end))
                self:Track(UserInputService.InputChanged:Connect(function(Input)
                    if Input.UserInputType ~= Enum.UserInputType.MouseMovement then
                        return
                    end
                    if self.DragTarget == 'square' then
                        self:UpdateFromSquare()
                    elseif self.DragTarget == 'hue' then
                        self:UpdateFromHue()
                    elseif self.DragTarget == 'alpha' then
                        self:UpdateFromAlpha()
                    end
                end))
                self:Track(UserInputService.InputEnded:Connect(function(Input)
                    if Input.UserInputType == Enum.UserInputType.MouseButton1 then
                        self.DragTarget = nil
                    end
                end))
                self:CreateTemplates(Popup)
                self:UpdateVisuals()
            end
            function ColorPicker:UpdateFromSquare()
                if not self.Square then
                    return
                end

                local Mouse = UserInputService:GetMouseLocation()
                local Position = self.Square.AbsolutePosition
                local Size = self.Square.AbsoluteSize

                self.Saturation = math.clamp((Mouse.X - Position.X) / math.max(Size.X, 1), 0, 1)
                self.Brightness = 1 - math.clamp((Mouse.Y - Position.Y) / math.max(Size.Y, 1), 0, 1)

                self:SetValue(Color3.fromHSV(self.Hue, self.Saturation, self.Brightness))
            end
            function ColorPicker:UpdateFromHue()
                if not self.HueBar then
                    return
                end

                local Mouse = UserInputService:GetMouseLocation()
                local Position = self.HueBar.AbsolutePosition
                local Size = self.HueBar.AbsoluteSize

                self.Hue = math.clamp((Mouse.X - Position.X) / math.max(Size.X, 1), 0, 1)

                self:SetValue(Color3.fromHSV(self.Hue, self.Saturation, self.Brightness))
            end
            function ColorPicker:UpdateFromAlpha()
                if not self.AlphaBar then
                    return
                end

                local Mouse = UserInputService:GetMouseLocation()
                local Position = self.AlphaBar.AbsolutePosition
                local Size = self.AlphaBar.AbsoluteSize

                self:SetAlpha((Mouse.X - Position.X) / math.max(Size.X, 1))
            end
            function ColorPicker:SetAlpha(Value: any, RunCallback: boolean?)
                self.Alpha = math.clamp(tonumber(Value) or self.Alpha or 1, 0, 1)

                if self.Flag then
                    self.Library.FlagManager:Set(self.Flag .. '.Alpha', self.Alpha)
                end
                if RunCallback ~= false then
                    self.Library:RunCallback(self.Options.Text or 'Color', self.Callback, self.Value, self.Alpha)
                end

                self:UpdateVisuals()
            end
            function ColorPicker:UpdateVisuals()
                local Color = self.Value

                self.Swatch.BackgroundColor3 = Color
                self.Swatch.BackgroundTransparency = 1 - self.Alpha

                if self.Preview then
                    self.Preview.BackgroundColor3 = Color
                    self.Preview.BackgroundTransparency = 1 - self.Alpha
                end
                if self.Square then
                    self.Square.BackgroundColor3 = Color3.fromHSV(self.Hue, 1, 1)
                end
                if self.SquareCursor then
                    self.SquareCursor.Position = UDim2.new(self.Saturation, -4, 1 - self.Brightness, -4)
                end
                if self.HueCursor then
                    self.HueCursor.Position = UDim2.new(self.Hue, -3, 0, -2)
                end
                if self.AlphaBar then
                    self.AlphaBar.BackgroundColor3 = Color
                end
                if self.AlphaCursor then
                    self.AlphaCursor.Position = UDim2.new(self.Alpha, -3, 0, -2)
                end
                if self.Hex then
                    self.Hex.Text = self.Alpha < 0.999 and Palette.ToRgba(Color, self.Alpha) or Palette.ToHex(Color)
                end
            end
            function ColorPicker:SetValue(Value: any, RunCallback: boolean?)
                local Color, Alpha = Utils.ToColorAlpha(Value)

                if Alpha ~= nil then
                    self.Alpha = math.clamp(Alpha, 0, 1)
                end
                if self.Flag then
                    self.Library.FlagManager:Set(self.Flag .. '.Alpha', self.Alpha)
                end

                self.Hue, self.Saturation, self.Brightness = Color3.toHSV(Color)

                self:Commit(Color, RunCallback)
                self:UpdateVisuals()
            end
            function ColorPicker:Destroy()
                self:ClosePicker()

                if self.AlphaFlag then
                    self.Library.FlagManager:Unregister(self.AlphaFlag)
                end
                if self.DestroyConnection then
                    self.DestroyConnection:Disconnect()

                    self.DestroyConnection = nil
                end

                BaseWidget.Destroy(self)
            end

            return ColorPicker
        end

        function __DARKLUA_BUNDLE_MODULES.J(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.J

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.J = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local ImageLoader = __DARKLUA_BUNDLE_MODULES.r()
            local HitboxPreview = {}

            HitboxPreview.__index = HitboxPreview

            setmetatable(HitboxPreview, {__index = BaseWidget})

            local Priorities = {
                {
                    Id = 'First',
                    Color = Color3.fromRGB(72, 25, 20),
                },
                {
                    Id = 'Second',
                    Color = Color3.fromRGB(75, 54, 27),
                },
                {
                    Id = 'Third',
                    Color = Color3.fromRGB(35, 61, 23),
                },
                {
                    Id = 'Fourth',
                    Color = Color3.fromRGB(12, 62, 90),
                },
                {
                    Id = 'Ignore',
                    Color = Color3.fromRGB(29, 30, 36),
                },
            }
            local Regions = {
                {
                    Id = 'Head',
                    X = 73,
                    Y = 12,
                    W = 34,
                    H = 48,
                },
                {
                    Id = 'Body',
                    X = 52,
                    Y = 60,
                    W = 78,
                    H = 116,
                },
                {
                    Id = 'LeftArm',
                    X = 18,
                    Y = 72,
                    W = 42,
                    H = 118,
                },
                {
                    Id = 'RightArm',
                    X = 122,
                    Y = 72,
                    W = 42,
                    H = 118,
                },
                {
                    Id = 'LeftLeg',
                    X = 54,
                    Y = 170,
                    W = 38,
                    H = 110,
                },
                {
                    Id = 'RightLeg',
                    X = 91,
                    Y = 170,
                    W = 38,
                    H = 110,
                },
            }
            local FallbackParts = {
                {
                    Name = 'Head',
                    X = 75,
                    Y = 14,
                    W = 30,
                    H = 38,
                    Round = 18,
                },
                {
                    Name = 'Neck',
                    X = 82,
                    Y = 52,
                    W = 16,
                    H = 16,
                    Round = 4,
                },
                {
                    Name = 'Torso',
                    X = 56,
                    Y = 66,
                    W = 68,
                    H = 104,
                    Round = 4,
                },
                {
                    Name = 'LeftArm',
                    X = 24,
                    Y = 78,
                    W = 24,
                    H = 108,
                    Round = 4,
                },
                {
                    Name = 'RightArm',
                    X = 132,
                    Y = 78,
                    W = 24,
                    H = 108,
                    Round = 4,
                },
                {
                    Name = 'LeftLeg',
                    X = 58,
                    Y = 170,
                    W = 28,
                    H = 108,
                    Round = 4,
                },
                {
                    Name = 'RightLeg',
                    X = 94,
                    Y = 170,
                    W = 28,
                    H = 108,
                    Round = 4,
                },
            }

            function HitboxPreview:CreateImageFallback(Theme: {[string]: any})
                local Holder = Elements.New('Frame', {
                    Name = 'PreviewFallback',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(17, 8),
                    Size = UDim2.fromOffset(178, 274),
                    ZIndex = 30,
                }, self.Root)::Frame

                self.FallbackParts = {}

                for _, Part in ipairs(FallbackParts)do
                    local Frame = Elements.New('Frame', {
                        Name = Part.Name,
                        BackgroundColor3 = Theme.Muted,
                        BackgroundTransparency = 0.52,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(Part.X, Part.Y),
                        Size = UDim2.fromOffset(Part.W, Part.H),
                        ZIndex = 30,
                    }, Holder)::Frame

                    Elements.Corner(Frame, Part.Round)
                    table.insert(self.FallbackParts, Frame)
                end

                self:BindTheme(function(NewTheme)
                    for _, Part in ipairs(self.FallbackParts)do
                        Part.BackgroundColor3 = NewTheme.Muted
                    end
                end)
            end
            function HitboxPreview.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Default or {}

                local self = BaseWidget.New(Section, Options, 390)

                setmetatable(self, HitboxPreview)

                local Theme = self.Window.Theme

                self.RegionState = table.clone(self.Value)
                self.Overlays = {}

                local Image = Elements.New('ImageLabel', {
                    Name = 'PreviewImage',
                    BackgroundTransparency = 1,
                    Position = UDim2.fromOffset(17, 8),
                    Size = UDim2.fromOffset(178, 274),
                    ScaleType = Enum.ScaleType.Fit,
                    ZIndex = 31,
                }, self.Root)::ImageLabel

                if not ImageLoader.Apply(Image, self.Library.AssetCache, 'HitboxPreview') then
                    Image.Visible = false

                    self:CreateImageFallback(Theme)
                end

                self.Image = Image

                for _, Region in ipairs(Regions)do
                    local Overlay = Elements.New('TextButton', {
                        Name = Region.Id,
                        AutoButtonColor = false,
                        BackgroundColor3 = Priorities[1].Color,
                        BackgroundTransparency = 0.66,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(17 + Region.X, 8 + Region.Y),
                        Size = UDim2.fromOffset(Region.W, Region.H),
                        Text = '',
                        ZIndex = 34,
                    }, self.Root)::TextButton

                    self.Overlays[Region.Id] = Overlay

                    Overlay.MouseButton1Click:Connect(function()
                        self:Cycle(Region.Id)
                    end)
                end
                for Index, Priority in ipairs(Priorities)do
                    local Row = math.floor((Index - 1) / 2)
                    local Col = (Index - 1) % 2
                    local Dot = Elements.New('Frame', {
                        Name = Priority.Id .. 'Dot',
                        BackgroundColor3 = Priority.Color,
                        BorderSizePixel = 0,
                        Position = UDim2.fromOffset(2 + Col * 94, 304 + Row * 22),
                        Size = UDim2.fromOffset(15, 15),
                        ZIndex = 31,
                    }, self.Root)::Frame

                    Elements.Corner(Dot, 8)

                    local Label = Elements.New('TextLabel', {
                        Name = Priority.Id,
                        Position = UDim2.fromOffset(24 + Col * 94, 300 + Row * 22),
                        Size = UDim2.fromOffset(70, 20),
                        Text = Priority.Id,
                        ZIndex = 31,
                    }, self.Root)::TextLabel

                    Styling.ApplyText(Label, Theme, 12, Theme.Muted)
                    FontLoader.Apply(Label, self.Library.AssetCache)
                end

                local Help = Elements.New('TextLabel', {
                    Name = 'Help',
                    Position = UDim2.fromOffset(2, 358),
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = 'Edit hitboxes by clicking on a body part.',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Help, Theme, 11, Theme.Hint)
                FontLoader.Apply(Help, self.Library.AssetCache)
                self:Refresh()

                return self
            end
            function HitboxPreview:PriorityFor(Region: string)
                local Index = self.RegionState[Region] or 1

                return Priorities[Index]
            end
            function HitboxPreview:Cycle(Region: string)
                local Next = (self.RegionState[Region] or 1) + 1

                if Next > #Priorities then
                    Next = 1
                end

                self.RegionState[Region] = Next

                self:SetValue(self.RegionState)
            end
            function HitboxPreview:Refresh()
                for Region, Overlay in pairs(self.Overlays)do
                    local Priority = self:PriorityFor(Region)

                    Overlay.BackgroundColor3 = Priority.Color
                end
            end
            function HitboxPreview:SetValue(Value: any, RunCallback: boolean?)
                if type(Value) ~= 'table' then
                    Value = {}
                end

                self.RegionState = table.clone(Value)

                self:Commit(self.RegionState, RunCallback)
                self:Refresh()
            end

            return HitboxPreview
        end

        function __DARKLUA_BUNDLE_MODULES.K(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.K

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.K = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Countdown = {}

            Countdown.__index = Countdown

            setmetatable(Countdown, {__index = BaseWidget})

            local function Format(Seconds: number): string
                Seconds = math.max(0, math.floor(Seconds))

                local Hours = math.floor(Seconds / 3600)
                local Minutes = math.floor((Seconds % 3600) / 60)
                local Left = Seconds % 60

                return string.format('%02d:%02d:%02d', Hours, Minutes, Left)
            end

            function Countdown.New(Section: any, Options: {[string]: any})
                Options.Default = Options.Seconds or 0

                local self = BaseWidget.New(Section, Options, Options.Height or 28)

                setmetatable(self, Countdown)

                local Theme = self.Window.Theme

                self.EndsAt = os.clock() + (Options.Seconds or 0)
                self.Running = true

                local Label = Elements.New('TextLabel', {
                    Name = 'Countdown',
                    Size = UDim2.fromScale(1, 1),
                    Text = Options.Text or Format(Options.Seconds or 0),
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Label, Theme, 12, Theme.Accent)
                FontLoader.Apply(Label, self.Library.AssetCache)

                self.Label = Label

                self:BindTheme(function(NewTheme)
                    Label.TextColor3 = NewTheme.Accent
                end)
                task.spawn(function()
                    while self.Running and self.Root and self.Root.Parent do
                        self:SetValue(math.max(0, self.EndsAt - os.clock()), false)
                        task.wait(1)
                    end
                end)

                return self
            end
            function Countdown:SetValue(Value: any, RunCallback: boolean?)
                local Seconds = tonumber(Value) or 0

                self:Commit(Seconds, RunCallback)

                self.Label.Text = Format(Seconds)
            end
            function Countdown:Destroy()
                self.Running = false

                BaseWidget.Destroy(self)
            end

            return Countdown
        end

        function __DARKLUA_BUNDLE_MODULES.L(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.L

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.L = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Dropdown = __DARKLUA_BUNDLE_MODULES.E()
            local ConfigList = {}

            function ConfigList.New(Section: any, Options: {[string]: any})
                local Library = Section.Window.Library

                local function ReadValues()
                    local Values = Library:GetConfigs()

                    if #Values == 0 then
                        return {
                            'None',
                        }
                    end

                    return Values
                end

                Options.Text = Options.Text or 'Config'
                Options.Hint = Options.Hint or 'Select saved config'
                Options.Flag = Options.Flag or 'config.selected'
                Options.Values = ReadValues()
                Options.Default = Options.Default or Options.Values[1] or 'None'
                Options.GetValues = ReadValues

                local Widget = Dropdown.New(Section, Options)

                function Widget:RefreshConfigs(SelectedName: string?)
                    local Values = ReadValues()

                    self:SetValues(Values, SelectedName or self.Value)
                end

                Library:RegisterConfigList(Widget)

                return Widget
            end

            return ConfigList
        end

        function __DARKLUA_BUNDLE_MODULES.M(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.M

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.M = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local BaseWidget = __DARKLUA_BUNDLE_MODULES.B()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Label = {}

            Label.__index = Label

            setmetatable(Label, {__index = BaseWidget})

            function Label.New(Section: any, Options: {[string]: any})
                local self = BaseWidget.New(Section, Options, Options.Height or 22)

                setmetatable(self, Label)

                local Theme = self.Window.Theme
                local Text = Elements.New('TextLabel', {
                    Name = 'Text',
                    Size = UDim2.fromScale(1, 1),
                    Text = Options.Text or '',
                    ZIndex = 31,
                }, self.Root)::TextLabel

                Styling.ApplyText(Text, Theme, 11, Options.Tone == 'muted' and Theme.Muted or Theme.Text)
                FontLoader.Apply(Text, self.Library.AssetCache)

                self.Text = Text

                self:BindTheme(function(NewTheme)
                    Text.TextColor3 = Options.Tone == 'muted' and NewTheme.Muted or NewTheme.Text
                end)

                return self
            end

            return Label
        end

        function __DARKLUA_BUNDLE_MODULES.N(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.N

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.N = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local WidgetFactory = {}

            WidgetFactory.Controls = {
                Toggle = __DARKLUA_BUNDLE_MODULES.C(),
                Slider = __DARKLUA_BUNDLE_MODULES.D(),
                Dropdown = __DARKLUA_BUNDLE_MODULES.E(),
                Button = __DARKLUA_BUNDLE_MODULES.F(),
                Textbox = __DARKLUA_BUNDLE_MODULES.G(),
                Keybind = __DARKLUA_BUNDLE_MODULES.H(),
                ColorPicker = __DARKLUA_BUNDLE_MODULES.J(),
                HitboxPreview = __DARKLUA_BUNDLE_MODULES.K(),
                Countdown = __DARKLUA_BUNDLE_MODULES.L(),
                ConfigList = __DARKLUA_BUNDLE_MODULES.M(),
                Label = __DARKLUA_BUNDLE_MODULES.N(),
            }

            function WidgetFactory.Create(Kind: string, Section: any, Options: {[string]: any})
                local Control = WidgetFactory.Controls[Kind]

                assert(Control, 'Unknown Fecurity widget: ' .. tostring(Kind))

                return Control.New(Section, Options)
            end

            return WidgetFactory
        end

        function __DARKLUA_BUNDLE_MODULES.O(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.O

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.O = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local AutoLayout = __DARKLUA_BUNDLE_MODULES.A()
            local WidgetFactory = __DARKLUA_BUNDLE_MODULES.O()
            local Section = {}

            Section.__index = Section

            function Section.New(Column: any, Name: string)
                local self = setmetatable({
                    Column = Column,
                    Window = Column.Window,
                    Name = Name,
                    Order = 0,
                }, Section)
                local Root = Elements.New('Frame', {
                    Name = Name,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, -30, 0, 24),
                    LayoutOrder = #Column.Sections + 1,
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 23,
                }, Column.Scroll)::Frame

                self.Root = Root

                local Header = Elements.New('TextLabel', {
                    Name = 'Header',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = string.upper(Name),
                    ZIndex = 24,
                }, Root)::TextLabel

                Styling.ApplyText(Header, Column.Window.Theme, 11, Column.Window.Theme.Muted)
                FontLoader.Apply(Header, Column.Window.Library.AssetCache)

                self.Header = Header

                local Body = Elements.New('Frame', {
                    Name = 'Body',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.new(1, 0, 0, 0),
                    AutomaticSize = Enum.AutomaticSize.Y,
                    ZIndex = 24,
                }, Root)::Frame

                Body.Position = UDim2.fromOffset(0, 28)
                self.Body = Body

                local RootLayout = AutoLayout.Vertical(Root, 0)

                self.RootLayout = RootLayout
                self.BodyLayout = AutoLayout.Vertical(Body, 0)

                AutoLayout.ResizeToContent(Root, RootLayout, 0)

                return self
            end
            function Section:NextOrder(): number
                self.Order += 1

                return self.Order
            end
            function Section:AddDivider(Text: string)
                return WidgetFactory.Create('Label', self, {
                    Text = string.upper(Text),
                    Tone = 'muted',
                    Height = 28,
                    SkipFlag = true,
                })
            end
            function Section:AddLabel(Options: {[string]: any})
                return WidgetFactory.Create('Label', self, Options)
            end
            function Section:AddToggle(Options: {[string]: any})
                return WidgetFactory.Create('Toggle', self, Options)
            end
            function Section:AddSlider(Options: {[string]: any})
                return WidgetFactory.Create('Slider', self, Options)
            end
            function Section:AddDropdown(Options: {[string]: any})
                return WidgetFactory.Create('Dropdown', self, Options)
            end
            function Section:AddList(Options: {[string]: any})
                return self:AddDropdown(Options)
            end
            function Section:AddButton(Options: {[string]: any})
                return WidgetFactory.Create('Button', self, Options)
            end
            function Section:AddTextbox(Options: {[string]: any})
                return WidgetFactory.Create('Textbox', self, Options)
            end
            function Section:AddBox(Options: {[string]: any})
                return self:AddTextbox(Options)
            end
            function Section:AddKeybind(Options: {[string]: any})
                return WidgetFactory.Create('Keybind', self, Options)
            end
            function Section:AddBind(Options: {[string]: any})
                return self:AddKeybind(Options)
            end
            function Section:AddColor(Options: {[string]: any})
                return WidgetFactory.Create('ColorPicker', self, Options)
            end
            function Section:AddHitboxPreview(Options: {[string]: any})
                return WidgetFactory.Create('HitboxPreview', self, Options)
            end
            function Section:AddCountdown(Options: {[string]: any})
                return WidgetFactory.Create('Countdown', self, Options)
            end
            function Section:AddConfigList(Options: {[string]: any})
                return WidgetFactory.Create('ConfigList', self, Options)
            end

            return Section
        end

        function __DARKLUA_BUNDLE_MODULES.P(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.P

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.P = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local AutoLayout = __DARKLUA_BUNDLE_MODULES.A()
            local Tokens = __DARKLUA_BUNDLE_MODULES.m()
            local Section = __DARKLUA_BUNDLE_MODULES.P()
            local Column = {}

            Column.__index = Column

            function Column.New(Tab: any, Index: number)
                local Window = Tab.Window
                local self = setmetatable({
                    Tab = Tab,
                    Window = Window,
                    Index = Index,
                    Sections = {},
                }, Column)
                local Root = Elements.New('Frame', {
                    Name = 'Column' .. tostring(Index),
                    BackgroundColor3 = Window.Theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, Tokens.PanelTop),
                    Size = UDim2.fromOffset(Tokens.PanelWidth, Tokens.PanelHeight),
                    ZIndex = 21,
                }, Window.Content)::Frame

                self.Stroke = Elements.Stroke(Root, Window.Theme.Border, 0, 1)
                self.Root = Root

                local Scroll = Elements.New('ScrollingFrame', {
                    Name = 'Scroll',
                    Active = true,
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromScale(1, 1),
                    ScrollBarThickness = 4,
                    ScrollBarImageColor3 = Window.Theme.Accent,
                    CanvasSize = UDim2.fromOffset(0, 0),
                    AutomaticCanvasSize = Enum.AutomaticSize.Y,
                    ZIndex = 22,
                }, Root)::ScrollingFrame

                Elements.Padding(Scroll, 15, 16, 15, 16)

                local Layout = AutoLayout.Vertical(Scroll, 0)

                self.Scroll = Scroll
                self.Layout = Layout

                self:ApplyLayout(Index, 1)
                Window:RegisterThemeBinding(function(Theme)
                    Root.BackgroundColor3 = Theme.Surface
                    self.Stroke.Color = Theme.Border
                    Scroll.ScrollBarImageColor3 = Theme.Accent
                end)

                return self
            end
            function Column:ApplyLayout(Index: number, Count: number)
                self.Index = Index

                local TargetSize = self.Window.TargetSize or UDim2.fromOffset(Tokens.WindowSize.X, Tokens.WindowSize.Y)
                local WindowWidth = TargetSize.X.Offset > 0 and TargetSize.X.Offset or Tokens.WindowSize.X
                local WindowHeight = TargetSize.Y.Offset > 0 and TargetSize.Y.Offset or Tokens.WindowSize.Y
                local X, Width = Tokens.PanelLayout(Index, Count, WindowWidth)

                self.Root.Position = UDim2.fromOffset(X, Tokens.PanelTop)
                self.Root.Size = UDim2.fromOffset(Width, Tokens.PanelHeightFor(WindowHeight))
            end
            function Column:AddSection(Name: string)
                local NewSection = Section.New(self, Name)

                table.insert(self.Sections, NewSection)

                return NewSection
            end

            return Column
        end

        function __DARKLUA_BUNDLE_MODULES.Q(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.Q

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.Q = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Transitions = __DARKLUA_BUNDLE_MODULES.z()
            local Column = __DARKLUA_BUNDLE_MODULES.Q()
            local Tab = {}

            Tab.__index = Tab

            function Tab.New(Window: any, Name: string, Options: {[string]: any}, Index: number)
                local self = setmetatable({
                    Window = Window,
                    Name = Name,
                    Icon = Options.Icon or string.lower(Name),
                    Index = Index,
                    Columns = {},
                    Active = false,
                }, Tab)

                self.Button = Window.Sidebar:AddButton(self)

                return self
            end
            function Tab:AddColumn()
                local NewColumn = Column.New(self, #self.Columns + 1)

                table.insert(self.Columns, NewColumn)
                self:RelayoutColumns()

                NewColumn.Root.Visible = self.Active

                return NewColumn
            end
            function Tab:RelayoutColumns()
                local Count = #self.Columns

                for Index, ColumnObject in ipairs(self.Columns)do
                    ColumnObject:ApplyLayout(Index, Count)
                end
            end
            function Tab:SetActive(Value: boolean)
                self.Active = Value

                if self.Button then
                    self.Button:SetActive(Value)
                end

                for Index, ColumnObject in ipairs(self.Columns)do
                    if Value then
                        Transitions.PanelIn(ColumnObject.Root, (Index - 1) * 0.025)
                    else
                        Transitions.PanelOut(ColumnObject.Root, (Index - 1) * 0.012)
                    end
                end
            end
            function Tab:RefreshTheme()
                if self.Button then
                    self.Button:RefreshTheme()
                end
            end

            return Tab
        end

        function __DARKLUA_BUNDLE_MODULES.R(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.R

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.R = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local TabContainer = {}

            TabContainer.__index = TabContainer

            function TabContainer.New(Root: Frame)
                local self = setmetatable({}, TabContainer)

                self.Content = Elements.New('Frame', {
                    Name = 'Content',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 20,
                }, Root)::Frame
                self.Overlay = Elements.New('Frame', {
                    Name = 'Overlay',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Position = UDim2.fromOffset(0, 0),
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 200,
                }, Root)::Frame

                return self
            end

            return TabContainer
        end

        function __DARKLUA_BUNDLE_MODULES.S(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.S

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.S = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Notification = {}

            function Notification.New(Window: any, Options: {[string]: any})
                local Theme = Window.Theme
                local Root = Elements.New('Frame', {
                    Name = 'Notification',
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Size = UDim2.fromOffset(250, 62),
                    ZIndex = 401,
                }, Window.Notifications)::Frame

                Elements.Stroke(Root, Theme.Border, 0, 1)
                Elements.Padding(Root, 12, 8, 12, 8)

                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, 0, 0, 18),
                    Text = Options.Title or 'Fecurity',
                    ZIndex = 402,
                }, Root)::TextLabel

                Styling.ApplyText(Title, Theme, 12, Theme.Text)
                FontLoader.Apply(Title, Window.Library.AssetCache)

                local Body = Elements.New('TextLabel', {
                    Name = 'Body',
                    Position = UDim2.fromOffset(0, 20),
                    Size = UDim2.new(1, 0, 0, 28),
                    Text = Options.Text or Options.Message or '',
                    TextWrapped = true,
                    ZIndex = 402,
                }, Root)::TextLabel

                Styling.ApplyText(Body, Theme, 11, Theme.Hint)
                FontLoader.Apply(Body, Window.Library.AssetCache)

                Root.BackgroundTransparency = 1

                Tween.Play(Root, 0.16, {BackgroundTransparency = 0})
                task.delay(Options.Duration or 3, function()
                    if Root and Root.Parent then
                        local Created = Tween.Play(Root, 0.16, {BackgroundTransparency = 1})

                        Created.Completed:Once(function()
                            if Root and Root.Parent then
                                Root:Destroy()
                            end
                        end)
                    end
                end)

                return Root
            end

            return Notification
        end

        function __DARKLUA_BUNDLE_MODULES.T(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.T

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.T = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local Styling = __DARKLUA_BUNDLE_MODULES.s()
            local FontLoader = __DARKLUA_BUNDLE_MODULES.t()
            local Modal = {}

            function Modal.New(Window: any, Options: {[string]: any})
                local Theme = Window.Theme
                local Root = Elements.New('Frame', {
                    Name = 'Modal',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    BackgroundColor3 = Theme.Surface,
                    BorderSizePixel = 0,
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = UDim2.fromOffset(260, 130),
                    ZIndex = 300,
                }, Window.Overlay)::Frame

                Elements.Stroke(Root, Theme.Border, 0, 1)
                Elements.Padding(Root, 14, 14, 14, 14)

                local Title = Elements.New('TextLabel', {
                    Name = 'Title',
                    Size = UDim2.new(1, 0, 0, 22),
                    Text = Options.Title or 'Fecurity',
                    ZIndex = 301,
                }, Root)::TextLabel

                Styling.ApplyText(Title, Theme, 13, Theme.Text)
                FontLoader.Apply(Title, Window.Library.AssetCache)

                local Body = Elements.New('TextLabel', {
                    Name = 'Body',
                    Position = UDim2.fromOffset(0, 30),
                    Size = UDim2.new(1, 0, 0, 54),
                    Text = Options.Text or Options.Message or '',
                    TextWrapped = true,
                    ZIndex = 301,
                }, Root)::TextLabel

                Styling.ApplyText(Body, Theme, 11, Theme.Hint)
                FontLoader.Apply(Body, Window.Library.AssetCache)

                return Root
            end

            return Modal
        end

        function __DARKLUA_BUNDLE_MODULES.U(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.U

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.U = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Modal = __DARKLUA_BUNDLE_MODULES.U()
            local Warning = {}

            function Warning.New(Window: any, Options: {[string]: any})
                Options.Title = Options.Title or 'Warning'

                return Modal.New(Window, Options)
            end

            return Warning
        end

        function __DARKLUA_BUNDLE_MODULES.V(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.V

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.V = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local UserInputService = game:GetService('UserInputService')
            local Tween = __DARKLUA_BUNDLE_MODULES.j()
            local Runtime = __DARKLUA_BUNDLE_MODULES.d()
            local ThemeModule = __DARKLUA_BUNDLE_MODULES.l()
            local Tokens = __DARKLUA_BUNDLE_MODULES.m()
            local Elements = __DARKLUA_BUNDLE_MODULES.n()
            local DragController = __DARKLUA_BUNDLE_MODULES.o()
            local KeybindManager = __DARKLUA_BUNDLE_MODULES.p()
            local Sidebar = __DARKLUA_BUNDLE_MODULES.w()
            local SnowLayer = __DARKLUA_BUNDLE_MODULES.x()
            local Topbar = __DARKLUA_BUNDLE_MODULES.y()
            local Tab = __DARKLUA_BUNDLE_MODULES.R()
            local TabContainer = __DARKLUA_BUNDLE_MODULES.S()
            local Notification = __DARKLUA_BUNDLE_MODULES.T()
            local Warning = __DARKLUA_BUNDLE_MODULES.V()
            local Window = {}

            Window.__index = Window

            local function ScaleSize(Size: UDim2, Factor: number): UDim2
                return UDim2.new(Size.X.Scale * Factor, math.floor(Size.X.Offset * Factor), Size.Y.Scale * Factor, math.floor(Size.Y.Offset * Factor))
            end

            function Window.New(Library: any, Options: {[string]: any})
                local self = setmetatable({
                    Library = Library,
                    Options = Options,
                    TargetSize = Options.Size or UDim2.fromOffset(Tokens.WindowSize.X, Tokens.WindowSize.Y),
                    Theme = ThemeModule.Resolve(Options.Theme or 'Dark', Options.Accent),
                    Tabs = {},
                    ActiveTab = nil,
                    Visible = true,
                    MenuKey = KeybindManager.Normalize(Options.MenuKey or Options.ToggleKey or Enum.KeyCode.Insert),
                    Dropdown = nil,
                    ThemeBindings = {},
                }, Window)
                local Gui = Instance.new('ScreenGui')

                Gui.Name = 'Fecurity'
                Gui.IgnoreGuiInset = true
                Gui.ResetOnSpawn = false
                Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

                Runtime.AttachGui(Gui)

                self.Gui = Gui

                local Canvas = Elements.New('Frame', {
                    Name = 'Canvas',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    Size = UDim2.fromScale(1, 1),
                    ZIndex = 1,
                }, Gui)::Frame

                self.Canvas = Canvas
                self.SnowLayer = SnowLayer.New(self, Canvas)

                local Root = Elements.New('Frame', {
                    Name = 'Window',
                    AnchorPoint = Vector2.new(0.5, 0.5),
                    Position = UDim2.fromScale(0.5, 0.5),
                    Size = self.TargetSize,
                    BackgroundColor3 = self.Theme.Surface,
                    BorderSizePixel = 0,
                    ZIndex = 10,
                }, Canvas)::Frame

                self.RootStroke = Elements.Stroke(Root, self.Theme.Border, 0, 1)
                self.Root = Root
                self.Topbar = Topbar.New(self, Root, Options)
                self.TabContainer = TabContainer.New(Root)
                self.Content = self.TabContainer.Content
                self.Overlay = self.TabContainer.Overlay
                self.Notifications = Elements.New('Frame', {
                    Name = 'Notifications',
                    BackgroundTransparency = 1,
                    BorderSizePixel = 0,
                    AnchorPoint = Vector2.new(1, 0),
                    Position = UDim2.new(1, -16, 0, 16),
                    Size = UDim2.fromOffset(250, 400),
                    ZIndex = 400,
                }, Canvas)::Frame

                Elements.List(self.Notifications, Enum.FillDirection.Vertical, 8)

                self.Sidebar = Sidebar.New(self)
                self.UnbindDrag = DragController.Attach(Root, Root)
                self.InsertConnection = UserInputService.InputBegan:Connect(function(Input, Processed)
                    if Processed then
                        return
                    end
                    if KeybindManager.IsActivation(Input, self.MenuKey) then
                        self:Toggle()
                    end
                end)

                self:RegisterThemeBinding(function(Theme)
                    Root.BackgroundColor3 = Theme.Surface
                    self.RootStroke.Color = Theme.Border
                end)

                return self
            end
            function Window:AddTab(Name: string, Options: {[string]: any}?)
                local NewTab = Tab.New(self, Name, Options or {}, #self.Tabs + 1)

                table.insert(self.Tabs, NewTab)

                if not self.ActiveTab then
                    self:SetActiveTab(NewTab)
                else
                    NewTab:SetActive(false)
                end

                return NewTab
            end
            function Window:SetActiveTab(TabObject: any)
                if self.Destroyed then
                    return
                end
                if self.ActiveTab == TabObject then
                    return
                end
                if self.ActiveTab then
                    self.ActiveTab:SetActive(false)
                end

                self.ActiveTab = TabObject

                self.ActiveTab:SetActive(true)
            end
            function Window:SetAccent(Color: Color3)
                if self.Destroyed then
                    return false
                end

                self.Theme.Accent = Color

                self:RefreshTheme()

                return true
            end
            function Window:SetTheme(ThemeValue: any)
                if self.Destroyed then
                    return false
                end

                local Accent = self.Theme.Accent

                if type(ThemeValue) == 'table' and ThemeValue.Accent then
                    Accent = ThemeValue.Accent
                end

                local NextTheme = ThemeModule.Resolve(ThemeValue, Accent)

                ThemeModule.Apply(self.Theme, NextTheme)
                self:RefreshTheme()

                return true
            end
            function Window:RefreshTheme()
                if self.Destroyed then
                    return
                end
                if self.Sidebar then
                    self.Sidebar:RefreshTheme()
                end

                for _, TabObject in ipairs(self.Tabs)do
                    TabObject:RefreshTheme()
                end
                for _, Binding in ipairs(self.ThemeBindings)do
                    pcall(Binding, self.Theme)
                end
            end
            function Window:RegisterThemeBinding(Binding: (any) -> ())
                table.insert(self.ThemeBindings, Binding)
                Binding(self.Theme)

                local Active = true

                return function()
                    if not Active then
                        return
                    end

                    Active = false

                    for Index = #self.ThemeBindings, 1, -1 do
                        if self.ThemeBindings[Index] == Binding then
                            table.remove(self.ThemeBindings, Index)

                            return
                        end
                    end
                end
            end
            function Window:SetMenuKey(Value: any)
                if self.Destroyed then
                    return self
                end

                self.MenuKey = KeybindManager.Normalize(Value or Enum.KeyCode.Insert)

                return self
            end
            function Window:Open()
                if self.Destroyed or not self.Root then
                    return false
                end

                self.Visible = true

                if self.SnowLayer then
                    self.SnowLayer:SetVisible(true)
                end

                self.Root.Visible = true
                self.Root.Size = ScaleSize(self.TargetSize, 0.94)

                Tween.Play(self.Root, 0.18, {
                    Size = self.TargetSize,
                })

                return true
            end
            function Window:Close()
                if self.Destroyed or not self.Root then
                    return false
                end

                self.Visible = false

                if self.SnowLayer then
                    self.SnowLayer:SetVisible(false)
                end

                local Created = Tween.Play(self.Root, 0.18, {
                    Size = ScaleSize(self.TargetSize, 0.94),
                })

                Created.Completed:Once(function()
                    if not self.Visible and self.Root then
                        self.Root.Visible = false
                    end
                end)

                return true
            end
            function Window:Toggle()
                if self.Visible then
                    return self:Close()
                else
                    return self:Open()
                end
            end
            function Window:Notify(Options: {[string]: any})
                return Notification.New(self, Options)
            end
            function Window:AddWarning(Options: {[string]: any})
                return Warning.New(self, Options)
            end
            function Window:Destroy()
                if self.Destroyed then
                    return
                end

                self.Destroyed = true

                if self.Dropdown and self.Dropdown.CloseMenu then
                    pcall(function()
                        self.Dropdown:CloseMenu(true)
                    end)

                    self.Dropdown = nil
                end
                if self.InsertConnection then
                    self.InsertConnection:Disconnect()

                    self.InsertConnection = nil
                end
                if self.UnbindDrag then
                    pcall(self.UnbindDrag)

                    self.UnbindDrag = nil
                end
                if self.SnowLayer then
                    self.SnowLayer:Destroy()

                    self.SnowLayer = nil
                end
                if self.Gui then
                    self.Gui:Destroy()

                    self.Gui = nil
                end

                table.clear(self.ThemeBindings)
                table.clear(self.Tabs)

                self.ActiveTab = nil
                self.Sidebar = nil
                self.Root = nil
                self.Canvas = nil
                self.Content = nil
                self.Overlay = nil
                self.Notifications = nil
                self.Topbar = nil
            end

            return Window
        end

        function __DARKLUA_BUNDLE_MODULES.W(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.W

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.W = v
            end

            return v.c
        end
    end
    do
        local function __modImpl()
            local Registry = __DARKLUA_BUNDLE_MODULES.b()
            local Safety = __DARKLUA_BUNDLE_MODULES.c()
            local AssetCache = __DARKLUA_BUNDLE_MODULES.f()
            local AssetRegistry = __DARKLUA_BUNDLE_MODULES.e()
            local FlagManager = __DARKLUA_BUNDLE_MODULES.g()
            local ConfigManager = __DARKLUA_BUNDLE_MODULES.i()
            local Window = __DARKLUA_BUNDLE_MODULES.W()
            local Library = {}

            Library.__index = Library

            function Library.New()
                local self = setmetatable({
                    Version = '0.1.0',
                    Windows = {},
                    ConfigWidgets = {},
                    AssetCache = AssetCache.New(),
                    AssetRegistry = AssetRegistry,
                    FlagManager = FlagManager.New(),
                }, Library)

                self.Flags = self.FlagManager.Values
                self.ConfigManager = ConfigManager.New(self.FlagManager)

                self.AssetCache:EnsureAll()

                self.RegistryEntry = Registry.Claim(self.Version, function()
                    self:Unload()
                end)

                return self
            end
            function Library:RunCallback(Scope: string, Callback: ((...any) -> ...any)?, ...)
                Safety.Callback(Scope, Callback, ...)
            end
            function Library:CreateWindow(Options: {[string]: any})
                local NewWindow = Window.New(self, Options or {})

                table.insert(self.Windows, NewWindow)

                return NewWindow
            end
            function Library:Notify(Options: {[string]: any})
                local Target = self.Windows[1]

                if Target then
                    return Target:Notify(Options)
                end

                return nil
            end
            function Library:AddWarning(Options: {[string]: any})
                local Target = self.Windows[1]

                if Target then
                    return Target:AddWarning(Options)
                end

                return nil
            end
            function Library:SaveConfig(Name: string)
                local Saved = self.ConfigManager:Save(Name)

                if Saved then
                    self:RefreshConfigLists(Name)
                end

                return Saved
            end
            function Library:LoadConfig(Name: string, RunCallbacks: boolean?)
                local Loaded = self.ConfigManager:Load(Name, RunCallbacks)

                if Loaded then
                    self:RefreshConfigLists(Name)
                end

                return Loaded
            end
            function Library:GetConfigs()
                return self.ConfigManager:GetConfigs()
            end
            function Library:RegisterConfigList(Widget: any)
                table.insert(self.ConfigWidgets, Widget)
            end
            function Library:RefreshConfigLists(SelectedName: string?)
                for Index = #self.ConfigWidgets, 1, -1 do
                    local Widget = self.ConfigWidgets[Index]

                    if not Widget.Root or not Widget.Root.Parent then
                        table.remove(self.ConfigWidgets, Index)
                    elseif Widget.RefreshConfigs then
                        Widget:RefreshConfigs(SelectedName)
                    end
                end
            end
            function Library:SetAccent(Color: Color3)
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:SetAccent(Color)
                end
            end
            function Library:SetAssetBaseUrl(BaseUrl: string)
                self.AssetRegistry.SetBaseUrl(BaseUrl)

                return self.AssetCache:EnsureAll()
            end
            function Library:SetTheme(NameOrTheme: any)
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:SetTheme(NameOrTheme)
                end

                return true
            end
            function Library:Toggle()
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:Toggle()
                end
            end
            function Library:Open()
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:Open()
                end
            end
            function Library:Close()
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:Close()
                end
            end
            function Library:Unload()
                for _, WindowObject in ipairs(self.Windows)do
                    WindowObject:Destroy()
                end

                table.clear(self.Windows)
                table.clear(self.ConfigWidgets)
                Registry.Clear(self.RegistryEntry)
            end

            return Library
        end

        function __DARKLUA_BUNDLE_MODULES.X(): typeof(__modImpl())
            local v = __DARKLUA_BUNDLE_MODULES.cache.X

            if not v then
                v = {
                    c = __modImpl(),
                }
                __DARKLUA_BUNDLE_MODULES.cache.X = v
            end

            return v.c
        end
    end
end

local Library = __DARKLUA_BUNDLE_MODULES.X()

return Library.New()
