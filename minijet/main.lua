do
    local ENT = {}
    ENT.Base = "base_anim"
    ENT.PrintName = "Rocket"
    ENT.Editable = false
    ENT.Spawnable = false
    ENT.AdminOnly = false
    ENT.RenderGroup = RENDERGROUP_TRANSCULENT
    local sndtrail = Sound("Missile.Accelerate")
    function ENT:Initialize()
        self:SetModel 'models/weapons/w_missile.mdl'
        self.Entity:SetMoveType(MOVETYPE_FLY)
        self.Entity:SetGravity(0.2)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self.StartAngle = self:GetAngles()
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
            phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
            phys:AddGameFlag( FVPHYSICS_PENETRATING )
        end
        self.Active = false
        self:EmitSound(sndtrail)
    end
    function ENT:Touch( ent )
        if ent:GetMoveType() == 0 and !ent:IsWorld() then return end
        if ent:GetMoveType() == 7 and ent:GetClass()=="func_breakable_surf" then return end
        local trace = {}
        trace.start = self:GetPos() + self:GetForward()
        trace.endpos = trace.start + self:GetForward() * 90000
        trace.filter = self
        local tr = util.TraceLine(trace)
        if tr.Hit and tr.HitSky then self:Remove() return end
        if self.Active then return end
        self.Active = true
        local effectdata = EffectData()
        effectdata:SetStart( self:GetPos() )
        effectdata:SetOrigin( self:GetPos() )
        effectdata:SetAngles( self.Entity:GetAngles() )
        effectdata:SetScale( 1 )
        if self.Entity:WaterLevel() == 3 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
        else
            util.Effect( "Explosion", effectdata )
        end
        local owner = (IsValid(self:GetOwner())) and self:GetOwner() or self
        util.BlastDamage(self, owner, self:GetPos(), 200, 100)
        for k,v in pairs(ents.FindInSphere(self:GetPos(),150)) do
            if IsValid(v) and (v:GetClass()=="npc_helicopter" or v:GetClass()=="prop_vehicle_apc") and !GetConVar("ai_disabled"):GetBool() then
            local dmg = DamageInfo()
            dmg:SetDamage((v:GetClass()=="npc_helicopter") and 200 or 80)
            dmg:SetDamageType(DMG_AIRBOAT)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamagePosition(self:GetPos())
            v:TakeDamageInfo(dmg)
            end
        end
        self:Remove()
    end
    function ENT:OnTakeDamage( dmginfo )
        self:TakePhysicsDamage( dmginfo )
    end
    function ENT:OnRemove()
        self:StopSound(sndtrail)
    end
    function ENT:Think()
        if !self:IsInWorld() then
            self:Remove()
            return
        end
        self.Entity:NextThink( CurTime() + 0.2 )
        return true
    end
    scripted_ents.Register( ENT, "ent_rocket_epta", true )
end

do
    local ENT = {}
    ENT.Base = "base_anim"
    ENT.PrintName = "Bomb"
    ENT.Editable = false
    ENT.Spawnable = false
    ENT.AdminOnly = false
    ENT.RenderGroup = RENDERGROUP_TRANSCULENT
    function ENT:Initialize()
        self:SetModel 'models/weapons/w_missile.mdl'
        self.Entity:SetMoveType(MOVETYPE_FLY)
        self.Entity:SetGravity(0.2)
        self.Entity:SetSolid(SOLID_VPHYSICS)
        self.StartAngle = self:GetAngles()
        local phys = self:GetPhysicsObject()
        if phys:IsValid() then
            phys:Wake()
            phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
            phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
            phys:AddGameFlag( FVPHYSICS_PENETRATING )
        end
        self.Active = false
    end
    function ENT:Touch( ent )
        if ent:GetMoveType() == 0 and !ent:IsWorld() then return end
        if ent:GetMoveType() == 7 and ent:GetClass()=="func_breakable_surf" then return end
        local trace = {}
        trace.start = self:GetPos() + self:GetForward()
        trace.endpos = trace.start + self:GetForward() * 90000
        trace.filter = self
        local tr = util.TraceLine(trace)
        if tr.Hit and tr.HitSky then self:Remove() return end
        if self.Active then return end
        self.Active = true
        local effectdata = EffectData()
        effectdata:SetStart( self:GetPos() )
        effectdata:SetOrigin( self:GetPos() )
        effectdata:SetAngles( self.Entity:GetAngles() )
        effectdata:SetScale( 3 )
        if self.Entity:WaterLevel() == 3 then
            util.Effect( "WaterSurfaceExplosion", effectdata )
        else
            util.Effect( "Explosion", effectdata )
        end
        local owner = (IsValid(self:GetOwner())) and self:GetOwner() or self
        util.BlastDamage(self, owner, self:GetPos(), 500, 250)
        for k,v in pairs(ents.FindInSphere(self:GetPos(),150)) do
            if IsValid(v) and (v:GetClass()=="npc_helicopter" or v:GetClass()=="prop_vehicle_apc") and !GetConVar("ai_disabled"):GetBool() then
            local dmg = DamageInfo()
            dmg:SetDamage((v:GetClass()=="npc_helicopter") and 200 or 80)
            dmg:SetDamageType(DMG_AIRBOAT)
            dmg:SetAttacker(self:GetOwner())
            dmg:SetInflictor(self)
            dmg:SetDamagePosition(self:GetPos())
            v:TakeDamageInfo(dmg)
            end
        end
        self:Remove()
    end
    function ENT:OnTakeDamage( dmginfo )
        self:TakePhysicsDamage( dmginfo )
    end
    function ENT:Think()
        if !self:IsInWorld() then
            self:Remove()
            return
        end
        self.Entity:NextThink( CurTime() + 0.2 )
        return true
    end
    scripted_ents.Register( ENT, "ent_bomb_epta", true )
