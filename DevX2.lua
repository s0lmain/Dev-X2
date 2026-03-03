local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()
local UIS = game:GetService("UserInputService")

-- Core Services
local _replicated = game:GetService("ReplicatedStorage")
local _workspace = game:GetService("Workspace")
local _players = game:GetService("Players")
local _lp = _players.LocalPlayer

-- State Variables
local currentBlockColor = Color3.fromRGB(163, 162, 165)
local currentSprayColor = Color3.fromRGB(255, 255, 255)
local currentRepStorageBrickText = "Dev, X2" 
local currentMaterial = "plastic" 
local _delCubesEnabled = false

-- Helper to find the RemoteEvent (Works whether tool is in Backpack or Character)
local function getToolRemote(toolName)
    local tool = _lp.Backpack:FindFirstChild(toolName) or (_lp.Character and _lp.Character:FindFirstChild(toolName))
    if tool then
        -- TCO tools sometimes hide the event inside a "Script" folder or directly in the tool
        return tool:FindFirstChild("Event", true) or tool:FindFirstChildWhichIsA("RemoteEvent", true)
    end
    return nil
end

-- Theme Setup
WindUI:SetFont("rbxassetid://16658246179")
WindUI:AddTheme({
    Name = "DevX2",
    Accent = Color3.fromHex("#14532D"),
    Background = Color3.fromHex("#0A0A0A"),
    Outline = Color3.fromHex("#1F2937"),
    Text = Color3.fromHex("#E5E7EB"),
    Placeholder = Color3.fromHex("#4B5563"),
    Button = Color3.fromHex("#166534"),
    Icon = Color3.fromHex("#22C55E"),
})
WindUI:SetTheme("DevX2")

local Window = WindUI:CreateWindow({
    Title = "Dev X2",
    Icon = "terminal",
    Author = "Discord.gg/",
    Theme = "DevX2",
    ToggleKey = Enum.KeyCode.K,
    HideSearchBar = false,
    Folder = "DevX2",

	User = {
		Enabled = true,
		Anonymous = false,
		Callback = function()
		end,
	},
})

------------------------------------------
-- OP Tab
------------------------------------------
local Tab = Window:Tab({
    Title = "Over-Powered",
    Icon = "gem",
    locked = false,
})

local Section = Tab:Section({
    Title = "RepStorage Bricks"
})

---
-- UI ELEMENTS
---

Tab:Colorpicker({
    Title = "Block Color",
    Default = Color3.fromRGB(163, 162, 165),
    Callback = function(color) currentBlockColor = color end
})

Tab:Colorpicker({
    Title = "Spray/Text Color",
    Default = Color3.fromRGB(255, 255, 255),
    Callback = function(color) currentSprayColor = color end
})

Tab:Dropdown({
    Title = "Brick Material",
    Desc = "Select the material used in TCO",
    Values = {
        "Smooth", "Plastic", "Tiles", "Bricks", "Planks", 
        "Ice", "Grass", "Sand", "Snow", "Glass", 
        "Wood", "Stone", "Pebble", "Marble", "Granite", 
        "Steel", "Metal", "Asphalt", "Concrete", "Pavement", 
        "Neon", "Toxic"
    },
    Callback = function(val) currentMaterial = val:lower() end
})

Tab:Input({
    Title = "Brick Text",
    Desc = "Front, Back, Left, Right, Top, Bottom",
    Value = "DevX2",
    InputIcon = "lucide:italic",
    Type = "Input",
    Callback = function(input) currentRepStorageBrickText = input end
})

Tab:Button({
    Title = "Set brick text",
    Desc = "This makes all new blocks have the text you put.",
    Callback = function()
        local brick = _replicated:FindFirstChild("Brick")
        local remote = getToolRemote("Paint")
        if not brick or not _lp.Character or not remote then return end

        local sCol = currentSprayColor
        local sprayHex = string.format("#%02x%02x%02x", math.floor(sCol.R * 255), math.floor(sCol.G * 255), math.floor(sCol.B * 255))
        
        local textList = {}
        local rawParts = string.split(currentRepStorageBrickText, ",")
        for i = 1, 6 do
            local p = rawParts[i] or rawParts[1] or " "
            table.insert(textList, p:match("^%s*(.-)%s*$"))
        end

        local sides = {"Front", "Back", "Left", "Right", "Top", "Bottom"}
        local key = "both \240\159\164\157"

        remote:FireServer(brick, "Front", brick.Position, key, currentBlockColor, currentMaterial, " ")
        task.wait(0.6)

        for i = 1, 6 do
            local sideName = sides[i]
            local content = textList[i]
            local taggedText = '<font color="'.. sprayHex ..'">' .. content .. '</font>'
            remote:FireServer(brick, sideName, brick.Position, key, currentBlockColor, "spray", taggedText)
            task.wait(0.45) 
        end
    end
})

