classdef partialpattern
    properties
        pattern_len
        patterns
    end
    methods
        function obj=partialpattern(pattern)
                obj.pattern_len = 10;
            if nargin == 1
                pattern = clip_pattern(obj, pattern);
                obj.patterns = [pattern];
            end
        end
        function clipped=clip_pattern(obj, pattern)
            pattern = pattern(1:min(end, obj.pattern_len));
            clipped = padarray(pattern, [0 obj.pattern_len-length(pattern)],0,'post');
        end
        function o=append(obj, pattern)
            obj.patterns = [obj.patterns; clip_pattern(obj, pattern)];
            o = obj;
        end
        function p=avg_pattern(obj)
            p = median(obj.patterns, 1);
        end
        function s=std_pattern(obj)
            s = std(obj.patterns, 1);
        end
        function p=avg_n(obj)
            p = avg_pattern(obj);
            p = p/p(1);
        end
        function s=std_n(obj)
            avg = obj.avg_pattern();
            s = obj.std_pattern() / avg(1);
        end 
        function p=latest(obj)
            p = obj.patterns(end,:);
        end
    end
    
    methods(Static)
        function patt_n=normalise(patt)
            patt_n=patt/sum(patt);
        end
        function p=all_harmonies_to_pattern(all_harmonies)
            hold on
            p = partialpattern;
            for h2=1:1:length(all_harmonies)
                harmonies = all_harmonies{h2};
                %Add to partial pattern
                for h=1:1:length(harmonies)
                    pattern = zeros(1,10);
                    ffreq = min(harmonies(h).freqs);
                    for i=1:1:p.pattern_len
                        f = find(harmonies(h).freqs==equaltemper(ffreq*i));
                        if ~isempty(f)
                            pattern(i) = harmonies(h).avg_amps(f(1));
                        end
                    end
                    pattern = partialpattern.normalise(pattern);
                    if sum(pattern==0)>6
                        continue
                    end
                    p = p.append(pattern);

                    %a = plot(p.latest(), 'o-');
                    %label(a, string(ffreq));
                    %string(string(ffreq) + " Hz, s: " + string(harmonies(h).start_time) + ", t: " + string(harmonies(h).end_time-harmonies(h).start_time))
                end
            end
            %plot(p.avg_pattern(), '*-')
        end
    end
end