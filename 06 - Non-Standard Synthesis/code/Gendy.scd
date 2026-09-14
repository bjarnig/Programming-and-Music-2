////////////////////////////////////////////////////////////////
//
//                            Gendy 
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


////////////////////////// Gendy ///////////////////////////

/* The standard distribution contains three Ugens by Nick
 Collins inspired by the stochastic synthesis of Xenakis */

{Gendy1.ar(ampdist: 10, ddparam: 0.001, minfreq: 200) * 0.5}.play


{Gendy1.ar(initCPs: 20, minfreq: 20, maxfreq: 2000) * 0.5}.play


{Gendy2.ar(a: 0.7, c: 0.2, ddparam: 0.2, minfreq:100, maxfreq:1000)}.play


{Gendy2.ar(ampdist:6, adparam:0.18, durscale:0.01)}.play


{Gendy3.ar(freq: 800, durscale:0.8, knum: 12)}.play


{Gendy3.ar(freq: 60, durscale:0.1)}.play


{Klank.ar(`[[142,182,1224,1448,2400],[1,0.5,0.2,0.4,0.2] * 0.01], Gendy2.ar)}.play


{MostChange.ar(Gendy2.ar(maxfreq: 10), Gendy3.ar(freq: 200, initCPs: 50))}.play