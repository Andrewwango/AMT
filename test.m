
harmonies = all_harmonies{5};
harmony = harmonies(1);

new_chord = chord(harmony).fit(harmony, pattern1);
chords = [chords new_chord];

