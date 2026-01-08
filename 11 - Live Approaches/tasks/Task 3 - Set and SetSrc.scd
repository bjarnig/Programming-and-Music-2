////////////////////////////////////////////////////////////////
//
//                    Task 3: Set and SetSrc
//
////////////////////////////////////////////////////////////////

Ndef.clear

a = Ndef(\na, { |freq=340, lop=2000| RLPF.ar(Blip.ar(freq, 150).fold2(SinOsc.ar([freq/20,freq/5])), lop) })

a.fadeTime = 2

a.play

(

a[1] = \set -> Pbind(
    \dur, Prand([0.2, 0.5, 0.25, 0.125], inf),
    \freq, Pwhite(50, 200, inf),
    \lop, Pwhite(300, 4000, inf)
)

);

// modify the source while it plays
a[0] = { |freq = 340, lop=2000| RLPF.ar(Saw.ar(freq/2 !2).fold2(SinOsc.ar([freq * 10,freq * 5])), lop) * 0.1 };

// set another source that recieves changes from the pattern
a[2] = {|freq=100| LFNoise1.kr(1) * Impulse.ar(freq!2, 0.5) }; // to check

// filter the combined sound
a[3] = \filter -> {|in| RLPF.ar(in, LFNoise1.ar(5).range(100,2000), 0.2) };




//////// Sequencing proxies instances with \setsrc /////////////

(

Ndef(\nb,
    \setsrc -> Pbind(\source,
        Pseq([
			{ Blip.ar(5000, 150).fold2(SinOsc.ar(10)) ! 2 * 0.2 },
			{ Blip.ar(50, 5).fold2(SinOsc.ar(0.1)) ! 2 * 0.5  },
			{ Blip.ar(500, 100).fold2(SinOsc.ar(20)) ! 2 * 0.2  },
        ], inf),
        \dur, Prand([3, 2, 4], inf)
    )
);

)

Ndef(\nbb, {  GVerb.ar( Ndef(\nb).ar.sum ) }).play

