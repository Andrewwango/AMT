function closest=equaltemper(f)
    middleA = 440;
    equaltemper = [];
    notes = ["G#2" "A2" "A#2" "B2" "C3" "C#3" "D3" "D#3" "E3" "F3" "F#3" "G3" "G#3" "A3" "A#3" "B3" "C4" "C#4" "D4" "D#4" "E4" "F4" "F#4" "G4" "G#4" "A4" "A#4" "B4" "C5" "C#5" "D5" "D#5" "E5" "F5" "F#5" "G5" "G#5" "A5" "A#5" "B5" "C6" "C#6" "D6" "D#6" "E6" "F6" "F#6" "G6" "G#6" "A6" "A#6" "B6" "C7" "C#7" "D7" "D#7" "E7" "F7" "F#7"];
    equaltemper_ranges = [;];
    for i = -40:1:33%-25:1:33
        equaltemper = [equaltemper middleA*2^(i/12) ];
        equaltemper_ranges = [equaltemper_ranges ; middleA*2^((i*100 - 50)/1200) middleA*2^((i*100 + 50)/1200) ];
    end
    log_equaltemper = log2(equaltemper);    
    closest = 2.^ interp1(log_equaltemper, log_equaltemper, log2(f), 'nearest', 'extrap');
end