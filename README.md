# Programming and Music 2

This advanced course builds upon Programming and Music 1, focusing on advanced
programming techniques, granular synthesis, waveform generation, microsound
composition, data sonification, chaotic systems, algorithmic composition, and
live coding. Students explore sophisticated sound synthesis methods and develop
complex musical systems using SuperCollider.

The course covers granular synthesis, waveform generation, demand-rate UGens,
binary operations, pulsar synthesis, waveset processing, wavetable synthesis,
data sonification, chaos theory, L-systems, fractal mathematics, grammars,
live coding with JitLib and Ndef, ProxySpace, and spatial audio techniques 
for creating innovative musical works.

## Course Structure

### 01 - Introduction
- Advanced programming concepts and server architecture
- **Code files:**
  - `Buses.scd` - Audio buses and signal routing
  - `Patterns.scd` - Advanced pattern techniques
  - `Demand.scd` - Demand-rate UGens and control
- PMB01 - Introduction.pdf

### 02 - Granularity
- Granular synthesis fundamentals and techniques
- **Code files:**
  - `GrainRoutines.scd` - Granular synthesis with routines
  - `GrainUGens.scd` - Granular synthesis UGens
  - `GrainGUI.scd` - Graphical interface for granular control
  - `TimeScales.scd` - Time-scale manipulation techniques
- **Audio samples:**
  - Various click samples and sound files
- PMB02 - Granularity.pdf

### 03 - Granular Examples
- Advanced granular synthesis applications
- **Code files:**
  - `Graintrnsfrm.scd` - Per-grain processing and transformation
  - `Reconstruction.scd` - Sound reconstruction techniques
  - `Trainlet.scd` - Trainlet synthesis methods
  - `Glisson.scd` - Glisson synthesis techniques
  - `Pulsars.scd` - Pulsar synthesis
- PMB03 - Granular Examples.pdf

### 04 - Waveforms
- Waveform generation and manipulation
- **Code files:**
  - `Shapes.scd` - Waveform shape generation
  - `Binary.scd` - Binary operations on waveforms
  - `Demand.scd` - Demand-rate waveform generation
  - `Gendy.scd` - Gendy synthesis techniques
  - `Instructions.scd` - Waveform generation instructions
  - `Wavesets.scd` - Waveset analysis and synthesis
- PMB04 - Waveforms.pdf

### 05 - Waveforms Examples
- Advanced waveform synthesis applications
- **Code files:**
  - `WavesetsEx.scd` - Waveset synthesis examples
  - `BinaryEx.scd` - Binary operation examples
  - `DemandEx.scd` - Demand-rate synthesis examples
  - `Youtube-Microsound.scd` - YouTube tutorial examples
- PMB05 - NSS Examples.pdf

### 06 - Sonification
- Data sonification techniques and file I/O
- **Code files:**
  - `Files.scd` - File reading and data manipulation
  - `Sonification.scd` - Data-to-sound mapping techniques
- **Data files:**
  - `earthquakes.csv`, `failedbanks.csv`, `populationbycountry.csv`
  - `temperature.csv`, `votes.csv`, `courses.txt`
  - `deathprobabilities.csv`, and more
- PMB06 - Sonification.pdf

### 07 - Chaos
- Chaos theory and algorithmic composition
- **Code files:**
  - `ChaosUGens.scd` - Chaotic oscillators and generators
  - `ChaosFunctions.scd` - Chaos functions in language
  - `ChaosPatterns.scd` - Pattern-based chaos
  - `voss.scd` - Voss noise (1/f noise) generation
- **Assignment 1:**
  - City data sonification project
  - `cities.csv` - Dataset for assignment
- PMB07 - Chaos.pdf

### 08 - Examples
- Comprehensive examples integrating course concepts
- **Code files:**
  - `01 - DemandEnvGen.scd` - Waveform synthesis with demand UGens
  - `02 - GranularSynthesis.scd` - Granular processing techniques
  - `03 - PulsarSynthesis.scd` - Pulsar synthesis examples
  - `04 - BufferGranulation.scd` - Real-time buffer granulation
  - `05 - BinaryOperations.scd` - Binary operations and waveshaping
  - `06 - Wavesets.scd` - Waveset processing techniques
  - `07 - Wavetables.scd` - Wavetable synthesis with VOsc/VOsc3
- **Audio samples:**
  - `bikecatm.wav`, `sequencem.wav`
  - 31 click samples for granular synthesis
  - 12 wavetable files
- **Documentation:**
  - `exercises.scd` - 15 practical exercises
  - Archive files: `pmb08.png`, `pmb08.zip`

### 09 - Grammars & Fractals
- Algorithmic composition using grammars and fractal mathematics
- **Code files:**
  - `Grammars.scd` - Grammar-based composition systems
  - `LSystems.scd` - L-Systems for generative music
  - `LSystemsExtended.scd` - Advanced L-System techniques
  - `Fractals.scd` - Fractal algorithms in music
  - `FractalTree.scd` - Tree-based fractal structures
  - `Recursion.scd` - Recursive algorithms
  - `1FNoise.scd` - 1/f (pink) noise generation
- PMB09 - Grammars.pdf

### 10 - Live Coding
- Introduction to live coding with JitLib
- **Code files:**
  - `PMB13 - JitLib.scd` - JitLib fundamentals
  - `PMB13 - NodeProxies.scd` - NodeProxy techniques
  - `PMB13 - PatternProxies.scd` - Pattern proxy systems
- PMB13 - Live Coding.pdf
- Archive files: `pmb13.png`, `pmb13.zip`

### 11 - Live Approaches
- Advanced live coding approaches and techniques
- **Code files:**
  - `Ndef.scd` - Ndef (Node Definition) usage
  - `ProxySpace.scd` - ProxySpace environments
  - `Steno.scd` - Steno live coding language
  - `Additional.scd` - Additional live coding techniques
- **Tasks:**
  - `Task 0 - Ndef basics.scd`
  - `Task 1 - ProxySpace.scd`
  - `Task 2 - Audio Rate Patterns.scd`
  - `Task 3 - Set and SetSrc.scd`
  - `Task 4 - Node Proxy Roles.scd`
  - `Task 5 - NdefPresetMorphing.scd`
  - `Task 6 - In.ar and Feedback.scd`
  - `Task 7 - Arrow Routing.scd`
- **Assignment 2:**
  - Live coding project
  - PMB - Assignment 2 (2025).pdf
- PMB16 - Live Coding, Approaches.pdf
- Archive files: `pmb16.png`, `pmb16.zip`

### 12 - Materials
- Advanced techniques for material-based composition
- **Data files:**
  - Various code examples and audio samples
  - Task-based exercises
- PMB15 - Examples.pdf
- Archive files: `pmb15.png`, `pmb15.zip`

### 13 - Spatialisation
- Spatial audio and multichannel composition
- **Data files:**
  - Multiple code examples and audio samples
  - Spatial processing techniques
- PMB16 - Spatialisation.pdf
- Archive files: `pmb16.png`, `pmb16.zip`

## Assignments

The course includes two major assignments:

- **Assignment 1** (Section 07 - Chaos): City data sonification project using chaotic systems
- **Assignment 2** (Section 11 - Live Approaches): Live coding performance project

## Resources

- [Bjarni Gunnarsson's Courses](https://www.bjarni-gunnarsson.net/courses)
- [Sonology Bachelor's Programme](https://sonology.org/bachelors-programme/)

## License

This course material is provided under the terms specified in the LICENSE file.