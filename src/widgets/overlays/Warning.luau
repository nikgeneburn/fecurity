--!strict

local Modal = require("@fec/widgets/overlays/Modal")

local Warning = {}

function Warning.New(Window: any, Options: { [string]: any })
    Options.Title = Options.Title or "Warning"
    return Modal.New(Window, Options)
end

return Warning

