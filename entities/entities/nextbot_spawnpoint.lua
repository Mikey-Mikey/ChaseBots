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

        timer.Create(tostring(self) .. " SpawnNextbot", 30, 1, function()
            self.nextbot = ents.Create(self.nextbotClass)
            self.nextbot:SetPos(self:GetPos())
            self.nextbot:Spawn()
            self:SetNWBool("NextbotSpawned", true)
        end)

    else
        self.hollowCircleMesh = Mesh()
        local radius = 80
        mesh.Begin(self.hollowCircleMesh, MATERIAL_TRIANGLE_STRIP, 360 / 5 * 2)
            for a = 0, 360, 5 do
                local ang = math.rad(a)
                local x = math.cos(ang) * radius
                local y = math.sin(ang) * radius

                mesh.TexCoord(0, 0, 0)
                mesh.Color(255, 0, 0, 255)
                mesh.Normal(self:GetUp())
                mesh.Position(Vector(x, y, 0))
                mesh.AdvanceVertex()

                mesh.TexCoord(0, 0, 0)
                mesh.Color(255, 0, 0, 255)
                mesh.Normal(self:GetUp())
                mesh.Position(Vector(x * 1.1, y * 1.1, 0))
                mesh.AdvanceVertex()
            end
        mesh.End()
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
    local pentagonMat = Material("lights/white")

    hook.Add("PostDrawOpaqueRenderables", "DrawNextbotSpawnpoints", function()
        for k, spawnpoint in pairs(ents.FindByClass("nextbot_spawnpoint")) do
            if spawnpoint:GetNWBool("NextbotSpawned", false) then
                continue
            end
            -- draw a 2d pentagram on the ground
            local pos = spawnpoint:GetPos()
            local ang = spawnpoint:GetAngles()
            local offset = 1

            local mat = Matrix()

            mat:Translate(pos)
            mat:Rotate(ang)
            mat:Translate(Vector(0, 0, -offset))
            render.SetMaterial(pentagonMat)
            cam.PushModelMatrix(mat, false)
                render.SetColorModulation(1, 0, 0)
                spawnpoint.hollowCircleMesh:Draw()
                render.SetColorModulation(1, 1, 1)
            cam.PopModelMatrix()

            debugoverlay.Cross(pos, 5, 5, Color(255, 0, 0), true)
        end
    end)
end