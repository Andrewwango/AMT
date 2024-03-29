classdef harmony
    properties
        start_time
        end_time
        freqs
        avg_amps
    end
    methods
        function obj=harmony(start_time, end_time, freqs, avg_amps)
            obj.start_time = start_time;
            obj.end_time = end_time;
            obj.freqs = freqs;
            obj.avg_amps = avg_amps;
        end
        function d=duration(obj)
            d=obj.end_time-obj.start_time;
        end
        function s=similar(obj, h)
            if obj.start_time < h.start_time
                h1 = obj;
                h2 = h;
            else 
                h2 = obj;
                h1 = h;
            end
            error_count = 0;
            for f=1:1:length(h1.freqs)
                error_count = error_count + isempty(find(h2.freqs==h1.freqs(f),1));
            end
            error_count = 2*error_count + length(h2.freqs) - length(h1.freqs);
            s = (h2.start_time - h1.end_time < 1) && (error_count/(length(h2.freqs)+length(h1.freqs)) < 0.35);
        end
        function r=plus(harmony1, harmony2)
            if harmony1.start_time < harmony2.start_time
                h1 = harmony1;
                h2 = harmony2;
            else 
                h2 = harmony1;
                h1 = harmony2;
            end
            
            %assert closeness to be added
            %assert(h2.start_time - h1.end_time < 5);
            r_end_time = max(h2.end_time, h1.end_time);
            r_start_time = min(h1.start_time, h2.start_time);
            r = harmony(r_start_time, r_end_time, h1.freqs, h1.avg_amps);
            for f=1:1:length(h2.freqs)
                h1i = find(h1.freqs == h2.freqs(f), 1);
                if isempty(h1i)
                    r.freqs = [r.freqs h2.freqs(f)];
                    r.avg_amps = [r.avg_amps h2.avg_amps(f)]; 
                else
                    assert(r.freqs(h1i) == h2.freqs(f));
                    %pool amps
 r.avg_amps(h1i) = (h1.duration()*r.avg_amps(h1i) + h2.duration()*h2.avg_amps(f))/(h1.duration()+h2.duration());%(r_end_time - r_start_time);
                end
            end
        end
    end
    methods(Static)
        function o=overlap(h1,h2)
            o = ((h2.start_time - h1.start_time < 2) && (h2.end_time - h1.end_time > -2)) || ...
               ((h2.start_time - h1.start_time > -2) && (h2.end_time - h1.end_time < 2));
        end
        
        function [CURR, DELETE_PREV, DELETE_CURR]=check_similar(prev_harmonies, curr_harmonies)
            mark_for_deletion_p = zeros(1, length(prev_harmonies));
            mark_for_deletion_c = zeros(1, length(curr_harmonies));
            
            %merge similar and overlapping harmonies
            for h_c=1:1:length(curr_harmonies)
                for h_p=1:1:length(prev_harmonies)
                    if curr_harmonies(h_c).similar(prev_harmonies(h_p))
                        curr_harmonies(h_c) = curr_harmonies(h_c) + prev_harmonies(h_p);
                        mark_for_deletion_p(h_p) = 1;
                    elseif harmony.overlap(curr_harmonies(h_c), prev_harmonies(h_p))
                        if curr_harmonies(h_c).duration() > prev_harmonies(h_p).duration()
                            mark_for_deletion_p(h_p) =1;
                        else
                            mark_for_deletion_c(h_c) =1;
                        end
                    end
                end
            end
            CURR = curr_harmonies;
            DELETE_PREV = mark_for_deletion_p;
            DELETE_CURR = mark_for_deletion_c;
        end
        
        function plot_all_harmonies(all_harmonies, cs)
            hold on
            for h2=1:1:length(all_harmonies)
                harmonies = all_harmonies{h2};
                cs(h2)
                for h=1:1:length(harmonies)
                    plot([harmonies(h).start_time harmonies(h).end_time], repelem(min(harmonies(h).freqs),2), 'o-');
                    text(harmonies(h).end_time, min(harmonies(h).freqs), name_note(min(harmonies(h).freqs)));
                    disp(name_note(sort(harmonies(h).freqs)))
                    disp([num2str(harmonies(h).start_time), " ", num2str(harmonies(h).end_time)])                     
                end
            end
        end

    end
end