Tab:Button({
    Title = "Toxic brick",
    Desc = "Every new brick becomes toxic",
    Callback = function()
        local brick = _replicated:WaitForChild("Brick")
        local remote = getToolRemote("Paint")
        if not remote then return end
        remote:FireServer(brick, "Front", brick.Position, "both \240\159\164\157", Color3.new(1,1,1), "toxic", "")
    end
})

Tab:Button({
    Title = "Anchor brick",
    Desc = "Anchors/Unanchors future bricks",
    Callback = function()
        local brick = _replicated:WaitForChild("Brick")
        local remote = getToolRemote("Paint")
        if not remote then return end
        remote:FireServer(brick, "Front", brick.Position, "both \240\159\164\157", Color3.new(1,1,1), "anchor", "")
    end
})

Tab:Button({
    Title = "Revert RepStorage",
    Desc = "Auto-detects device for best stability",
    Callback = function()
        local char = _lp.Character or _lp.CharacterAdded:Wait()
        local brick = _replicated:FindFirstChild("Brick")
        local isMobile = UIS.TouchEnabled
        
        local remote = getToolRemote("Paint")
        if not remote or not brick then return end

        local rootPos = char.HumanoidRootPart.Position
        local key = "both \u{1F91D}"
        local GREY = Color3.fromRGB(211, 211, 211)
        local PURE_BLACK = Color3.fromRGB(0, 0, 0)
        local waitTime = isMobile and 0.35 or 0.2

        remote:FireServer(brick, Enum.NormalId.Top, rootPos, key, GREY, "plastic", "")
        task.wait(0.5)

        local sides = {Enum.NormalId.Front, Enum.NormalId.Back, Enum.NormalId.Top, Enum.NormalId.Bottom, Enum.NormalId.Right, Enum.NormalId.Left}
        for _, side in ipairs(sides) do
            remote:FireServer(brick, side, rootPos, key, GREY, "spray", " ")
            task.wait(waitTime)
        end

        if not brick.Anchored then
            remote:FireServer(brick, Enum.NormalId.Top, rootPos, "material", PURE_BLACK, "anchor", "")
        end

        game:GetService("StarterGui"):SetCore("SendNotification", {
            Title = "DevX2",
            Text = "Successfully Reverted!",
            Duration = 5
        })
    end
})

local Section = Tab:Section({
    Title = "Other"
})

Tab:Toggle({
    Title = "Auto-Delete Bricks",
    Desc = "Continuously clears all player bricks",
    Default = false,
    Callback = function(state)
        _delCubesEnabled = state
        task.spawn(function()
            while _delCubesEnabled do
                local remote = getToolRemote("Delete")
                if remote and _lp.Character and _lp.Character:FindFirstChild("HumanoidRootPart") then
                    local myPos = _lp.Character.HumanoidRootPart.Position
                    for _, v in pairs(_workspace:GetDescendants()) do
                        if not _delCubesEnabled then break end
                        if v.Name == "Brick" and v:IsA("BasePart") then
                            remote:FireServer(v, myPos)
                            task.wait(0.01) 
                        end
                    end
                end
                task.wait(0.5)
            end
        end)
    end
})

local _voidAuraEnabled = false

Tab:Toggle({
    Title = "Void Aura",
    Desc = "Auto-teleport & paint all bricks black (Smart Detection)",
    Default = false,
    Callback = function(state)
        _voidAuraEnabled = state
        
        task.spawn(function()
            local char = _lp.Character or _lp.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart")
            local isMobile = UIS.TouchEnabled
            local originalPos = root.CFrame
            local handshake = "both \240\159\164\157" 
            local black = Color3.new(0, 0, 0)
            local sides = {"Front", "Back", "Top", "Bottom", "Left", "Right"}

            local syncTime = isMobile and 0.08 or 0.05
            local batchPause = isMobile and 0.02 or 0.01
            local batchSize = isMobile and 6 or 12

            local noclipConnection
            local function setNoClip(enable)
                if enable then
                    if noclipConnection then noclipConnection:Disconnect() end
                    noclipConnection = game:GetService("RunService").Stepped:Connect(function()
                        if char and char.Parent then
                            for _, part in pairs(char:GetDescendants()) do
                                if part:IsA("BasePart") then part.CanCollide = false end
                            end
                        end
                    end)
                else
                    if noclipConnection then noclipConnection:Disconnect() noclipConnection = nil end
                    for _, part in pairs(char:GetDescendants()) do
                        if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" then 
                            part.CanCollide = true 
                        end
                    end
                end
            end

            if _voidAuraEnabled then
                game:GetService("StarterGui"):SetCore("SendNotification", {
                    Title = "DevX2",
                    Text = "Void Aura: ENABLED",
                    Duration = 3
                })
                setNoClip(true)
            else
                setNoClip(false)
                return
            end

            while _voidAuraEnabled do
                local remote = getToolRemote("Paint")
                if remote and char and char:FindFirstChild("HumanoidRootPart") then
                    local targets = {}
                    for _, obj in pairs(_workspace:GetDescendants()) do
                        if not _voidAuraEnabled then break end
                        if obj.Name == "Brick" and obj:IsA("BasePart") and obj.Color ~= black then
                            table.insert(targets, obj)
                        end
                    end

                    for i, brick in ipairs(targets) do
                        if not _voidAuraEnabled then break end
                        root.CFrame = brick.CFrame
                        task.wait(syncTime)

                        task.spawn(function()
                            for _, side in ipairs(sides) do
                                remote:FireServer(brick, side, brick.Position, handshake, black, "spray", " ")
                            end
                        end)

                        if i % batchSize == 0 then
                            task.wait(batchPause)
                        end
                    end
                end

                if _voidAuraEnabled then
                    root.CFrame = originalPos
                    task.wait(0.5) 
                end
            end

            setNoClip(false)
            root.CFrame = originalPos
            game:GetService("StarterGui"):SetCore("SendNotification", {
                Title = "DevX2",
                Text = "Void Aura: DISABLED",
                Duration = 3
            })
        end)
    end
})

