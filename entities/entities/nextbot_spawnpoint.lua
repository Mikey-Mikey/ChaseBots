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

                mesh.Color(127, 0, 0, 255)
                mesh.Position(Vector(x, y, 0))
                mesh.AdvanceVertex()

                mesh.Color(127, 0, 0, 255)
                mesh.Position(Vector(x * 1.1, y * 1.1, 0))
                mesh.AdvanceVertex()
            end
        mesh.End()

        self.circleMesh = Mesh()
        mesh.Begin(self.circleMesh, MATERIAL_TRIANGLE_STRIP, 360 / 5 * 2)
            for a = 0, 360, 5 do
                local ang = math.rad(a)
                local x = math.cos(ang) * radius
                local y = math.sin(ang) * radius

                mesh.Color(0, 0, 0, 255)
                mesh.Position(Vector(0, 0, 0))
                mesh.AdvanceVertex()

                mesh.Color(0, 0, 0, 255)
                mesh.Position(Vector(x, y, 0))
                mesh.AdvanceVertex()
            end
        mesh.End()

        --[[ p5js code
            let prevAng = radians(a - 360 / 5 + 180);
            let ang = radians(a + 360 / 5 + 180);
            
            line(sin(prevAng) * 20,cos(prevAng) * 20,sin(ang) * 20,cos(ang) * 20);
        ]]
        -- draw a line using 4 vertices
        local function drawLine(x1, y1, x2, y2)
            local dir = Vector(x2 - x1, y2 - y1, 0):GetNormalized()
            local perp = Vector(-dir.y, dir.x, 0) * 5

            mesh.Color(127, 0, 0, 255)
            mesh.Position(Vector(x1 + perp.x, y1 + perp.y, 0))
            mesh.AdvanceVertex()

            mesh.Color(127, 0, 0, 255)
            mesh.Position(Vector(x1 - perp.x, y1 - perp.y, 0))
            mesh.AdvanceVertex()

            mesh.Color(127, 0, 0, 255)
            mesh.Position(Vector(x2 + perp.x, y2 + perp.y, 0))
            mesh.AdvanceVertex()

            mesh.Color(127, 0, 0, 255)
            mesh.Position(Vector(x2 - perp.x, y2 - perp.y, 0))
            mesh.AdvanceVertex()

        end

        self.starMesh = Mesh()
        mesh.Begin(self.starMesh, MATERIAL_TRIANGLE_STRIP, 360 / 5 * 2)
            for a = 0, 360, 360 / 5 do
                local prevAng = math.rad(a - 360 / 5 + 180)
                local ang = math.rad(a + 360 / 5 + 180)

                local px = math.cos(prevAng) * radius
                local py = math.sin(prevAng) * radius

                local x = math.cos(ang) * radius
                local y = math.sin(ang) * radius

                drawLine(px, py, x, y)
            end
        mesh.End()

        self.starRot = 0

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

            local mat = Matrix()

            mat:Translate(pos)
            mat:Rotate(ang)
            mat:Translate(Vector(0, 0, -offset))

            render.SetColorMaterial()

            cam.PushModelMatrix(mat, false)
                spawnpoint.circleMesh:Draw()
                spawnpoint.hollowCircleMesh:Draw()
            cam.PopModelMatrix()

            mat:Rotate(Angle(0, spawnpoint.starRot, 0))
            for i = 1, 5 do
                render.SetBlend(0.1)
                cam.PushModelMatrix(mat, false)
                    spawnpoint.starMesh:Draw()
                cam.PopModelMatrix()
                mat:Translate(Vector(0, 0, -1))
            end

            spawnpoint.starRot = spawnpoint.starRot + FrameTime() * 10

            debugoverlay.Cross(pos, 5, 5, Color(255, 0, 0), true)
        end
    end)
end