module MatchesHelper
    def can_join(pids) #determines if it is possible to join match
        pids = pids.compact #list of ids
        if pids.include?(current_user.id) then return false end
        count = pids.count #number of players
        match_type = @match.match_type

        #if there isnt any room
        if(["Singles", "Men's Singles", "Women's Singles"].include?(match_type)\
            and count > 1)
            return false
        end
        if(["Doubles", "Men's Doubles", "Women's Doubles"].include?(match_type)\
            and count > 3)
            return false
        end
        # 0 = Male, 1 = Female
        #only men can enter men's games
        if(["Men's Singles", "Men's Doubles"].include?(match_type)\
            and current_user.gender != 0)
            return false
        end
        #only women can enter women's games
        if(["Women's Singles", "Women's Doubles"].include?(match_type)\
            and current_user.gender != 1)
            return false
        end
        
        genders = pids.map{|pid| User.find(pid).gender} #genders of players
        if(match_type == "Mixed Doubles"\
            and ( ![0, 1].include?(current_user.gender)\
            or genders.count(current_user.gender) > 1))
            return false
        end

        return true
    end

    def get_player_list(match) #get the list of players
        p = []
        p[0] = User.find_by_id(match.player1_id); 
        p[1] = User.find_by_id(match.player2_id); 
        p[2] = User.find_by_id(match.player3_id); 
        p[3] = User.find_by_id(match.player4_id); 
        return p;
    end

    def join_now(match, pid) #join if there is space (second check)
        joined = false
        if match.player2_id.nil? then match.player2_id = pid; joined = true
        elsif match.player3_id.nil? then match.player3_id = pid ; joined = true
        elsif match.player4_id.nil? then match.player4_id = pid ; joined = true
        end
        return joined
    end

    def leave_now(match, pid, host) #leave match
        left = false
        if match.player2_id == pid then match.player2_id = nil; left = true
        elsif match.player3_id == pid then match.player3_id = nil; left = true
        elsif match.player4_id == pid then match.player4_id = nil; left = true
        end
        #if you are host, if there is someone else in the match, he becomes host
        #otherwise the match is destroyed in the calling method
        if host
            @match.player1_id = nil
            if @match.player2_id
                @match.player1_id, @match.player2_id = @match.player2_id, @match.player1_id
            elsif @match.player3_id
                @match.player1_id, @match.player3_id = @match.player3_id, @match.player1_id 
            elsif @match.player4_id
                @match.player1_id, @match.player4_id = @match.player4_id, @match.player1_id 
            end
            if !@match.player1_id.nil? then left = true end
        end

        return left
    end

    def get_class(match) # returns the class for match which is full/ready
        p_count = get_player_list(match).compact.count
        match_type = match.match_type
        if((["Singles", "Men's Singles", "Women's Singles"].include?(match_type) and p_count == 2) or
            (["Doubles", "Men's Doubles", "Women's Doubles"].include?(match_type) and p_count == 4))
            return "success"
        end
        return ""
    end

end
