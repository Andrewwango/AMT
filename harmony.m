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
    end
end