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
        function a=avg_amp(obj)
            %a = cellfun(@mean, {obj.amps}); %mean of each individual partial
            a = mean([obj.amps]); %concatenate all peaks together
        end
    end
end