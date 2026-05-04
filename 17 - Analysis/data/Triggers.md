# Triggers

Going from a continuous signal to **discrete events**. Where Listening
produces streams (pitch, amp, centroid…), Triggers produces ticks: things
fire, are counted, are gated. Onsets, beats, peaks, key changes, hysteresis.

The loader at the top reads four sounds (`~aa`, `~ab`, `~ca`, `~cb`).

---

## 1. Onsets — bleep on each attack

A spectral attack detector with mouse-controlled threshold, hooked to a
percussion envelope on a sine. Slide MouseX right to make the detector less
sensitive.

- **`FFT(buffer, in)`** — produces the FFT chain that Onsets consumes.
- **`Onsets.kr(fft, threshold, odftype)`** — fires a 1-sample trigger each
  time it detects an attack. Internally computes an "onset detection
  function" (ODF) from the FFT and triggers when it spikes above
  `threshold`. `\complex` is a robust default ODF — it tracks both magnitude
  and phase change.
- **`EnvGen.kr(env, gate)`** — plays an envelope shape on each trigger.
- **`Env.perc(attack, release, level)`** — a one-shot percussion envelope:
  rises to `level` in `attack` seconds, falls in `release`.

---

## 2. Onsets via OSC — receive each event in the language

Same Onsets UGen, but instead of triggering a sound on the server, we route
the event to the language via SendReply / OSCFunc. Useful when onsets should
trigger language-side scheduling, GUI updates, or external software.

- **`SendReply.kr(trigger, replyName)`** — sends an OSC message with
  `replyName` to the language each time `trigger` is non-zero.
- **`OSCFunc({ |msg, time| ... }, replyName)`** — a language-side responder
  to incoming OSC. Replaces the deprecated `OSCresponder`.

---

## 3. Onsets trigger a grain

The same onset trigger now drives `TGrains`, which spawns a grain of the
source buffer at random pitch each time an attack is detected. The source
becomes its own granular rhythm section.

- **`TGrains.ar(numChannels, trigger, buf, rate, centerPos, dur, pan, amp)`**
  — triggered granular synthesis. On each trigger, plays a Hann-windowed
  grain from `buf`. `rate` = playback speed (also pitch). `dur` = grain
  length in seconds. Multichannel output panned across `numChannels`.
- **`LFNoise1.kr(freq).range(lo, hi)`** — interpolated low-frequency noise.
  Provides a slow random rate variation per grain.

---

## 4. BeatTrack drives a filter sweep

BeatTrack returns four control signals from an FFT: triggers at the beat,
half-bar, quarter-bar, and a continuous tempo estimate. Here the beat and
half-bar triggers drive Decay envelopes that sweep two band-pass filters
across the source. The source itself becomes the "drum kit" — no overlaid
synths.

- **`BeatTrack.kr(fft)`** — autocorrelation-based tempo and beat tracker.
  Returns `[beat, halfbeat, quarterbeat, tempo]`.
- **`Decay.kr(trigger, decayTime)`** — exponential decay envelope retriggered
  on each impulse. Output is 1.0 at the trigger and decays toward 0.
- **`BPF.ar(in, freq, rq)`** — second-order resonant band-pass. `rq` is the
  reciprocal of Q (so 0.3 is sharp, 1.0 is wide).
- **`.linexp(inMin, inMax, outMin, outMax)`** — linear-input exponential-
  output mapping. Better than `linlin` when the output is a frequency, since
  pitch is perceived logarithmically.

---

## 5. KeyTrack — drone on the detected tonic

Estimates the key (pitch class 0–11) and plays a Saw drone two octaves down
from C+key. The drone shifts as the key estimate changes.

- **`KeyTrack.kr(fft)`** — chromagram-based key estimator. Outputs an integer
  0..11 representing C..B (same encoding as MIDI note % 12).
- **`.midicps`** — MIDI note number → frequency in Hz.
- **`Lag.kr(freq, time)`** — smooths the frequency change over `time` seconds
  so the drone glides instead of jumping.

---

## 6. Peak / PeakFollower / RunningMax — running max becomes a tempo

Three different peak detectors. Here only the running max is used: it grows
to the loudest sample seen so far and never shrinks, so it ratchets upward.
We map that to an `Impulse` rate.

- **`Peak.ar(in)`** — outputs the maximum absolute value seen since the last
  trigger (or forever if no trigger).
- **`PeakFollower.ar(in, decay)`** — tracks the peak with an exponential
  decay back to the input. Like a peak meter that sags.
- **`RunningMax.ar(in)`** — monotonic maximum since start (or last reset).
- **`Impulse.ar(freq)`** — single-sample impulses at `freq` Hz. Useful as a
  trigger source.

---

## 7. Median for stable envelope, drives clicks

`Median` outputs the median of the last N samples of its input. On the
absolute value of audio, this gives a noise-resistant envelope that ignores
isolated spikes.

- **`Median.ar(length, in)`** — sliding-window median over the last `length`
  samples (must be odd, default 3).

---

## 8. Schmidt trigger — fires only on threshold crossing

A Schmidt trigger is a comparator with hysteresis: it goes high at one
threshold and low at a *different*, lower threshold. This prevents
chattering when the input lingers near a single threshold. Here we ping each
time the trigger flips.

- **`Schmidt.ar(in, lo, hi)`** — outputs 1 once `in` rises above `hi`, stays
  1 until `in` falls below `lo`, then goes back to 0.
- **`HPZ1.ar(in)`** — first-order high-pass: outputs `0.5 * (in[t] - in[t-1])`.
  On a 0/1 gate signal, this isolates the moment the gate changes.
- **`Decay2.ar(trig, attack, decay)`** — double-exponential percussive
  envelope (smoother attack than `Decay`).
