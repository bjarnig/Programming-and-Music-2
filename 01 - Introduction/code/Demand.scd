////////////////////////////////////////////////////////////////
//
//                   	Demand Rate
//
////////////////////////////////////////////////////////////////


///////////////////////// Demand rate //////////////////////////

( // Demand requires a trigger and a demand rate Ugen
	{
	var seq, demand, pulse;
	seq = Dseq([1,2,3] * 100, inf);
	pulse = Impulse.ar(5);
	demand = Demand.ar(pulse, 0, seq);
	Saw.ar(demand) * 0.1 ! 2
	}.play
)


( // Using Dust and FM
    {
    var freq, trig, reset, seq;
    trig = Dust.kr(50);
    seq = Dseq([72, 75, 79, Drand([82,84,86])], inf).midicps;
    freq = Demand.kr(trig, 0, seq);
	PMOsc.ar([80,120], freq, 10) * 0.1;
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

( // DemandEnv for saw

{

DemandEnvGen.ar(
		Dseq([Dseries(-0.5, 0.1, 15)], inf),
        SampleDur.ir * 50
) ! 2

}.play

)

( // Demand for wavefroms, sequence and varies frequency
	{   var trig, movement;
	trig = Impulse.ar(SinOsc.kr(0.1, 0, 6000, 8000));
	movement = Dseq([Dbrown(-0.1,0.1,0.5,32), Dbrown(-0.8,0.8,0.5,16)], inf);
	Demand.ar(trig, 0, movement) ! 2 * 0.15;
	}.play;
)


