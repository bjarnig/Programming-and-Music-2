# Programming and Music 2

This advanced course builds upon Programming and Music 1, focusing on advanced
programming techniques, granular synthesis, waveform generation, microsound
composition, data sonification, chaotic systems, algorithmic composition, and
live coding. Students explore sophisticated sound synthesis methods and develop
complex musical systems using SuperCollider.

The course covers granular synthesis, waveform generation, demand-rate UGens,
binary operations, pulsar synthesis, waveset processing, wavetable synthesis,
data sonification, chaos theory, L-systems, fractal mathematics, grammars,
live coding with JitLib and Ndef, ProxySpace, network music, spatial audio,
CDP (Composer's Desktop Project) processing, FFT analysis, and ecosystemic
composition for creating innovative musical works.

## Course Structure

### 01 - Introduction
- Advanced programming concepts and server architecture
- **Code files:**
  - `Buses.scd` - Audio buses and signal routing
  - `Patterns.scd` - Advanced pattern techniques
  - `Demand.scd` - Demand-rate UGens and control
- PMB01 - Introduction.pdf

### 02 - Granular Synthesis
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

### 04 - Sound Transformation
- Composer's Desktop Project: sound transformation and processing
- **Code files:**
  - `CDP.scd` - CDP integration with SuperCollider
- PMB09 - CDP.pdf
- Archive files: `pmb15.png`, `pmb15.zip`

### 05 - Sound Transformation Examples
- Advanced CDP techniques and cross-synthesis
- **Code files:**
  - `CDP2.scd` - Advanced CDP processing
  - `CDPCross.scd` - Cross-synthesis with CDP
  - `CDPGui.scd` - Graphical interface for CDP workflows
- PMB16 - CDP 2.pdf
- Archive files: `pmb16.png`, `pmb16.zip`

### 06 - Non-Standard Synthesis
- Describing the waveform directly, sample by sample
- **Code files:**
  - `Shapes.scd` - Waveform shape generation
  - `Binary.scd` - Binary operations on waveforms
  - `Demand.scd` - Demand-rate waveform generation
  - `Gendy.scd` - Gendy synthesis techniques
  - `Instructions.scd` - Waveform generation instructions
  - `Wavesets.scd` - Waveset analysis and synthesis
- PMB04 - Waveforms.pdf

### 07 - Non-Standard Examples
- The same idea with SuperCollider's own tools
- **Code files:**
  - `WavesetsEx.scd` - Waveset synthesis examples
  - `BinaryEx.scd` - Binary operation examples
  - `DemandEx.scd` - Demand-rate synthesis examples
  - `Youtube-Microsound.scd` - YouTube tutorial examples
- PMB05 - NSS Examples.pdf

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

### 11 - Live Coding 2
- Advanced live coding approaches and techniques
- **Code files:**
  - `Ndef.scd` - Ndef (Node Definition) usage
  - `Processing.scd` - Live processing of audio sources
  - `Systems.scd` - Building live coding systems
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

### 12 - Network Music
- Network music, collaborative performance, and distributed systems
- **Code files:**
  - `Network.scd` - Network music fundamentals and OSC communication
  - `Network-Advanced.scd` - Advanced networking and multi-machine setups
- **Examples:**
  - `Feedback.scd`, `MI.scd`, `Ndefs.scd`, `Proxychain.scd`
  - `Steno.scd`, `Synthesis.scd`, `VST.scd`
- PMB12 - Network Music.pdf
- **Assignment 2:** PMB - Assignment 2 (2026).pdf

### 13 - Spatialisation
- Spatial audio, multichannel composition, and ambisonics
- **Code files:**
  - `Ambisonics.scd` - Ambisonic encoding and decoding
  - `VBAP.scd` - Vector Base Amplitude Panning
  - `PanAz.scd` - Azimuth panning techniques
  - `Grainspat.scd` - Spatial granular synthesis
  - `Specdiff.scd` - Spectral diffusion
  - `BPF.scd` - Band-pass filter spatialisation
  - `Examples.scd` - Spatialisation examples
- PMB13 - Spatialisation.pdf
- Archive files: `pmb13.png`

### 14 - Live Examples
- Live coding examples and workflow demonstrations
- **Code files:**
  - `Examples.scd` - Integrated live coding examples
  - `Workflows.scd` - Live coding workflow patterns
- PMB14 - Examples.pdf
- **Assignment 2:** PMB - Assignment 2 (2026).pdf
- Archive files: `pmb14.png`, `pmb14.zip`

### 17 - Analysis
- Spectral analysis, FFT, and ecosystemic composition
- **Code files:**
  - `FFT.scd` - Fast Fourier Transform analysis
  - `Listening.scd` - Machine listening techniques
  - `Triggers.scd` - Trigger-based event detection
  - `NRT.scd` - Non-real-time processing
  - `Cross.scd` - Cross-synthesis and convolution
  - `Ecosystemics.scd` - Ecosystemic and autonomous composition
- PMB17 - Analysis.pdf
- Archive files: `pmb17.png`, `pmb17.zip`

### 18 - FluCoMa
- Fluid Corpus Manipulation toolkit for analysis and corpus-based work
- **Code files (`code/flucoma/atomic`):**
  - `buffer-descriptors.scd` - Buffer-based audio descriptors
  - `realtime-descriptors.scd` - Real-time descriptor extraction
  - `decomposition.scd` - Signal decomposition (HPSS, sines, transients)
  - `slicers.scd` - Onset and novelty slicing
- **Code files (`code/flucoma/methods`):**
  - `corpus-building.scd` - Building a corpus with MFCC descriptors
  - `sound-browser.scd` - Browsing a corpus interactively
  - `cross-synthesis.scd` - Corpus-based cross-synthesis
  - `decomposition-compositional.scd` - Decomposition for composition
  - Supporting `sounds/` directory and `corpus_mfcc.json`
- PMB18 - FluCoMa.pdf
- **Assignment 3:** PMB - Assignment 3 (2026).pdf

### 19 - ML
- Machine learning for sound: classification, regression and clustering
- **Code files:**
  - `Flucoma - Classification.scd` - Classifying sounds with FluCoMa
  - `Flucoma - Regressor.scd` - Regression with FluCoMa
  - `Custom - Regressor.scd` - Building a custom regressor
- **`code/atomic` walkthrough:**
  - `01-dataset.scd` - Datasets and labelling
  - `02-scaling.scd` - Feature scaling
  - `03-reduction.scd` - Dimensionality reduction
  - `04-clustering.scd` - Clustering
  - `05-supervised.scd` - Supervised learning
  - `tiny_ds.json` - Example dataset
- PMB19 - ML.pdf

### 20 - Complexity
- Complex systems: cellular automata, physical and agent-based models
- **Code files:**
  - `CA.scd`, `LifeCA.scd`, `WolframCA.scd`, `AdditiveCA.scd` - Cellular automata
  - `Boids.scd` - Flocking / boids
  - `BouncingBalls.scd`, `TraerPhysics.scd`, `TraerPhysicsExtended.scd` - Physical modelling
  - `Kuramoto.scd` - Coupled oscillator synchronisation
  - `Lorenz.scd` - Lorenz attractor
  - `Networks.scd` - Network-based systems
  - `GeneticBasics.scd`, `GeneticBuffer.scd` - Genetic algorithms
  - Supporting `samples/` directory
- PMB20 - Complexity.pdf
- **Assignment 3:** PMB - Assignment 3 (2026).pdf

## Assignments

The course includes three major assignments:

- **Assignment 1** (Section 22 - Chaos): City data sonification project using chaotic systems
- **Assignment 2** (Sections 12/14 - Network Music / Live Examples): Network music and live coding performance project (2026)
- **Assignment 3** (Sections 18/20 - FluCoMa / Complexity): Machine learning and complex systems project (2026)

## Resources

- [Bjarni Gunnarsson's Courses](https://www.bjarni-gunnarsson.net/courses)
- [Sonology Bachelor's Programme](https://sonology.org/bachelors-programme/)

## License

This course material is provided under the terms specified in the LICENSE file.### 21 - Sonification
- Data sonification techniques and file I/O
- **Code files:**
  - `Files.scd` - File reading and data manipulation
  - `Sonification.scd` - Data-to-sound mapping techniques
- **Data files:**
  - `earthquakes.csv`, `failedbanks.csv`, `populationbycountry.csv`
  - `temperature.csv`, `votes.csv`, `courses.txt`
  - `deathprobabilities.csv`, and more
- PMB06 - Sonification.pdf

### 22 - Chaos
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

