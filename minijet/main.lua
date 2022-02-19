if MINIJET_PPL then
    for k, v in next, MINIJET_PPL.Active do
        MINIJET_PPL:stop(v)
    end
end

MINIJET_PPL = {
    Active = {}
}

setmetatable(MINIJET_PPL, {
    __call = function(self, ply, mode)
        if ply and IsValid(ply) then
            if mode then
                if not self.Active[ply] then
                    self:start(ply)
                    print(ply, 'became a Jet!')
                else    
                    print(ply, 'is already a Jet!')
                end
            else
                if self.Active[ply] then
                    self:stop(ply)
                    print(ply, 'became a regular guy')
                else
                    print(ply, 'isn\'t a Jet!')
                end
            end
        end
    end
})

local m = MINIJET_PPL

m.jetModel = 'models/xqm/jetbody3.mdl'
m.pilotModel = 'models/player/urban.mdl'

--
-- Client-side mini-jet visual part
--

util.AddNetworkString('mj.main')

function m.Run(ply)
    local viewers = player.GetAll()
    table.RemoveByValue(viewers, ply)

    net.Start 'mj.main'
        net.WriteBit(true) -- 1: minijet or 0: regular klainer
        net.WriteBit(false) -- 0 if viewer or 1 if target
        net.WriteEntity(ply)
    net.Send(viewers)

    net.Start 'mj.main'
        net.WriteBit(true)
        net.WriteBit(true)
    net.Send(ply)
end

function m.Stop(ply)
    local viewers = player.GetAll()
    table.RemoveByValue(viewers, ply)

    net.Start 'mj.main'
        net.WriteBit(false) -- 1: minijet or 0: regular klainer
        net.WriteBit(false) -- 0 if viewer or 1 if target
        net.WriteEntity(ply)
    net.Send(viewers)

    net.Start 'mj.main'
        net.WriteBit(false)
        net.WriteBit(true)
    net.Send(ply)
end

function m:start(ply)
    ply.jetOldMdl = ply:GetModel()
    --ply:SetModel(self.pilotModel)
    ply:SetMoveType(MOVETYPE_FLY)
    ply:SetRenderMode(4)
    ply:SetColor(Color(0, 0, 0, 1))
    ply:SetModelScale(.1)
    self.Active[ply] = true
    self.Run(ply)
end

function m:stop(ply)
    --ply:SetModel(ply.jetOldMdl)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetRenderMode(0)
    ply:SetColor(Color(0, 0, 0, 0)) 
    ply:SetModelScale(1)
    self.Active[ply] = nil
    self.Stop(ply)
end

local function ForceModel(user)
    local dir = user:EyeAngles()
    if user:KeyDown(IN_WALK) then
        user:SetVelocity(-(user:GetVelocity()/50))
        return
    end
    local boost = 0.5
    if user:KeyDown(IN_SPEED) then
        boost = 1
    end
    if user:KeyDown(IN_JUMP) then
        user:SetVelocity( dir:Up() * 20 * boost )
    end
    if user:KeyDown(IN_DUCK) then
        user:SetVelocity( dir:Up() * -20 * boost )
    end
    if user:KeyDown(IN_FORWARD) then
        user:SetVelocity( dir:Forward() * 20 * boost )
    end
    if user:KeyDown(IN_BACK) then
        user:SetVelocity( dir:Forward() * -20 * boost )
    end
    if user:KeyDown(IN_MOVELEFT) then
        user:SetVelocity( dir:Right() * -20 * boost )
    end
    if user:KeyDown(IN_MOVERIGHT) then
        user:SetVelocity( dir:Right() * 20 * boost )
    end
end

function m.Think()
    if not MINIJET_PPL then
        hook.Remove('mj.tick')
        return
    end
    local self = MINIJET_PPL
    for k, v in next, self.Active do
        if k and IsValid(k) then
            if k:GetMoveType() ~= MOVETYPE_FLY then k:SetMoveType(MOVETYPE_FLY) end
            ForceModel(k)
        end
    end
end

hook.Add('Think', 'mj.tick', m.Think)