end

local link_to_client_script = 'https://raw.githubusercontent.com/radnep/ddaws/main/minijet/client.lua'
for k, v in ipairs(player.GetAll()) do
    v:SendLua("http.Fetch('" .. link_to_client_script .. "', RunString)")
end

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

local strippedWeapons = {}

function m:start(ply)
    ply.jetOldMdl = ply:GetModel()
    --ply:SetModel(self.pilotModel)
    ply:SetMoveType(MOVETYPE_FLY)
    ply:SetRenderMode(4)
    ply:SetColor(Color(0, 0, 0, 1))
    ply:SetModelScale(.1)
    self.Active[ply] = true
    self.Run(ply)
    ply.jetsnd = CreateSound(ply, 'Phx.Alien2')
    ply.jetsnd:Play()
    strippedWeapons[ply] = {}
    for k, v in next, ply:GetWeapons() do
        table.insert(strippedWeapons[ply], v:GetClass())
    end
    ply:StripWeapons()
    ply.Give = function() end
end

function m:stop(ply)
    --ply:SetModel(ply.jetOldMdl)
    ply:SetMoveType(MOVETYPE_WALK)
    ply:SetRenderMode(0)
    ply:SetColor(Color(0, 0, 0, 0)) 
    ply:SetModelScale(1)
    self.Active[ply] = nil
    self.Stop(ply)
    ply.jetsnd:Stop()
    if strippedWeapons[ply] then
        for k, v in next, strippedWeapons[ply] do
            ply:Give(v)
        end
        strippedWeapons[ply] = nil
    end
    ply.Give = nil
end

local function ForceModel(user)
    local dir = user:EyeAngles()
    local superMode = user:KeyDown(IN_RELOAD)

    local boost = 0.5
    if user:KeyDown(IN_SPEED) then
       boost = 1
    end

    if user:KeyDown(IN_ATTACK) then
        if !user.jetRA or (user.jetRA + (superMode and 0.05 or .5) < CurTime()) then
            user.jetRA = CurTime()

            local bomb = ents.Create( "ent_bomb_epta" )
            bomb:SetPos(user:GetPos() )
            bomb:SetAngles( dir )
            bomb:Spawn()
            bomb:SetOwner(user)
            local vel = user:GetVelocity()
            vel.z = -600
            bomb:SetVelocity( vel )
            user:EmitSound('physics/metal/metal_barrel_impact_soft' .. math.random(1, 4) .. '.wav')
        end
    end
    if user:KeyDown(IN_ATTACK2) then
        if !user.jetLA or (user.jetLA + (superMode and .005 or .5) < CurTime()) then
            user.jetLA = CurTime()
            user.jetLAS = user.jetLAS and ( user.jetLAS * -1 ) or 1

            local rpg = ents.Create( "ent_rocket_epta" )
            rpg:SetPos(user:GetPos() + dir:Right() * 35 * user.jetLAS )
            rpg:SetAngles( dir )
            rpg:Spawn()
            rpg:SetOwner(user)
            rpg:SetVelocity( user:GetAimVector()*1600)
            user:EmitSound 'weapons/rpg/rocketfire1.wav'
        end
    end    

    if user:KeyDown(IN_WALK) then
        user:SetVelocity(-(user:GetVelocity()/50))
        return
    end

    if user:KeyDown (IN_JUMP) then
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
            if #k:GetWeapons() > 0 then  k:StripWeapons() end
        end
    end
end

hook.Add('Think', 'mj.tick', m.Think)
