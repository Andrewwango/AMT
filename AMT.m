middleA = 440;
equaltemper = [];
notes = ["G#2" "A2" "A#2" "B2" "C3" "C#3" "D3" "D#3" "E3" "F3" "F#3" "G3" "G#3" "A3" "A#3" "B3" "C4" "C#4" "D4" "D#4" "E4" "F4" "F#4" "G4" "G#4" "A4" "A#4" "B4" "C5" "C#5" "D5" "D#5" "E5" "F5" "F#5" "G5" "G#5" "A5" "A#5" "B5" "C6" "C#6" "D6" "D#6" "E6" "F6" "F#6" "G6" "G#6" "A6" "A#6" "B6" "C7" "C#7" "D7" "D#7" "E7" "F7" "F#7"];
equaltemper_ranges = [;];
for i = -25:1:33
    equaltemper = [equaltemper middleA*2^(i/12) ];
    equaltemper_ranges = [equaltemper_ranges ; middleA*2^((i*100 - 50)/1200) middleA*2^((i*100 + 50)/1200) ];
end
log_equaltemper = log2(equaltemper);

fmax = 4410;
fNyq = fmax * 2;
t_d = 2;
t_s = t_d/30;
[x,fs] = audioread("C:\Users\mcgivyw\Desktop\AMT\piano-1.wav");
x = x(:,1); %stereo to mono
x_lp = lowpass(x, fmax, fs);
x_ds = downsample(x_lp, fs/fNyq);

discretisation = x_ds(1:t_d*fNyq);
wft = abs(WindowFT(discretisation, t_s*fNyq/2, t_s*fNyq, 'Rectangle'));
wft = wft(1:(t_d*fNyq/2+1),:);

spect = [];
partials = {};
for i = 1:1:size(wft,2)
    y_i = wft(:,i);

    %peak detection
    [~, peak_freqs] = findpeaks(movmean(y_i,30), 'MinPeakProminence', 0.2);
    peak_amps = y_i(peak_freqs);
    note_freqs = 2.^ interp1(log_equaltemper, log_equaltemper, log2(peak_freqs), 'nearest');

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
            newpartial = partial;
            newpartial.start_time = i;
            newpartial.end_time = i;
            newpartial.freq = note_freqs(j);
            newpartial.amps = [peak_amps(j)];
            partials = [partials, newpartial];
        end
    end
end
scatter(spect(:,1), spect(:,2))%, spect(:,3))
hold on
for p=1:1:length(partials)
    if partials(p).end_time - partials(p).start_time < 2
        continue;
    end
    scatter(linspace(partials(p).start_time, partials(p).end_time, 100), ones(100,1)*partials(p).freq, 5, 'MarkerEdgeColor',[0.5 0 0], 'MarkerFaceColor',[0.5 0 0]);
    text(partials(p).end_time, partials(p).freq, string(mean(partials(p).amps)));
    %scatter(partials(p).start_time, partials(p).end_time);
    hold on
end
