crystal_ball = {}

function crystal_ball.new(base_score, multiplier)
    local ret = {}
    ret.multiplier = multiplier
    ret.score = 0
    ret.base_score = base_score
    
    ret.inc_multiplier = function(self)
        self.multiplier = self.multiplier + 1
    end
    
    ret.set_multiplier = function(self, new_multiplier)
        self.multiplier = new_multiplier
    end
    
    ret.get_multiplier = function(self)
        return self.multiplier
    end
    
    ret.update = function(self, delta_time)
        ret.score = ret.score + self.base_score * self.multiplier * delta_time
    end
    
    return ret
end
