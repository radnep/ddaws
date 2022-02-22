local ENT = {}
ENT.Base = "base_anim"
ENT.PrintName = "Bomb"
ENT.Editable = false
ENT.Spawnable = false
ENT.AdminOnly = false
ENT.RenderGroup = RENDERGROUP_TRANSCULENT

function ENT:Initialize()
	if SERVER then
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
	if CLIENT then
	    self.EffectData = EffectData()
	    self.EffectData:SetEntity(self.Entity)
	    self.EffectData:SetScale(1.5)
	end
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
    if CLIENT or self.Active then return end
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

if CLIENT then
    function ENT:Draw()
        self:DrawModel()
    end
end

function ENT:Use()
end

function ENT:OnRemove()
end

function ENT:Think()
    if CLIENT then return end
    if !self:IsInWorld() then
        self:Remove()
        return
    end
    self.Entity:NextThink( CurTime() + 0.2 )
    return true
end

scripted_ents.Register( ENT, "ent_bomb_epta", true )
