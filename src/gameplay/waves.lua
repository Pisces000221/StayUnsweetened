require 'src/global'

AMPERE.WAVES = {}

AMPERE.WAVES.names = {'chocolate', 'cane', 'cube', 'jelly', 'fruit', 'gingerbread'}
AMPERE.WAVES.starting = {
    {5, 0, 0, 0, 0, 0},
    {10, 0, 0, 0, 0, 0},
    {10, 10, 0, 0, 0, 0},
    {0, 0, 8, 0, 0, 0},
    {5, 0, 0, 10, 0, 0},
    {0, 0, 0, 0, 12, 0},
    {0, 3, 0, 0, 0, 0},
    {0, 0, 0, 0, 0, 1},
    {5, 5, 5, 5, 15, 0}
}
-- test only
AMPERE.WAVES.cycle = {
    {10, 0, 0, 0, 0, 0},
    {-5, 5, 0, 0, 0, 0},   -- 5 5 0 0 0
    {0, 3, 8, 0, 0, 0},    -- 5 8 8 0 0
    {5, -3, 0, 0, 0, 0},   -- 10 5 8 0 0
    {-10, 0, -3, 10, 0, 0},-- 0 5 5 10 0
    {8, 5, 2, -10, 8, 0},  -- 8 10 7 0 8
    {2, -2, 0, 5, 2, 0},   -- 10 8 7 5 10
    {0, 0, 0, 0, 0, 1}     -- 0 0 0 0 0 [1]
}
AMPERE.WAVES.cycle[0] = {}
-- Do not calculate gingerbread house
for j = 1, #AMPERE.WAVES.names do AMPERE.WAVES.cycle[0][j] = 0 end
for i = 1, #AMPERE.WAVES.cycle do
    for j = 1, #AMPERE.WAVES.names - 1 do
        AMPERE.WAVES.cycle[0][j] =
            AMPERE.WAVES.cycle[0][j] + AMPERE.WAVES.cycle[i][j]
    end
end
AMPERE.WAVES.delay = {1, 1, 1.3, 3.2, 1, 45}

function AMPERE.WAVES.get(wave)
    local ret = { ['wavenum'] = wave, ['rest'] = 0 }
    if wave <= #AMPERE.WAVES.starting then
        for i = 1, #AMPERE.WAVES.starting[wave] do
            local c = AMPERE.WAVES.starting[wave][i]
            ret[AMPERE.WAVES.names[i]] = c
            ret['rest'] = ret['rest'] + c * AMPERE.WAVES.delay[i]
        end
    else
        local fullcycles = math.floor(
            (wave - #AMPERE.WAVES.starting) / #AMPERE.WAVES.cycle)
        local cycle_idx = (wave - #AMPERE.WAVES.starting) % #AMPERE.WAVES.cycle
        if cycle_idx == 0 then cycle_idx = #AMPERE.WAVES.cycle end
        ret['cycle_idx'] = cycle_idx
        if AMPERE.WAVES.cycle[cycle_idx][#AMPERE.WAVES.names] > 0 then
            for j = 1, #AMPERE.WAVES.names - 1 do ret[AMPERE.WAVES.names[j]] = 0 end
            ret[AMPERE.WAVES.names[#AMPERE.WAVES.names]] = AMPERE.WAVES.cycle[cycle_idx][#AMPERE.WAVES.names]
            ret['rest'] = AMPERE.WAVES.delay[#AMPERE.WAVES.names] * AMPERE.WAVES.cycle[cycle_idx][#AMPERE.WAVES.names]
            return ret
        end
        ret[AMPERE.WAVES.names[#AMPERE.WAVES.names]] = 0
        for i = 1, #AMPERE.WAVES.names - 1 do
            local c = AMPERE.WAVES.cycle[0][i] * fullcycles
                + AMPERE.WAVES.starting[#AMPERE.WAVES.starting][i]
            ret[AMPERE.WAVES.names[i]] = c
            ret['rest'] = ret['rest'] + c * AMPERE.WAVES.delay[i]
        end
        for i = 1, cycle_idx do
            for j = 1, #AMPERE.WAVES.names - 1 do
                local c = AMPERE.WAVES.cycle[i][j]
                ret[AMPERE.WAVES.names[j]] = ret[AMPERE.WAVES.names[j]] + c
                ret['rest'] = ret['rest'] + c * AMPERE.WAVES.delay[j]
            end
        end
    end
    return ret
end