Tab:Button({
    Title = "Break bkit",
    Desc = "Destroy bkit",
    Callback = function()
        local brick = _replicated:FindFirstChild("Brick")
        local delTool = getToolRemote("Delete")
        if delTool and brick and _lp.Character then 
            delTool:FireServer(brick, _lp.Character.HumanoidRootPart.Position) 
        end
    end
})

------------------------------------------
-- Home Tab
------------------------------------------
-- [[ STATE & VARIABLES ]] --
local h, RainbowSpeed = 0, 0.005
local currentMaterial = "smooth"
local currentBlockPathType = "detailed"
local rainbow, shovel, delete, detailedPath, ka = false, false, false, false, false
local GlobalRange = 500

-- [[ UTILITIES ]] --

-- Force Equips a tool by name
local function forceEquip(toolName)
    local lp = game.Players.LocalPlayer
    local tool = lp.Backpack:FindFirstChild(toolName)
    if tool and lp.Character then
        lp.Character.Humanoid:EquipTool(tool)
    end
    return lp.Character:FindFirstChild(toolName)
end

local function getToolEvent(name)
    local t = game.Players.LocalPlayer.Character:FindFirstChild(name) or game.Players.LocalPlayer.Backpack:FindFirstChild(name)
    return t and t:FindFirstChild("Event", true)
end

