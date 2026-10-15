if not game:IsLoaded() then game.Loaded:Wait() end

local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

if not Rayfield then
    warn("[ERROR]: Failed to load Rayfield.")
    return
end

-- Thème rouge sombre personnalisé
local RedTheme = {
    TextColor = Color3.fromRGB(245, 240, 240),

    Background = Color3.fromRGB(18, 10, 12),
    Topbar = Color3.fromRGB(30, 14, 18),
    Shadow = Color3.fromRGB(8, 4, 5),

    NotificationBackground = Color3.fromRGB(24, 12, 15),
    NotificationActionsBackground = Color3.fromRGB(235, 70, 80),

    TabBackground = Color3.fromRGB(30, 16, 20),
    TabStroke = Color3.fromRGB(70, 28, 34),
    TabBackgroundSelected = Color3.fromRGB(220, 38, 52),
    TabTextColor = Color3.fromRGB(210, 190, 192),
    SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

    ElementBackground = Color3.fromRGB(28, 15, 18),
    ElementBackgroundHover = Color3.fromRGB(42, 20, 25),
    SecondaryElementBackground = Color3.fromRGB(22, 12, 15),
    ElementStroke = Color3.fromRGB(70, 28, 34),
    SecondaryElementStroke = Color3.fromRGB(55, 22, 27),

    SliderBackground = Color3.fromRGB(90, 25, 32),
    SliderProgress = Color3.fromRGB(235, 55, 70),
    SliderStroke = Color3.fromRGB(255, 110, 120),

    ToggleBackground = Color3.fromRGB(20, 10, 12),
    ToggleEnabled = Color3.fromRGB(235, 55, 70),
    ToggleDisabled = Color3.fromRGB(95, 70, 73),
    ToggleEnabledStroke = Color3.fromRGB(255, 110, 120),
    ToggleDisabledStroke = Color3.fromRGB(120, 90, 93),
    ToggleEnabledOuterStroke = Color3.fromRGB(100, 30, 38),
    ToggleDisabledOuterStroke = Color3.fromRGB(60, 35, 38),

    DropdownSelected = Color3.fromRGB(48, 22, 27),
    DropdownUnselected = Color3.fromRGB(30, 15, 18),

    InputBackground = Color3.fromRGB(24, 12, 15),
    InputStroke = Color3.fromRGB(110, 40, 48),
    PlaceholderColor = Color3.fromRGB(150, 120, 123),
}

local Window = Rayfield:CreateWindow({
    Name = "🍋 Sell Lemons  •  Mk7.RBX",
    Icon = "flame",
    LoadingTitle = "Sell Lemons",
    LoadingSubtitle = "by Mk7.RBX",
    ShowText = "Menu",
    Theme = RedTheme,

    ToggleUIKeybind = Enum.KeyCode.RightShift,

    DisableRayfieldPrompts = true,
    DisableBuildWarnings = true,

    ConfigurationSaving = {
        Enabled = false,
        FolderName = "MK7_Configs",
        FileName = "Config_Main"
    },

    Discord = {
        Enabled = true,
        Invite = "discord.gg/c4byf5cdRd",
        RememberJoins = false
    },
})

if not Window then
    warn("[ERROR]: Failed to load Window.")
    return
end

-- Sécurité : si la version de Rayfield n'accepte pas une table dans Theme
pcall(function()
    if Window.ModifyTheme then
        Window.ModifyTheme(RedTheme)
    end
end)

local function DestroyUI(value)
    if value then 
        task.wait(value) 
    end

    Rayfield:Destroy()
end

local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local HttpService = game:GetService("HttpService")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local LocalPlayer = Players.LocalPlayer

if not LocalPlayer then
    warn("[ERROR]: Failed to load LocalPlayer (how?).")
    return
end

local SuccessIdle, ErrIdle = pcall(function()
    for _, idle in pairs(getconnections(LocalPlayer.Idled)) do
        idle:Disable()
    end
end)

if not SuccessIdle then
    warn("[ERROR]: Anti-Idle failed. | Error: " .. tostring(ErrIdle))
end

-- Variables pour les statistiques en temps réel et globales du jeu
local StatsData = {
    StartTime = tick(),
    TotalPurchasesMade = 0,
}

local ScriptData = {
    PlayerTycoon = nil, -- the current player's tycoon.
    Values = nil, -- the values folder in the player's tycoon.
    Powers = nil, -- tycoon powers.
    Streams = nil, -- tycoon income sources

    AutoBuy = false, -- button buying, rebirths, evolutions, ascensions, phone offers, income source waking, etc.
    AutoUpgrade = false,
    AutoRebirth = false,
    AutoEvolve = false,
    AutoAscend = false,
    AutoBuyPowers = false,
    AutoWakeIncomeSources = false,
    AutoPhoneOffers = false,
    AutoCollectFruits = false,

    MainSettings = {
        ButtonBuy = {
            BuyInterval = 0.05, -- how often (in seconds) to buy new buyable buttons.
            UseForeverPurchase = false, -- whether to use the forever purchase or not when auto buying. (if false, it will use the normal buy)
        },

        Rebirth = {
            MaximumRebirths = 0, -- maximum allowed rebirths per evolution (0 = off)

            MinimumPotential = 1000, -- the minimum potential investors needed to rebirth when auto rebirth is on.
            XFactor = 10, -- the X factor to rebirth at when auto rebirth is on. (current investors * this number = then rebirth)

            RebirthWhenUnableToBuy = false, -- whether to rebirth when unable to buy any more buttons or not. (does not work with the above options, it will override them when enabled)\
            TimeBeforeRebirthWhenUnableToBuy = 30, -- the amount of time (in seconds) to wait before rebirthing when the above option is enabled.

            RebirthAfterCertainTime = false, -- whether to rebirth after a certain amount of time or not. (does not with X factor)
            TimeAmount = 60, -- the amount of time (in seconds) to wait before rebirthing when the above option is enabled.
        },

        Evolve = {
            MaximumEvolution = 0, -- the maximum allowed evolution, good when you want to ascend.
        },
    },

    Modules = {
        Tycoon = nil,

        Analyzer = nil,
        Balance = nil,

        Balances = nil,
        Upgrades = nil,
        Rebirth = nil,
        Evolve = nil,
        Ascension = nil,
        PhoneOffers = nil,
        TycoonPowers = nil,
    },

    Remotes = {
        Rebirth = nil,
        Evolve = nil,
        Ascend = nil,
        UpgradePowerLevel = nil,
        WakeIncomeStream = nil,
        PhoneOffer = nil,
    },
}

