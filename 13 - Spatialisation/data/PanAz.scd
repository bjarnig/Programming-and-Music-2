
////////////////////////////////////////////////////////////////
//
//                     PanAz & PanX
//
////////////////////////////////////////////////////////////////

/*

PanAz is short for "panning azimuth", which refers to the horizontal
angle at which a sound is perceived by a listener. The UGen can be used
to create stereo images, simulate three-dimensional spaces, and manipulate
the perceived location of sounds within a stereo field.

*/

( // Mono

{ Out.ar(0,Impulse.ar(25,0.2)) }.play

)

( // Test

{ Dust.ar( { 40.rand } ! 4 ) }.play

)

( // PanX goes from 0 to 1

{ PanX.ar(4, Impulse.ar(20), SinOsc.ar(0.1).range(0.0,1.0)) }.play

)


( // PanAz goes from -1 to 1

{ PanAz.ar(4, Impulse.ar(20), SinOsc.ar(0.1).range(-1.0,1.0)) }.play

)


( // PanAz also has 'width'

{ PanAz.ar(4, Impulse.ar(20), SinOsc.ar(0.5).range(-1.0,1.0), 1, width: Line.kr(0.1,4,10)) }.play

)

( // Example

NF(\pointa, {
	|hifrom=4,hito=10,hirate=1,hifreq=400,hires=0.1,hiamp=250,lorate=20,
	lofreq=8000,lores=0.01,loamp=150|
	PanAz.ar(4,
	BBandPass.ar(Impulse.ar(
	LFNoise1.ar(hirate).range(hifrom,hito)) * 0.01, hifreq, hires, hiamp) +
	BBandPass.ar(Impulse.ar(lorate) * 0.1, lofreq, lores, loamp),
	LFNoise1.ar(Line.kr(4,10,25)).range(-1,1))
}).play;

)

( // Be careful with phasing!

{ PanAz.ar(4, BrownNoise.ar(0.5) * 0.3, SinOsc.ar(0.1).range(-1.0,1.0)) }.play

)
