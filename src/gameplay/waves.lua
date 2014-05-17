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
AMPERE.WAVES.delay = {1, 1, 1.3, 3.2, 1}

function AMPERE.WAVES.get(wave)
    local ret = { ['rest'] = 0 }
    if wave <= #AMPERE.WAVES.starting then
        for i = 1, #AMPERE.WAVES.starting[wave] do
            local c = AMPERE.WAVES.starting[wave][i]
            ret[AMPERE.WAVES.names[i]] = c
            ret['rest'] = ret['rest'] + c
        end
    else
    end
    return ret
end