local function FindValues(Value, AnotherChild, ReturnLast)
    if not ScriptData.PlayerTycoon then return end

    local Values = ScriptData.PlayerTycoon:FindFirstChild("Values")
    if not Values then warn("[ERROR]: Failed to find Values folder.") end

    local ReturnValue = Values:FindFirstChild(Value)
    if not ReturnValue then warn("[ERROR]: Failed to find configuration in Values.") end

    if not AnotherChild then
        return ReturnValue
    else
        local Check = ReturnValue:FindFirstChild(AnotherChild)

        if Check and not ReturnLast then
            return ReturnValue, Check
        elseif Check and ReturnLast then
            return Check
        end
    end
end

-- Fonction Améliorée pour trouver le Tycoon de n'importe quel joueur
local function FindTycoonForPlayer(targetPlayer)
    if not targetPlayer then return nil end
    
    for _, v in pairs(Workspace:GetChildren()) do
        if v:IsA("Folder") and v.Name:match("Tycoon%d") then
            local owner = v:FindFirstChild("Owner")
            if owner then
                if owner.Value == targetPlayer 
                   or owner.Value == targetPlayer.Name 
                   or owner.Value == targetPlayer.UserId 
                   or tostring(owner.Value) == targetPlayer.Name then
                    return v
                end
            end
        end
    end
    return nil
end

local function FindTycoon()
    return FindTycoonForPlayer(LocalPlayer)
end

local StartTime = tick()
repeat
    ScriptData.PlayerTycoon = FindTycoon()

    if tick() - StartTime > 5 then
        Rayfield:Notify({
            Title = "Information",
            Content = "Taking longer than usual to find your tycoon, this may be due to loading. Please wait.",
            Image = "alert-triangle",
            Duration = 5,
        })
    elseif tick() - StartTime > 30 then
        warn("[ERROR]: Tycoon unable to be found.")
        DestroyUI()
        return
    end
    task.wait(0.25)
until ScriptData.PlayerTycoon ~= nil

StartTime = tick()
repeat 
    ScriptData.Values = FindValues("Values")

    if tick() - StartTime > 5 then
        warn("[ERROR]: Values unable to be found.")
        DestroyUI()
        return
    end
until ScriptData.Values ~= nil

StartTime = tick()
repeat 
    ScriptData.Powers = FindValues("Powers", "Permanent", true)

    if tick() - StartTime > 5 then
        warn("[ERROR]: Powers unable to be found.")
        DestroyUI()
        return
    end
until ScriptData.Powers ~= nil

StartTime = tick()
repeat 
    ScriptData.Streams = FindValues("Income", "Streams", true)

    if tick() - StartTime > 5 then
        warn("[ERROR]: Streams unable to be found.")
        DestroyUI()
        return
    end
until ScriptData.Streams ~= nil

local S1, R1 = pcall(function()
    ScriptData.Modules.Tycoon = require(ReplicatedStorage.Modules.Tycoon.Tycoon)

    ScriptData.Modules.Balances = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonBalances)
    ScriptData.Modules.Upgrades = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonUpgrades)
    ScriptData.Modules.Rebirth = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonRebirth)
    ScriptData.Modules.Evolve = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonEvolution)
    ScriptData.Modules.Ascension = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonAscension)
    ScriptData.Modules.PhoneOffers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPhoneOffers)
    ScriptData.Modules.TycoonPowers = require(ReplicatedStorage.Modules.Tycoon.Component.Client.ClientTycoonPowers)
    ScriptData.Modules.Analyzer = require(ReplicatedStorage.Modules.Tycoon.Component.TycoonAnalyzer)
    ScriptData.Modules.Balance = require(ReplicatedStorage.Balance)
end)

local S2, R2 = pcall(function()
    ScriptData.Remotes.Rebirth = ScriptData.PlayerTycoon.Remotes.Rebirth
    ScriptData.Remotes.Evolve = ScriptData.PlayerTycoon.Remotes.Evolve
    ScriptData.Remotes.Ascend = ScriptData.PlayerTycoon.Remotes.Ascend
    ScriptData.Remotes.UpgradePowerLevel = ScriptData.PlayerTycoon.Remotes.UpgradePowerLevel
    ScriptData.Remotes.WakeIncomeStream = ScriptData.PlayerTycoon.Remotes.WakeIncomeStream
    ScriptData.Remotes.PhoneOffer = ScriptData.PlayerTycoon.Remotes.PhoneOffer
end)