-- [[ MAIN EXECUTION LOOP ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    local lp = game.Players.LocalPlayer
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    h = (h + RainbowSpeed) % 1
    local col = Color3.fromHSV(h, 1, 1)
    local mouseHit = lp:GetMouse().Hit.Position

    -- 1. RAINBOW PAINT (With Force Equip)
    if rainbow then
        local tool = forceEquip("Paint")
        if tool then
            local ev = tool:FindFirstChild("Event", true)
            if ev then
                ev:FireServer(workspace.Terrain, Enum.NormalId.Top, mouseHit, "both \240\159\164\157", col, currentMaterial, "")
            end
        end
    end

    -- 2. KILL AURA (With Force Equip)
    if ka then
        forceEquip("Build")
        forceEquip("Paint")
        
        local buildEv = getToolEvent("Build")
        local paintEv = getToolEvent("Paint")
        
        local targetPlayer = nil
        local dist = 20
        for _, p in ipairs(game.Players:GetPlayers()) do
            if p ~= lp and p.Character and p.Character:FindFirstChild("HumanoidRootPart") then
                local d = (p.Character.HumanoidRootPart.Position - hrp.Position).Magnitude
                if d < dist then
                    targetPlayer = p.Character.HumanoidRootPart
                    dist = d
                end
            end
        end
        
        if targetPlayer and buildEv and paintEv then
            buildEv:FireServer(workspace.Terrain, Enum.NormalId.Top, targetPlayer.Position, "detailed")
            paintEv:FireServer(workspace.Terrain, Enum.NormalId.Top, targetPlayer.Position, "both \240\159\164\157", Color3.new(0,0,0), "toxic", "")
        end
    end

    -- 3. SHOVEL / DELETE / TRAIL (Standard Logic)
    if shovel then
        local ev = getToolEvent("Shovel")
        if ev then ev:FireServer(workspace.Terrain, Enum.NormalId.Top, mouseHit, "dig") end
    end

    if delete then
        local ev = getToolEvent("Delete")
        if ev then
            local res = workspace:Raycast(hrp.Position, (mouseHit - hrp.Position).Unit * GlobalRange)
            ev:FireServer(res and res.Instance or workspace.Terrain, hrp.Position)
        end
    end

    if detailedPath then
        local buildEv = getToolEvent("Build")
        if buildEv then
            local pType = currentBlockPathType:gsub("rainbow ", "")
            buildEv:FireServer(workspace.Terrain, Enum.NormalId.Top, hrp.Position, pType)
        end
    end
end)

-- [[ UI SETUP ]] --

local Tab = Window:Tab({
    Title = "Home",
    Icon = "lucide:terminal",
})

Tab:Button({
    Title = "Load Infinite Yield",
    Desc = "Universal command script",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/EdgeIY/infiniteyield/master/source"))()
    end
})

Tab:Button({
    Title = "Joinxl",
    Callback = function()
        game.ReplicatedStorage.System:FireServer("xl")
    end
})

Tab:Dropdown({
    Title = "Material",
    Values = {"smooth", "plastic", "tiles", "bricks", "planks", "ice", "neon", "toxic", "anchor"},
    Value = "smooth",
    Callback = function(option) currentMaterial = option end
})

Tab:Toggle({
    Title = "Rainbow paint",
    Icon = "lucide:paintbrush",
    Callback = function(state) rainbow = state end
})

Tab:Toggle({
    Title = "Shovel",
    Icon = "lucide:shovel",
    Callback = function(state) shovel = state end
})

Tab:Toggle({
    Title = "Delete",
    Icon = "lucide:hammer",
    Callback = function(state) delete = state end
})

Tab:Dropdown({
    Title = "Block trail type",
    Values = {"detailed", "normal", "rainbow detailed", "rainbow normal"},
    Value = "detailed",
    Callback = function(option) currentBlockPathType = option[1] or option end
})

Tab:Toggle({
    Title = "Block trail",
    Icon = "lucide:line-squiggle",
    Callback = function(state) detailedPath = state end
})

Tab:Toggle({
    Title = "Kill aura",
    Icon = "lucide:sword",
    Callback = function(state) ka = state end
})

Tab:Section({ Title = "Aura Settings" })

Tab:Slider({
    Title = "Rainbow Speed",
    Step = 0.001,
    Value = { Min = 0.001, Max = 0.05, Default = 0.005 },
    Callback = function(v) RainbowSpeed = v end
})

Tab:Slider({
    Title = "Aura Range",
    Value = { Min = 10, Max = 500, Default = 500 },
    Callback = function(v) GlobalRange = v end
})

------------------------------------------
-- Aura Tab
------------------------------------------
-- [[ VARIABLES & STATE ]] --
local Buildaura, SignAura, PaintAura, DeleteAura = false, false, false, false
local DeleteAuraRange, PaintAuraRange = 20, 20 -- Default ranges
local h = 0
local RainbowSpeed = 0.005

-- [[ CORE UTILITIES ]] --

-- Finds a tool and its event whether it's equipped or in the backpack
local function getToolEvent(toolName)
    local tool = _lp.Character:FindFirstChild(toolName) or _lp.Backpack:FindFirstChild(toolName)
    if tool then
        -- true search depth finds the RemoteEvent even if it's nested inside folders
        return tool:FindFirstChild("Event", true) 
    end
    return nil
end

-- Spherical Positioning Logic (From your provided snippet)
local function getPositionAround(part, minRange, maxRange)
    local distance = math.random() * (maxRange - minRange) + minRange
    local theta = math.random() * math.pi * 2
    local phi = math.acos(2 * math.random() - 1) 
    return part.Position + Vector3.new(
        distance * math.sin(phi) * math.cos(theta),
        distance * math.cos(phi),
        distance * math.sin(phi) * math.sin(theta)
    )
end

-- Nearest Part Detection (Targets TCO specific brick folders)
local function getNearestPart(maxRange)
    local candidates = {}
    local hrp = _lp.Character and _lp.Character:FindFirstChild("HumanoidRootPart")
    if not hrp then return end
    
    local folder = _workspace:FindFirstChild("Bricks") or _workspace:FindFirstChild("PlacedBlocks")
    if not folder then return end

    for _, part in ipairs(folder:GetDescendants()) do
        if part:IsA("BasePart") then
            local d = (hrp.Position - part.Position).Magnitude
            if d <= maxRange then 
                table.insert(candidates, part) 
            end
        end
    end
    return #candidates > 0 and candidates[math.random(1, #candidates)] or nil
end

-- [[ THE "HANDS-FREE" LOOP ]] --
game:GetService("RunService").RenderStepped:Connect(function()
    local char = _lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    if not hrp then return end

    -- Sync Rainbow Cycle
    h = (h + RainbowSpeed) % 1
    local col = Color3.fromHSV(h, 1, 1)

    -- 1. BUILD AURA (Sphere)
    if Buildaura then
        local event = getToolEvent("Build")
        if event then
            event:FireServer(_workspace.Terrain, Enum.NormalId.Top, getPositionAround(hrp, 3, 15), "normal")
        end
    end

    -- 2. DELETE AURA (Distance based)
    if DeleteAura then
        local event = getToolEvent("Delete")
        local block = getNearestPart(DeleteAuraRange)
        if event and block then
            event:FireServer(block, hrp.Position)
        end
    end

    -- 3. SIGN AURA (Sphere)
    if SignAura then
        local event = getToolEvent("Sign")
        if event then
            event:FireServer(_workspace.Terrain, Enum.NormalId.Top, getPositionAround(hrp, 3, 15), "normal")
        end
    end

    -- 4. PAINT AURA (Distance based + Rainbow)
    if PaintAura then
        local event = getToolEvent("Paint")
        local block = getNearestPart(PaintAuraRange)
        if event and block then
            -- Specific FireServer signature for the TCO Paint Tool
            event:FireServer(block, Enum.NormalId.Top, hrp.Position, "both \240\159\164\157", col, "plastic", "")
        end
    end
end)

-- [[ UI SETUP ]] --
local AuraTab = Window:Tab({
    Title = "Auras (Advanced)",
    Icon = "lucide:zap",
})

AuraTab:Section({ Title = "Automatic Auras" })

AuraTab:Toggle({
    Title = "Build Aura",
    Callback = function(state) Buildaura = state end
})

AuraTab:Toggle({
    Title = "Sign Aura",
    Callback = function(state) SignAura = state end
})

AuraTab:Toggle({
    Title = "Delete Aura",
    Callback = function(state) DeleteAura = state end
})

AuraTab:Toggle({
    Title = "Rainbow Paint Aura",
    Callback = function(state) PaintAura = state end
})

AuraTab:Section({ Title = "Aura Configuration" })

AuraTab:Slider({
    Title = "Rainbow Speed",
    Step = 0.001,
    Value = { Min = 0.001, Max = 0.05, Default = 0.005 },
    Callback = function(v) RainbowSpeed = v end
})

AuraTab:Slider({
    Title = "Delete Range",
    Value = { Min = 5, Max = 500, Default = 20 }, -- Max set to 500
    Callback = function(v) DeleteAuraRange = v end
})

AuraTab:Slider({
    Title = "Paint Range",
    Value = { Min = 5, Max = 500, Default = 20 }, -- Max set to 500
    Callback = function(v) PaintAuraRange = v end
})

---------------------------------------------------------------------------------------------------------------------
-- Dev X2 Autobuild
---------------------------------------------------------------------------------------------------------------------
local lp = game.Players.LocalPlayer
local mult = 4 
local built, stopped, skipblock, tp = false, false, false, true

-- [[ UTILITIES ]] --

local function forceEquip(toolName)
    local tool = lp.Backpack:FindFirstChild(toolName)
    if tool and lp.Character then lp.Character.Humanoid:EquipTool(tool) end
    return lp.Character:FindFirstChild(toolName)
end

local function getTCOEvent(toolName)
    local tool = lp.Character:FindFirstChild(toolName) or lp.Backpack:FindFirstChild(toolName)
    return tool and tool:FindFirstChild("Event", true)
end

-- CRITICAL FIX: Snaps character position to the 4-stud grid
local function snapToGrid(pos)
    return Vector3.new(
        math.floor(pos.X / mult + 0.5) * mult,
        math.floor(pos.Y / mult + 0.5) * mult,
        math.floor(pos.Z / mult + 0.5) * mult
    )
end

-- Listener: Cleans up green ghost outlines as soon as a block is placed
if workspace:FindFirstChild("Bricks") and workspace.Bricks:FindFirstChild(lp.Name) then
    workspace.Bricks[lp.Name].ChildAdded:Connect(function(child)
        built = true
        for _, v in ipairs(workspace:GetChildren()) do
            if v:IsA("BasePart") and v.Name == "Part" and v.Transparency > 0.4 then
                v:Destroy()
            end
        end
    end)
end

local function buildblock(pos, bsize)
    task.wait(0.01)
    built, skipblock = false, false
    local c = 0
    repeat
        c = c + 1
        forceEquip("Build")
        local event = getTCOEvent("Build")
        if event then
            event:FireServer(workspace.Terrain, Enum.NormalId.Top, pos, bsize or "normal")
        end
        if tp and lp.Character:FindFirstChild("HumanoidRootPart") then
            -- TP slightly above the block to avoid getting stuck inside
            lp.Character.HumanoidRootPart.CFrame = CFrame.new(pos + Vector3.new(0, 6, 0))
        end
        task.wait(0.07)
    until built or stopped or skipblock or c > 40
    built = false
end

---------------------------------------------------------------------------------------------------------------------
-- UI TAB SETUP
---------------------------------------------------------------------------------------------------------------------
local Tab = Window:Tab({ Title = "Autobuild", Icon = "lucide:hammer" })

Tab:Section({ Title = "Build Controls" })

Tab:Button({ Title = "Stop Building", Callback = function() stopped = true end })
Tab:Button({ Title = "Skip Block", Callback = function() skipblock = true end })
Tab:Toggle({ Title = "Teleport to Block", Value = true, Callback = function(s) tp = s end })

Tab:Section({ Title = "Generation" })

Tab:Input({
    Title = "Build Cube (Size)",
    Placeholder = "e.g. 5",
    Callback = function(txt)
        local num = tonumber(txt)
        if not num or not lp.Character:FindFirstChild("HumanoidRootPart") then return end
        stopped = false
        
        -- Apply snapping to the start position
        local startPos = snapToGrid(lp.Character.HumanoidRootPart.Position)
        
        for y = 0, num - 1 do
            for x = 0, num - 1 do
                for z = 0, num - 1 do
                    if stopped then break end
                    local target = startPos + Vector3.new(x * mult, y * mult, z * mult)
                    buildblock(target)
                end
            end
        end
    end
})

-- Re-adding Text-to-Blocks with Snapping
local txtstuff
pcall(function()
    txtstuff = loadstring(game:HttpGet("https://rawscripts.net/raw/Universal-Script-Text-to-Blocks-WIP-20736"))()
end)

Tab:Input({
    Title = "Build Text",
    Placeholder = "Enter text...",
    Callback = function(txt)
        if not txtstuff then return end
        stopped = false
        local blocks = txtstuff.getblocks(txt)
        local _, pttable, cfrtable = txtstuff.displayblocks(blocks, lp.Character:GetPivot(), 4, true, 4, 4, 0, false, Enum.Material.ForceField)
        
        for _, v in pairs(cfrtable) do
            if stopped then break end
            buildblock(snapToGrid(v.Position))
        end
        if pttable then for _,p in pairs(pttable) do p:Destroy() end end
    end
})

-- Save/Load brought back
local saveName = ""
Tab:Input({ Title = "Save Name", Placeholder = "Name...", Callback = function(t) saveName = t end })

Tab:Button({
    Title = "Save Build",
    Callback = function()
        if saveName == "" then return end
        local data = {}
        local folder = workspace.Bricks:FindFirstChild(lp.Name)
        if folder then
            for _, v in ipairs(folder:GetChildren()) do
                if v:IsA("BasePart") then
                    table.insert(data, {p = {v.Position.X, v.Position.Y, v.Position.Z}})
                end
            end
        end
        if not isfolder("DevX2_Builds") then makefolder("DevX2_Builds") end
        writefile("DevX2_Builds/"..saveName..".json", game:GetService("HttpService"):JSONEncode(data))
    end
})

Tab:Button({
    Title = "Load Build",
    Callback = function()
        local path = "DevX2_Builds/"..saveName..".json"
        if not isfile(path) then return end
        local data = game:GetService("HttpService"):JSONDecode(readfile(path))
        stopped = false
        for _, v in ipairs(data) do
            if stopped then break end
            buildblock(Vector3.new(v.p[1], v.p[2], v.p[3]))
        end
    end
})

local lp = game.Players.LocalPlayer
local lighting = game:GetService("Lighting")
local sg = game:GetService("StarterGui")
local runService = game:GetService("RunService")

-- [[ FINAL STATES ]] --
local AntiBlind, Antimyopic, AutoFixCam = false, false, false
local AntiJail, Antifreeze, AntiGlitch, AntiFog = false, false, false, false

local atmosphere = lighting:FindFirstChildOfClass("Atmosphere")
local OriginalFogDensity = atmosphere and atmosphere.Density or 0.3
local lastSafePosition = nil

-- [[ UTILITIES ]] --
local function fixPlayerState()
    pcall(function()
        sg:SetCoreGuiEnabled(Enum.CoreGuiType.Backpack, true)
        sg:SetCoreGuiEnabled(Enum.CoreGuiType.All, true)
    end)
    local cam = workspace.CurrentCamera
    if lp.Character and lp.Character:FindFirstChild("Humanoid") then
        cam.CameraType = Enum.CameraType.Custom
        cam.CameraSubject = lp.Character.Humanoid
        cam.FieldOfView = 70
    end
end

local function canCollideObj(obj)
    if not obj then return end
    for _, part in ipairs(obj:GetDescendants()) do
        if part:IsA("BasePart") then part.CanCollide = false end
    end
end

-- [[ THE "STRICT" BACKGROUND WATCHER ]] --
runService.RenderStepped:Connect(function()
    local char = lp.Character
    local hrp = char and char:FindFirstChild("HumanoidRootPart")
    
    -- 1. Anti-Glitch Logic
    if hrp then
        if AntiGlitch and lastSafePosition then
            if (hrp.Position - lastSafePosition).Magnitude > 1000 then
                hrp.Velocity = Vector3.zero
                hrp.CFrame = CFrame.new(lastSafePosition)
            end
        end
        if hrp.Position.Y > -50 and hrp.Position.Y < 5000 then
            lastSafePosition = hrp.Position
        end
    end

    -- 2. Anti-Blind Strict Force-Off
    if AntiBlind then
        local b = lp.PlayerGui:FindFirstChild("Blind")
        if b then 
            b.Enabled = false 
            for _, v in ipairs(b:GetDescendants()) do
                if v:IsA("Frame") or v:IsA("ImageLabel") then v.Visible = false end
            end
        end
    end

    -- 3. Anti-Myopic Strict Force-Off
    if Antimyopic then
        local blur = lighting:FindFirstChildOfClass("BlurEffect")
        if blur then 
            blur.Enabled = false 
            blur.Size = 0 
        end
    end

    -- 4. Auto-Fix Camera & Fog
    if AutoFixCam then
        local cam = workspace.CurrentCamera
        if cam.CameraType ~= Enum.CameraType.Custom then cam.CameraType = Enum.CameraType.Custom end
    end
    if AntiFog and atmosphere then
        atmosphere.Density = 0.4
    end
end)

---------------------------------------------------------------------------------------------------------------------
-- WIND UI: THE COMPLETE ANTIS TAB
---------------------------------------------------------------------------------------------------------------------
local AntiTab = Window:Tab({ Title = "Antis", Icon = "lucide:shield-x" })

-- SECTION: RECOVERY
AntiTab:Section({ Title = "Recovery & Bug Fixes" })

AntiTab:Toggle({
    Title = "Auto-Fix Camera/Inv",
    Desc = "Prevents Vampire Bug from locking screen/inventory",
    Callback = function(state) 
        AutoFixCam = state 
        if state then fixPlayerState() end
    end
})

AntiTab:Button({
    Title = "Manual UI Restore",
    Callback = function() fixPlayerState() end
})

-- SECTION: VISUALS
AntiTab:Section({ Title = "Atmosphere & Visuals" })

AntiTab:Toggle({
    Title = "Anti-Fog",
    Callback = function(state) 
        AntiFog = state
        if not state and atmosphere then atmosphere.Density = OriginalFogDensity end
    end
})

AntiTab:Toggle({
    Title = "Anti-Blind",
    Callback = function(state) AntiBlind = state end
})

AntiTab:Toggle({
    Title = "Anti-Myopic",
    Callback = function(state) Antimyopic = state end
})

-- SECTION: PROTECTION
AntiTab:Section({ Title = "Character Protection" })

AntiTab:Toggle({
    Title = "Anti-Glitch",
    Desc = "Returns you to last safe spot if flung",
    Callback = function(state) AntiGlitch = state end
})

AntiTab:Toggle({
    Title = "Anti-Jail",
    Callback = function(state) 
        AntiJail = state 
        if state and lp.Character:FindFirstChild("Jail") then canCollideObj(lp.Character.Jail) end
    end
})

AntiTab:Toggle({
    Title = "Anti-Freeze",
    Callback = function(state) Antifreeze = state end
})

-- [[ PERSISTENT LISTENERS ]] --
lp.CharacterAdded:Connect(function(char)
    if AutoFixCam then task.wait(0.5) fixPlayerState() end
    char.ChildAdded:Connect(function(inst)
        if inst.Name == "Hielo" and Antifreeze then
            char:FindFirstChildOfClass("Humanoid").Health = 0
        elseif inst.Name == "Jail" and AntiJail then
            task.wait(0.1)
            canCollideObj(inst)
        end
    end)
end)

local lp = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")

-- [[ STATES ]] --
local selectedTarget = nil
local targetDelcubes = false
local clickTPEnabled = false

-- [[ UTILITIES ]] --
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "No Players Found") end
    return names
