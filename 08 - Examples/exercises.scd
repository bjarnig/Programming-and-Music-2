
EXERCISE 1: Modified Waveforms (DemandEnvGen)
Take Example 2 from 01-DemandEnvGen (Triangle Wave) and modify it to create an triangle wave where the rise time is twice as long as the fall time. Adjust the step sizes accordingly.


EXERCISE 2: Rhythmic Grain Patterns (Granular)
Extend Example 5 from 02-GranularSynthesis (Rhythmic Granular Patterns). Create a new 32-step pattern that includes rests (zeros) to create a more complex rhythm.


EXERCISE 3: Pulsar Sequence (Pulsar Synthesis)
Using the pulsar synthesis setup from 03-PulsarSynthesis, create a simple  pattern by sequencing different fundamental frequencies using Demand UGens. Keep the formant frequency constant.


EXERCISE 4: Dual-Reader Granulation (Buffer Granulation)
Modify Example 1 from 04-BufferGranulation to use two different granular readers reading from the same buffer. Give each reader different grain parameters (size, density, playback rate).


EXERCISE 5: Cascaded Waveshaping (Binary Operations)
Take Example 1 from 05-BinaryOperations (.fold2) and create a chain of three different binary operations applied in sequence (e.g., fold2 → wrap2 → thresh). Experiment with different modulation rates for each stage.


EXERCISE 6: Waveset Sequencer (Wavesets)
Create a simple sequencer using Example 3 from 06-Wavesets that plays back specific waveset indices in a defined pattern (e.g., [0, 5, 10, 3, 8]) rather than random selection.


EXERCISE 7: Wavetable Chords (Wavetables)
Extend Example 10 from 07-Wavetables (Multi-Voice Polyphonic VOsc) to create harmonic chords. Use frequency ratios like [1, 5/4, 3/2, 2] to create major chords at different root frequencies.


EXERCISE 8: Multi-Breakpoint Gendy (DemandEnvGen)
Modify Example 9 from 01-DemandEnvGen to use different Dbrown step sizes for odd and even breakpoints, creating alternating smooth and jagged evolution patterns.


EXERCISE 9: Spatial Granular Cloud (Granular)
Take Example 3 from 02-GranularSynthesis (Multi-Band Granular Processing) and add spatial movement by modulating the pan position of each layer with different LFO rates.


EXERCISE 10: Formant Sweep (Pulsar Synthesis)
Create a pulsar patch that keeps the fundamental frequency constant while sweeping the formant frequency from low to high over 10 seconds using an exponential curve (XLine).


EXERCISE 11: Feedback Loop Integration (Buffer Granulation)
Combine concepts from 04-BufferGranulation with feedback. Create a system where the granulated output is fed back into the circular buffer alongside the original source.


EXERCISE 12: Rhythmic Binary Modulation (Binary Operations)
Use Example 4 from 05-BinaryOperations (.amclip) and add rhythmic control where the modulation depth changes in sync with a Demand-based pattern at audio rate.


EXERCISE 13: Waveset Density Control (Wavesets)
Modify Example 6 from 06-Wavesets (Density Control) to create three distinct density zones: sparse (5 grains/sec), medium (15 grains/sec), and dense (40 grains/sec), with smooth transitions between them.


EXERCISE 14: VOsc with Envelope Timbre (Wavetables)
Extend Example 9 from 07-Wavetables to create a patch where the buffer index is controlled by a multi-segment envelope (Env with 5+ segments), creating a scripted timbral transition.


EXERCISE 15: Hybrid Synthesis Patch
Combine at least three techniques from different example files into a single cohesive patch. For example: use DemandEnvGen to create a pulsaret waveform, process it with binary operations, and granulate the result with buffer-based granulation.
