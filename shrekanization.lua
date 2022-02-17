-- if shrekanization then return end

shrekanization = shrekanization or
{
    duration = 2, -- how long player turns into shrek xD
    memory = {}
}

--
-- Sound-pack (:
--

local soundsDownloader = [[
    local soundUrls = {
        shrek_001 = 'https://github.com/reystudio/audio/blob/main/shrek_001.txt?raw=true',
        shrek_002 = 'https://github.com/reystudio/audio/blob/main/shrek_002.txt?raw=true',
        shrek_003 = 'https://github.com/reystudio/audio/blob/main/shrek_003.txt?raw=true',
    }
    local lastKey, httperr, httpsucc
    SHRSND = {}
    local function nextSound(lk)
        lastKey = next(soundUrls, lk)
        if not lastKey then print('done!', table.Count(SHRSND), 'sounds downloaded!') return end
        http.Fetch(soundUrls[lastKey], httpsucc, httperr)
    end
    httperr = function (...) nextSound(lastKey) end
    httpsucc = function (body, size, h, code)
        local name = lastKey .. '.mp3'
        file.Write(name, body)
        SHRSND[lastKey] = name
        nextSound(lastKey)
    end
    nextSound()
    local function pl(ent, name)
        if not (ent and IsValid(ent)) then print('invalid ent', ent) return end
        if SHRSND[name] then
            sound.PlayFile(SHRSND[name], '3d', function(st, ...)
                if IsValid(st) then
                    st:SetPos(ent)
                else
                    print(...)
                end
            end)
        else
            timer.Simple(1, function() pl(ent, name) end)
            return
        end
    end
    net.Receive('shrek.morph', function(l)
        local ent = net.ReadEntity()
        pl(ent, SHRSND)
    end)
]]



-- 
-- Rescaling playermodel on turning in Shrek and back o_O
-- 

function shrekanization.SetScale(ent)
    local scale = ent:GetModelScale()
    ent:SetModelScale(1.4, shrekanization.duration)
    -- Remember the previous playermodel scale (and overwrite if it was changed when server tried to set new model scale)
    function ent:SetModelScale(newScale, delta)
        local id = self:UserID()
        if shrekanization.memory[id] then
            shrekanization.memory[id]['scale'] = newScale
        end
    end
    return scale
end

function shrekanization.ResetScale(ent, uid)
    ent.SetModelScale = nil
    ent:SetModelScale(shrekanization.memory[uid]['scale'] or 1, shrekanization.duration)
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
        -- net.WriteBool(isShrek == true)
    net.Broadcast()
end

function shrekanization:start(ent)
    local id = ent:UserID()
    if self.memory[id] then
        print(ent, 'already is Shrek...')
        return
    end
    local data = self.memory[id] or {}
    self.memory[id] = data
    --
    data.scale =
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
    -- self.ForceSound(ent, false)
    --
    self.memory[id] = nil
end

setmetatable(shrekanization, {
    __call = function(self, ent, state)
        if not (ent and IsValid(ent) and (ent:IsPlayer() or ent:IsBot())) then return end
        if state == true then
            self:start(ent)
        else
            self:stop(ent)
        end
    end
})