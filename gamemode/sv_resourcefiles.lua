resource.AddFile("materials/entities/parkourmod.png")
resource.AddFile("materials/hud/parkourmod_killicon.vmt")
resource.AddFile("models/weapons/c_parkour_hands.mdl")

for i = 1, 4 do
    resource.AddFile("sound/parkourmod/wallrun" .. i .. ".wav")
end

for i = 1, 8 do
    resource.AddFile("sound/parkourmod/swimming_wade" .. i .. ".wav")
end

resource.AddFile("sound/parkourmod/necksnap.wav")

for i = 1, 7 do
    resource.AddFile("sound/parkourmod/impact_soft" .. i .. ".wav")
end

for i = 1, 6 do
    resource.AddFile("sound/parkourmod/floorslide_hit_hard" .. i .. ".wav")
end

resource.AddFile("sound/parkourmod/floorslide.wav")

for i = 1, 2 do
    resource.AddFile("sound/parkourmod/floorrolling_0" .. i .. ".wav")
    resource.AddFile("sound/parkourmod/die_male_0" .. i .. ".wav")
    resource.AddFile("sound/parkourmod/die_female_0" .. i .. ".wav")
end

resource.AddFile("sound/parkourmod/door_brust.wav")

for i = 1, 3 do
    resource.AddFile("sound/parkourmod/die_combine_0" .. i .. ".wav")
    resource.AddFile("sound/parkourmod/die_body_break_0" .. i .. ".wav")
end