if not S1 or not S2 then
    if not S1 and not S2 then
        Rayfield:Notify({
            Title = "Critical Error!",
            Content = "Script is being aborted. Please wait and try again.",
            Image = "shield-alert",
            Duration = 3,
        })

        warn("[ERROR]: CRITICAL FAILURE, Failed to load modules and remotes.")
        warn(string.format("Module Error: %s\n", tostring(R1)))
        warn(string.format("Remote Error: %s\n", tostring(R2)))
        DestroyUI(5)
        return
    end

    if not S1 then
        Rayfield:Notify({
            Title = "Module Error!",
            Content = "Failed to load modules, some features may not work.",
            Image = "circle-alert",
            Duration = 3,
        })

        warn(string.format("[ERROR]: Module failed.\nError: %s\n", tostring(R1)))
    end

    if not S2 then
        Rayfield:Notify({
            Title = "Remote Error!",
            Content = "Failed to load remotes, some features may not work.",
            Image = "circle-alert",
            Duration = 3,
        })

        warn(string.format("[ERROR]: Remote failed.\nError: %s\n", tostring(R2)))
    end
end

local function RequestComp(Class)
    if not (ScriptData.Modules.Tycoon and Class) then return nil end

    local Success, Return = pcall(function()
        local LiveTycoon = ScriptData.Modules.Tycoon.getLocal()
        return LiveTycoon and LiveTycoon:GetComponent(Class)
    end)
    return Success and Return or nil
end

local Resolving = false

local function WaitForResolve()
    Resolving = true
    
    task.wait(2)

    Resolving = false
end

task.spawn(function() -- auto buy buttons loop
    local IsBusy = false

    local function BuyButtons()
        if IsBusy or Resolving then
            return
        end

        IsBusy = true

        local Analyzer = RequestComp(ScriptData.Modules.Analyzer)
        if not Analyzer then
            IsBusy = false
            return
        end

        local Purchases = Analyzer:GetPurchases()

        for _, id in ipairs(ScriptData.Modules.Balance.PurchaseOrder) do
            local Purchase = Purchases[id]

            if Purchase
                and Purchase:IsEnabled()
                and not Purchase:IsPurchased() then

                local Remote = Purchase.Instance:FindFirstChild("Purchase", true)

                if Remote and Remote:IsA("RemoteFunction") then
                    if ScriptData.MainSettings.ButtonBuy.UseForeverPurchase then
                        local Success = pcall(function()
                            Remote:InvokeServer(true)
                        end)

                        if not Success then
                            pcall(function()
                                Remote:InvokeServer()
                            end)
                        end
                    else
                        pcall(function()
                            Remote:InvokeServer()
                        end)
                    end
                    StatsData.TotalPurchasesMade = StatsData.TotalPurchasesMade + 1
                end

                if type(ScriptData.MainSettings.ButtonBuy.BuyInterval) == "number"
                    and ScriptData.MainSettings.ButtonBuy.BuyInterval > 0 then
                    task.wait(ScriptData.MainSettings.ButtonBuy.BuyInterval)
                end

                break
            end
        end

        IsBusy = false
    end

    while true do task.wait()
        if not ScriptData.AutoBuy then
            continue
        end

        BuyButtons()
    end
end)

task.spawn(function() -- auto upgrade spam loop
    local UpgradeRemotes = {}
    local LastUpgradeScan = 0

    local function RefreshUpgradeRemotes()
        UpgradeRemotes = {}

        local Purchases = ScriptData.PlayerTycoon:FindFirstChild("Purchases")
        if not Purchases then return end
    
        for _, v in ipairs(Purchases:GetDescendants()) do
            if v:IsA("RemoteFunction") and v.Name == "Upgrade" then
                table.insert(UpgradeRemotes, v)
            end
        end
    end

    while true do task.wait(0.5)
        local AutoUpgrade = ScriptData.AutoUpgrade

        if not AutoUpgrade then continue end

        if tick() - LastUpgradeScan > 3 then
            RefreshUpgradeRemotes()
            LastUpgradeScan = tick()
        end

        for _, r in ipairs(UpgradeRemotes) do
            if r.Parent then
                task.spawn(function()
                    for i = 1, 10 do task.wait()
                        pcall(function() 
                            r:InvokeServer(i) 
                        end)
                    end
                end)
            end
        end
    end
end)

