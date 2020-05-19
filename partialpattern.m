classdef partialpattern
    properties
        n_samples
        avg_pattern
        pattern_len
    end
    methods
        function obj=partialpattern(pattern)
                obj.n_samples = 0;
                obj.pattern_len = 10;
                obj.avg_pattern = zeros(1,obj.pattern_len);
            if nargin == 1
                obj.n_samples = 1;
                pattern = clip_pattern(obj, pattern);
                obj.avg_pattern = pattern;
            end
        end
        function clipped=clip_pattern(obj, pattern)
            pattern = pattern(1:min(end, obj.pattern_len));
            clipped = padarray(pattern, [0 obj.pattern_len-length(pattern)],0,'post');
        end
        function obj=update_pattern(obj, pattern)
            n = obj.n_samples;
            pattern = clip_pattern(obj, pattern);
            obj.avg_pattern = (obj.avg_pattern*n + pattern)./(n + 1);
            obj.n_samples = n + 1;
        end
    end
end