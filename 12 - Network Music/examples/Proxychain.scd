////////////////////////////////////////////////////////////////
//
//                         Proxychain
//
////////////////////////////////////////////////////////////////


ProxyChain(\first).clear;

ProxyChain.add(\dust, \mix -> { Dust.ar(180 ! 2) });

ProxyChain.add(\dist, \filter -> { |in| in.fold2(SinOsc.ar(20))});

ProxyChain.add(\comb, \filter -> { |in| CombC.ar(in,0.1,0.1,4) });

ProxyChain(\first, [\dust, \dist, \comb]);


// Tell the proxy to play
(
ProxyChain(\first).play;
ProxyChain(\first).proxy.fadeTime = 3;
)

// Add the dust and the effects
ProxyChain(\first).add(\dust, 0.5)
ProxyChain(\first).add(\dist, 0.5)
ProxyChain(\first).add(\comb, 0.25)

ProxyChain(\first).remove(\dist)
ProxyChain(\test).gui;
