

Ambspat : UGen {
	*ar { arg channels=8, in=0.0, azimuth=0, elevation=0, orientation=0.5, mul=1.0, add=0.0;
		var out, ambw, ambx, amby, ambz;
		#ambw, ambx, amby, ambz = PanB.ar(in, azimuth, elevation);
        out = DecodeB2.ar(channels, ambw, ambx, amby, orientation);
		^out.madd(mul, add)
	}
}

Vbspat : UGen {
	*ar { arg channels=8, in=0.0, buf=0, azimuth=0, elevation=1, spread=10, mul=1.0, add=0.0;
		var out = VBAP.ar(channels, in, buf, azimuth, elevation, spread);
		^out.madd(mul, add)
	}
}

Panspat : UGen {
	*ar { arg channels=8, in=0.0, pos=0.0, level=1.0, width=2.0, orientation=0.5, mul=1.0, add=0.0;
		var out = PanAz.ar(channels, in, pos, level, width, orientation);
		^out.madd(mul, add)
	}
}
