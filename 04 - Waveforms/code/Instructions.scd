////////////////////////////////////////////////////////////////
//
//               			Instructions
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)


/////////////////// Instruction Synthesis //////////////////////


/* The following come from SLUGens SC3 Plugins by Nick Collins  */

( // Random instructions

var array, buffer;
array = Array.fill(1024,{arg i; if(i.even,{7.rand},{1.0.rand})});
buffer = Buffer.sendCollection(s, array, 1, action: {
{Out.ar(0,Pan2.ar(Instruction.ar(buffer.bufnum) * 0.5, 0.0))}.play});

)




( // More random instructions

var array, buffer;
array = Array.fill(8,{ 1.0.rand; });
buffer = Buffer.sendCollection(s, array, 1, action: {
{Out.ar(0,FreeVerb.ar(Pan2.ar(Instruction.ar(buffer.bufnum) * 0.5, 0.0)))}.play});

)




( //LPC Error

{
	LPCError.ar(
		SinOsc.ar(LFNoise0.kr(0.2,400,500)), SinOsc.kr(0.1,0,63,64)
	) ! 2 * 0.3
}.play

)
