
harmonies = all_harmonies{4};
harmony = harmonies(1);

new_chord = chord(harmony).fit(harmony, pattern1, pattern2);
chords = [chords new_chord];

