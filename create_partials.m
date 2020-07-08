function partials=create_partials(wft)

spect = [];
partials = [];

for i = 1:1:size(wft,2)
    y_i = wft(:,i);
    %peak detection
    [~, peak_freqs] = findpeaks(y_i, 'MinPeakHeight', 1, 'MinPeakProminence', 0.1); %ADD ELEVATION FILTER TOO
    peak_amps = y_i(peak_freqs);
    note_freqs = equaltemper(peak_freqs);
    
    for j = 1:1:length(peak_freqs)
        spect = [spect ; i note_freqs(j) peak_amps(j)];
        new_p = true;
        for p = 1:1:length(partials)
            if (partials(p).end_time == i-1 | partials(p).end_time == i-2) & abs(partials(p).freq - note_freqs(j)) <= 0.1
                partials(p).end_time = i;
                partials(p).amps = [partials(p).amps peak_amps(j)];
                new_p = false;
                break
            end
        end
        if new_p == true
            partials = [partials partial(i, i, note_freqs(j), [peak_amps(j)])];
        end
    end
end

if isempty(partials)
    return
end

%filter
partials = filter_partials(partials);

%split long partials
hold on
for p=1:1:length(partials)
    %plot(linspace(partials(p).start_time, partials(p).end_time, length(partials(p).amps)), partials(p).amps)
    %plot(partials(p).start_time, partials(p).amps(1), 'ro')    
    
    late_attack = movmedian(partials(p).amps, 3);
    v = [diff(late_attack) 0];
    late_attack(v<mean(v)+std(v)) = 0; %get rises
    late_attack(1:round(length(late_attack)/3)) = 0; %not in initial attack or decay
    new_ps = find([0 diff(logical(late_attack))==1]) + partials(p).start_time; %detect edges
    
    %plot(linspace(partials(p).start_time, partials(p).end_time, length(partials(p).amps)), [0 diff(logical(late_attack))==1])
    
    if isempty(new_ps)
        continue
    else
        new_ps = new_ps(1);
    end
    
    %modify partials
    partials = [partials partial(new_ps, partials(p).end_time, partials(p).freq, partials(p).amps(new_ps-partials(p).start_time:end))];
    partials(p).end_time = new_ps - 1;
    partials(p).amps = partials(p).amps(1:new_ps-partials(p).start_time-1);
end

partials=filter_partials(partials);

% plot
hold on
% scatter(spect(:,1), spect(:,2))%, spect(:,3)) %time, frequency plot
% for p=1:1:length(partials)
%     plot([partials(p).start_time, partials(p).end_time], repelem(partials(p).freq, 2), 'LineWidth', 2, 'Color',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
%     text(partials(p).end_time, partials(p).freq, string(num2str(p) + ", " + name_note(partials(p).freq)));
% end
end

function filtered=filter_partials(ps)
filtered = ps(([ps.end_time] - [ps.start_time] >= 2) ...
    & ([ps.freq] > equaltemper(0)) ...
    & (cellfun(@length, {ps.amps}) > 3));
end