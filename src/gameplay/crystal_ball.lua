crystal_ball = {}

function crystal_ball.new(base_score, multiplier)
    local ret = {}
    ret.multiplier = multiplier
    ret.score = 0
    ret.base_score = base_score
    ret.cur_base_score = base_score
    
    ret.inc_multiplier = function(self)
        self.multiplier = self.multiplier + 1
    end
    
    ret.dec_base_score = function(self, rate)
        --print('decrement: ', self.base_score * rate)
        self.cur_base_score = self.cur_base_score - self.base_score * rate
    end
    
    ret.is_finished = function(self)
        return self.cur_base_score <= 0
    end
    
    ret.base_score_rate = function(self)
        return self.cur_base_score / self.base_score
    end
    
    ret.update = function(self, delta_time)
        ret.score = ret.score + self.cur_base_score * self.multiplier * delta_time
    end
    
    return ret
end