end

local lp = game.Players.LocalPlayer
local uis = game:GetService("UserInputService")

-- [[ STATES ]] --
local selectedTarget = nil
local targetDelcubes = false
local clickTPEnabled = false

-- [[ UTILITIES ]] --
local function getPlayerNames()
    local names = {}
    for _, p in ipairs(game.Players:GetPlayers()) do
        if p ~= lp then table.insert(names, p.Name) end
    end
    if #names == 0 then table.insert(names, "No Players Found") end
    return names
end

local function forceEquip(toolName)
    local tool = lp.Backpack:FindFirstChild(toolName)
    if tool and lp.Character then
        lp.Character.Humanoid:EquipTool(tool)
    end
    return lp.Character:FindFirstChild(toolName)
end

---------------------------------------------------------------------------------------------------------------------
-- TARGET TAB
---------------------------------------------------------------------------------------------------------------------
local TargetTab = Window:Tab({ 
    Title = "Target", 
    Icon = "lucide:users-round" 
})

local PlayerDropdown = TargetTab:Dropdown({
    Title = "Select Player",
    Desc = "Choose who to target",
    Values = getPlayerNames(),
    Callback = function(val)
        selectedTarget = game.Players:FindFirstChild(val)
    end
})

TargetTab:Button({
    Title = "Refresh Player List",
    Callback = function()
        PlayerDropdown:SetValues(getPlayerNames())
    end
})

