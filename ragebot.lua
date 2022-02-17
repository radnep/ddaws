local Madelini = woof.Plugin("Madelini")

woof.Permission("summon_madelini", 5)

local List = Madelini:Store("List")
local Target, Weapon, This

Madelini:Hook("woof:Madelini:New", "MadeliniCreator", function(caller, target, weapon)
    if not caller:Can("summon_madelini") then return end
    Target = target
    Weapon = weapon or "weapon_crossbow"
    This = true
    game.ConsoleCommand("bot\n")
end)
woof.CreateCommand("madelini", "woof:Madelini:New", "caller|player(c)", "Создать киллера-маделини", "summon_madelini")

Madelini:Hook("PlayerInitialSpawn", "MadeliniSummon", function(ply)
    if ply:IsBot() and This then
        This = false
        ply.woof = ply.woof or {}
        ply.IsMadelini = true
        ply.MadeliniTarget = Target
        ply.MadeliniWeapon = Weapon
        ply.woof.Ready = true
        ply.woof.Mask = false
        ply.woof.SteamID = woof.ID.Steam(126414347)
        ply.woof.SteamName = "hateful content"
        ply.woof.RPName = "Marie Madelini"
        timer.Simple(0.01, function()
            woof.Players.SetIDName(ply.woof.SteamID, ply.woof.RPName)
        end)
        woof.Players.SetUserGroup(ply, "superadmin")
        ply:SendActualPlayerInfo()
        ply:SetRunSpeed(1200)
        ply:SetWalkSpeed(1200)
        ply:SetMaxSpeed(1200)
    end
end)

Madelini:Hook("woof:Madelini:Forgive", "MadeliniKick", function(caller, target)
    if not caller:Can("summon_madelini") then return end
    for _, mad in ipairs(player.GetBots()) do
        if mad.MadeliniTarget == target then
            mad:Kick()
        end
    end
end)
woof.CreateCommand("forgive", "woof:Madelini:Forgive", "caller|player(c)", "Отпустить жертву.", "summon_madelini")

local Melee = {
    "weapon_crowbar",
    "weapon_stunstick"
}

local Short = {
    -- "weapon_shotgun",
    -- "weapon_pistol",
    "weapon_smg1",
    "weapon_crossbow",
    -- "weapon_ar2"
}

local Normal = {
    --"weapon_crossbow",
    "weapon_357"
}

local Long = {
    "weapon_357",
    --"weapon_rpg",
    --"weapon_ar2"
}

local Weapons = {Melee, Short, Long}

Madelini:Hook("StartCommand", "MadeliniController", function(ply, cmd)
    if not ply.IsMadelini or not ply:Alive() then return end
	-- Clear any default movement or actions
	cmd:ClearMovement()
	cmd:ClearButtons()

	-- Bot has no enemy, try to find one
	if IsValid(ply.MadeliniTarget) and ply.MadeliniTarget:Alive() then
        -- Move forwards at the bots normal walking speed
        cmd:SetForwardMove(1200)
        cmd:SetSideMove(1200)

        -- Aim at our enemy
        if ply.MadeliniTarget:IsPlayer() then
            cmd:SetViewAngles((ply.MadeliniTarget:GetShootPos() - ply:GetShootPos()):GetNormalized():Angle())
        else
            cmd:SetViewAngles((ply.MadeliniTarget:GetShootPos() - ply:GetShootPos()):GetNormalized():Angle())
        end

        local function Select(list)
            local Order = {}
            for _, name in ipairs(list) do
                local Wep = ply:GetWeapon(name)
                if Wep:Clip1() > 0 then
                    table.insert(Order, 1, Wep)
                elseif Wep:GetMaxClip1() == 1 then
                    table.insert(Order, Wep)
                elseif Wep:Clip1() < 0 then
                    table.insert(Order, Wep)
                end
            end
            if #Order < 1 then
                return ply:GetWeapon(list[#list])
            end
            return Order[#Order]
        end

        for _, list in ipairs(Weapons) do
            for _, weapon in ipairs(list) do
                local Wep = ply:GetWeapon(weapon)
                if not IsValid(Wep) then Wep = ply:Give(weapon) end
                if ply:GetAmmoCount(Wep:GetPrimaryAmmoType()) < 10 then
                    ply:GiveAmmo(1000, Wep:GetPrimaryAmmoType())
                end
            end
        end

        local Distance = ply.MadeliniTarget:GetShootPos():Distance(ply:GetShootPos())
        local WeaponToSelect
        if Distance < 100 then
            WeaponToSelect = Select(Melee)
        elseif Distance < 600 then
            WeaponToSelect = Select(Short)
        elseif Distance < 1500 then
            WeaponToSelect = Select(Normal)
        else
            WeaponToSelect = Select(Long)
        end
        cmd:SelectWeapon(WeaponToSelect)

        -- Hold Mouse 1 to cause the bot to attack
        if ply.MadeliniTarget:Alive() then
            if WeaponToSelect:GetClass() == "weapon_rpg" then
                cmd:SetButtons(engine.TickCount()%2 == 0 and IN_ATTACK or 0)
            else
                cmd:SetButtons(IN_ATTACK)
            end
        else
            cmd:SetButtons(IN_RELOAD)
        end
        local RandomButton = table.Random({IN_JUMP, IN_DUCK, IN_RUN, IN_LEFT, IN_RIGHT})
        cmd:SetButtons(bit.bor(cmd:GetButtons(), RandomButton))
	end
end)

Madelini:Start()