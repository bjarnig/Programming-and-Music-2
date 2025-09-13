////////////////////////////////////////////////////////////////
//
//                      Demand Rate 
//
////////////////////////////////////////////////////////////////


Be careful with volume. SafetyNet can prevent harmful signals.

( // Installs the SafetyNet Quark.

Quarks.fetchDirectory(true); Quarks.install("SafetyNet");
thisProcess.recompile;

)



///////////////////////// Demand rate //////////////////////////


( // Use Demand and server side patterns for waveforms

{   var trig, movement;
	trig = Impulse.ar(400);
	movement = Dbrown(-1,1,0.8,inf);
	Demand.ar(trig, 0, movement) ! 2 * 0.5;
}.play;
)




( // Demand sequence and vary frequency

{   var trig, movement;
	trig = Impulse.ar(SinOsc.kr(0.1, 0, 4500, 8000));
	movement = Dseq([Dbrown(-0.1,0.1,0.5,32), Dbrown(-0.8,0.8,0.5,16)], inf);
	Demand.ar(trig, 0, movement) ! 2 * 0.5;
}.play;
)




( // Demand rate for sequencing ranges of random values

{ var da, db, dc, dd;
da = Dwhite(-1.0, 1.0, Dwhite(2,128));
db = Dwhite(-0.2, 0.2, Dwhite(2,128));
dc = Dwhite(-0.1, 0.1, Dwhite(2,128));
dd = Dwhite(0.0, 0.6, Dwhite(2,128));
Demand.ar(Impulse.ar(5000), 0, Dseq([da,db,dc,dd], inf))
}.play;
)




( // Demand rate for controlling oscillators

{
    var brown, freq, trig;
    brown = Dbrown(50, 5000, 100, inf);
	trig = Impulse.kr(500);
    freq = Demand.kr(trig, 0, brown);
    Pulse.ar(freq) ! 2 * 0.1
}.play;

)




( // Works with multichannel expansion and nested patterns

{
var seq, demand, pulse, times=10, speed=25;
seq = Dbrown(0, Dwhite(0.1,1.0,inf), Array.rand(times, 0.01, 0.8));
pulse = Impulse.ar(speed);
demand = Demand.ar(pulse, 0, seq * 1000).poll;
Splay.ar(Impulse.ar(demand), level:0.5)
}.play

)



( // Duty allows to set the demand rate to a list of duration

{
var duty = Duty.ar(Dwhite(0.2, 1.5,inf), 0, Dwhite(100,1000,inf));
	LPF.ar(WhiteNoise.ar, Lag.ar(duty, 5))  ! 2;
}.play

)

(
{

	Duty.ar( Dseq([Dseries(-1.0,0.1,20),Dseries(1.0,-0.1,20)],inf), 0, Dseq([1000],inf)) * 0.1;

}.plot
)


( // DemandEnv for waveform

{
 DemandEnvGen.ar(
                Dseq([-1, 0.1,  Dwhite(-0.1, 0.1, 5), Dwhite(-0.2, 0.2, 5)], inf),
		SampleDur.ir * 8, 1, 0,  1, Impulse.ar(1)) * Line.ar(0, 0.5, 10) ! 2
}.play

)



( // DemandEnv for saw

{

DemandEnvGen.ar(
		Dseq([Dseries(-0.5, 0.1, 15)], inf),
        SampleDur.ir * 50
) ! 2

}.play

)


(

// Sequences of random walks determined by number of breakpoints (adapted from Sergio Luque's model)

{
  var points = 10, durFrom = 5, durTo = 15, durStep=0.1, ampFrom=(-0.5), ampTo=0.5, ampStep=0.01;
  var amps = { Dbrown(ampFrom, ampTo, 0.01) } ! points;
  var durations = { Dbrown(durFrom, durTo, durStep) } ! points;
  var series = Array.series(points, 0, 1);

	DemandEnvGen.ar(
		Dswitch1(amps, Dseq(series, inf)),
		Dswitch1(durations, Dseq(series, inf)
	) * SampleDur.ir ) ! 2;

}.play

);