TargetTab:Section({ Title = "Offensive" })

TargetTab:Toggle({
    Title = "Delcubes Player",
    Desc = "Automatically deletes everything the target builds",
    Callback = function(state) 
        targetDelcubes = state 
    end
})

TargetTab:Section({ Title = "Movement" })

TargetTab:Toggle({
    Title = "Click TP",
    Desc = "Tap the ground to teleport instantly",
    Callback = function(state) 
        clickTPEnabled = state 
    end
})

TargetTab:Button({
    Title = "Teleport to Target",
    Callback = function()
        if selectedTarget and selectedTarget.Character and selectedTarget.Character:FindFirstChild("HumanoidRootPart") then
            lp.Character.HumanoidRootPart.CFrame = selectedTarget.Character.HumanoidRootPart.CFrame * CFrame.new(0, 5, 0)
        end
    end
})

---------------------------------------------------------------------------------------------------------------------
-- MOBILE CLICK TP LOGIC
---------------------------------------------------------------------------------------------------------------------
uis.TouchTapInWorld:Connect(function(touchPos, processed)
    if processed or not clickTPEnabled then return end
    
    local hrp = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if hrp then
        local unitRay = workspace.CurrentCamera:ScreenPointToRay(touchPos.X, touchPos.Y)
        local raycastResult = workspace:Raycast(unitRay.Origin, unitRay.Direction * 1000)
        
        if raycastResult then
            hrp.CFrame = CFrame.new(raycastResult.Position + Vector3.new(0, 3, 0))
        end
    end
end)

