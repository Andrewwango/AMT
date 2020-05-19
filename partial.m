classdef partial
    properties
        start_time
        end_time
        freq
        amps
    end
    methods
        function obj=partial(start_time, end_time, freq, amps)
            obj.start_time = start_time;
            obj.end_time = end_time;
            obj.freq = freq;
            obj.amps = amps;
        end
    end
end