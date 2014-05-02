require 'src/global'

AMPERE.WAVES = {}

AMPERE.WAVES.names = {'chocolate', 'cane'}
AMPERE.WAVES.starting = {
    {5, 0},
    {10, 0},
    {5, 10}
}
AMPERE.WAVES.delay = {1, 1}

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