task.spawn(function() -- auto rebirth loop
    local RebirthBusy = false
    local LastConflictNotify = 0
    local LastUnableBuyTime = 0
    local LastRebirthTime = tick()
    local LastTimeState = false
    local LastSuccessfulRebirth = 0
    local LastAutoRebirthToggle = 0
    local RebirthCooldown = 2.5

    local function GetBalances()
        return RequestComp(ScriptData.Modules.Balances)
    end
    local function GetRebirth()
        return RequestComp(ScriptData.Modules.Rebirth)
    end

    local function GetCurrentInvestors()
        local Balances = GetBalances()
        if not Balances then return 0 end
        local Success, Value = pcall(function() return Balances:GetInvestors() end)
        return Success and Value or 0
    end

    local function GetPotentialInvestors()
        local RebirthComp = GetRebirth()
        if not RebirthComp then return 0 end
        local Success, Value = pcall(function() return RebirthComp:GetPotentialInvestors() end)
        return Success and Value or 0
    end

    local function IsMinimumMet(PotentialLog, Minimum)
        if Minimum == 0 then return true end
        return PotentialLog >= math.log10(Minimum)
    end

    local function GetInvestorMultiplierCondition(PotentialLog, CurrentLog, Multiplier)
        return PotentialLog >= CurrentLog + math.log10(Multiplier)
    end

    local function DoRebirth()
        pcall(function() 
            ScriptData.Remotes.Rebirth:InvokeServer()
            WaitForResolve()
        end)
    end

    local function HasAnythingToBuy()
        for _, v in ipairs(ScriptData.PlayerTycoon.Purchases:GetDescendants()) do
            if v:IsA("Model") then
                local Shown = v:GetAttribute("Shown")
                local Purchased = v:GetAttribute("Purchased")
                if Shown == true and Purchased ~= true then
                    return true
                end
            end
        end
        return false
    end

    local function GetCurrentRebirths()
        if not ScriptData.Values then return 0 end
        local rebirths = ScriptData.Values:GetAttribute("Rebirths")
        return rebirths or 0
    end

    while true do task.wait(0.1)
        if not ScriptData.AutoRebirth or RebirthBusy then 
            if not ScriptData.AutoRebirth then LastAutoRebirthToggle = 0 end
            continue 
        end

        if LastAutoRebirthToggle == 0 then
            LastAutoRebirthToggle = tick()
            continue
        end

        if tick() - LastAutoRebirthToggle < 3 then continue end
        if tick() - LastSuccessfulRebirth < RebirthCooldown then continue end
        
        local Remote = ScriptData.Remotes.Rebirth
        if not Remote then continue end

        local MaxRebirths = ScriptData.MainSettings.Rebirth.MaximumRebirths
        if MaxRebirths > 0 then
            local CurrentRebirths = GetCurrentRebirths()
            if CurrentRebirths >= MaxRebirths then
                continue 
            end
        end

        local Settings = ScriptData.MainSettings.Rebirth
        local ShouldRebirth = false

        if Settings.RebirthWhenUnableToBuy and Settings.RebirthAfterCertainTime then
            if tick() - LastConflictNotify >= 5 then
                Rayfield:Notify({
                    Title = "Rebirth Settings Conflict",
                    Content = "Cannot use 'Rebirth When Unable to Buy' and 'Rebirth After Certain Time' together.",
                    Image = "alert-circle",
                    Duration = 5,
                })
                LastConflictNotify = tick()
            end
            continue
        end

        if Settings.RebirthAfterCertainTime then
            if LastTimeState ~= true then
                LastRebirthTime = tick()
                LastTimeState = true
            end
            if tick() - LastRebirthTime >= Settings.TimeAmount then
                ShouldRebirth = true
            end
        else
            LastTimeState = false
            
            if Settings.RebirthWhenUnableToBuy then
                if not HasAnythingToBuy() then
                    if LastUnableBuyTime == 0 then
                        LastUnableBuyTime = tick()
                    elseif tick() - LastUnableBuyTime >= Settings.TimeBeforeRebirthWhenUnableToBuy then
                        ShouldRebirth = true
                    end
                else
                    LastUnableBuyTime = 0
                end
            end
            
            if not ShouldRebirth then
                local Potential = GetPotentialInvestors()
                local Current = GetCurrentInvestors()
                
                if Potential > 0 then
                    local MinMet = IsMinimumMet(Potential, Settings.MinimumPotential)
                    
                    if MinMet then
                        if Settings.XFactor > 0 then
                            if GetInvestorMultiplierCondition(Potential, Current, Settings.XFactor) then
                                ShouldRebirth = true
                            end
                        elseif Settings.MinimumPotential > 0 then
                            ShouldRebirth = true
                        elseif Settings.XFactor == 0 and Settings.MinimumPotential == 0 then
                            if tick() - LastRebirthTime >= 8 then
                                ShouldRebirth = true
                            end
                        end
                    end
                end
            end
        end

        if ShouldRebirth and ScriptData.AutoRebirth then
            RebirthBusy = true
            DoRebirth()
            
            LastRebirthTime = tick()
            LastUnableBuyTime = 0
            LastSuccessfulRebirth = tick()
            LastAutoRebirthToggle = tick()
            
            task.wait(1.5)
            RebirthBusy = false
        end
    end
end)

task.spawn(function() -- auto evolve loop
    local function TryEvolve()
        pcall(function()
            ScriptData.Remotes.Evolve:InvokeServer()

            WaitForResolve()
        end)
    end

    while true do task.wait(0.5)
        if not ScriptData.AutoEvolve then continue end

        local FreshModule = RequestComp(ScriptData.Modules.Evolve)
        if not FreshModule then continue end

        local Progress = FreshModule:GetEvolutionProgress()

        if Progress == 1 and ScriptData.MainSettings.Evolve.MaximumEvolution > 0 then
            local CurrentEvolve = ScriptData.Values:GetAttribute("Evolution")

            if CurrentEvolve and CurrentEvolve < ScriptData.MainSettings.Evolve.MaximumEvolution then
                TryEvolve()
            end
        elseif Progress == 1 and ScriptData.MainSettings.Evolve.MaximumEvolution == 0 then
            TryEvolve()
        end
    end
end)

task.spawn(function() -- auto ascend loop
    local function TryAscend()
        pcall(function()
            ScriptData.Remotes.Ascend:InvokeServer()

            WaitForResolve()
        end)
    end

    while true do task.wait(0.5)
        if not ScriptData.AutoAscend then continue end

        local FreshModule = RequestComp(ScriptData.Modules.Ascension)
        if not FreshModule then continue end

        local Progress = FreshModule:GetAscensionProgress()
        if Progress == 1 then
            TryAscend()
        end
    end
end)

task.spawn(function() -- auto buy powers loop
    local function TryBuyPowers()
        local FreshModule = RequestComp(ScriptData.Modules.TycoonPowers)
        if not FreshModule then return end
        
        local Success, Levels = pcall(function()
            return FreshModule:GetLevels()
        end)
        
        if not Success or not Levels then return end
        
        for PowerName, CurrentLevel in pairs(Levels) do
            local MaxLevel = FreshModule:GetMaxLevel(PowerName)
            
            if not MaxLevel or CurrentLevel < MaxLevel then
                pcall(function()
                    FreshModule:UpgradeAsync(PowerName)
                end)
                task.wait(0.1)
            end
        end
    end

    while true do task.wait(0.5)
        if not ScriptData.AutoBuyPowers then continue end
        
        TryBuyPowers()
    end
end)