---------------------------------------------------------------------------------------------------------------------
-- DELCUBES PLAYER LOOP
---------------------------------------------------------------------------------------------------------------------
task.spawn(function()
    while task.wait(0.5) do -- Timed for mobile stability
        if targetDelcubes and selectedTarget then
            local bricksFolder = workspace:FindFirstChild("Bricks")
            local targetBricks = bricksFolder and bricksFolder:FindFirstChild(selectedTarget.Name)
            
            if targetBricks and #targetBricks:GetChildren() > 0 then
                -- Ensure the Delete tool is ready
                local tool = forceEquip("Delete")
                local ev = tool and tool:FindFirstChild("Event", true)
                
                if ev then
                    -- Delete all blocks in the target's folder
                    for _, cube in ipairs(targetBricks:GetChildren()) do
                        if not targetDelcubes then break end
                        ev:FireServer(cube, lp.Character.HumanoidRootPart.Position)
                        -- Small delay between blocks to avoid kicking for spam
                        task.wait(0.02)
                    end
                end
            end
        end
    end
end)

local Tab = Window:Tab({
        Title = "Scripts",
        Icon = "file-terminal",
})

Tab:Paragraph({
    Title = "Information",
    Desc = "You can find all OP and working scripts here!"
})

local AdvancedDropdown = Tab:Dropdown({
    Title = "Scripts!",
    Values = {
        {
            Title = "Extra Stuff",
            Desc = "First script!",
            Icon = "",
            Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/s0lmain/Extra-Stuff-File/refs/heads/main/s0l"))()
            end
        },
        {
            Title = "ZTE Hub",
            Desc = "Second script!",
            Icon = "",
            Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/khanh-lol/Ztehub/refs/heads/main/ztebeta"))()
            end
        
        },
        {
            Title = "VPLI Hub",
            Desc = "Third script!",
            Icon = "",
            Callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))()
           
            end
    
        },
        {
            Title = "Annoyance Hub",
            Desc = "Fourth script!",
            Icon = "",
            Callback = function()
                    loadstring(game:HttpGet("https://raw.githubusercontent.com/s0lmain/Annoyance-Hub-File/refs/heads/main/s0l"))()
            
            end
        },
        {

            Title = "Emote Wheel",
            Desc = "Fifth!",
            Icon = "",
            Callback = function()
                loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()

            end
        },
    }
})

