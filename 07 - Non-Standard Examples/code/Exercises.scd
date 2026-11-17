////////////////////////////////////////////////////////////////
//
//                 Non-Standard Examples: Exercises
//
////////////////////////////////////////////////////////////////

s.boot

( // the two sounds in samples/
~path = PathName(thisProcess.nowExecutingPath).pathOnly ++ "samples/";
~voice = Buffer.read(s, ~path ++ "vocal.wav");
~bikecat = Buffer.read(s, ~path ++ "bikecat.wav");
)


////////////////////////////////////////////////////////////////
// This class
////////////////////////////////////////////////////////////////

/*
   1. Make the saw fall instead of rise.
*/




/*
   2. Set the saw to 220 Hz. How many samples long is one cycle?
*/




/*
   3. Replace the Dseries in the saw with a Dseq of five levels of your
   own.
*/




/*
   4. Give the triangle random durations with Dwhite.
*/




/*
   5. Use Dswitch to alternate between two waveforms of your own.
*/




/*
   6. Fold one of your waveforms with fold2, by a slow sine.
*/




/*
   7. Fill the eight tables with sine1 and random partials, and morph
   between them with the mouse.
*/




/*
   8. Drive the VOsc index with a Dbrown stream instead of the mouse.
*/




/*
   9. Play three VOsc3 frequencies that form a chord.
*/




/*
   10. Put one demand-rate waveform in a SynthDef with an envelope, and
   play it from a Pbind.
*/




/*
   11. Use the same Dseq of levels twice: as a waveform, and in seconds
   as a frequency envelope.
*/




/*
   12. Create a DemandEnvGen process containing at least two layers of
   the main UGen, where the envelope points are created using Dbrown or
   Dbrown2.
*/




/*
   13. Create a DemandEnvGen process that forms a varying triangle
   waveform.
*/




/*
   14. Combine the binary operations so that different ones are used for
   the high frequencies of the input sound and different ones for the low
   frequencies.
*/





////////////////////////////////////////////////////////////////
// From class 02 Granular Synthesis
////////////////////////////////////////////////////////////////

/*
   1. Create a granular texture that evolves from dense to sparse, with
   at least two different voices created with a granular UGen and
   multichannel expansion.
*/




/*
   2. Create a movement of granular sound controlled by audio rate
   waveforms, such as sine waves or LFNoise, mixing more than one buffer
   to read from.
*/




/*
   3. Experiment with coupling parameters, so that only two or three
   controls are mapped to all the granular controls used.
*/




/*
   4. Implement a granular routine where each grain is filtered,
   enveloped, speed-shifted and panned differently.
*/





////////////////////////////////////////////////////////////////
// From class 03 Granular Examples
////////////////////////////////////////////////////////////////

/*
   1. Create a glisson synthesis variant where each of the glissandi goes
   progressively lower in pitch.
*/




/*
   2. Create a layered version of a pulsar synthesis train where each
   layer has a different waveform, envelope and potentially frequency as
   well.
*/




/*
   3. Extend the example of trainlet synthesis by including not only the
   synthetic impulses but also sampled sound.
*/




/*
   4. Extend any of the included examples by making them a function that
   can generate clouds of a certain duration.
*/




/*
   5. Take one of the above and write it as a Pbind, with at least one
   parameter derived from another using Pkey.
*/




/*
   6. Build a live granulation where the delay is not fixed but moves,
   and describe what the moving delay does to the material.
*/




/*
   7. Use Pdef to replace a playing cloud with a different one, so that
   the change is heard as a transition rather than as a stop and a start.
*/




/*
   8. Write a mask that is not in the file: a sieve, a rhythm read from
   an array, or a mask driven by the amplitude of another signal.
*/




/*
   9. Excite a set of resonators with a pulsar train, where the set and
   the rhythm are composed separately and can be changed independently.
*/





////////////////////////////////////////////////////////////////
// From class 04 Sound Transformation
////////////////////////////////////////////////////////////////

/*
   1. Choose a short sound and extend it, using drunk, zigzag or another
   extension method, until it is at least ten times its original length.
*/




/*
   2. Take one source and build a family of eight related sounds from it.
   Keep the chain that made each one.
*/




/*
   3. Make one transformation from A to B where both ends stay
   recognisable, and one where B has lost all trace of A. Say which was
   harder.
*/




/*
   4. Chain at least four programs, listening to every intermediate file,
   and keep the one you did not expect.
*/




/*
   5. Implement a pattern process for waveset distortion that uses
   different patterns to control the play rate and the repeats
   parameters.
*/




/*
   6. Implement a pattern process for waveset distortion that adds a per-
   waveset transformation, such as a filter, a glissando or a binary
   transformation.
*/





////////////////////////////////////////////////////////////////
// From class 05 Sound Transformation Examples
////////////////////////////////////////////////////////////////

/*
   1. Write a breakpoint file with a pattern and use it as the speed or
   the stretch of one sound. Run it with two different seeds and compare.
*/




/*
   2. Apply distort repeat and distort delete to the same sound and
   compare how each changes the length and the surface of the wavesets.
*/




/*
   3. Run distort divide and distort multiply on a pitched sound and on a
   noisy one, and describe which source keeps more of its character.
*/




/*
   4. Chain three waveset distortions with ~cdp, for example omit,
   telescope and average, and listen to the file after each step.
*/




/*
   5. Make a family of eight sounds from one source using at least two
   programs. Keep the log and the files.
*/




/*
   6. Cross synthesize two sounds from your family. Transform one of them
   first and cross again.
*/





////////////////////////////////////////////////////////////////
// From class 06 Non-Standard Synthesis
////////////////////////////////////////////////////////////////

/*
   1. Create a demand rate waveform that contains two different demand
   patterns, for creating both durations and levels.
*/




/*
   2. Implement a SynthDef with two or more Gendy oscillators. These
   should additionally be cross-modulated using binary operations.
*/




/*
   3. Generate a buffer to read with Osc, based on at least three
   different ways of creating random numbers.
*/




/*
   4. Create a shape that is used at the same time as a waveform for
   synthesis and as an envelope for a sound object.
*/




/*
   5. Change A Saw by Hand into a square wave: output 1 while the phase
   is below 0, and -1 above it.
*/




/*
   6. Write a ring modulator: multiply in0 by a sine computed in the
   script, with its frequency as a parameter.
*/




/*
   7. In the GENDY script, set points: anywhere from 2 to 100 and listen
   for where the pitch gives way to a low, rough texture.
*/




/*
   8. Count samples in a variable and use it to switch between two
   waveforms every half second (srate / 2 samples).
*/



