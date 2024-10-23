AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.PrintName = "Nextbot Spawnpoint"
ENT.Author = "Mikey"

function ENT:Initialize()
    if SERVER then
        local self = self

        self:SetNoDraw(true)

        self:SetNWBool("NextbotSpawned", false)

        timer.Create(tostring(self) .. " SpawnNextbot", 10, 1, function()
            self.nextbot = ents.Create(self.nextbotClass)
            nextbot:SetPos(self:GetPos())
            nextbot:Spawn()
            self:SetNWBool("NextbotSpawned", true)
        end)
    end
end

function ENT:OnRemove()
    if SERVER then
        local self = self
        timer.Remove(tostring(self) .. " SpawnNextbot")
        if IsValid(self.nextbot) then
            self.nextbot:Remove()
        end
    end
end

if CLIENT then
    hook.Add("PostDrawOpaqueRenderables", "DrawNextbotSpawnpoints", function()
        for k, v in pairs(ents.FindByClass("nextbot_spawnpoint")) do
            if v:GetNWBool("NextbotSpawned", false) then
                continue
            end
            -- draw a 2d pentagram on the ground
            local pos = v:GetPos()
            local ang = v:GetAngles()
            local size = 60
            local offset = 1

            cam.Start3D2D(pos + v:GetUp() * offset, ang, 1)
                -- Draw the circle
                local circleVerts = {}
                for a = 0, 360, 360 / 32 do
                    local x = math.cos(math.rad(a)) * size
                    local y = math.sin(math.rad(a)) * size
                    circleVerts[#circleVerts + 1] = {x = x, y = y}
                end
                surface.SetDrawColor(200, 0, 0)
                surface.DrawPoly(circleVerts)
            cam.End3D2D()
        end
    end)
end