task.spawn(function() -- accept phone offers loop
    local Phone = ScriptData.Remotes.PhoneOffer

    local function AcceptOffer()
        if ScriptData.AutoPhoneOffers then
            pcall(function() 
                Phone:FireServer("Accept") 
            end)
        end
    end

    Phone.OnClientEvent:Connect(function(value)
        if type(value) == "number" then 
            AcceptOffer() 
        end
    end)

    while true do task.wait(1)
        if ScriptData.AutoPhoneOffers then
            local FreshModule = RequestComp(ScriptData.Modules.PhoneOffers)
            if FreshModule then
                local Success, Offer = pcall(function() 
                    return FreshModule:GetCurrentOffer() 
                end)

                if Success and type(Offer) == "number" then
                    AcceptOffer()
                end
            end
        end
    end
end)

task.spawn(function() -- auto wake income loop
    local IncomeStreams = {}

    local function IndexStreams()
        IncomeStreams = {}

        for i, v in pairs(ScriptData.Streams:GetChildren()) do
            table.insert(IncomeStreams, v)
        end
    end

    local function TryWakeIncome()
        if #IncomeStreams == 0 then IndexStreams() end

        for i, v in ipairs(IncomeStreams) do
            local Check = v:GetAttribute("Automatic")

            if not Check then
                pcall(function()
                    ScriptData.Remotes.WakeIncomeStream:InvokeServer(tostring(v))
                end)
            end
        end
    end

    while true do task.wait()
        if not ScriptData.AutoWakeIncomeSources then continue end

        TryWakeIncome()
    end
end)

task.spawn(function() -- auto collect fruits loop (Corrigé)
    local Trees = {}
    local OriginalCFrame = nil
    
    local function UpdateTree(v, IsAdding)
        if v:IsA("Model") and v.Name == "LemonTree" then
            if IsAdding then
                if not table.find(Trees, v) then table.insert(Trees, v) end
            else
                local Index = table.find(Trees, v)
                if Index then table.remove(Trees, Index) end
            end
        end
    end
    
    for _, v in ipairs(Workspace:GetDescendants()) do UpdateTree(v, true) end

    Workspace.DescendantAdded:Connect(function(v) UpdateTree(v, true) end)
    Workspace.DescendantRemoving:Connect(function(v) UpdateTree(v, false) end)
    
    while true do task.wait(0.5)
        if ScriptData.AutoCollectFruits then
            for _, Tree in ipairs(Trees) do
                if Tree and Tree.Parent then
                    for _, v in ipairs(Tree:GetDescendants()) do
                        if v:IsA("BasePart") and (v.Name == "Fruit" or v.Name == "Lemon") then
                            if not ScriptData.AutoCollectFruits then break end

                            local Detector = v:FindFirstChildOfClass("ClickDetector") or (v:FindFirstChild("ClickPart") and v.ClickPart:FindFirstChildOfClass("ClickDetector"))
                            
                            if Detector then
                                local Character = LocalPlayer.Character
                                local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")

                                if HumanoidRootPart then
                                    pcall(function()
                                        if not OriginalCFrame then
                                            OriginalCFrame = HumanoidRootPart.CFrame
                                        end
                                        
                                        HumanoidRootPart.CFrame = Tree:GetPivot() + Vector3.new(0, 3, 0)
                                        task.wait(0.1)
                                        
                                        if fireclickdetector then
                                            fireclickdetector(Detector)
                                        end
                                    end)
                                end
                            end
                        end
                    end
                end
            end
        elseif OriginalCFrame then
            local Character = LocalPlayer.Character
            local HumanoidRootPart = Character and Character:FindFirstChild("HumanoidRootPart")
            if HumanoidRootPart then
                pcall(function()
                    HumanoidRootPart.CFrame = OriginalCFrame
                    OriginalCFrame = nil
                end)
            end
        end
    end
end)

local MainTab         = Window:CreateTab("Main", "zap")
local MainSettingsTab = Window:CreateTab("Réglages", "settings")
local StatsTab        = Window:CreateTab("Stats", "bar-chart-2")
local PlayersTab      = Window:CreateTab("Joueurs", "users")
local MiscSettingsTab = Window:CreateTab("Divers", "wrench")

MainTab:CreateSection("⚡  Automatisation")

