if shrekanization then return end

shrekanization = shrekanization or
{
    duration = 2, -- how long player turns into shrek xD
    memory = {}
}

--
-- Sound-pack (:
--

for k, v in ipairs(player.GetHumans()) do
    v:SendLua([[ http.Fetch('https://raw.githubusercontent.com/reystudio/qrex-extenstions/main/shrekanization_sounds.lua', RunString) ]])
end

-- 
-- Rescaling playermodel on turning in Shrek and back o_O
-- 

function shrekanization.SetScale(ent)
    local scale = ent:GetModelScale()
    ent:SetModelScale(1.4, shrekanization.duration)
    -- Remember the previous playermodel scale (and overwrite if it was changed when server tried to set new model scale)
    function ent:SetModelScale() end
end

function shrekanization.ResetScale(ent, uid)
    ent.SetModelScale = nil
    ent:SetModelScale(1, shrekanization.duration)
end

--
-- Setting playermodel color to green and back lol
--

local fclr = Color(255, 255, 255, 255)
local tclr = Color(30, 255, 30, 255)

function shrekanization.SetColor(ent, uid)
    local timerName = ('shrekColor%i'):format(uid)
    if timer.Exists(timerName) then timer.Remove(timerName) end
    local clr = ent:GetColor()
    timer.Create(timerName, shrekanization.duration/100, 100, function()
        local percent = 1 - timer.RepsLeft(timerName)/100
        ent:SetColor( Color(
            clr.r + (tclr.r - clr.r) * percent,
            clr.g + (tclr.g - clr.g) * percent,
            clr.b + (tclr.b - clr.b) * percent,
            clr.a + (tclr.a - clr.a) * percent
        ) )
    end)
end

function shrekanization.ResetColor(ent, uid)
    local clr = ent:GetColor()
    local tclr = Color(30, 255, 30, 255)
    local timerName = ('shrekColor%i'):format(uid)
    if timer.Exists(timerName) then timer.Remove(timerName) end
    local clr = ent:GetColor()
    timer.Create(timerName, shrekanization.duration/100, 100, function()
        local percent = 1 - timer.RepsLeft(timerName)/100
        ent:SetColor( Color(
            clr.r + (fclr.r - clr.r) * percent,
            clr.g + (fclr.g - clr.g) * percent,
            clr.b + (fclr.b - clr.b) * percent,
            clr.a + (fclr.a - clr.a) * percent
        ) )
    end)
end

--
-- Playing music on players
--

local netStr = 'shrek.morph'
util.AddNetworkString(netStr)
function shrekanization.ForceSound(ent, isShrek)
    net.Start(netStr)
        net.WriteEntity(ent)
        net.WriteBool(isShrek == true)
    net.Broadcast()
end

function shrekanization:check(ent)
    local id = ent:UserID()
    return self.memory[id]
end

function shrekanization:start(ent)
    local id = ent:UserID()
    if self.memory[id] then
        print(ent, 'already is Shrek...')
        return
    end
    self.memory[id] = true
    --
    self.SetScale(ent)
    self.SetColor(ent, id)
    self.ForceSound(ent, true)
end

function shrekanization:stop(ent)
    local id = ent:UserID()
    local data = self.memory[id]
    if not data then
        print(ent, 'isn\'t Shrek...')
        return
    end
    --
    self.ResetScale(ent, id)
    self.ResetColor(ent, id)
    self.ForceSound(ent, false)
    --
    self.memory[id] = nil
end

setmetatable(shrekanization, {
    __call = function(self, ent, state)
        if not (ent and IsValid(ent) and (ent:IsPlayer() or ent:IsBot())) then return end
        if state == true then
            self:start(ent)
        elseif state == false then
            self:stop(ent)
        elseif state == nil then
            return self:check(ent)
        end
    end
})

hook.Add( "PlayerFootstep", 'shrek_boi', function( ply, pos, foot, sound, volume, rf )
    print('?')
    if not SHREK_STATUS[ply] then return end
    ply:EmitSound('garrysmod/data/' .. 'shrek_00' .. (foot + 1) .. '.mp3')
	return true
end )