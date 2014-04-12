set = {}

function set.new()
    local ret = {}

    ret.append = function(self, val)
        self[#self+1] = val
    end

    ret.remove = function(self, idx)
        self[idx] = self[#self]
        self[#self] = nil
    end

    ret.pop = function(self)
        local ret = self[1]
        self[1] = self[#self]
        self[#self] = nil
        return ret
    end

    return ret
end