local Button = Tab:Button({
    Title = "Extra Stuff",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/s0lmain/Scripts/refs/heads/main/ExtraStuff.txt"))()
    end
})


local Button = Tab:Button({
    Title = "ZTE Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/khanh-lol/Ztehub/refs/heads/main/ztebeta"))()
    end
})


local Button = Tab:Button({
    Title = "VPLI Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/Adam3mka/The-chosen-one-lukaku/refs/heads/main/Protected_6361979247750901.txt"))()
    end
})


local Button = Tab:Button({
    Title = "Annoyance Hub",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/s0lmain/Scripts/refs/heads/main/Annoyance.txt"))()
    end
})


local Button = Tab:Button({
    Title = "Emote Wheel",
    Callback = function()
        loadstring(game:HttpGet("https://raw.githubusercontent.com/7yd7/Hub/refs/heads/Branch/GUIS/Emotes.lua"))()
    end
})

----------------------------------------------
-- Credits tab
----------------------------------------------
local Tab = Window:Tab({
    Title = "Credits",
    Icon = "lucide:form",
})

Tab:Paragraph({
    Title = "Credits",
    Desc = "All made by stik :3\nEnjoy using my script!"
})

Tab:Paragraph({
    Title = "Keybinds",
    Desc = "PC\nClick K to hide or show hub.\nThats all!"
})