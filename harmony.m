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
        function r=plus(harmony1, harmony2)
            if harmony1.start_time < harmony2.start_time
                h1 = harmony1;
                h2 = harmony2;
            else 
                h2 = harmony1;
                h1 = harmony2;
            end
            
            %assert closeness to be added
            assert(h2.start_time - h1.end_time < 5);
            
            r=harmony(h1.start_time, h2.end_time, h1.freqs, h1.avg_amps);
            for f=1:1:length(h2.freqs)
                h1i = find(h1.freqs == h2.freqs(f), 1);
                if isempty(h1i)
                    r.freqs = [r.freqs h2.freqs(f)];
                    r.avg_amps = [r.avg_amps h2.avg_amps(f)]; 
                else
                    assert(r.freqs(h1i) == h2.freqs(f));
                    %pool amps
 r.avg_amps(h1i) = ((h1.end_time-h1.start_time)*r.avg_amps(h1i) + (h2.end_time - h2.start_time)*h2.avg_amps(f))/(h2.end_time - h1.start_time);
                end
            end
        end
    end
end