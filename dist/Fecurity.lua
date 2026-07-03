local a={cache={}}do do local __modImpl=function()local b={}b.Prefix='[Fecurity]'b.Verbose=false b.LogFile='Fecurity/Logs/fecurity.log'b.MaxLogBytes=24000 local Join=function(...)local c={}for d=1,
select('#',...)do table.insert(c,tostring(select(d,...)))end return table.concat(c,' ')end local EnsureLogFolder=function()if type(isfolder)~='function'or type(makefolder)~='function'then return false
end local FolderExists=function(c)local d,e=pcall(isfolder,c)return d and e==true end local EnsureFolder=function(c)if FolderExists(c)then return true end local d=pcall(makefolder,c)return d and
FolderExists(c)end if not EnsureFolder('Fecurity')then return false end if not EnsureFolder('Fecurity/Logs')then return false end return true end local Append=function(c,...)if type(writefile)~=
'function'or type(readfile)~='function'or type(isfile)~='function'then return end local d=Join(...)pcall(function()if not EnsureLogFolder()then return end local e=''if isfile(b.LogFile)then local f,g=
pcall(readfile,b.LogFile)if f and type(g)=='string'then e=g end end local f=os.date('%Y-%m-%d %H:%M:%S')local g=('%s %s %s %s\n'):format(f,b.Prefix,c,d)local h=e..g if#h>b.MaxLogBytes then h=string.
sub(h,#h-b.MaxLogBytes+1)end pcall(writefile,b.LogFile,h)end)end function b.SetVerbose(c)b.Verbose=c end function b.Info(...)Append('[Info]',...)print(b.Prefix,...)end function b.Warn(...)Append(
'[Warn]',...)warn(b.Prefix,...)end function b.Debug(...)if b.Verbose then Append('[Debug]',...)print(b.Prefix,'[Debug]',...)end end function b.Error(c,d)Append('[Error]',c,'->',tostring(d))warn(b.
Prefix,'[Error]',c,'->',tostring(d))end return b end function a.a()local b=a.cache.a if not b then b={c=__modImpl()}a.cache.a=b end return b.c end end do local __modImpl=function()local b=a.a()local c
={}local d='__FECURITY_UI__'local Environment=function()if getgenv then local e,f=pcall(getgenv)if e and type(f)=='table'then return f end end return _G end function c.Get()return Environment()[d]end
function c.Set(e)Environment()[d]=e end function c.Clear(e)local f=Environment()if e==nil or f[d]==e then f[d]=nil end end function c.Claim(e,f)local g=c.Get()if g and g.Unload then b.Info((
'Reloading previous Fecurity session %s'):format(tostring(g.Version)))pcall(function()g:Unload()end)elseif g and g.Teardown then pcall(g.Teardown)end local h={Version=e,Teardown=f}c.Set(h)return h end
return c end function a.b()local b=a.cache.b if not b then b={c=__modImpl()}a.cache.b=b end return b.c end end do local __modImpl=function()local b=a.a()local c={}function c.Try(d,e,...)local f=table.
pack(pcall(e,...))if not f[1]then b.Error(d,f[2])return false end return true,table.unpack(f,2,f.n)end function c.Callback(d,e,...)if not e then return end local f,g=pcall(e,...)if not f then b.Error(
d,g)end end return c end function a.c()local b=a.cache.c if not b then b={c=__modImpl()}a.cache.c=b end return b.c end end do local __modImpl=function()local b={}function b.GetPlayerGui()local c=game:
GetService('Players')local d=c.LocalPlayer return d:WaitForChild('PlayerGui')end function b.GetGuiParent()local c,d=pcall(function()return game:GetService('CoreGui')end)if c and d then return d end
return b.GetPlayerGui()end function b.AttachGui(c)local d=pcall(function()c.Parent=b.GetGuiParent()end)if d then return true end local e=pcall(function()c.Parent=b.GetPlayerGui()end)return e end
function b.FileApi()return{IsFolder=isfolder,MakeFolder=makefolder,IsFile=isfile,WriteFile=writefile,ReadFile=readfile,DeleteFile=delfile,ListFiles=listfiles,GetCustomAsset=getcustomasset}end function
b.HasFileApi()return type(isfolder)=='function'and type(makefolder)=='function'and type(isfile)=='function'and type(writefile)=='function'and type(readfile)=='function'and type(delfile)=='function'end
return b end function a.d()local b=a.cache.d if not b then b={c=__modImpl()}a.cache.d=b end return b.c end end do local __modImpl=function()local b={}local c=
[[https://raw.githubusercontent.com/nikgeneburn/fecurity/main/]]local NormalizeBaseUrl=function(d)if string.sub(d,-1)~='/'then return d..'/'end return d end local ReadOverrideBaseUrl=function()local d
=_G if getgenv then local e,f=pcall(getgenv)if e and type(f)=='table'then d=f end end local e=d.FecurityAssetBaseUrl if type(e)=='string'and e~=''then return NormalizeBaseUrl(e)end return
NormalizeBaseUrl(c)end b.BaseUrl=ReadOverrideBaseUrl()b.CacheRoot='Fecurity'b.Folders={'Fecurity','Fecurity/Assets','Fecurity/Assets/Fonts','Fecurity/Assets/Icons','Fecurity/Assets/Images',
'Fecurity/Configs','Fecurity/Logs'}b.Fonts={Main={Url=b.BaseUrl..'assets/fonts/ProximaNova-Semibold.ttf',File='Fecurity/Assets/Fonts/ProximaNova-Semibold.ttf',Bytes=53740,Fallback=Enum.Font.GothamBold
}}b.Icons={assist={Url=b.BaseUrl..'assets/icons/assist.png',File='Fecurity/Assets/Icons/assist.png',Bytes=1982,Fallback='A'},visuals={Url=b.BaseUrl..'assets/icons/visuals.png',File=
'Fecurity/Assets/Icons/visuals.png',Bytes=2131,Fallback='V'},misc={Url=b.BaseUrl..'assets/icons/misc.png',File='Fecurity/Assets/Icons/misc.png',Bytes=1770,Fallback='M'},colors={Url=b.BaseUrl..
'assets/icons/colors.png',File='Fecurity/Assets/Icons/colors.png',Bytes=1234,Fallback='C'},trial={Url=b.BaseUrl..'assets/icons/trial.png',File='Fecurity/Assets/Icons/trial.png',Bytes=1030,Fallback='T'
}}b.Images={Logo={Url=b.BaseUrl..'assets/images/logo.png',File='Fecurity/Assets/Images/logo.png',Bytes=1650,Fallback=nil},HitboxPreview={Url=b.BaseUrl..'assets/images/hitbox-preview.png',File=
'Fecurity/Assets/Images/hitbox-preview.png',Bytes=211220,Fallback=nil}}function b.SetBaseUrl(d)d=NormalizeBaseUrl(d)b.BaseUrl=d b.Fonts.Main.Url=d..'assets/fonts/ProximaNova-Semibold.ttf'for e,f in
pairs(b.Icons)do f.Url=d..'assets/icons/'..e..'.png'end b.Images.Logo.Url=d..'assets/images/logo.png'b.Images.HitboxPreview.Url=d..'assets/images/hitbox-preview.png'end return b end function a.e()
local b=a.cache.e if not b then b={c=__modImpl()}a.cache.e=b end return b.c end end do local __modImpl=function()local b=a.a()local c=a.d()local d=a.e()local e={}e.__index=e function e.New()return
setmetatable({Ready=false,Failed={}},e)end function e.FolderExists(f,g)if type(isfolder)~='function'then return false end local h,i=pcall(isfolder,g)return h and i==true end function e.FileExists(f,g)
if type(isfile)~='function'then return false end local h,i=pcall(isfile,g)return h and i==true end function e.EnsureFolders(f)if not c.HasFileApi()then return false end local g=true for h,i in ipairs(
d.Folders)do if not f:FolderExists(i)then local j,k=pcall(makefolder,i)if not j then g=false b.Warn('Asset cache folder failed',i,k)end end end return g end function e.Download(f,g)local h,i=pcall(
function()return game:HttpGet(g)end)if h and type(i)=='string'and#i>0 then return i end return nil end function e.IsValidBody(f,g,h)if#h<=0 then return false end if g.Bytes and#h~=g.Bytes then return
false end return true end function e.DeleteBadFile(f,g)if type(delfile)=='function'then local h,i=pcall(delfile,g)if not h then b.Warn('Asset cache delete failed',g,i)end end end function e.
EnsureAsset(f,g)if not c.HasFileApi()then return nil end if f:FileExists(g.File)then local h,i=pcall(readfile,g.File)if h and type(i)=='string'and f:IsValidBody(g,i)then f.Failed[g.File]=nil return g.
File end f:DeleteBadFile(g.File)end local h=f:Download(g.Url)if h and f:IsValidBody(g,h)then local i,j=pcall(writefile,g.File,h)if i then f.Failed[g.File]=nil return g.File end b.Warn(
'Asset cache write failed',g.File,j)end f.Failed[g.File]=true b.Warn('Asset download failed',g.Url)return nil end function e.EnsureAll(f)table.clear(f.Failed)local g=f:EnsureFolders()if not f:
EnsureAsset(d.Fonts.Main)then g=false end for h,i in pairs(d.Icons)do if not f:EnsureAsset(i)then g=false end end for h,i in pairs(d.Images)do if not f:EnsureAsset(i)then g=false end end f.Ready=g
return g end function e.GetCustomAsset(f,g)if type(getcustomasset)~='function'then return nil end if not f:FileExists(g)then return nil end local h,i=pcall(getcustomasset,g)if h then return i end
return nil end return e end function a.f()local b=a.cache.f if not b then b={c=__modImpl()}a.cache.f=b end return b.c end end do local __modImpl=function()local b=a.c()local c={}c.__index=c function c
.New()return setmetatable({Values={},Widgets={},SkipFlags={}},c)end function c.Register(d,e,f,g,h)if not e then return end if h then d.SkipFlags[e]=true else d.SkipFlags[e]=nil d.Widgets[e]=f end if d
.Values[e]==nil then d.Values[e]=g end end function c.Unregister(d,e,f)if not e then return end if f==nil or d.Widgets[e]==f then d.Widgets[e]=nil end end function c.Set(d,e,f)if not e then return end
d.Values[e]=f end function c.Get(d,e,f)local g=d.Values[e]if g==nil then return f end return g end function c.Export(d)local e={}for f,g in pairs(d.Values)do if d.SkipFlags[f]~=true then e[f]=g end
end return e end function c.Load(d,e,f)for g,h in pairs(e)do if d.SkipFlags[g]~=true then d.Values[g]=h local i=d.Widgets[g]if i and i.SetValue then b.Try('FlagManager.Load',function()i:SetValue(h,f==
true)end)end end end end return c end function a.g()local b=a.cache.g if not b then b={c=__modImpl()}a.cache.g=b end return b.c end end do local __modImpl=function()local b=game:GetService(
'HttpService')local c={}local function Pack(d,e)local f=typeof(d)if f=='Color3'then return{__FecurityType='Color3',R=d.R,G=d.G,B=d.B}end if type(d)~='table'then return d end e=e or{}if e[d]then return
nil end e[d]=true local g={}for h,i in pairs(d)do g[h]=Pack(i,e)end e[d]=nil return g end local function Unpack(d)if type(d)~='table'then return d end if d.__FecurityType=='Color3'then return Color3.
new(tonumber(d.R)or 1,tonumber(d.G)or 1,tonumber(d.B)or 1)end local e={}for f,g in pairs(d)do e[f]=Unpack(g)end return e end function c.Encode(d)return b:JSONEncode(Pack(d))end function c.Decode(d)
local e,f=pcall(function()return b:JSONDecode(d)end)if e then return Unpack(f)end return nil end return c end function a.h()local b=a.cache.h if not b then b={c=__modImpl()}a.cache.h=b end return b.c
end end do local __modImpl=function()local b=a.h()local c=a.a()local d=a.d()local e={}e.__index=e local CleanName=function(f)local g=string.gsub(tostring(f or''),'[^%w_%-%s]','')if g==''then g=
'Default'end return g end local SortedNames=function(f)local g={}for h in pairs(f)do table.insert(g,h)end table.sort(g)return g end function e.New(f)return setmetatable({Flags=f,Folder=
'Fecurity/Configs',IndexFile='Fecurity/Configs/index.json',KnownConfigs={},IndexLoaded=false},e)end function e.FolderExists(f,g)local h,i=pcall(isfolder,g)return h and i==true end function e.
FileExists(f,g)local h,i=pcall(isfile,g)return h and i==true end function e.EnsureFolders(f)if not d.HasFileApi()then return false end for g,h in ipairs({'Fecurity',f.Folder})do if not f:FolderExists(
h)then local i,j=pcall(makefolder,h)if not i then c.Warn('Config folder failed',h,j)return false end end end return true end function e.LoadIndex(f)if f.IndexLoaded or not d.HasFileApi()then return
end f.IndexLoaded=true if not f:FileExists(f.IndexFile)then return end local g,h=pcall(readfile,f.IndexFile)if not g or type(h)~='string'then c.Warn('Config index read failed',f.IndexFile,h)return end
local i=b.Decode(h)if type(i)~='table'then return end for j,k in ipairs(i)do if type(k)=='string'then f.KnownConfigs[CleanName(k)]=true end end end function e.SaveIndex(f)if not d.HasFileApi()then
return false end if not f:EnsureFolders()then return false end local g,h=pcall(writefile,f.IndexFile,b.Encode(SortedNames(f.KnownConfigs)))if not g then c.Warn('Config index write failed',f.IndexFile,
h)return false end return true end function e.Remember(f,g)local h=CleanName(g)f:LoadIndex()f.KnownConfigs[h]=true f:SaveIndex()return h end function e.Path(f,g)return f.Folder..'/'..CleanName(g)..
'.json'end function e.Save(f,g)if not d.HasFileApi()then return false end if not f:EnsureFolders()then return false end local h=CleanName(g)local i=f:Path(h)local j,k=pcall(writefile,i,b.Encode(f.
Flags:Export()))if not j then c.Warn('Config write failed',i,k)return false end f:Remember(h)return true end function e.Load(f,g,h)if not d.HasFileApi()then return false end local i=CleanName(g)local
j=f:Path(i)if not f:FileExists(j)then return false end local k,l=pcall(readfile,j)if not k or type(l)~='string'then c.Warn('Config read failed',j,l)return false end local m=b.Decode(l)if type(m)~=
'table'then return false end f.Flags:Load(m,h)f:Remember(i)return true end function e.GetConfigs(f)if not d.HasFileApi()then return{}end f:LoadIndex()if type(listfiles)=='function'and f:FolderExists(f
.Folder)then local g,h=pcall(listfiles,f.Folder)if g and type(h)=='table'then for i,j in ipairs(h)do local k=string.match(j,'([^/\\]+)%.json$')if k and k~='index'then f.KnownConfigs[CleanName(k)]=true
end end elseif not g then c.Warn('Config listing failed',f.Folder,h)end end return SortedNames(f.KnownConfigs)end return e end function a.i()local b=a.cache.i if not b then b={c=__modImpl()}a.cache.i=
b end return b.c end end do local __modImpl=function()local b=game:GetService('TweenService')local c={}function c.Play(d,e,f,g,h)local i=TweenInfo.new(e,g or Enum.EasingStyle.Quad,h or Enum.
EasingDirection.Out)local j=b:Create(d,i,f)j:Play()return j end function c.Press(d,e,f)c.Play(d,0.08,{BackgroundColor3=e})task.delay(0.1,function()if d and d.Parent then c.Play(d,0.12,{
BackgroundColor3=f})end end)end return c end function a.j()local b=a.cache.j if not b then b={c=__modImpl()}a.cache.j=b end return b.c end end do local __modImpl=function()local b={}function b.Hex(c)
local d=string.gsub(c,'#','')local e=tonumber(string.sub(d,1,2),16)or 255 local f=tonumber(string.sub(d,3,4),16)or 255 local g=tonumber(string.sub(d,5,6),16)or 255 return Color3.fromRGB(e,f,g)end
function b.Darken(c,d)return Color3.new(math.clamp(c.R*(1-d),0,1),math.clamp(c.G*(1-d),0,1),math.clamp(c.B*(1-d),0,1))end function b.Lighten(c,d)return c:Lerp(Color3.new(1,1,1),d)end function b.ToHex(
c)return string.format('#%02x%02x%02x',math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5))end function b.ParseWithAlpha(c)local d=string.gsub(c,'%s+','')local e=string.match(d,
'^#?([%da-fA-F]+)$')if e and(#e==3 or#e==6 or#e==8)then local f=nil if#e==3 then e=string.sub(e,1,1)..string.sub(e,1,1)..string.sub(e,2,2)..string.sub(e,2,2)..string.sub(e,3,3)..string.sub(e,3,3)
elseif#e==8 then f=(tonumber(string.sub(e,7,8),16)or 255)/255 end return b.Hex(string.sub(e,1,6)),f end local f=string.match(d,'^rgba?%((.+)%)$')if not f then return nil,nil end local g={}for h in
string.gmatch(f,'[%d%.]+')do table.insert(g,tonumber(h)or 0)end if#g<3 then return nil,nil end local h=g[4]if h~=nil and h>1 then h=h/255 end return Color3.fromRGB(math.clamp(math.floor(g[1]+0.5),0,
255),math.clamp(math.floor(g[2]+0.5),0,255),math.clamp(math.floor(g[3]+0.5),0,255)),h and math.clamp(h,0,1)or nil end function b.Parse(c)local d=b.ParseWithAlpha(c)return d end function b.ToRgba(c,d)
return string.format('rgba(%d, %d, %d, %.2f)',math.floor(c.R*255+0.5),math.floor(c.G*255+0.5),math.floor(c.B*255+0.5),math.clamp(d,0,1))end return b end function a.k()local b=a.cache.k if not b then b
={c=__modImpl()}a.cache.k=b end return b.c end end do local __modImpl=function()local b=a.k()local c={}c.Default={Canvas=b.Hex('#0a0a0a'),Surface=b.Hex('#111111'),Selected=b.Hex('#1b1b1b'),Border=b.
Hex('#2c2c2c'),Text=b.Hex('#ffffff'),Muted=b.Hex('#646464'),Hint=b.Hex('#575757'),Accent=b.Hex('#6a62c6'),Control=b.Hex('#212121'),ControlHover=b.Hex('#252525'),ToggleOff=b.Hex('#1d1d1d'),
ToggleKnobOff=b.Hex('#696969'),SliderTrack=b.Hex('#232323'),Success=b.Hex('#2fb636')}c.Presets={Dark=c.Default,dark=c.Default,Fecurity=c.Default,fecurity=c.Default,Midnight={Canvas=b.Hex('#050505'),
Surface=b.Hex('#101012'),Selected=b.Hex('#1a1a20'),Border=b.Hex('#303039'),Text=b.Hex('#ffffff'),Muted=b.Hex('#72727a'),Hint=b.Hex('#5a5a63'),Accent=b.Hex('#6a62c6'),Control=b.Hex('#202025'),
ControlHover=b.Hex('#282831'),ToggleOff=b.Hex('#1b1b20'),ToggleKnobOff=b.Hex('#707078'),SliderTrack=b.Hex('#25252d')}}c.Presets.midnight=c.Presets.Midnight local CopyFrom=function(d)local e={}for f,g
in pairs(c.Default)do e[f]=d[f]or g end return e end function c.Clone(d)local e=CopyFrom(c.Default)if d then e.Accent=d end return e end function c.Resolve(d,e)local f=c.Default if type(d)=='string'
then f=c.Presets[d]or c.Presets[string.lower(d)]or c.Default elseif type(d)=='table'then f=d end local g=CopyFrom(f)if e then g.Accent=e end return g end function c.Apply(d,e)for f in pairs(c.Default)
do d[f]=e[f]or c.Default[f]end end return c end function a.l()local b=a.cache.l if not b then b={c=__modImpl()}a.cache.l=b end return b.c end end do local __modImpl=function()local b={WindowSize=
Vector2.new(980,520),SidebarWidth=67,PanelTop=17,PanelHeight=485,PanelWidth=281,PanelGap=18,PanelLeft=85,PanelRight=16,PanelBottom=18,Radius=0}function b.PanelX(c)return b.PanelLeft+(c-1)*(b.
PanelWidth+b.PanelGap)end function b.PanelHeightFor(c)local d=c or b.WindowSize.Y if d==b.WindowSize.Y then return b.PanelHeight end return math.max(80,d-b.PanelTop-b.PanelBottom)end function b.
PanelLayout(c,d,e)local f=e or b.WindowSize.X if d==3 and f==b.WindowSize.X then return b.PanelX(c),b.PanelWidth end local g=math.max(1,f-b.PanelLeft-b.PanelRight)local h=b.PanelGap*math.max(d-1,0)
local i=math.max(1,g-h)local j=math.floor(i/math.max(d,1))local k=i-j*math.max(d,1)local l=j+(c==d and k or 0)local m=b.PanelLeft+(c-1)*(j+b.PanelGap)return m,l end return b end function a.m()local b=
a.cache.m if not b then b={c=__modImpl()}a.cache.m=b end return b.c end end do local __modImpl=function()local b={}function b.New(c,d,e)local f=Instance.new(c)if d then for g,h in pairs(d)do(f)[g]=h
end end f.Parent=e return f end function b.Corner(c,d)local e=Instance.new('UICorner')e.CornerRadius=UDim.new(0,d or 0)e.Parent=c return e end function b.Stroke(c,d,e,f)local g=Instance.new('UIStroke'
)g.Color=d g.Transparency=e or 0 g.Thickness=f or 1 g.ApplyStrokeMode=Enum.ApplyStrokeMode.Border g.Parent=c return g end function b.Padding(c,d,e,f,g)local h=Instance.new('UIPadding')h.PaddingLeft=
UDim.new(0,d)h.PaddingTop=UDim.new(0,e)h.PaddingRight=UDim.new(0,f)h.PaddingBottom=UDim.new(0,g)h.Parent=c return h end function b.List(c,d,e)local f=Instance.new('UIListLayout')f.FillDirection=d f.
SortOrder=Enum.SortOrder.LayoutOrder f.Padding=UDim.new(0,e or 0)f.Parent=c return f end return b end function a.n()local b=a.cache.n if not b then b={c=__modImpl()}a.cache.n=b end return b.c end end
do local __modImpl=function()local b=game:GetService('UserInputService')local c={}function c.Attach(d,e)local f=false local g=Vector2.zero local h=e.Position local i={}table.insert(i,d.InputBegan:
Connect(function(j)if j.UserInputType~=Enum.UserInputType.MouseButton1 then return end f=true g=b:GetMouseLocation()h=e.Position end))table.insert(i,b.InputEnded:Connect(function(j)if j.UserInputType
==Enum.UserInputType.MouseButton1 then f=false end end))table.insert(i,b.InputChanged:Connect(function(j)if not f or j.UserInputType~=Enum.UserInputType.MouseMovement then return end local k=b:
GetMouseLocation()-g e.Position=UDim2.new(h.X.Scale,h.X.Offset+k.X,h.Y.Scale,h.Y.Offset+k.Y)end))return function()for j,k in ipairs(i)do k:Disconnect()end end end return c end function a.o()local b=a.
cache.o if not b then b={c=__modImpl()}a.cache.o=b end return b.c end end do local __modImpl=function()local b={}function b.Display(c)if typeof(c)=='EnumItem'then return string.gsub((c).Name,'Insert',
'INS')end if typeof(c)=='Instance'then local d=c if d.UserInputType==Enum.UserInputType.MouseButton1 then return'M1'elseif d.UserInputType==Enum.UserInputType.MouseButton2 then return'M2'elseif d.
KeyCode~=Enum.KeyCode.Unknown then return b.Display(d.KeyCode)end end return tostring(c)end function b.Normalize(c)local d=b.Display(c)d=string.gsub(d,'^Enum%.KeyCode%.','')d=string.gsub(d,
'^Enum%.UserInputType%.MouseButton1$','M1')d=string.gsub(d,'^Enum%.UserInputType%.MouseButton2$','M2')d=string.gsub(d,'^MouseButton1$','M1')d=string.gsub(d,'^MouseButton2$','M2')d=string.gsub(d,
'^Insert$','INS')return d end function b.IsActivation(c,d)local e=b.Display(c)return e==b.Normalize(d)end return b end function a.p()local b=a.cache.p if not b then b={c=__modImpl()}a.cache.p=b end
return b.c end end do local __modImpl=function()local b={}function b.AccentVertical(c,d)local e=Instance.new('UIGradient')e.Rotation=90 e.Color=b.AccentSequence(d)e.Parent=c return e end function b.
AccentSequence(c)return ColorSequence.new({ColorSequenceKeypoint.new(0,c:Lerp(Color3.new(1,1,1),0.26)),ColorSequenceKeypoint.new(1,c:Lerp(Color3.new(0,0,0),0.46))})end function b.SetAccent(c,d)c.Color
=b.AccentSequence(d)end return b end function a.q()local b=a.cache.q if not b then b={c=__modImpl()}a.cache.q=b end return b.c end end do local __modImpl=function()local b=a.e()local c={}function c.
Get(d,e)local f=b.Images[e]if not f or not d then return nil end return d:GetCustomAsset(f.File)end function c.Apply(d,e,f)local g=c.Get(e,f)if g then d.Image=g return true end return false end return
c end function a.r()local b=a.cache.r if not b then b={c=__modImpl()}a.cache.r=b end return b.c end end do local __modImpl=function()local b=game:GetService('TextService')local c={}function c.
ApplyText(d,e,f,g)d.Font=Enum.Font.GothamBold d.TextSize=f or 12 d.TextColor3=g or e.Text d.TextXAlignment=Enum.TextXAlignment.Left d.TextYAlignment=Enum.TextYAlignment.Center d.BackgroundTransparency
=1 d.TextTruncate=Enum.TextTruncate.AtEnd end function c.FitText(d,e,f)local g=e or d.TextSize local h=f or 9 local Resize=function()local i=math.max(d.AbsoluteSize.X-6,4)local j=h local k=d.Font if k
==Enum.Font.Unknown then k=Enum.Font.GothamBold end for l=g,h,-1 do local m=b:GetTextSize(d.Text,l,k,Vector2.new(math.huge,math.huge))if m.X<=i then j=l break end end d.TextSize=j end task.defer(
Resize)d:GetPropertyChangedSignal('Text'):Connect(Resize)d:GetPropertyChangedSignal('AbsoluteSize'):Connect(Resize)return Resize end return c end function a.s()local b=a.cache.s if not b then b={c=
__modImpl()}a.cache.s=b end return b.c end end do local __modImpl=function()local b=a.e()local c={}function c.Apply(d,e)d.Font=b.Fonts.Main.Fallback if not e then return end local f=e:GetCustomAsset(b
.Fonts.Main.File)if not f then return end pcall(function()d.FontFace=Font.new(f,Enum.FontWeight.SemiBold,Enum.FontStyle.Normal)end)end return c end function a.t()local b=a.cache.t if not b then b={c=
__modImpl()}a.cache.t=b end return b.c end end do local __modImpl=function()local b=a.e()local c=a.s()local d={}function d.Apply(e,f,g,h)local i=b.Icons[string.lower(f)]local j=i and h and h:
GetCustomAsset(i.File)if j then local k=Instance.new('ImageLabel')k.Name='Icon'k.BackgroundTransparency=1 k.Image=j k.ImageColor3=g.Muted k.Size=UDim2.fromOffset(16,16)k.Parent=e return k end local k=
Instance.new('TextLabel')k.Name='IconFallback'k.Size=UDim2.fromOffset(16,16)k.Text=i and i.Fallback or string.sub(f,1,1)c.ApplyText(k,g,15,g.Muted)k.TextXAlignment=Enum.TextXAlignment.Center k.Parent=
e return k end return d end function a.u()local b=a.cache.u if not b then b={c=__modImpl()}a.cache.u=b end return b.c end end do local __modImpl=function()local b=a.j()local c=a.n()local d=a.s()local
e=a.t()local f=a.u()local g={}g.__index=g local h={72,139,206,274,340}function g.New(i,j,k)local l=setmetatable({Window=i,Tab=j,Active=false},g)local m=(c.New('TextButton',{Name=j.Name..'Tab',
AutoButtonColor=false,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,h[k]or(72+(k-1)*67)),Size=UDim2.fromOffset(67,64),Text='',ZIndex=25},i.Sidebar.Root))l.Root=m local n=(c.
New('Frame',{Name='Content',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,14),Size=UDim2.fromOffset(67,34),ZIndex=26},m))l.Content=n local o=f.Apply(n,j.Icon,i.Theme,i.Library
.AssetCache)local p=o p.AnchorPoint=Vector2.new(0.5,0)p.Position=UDim2.new(0.5,0,0,0)l.Icon=o local q=(c.New('TextLabel',{Name='Label',Position=UDim2.fromOffset(0,22),Size=UDim2.fromOffset(67,12),Text
=string.upper(j.Name),ZIndex=26},n))d.ApplyText(q,i.Theme,14,i.Theme.Muted)e.Apply(q,i.Library.AssetCache)q.TextXAlignment=Enum.TextXAlignment.Center l.Label=q m.MouseButton1Click:Connect(function()i:
SetActiveTab(j)end)return l end function g.SetActive(i,j)i.Active=j i:RefreshTheme()if j then local k=i.Window.Sidebar.SelectedTab k.BackgroundTransparency=0 b.Play(k,0.16,{Position=UDim2.fromOffset(0
,i.Root.Position.Y.Offset)})end end function g.RefreshTheme(i)local j=i.Window.Theme local k=i.Active and j.Accent or j.Muted if i.Icon:IsA('ImageLabel')then i.Icon.ImageColor3=k elseif i.Icon:IsA(
'TextLabel')then i.Icon.TextColor3=k end i.Label.TextColor3=k end return g end function a.v()local b=a.cache.v if not b then b={c=__modImpl()}a.cache.v=b end return b.c end end do local __modImpl=
function()local b=a.n()local c=a.q()local d=a.r()local e=a.s()local f=a.t()local g=a.m()local h={}h.__index=h function h.New(i)local j=setmetatable({Window=i,Buttons={}},h)local k=(b.New('Frame',{Name
='Sidebar',BackgroundColor3=i.Theme.Surface,BorderSizePixel=0,Position=UDim2.fromOffset(0,0),Size=UDim2.fromOffset(g.SidebarWidth,g.WindowSize.Y-2),ZIndex=22},i.Root))j.Stroke=b.Stroke(k,i.Theme.
Border,0,1)j.Root=k local l=(b.New('Frame',{Name='SelectedTab',BackgroundColor3=i.Theme.Selected,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,72),Size=UDim2.fromOffset(g.
SidebarWidth,64),ZIndex=23},k))j.SelectedTab=l local m=(b.New('ImageLabel',{Name='Logo',BackgroundTransparency=1,Position=UDim2.fromOffset(6,13),Size=UDim2.fromOffset(50,48),ImageColor3=i.Theme.Accent
,ZIndex=24},k))local n=d.Apply(m,i.Library.AssetCache,'Logo')local o=c.AccentVertical(m,i.Theme.Accent)j.Logo=m j.LogoGradient=o if not n then local p=(b.New('TextLabel',{Name='LogoFallback',
BackgroundTransparency=1,Position=UDim2.fromOffset(6,13),Size=UDim2.fromOffset(50,48),Text='F',ZIndex=25},k))e.ApplyText(p,i.Theme,28,i.Theme.Accent)f.Apply(p,i.Library.AssetCache)p.TextXAlignment=
Enum.TextXAlignment.Center j.LogoFallback=p end return j end function h.AddButton(i,j)local k=a.v().New(i.Window,j,#i.Buttons+1)table.insert(i.Buttons,k)return k end function h.RefreshTheme(i)i.Root.
BackgroundColor3=i.Window.Theme.Surface i.Stroke.Color=i.Window.Theme.Border i.SelectedTab.BackgroundColor3=i.Window.Theme.Selected i.Logo.ImageColor3=i.Window.Theme.Accent c.SetAccent(i.LogoGradient,
i.Window.Theme.Accent)if i.LogoFallback then i.LogoFallback.TextColor3=i.Window.Theme.Accent end end return h end function a.w()local b=a.cache.w if not b then b={c=__modImpl()}a.cache.w=b end return
b.c end end do local __modImpl=function()local b=game:GetService('RunService')local c=a.n()local d={}d.__index=d local e=180 local f=-8E-2 local g=1.08 function d.New(h,i)local j=setmetatable({Window=
h,Flakes={},Elapsed=0,Visible=true},d)local k=(c.New('Frame',{Name='SnowLayer',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),ZIndex=2},i))j.Root=k
for l=0,e-1 do local m=((l*53)%100)/100 local n=m^1.8 local o=(l*23+math.floor(l/3)*11)%100 local p=4+n*12+(l%5)*0.18 local q=18-n*11+(l*7%5)local r=(l*0.47)%q local s=math.round((((l*29)%120)-60)*(
0.35+n*1.25))local t=0.35+n*0.5 local u=l%2==0 and 180 or-180 local v=(c.New('Frame',{Name='Flake'..tostring(l),BackgroundColor3=Color3.new(1,1,1),BackgroundTransparency=1-t,BorderSizePixel=0,Size=
UDim2.fromOffset(p,p),ZIndex=2},k))c.Corner(v,math.ceil(p/2))table.insert(j.Flakes,{Node=v,LeftPercent=o,Duration=q,Delay=r,Drift=s,Spin=u})end j.Connection=b.RenderStepped:Connect(function(l)j:Step(l
)end)return j end function d.Step(h,i)if not h.Visible then return end local j=h.Root.AbsoluteSize if j.X<=0 or j.Y<=0 then return end h.Elapsed+=i for k,l in ipairs(h.Flakes)do local m=((h.Elapsed+l.
Delay)%l.Duration)/l.Duration local n=(l.LeftPercent/100)*j.X+m*l.Drift local o=(f+m*(g-f))*j.Y l.Node.Position=UDim2.fromOffset(n,o)l.Node.Rotation=m*l.Spin end end function d.SetVisible(h,i)h.
Visible=i h.Root.Visible=i end function d.Destroy(h)if h.Connection then h.Connection:Disconnect()end if h.Root then h.Root:Destroy()end end return d end function a.x()local b=a.cache.x if not b then
b={c=__modImpl()}a.cache.x=b end return b.c end end do local __modImpl=function()local b={}b.__index=b b.Height=0 function b.New(c,d,e)local f=setmetatable({Window=c,Root=d,Title=e.Title or'Fecurity',
Subtitle=e.Subtitle or''},b)f:Apply()return f end function b.Apply(c)c.Root:SetAttribute('FecurityTitle',c.Title)c.Root:SetAttribute('FecuritySubtitle',c.Subtitle)end function b.SetTitle(c,d,e)c.Title
=d if e~=nil then c.Subtitle=e end c:Apply()end return b end function a.y()local b=a.cache.y if not b then b={c=__modImpl()}a.cache.y=b end return b.c end end do local __modImpl=function()local b=a.j(
)local c={}function c.FadeIn(d)d.Visible=true d.BackgroundTransparency=1 b.Play(d,0.15,{BackgroundTransparency=0})end function c.FadeOut(d)local e=b.Play(d,0.15,{BackgroundTransparency=1})e.Completed:
Once(function()if d and d.Parent then d.Visible=false end end)end function c.PanelIn(d,e)local f=d.Position d.Visible=true d.Position=f+UDim2.fromOffset(0,7)d.BackgroundTransparency=1 task.delay(e or
0,function()if d and d.Parent then b.Play(d,0.16,{Position=f,BackgroundTransparency=0})end end)end function c.PanelOut(d,e)local f=d.Position task.delay(e or 0,function()if not d or not d.Parent then
return end local g=b.Play(d,0.12,{Position=f+UDim2.fromOffset(0,7),BackgroundTransparency=1},Enum.EasingStyle.Quad,Enum.EasingDirection.In)g.Completed:Once(function()if d and d.Parent then d.Visible=
false d.Position=f d.BackgroundTransparency=0 end end)end)end return c end function a.z()local b=a.cache.z if not b then b={c=__modImpl()}a.cache.z=b end return b.c end end do local __modImpl=function
()local b=a.n()local c={}function c.Vertical(d,e)local f=b.List(d,Enum.FillDirection.Vertical,e or 0)f.HorizontalAlignment=Enum.HorizontalAlignment.Left return f end function c.Horizontal(d,e)local f=
b.List(d,Enum.FillDirection.Horizontal,e or 0)f.VerticalAlignment=Enum.VerticalAlignment.Center return f end function c.ResizeToContent(d,e,f)local Update=function()d.Size=UDim2.new(d.Size.X.Scale,d.
Size.X.Offset,0,e.AbsoluteContentSize.Y+(f or 0))end e:GetPropertyChangedSignal('AbsoluteContentSize'):Connect(Update)task.defer(Update)end return c end function a.A()local b=a.cache.A if not b then b
={c=__modImpl()}a.cache.A=b end return b.c end end do local __modImpl=function()local b=a.n()local c={}c.__index=c function c.New(d,e,f)local g=setmetatable({Section=d,Window=d.Window,Library=d.Window
.Library,Options=e,Flag=e.Flag,SkipFlag=e.SkipFlag==true,Value=e.Default,Callback=e.Callback,ThemeUnbinds={}},c)g.Root=(b.New('Frame',{Name=e.Text or'Widget',BackgroundTransparency=1,BorderSizePixel=0
,Size=UDim2.new(1,0,0,f),LayoutOrder=d:NextOrder(),ZIndex=30},d.Body))if g.Flag then g.Library.FlagManager:Register(g.Flag,g,g.Value,g.SkipFlag)local h=g.Library.FlagManager:Get(g.Flag,nil)if h~=nil
then g.Value=h end end g.FlagDestroyConnection=g.Root.Destroying:Connect(function()g:UnregisterFlag()end)g.ThemeDestroyConnection=g.Root.Destroying:Connect(function()g:UnbindTheme()end)return g end
function c.UnbindTheme(d)for e,f in ipairs(d.ThemeUnbinds)do pcall(f)end table.clear(d.ThemeUnbinds)if d.ThemeDestroyConnection then d.ThemeDestroyConnection:Disconnect()d.ThemeDestroyConnection=nil
end end function c.UnregisterFlag(d)if d.Flag then d.Library.FlagManager:Unregister(d.Flag,d)end if d.FlagDestroyConnection then d.FlagDestroyConnection:Disconnect()d.FlagDestroyConnection=nil end end
function c.Commit(d,e,f)d.Value=e d.Library.FlagManager:Set(d.Flag,e)if f~=false then d.Library:RunCallback(d.Options.Text or'Widget',d.Callback,e,d.Alpha)end end function c.SetValue(d,e,f)d:Commit(e,
f)end function c.Destroy(d)d:UnregisterFlag()d:UnbindTheme()if d.Root then d.Root:Destroy()end end function c.BindTheme(d,e)if d.Window and d.Window.RegisterThemeBinding then local f=d.Window:
RegisterThemeBinding(e)if f then table.insert(d.ThemeUnbinds,f)end end end function c.AddColor(d,e)return d.Section:AddColor(e)end function c.AddBind(d,e)return d.Section:AddBind(e)end return c end
function a.B()local b=a.cache.B if not b then b={c=__modImpl()}a.cache.B=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f=a.j()local g=
{}g.__index=g setmetatable(g,{__index=b})function g.New(h,i)i.Default=i.Default==true local j=b.New(h,i,40)setmetatable(j,g)local k=j.Window.Theme local l=(c.New('TextLabel',{Name='Title',Position=
UDim2.fromOffset(0,0),Size=UDim2.new(1,-44,0,16),Text=i.Text or'Toggle',ZIndex=31},j.Root))d.ApplyText(l,k,14,k.Text)e.Apply(l,j.Library.AssetCache)j.Title=l local m=(c.New('TextLabel',{Name='Hint',
Position=UDim2.fromOffset(0,15),Size=UDim2.new(1,-44,0,14),Text=i.Hint or'',ZIndex=31},j.Root))d.ApplyText(m,k,13,k.Hint)e.Apply(m,j.Library.AssetCache)j.Hint=m local n=(c.New('Frame',{Name='Track',
AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-1,0,5),Size=UDim2.fromOffset(26,16),BackgroundColor3=k.ToggleOff,BorderSizePixel=0,ZIndex=32},j.Root))c.Corner(n,8)j.Track=n local o=(c.New('Frame',{
Name='Knob',Position=UDim2.fromOffset(2,2),Size=UDim2.fromOffset(12,12),BackgroundColor3=k.ToggleKnobOff,BorderSizePixel=0,ZIndex=33},n))c.Corner(o,6)j.Knob=o local p=(c.New('TextButton',{Name=
'Hitbox',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),Text='',ZIndex=34},j.Root))p.MouseButton1Click:Connect(function()j:SetValue(not j.Value)end)j.Hit=p j:BindTheme(function(q
)l.TextColor3=q.Text m.TextColor3=q.Hint n.BackgroundColor3=j.Value and q.ControlHover or q.ToggleOff o.BackgroundColor3=j.Value and q.Accent or q.ToggleKnobOff end)j:SetValue(j.Value,false)return j
end function g.SetValue(h,i,j)local k=i==true h:Commit(k,j)local l=h.Window.Theme f.Play(h.Track,0.12,{BackgroundColor3=k and l.ControlHover or l.ToggleOff})f.Play(h.Knob,0.12,{BackgroundColor3=k and
l.Accent or l.ToggleKnobOff,Position=k and UDim2.fromOffset(13,2)or UDim2.fromOffset(2,2)})end return g end function a.C()local b=a.cache.C if not b then b={c=__modImpl()}a.cache.C=b end return b.c
end end do local __modImpl=function()local b=game:GetService('UserInputService')local c=a.B()local d=a.n()local e=a.s()local f=a.t()local g={}g.__index=g setmetatable(g,{__index=c})local Format=
function(h,i)if h.Suffix then local j=h.Decimals and string.format('%.'..tostring(h.Decimals)..'f',i)or tostring(math.floor(i+0.5))return j..(h.SuffixSpacing==false and''or' ')..h.Suffix end if h.
Format=='percent'then return tostring(math.floor(i+0.5))..'%'elseif h.Format=='ms'then return tostring(math.floor(i+0.5))..' MS'elseif h.Format=='coefficient'then return'x'..string.format('%.2f',i)
elseif h.Format=='fixed2'then return string.format('%.2f',i)end return tostring(math.floor(i+0.5))end function g.New(h,i)i.Min=i.Min or 0 i.Max=i.Max or 100 i.Step=i.Step or 1 i.Default=i.Default or i
.Value or i.Min local j=c.New(h,i,40)setmetatable(j,g)j.Connections={}local k=j.Window.Theme local l=(d.New('TextLabel',{Name='Title',Size=UDim2.new(0.78,0,0,16),Text=i.Text or'Slider',ZIndex=31},j.
Root))e.ApplyText(l,k,14,k.Text)f.Apply(l,j.Library.AssetCache)j.Title=l local m=(d.New('TextLabel',{Name='Value',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,0,0,0),Size=UDim2.new(0.25,0,0,16),
Text='',ZIndex=31},j.Root))e.ApplyText(m,k,14,k.Text)f.Apply(m,j.Library.AssetCache)m.TextXAlignment=Enum.TextXAlignment.Right j.ValueLabel=m local n=(d.New('Frame',{Name='Track',Position=UDim2.
fromOffset(0,30),Size=UDim2.new(1,0,0,2),BackgroundColor3=k.SliderTrack,BorderSizePixel=0,ZIndex=31},j.Root))j.Track=n local o=(d.New('Frame',{Name='Fill',Size=UDim2.fromOffset(0,2),BackgroundColor3=k
.Accent,BorderSizePixel=0,ZIndex=32},n))j.Fill=o local p=(d.New('Frame',{Name='Knob',AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromOffset(0,1),Size=UDim2.fromOffset(12,12),BackgroundColor3=k.
Accent,BorderSizePixel=0,ZIndex=33},n))d.Corner(p,6)j.Knob=p local q=false local SetFromMouse=function()local r=b:GetMouseLocation().X-n.AbsolutePosition.X local s=math.clamp(r/math.max(n.AbsoluteSize
.X,1),0,1)local t=i.Min+(i.Max-i.Min)*s local u=math.floor((t/i.Step)+0.5)*i.Step j:SetValue(math.clamp(u,i.Min,i.Max))end j:TrackConnection(n.InputBegan:Connect(function(r)if r.UserInputType==Enum.
UserInputType.MouseButton1 then q=true SetFromMouse()end end))j:TrackConnection(p.InputBegan:Connect(function(r)if r.UserInputType==Enum.UserInputType.MouseButton1 then q=true end end))j:
TrackConnection(b.InputEnded:Connect(function(r)if r.UserInputType==Enum.UserInputType.MouseButton1 then q=false end end))j:TrackConnection(b.InputChanged:Connect(function(r)if q and r.UserInputType==
Enum.UserInputType.MouseMovement then SetFromMouse()end end))j.DestroyConnection=j.Root.Destroying:Connect(function()j:DisconnectInputs()end)j:BindTheme(function(r)l.TextColor3=r.Text m.TextColor3=r.
Text n.BackgroundColor3=r.SliderTrack o.BackgroundColor3=r.Accent p.BackgroundColor3=r.Accent end)j:SetValue(j.Value,false)return j end function g.TrackConnection(h,i)table.insert(h.Connections,i)
return i end function g.DisconnectInputs(h)for i,j in ipairs(h.Connections)do j:Disconnect()end table.clear(h.Connections)if h.DestroyConnection then h.DestroyConnection:Disconnect()h.
DestroyConnection=nil end end function g.SetValue(h,i,j)local k=tonumber(i)or h.Options.Min k=math.clamp(k,h.Options.Min,h.Options.Max)h:Commit(k,j)local l=(k-h.Options.Min)/math.max(h.Options.Max-h.
Options.Min,1)h.Fill.Size=UDim2.new(l,0,0,2)h.Knob.Position=UDim2.new(l,0,0,1)h.ValueLabel.Text=Format(h.Options,k)end function g.Destroy(h)h:DisconnectInputs()c.Destroy(h)end return g end function a.
D()local b=a.cache.D if not b then b={c=__modImpl()}a.cache.D=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f=a.j()local g={}g.__index
=g setmetatable(g,{__index=b})local Contains=function(h,i)for j,k in ipairs(h)do if k==i then return true end end return false end local Display=function(h)if type(h)=='table'then return#h>0 and table
.concat(h,', ')or'None'end return tostring(h or'None')end function g.New(h,i)i.Values=i.Values or i.Options or{}local j=if i.Default~=nil then i.Default else i.Value if i.Multi then i.Default=j if i.
Default==nil then i.Default={}elseif type(i.Default)~='table'then i.Default={i.Default}end else i.Default=j or i.Values[1]or'None'end if i.Multi and type(i.Default)~='table'then i.Default={i.Default}
end local k=b.New(h,i,72)setmetatable(k,g)local l=k.Window.Theme local m=(c.New('TextLabel',{Name='Title',Size=UDim2.new(1,0,0,16),Text=i.Text or'Dropdown',ZIndex=31},k.Root))d.ApplyText(m,l,14,l.Text
)e.Apply(m,k.Library.AssetCache)local n=(c.New('TextLabel',{Name='Hint',Position=UDim2.fromOffset(0,15),Size=UDim2.new(1,0,0,14),Text=i.Hint or'',ZIndex=31},k.Root))d.ApplyText(n,l,13,l.Hint)e.Apply(n
,k.Library.AssetCache)local o=(c.New('TextButton',{Name='Box',AutoButtonColor=false,BackgroundColor3=l.Control,BorderSizePixel=0,Position=UDim2.fromOffset(0,31),Size=UDim2.new(1,0,0,24),Text='',ZIndex
=32},k.Root))k.Box=o c.Stroke(o,l.Border,0.45,1)local p=(c.New('TextLabel',{Name='Value',Position=UDim2.fromOffset(16,7),Size=UDim2.new(1,-50,0,12),Text='',ZIndex=33},o))d.ApplyText(p,l,14,l.Text)e.
Apply(p,k.Library.AssetCache)d.FitText(p,14,11)k.ValueLabel=p local q=(c.New('TextLabel',{Name='Arrow',AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-18,0,10),Size=UDim2.fromOffset(8,5),Text='v',
ZIndex=33},o))d.ApplyText(q,l,10,l.Muted)e.Apply(q,k.Library.AssetCache)q.TextXAlignment=Enum.TextXAlignment.Center k.Arrow=q o.MouseButton1Click:Connect(function()k:ToggleMenu()end)o.MouseEnter:
Connect(function()f.Play(o,0.12,{BackgroundColor3=k.Window.Theme.ControlHover})end)o.MouseLeave:Connect(function()f.Play(o,0.12,{BackgroundColor3=k.Window.Theme.Control})end)k.DestroyConnection=k.Root
.Destroying:Connect(function()k:CloseMenu(true)end)k:BindTheme(function(r)m.TextColor3=r.Text n.TextColor3=r.Hint o.BackgroundColor3=r.Control p.TextColor3=r.Text q.TextColor3=r.Muted k:RefreshRows()
end)k:SetValue(k.Value,false)return k end function g.CloseMenu(h,i)local j=h.Menu if j then h.Menu=nil h.OptionRows=nil if i then j:Destroy()else local k=f.Play(j,0.12,{Size=UDim2.fromOffset(j.
AbsoluteSize.X,0),BackgroundTransparency=0.15},Enum.EasingStyle.Quad,Enum.EasingDirection.In)k.Completed:Connect(function()if j and j.Parent then j:Destroy()end end)end end if h.Window.Dropdown==h
then h.Window.Dropdown=nil end if h.Arrow and h.Arrow.Parent then if i then h.Arrow.Rotation=0 else f.Play(h.Arrow,0.12,{Rotation=0})end end end function g.ToggleMenu(h)if h.Menu then h:CloseMenu()
else h:OpenMenu()end end function g.OpenMenu(h)if h.Window.Dropdown and h.Window.Dropdown~=h then h.Window.Dropdown:CloseMenu()end if h.Options.GetValues then local i,j=pcall(h.Options.GetValues)if i
and type(j)=='table'then h.Options.Values=j end end h.Window.Dropdown=h local i=h.Window.Theme local j=h.Window.Root.AbsolutePosition local k=h.Box.AbsolutePosition local l=22 local m=math.max(l,math.
min(#h.Options.Values,7)*l)local n=(c.New('Frame',{Name='DropdownMenu',BackgroundColor3=i.Control,BackgroundTransparency=0.15,BorderSizePixel=0,ClipsDescendants=true,Position=UDim2.fromOffset(k.X-j.X,
k.Y-j.Y+h.Box.AbsoluteSize.Y+1),Size=UDim2.fromOffset(h.Box.AbsoluteSize.X,0),ZIndex=210},h.Window.Overlay))c.Stroke(n,i.Border,0,1)h.Menu=n h.OptionRows={}f.Play(n,0.14,{Size=UDim2.fromOffset(h.Box.
AbsoluteSize.X,m),BackgroundTransparency=0})f.Play(h.Arrow,0.14,{Rotation=180})local o=(c.New('ScrollingFrame',{Name='Options',Active=true,BackgroundTransparency=1,BorderSizePixel=0,CanvasSize=UDim2.
fromOffset(0,#h.Options.Values*l),ScrollBarImageColor3=i.Accent,ScrollBarThickness=#h.Options.Values>7 and 2 or 0,ScrollingDirection=Enum.ScrollingDirection.Y,Size=UDim2.fromScale(1,1),ZIndex=211},n))
for p,q in ipairs(h.Options.Values)do local r=(c.New('TextButton',{Name='Option'..tostring(p),AutoButtonColor=false,BackgroundColor3=i.Control,BackgroundTransparency=0,BorderSizePixel=0,Position=UDim2
.fromOffset(0,(p-1)*l),Size=UDim2.new(1,-2,0,l),Text='',ZIndex=211},o))local s=nil local t=nil if h.Options.Multi then s=(c.New('Frame',{Name='Indicator',BackgroundColor3=i.Accent,
BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(13,7),Size=UDim2.fromOffset(7,7),ZIndex=212},r))t=c.Stroke(s,i.Muted,0,1)end local u=(c.New('TextLabel',{Name='Label',Position=
UDim2.fromOffset(h.Options.Multi and 30 or 16,0),Size=UDim2.new(1,h.Options.Multi and-46 or-32,1,0),Text=tostring(q),ZIndex=212},r))d.ApplyText(u,i,14,i.Muted)e.Apply(u,h.Library.AssetCache)h.
OptionRows[p]={Option=q,Row=r,Label=u,Indicator=s,IndicatorStroke=t}r.MouseEnter:Connect(function()f.Play(r,0.1,{BackgroundColor3=i.ControlHover})end)r.MouseLeave:Connect(function()local v=if h.
Options.Multi then Contains(h.Value,q)else h.Value==q if not v then f.Play(r,0.12,{BackgroundColor3=h.Window.Theme.Control})end end)r.MouseButton1Click:Connect(function()f.Press(r,i.Control,i.
ControlHover)if h.Options.Multi then local v=table.clone(h.Value)if Contains(v,q)then for w=#v,1,-1 do if v[w]==q then table.remove(v,w)end end else table.insert(v,q)end h:SetValue(v)h:RefreshRows()
else h:SetValue(q)h:CloseMenu()end end)end h:RefreshRows()end function g.SetValue(h,i,j)if h.Options.Multi and type(i)~='table'then i={i}end h:Commit(i,j)h.ValueLabel.Text=Display(i)end function g.
SetValues(h,i,j)h.Options.Values=i or{}local k=j or h.Value if h.Options.Multi then local l=if type(k)=='table'then k else{k}local m={}for n,o in ipairs(l)do if Contains(h.Options.Values,o)then table.
insert(m,o)end end h:SetValue(m,false)elseif not Contains(h.Options.Values,k)then h:SetValue(h.Options.Values[1]or'None',false)else h:SetValue(k,false)end if h.Menu then local l=h.Menu h.Menu=nil h.
OptionRows=nil l:Destroy()h:OpenMenu()else h:RefreshRows()end end function g.RefreshRows(h)if not h.OptionRows then return end local i=h.Window.Theme for j,k in ipairs(h.OptionRows)do local l=if h.
Options.Multi then Contains(h.Value,k.Option)else h.Value==k.Option if k.Indicator then k.Indicator.BackgroundColor3=i.Accent k.Indicator.BackgroundTransparency=l and 0 or 1 end if k.IndicatorStroke
then k.IndicatorStroke.Color=l and i.Accent or i.Muted end k.Label.TextColor3=l and i.Accent or i.Muted k.Row.BackgroundColor3=l and i.ControlHover or i.Control end if h.Menu then h.Menu.
BackgroundColor3=i.Control end end function g.Destroy(h)h:CloseMenu(true)if h.DestroyConnection then h.DestroyConnection:Disconnect()h.DestroyConnection=nil end b.Destroy(h)end return g end function a
.E()local b=a.cache.E if not b then b={c=__modImpl()}a.cache.E=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f=a.k()local g=a.j()local
h={}h.__index=h setmetatable(h,{__index=b})function h.New(i,j)local k=b.New(i,j,j.Height or 40)setmetatable(k,h)local l=k.Window.Theme local m=l.Accent local n=(c.New('TextButton',{Name='Button',
AutoButtonColor=false,BackgroundColor3=m,BorderSizePixel=0,Position=UDim2.fromOffset(0,6),Size=UDim2.new(1,0,0,26),Text=j.Text or'BUTTON',ZIndex=31},k.Root))d.ApplyText(n,l,14,l.Text)e.Apply(n,k.
Library.AssetCache)n.TextXAlignment=Enum.TextXAlignment.Center d.FitText(n,14,12)k.Control=n k.BaseColor=m n.MouseButton1Down:Connect(function()g.Play(n,0.08,{BackgroundColor3=f.Lighten(k.BaseColor,
0.16)})end)n.MouseButton1Up:Connect(function()g.Play(n,0.12,{BackgroundColor3=k.BaseColor})end)n.MouseLeave:Connect(function()g.Play(n,0.12,{BackgroundColor3=k.BaseColor})end)n.MouseButton1Click:
Connect(function()k.Library:RunCallback(j.Text or'Button',k.Callback)end)k:BindTheme(function(o)k.BaseColor=o.Accent n.BackgroundColor3=k.BaseColor n.TextColor3=o.Text end)return k end return h end
function a.F()local b=a.cache.F if not b then b={c=__modImpl()}a.cache.F=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f={}f.__index=f
setmetatable(f,{__index=b})function f.New(g,h)h.Default=h.Default or''local i=b.New(g,h,52)setmetatable(i,f)local j=i.Window.Theme local k=(c.New('TextLabel',{Name='Title',Size=UDim2.new(1,0,0,16),
Text=h.Text or'Textbox',ZIndex=31},i.Root))d.ApplyText(k,j,14,j.Text)e.Apply(k,i.Library.AssetCache)local l=(c.New('TextBox',{Name='Box',BackgroundColor3=j.Control,BorderSizePixel=0,ClearTextOnFocus=
false,Position=UDim2.fromOffset(0,22),Size=UDim2.new(1,0,0,24),Text=tostring(i.Value),ZIndex=32},i.Root))d.ApplyText(l,j,14,j.Text)e.Apply(l,i.Library.AssetCache)l.TextXAlignment=Enum.TextXAlignment.
Left i.Box=l l.FocusLost:Connect(function()i:SetValue(l.Text)end)i:BindTheme(function(m)k.TextColor3=m.Text l.BackgroundColor3=m.Control l.TextColor3=m.Text end)return i end function f.SetValue(g,h,i)
g:Commit(tostring(h or''),i)if g.Box.Text~=g.Value then g.Box.Text=g.Value end end return f end function a.G()local b=a.cache.G if not b then b={c=__modImpl()}a.cache.G=b end return b.c end end do
local __modImpl=function()local b=game:GetService('UserInputService')local c=a.B()local d=a.n()local e=a.s()local f=a.t()local g=a.p()local h={}h.__index=h setmetatable(h,{__index=c})function h.New(i,
j)j.Default=j.Default or j.Value or'None'local k=j.Callback or j.OnPressed j.Callback=j.Changed or j.OnChanged local l=c.New(i,j,40)setmetatable(l,h)l.ActivationCallback=k local m=l.Window.Theme local
n=(d.New('TextLabel',{Name='Title',Size=UDim2.new(1,-92,0,16),Text=j.Text or'Keybind',ZIndex=31},l.Root))e.ApplyText(n,m,14,m.Text)f.Apply(n,l.Library.AssetCache)local o=(d.New('TextLabel',{Name=
'Hint',Position=UDim2.fromOffset(0,15),Size=UDim2.new(1,-92,0,14),Text=j.Hint or'',ZIndex=31},l.Root))e.ApplyText(o,m,13,m.Hint)f.Apply(o,l.Library.AssetCache)local p=(d.New('TextButton',{Name='Box',
AutoButtonColor=false,AnchorPoint=Vector2.new(1,0),BackgroundColor3=m.Control,BorderSizePixel=0,Position=UDim2.new(1,0,0,1),Size=UDim2.fromOffset(90,20),Text=tostring(l.Value),ZIndex=32},l.Root))e.
ApplyText(p,m,14,m.Text)f.Apply(p,l.Library.AssetCache)p.TextXAlignment=Enum.TextXAlignment.Center e.FitText(p,14,11)l.Box=p p.MouseButton1Click:Connect(function()l:Listen()end)l.ActivationConnection=
b.InputBegan:Connect(function(q,r)if r or l.Listening then return end if g.IsActivation(q,l.Value)then l.Library:RunCallback(j.Text or'Keybind',l.ActivationCallback,l.Value,q)end end)l.
DestroyConnection=l.Root.Destroying:Connect(function()l:DisconnectInputs()end)l:BindTheme(function(q)n.TextColor3=q.Text o.TextColor3=q.Hint p.BackgroundColor3=q.Control p.TextColor3=q.Text end)l:
SetValue(l.Value,false)return l end function h.Listen(i)if i.Listening then return end i.Listening=true i.Box.Text='...'i.Box.BackgroundColor3=i.Window.Theme.ControlHover if i.ListenConnection then i.
ListenConnection:Disconnect()end i.ListenConnection=b.InputBegan:Connect(function(j,k)if k then return end i.ListenConnection:Disconnect()i.ListenConnection=nil i.Listening=false i.Box.
BackgroundColor3=i.Window.Theme.Control i:SetValue(g.Normalize(j))end)end function h.SetValue(i,j,k)i:Commit(g.Normalize(j or'None'),k)i.Box.Text=i.Value end function h.DisconnectInputs(i)if i.
ListenConnection then i.ListenConnection:Disconnect()i.ListenConnection=nil end if i.ActivationConnection then i.ActivationConnection:Disconnect()i.ActivationConnection=nil end if i.DestroyConnection
then i.DestroyConnection:Disconnect()i.DestroyConnection=nil end end function h.Destroy(i)i:DisconnectInputs()c.Destroy(i)end return h end function a.H()local b=a.cache.H if not b then b={c=__modImpl(
)}a.cache.H=b end return b.c end end do local __modImpl=function()local b=a.k()local c={}c.Templates={'#ff0000','#5f90f6','#d8f368','#e1ae24','#3ad4bb','#fee2eb','#f25dab','#ffffff'}c.HueSequence=
ColorSequence.new({ColorSequenceKeypoint.new(0,Color3.fromRGB(255,0,0)),ColorSequenceKeypoint.new(0.17,Color3.fromRGB(255,255,0)),ColorSequenceKeypoint.new(0.33,Color3.fromRGB(0,255,0)),
ColorSequenceKeypoint.new(0.5,Color3.fromRGB(0,255,255)),ColorSequenceKeypoint.new(0.67,Color3.fromRGB(0,0,255)),ColorSequenceKeypoint.new(0.83,Color3.fromRGB(255,0,255)),ColorSequenceKeypoint.new(1,
Color3.fromRGB(255,0,0))})function c.ToColorAlpha(d)if typeof(d)=='Color3'then return d,nil end if type(d)=='table'then local e,f=c.ToColorAlpha(d.Color or d.Value)return e,tonumber(d.Alpha)or f end
if type(d)=='string'then local e,f=b.ParseWithAlpha(d)return e or b.Hex(d),f end return Color3.new(1,1,1),nil end function c.AddGradient(d,e,f,g)local h=Instance.new('UIGradient')h.Color=e if f then h
.Transparency=f end h.Rotation=g or 0 h.Parent=d return h end return c end function a.I()local b=a.cache.I if not b then b={c=__modImpl()}a.cache.I=b end return b.c end end do local __modImpl=function
()local b=game:GetService('UserInputService')local c=a.B()local d=a.n()local e=a.s()local f=a.t()local g=a.k()local h=a.I()local i={}i.__index=i setmetatable(i,{__index=c})function i.New(j,k)k.Default
=k.Default or k.Value or Color3.new(1,1,1)local l=c.New(j,k,40)setmetatable(l,i)local m=l.Window.Theme l.PopupConnections={}l.Alpha=math.clamp(tonumber(k.Alpha or k.DefaultAlpha)or 1,0,1)if l.Flag
then local n=l.Flag..'.Alpha'l.AlphaFlag=n local o=l.Library.FlagManager:Get(n,nil)if o~=nil then l.Alpha=math.clamp(tonumber(o)or l.Alpha,0,1)end l.Library.FlagManager:Register(n,{SetValue=function(p
,q,r)l:SetAlpha(q,r)end},l.Alpha,l.SkipFlag)end local n=(d.New('TextLabel',{Name='Title',Size=UDim2.new(1,-44,0,16),Text=k.Text or'Color',ZIndex=31},l.Root))e.ApplyText(n,m,14,m.Text)f.Apply(n,l.
Library.AssetCache)local o=(d.New('TextLabel',{Name='Hint',Position=UDim2.fromOffset(0,15),Size=UDim2.new(1,-44,0,14),Text=k.Hint or'',ZIndex=31},l.Root))e.ApplyText(o,m,13,m.Hint)f.Apply(o,l.Library.
AssetCache)local p=(d.New('TextButton',{Name='Swatch',AutoButtonColor=false,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-1,0,5),Size=UDim2.fromOffset(15,15),BackgroundColor3=(h.ToColorAlpha(l.
Value)),BorderSizePixel=0,Text='',ZIndex=32},l.Root))d.Corner(p,8)d.Stroke(p,m.Border,0,1)l.Swatch=p p.MouseButton1Click:Connect(function()l:TogglePicker()end)l.DestroyConnection=l.Root.Destroying:
Connect(function()l:ClosePicker()if l.AlphaFlag then l.Library.FlagManager:Unregister(l.AlphaFlag)end end)l:BindTheme(function(q)n.TextColor3=q.Text o.TextColor3=q.Hint if l.Popup then l.Popup.
BackgroundColor3=q.Surface end if l.Apply then l.Apply.BackgroundColor3=q.Accent l.Apply.TextColor3=q.Text end if l.Hex then l.Hex.BackgroundColor3=q.Control l.Hex.TextColor3=q.Text end end)l:
SetValue(l.Value,false)return l end function i.DisconnectPopup(j)for k,l in ipairs(j.PopupConnections)do l:Disconnect()end table.clear(j.PopupConnections)end function i.Track(j,k)table.insert(j.
PopupConnections,k)return k end function i.ClosePicker(j)j:DisconnectPopup()j.DragTarget=nil if j.Popup then j.Popup:Destroy()j.Popup=nil j.Apply=nil j.Hex=nil j.Preview=nil j.Square=nil j.
SquareCursor=nil j.HueCursor=nil j.AlphaBar=nil j.AlphaCursor=nil end end function i.TogglePicker(j)if j.Popup then j:ClosePicker()else j:OpenPicker()end end function i.CreateColorSquare(j,k,l)local m
=(d.New('Frame',{Name='ColorSquare',BackgroundColor3=Color3.fromHSV(j.Hue,1,1),BorderSizePixel=0,Position=UDim2.fromOffset(10,40),Size=UDim2.fromOffset(182,182),ZIndex=221},k))j.Square=m local n=(d.
New('Frame',{Name='White',BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=222},m))h.AddGradient(n,ColorSequence.new(Color3.new(1,1,1)),NumberSequence.new({
NumberSequenceKeypoint.new(0,0),NumberSequenceKeypoint.new(1,1)}))local o=(d.New('Frame',{Name='Black',BackgroundColor3=Color3.new(0,0,0),BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=223},m))h.
AddGradient(o,ColorSequence.new(Color3.new(0,0,0)),NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}),90)local p=(d.New('Frame',{Name='Cursor',BackgroundColor3=l.
Accent,BorderSizePixel=0,Size=UDim2.fromOffset(7,7),ZIndex=224},m))d.Corner(p,4)d.Stroke(p,l.Text,0.4,1)j.SquareCursor=p j:Track(m.InputBegan:Connect(function(q)if q.UserInputType==Enum.UserInputType.
MouseButton1 then j.DragTarget='square'j:UpdateFromSquare()end end))end function i.CreateHueBar(j,k,l)local m=(d.New('Frame',{Name='Hue',BackgroundColor3=Color3.new(1,1,1),BorderSizePixel=0,Position=
UDim2.fromOffset(10,232),Size=UDim2.fromOffset(182,10),ZIndex=221},k))h.AddGradient(m,h.HueSequence)j.HueBar=m local n=(d.New('Frame',{Name='HueCursor',BackgroundColor3=l.Accent,BorderSizePixel=0,Size
=UDim2.fromOffset(7,7),ZIndex=222},m))d.Corner(n,4)d.Stroke(n,l.Text,0.4,1)j.HueCursor=n j:Track(m.InputBegan:Connect(function(o)if o.UserInputType==Enum.UserInputType.MouseButton1 then j.DragTarget=
'hue'j:UpdateFromHue()end end))end function i.CreateAlphaBar(j,k,l)local m=(d.New('Frame',{Name='Alpha',BackgroundColor3=j.Value,BorderSizePixel=0,Position=UDim2.fromOffset(10,248),Size=UDim2.
fromOffset(182,10),ZIndex=221},k))h.AddGradient(m,ColorSequence.new(Color3.new(1,1,1)),NumberSequence.new({NumberSequenceKeypoint.new(0,1),NumberSequenceKeypoint.new(1,0)}))j.AlphaBar=m local n=(d.
New('Frame',{Name='AlphaCursor',BackgroundColor3=l.Accent,BorderSizePixel=0,Size=UDim2.fromOffset(7,7),ZIndex=222},m))d.Corner(n,4)d.Stroke(n,l.Text,0.4,1)j.AlphaCursor=n j:Track(m.InputBegan:Connect(
function(o)if o.UserInputType==Enum.UserInputType.MouseButton1 then j.DragTarget='alpha'j:UpdateFromAlpha()end end))end function i.CreateTemplates(j,k)local l=j.Window.Theme for m,n in ipairs(h.
Templates)do local o=(d.New('TextButton',{Name='Template'..tostring(m),AutoButtonColor=false,BackgroundColor3=g.Hex(n),BorderSizePixel=0,Position=UDim2.fromOffset(10+(m-1)*24,302),Size=UDim2.
fromOffset(16,16),Text='',ZIndex=221},k))d.Corner(o,8)d.Stroke(o,l.Text,0.8,1)j:Track(o.MouseButton1Click:Connect(function()j:SetValue(g.Hex(n))end))end end function i.OpenPicker(j)local k=j.Window.
Theme local l=j.Window.Root.AbsolutePosition local m=j.Swatch.AbsolutePosition local n=(d.New('Frame',{Name='ColorPickerPopup',BackgroundColor3=k.Surface,BorderSizePixel=0,Position=UDim2.fromOffset(m.
X-l.X-188,m.Y-l.Y+22),Size=UDim2.fromOffset(204,328),ZIndex=220},j.Window.Overlay))d.Stroke(n,k.Border,0,1)j.Popup=n j.Preview=(d.New('Frame',{Name='Preview',BackgroundColor3=j.Value,BorderSizePixel=0
,Position=UDim2.fromOffset(10,10),Size=UDim2.fromOffset(182,20),ZIndex=221},n))j:CreateColorSquare(n,k)j:CreateHueBar(n,k)j:CreateAlphaBar(n,k)local o=(d.New('TextBox',{Name='Hex',BackgroundColor3=k.
Control,BorderSizePixel=0,ClearTextOnFocus=false,Position=UDim2.fromOffset(10,268),Size=UDim2.fromOffset(112,24),Text=g.ToRgba(j.Value,j.Alpha),ZIndex=221},n))e.ApplyText(o,k,14,k.Text)f.Apply(o,j.
Library.AssetCache)local p=d.Stroke(o,k.Border,0,1)j.Hex=o j.HexStroke=p local q=(d.New('TextButton',{Name='Apply',AutoButtonColor=false,BackgroundColor3=k.Accent,BorderSizePixel=0,Position=UDim2.
fromOffset(130,268),Size=UDim2.fromOffset(62,24),Text='APPLY',ZIndex=221},n))e.ApplyText(q,k,14,k.Text)f.Apply(q,j.Library.AssetCache)q.TextXAlignment=Enum.TextXAlignment.Center j.Apply=q j:Track(q.
MouseButton1Click:Connect(function()local r,s=g.ParseWithAlpha(o.Text)p.Color=r and k.Border or g.Hex('#ff3f38')j:SetValue({Color=r or j.Value,Alpha=s})end))j:Track(o.FocusLost:Connect(function()local
r,s=g.ParseWithAlpha(o.Text)p.Color=r and k.Border or g.Hex('#ff3f38')j:SetValue({Color=r or j.Value,Alpha=s})end))j:Track(b.InputChanged:Connect(function(r)if r.UserInputType~=Enum.UserInputType.
MouseMovement then return end if j.DragTarget=='square'then j:UpdateFromSquare()elseif j.DragTarget=='hue'then j:UpdateFromHue()elseif j.DragTarget=='alpha'then j:UpdateFromAlpha()end end))j:Track(b.
InputEnded:Connect(function(r)if r.UserInputType==Enum.UserInputType.MouseButton1 then j.DragTarget=nil end end))j:CreateTemplates(n)j:UpdateVisuals()end function i.UpdateFromSquare(j)if not j.Square
then return end local k=b:GetMouseLocation()local l=j.Square.AbsolutePosition local m=j.Square.AbsoluteSize j.Saturation=math.clamp((k.X-l.X)/math.max(m.X,1),0,1)j.Brightness=1-math.clamp((k.Y-l.Y)/
math.max(m.Y,1),0,1)j:SetValue(Color3.fromHSV(j.Hue,j.Saturation,j.Brightness))end function i.UpdateFromHue(j)if not j.HueBar then return end local k=b:GetMouseLocation()local l=j.HueBar.
AbsolutePosition local m=j.HueBar.AbsoluteSize j.Hue=math.clamp((k.X-l.X)/math.max(m.X,1),0,1)j:SetValue(Color3.fromHSV(j.Hue,j.Saturation,j.Brightness))end function i.UpdateFromAlpha(j)if not j.
AlphaBar then return end local k=b:GetMouseLocation()local l=j.AlphaBar.AbsolutePosition local m=j.AlphaBar.AbsoluteSize j:SetAlpha((k.X-l.X)/math.max(m.X,1))end function i.SetAlpha(j,k,l)j.Alpha=math
.clamp(tonumber(k)or j.Alpha or 1,0,1)if j.Flag then j.Library.FlagManager:Set(j.Flag..'.Alpha',j.Alpha)end if l~=false then j.Library:RunCallback(j.Options.Text or'Color',j.Callback,j.Value,j.Alpha)
end j:UpdateVisuals()end function i.UpdateVisuals(j)local k=j.Value j.Swatch.BackgroundColor3=k j.Swatch.BackgroundTransparency=1-j.Alpha if j.Preview then j.Preview.BackgroundColor3=k j.Preview.
BackgroundTransparency=1-j.Alpha end if j.Square then j.Square.BackgroundColor3=Color3.fromHSV(j.Hue,1,1)end if j.SquareCursor then j.SquareCursor.Position=UDim2.new(j.Saturation,-4,1-j.Brightness,-4)
end if j.HueCursor then j.HueCursor.Position=UDim2.new(j.Hue,-3,0,1)end if j.AlphaBar then j.AlphaBar.BackgroundColor3=k end if j.AlphaCursor then j.AlphaCursor.Position=UDim2.new(j.Alpha,-3,0,1)end
if j.Hex then j.Hex.Text=j.Alpha<0.999 and g.ToRgba(k,j.Alpha)or g.ToHex(k)end end function i.SetValue(j,k,l)local m,n=h.ToColorAlpha(k)if n~=nil then j.Alpha=math.clamp(n,0,1)end if j.Flag then j.
Library.FlagManager:Set(j.Flag..'.Alpha',j.Alpha)end j.Hue,j.Saturation,j.Brightness=Color3.toHSV(m)j:Commit(m,l)j:UpdateVisuals()end function i.Destroy(j)j:ClosePicker()if j.AlphaFlag then j.Library.
FlagManager:Unregister(j.AlphaFlag)end if j.DestroyConnection then j.DestroyConnection:Disconnect()j.DestroyConnection=nil end c.Destroy(j)end return i end function a.J()local b=a.cache.J if not b
then b={c=__modImpl()}a.cache.J=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f=a.r()local g=a.j()local h={}h.__index=h setmetatable(h
,{__index=b})local i={{Id='First',Color=Color3.fromRGB(72,25,20),Stroke=Color3.fromRGB(131,53,68)},{Id='Second',Color=Color3.fromRGB(75,54,27),Stroke=Color3.fromRGB(162,148,112)},{Id='Third',Color=
Color3.fromRGB(35,61,23),Stroke=Color3.fromRGB(101,149,94)},{Id='Fourth',Color=Color3.fromRGB(12,62,90),Stroke=Color3.fromRGB(50,115,145)},{Id='Ignore',Color=Color3.fromRGB(29,30,36),Stroke=Color3.
fromRGB(69,71,77)}}local j={{Id='Head',X=73,Y=12,W=34,H=48},{Id='Body',X=52,Y=60,W=78,H=116},{Id='LeftArm',X=18,Y=72,W=42,H=118},{Id='RightArm',X=122,Y=72,W=42,H=118},{Id='LeftLeg',X=54,Y=170,W=38,H=
110},{Id='RightLeg',X=91,Y=170,W=38,H=110}}local k={{Name='Head',X=75,Y=14,W=30,H=38,Round=18},{Name='Neck',X=82,Y=52,W=16,H=16,Round=4},{Name='Torso',X=56,Y=66,W=68,H=104,Round=4},{Name='LeftArm',X=
24,Y=78,W=24,H=108,Round=4},{Name='RightArm',X=132,Y=78,W=24,H=108,Round=4},{Name='LeftLeg',X=58,Y=170,W=28,H=108,Round=4},{Name='RightLeg',X=94,Y=170,W=28,H=108,Round=4}}function h.
CreateImageFallback(l,m)local n=(c.New('Frame',{Name='PreviewFallback',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(17,8),Size=UDim2.fromOffset(178,274),ZIndex=30},l.Root))l.
FallbackParts={}for o,p in ipairs(k)do local q=(c.New('Frame',{Name=p.Name,BackgroundColor3=m.Muted,BackgroundTransparency=0.52,BorderSizePixel=0,Position=UDim2.fromOffset(p.X,p.Y),Size=UDim2.
fromOffset(p.W,p.H),ZIndex=30},n))c.Corner(q,p.Round)table.insert(l.FallbackParts,q)end l:BindTheme(function(o)for p,q in ipairs(l.FallbackParts)do q.BackgroundColor3=o.Muted end end)end function h.
New(l,m)m.Default=m.Default or{}local n=b.New(l,m,390)setmetatable(n,h)local o=n.Window.Theme n.RegionState=table.clone(n.Value)n.Overlays={}local p=(c.New('ImageLabel',{Name='PreviewImage',
BackgroundTransparency=1,Position=UDim2.fromOffset(17,8),Size=UDim2.fromOffset(178,274),ScaleType=Enum.ScaleType.Fit,ZIndex=31},n.Root))if not f.Apply(p,n.Library.AssetCache,'HitboxPreview')then p.
Visible=false n:CreateImageFallback(o)end n.Image=p for q,r in ipairs(j)do local s=(c.New('TextButton',{Name=r.Id,AutoButtonColor=false,BackgroundColor3=o.Accent,BackgroundTransparency=1,
BorderSizePixel=0,Position=UDim2.fromOffset(17+r.X,8+r.Y),Size=UDim2.fromOffset(r.W,r.H),Text='',ZIndex=34},n.Root))n.Overlays[r.Id]=s s.MouseButton1Click:Connect(function()n:Cycle(r.Id)end)s.
MouseEnter:Connect(function()local t=n:PriorityFor(r.Id)if t then g.Play(s,0.12,{BackgroundColor3=t.Color,BackgroundTransparency=0.32})else g.Play(s,0.12,{BackgroundColor3=n.Window.Theme.Accent,
BackgroundTransparency=0.84})end end)s.MouseLeave:Connect(function()n:Refresh()end)end for q,r in ipairs(i)do local s=math.floor((q-1)/2)local t=(q-1)%2 local u=(c.New('Frame',{Name=r.Id..'Dot',
BackgroundColor3=r.Color,BorderSizePixel=0,Position=UDim2.fromOffset(2+t*94,304+s*22),Size=UDim2.fromOffset(10,10),ZIndex=31},n.Root))c.Corner(u,5)c.Stroke(u,r.Stroke,0,1)local v=(c.New('TextLabel',{
Name=r.Id,Position=UDim2.fromOffset(19+t*94,300+s*22),Size=UDim2.fromOffset(70,20),Text=r.Id,ZIndex=31},n.Root))d.ApplyText(v,o,14,o.Muted)e.Apply(v,n.Library.AssetCache)end local q=(c.New('TextLabel'
,{Name='Help',Position=UDim2.fromOffset(2,358),Size=UDim2.new(1,0,0,18),Text='Edit hitboxes by clicking on a body part.',ZIndex=31},n.Root))d.ApplyText(q,o,15,o.Hint)e.Apply(q,n.Library.AssetCache)n:
Refresh()return n end function h.PriorityFor(l,m)local n=l.RegionState[m]if not n then return nil end return i[n]end function h.Cycle(l,m)local n=(l.RegionState[m]or 0)+1 if n>#i then n=nil end l.
RegionState[m]=n l:SetValue(l.RegionState)end function h.Refresh(l)for m,n in pairs(l.Overlays)do local o=l:PriorityFor(m)if o then n.BackgroundColor3=o.Color n.BackgroundTransparency=0.46 else n.
BackgroundTransparency=1 end end end function h.SetValue(l,m,n)if type(m)~='table'then m={}end l.RegionState=table.clone(m)l:Commit(l.RegionState,n)l:Refresh()end return h end function a.K()local b=a.
cache.K if not b then b={c=__modImpl()}a.cache.K=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f={}f.__index=f setmetatable(f,{__index
=b})local Format=function(g)g=math.max(0,math.floor(g))local h=math.floor(g/86400)local i=math.floor((g%86400)/3600)local j=math.floor((g%3600)/60)local k=g%60 return string.format(
'%d DAYS %d HOURS %d MINS %d SECS',h,i,j,k)end local ToneColor=function(g,h)if h=='muted'then return g.Muted elseif h=='success'then return g.Success end return g.Text end function f.New(g,h)h.Default
=h.Seconds or 0 local i=b.New(g,h,h.Height or 28)setmetatable(i,f)local j=i.Window.Theme i.EndsAt=os.clock()+(h.Seconds or 0)i.Running=true local k=(c.New('TextLabel',{Name='Countdown',Size=UDim2.
fromScale(1,1),Text=h.Text or Format(h.Seconds or 0),ZIndex=31},i.Root))d.ApplyText(k,j,14,ToneColor(j,h.Tone))e.Apply(k,i.Library.AssetCache)i.Label=k i:BindTheme(function(l)k.TextColor3=ToneColor(l,
h.Tone)end)task.spawn(function()while i.Running and i.Root and i.Root.Parent do i:SetValue(math.max(0,i.EndsAt-os.clock()),false)task.wait(1)end end)return i end function f.SetValue(g,h,i)local j=
tonumber(h)or 0 g:Commit(j,i)g.Label.Text=Format(j)end function f.Destroy(g)g.Running=false b.Destroy(g)end return f end function a.L()local b=a.cache.L if not b then b={c=__modImpl()}a.cache.L=b end
return b.c end end do local __modImpl=function()local b=a.E()local c={}function c.New(d,e)local f=d.Window.Library local ReadValues=function()local g=f:GetConfigs()if#g==0 then return{'None'}end
return g end e.Text=e.Text or'Config'e.Hint=e.Hint or'Select saved config'e.Flag=e.Flag or'config.selected'e.Values=ReadValues()e.Default=e.Default or e.Values[1]or'None'e.GetValues=ReadValues local g
=b.New(d,e)function g.RefreshConfigs(h,i)local j=ReadValues()h:SetValues(j,i or h.Value)end f:RegisterConfigList(g)return g end return c end function a.M()local b=a.cache.M if not b then b={c=
__modImpl()}a.cache.M=b end return b.c end end do local __modImpl=function()local b=a.B()local c=a.n()local d=a.s()local e=a.t()local f={}f.__index=f setmetatable(f,{__index=b})local ToneColor=
function(g,h)if h=='muted'then return g.Muted elseif h=='success'then return g.Success end return g.Text end function f.New(g,h)local i=b.New(g,h,h.Height or 28)setmetatable(i,f)local j=i.Window.Theme
local k=(c.New('TextLabel',{Name='Text',Size=UDim2.fromScale(1,1),Text=h.Text or'',ZIndex=31},i.Root))d.ApplyText(k,j,14,ToneColor(j,h.Tone))e.Apply(k,i.Library.AssetCache)i.Text=k i:BindTheme(
function(l)k.TextColor3=ToneColor(l,h.Tone)end)return i end return f end function a.N()local b=a.cache.N if not b then b={c=__modImpl()}a.cache.N=b end return b.c end end do local __modImpl=function()
local b={}b.Controls={Toggle=a.C(),Slider=a.D(),Dropdown=a.E(),Button=a.F(),Textbox=a.G(),Keybind=a.H(),ColorPicker=a.J(),HitboxPreview=a.K(),Countdown=a.L(),ConfigList=a.M(),Label=a.N()}function b.
Create(c,d,e)local f=b.Controls[c]assert(f,'Unknown Fecurity widget: '..tostring(c))return f.New(d,e)end return b end function a.O()local b=a.cache.O if not b then b={c=__modImpl()}a.cache.O=b end
return b.c end end do local __modImpl=function()local b=a.n()local c=a.s()local d=a.t()local e=a.A()local f=a.O()local g={}g.__index=g function g.New(h,i,j)j=j or{}local k=j.NoHeader==true local l=k
and 0 or 28 local m=setmetatable({Column=h,Window=h.Window,Name=i,Order=0},g)local n=(b.New('Frame',{Name=i,BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,-30,0,24),LayoutOrder=#h.
Sections+1,AutomaticSize=Enum.AutomaticSize.Y,ZIndex=23},h.Scroll))m.Root=n if not k then local o=(b.New('TextLabel',{Name='Header',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.new(1,0,0,l),
Text=string.upper(i),ZIndex=24},n))c.ApplyText(o,h.Window.Theme,14,h.Window.Theme.Muted)d.Apply(o,h.Window.Library.AssetCache)m.Header=o end local o=(b.New('Frame',{Name='Body',BackgroundTransparency=
1,BorderSizePixel=0,Size=UDim2.new(1,0,0,0),AutomaticSize=Enum.AutomaticSize.Y,ZIndex=24},n))o.Position=UDim2.fromOffset(0,l)m.Body=o local p=e.Vertical(n,0)m.RootLayout=p m.BodyLayout=e.Vertical(o,0)
e.ResizeToContent(n,p,0)return m end function g.NextOrder(h)h.Order+=1 return h.Order end function g.AddDivider(h,i)return f.Create('Label',h,{Text=string.upper(i),Tone='muted',Height=28,SkipFlag=true
})end function g.AddLabel(h,i)return f.Create('Label',h,i)end function g.AddToggle(h,i)return f.Create('Toggle',h,i)end function g.AddSlider(h,i)return f.Create('Slider',h,i)end function g.AddDropdown
(h,i)return f.Create('Dropdown',h,i)end function g.AddList(h,i)return h:AddDropdown(i)end function g.AddButton(h,i)return f.Create('Button',h,i)end function g.AddTextbox(h,i)return f.Create('Textbox',
h,i)end function g.AddBox(h,i)return h:AddTextbox(i)end function g.AddKeybind(h,i)return f.Create('Keybind',h,i)end function g.AddBind(h,i)return h:AddKeybind(i)end function g.AddColor(h,i)return f.
Create('ColorPicker',h,i)end function g.AddHitboxPreview(h,i)return f.Create('HitboxPreview',h,i)end function g.AddCountdown(h,i)return f.Create('Countdown',h,i)end function g.AddConfigList(h,i)return
f.Create('ConfigList',h,i)end return g end function a.P()local b=a.cache.P if not b then b={c=__modImpl()}a.cache.P=b end return b.c end end do local __modImpl=function()local b=a.n()local c=a.A()
local d=a.m()local e=a.P()local f={}f.__index=f function f.New(g,h)local i=g.Window local j=setmetatable({Tab=g,Window=i,Index=h,Sections={}},f)local k=(b.New('Frame',{Name='Column'..tostring(h),
BackgroundColor3=i.Theme.Surface,BorderSizePixel=0,Position=UDim2.fromOffset(0,d.PanelTop),Size=UDim2.fromOffset(d.PanelWidth,d.PanelHeight),ZIndex=21},i.Content))j.Stroke=b.Stroke(k,i.Theme.Border,0,
1)j.Root=k local l=(b.New('ScrollingFrame',{Name='Scroll',Active=true,BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),ScrollBarThickness=4,
ScrollBarImageColor3=i.Theme.Accent,CanvasSize=UDim2.fromOffset(0,0),AutomaticCanvasSize=Enum.AutomaticSize.Y,ZIndex=22},k))b.Padding(l,15,16,15,16)local m=c.Vertical(l,0)j.Scroll=l j.Layout=m j:
ApplyLayout(h,1)i:RegisterThemeBinding(function(n)k.BackgroundColor3=n.Surface j.Stroke.Color=n.Border l.ScrollBarImageColor3=n.Accent end)return j end function f.ApplyLayout(g,h,i)g.Index=h local j=g
.Window.TargetSize or UDim2.fromOffset(d.WindowSize.X,d.WindowSize.Y)local k=j.X.Offset>0 and j.X.Offset or d.WindowSize.X local l=j.Y.Offset>0 and j.Y.Offset or d.WindowSize.Y local m,n=d.
PanelLayout(h,i,k)g.Root.Position=UDim2.fromOffset(m,d.PanelTop)g.Root.Size=UDim2.fromOffset(n,d.PanelHeightFor(l))end function f.AddSection(g,h,i)local j=e.New(g,h,i)table.insert(g.Sections,j)return
j end return f end function a.Q()local b=a.cache.Q if not b then b={c=__modImpl()}a.cache.Q=b end return b.c end end do local __modImpl=function()local b=a.z()local c=a.Q()local d={}d.__index=d
function d.New(e,f,g,h)local i=setmetatable({Window=e,Name=f,Icon=g.Icon or string.lower(f),Index=h,Columns={},Active=false},d)i.Button=e.Sidebar:AddButton(i)return i end function d.AddColumn(e)local
f=c.New(e,#e.Columns+1)table.insert(e.Columns,f)e:RelayoutColumns()f.Root.Visible=e.Active return f end function d.RelayoutColumns(e)local f=#e.Columns for g,h in ipairs(e.Columns)do h:ApplyLayout(g,f
)end end function d.SetActive(e,f)e.Active=f if e.Button then e.Button:SetActive(f)end for g,h in ipairs(e.Columns)do if f then b.PanelIn(h.Root,(g-1)*0.025)else b.PanelOut(h.Root,(g-1)*0.012)end end
end function d.RefreshTheme(e)if e.Button then e.Button:RefreshTheme()end end return d end function a.R()local b=a.cache.R if not b then b={c=__modImpl()}a.cache.R=b end return b.c end end do local
__modImpl=function()local b=a.n()local c={}c.__index=c function c.New(d)local e=setmetatable({},c)e.Content=(b.New('Frame',{Name='Content',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.
fromOffset(0,0),Size=UDim2.fromScale(1,1),ZIndex=20},d))e.Overlay=(b.New('Frame',{Name='Overlay',BackgroundTransparency=1,BorderSizePixel=0,Position=UDim2.fromOffset(0,0),Size=UDim2.fromScale(1,1),
ZIndex=200},d))return e end return c end function a.S()local b=a.cache.S if not b then b={c=__modImpl()}a.cache.S=b end return b.c end end do local __modImpl=function()local b=a.n()local c=a.s()local
d=a.t()local e=a.j()local f={}function f.New(g,h)local i=g.Theme local j=(b.New('Frame',{Name='Notification',BackgroundColor3=i.Surface,BorderSizePixel=0,Size=UDim2.fromOffset(250,62),ZIndex=401},g.
Notifications))b.Stroke(j,i.Border,0,1)b.Padding(j,12,8,12,8)local k=(b.New('TextLabel',{Name='Title',Size=UDim2.new(1,0,0,18),Text=h.Title or'Fecurity',ZIndex=402},j))c.ApplyText(k,i,16,i.Text)d.
Apply(k,g.Library.AssetCache)local l=(b.New('TextLabel',{Name='Body',Position=UDim2.fromOffset(0,20),Size=UDim2.new(1,0,0,28),Text=h.Text or h.Message or'',TextWrapped=true,ZIndex=402},j))c.ApplyText(
l,i,15,i.Hint)d.Apply(l,g.Library.AssetCache)j.BackgroundTransparency=1 e.Play(j,0.16,{BackgroundTransparency=0})task.delay(h.Duration or 3,function()if j and j.Parent then local m=e.Play(j,0.16,{
BackgroundTransparency=1})m.Completed:Once(function()if j and j.Parent then j:Destroy()end end)end end)return j end return f end function a.T()local b=a.cache.T if not b then b={c=__modImpl()}a.cache.
T=b end return b.c end end do local __modImpl=function()local b=a.n()local c=a.s()local d=a.t()local e={}function e.New(f,g)local h=f.Theme local i=(b.New('Frame',{Name='Modal',AnchorPoint=Vector2.
new(0.5,0.5),BackgroundColor3=h.Surface,BorderSizePixel=0,Position=UDim2.fromScale(0.5,0.5),Size=UDim2.fromOffset(260,130),ZIndex=300},f.Overlay))b.Stroke(i,h.Border,0,1)b.Padding(i,14,14,14,14)local
j=(b.New('TextLabel',{Name='Title',Size=UDim2.new(1,0,0,22),Text=g.Title or'Fecurity',ZIndex=301},i))c.ApplyText(j,h,17,h.Text)d.Apply(j,f.Library.AssetCache)local k=(b.New('TextLabel',{Name='Body',
Position=UDim2.fromOffset(0,30),Size=UDim2.new(1,0,0,54),Text=g.Text or g.Message or'',TextWrapped=true,ZIndex=301},i))c.ApplyText(k,h,15,h.Hint)d.Apply(k,f.Library.AssetCache)return i end return e
end function a.U()local b=a.cache.U if not b then b={c=__modImpl()}a.cache.U=b end return b.c end end do local __modImpl=function()local b=a.U()local c={}function c.New(d,e)e.Title=e.Title or'Warning'
return b.New(d,e)end return c end function a.V()local b=a.cache.V if not b then b={c=__modImpl()}a.cache.V=b end return b.c end end do local __modImpl=function()local b=game:GetService(
'UserInputService')local c=a.j()local d=a.d()local e=a.l()local f=a.m()local g=a.n()local h=a.o()local i=a.p()local j=a.w()local k=a.x()local l=a.y()local m=a.R()local n=a.S()local o=a.T()local p=a.V(
)local q={}q.__index=q local ScaleSize=function(r,s)return UDim2.new(r.X.Scale*s,math.floor(r.X.Offset*s),r.Y.Scale*s,math.floor(r.Y.Offset*s))end function q.New(r,s)local t=setmetatable({Library=r,
Options=s,TargetSize=s.Size or UDim2.fromOffset(f.WindowSize.X,f.WindowSize.Y),Theme=e.Resolve(s.Theme or'Dark',s.Accent),Tabs={},ActiveTab=nil,Visible=true,MenuKey=i.Normalize(s.MenuKey or s.
ToggleKey or Enum.KeyCode.Insert),Dropdown=nil,ThemeBindings={}},q)local u=Instance.new('ScreenGui')u.Name='Fecurity'u.IgnoreGuiInset=true u.ResetOnSpawn=false u.ZIndexBehavior=Enum.ZIndexBehavior.
Sibling d.AttachGui(u)t.Gui=u local v=(g.New('Frame',{Name='Canvas',BackgroundTransparency=1,BorderSizePixel=0,Size=UDim2.fromScale(1,1),ZIndex=1},u))t.Canvas=v t.SnowLayer=k.New(t,v)local w=(g.New(
'Frame',{Name='Window',AnchorPoint=Vector2.new(0.5,0.5),Position=UDim2.fromScale(0.5,0.5),Size=t.TargetSize,BackgroundColor3=t.Theme.Surface,BorderSizePixel=0,ZIndex=10},v))t.RootStroke=g.Stroke(w,t.
Theme.Border,0,1)t.Root=w t.Topbar=l.New(t,w,s)t.TabContainer=n.New(w)t.Content=t.TabContainer.Content t.Overlay=t.TabContainer.Overlay t.Notifications=(g.New('Frame',{Name='Notifications',
BackgroundTransparency=1,BorderSizePixel=0,AnchorPoint=Vector2.new(1,0),Position=UDim2.new(1,-16,0,16),Size=UDim2.fromOffset(250,400),ZIndex=400},v))g.List(t.Notifications,Enum.FillDirection.Vertical,
8)t.Sidebar=j.New(t)t.UnbindDrag=h.Attach(w,w)t.InsertConnection=b.InputBegan:Connect(function(x,y)if y then return end if i.IsActivation(x,t.MenuKey)then t:Toggle()end end)t:RegisterThemeBinding(
function(x)w.BackgroundColor3=x.Surface t.RootStroke.Color=x.Border end)return t end function q.AddTab(r,s,t)local u=m.New(r,s,t or{},#r.Tabs+1)table.insert(r.Tabs,u)if not r.ActiveTab then r:
SetActiveTab(u)else u:SetActive(false)end return u end function q.SetActiveTab(r,s)if r.Destroyed then return end if r.ActiveTab==s then return end if r.ActiveTab then r.ActiveTab:SetActive(false)end
r.ActiveTab=s r.ActiveTab:SetActive(true)end function q.SetAccent(r,s)if r.Destroyed then return false end r.Theme.Accent=s r:RefreshTheme()return true end function q.SetTheme(r,s)if r.Destroyed then
return false end local t=r.Theme.Accent if type(s)=='table'and s.Accent then t=s.Accent end local u=e.Resolve(s,t)e.Apply(r.Theme,u)r:RefreshTheme()return true end function q.RefreshTheme(r)if r.
Destroyed then return end if r.Sidebar then r.Sidebar:RefreshTheme()end for s,t in ipairs(r.Tabs)do t:RefreshTheme()end for s,t in ipairs(r.ThemeBindings)do pcall(t,r.Theme)end end function q.
RegisterThemeBinding(r,s)table.insert(r.ThemeBindings,s)s(r.Theme)local t=true return function()if not t then return end t=false for u=#r.ThemeBindings,1,-1 do if r.ThemeBindings[u]==s then table.
remove(r.ThemeBindings,u)return end end end end function q.SetMenuKey(r,s)if r.Destroyed then return r end r.MenuKey=i.Normalize(s or Enum.KeyCode.Insert)return r end function q.Open(r)if r.Destroyed
or not r.Root then return false end r.Visible=true if r.SnowLayer then r.SnowLayer:SetVisible(true)end r.Root.Visible=true r.Root.Size=ScaleSize(r.TargetSize,0.94)c.Play(r.Root,0.18,{Size=r.TargetSize
})return true end function q.Close(r)if r.Destroyed or not r.Root then return false end r.Visible=false if r.SnowLayer then r.SnowLayer:SetVisible(false)end local s=c.Play(r.Root,0.18,{Size=ScaleSize(
r.TargetSize,0.94)})s.Completed:Once(function()if not r.Visible and r.Root then r.Root.Visible=false end end)return true end function q.Toggle(r)if r.Visible then return r:Close()else return r:Open()
end end function q.Notify(r,s)return o.New(r,s)end function q.AddWarning(r,s)return p.New(r,s)end function q.Destroy(r)if r.Destroyed then return end r.Destroyed=true if r.Dropdown and r.Dropdown.
CloseMenu then pcall(function()r.Dropdown:CloseMenu(true)end)r.Dropdown=nil end if r.InsertConnection then r.InsertConnection:Disconnect()r.InsertConnection=nil end if r.UnbindDrag then pcall(r.
UnbindDrag)r.UnbindDrag=nil end if r.SnowLayer then r.SnowLayer:Destroy()r.SnowLayer=nil end if r.Gui then r.Gui:Destroy()r.Gui=nil end table.clear(r.ThemeBindings)table.clear(r.Tabs)r.ActiveTab=nil r
.Sidebar=nil r.Root=nil r.Canvas=nil r.Content=nil r.Overlay=nil r.Notifications=nil r.Topbar=nil end return q end function a.W()local b=a.cache.W if not b then b={c=__modImpl()}a.cache.W=b end return
b.c end end do local __modImpl=function()local b=a.b()local c=a.c()local d=a.f()local e=a.e()local f=a.g()local g=a.i()local h=a.W()local i={}i.__index=i function i.New()local j=setmetatable({Version=
'0.1.0',Windows={},ConfigWidgets={},AssetCache=d.New(),AssetRegistry=e,FlagManager=f.New()},i)j.Flags=j.FlagManager.Values j.ConfigManager=g.New(j.FlagManager)j.AssetCache:EnsureAll()j.RegistryEntry=b
.Claim(j.Version,function()j:Unload()end)return j end function i.RunCallback(j,k,l,...)c.Callback(k,l,...)end function i.CreateWindow(j,k)local l=h.New(j,k or{})table.insert(j.Windows,l)return l end
function i.Notify(j,k)local l=j.Windows[1]if l then return l:Notify(k)end return nil end function i.AddWarning(j,k)local l=j.Windows[1]if l then return l:AddWarning(k)end return nil end function i.
SaveConfig(j,k)local l=j.ConfigManager:Save(k)if l then j:RefreshConfigLists(k)end return l end function i.LoadConfig(j,k,l)local m=j.ConfigManager:Load(k,l)if m then j:RefreshConfigLists(k)end return
m end function i.GetConfigs(j)return j.ConfigManager:GetConfigs()end function i.RegisterConfigList(j,k)table.insert(j.ConfigWidgets,k)end function i.RefreshConfigLists(j,k)for l=#j.ConfigWidgets,1,-1
do local m=j.ConfigWidgets[l]if not m.Root or not m.Root.Parent then table.remove(j.ConfigWidgets,l)elseif m.RefreshConfigs then m:RefreshConfigs(k)end end end function i.SetAccent(j,k)for l,m in
ipairs(j.Windows)do m:SetAccent(k)end end function i.SetAssetBaseUrl(j,k)j.AssetRegistry.SetBaseUrl(k)return j.AssetCache:EnsureAll()end function i.SetTheme(j,k)for l,m in ipairs(j.Windows)do m:
SetTheme(k)end return true end function i.Toggle(j)for k,l in ipairs(j.Windows)do l:Toggle()end end function i.Open(j)for k,l in ipairs(j.Windows)do l:Open()end end function i.Close(j)for k,l in
ipairs(j.Windows)do l:Close()end end function i.Unload(j)for k,l in ipairs(j.Windows)do l:Destroy()end table.clear(j.Windows)table.clear(j.ConfigWidgets)b.Clear(j.RegistryEntry)end return i end
function a.X()local b=a.cache.X if not b then b={c=__modImpl()}a.cache.X=b end return b.c end end end local b=a.X()return b.New()