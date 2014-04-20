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
    local ret = {}
    if wave <= #AMPERE.WAVES.starting then
        for i = 1, #AMPERE.WAVES.starting[wave] do
            ret[AMPERE.WAVES.names[i]] = AMPERE.WAVES.starting[wave][i] end
    else
    end
    return ret
end
