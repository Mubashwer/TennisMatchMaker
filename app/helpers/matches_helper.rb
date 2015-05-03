module MatchesHelper
    def can_join(pids)
        pids = pids.compact
        if !pids.include?(current_user.id) and 
            ((@match.match_type == "Single" and pids.count < 2) or 
            (@match.match_type == "Double" and pids.count < 4))
            return true
        end
        return false
    end

    def get_player_list(match)
        p = []
        p[0] = User.find_by_id(match.player1_id); 
        p[1] = User.find_by_id(match.player2_id); 
        p[2] = User.find_by_id(match.player3_id); 
        p[3] = User.find_by_id(match.player4_id); 
        return p;
    end

    def join_now(match, pid)
        joined = false
        if match.player2_id.nil? then match.player2_id = pid; joined = true
        elsif match.player3_id.nil? then match.player3_id = pid ; joined = true
        elsif match.player4_id.nil? then match.player4_id = pid ; joined = true
        end
        return joined
    end

    def leave_now(match, pid, host)
        left = false
        if match.player2_id == pid then match.player2_id = nil; left = true
        elsif match.player3_id == pid then match.player3_id = nil; left = true
        elsif match.player4_id == pid then match.player4_id = nil; left = true
        end

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

    def get_class(match)
        p_count = get_player_list(match).compact.count
        if((match.match_type == "Single" and p_count == 2) or
            (match.match_type == "Double" and p_count == 4))
            return "success"
        end
        return ""
    end

end
