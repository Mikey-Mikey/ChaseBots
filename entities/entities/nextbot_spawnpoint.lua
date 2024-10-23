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
            self.nextbot:SetPos(self:GetPos())
            self.nextbot:Spawn()
            self:SetNWBool("NextbotSpawned", true)
        end)

    else
        self.circleVerts = {}
        -- Cache the circle
        for a = 0, 360, 360 / 32 do
            local size = 80
            local x = math.cos(math.rad(a)) * size
            local y = math.sin(math.rad(a)) * size
            self.circleVerts[#self.circleVerts + 1] = {x = x, y = y}
        end
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
        for k, spawnpoint in pairs(ents.FindByClass("nextbot_spawnpoint")) do
            if spawnpoint:GetNWBool("NextbotSpawned", false) then
                continue
            end
            -- draw a 2d pentagram on the ground
            local pos = spawnpoint:GetPos()
            local ang = spawnpoint:GetAngles()
            local offset = 1

            cam.Start3D2D(pos + spawnpoint:GetUp() * offset, ang, 1)
                surface.SetDrawColor(0, 0, 0)
                surface.DrawPoly(spawnpoint.circleVerts)
                local hollowCircleVerts = {}

                for i, vert in ipairs(spawnpoint.circleVerts) do
                    hollowCircleVerts[#hollowCircleVerts + 1] = {x = vert.x * 0.8, y = vert.y * 0.8}
                    hollowCircleVerts[#hollowCircleVerts + 1] = {x = vert.x, y = vert.y}
                end
                surface.SetDrawColor(127, 0, 0)
                surface.DrawPoly(hollowCircleVerts)
            cam.End3D2D()
        end
    end)
end