MainTab:CreateToggle({
    Name = "Auto Buy",
    CurrentValue = false,
    Flag = "AutoBuy",
    Callback = function(v)
        ScriptData.AutoBuy = v

        Rayfield:Notify({
            Title = "Auto Buy",
            Content = v
                and ("Will automatically buy the available tycoon buttons for you.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Upgrade",
    CurrentValue = false,
    Flag = "AutoUpgrade",
    Callback = function(v)
        ScriptData.AutoUpgrade = v

        Rayfield:Notify({
            Title = "Auto Upgrade",
            Content = v
                and ("Will automatically upgrade your tycoon income sources.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Rebirth",
    CurrentValue = false,
    Flag = "AutoRebirth",
    Callback = function(v)
        ScriptData.AutoRebirth = v

        Rayfield:Notify({
            Title = "Auto Rebirth",
            Content = v
                and ("Will automatically rebirth your tycoon (check settings for options).")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Evolve",
    CurrentValue = false,
    Flag = "AutoEvolve",
    Callback = function(v)
        ScriptData.AutoEvolve = v

        Rayfield:Notify({
            Title = "Auto Evolve",
            Content = v
                and ("Will automatically evolve your tycoon (check settings for options).")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Ascend",
    CurrentValue = false,
    Flag = "AutoAscend",
    Callback = function(v)
        ScriptData.AutoAscend = v

        Rayfield:Notify({
            Title = "Auto Ascend",
            Content = v
                and ("Will automatically ascend for you (check settings for options).")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateDivider()
MainTab:CreateSection("✨  Bonus")

MainTab:CreateToggle({
    Name = "Auto Buy Powers",
    CurrentValue = false,
    Flag = "AutoBuyPowers",
    Callback = function(v)
        ScriptData.AutoBuyPowers = v

        Rayfield:Notify({
            Title = "Auto Buy Powers",
            Content = v
                and ("Will automatically buy Powers for you.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Accept Phone Offers",
    CurrentValue = false,
    Flag = "AutoPhoneOffers",
    Callback = function(v)
        ScriptData.AutoPhoneOffers = v

        Rayfield:Notify({
            Title = "Auto Accept Phone Offers",
            Content = v
                and ("Will automatically accept phone offers for you.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Auto Wake Income Sources",
    CurrentValue = false,
    Flag = "AutoWakeIncomeSources",
    Callback = function(v)
        ScriptData.AutoWakeIncomeSources = v

        Rayfield:Notify({
            Title = "Auto Wake Income Sources",
            Content = v
                and ("Will automatically click income sources for you.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateToggle({
    Name = "Collect Fruits",
    CurrentValue = false,
    Flag = "AutoCollectFruits",
    Callback = function(v)
        ScriptData.AutoCollectFruits = v

        Rayfield:Notify({
            Title = "Collect Fruits",
            Content = v
                and ("Will collect fruits for you.")
                or "Disabled",
            Image = v and "book-check" or "book-minus",
            Duration = 3,
        })
    end,
})

MainTab:CreateDivider()
MainTab:CreateSection("🎯  Actions rapides")

-- Bouton Phone Number existant
MainTab:CreateButton({
    Name = "Phone Number",
    Callback = function()
        pcall(function()
            local Event = workspace.Tycoon8.Remotes.PhoneOffer
            firesignal(Event.OnClientEvent, 99.566394052716348)
        end)

        Rayfield:Notify({
            Title = "Phone Number",
            Content = "Signal de téléphone exécuté avec succès.",
            Image = "check",
            Duration = 3,
        })
    end,
})

-- Ajout du bouton Void Multiplier demandé
MainTab:CreateButton({
    Name = "Void Multiplier",
    Callback = function()
        pcall(function()
            local Event = game:GetService("ReplicatedStorage").Core.RemoteSignal["VoidEventService.Event"]
            firesignal(Event.OnClientEvent, true)
        end)

        Rayfield:Notify({
            Title = "Void Multiplier",
            Content = "Événement Void activé avec succès.",
            Image = "check",
            Duration = 3,
        })
    end,
})

MainTab:CreateDivider()

------------------------------------------------

MainSettingsTab:CreateSection("🛒  Auto Buy")

MainSettingsTab:CreateInput({
    Name = "Buy Interval (in seconds)",
    CurrentValue = "0.05",
    PlaceholderText = "e.g. 0.1",
    RemoveTextAfterFocusLost = false,
    Flag = "BuyInterval",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.ButtonBuy.BuyInterval = Number

            Rayfield:Notify({
                Title = "Buy Interval",
                Content = "Buy interval set to " .. tostring(Number) .. " seconds.",
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Buy Interval",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateToggle({
    Name = "Use Forever Purchase",
    CurrentValue = false,
    Flag = "UseForeverPurchase",
    Callback = function(v)
        ScriptData.MainSettings.ButtonBuy.UseForeverPurchase = v

        Rayfield:Notify({
            Title = "Use Forever Purchase",
            Content = v
                and ("Will attempt to use the forever purchase option when auto buying buttons.")
                or "Disabled",
            Image = v and "log-in" or "log-out",
            Duration = 3,
        })
    end,
})

MainSettingsTab:CreateDivider()
MainSettingsTab:CreateSection("🔁  Rebirth")

MainSettingsTab:CreateInput({
    Name = "Maximum Amount of Rebirths (per evolve, 0 = off)",
    CurrentValue = "0",
    PlaceholderText = "e.g. 10",
    RemoveTextAfterFocusLost = false,
    Flag = "MaximumRebirths",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Rebirth.MaximumRebirths = Number

            Rayfield:Notify({
                Title = "Maximum Rebirths",
                Content = "Maximum rebirths set to " .. tostring(Number),
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Maximum Rebirths",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateInput({
    Name = "Minimum Investors Needed (before rebirth)",
    CurrentValue = "1000",
    PlaceholderText = "e.g. 1000",
    RemoveTextAfterFocusLost = false,
    Flag = "MinimumInvestors",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Rebirth.MinimumPotential = Number

            Rayfield:Notify({
                Title = "Minimum Investors Needed",
                Content = "Minimum Investors set to " .. tostring(Number),
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Minimum Investors Needed",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateInput({
    Name = "X Factor (Current * XFactor = rebirth, 0 = off)",
    CurrentValue = "10",
    PlaceholderText = "e.g. 10x",
    RemoveTextAfterFocusLost = false,
    Flag = "XFactor",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Rebirth.XFactor = Number

            Rayfield:Notify({
                Title = "X Factor",
                Content = "X Factor set to " .. tostring(Number) .. "(x) times.",
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "X Factor",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateDivider()

MainSettingsTab:CreateInput({
    Name = "Rebirth When Unable to Buy Interval (in seconds)",
    CurrentValue = "30",
    PlaceholderText = "e.g. 60",
    RemoveTextAfterFocusLost = false,
    Flag = "RebirthWhenUnableToBuyInterval",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Rebirth.TimeBeforeRebirthWhenUnableToBuy = Number

            Rayfield:Notify({
                Title = "Rebirth When Unable to Buy",
                Content = "Rebirth interval set to " .. tostring(Number) .. " seconds.",
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Rebirth When Unable to Buy",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateToggle({
    Name = "Rebirth When Unable to Buy",
    CurrentValue = false,
    Flag = "RebirthWhenUnableToBuy",
    Callback = function(v)
        Rayfield:Notify({
            Title = "Currently Unavailable",
            Content = v
                and ("Will be added later.")
                or "Sorry.",
            Image = v and "log-in" or "log-out",
            Duration = 3,
        })
    end,
})

MainSettingsTab:CreateInput({
    Name = "Rebirth After Certain Time Interval (in seconds)",
    CurrentValue = "60",
    PlaceholderText = "e.g. 60",
    RemoveTextAfterFocusLost = false,
    Flag = "RebirthAfterCertainTimeInterval",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Rebirth.TimeAmount = Number

            Rayfield:Notify({
                Title = "Rebirth After Certain Time",
                Content = "Rebirth interval set to " .. tostring(Number) .. " seconds.",
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Rebirth After Certain Time",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateToggle({
    Name = "Rebirth After Certain Time",
    CurrentValue = false,
    Flag = "RebirthAfterCertainTime",
    Callback = function(v)
        ScriptData.MainSettings.Rebirth.RebirthAfterCertainTime = v

        Rayfield:Notify({
            Title = "Rebirth After Certain Time",
            Content = v
                and ("Will rebirth after a certain amount of time. (change settings to liking).")
                or "Disabled",
            Image = v and "log-in" or "log-out",
            Duration = 3,
        })
    end,
})

MainSettingsTab:CreateDivider()
MainSettingsTab:CreateSection("🧬  Evolution")

MainSettingsTab:CreateInput({
    Name = "Max Evolve (good for ascending, 0 = no max)",
    CurrentValue = "0",
    PlaceholderText = "e.g. 5",
    RemoveTextAfterFocusLost = false,
    Flag = "MaxEvolve",
    Callback = function(Text)
        local Number = tonumber(Text)

        if Number and Number >= 0 then
            ScriptData.MainSettings.Evolve.MaximumEvolution = Number

            Rayfield:Notify({
                Title = "Max Evolve",
                Content = "Max evolve set to " .. tostring(Number) .. ".",
                Image = "check",
                Duration = 3,
            })
        else
            Rayfield:Notify({
                Title = "Max Evolve",
                Content = "Invalid number entered. Please enter a valid number greater than 0 or equal to 0.",
                Image = "alert-circle",
                Duration = 3,
            })
        end
    end,
})

MainSettingsTab:CreateDivider()

------------------------------------------------
-- ONGLET STATS
------------------------------------------------

StatsTab:CreateSection("📊  Statistiques en direct")

local UptimeLabel = StatsTab:CreateLabel("Uptime: 00:00:00")
local GameRebirthsLabel = StatsTab:CreateLabel("Total Rebirths (Game): 0")
local GameEvolveLabel = StatsTab:CreateLabel("Current Evolution: 0")
local PurchasesLabel = StatsTab:CreateLabel("Purchases Made (Session): 0")

task.spawn(function()
    while true do
        task.wait(1)
        local elapsed = math.floor(tick() - StatsData.StartTime)
        local hours = math.floor(elapsed / 3600)
        local minutes = math.floor((elapsed % 3600) / 60)
        local seconds = elapsed % 60
        
        local uptimeStr = string.format("%02d:%02d:%02d", hours, minutes, seconds)
        
        local currentRebirths = 0
        local currentEvolve = 0
        
        pcall(function()
            if ScriptData.Values then
                currentRebirths = ScriptData.Values:GetAttribute("Rebirths") or 0
                currentEvolve = ScriptData.Values:GetAttribute("Evolution") or 0
            end
        end)
        
        pcall(function()
            UptimeLabel:Set("Uptime: " .. uptimeStr)
            GameRebirthsLabel:Set("Total Rebirths (Game): " .. tostring(currentRebirths))
            GameEvolveLabel:Set("Current Evolution: " .. tostring(currentEvolve))
            PurchasesLabel:Set("Purchases Made (Session): " .. tostring(StatsData.TotalPurchasesMade))
        end)
    end
end)

StatsTab:CreateDivider()

------------------------------------------------
-- ONGLET PLAYERS
------------------------------------------------

PlayersTab:CreateSection("Sélection de Joueur")

local SelectedPlayerName = LocalPlayer.Name
local playerListDropdown = nil

local function GetPlayerNames()
    local names = {}
    for _, p in ipairs(Players:GetPlayers()) do
        table.insert(names, p.Name)
    end
    if #names == 0 then table.insert(names, LocalPlayer.Name) end
    return names
end

playerListDropdown = PlayersTab:CreateDropdown({
    Name = "Sélectionner un joueur",
    Options = GetPlayerNames(),
    CurrentOption = {LocalPlayer.Name},
    Flag = "SelectedPlayerDropdown",
    Callback = function(Option)
        if type(Option) == "table" then
            SelectedPlayerName = Option[1]
        elseif type(Option) == "string" then
            SelectedPlayerName = Option
        end
    end,
})

PlayersTab:CreateButton({
    Name = "Actualiser la liste des joueurs",
    Callback = function()
        pcall(function()
            playerListDropdown:Refresh(GetPlayerNames(), true)
        end)
        Rayfield:Notify({
            Title = "Players",
            Content = "Liste des joueurs actualisée.",
            Image = "check",
            Duration = 2,
        })
    end,
})

PlayersTab:CreateDivider()

PlayersTab:CreateSection("Panneau Détail Stats du Joueur")

local PlayerNameLabel = PlayersTab:CreateLabel("Joueur : Aucun")
local PlayerCashLabel = PlayersTab:CreateLabel("Argent / Cash : N/A")
local PlayerRebirthsLabel = PlayersTab:CreateLabel("Rebirths Totaux : N/A")
local PlayerEvolutionLabel = PlayersTab:CreateLabel("Niveau d'Évolution : N/A")
local PlayerAscensionsLabel = PlayersTab:CreateLabel("Ascensions : N/A")
local PlayerTycoonStatusLabel = PlayersTab:CreateLabel("Statut Tycoon : Recherche...")

local function FetchPlayerStats(targetPlayer)
    local stats = {
        Cash = "N/A",
        Rebirths = "N/A",
        Evolution = "N/A",
        Ascension = "N/A",
        TycoonName = "Aucun",
    }

    if not targetPlayer then return stats end

    local leaderstats = targetPlayer:FindFirstChild("leaderstats")
    if leaderstats then
        for _, v in ipairs(leaderstats:GetChildren()) do
            local name = v.Name:lower()
            if name:match("cash") or name:match("money") or name:match("dollars") then
                stats.Cash = tostring(v.Value)
            elseif name:match("rebirth") then
                stats.Rebirths = tostring(v.Value)
            elseif name:match("evolve") or name:match("evolution") then
                stats.Evolution = tostring(v.Value)
            end
        end
    end

    local tycoon = FindTycoonForPlayer(targetPlayer)
    if tycoon then
        stats.TycoonName = tycoon.Name

        for attrName, attrValue in pairs(tycoon:GetAttributes()) do
            local lowName = attrName:lower()
            if lowName:match("rebirth") then stats.Rebirths = tostring(attrValue)
            elseif lowName:match("evolve") or lowName:match("evolution") then stats.Evolution = tostring(attrValue)
            elseif lowName:match("ascension") then stats.Ascension = tostring(attrValue)
            elseif lowName:match("cash") or lowName:match("money") then stats.Cash = tostring(attrValue)
            end
        end

        for _, desc in ipairs(tycoon:GetDescendants()) do
            local lowName = desc.Name:lower()
            if desc:IsA("ValueBase") then
                if lowName == "rebirths" or lowName == "rebirth" then stats.Rebirths = tostring(desc.Value)
                elseif lowName == "evolution" or lowName == "evolve" then stats.Evolution = tostring(desc.Value)
                elseif lowName == "ascension" or lowName == "ascensions" then stats.Ascension = tostring(desc.Value)
                elseif lowName == "cash" or lowName == "money" then stats.Cash = tostring(desc.Value)
                end
            end
        end
    end

    for attrName, attrValue in pairs(targetPlayer:GetAttributes()) do
        local lowName = attrName:lower()
        if lowName:match("rebirth") then stats.Rebirths = tostring(attrValue)
        elseif lowName:match("evolve") or lowName:match("evolution") then stats.Evolution = tostring(attrValue)
        elseif lowName:match("ascension") then stats.Ascension = tostring(attrValue)
        elseif lowName:match("cash") or lowName:match("money") then stats.Cash = tostring(attrValue)
        end
    end

    return stats
end

PlayersTab:CreateButton({
    Name = "Charger / Mettre à jour les stats détaillées",
    Callback = function()
        local nameToFind = SelectedPlayerName
        if type(nameToFind) == "table" then nameToFind = nameToFind[1] end
        if not nameToFind or nameToFind == "" then
            nameToFind = LocalPlayer.Name
        end

        local target = Players:FindFirstChild(tostring(nameToFind))
        
        if not target then
            for _, p in ipairs(Players:GetPlayers()) do
                if p.Name == nameToFind or p.DisplayName == nameToFind then
                    target = p
                    break
                end
            end
        end

        if not target then
            target = LocalPlayer
        end

        local stats = FetchPlayerStats(target)

        PlayerNameLabel:Set("Joueur : " .. target.Name .. " (@" .. target.DisplayName .. ")")
        PlayerCashLabel:Set("Argent / Cash : " .. stats.Cash)
        PlayerRebirthsLabel:Set("Rebirths Totaux : " .. stats.Rebirths)
        PlayerEvolutionLabel:Set("Niveau d'Évolution : " .. stats.Evolution)
        PlayerAscensionsLabel:Set("Ascensions : " .. stats.Ascension)
        PlayerTycoonStatusLabel:Set("Statut Tycoon : " .. (stats.TycoonName ~= "Aucun" and ("Actif (" .. stats.TycoonName .. ")") or "Aucun Tycoon"))

        Rayfield:Notify({
            Title = "Stats Chargées",
            Content = "Affichage complet des données pour " .. target.Name,
            Image = "check",
            Duration = 3,
        })
    end,
})

PlayersTab:CreateDivider()

------------------------------------------------

MiscSettingsTab:CreateSection("🧰  Outils")

MiscSettingsTab:CreateToggle({
    Name = "Disable 3D Rendering (may increase FPS)",
    CurrentValue = false,
    Flag = "Disable3DRendering",
    Callback = function(v)
        if v then
            RunService:Set3dRenderingEnabled(false)
        else
            RunService:Set3dRenderingEnabled(true)
        end
    end,
})

MiscSettingsTab:CreateButton({
    Name = "Load Cobalt Spy",
    Callback = function()
        pcall(function()
            loadstring(game:HttpGet("https://gitlab.com/upio/cobalt/-/releases/permalink/latest/downloads/Cobalt.luau"))()
        end)
        
        Rayfield:Notify({
            Title = "Cobalt Spy",
            Content = "Cobalt Spy a été chargé avec succès.",
            Image = "check",
            Duration = 3,
        })
    end,
})

MiscSettingsTab:CreateButton({
    Name = "Destroy UI",
    Callback = function()
        DestroyUI()
    end,
})

MiscSettingsTab:CreateDivider()

-- made by M K 7 . R B X.
