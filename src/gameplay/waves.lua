require 'src/global'

AMPERE.WAVES = {}

AMPERE.WAVES.names = {'chocolate', 'cane', 'cube', 'jelly', 'fruit'}
AMPERE.WAVES.starting = {
    {5, 0, 0, 0, 0},
    {10, 0, 0, 0, 0},
    {10, 10, 0, 0, 0},
    {0, 0, 8, 0, 0},
    {0, 0, 0, 10, 0},
    {0, 0, 0, 0, 15}
}
-- test only
AMPERE.WAVES.cycle = {
    {10, 0, 0, 0, 0},
    {-5, 5, 0, 0, 0},   -- 5 5 0 0 0
    {0, 3, 8, 0, 0},    -- 5 8 8 0 0
    {5, -3, 0, 0, 0},   -- 10 5 8 0 0
    {-10, 0, -3, 10, 0},-- 0 5 5 10 0
    {8, 5, 2, -10, 8},  -- 8 10 7 0 8
    {2, -2, 0, 5, 2}    -- 10 8 7 5 10
}
AMPERE.WAVES.cycle[0] = {}
for j = 1, #AMPERE.WAVES.names do AMPERE.WAVES.cycle[0][j] = 0 end
for i = 1, #AMPERE.WAVES.cycle do
    for j = 1, #AMPERE.WAVES.names do
        AMPERE.WAVES.cycle[0][j] =
            AMPERE.WAVES.cycle[0][j] + AMPERE.WAVES.cycle[i][j]
    end
end
AMPERE.WAVES.delay = {1, 1, 1.3, 3.2, 1}

function AMPERE.WAVES.get(wave)
    local ret = { ['wavenum'] = wave, ['rest'] = 0 }
    if wave <= #AMPERE.WAVES.starting then
        for i = 1, #AMPERE.WAVES.starting[wave] do
            local c = AMPERE.WAVES.starting[wave][i]
            ret[AMPERE.WAVES.names[i]] = c
            ret['rest'] = ret['rest'] + c
        end
    else
        local fullcycles = math.floor(
            (wave - #AMPERE.WAVES.starting) / #AMPERE.WAVES.cycle)
        for i = 1, #AMPERE.WAVES.names do
            local c = AMPERE.WAVES.cycle[0][i] * fullcycles
                + AMPERE.WAVES.starting[#AMPERE.WAVES.starting][i]
            ret[AMPERE.WAVES.names[i]] = c
            ret['rest'] = ret['rest'] + c
        end
        for i = 1, (wave - #AMPERE.WAVES.starting) % #AMPERE.WAVES.cycle do
            for j = 1, #AMPERE.WAVES.names do
                local c = AMPERE.WAVES.cycle[i][j]
                ret[AMPERE.WAVES.names[j]] = ret[AMPERE.WAVES.names[j]] + c
                ret['rest'] = ret['rest'] + c
            end
        end
    end
    return ret
end
