(
//Server Setup

s = Server.local;
//ServerOptions.devices;
Server.default.options.inDevice_("MME : Analogue 1 + 2 (3- Focusrite Us");
Server.default.options.outDevice_("MME : Analogue 1 + 2 (3- Focusrite Us");
Server.default.options.sampleRate_(48000);
s.options.numOutputBusChannels = 2;
s.options.numInputBusChannels = 2;
//s.options.sampleRate_(44100);
s.options.memSize_(8192*8); //if need more memory
s.newBusAllocators;
NetAddr.langPort;


MIDIClient.init;
MIDIIn.connectAll;

ServerBoot.removeAll;
ServerTree.removeAll;
ServerQuit.removeAll;

//Global Variables

~out = 0; //For changing global out

//HID
HID.findAvailable; //find HIDs
HID.postAvailable; //Show me whats there as HID
~myhid = HID.open(1118, 673); //HID ID for Xbox Controller
~selectednotes = [60,62,64,66,67,69,71,72];
~selectednotes2 = ((~selectednotes-12)++~selectednotes++(~selectednotes+12)).as(Set).as(Array).sort;
~selectednotes3 = ((~selectednotes-24)++(~selectednotes-12)).as(Set).as(Array).sort;

~calc = {~selectednotes = ~notelistforac; ~selectednotes2 = ((~selectednotes-12)++~selectednotes++(~selectednotes+12)).as(Set).as(Array).sort; ~selectednotes3 = ((~selectednotes-24)++(~selectednotes-12)).as(Set).as(Array).sort;};

~sncnt = 0;
~chrdctrls = 0;
~playctrls = 0;



//For Tracking Notes
~acmaxnotemidi = 90;//--------------->Max midi note for capture notes
~acmimnotemidi = 52;//--------------->Min midi note for capture notes
~ptacinctrl = 1;//------------------->Control Switch for capture replay
~capturetime = 8; //----------------->Capturetime in seconds
~capturedetail = 0.4; //-------------->Samplenote for every 0.1 sec. (10 notes per seconds)

//trigerzza retrig control
~trigcheck = 1;


~bufPath = PathName(thisProcess.nowExecutingPath).parentPath++"buffers/"; //forBufPaths

//Buffer Path
~makeBuffers = {
	b = Dictionary.new;
	PathName(~bufPath).entries.do{
		arg subfolder;
		b.add(
			subfolder.folderName.asSymbol ->
			Array.fill(
				subfolder.entries.size,
				{
					arg i;
					Buffer.read(s, subfolder.entries[i].fullPath);
				}
			)
		);
	};
};


//
~makeBusses = {
	~bus = Dictionary.new;
	~bus.add(\reverb -> Bus.audio(s,2));
~tpmbus = Bus.control(s,1);   //TrackedPitchMidiNo BUS
~tpfbus = Bus.control(s,1);   //TrackedPitchFreq BUS
~tpgbus = Bus.control(s,1);   //Tracked GATE BUS
};

~cleanup = {
	s.newBusAllocators;
	ServerBoot.removeAll;
	ServerTree.removeAll;
	ServerQuit.removeAll;
};

~makeNodes = {
	s.bind({
	~mainGrp = Group.new;
	~reverbGrp = Group.after(~mainGrp);
	~trackerGrp = Group.after(~reverbGrp);
	//~triggerzatracker = Synth.new(\tracker, target: ~trackerGrp);
	~reverbSynth = Synth.new(
		\reverb,
		[
			\amp, 1,
			\revtime, 3,
			\mix, 0.7,
			\in, ~bus[\reverb],
			\out, ~out
		],
		~reverbGrp
	);
	});
};


~makeEvents = {
	e = Dictionary.new;
	e.add(\event1 -> {~looperOSC.value;}); //LOOPER LEAP
	e.add(\event2 -> {OSCdef(\leapsagel).free;}); //LOOPERLEAP DEACTIVATE
	e.add(\event3 -> {~rainsyn = Synth(\rainmaker); ~rainmakerz.value;~rainmakerz2.value;});
	e.add(\event4 -> {OSCdef(\raingenerator1).free; OSCdef(\raingenerator2).free; Routine({~rainsyn.set(\amp, 0); 1.wait; ~rainsyn.free;});});
	e.add(\event5 -> {~bufshow = Synth(\tmbuf2, [\bufname, ~reichrein]); ~showleap.value;~showleap2.value;}); //buffershow
	e.add(\event6 -> {Routine({~bufshow.set(\amp, 0); 3.wait; ~bufshow.free;OSCdef(\showleap).free;OSCdef(\showleap2).free;}).play;};);  //birds ambient stop
	e.add(\event7 -> {~scrtchy = Synth(\scratch2, [\pos, 0, \push, 0, \bufname, ~reichrein]); ~scratchosc.value;}); //buffershow
	e.add(\event8 -> {Routine({~scrtchy.set(\amp, 0); 2.wait; ~scrtchy.free;OSCdef(\scratch2osc).free;}).play};);  //birds ambient stop
	e.add(\event9 -> {~trackersynthRout = Routine({if(~ptacinctrl == 1){~ptacinctrl = 0;~notelistforac = Array.new(~capturetime*(1/~capturedetail));(~capturetime*(1/~capturedetail)).do{~notelistforac.add(~tpmbus.getSynchronous.asInteger); ~capturedetail.wait;};0.03.wait; (~notelistforac.size).do{arg i; if ((~notelistforac[i] >= ~acmaxnotemidi) || (~notelistforac[i] <= ~acmimnotemidi)) {~notelistforac[i]=0}}; 0.03.wait; ~notelistforac = ~notelistforac.as(Set).as(Array).sort;0.03.wait;~notelistforac.removeAt(0); ~notelistforac.postln;~trackersynth.free;0.03.wait; ~ptacinctrl = 1; 0.1.wait; ~calc.value;}}).play;}); //CAPTURE SCALE FROM INPUT
	e.add(\event10 -> {~pickupscale = Array.fill(10, {[~notelistforac.choose,~notelistforac.choose,~notelistforac.choose];});(~pickupscale.size).do{arg i; ~pickupscale[i] = ~pickupscale[i] ++ (~pickupscale[i]+12).round ++ (~pickupscale[i]-12) ++ (~pickupscale[i]-24);};
};); //leapinst
	e.add(\event11 -> {~chordcontrol3.play;});
	e.add(\event12 -> {~chordcontrol3.stop;});
	e.add(\event13 -> {~thereminx = Synth(\theremin, [\amp, 0]);~grabnotesfromac1.value;~grabnotesfromac2.value;});
	e.add(\event14 -> {~thereminx.free; OSCdef(\grabnotesfromac2).free;  OSCdef(\grabnotesfromac1).free; });
	e.add(\event15 -> {~looperOSC2.value;}); //LOOPER LEAP
	e.add(\event16 -> {OSCdef(\leapsolel).free;}); //LOOPERLEAP DEACTIVATE
};

//Register Functions
ServerBoot.add(~makeBuffers);
ServerBoot.add(~makeBusses);
ServerQuit.add(~cleanup);

//Server Boot
s.waitForBoot({
	s.sync;
	1.wait;
	~lupibuf = Buffer.alloc(s, s.sampleRate * 4); //For looper synth buf
	~lupibuf2 = Buffer.alloc(s, s.sampleRate * 8); //For looper synth buf
	~makeNodes.value;
	~makeEvents.value;


	//SYNTHDEFS----------------------------

	//REVERB
	SynthDef(\reverb, {
		arg in, predelay = 0.1, revtime = 1.8, lpf = 4500, mix = 0.4, amp = 1, out = 0;
		var dry, wet, temp, sig;
		dry = In.ar(in,2);
		temp = In.ar(in,2);
		wet = 0;
		temp = DelayN.ar(temp, 0, 2, predelay);
		16.do{
			temp = AllpassN.ar(temp, 0.05, {Rand(0.001, 0.05)}!2, revtime);
			temp = LPF.ar(temp, lpf);
			wet = wet + temp;
		};
		sig = XFade2.ar(dry, wet, mix*2-1, amp);
		Out.ar(out, sig);
	}).add;

	s.sync;

			SynthDef(\tracker, {
	var track, trackgate;
	# track, trackgate = Pitch.kr(SoundIn.ar(0, minFreq: 60, maxFreq: 8000, ampThreshold: 0.6, peakThreshold: 0.8));
	~trackedpitchfreq = track;
	~trackedpitchmidi = track.cpsmidi.round(1);
	Out.kr(~tpfbus, ~trackedpitchfreq);
	Out.kr(~tpmbus, ~trackedpitchmidi);
	Out.kr(~tpgbus, trackgate);
}).add;

	s.sync;

	//LOOPER SYNTHS

	SynthDef(\looper, {
		arg lpffr = 20000;
		var mic, trig, max, ptr, loop, rec, mix;
		var xfade = \xfade.kr(0.02);
		var buf = \buf.kr(0);
		mic = SoundIn.ar(\in.ir(0));
		trig = Trig1.ar(\trig.tr(0), ControlDur.ir);
		max = Sweep.ar(trig, SampleRate.ir * \run.kr(0));
		ptr = Phasor.ar(trig, 1, 0, max, 0);
		loop = BufRd.ar(1, buf, ptr);
		rec = sum([
			mic * \reclev.kr(0).varlag(xfade,-2),
			loop * \prelev.kr(0).varlag(xfade,-2)
		]);
		rec = rec * \recAmp.kr(1).varlag(xfade,-2);
		BufWr.ar(rec, buf, ptr);
		mix = sum([
			LPF.ar(loop, lpffr)* \loopAmp.kr(1).varlag(xfade,-2),
			mic * \micAmp.kr(0).varlag(xfade,-2)
		]);
		mix = mix * \mixAmp.kr(1).varlag(xfade,-2);
		Out.ar(\out.ir(0), mix!2);
	}).add;

	s.sync;

		SynthDef(\looper2, {
		arg lpffr = 20000;
		var mic, trig, max, ptr, loop, rec, mix;
		var xfade = \xfade.kr(0.02);
		var buf = \buf.kr(0);
		mic = SoundIn.ar(\in.ir(0));
		trig = Trig1.ar(\trig.tr(0), ControlDur.ir);
		max = Sweep.ar(trig, SampleRate.ir * \run.kr(0));
		ptr = Phasor.ar(trig, 1, 0, max, 0);
		loop = BufRd.ar(1, buf, ptr);
		rec = sum([
			mic * \reclev.kr(0).varlag(xfade,-2),
			loop * \prelev.kr(0).varlag(xfade,-2)
		]);
		rec = rec * \recAmp.kr(1).varlag(xfade,-2);
		BufWr.ar(rec, buf, ptr);
		mix = sum([
			LPF.ar(loop, lpffr)* \loopAmp.kr(1).varlag(xfade,-2),
			mic * \micAmp.kr(0).varlag(xfade,-2)
		]);
		mix = mix * \mixAmp.kr(1).varlag(xfade,-2);
		Out.ar(\out.ir(0), mix!2);
	}).add;

	s.sync;


	//FOR CHORDS

SynthDef(\blonp, {
	arg f1Freq=0.1, f2Freq=1.1, f3Freq=2.2, nFreq=440, m1Ratio=1, m2Ratio=2, m3Ratio=3,
	amp=0.1, dur=6, ampM=0.84 , pan=0;
	var sig, car1, mod1, car2, mod2, car3, mod3, env, index;
	index = LFNoise1.kr(0.2).range(2, 12);
	env = EnvGen.kr(Env.new([0, 0.70, 0.70, 0], [dur*0.2, dur*0.1, dur*0.7], -4), doneAction:2);
	mod1 = SinOsc.ar([nFreq * m1Ratio, nFreq+0.7 * m1Ratio], mul:nFreq * m1Ratio * index) * ampM;
	car1 = SinOsc.ar(f1Freq + mod1);
	mod2 = SinOsc.ar([nFreq * m2Ratio, nFreq+1.4 * m2Ratio], mul:nFreq * m2Ratio * index) * ampM;
	car2 = SinOsc.ar(f2Freq + mod2);
	mod3 = SinOsc.ar([nFreq * m3Ratio, nFreq+0.35 * m3Ratio], mul:nFreq * m3Ratio * index) * ampM;
	car3 = SinOsc.ar(f3Freq + mod3) * 0.4;
	sig = car1 + car2 + car3 * env * amp;
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;

	//RAINMAKER SYNTH
SynthDef(\rainmaker, {
	arg amp = 0, alt = 40, ust = 50, wind = 1, thunder = 1, drops = 1;
	var sigout, sig1, sig2;
	sig1 = tanh(3 * GVerb.ar(HPF.ar((PinkNoise.ar(0.08+LFNoise1.kr(0.3,0.02))*wind.varlag(1))+(drops.varlag(0.1) * LPF.ar(Dust2.ar(LFNoise1.kr(0.2).range(alt,ust)),7000)),400),250,50,0.25,drylevel:0.3) * Line.kr(0,1,10));
	sig2 = (GVerb.ar(LPF.ar(10 * HPF.ar(PinkNoise.ar(LFNoise1.kr(3).clip(0,1)*LFNoise1.kr(2).clip(0,1) ** 1.8), 20),LFNoise1.kr(1).exprange(100,2500)).tanh,270,30,0.7,drylevel:0.5) * Line.kr(0,0.7,30));
	sig2 = sig2 * thunder.varlag(2);
	sigout = sig1 + sig2;
	sigout = sigout * amp.varlag(2);
	sigout = Limiter.ar(sigout);
	Out.ar(0,sigout);
}).add;

	//BufSpeedSynth
SynthDef(\tmbuf2, {
	arg bufname, rate = 0, stpos = 0, looping = 1, amp = 1, fader = 3, vibfreq = 40, decayt = 1.0, trig = 1, mixi= 0.5, vibrate = 1;
	var sig, sig2, sigout;
	sig = PlayBuf.ar(1, bufname, rate.varlag(3), trig, stpos, looping, doneAction:0);
	sig = CombL.ar(sig, decaytime: decayt);
	sig2 = sig * Blip.ar(Vibrato.kr(vibfreq.varlag(0.2),vibfreq,0.02));
	sigout = (sig*(1-mixi)) + (sig2*mixi);
	sigout = sigout * amp.varlag(fader);
	sigout = Splay.ar(sigout);
	Out.ar(0,sigout);
}).add;

	s.sync;


	//Thereminlike
SynthDef.new(\theremin, {
	arg freq = 440, amp = 0.08, revmix= 0.5, revroom = 0.5, freq2 = 1000;
	var signal, signal2;
	signal = SinOsc.ar(freq.varlag(0.1));
	signal2 = LFSaw.ar(freq2.varlag(0.1));
	signal = signal*signal2;
	signal = signal * amp.varlag(0.02);
	signal = Splay.ar(signal);
	signal = FreeVerb.ar(signal, revmix.varlag(0.2), revroom.varlag(0.2));
	//DetectSilence.ar(signal, doneAction: 2);
	Out.ar(0, signal);
}).add;

	s.sync;


//Wavetable for synth
	~chrdsbuf = Buffer.alloc(s, 8192);
	~chrdsbuf.sine2(
	Array.exprand(24, 1, 16).round.sort,
	Array.exprand(24, 0.1, 1).sort.reverse,
	asWavetable:true
);

	s.sync;

	SynthDef(\chordidi,{
	arg m=60;
	var sig, n;
	n = m.midicps* Rand(-0.15,0.15).midiratio;
		sig = Osc.ar(~chrdsbuf, n) * 0.1;
		sig = sig * SinOsc.kr(Rand(0.1,0.15), Rand(0,2pi)).range(0.2,1);
		sig = LPF.ar(sig, n * 2);
		sig = Pan2.ar(sig, rrand(-0.9,0.9));
		sig = sig * Env([0,1,0],[6,6],[1,-1]).kr(2);
	    sig = Splay.ar(sig);
	Out.ar(0,sig);
}).add;

	s.sync;

	SynthDef(\scratch2, {
	arg pos, push, bufname, amp = 1.5;
    var signal, speed;
	speed = pos.varlag(0.15);
	speed = speed - DelayN.kr(speed, 0.1, 0.1);
	speed = push.varlag(0.3) + speed;
	signal = PlayBuf.ar(1, bufname, speed, loop: 1);
	signal = signal * amp.varlag(1.5);
	signal = Splay.ar(signal);
	Out.ar(0,signal);
}).add;

	s.sync;

	SynthDef(\xboxsynth1, {
	arg fq, amp = 1, revmix = 0.3, room = 0.3, pan = 0, synthmix = 0.5, gate = 0, pulsy = 1, noizy=1, lpfiltfreq = 20000, hpfiltfreq = 80, bpfiltfreq = 1000, rqu=1.5;
	var sig1, sig2, sigout, synmix, fqlag;
	synmix = synthmix.linlin(0,1,0,1);
	fqlag = fq.varlag(0.5);
	sig1 = (SinOsc.ar(fqlag)*Pulse.ar(pulsy)/3) + ((LFSaw.ar(fqlag/4) * SinOsc.ar(noizy))/3) + ((LFSaw.ar(fqlag/1.01) * SinOsc.ar(noizy/1.01))/3);
	sig2 = (LFTri.ar(fqlag)*Pulse.ar(noizy)/3) + ((SinOsc.ar(fqlag/8)* LFTri.ar(pulsy))/3) + ((SinOsc.ar(fqlag/1.01)* LFTri.ar(pulsy)/1.01)/3);
	sigout = ((sig1*synmix.varlag(0.1)) + (sig2*(1-synmix.varlag(0.1)))) * amp.varlag(0.5) * gate.varlag(0.5);
	sigout = LPF.ar(sigout, lpfiltfreq.varlag(0.1));
	sigout = HPF.ar(sigout, hpfiltfreq.varlag(0.1));
	sigout = BPF.ar(sigout, bpfiltfreq.varlag(0.1), rqu.varlag(0.1));
	sigout = FreeVerb.ar(sigout, revmix.varlag(0.5), room.varlag(0.5), 0.9);
	sigout = Pan2.ar(sigout, pan.varlag(0.1));
	Out.ar(0, sigout);
}).add;

		s.sync;

(
SynthDef(\butsynths, {
	arg f1Freq=0.1, f2Freq=1.1, f3Freq=2.2, nFreq=440, m1Ratio=1, m2Ratio=2, m3Ratio=3,
	amp=0.015, durl=16, ampM=0.84 , pan=0, gate;
	var sig, car1, mod1, car2, mod2, car3, mod3, env, index;
	index = LFNoise1.kr(0.2).range(2, 12);
	env = EnvGen.kr(Env.new([0, 0.70, 0.70, 0], [durl*0.25, durl*0.25, durl*0.5], curve: -4), doneAction:2);
	mod1 = SinOsc.ar([nFreq * m1Ratio, nFreq+0.7 * m1Ratio], mul:nFreq * m1Ratio * index) * ampM;
	car1 = SinOsc.ar(f1Freq + mod1);
	mod2 = SinOsc.ar([nFreq * m2Ratio, nFreq+1.4 * m2Ratio], mul:nFreq * m2Ratio * index) * ampM;
	car2 = SinOsc.ar(f2Freq + mod2);
	mod3 = SinOsc.ar([nFreq * m3Ratio, nFreq+0.35 * m3Ratio], mul:nFreq * m3Ratio * index) * ampM;
	car3 = SinOsc.ar(f3Freq + mod3) * 0.4;
	sig = car1 + car2 + car3 * env * amp.varlag(1);
	sig = FreeVerb.ar(sig, 0.4, 0.4, 0.5);
	sig = Pan2.ar(sig, pan);
	Out.ar(0, sig);
}).add;
);

	s.sync;

//ChordsRoutine for Event


~chordcontrol3 = {Routine({(
Synth(\chordidi, [\m, ~notelistforac.choose]);
Synth(\chordidi, [\m, ~notelistforac.choose]);
Synth(\chordidi, [\m, ~notelistforac.choose]);
Synth(\chordidi, [\m, ~notelistforac.choose]);
Synth(\chordidi, [\m, ~notelistforac.choose]);
Synth(\chordidi, [\m, ~notelistforac.choose]);
10.wait;
~chordcontrol3.reset;
)
	}).play;};

	s.sync;

		//Server Tree prep for loopers etc.
	ServerTree.add(~makeNodes);
	ServerTree.add(~makeEvents);
	0.2.wait;
		~looper = Synth(
		\looper, [
			\in, 0,
			\buf, ~lupibuf.bufnum,
			\out, ~bus[\reverb]
		], ~mainGrp
	);
	0.2.wait;
	~looper2 = Synth(
		\looper2, [
			\in, 0,
			\buf, ~lupibuf2.bufnum,
			\out, ~bus[\reverb]
		], ~mainGrp
	);

	0.2.wait;

		~fok = Synth(
		\xboxsynth1, [
			\gate, 0,
			\out, 0
		], ~mainGrp
	);

		0.2.wait;

	~startrakker = Synth(
		\tracker,
		target: ~mainGrp
	);


	0.4.wait;


		s.sync;
	///OSC*********
	~sagelcontrol = 0;
	~sagdubctrl = 1;
	~sagdubctrl = 0;
	~sagrecctrl = 0;
	~sagfadectrl = 0;
	~sagfadectrl2 = 1;
	~sagelcontrol31 = 0;
	~sagdubctrl32 = 1;
	~sagdubctrl32 = 0;
	~sagrecctrl31 = 0;
	~sagfadectrl31 = 0;
	~sagfadectrl312 = 1;

	~rainmakerz = {OSCdef(\raingenerator1, {arg msg;
	msg[28].postln;
	~rainsyn.set(\drops, msg[4].linlin(10,160,1,0.05));
	~rainsyn.set(\thunder, msg[28].linlin(0,100,0,3));
	~rainsyn.set(\alt, msg[4].linlin(10,160,80,14));
	~rainsyn.set(\ust, msg[4].linlin(10,160,100,20));
	}, "/proc/sagel");};

~rainmakerz2 = {OSCdef(\raingenerator2, {arg msg;
	~rainsyn.set(\wind, msg[4].linlin(10,160,1,0.05));
	~rainsyn.set(\amp, msg[30].abs.linlin(20,150,1,0));
}, "/proc/solel");};

	~looperOSC = {OSCdef(\leapsagel, {arg msg;
		case
		{(msg[28]>=90) && (msg[2]>=55) && (msg[4]>=50) && ~sagrecctrl==0} {~looper.set(\trig, 1, \run, 1, \reclev, 1, \prelev, 1);~sagrecctrl = 1; ~sagplctrl = 0; "kayit girdi".postln;}
		{(msg[28]>=90) && (msg[4]<=50) && ~sagdubctrl == 0} {~looper.set(\run, 0, \reclev, 1, \prelev, -1.dbamp); ~sagdubctrl = 1; ~sagplctrl = 0;"overdub girdi".postln;}
		{(msg[28]<=90) && ~sagrecctrl==1 && ~sagplctrl == 0} {~looper.set(\run, 0, \reclev, 0, \prelev, 1);~sagplctrl = 1;~sagdubctrl = 0;"play".postln;}
		{(msg[26] == 100) && ~sagfadectrl == 0} {~looper.set(\loopAmp, 0, \xfade, 2); ~sagfadectrl2 = 0;}
		{(msg[30] >= 160) && ~sagfadectrl2 == 0} {~looper.set(\loopAmp, 1, \xfade, 2); ~sagfadectrl = 0;}
		{(msg[2]<=40) && (msg[28]>=90) && ~sagfadectrl2 == 0}{~lupibuf.zero; ~looper.set(\trig, 1, \run, 0, \reclev, 0, \prelev, 0, \xfade, 0.02);~sagrecctrl = 0;"silindi".postln;}
		{true} {nil};
	}, "/proc/sagel");};

		~looperOSC2 = {OSCdef(\leapsolel, {arg msg;
		case
		{(msg[28]>=90) && (msg[2]>=55) && (msg[4]>=50) && ~sagrecctrl31==0} {~looper2.set(\trig, 1, \run, 1, \reclev, 1, \prelev, 1);~sagrecctrl31 = 1; ~sagplctrl31 = 0; "kayit girdi2".postln;}
		{(msg[28]>=90) && (msg[4]<=50) && ~sagdubctrl32 == 0} {~looper2.set(\run, 0, \reclev, 1, \prelev, -1.dbamp); ~sagdubctrl32 = 1; ~sagplctrl31 = 0;"overdub girdi2".postln;}
		{(msg[28]<=90) && ~sagrecctrl31==1 && ~sagplctrl31 == 0} {~looper2.set(\run, 0, \reclev, 0, \prelev, 1);~sagplctrl31 = 1;~sagdubctrl32 = 0;"play2".postln;}
		{(msg[26] == 100) && ~sagfadectrl31 == 0} {~looper2.set(\loopAmp, 0, \xfade, 2); ~sagfadectrl312 = 0;}
		{(msg[30] >= 160) && ~sagfadectrl312 == 0} {~looper2.set(\loopAmp, 1, \xfade, 2); ~sagfadectrl31 = 0;}
		{(msg[2]<=40) && (msg[28]>=90) && ~sagfadectrl312 == 0}{~lupibuf2.zero; ~looper2.set(\trig, 1, \run, 0, \reclev, 0, \prelev, 0, \xfade, 0.02);~sagrecctrl31 = 0;"silindi2".postln;}
		{true} {nil};
	}, "/proc/solel");};

~showleap = {OSCdef(\showleap, {arg msg;
		//msg.postln;
		case
		{(msg[30]>=40) && (msg[30]<=150)} {~bufshow.set(\rate, msg[4].linlin(-30,85,-1,1))}
		{true} {nil};
	}, "/proc/sagel");};


~showleap2 = {OSCdef(\showleap2, {arg msg;
	    ~bufshow.set(\vibfreq,msg[4].linlin(0,80,20,1));
	    ~bufshow.set(\mixi,msg[4].linlin(0,80,0.5,1));
	    ~bufshow.set(\vibrate,msg[4].linlin(0,80,80,10));
		case
		{(msg[26] == 0) && (~trigcontrlbuf == 1)} {~trigcontrlbuf = 0; ~bufshow.set(\trig, 0)}
		{(msg[26] == 100) && (~trigcontrlbuf == 0)} {~trigcontrlbuf = 1; ~bufshow.set(\trig, 1)}
		{true} {nil};
	}, "/proc/solel");};

	~sagfadectrlb = 1;
	~trigcontrlbuf = 1;

	~scratchosc = {OSCdef(\scratch2osc, {arg msg;
		(msg[4]).postln;
		case
		{(msg[4] >= 75)} {~scrtchy.set(\push, 0); ~scrtchy.set(\pos, msg[2].linlin(0,190, -7, 7)) }
		{(msg[4] < 75)} {~scrtchy.set(\push, 1);}
		{true} {nil};
	}, "/proc/sagel");};


	~controlsag = 1;
	~notecluster = [60,62,64,66,67,69,71,72];
	~scalesize = ~notecluster.size;
	~scalesize.do{
	arg item;
	~freqinterval = (106/(item+1));};
	~maplist = Array.new((~notecluster.size)+1);
	~scalesize.do{
	arg item;
	~maplist.add((item+1)*~freqinterval);};
	//~maplist.add(~maplist[(~notecluster.size-1)]*2);


	~leapinsti = {
	OSCdef(\leapinstsag, {arg msg;
			var panner;
			panner = msg[2].linlin(-20,130,-0.9,0.9);

		case
		{(msg[26]>=40) && (msg[4]>=70) && (~controlsag == 1)} {(~notecluster.size-1).do{
		arg item;
		if ((msg[2]>=~maplist[item]) && (msg[2] <= ~maplist[(item+1)]))//BURADA
		{
		~instlmsag = Synth.new(\blonp,[\nFreq, (~notecluster[item].midicps), \amp, 0.03, \dur, 1.8, \pan, panner]);
		~controlsag = 0;~notecluster[item].midicps*8;}};}
		{(msg[4]<=65) && (~controlsag == 0)}{~controlsag = 1;}
		{true} {nil};}, "/proc/sagel");

	OSCdef(\leapinstsol, {arg msg;
		var panner;
		panner = msg[2].linlin(-20,130,-0.9,0.9);
		case
		{(msg[26]>=40) && (msg[4]>=70) && (~controlsag == 1)} {(~notecluster.size-1).do{
		arg item;
			if ((msg[2]>=~maplist[item]) && (msg[2] <= ~maplist[(item+1)]))
		{
		~instlmsol = Synth.new(\blonp,[\nFreq, ((~notecluster[item].midicps)/4), \amp, 0.015, \dur, 10, \pan, panner]);
		~controlsag = 0;}};}
		{(msg[4]<=65) && (~controlsag == 0)}{~controlsag = 1;}
		{true} {nil};}, "/proc/solel");
	};


~grabnotesfromac1 = {OSCdef(\grabnotesfromac1, {arg msg;
	msg[30].postln;
	~thereminx.set(\freq, (msg[4].linexp(10,80,2000,100)));
	~thereminx.set(\revmix, (msg[30].abs.linlin(0,179,0,1)));
	//(msg[4].linlin(10,80,2000,100)).postln;
	}, "/proc/sagel");};

~grabnotesfromac2 = {OSCdef(\grabnotesfromac2, {arg msg;
	(msg[28].linlin(25,60,20.000,800.000)).postln;
	~thereminx.set(\amp, (msg[4].linlin(20,70,0.5,0.0001)));
	~thereminx.set(\revroom, (msg[30].linlin(-179,0,1,0)));
	~thereminx.set(\freq2, (msg[28].linlin(0,100,100,1000)));
	}, "/proc/solel");};

	//Dictionary ayarlarini yap
	~touchmebuflover = b[\songs][1];
	~touchmebufgaylover = b[\songs][0];
	~touchmebuflover2 = b[\songs][2];
	~touchmebufrain = b[\ambient][2];
	~touchmebufbirds = b[\ambient][0];
	~touchmebufocean = b[\ambient][1];
	~touchmebufwind = b[\ambient][3];
	~grabufev = b[\vocal][0];
	~birdof = b[\vocal][0];
	~reichrein = b[\vocal][1];
	~loverarray = [~touchmebuflover,~touchmebufgaylover,~touchmebuflover2];
	s.sync;

	//buraya kadar
	"Ready to go".postln;



	(
//HID Def
HID.action = {arg value, rawValue, usage, page, elid, element, devid, device;
	if (elid==0)
	{
		~leftStickY = value.linlin(-65535,0,0.1,6);
		~fok.set(\pulsy, ~leftStickY);
	};

	if (elid==1)
	{
		~leftStickX = value.linlin(-65535,0,6,0.1);
		~fok.set(\noizy, ~leftStickX);
	};

	if ((elid==2) && (~rscontrolboss == 1))
	{
		~rightStickY = value.linlin(-65535,0,0,0.8);
		~fok.set(\room, ~rightStickY);
	};

	if ((elid==2) && (~rscontrolboss == 3))
	{
		~rightStickY3 = value.linlin(-65535,0,0,1);
		~fok.set(\synthmix, ~rightStickY3);
	};

	if ((elid==3) && (~rscontrolboss == 1))
	{
		~rightStickX = value.linlin(-65535,0,0,0.8);
		~fok.set(\revmix, ~rightStickX);
	};

	if ((elid==3) && (~rscontrolboss == 3))
	{
		~rightStickX3 = value.linlin(-65535,0,0.8,-0.8);
		~fok.set(\pan, ~rightStickX3);
	};

	if ((elid==2) && (~rscontrolboss == 5))
	{
		~rightStickY5 = value.linlin(-65535,0, 10000, 1000);
		~fok.set(\lpfiltfreq, ~rightStickY5);
	};

	if ((elid==3) && (~rscontrolboss == 5))
	{
		~rightStickX5 = value.linlin(-65535,0,800 ,100);
		~fok.set(\hpfiltfreq, ~rightStickX5);
	};

	if ((elid==2) && (~rscontrolboss == 7))
	{
		~rightStickY7 = value.linlin(-65535,0, 1000, 3000);
		~fok.set(\bpfiltfreq, ~rightStickY7);
	};

	if ((elid==3) && (~rscontrolboss == 7))
	{
		~rightStickX7 = value.linlin(-65535,0, 3 ,0.3);
		~fok.set(\rqu, ~rightStickX7);
	};

	if (elid==4)
	{
		~triggers = value.linlin(-65408,-128,0,2);
		~fok.set(\amp, ~triggers);
	};

	if (elid==5)
	{
		~arrow = rawValue;
		if (~arrow!=0)
		{~rscontrolboss = ~arrow;}
	};

	if (elid==6)
	{
		~aBut = value;
		if (~aBut == 1)
		{
		~chordnote = ~tpmbus.getSynchronous.asInteger;
		Synth(\butsynths, [\nFreq, (~chordnote-24).midicps, \gate, ~aBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-17).midicps, \gate, ~aBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-12).midicps, \gate, ~aBut]);
		Synth(\butsynths, [\nFreq, ~chordnote.midicps, \gate, ~aBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+4).midicps, \gate, ~aBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+7).midicps, \gate, ~aBut]);
		}
	};

	if (elid==7)
	{
		~bBut = value;
		if (~bBut == 1)
		{
		~chordnote = ~tpmbus.getSynchronous.asInteger;
		Synth(\butsynths, [\nFreq, (~chordnote-24).midicps, \gate, ~bBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-17).midicps, \gate, ~bBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-12).midicps, \gate, ~bBut]);
		Synth(\butsynths, [\nFreq, ~chordnote.midicps, \gate, ~bBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+3).midicps, \gate, ~bBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+7).midicps, \gate, ~bBut]);
		}
	};

	if (elid==8)
	{
		~xBut = value;
		if (~xBut == 1)
		{
		~chordnote = ~tpmbus.getSynchronous.asInteger;
		Synth(\butsynths, [\nFreq, (~chordnote-24).midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-17).midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-12).midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, ~chordnote.midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+4).midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+7).midicps, \gate, ~xBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+10).midicps, \gate, ~xBut]);
		}
	};

	if (elid==9)
	{
		~yBut = value;
		if (~yBut == 1)
		{
		~chordnote = ~tpmbus.getSynchronous.asInteger;
		Synth(\butsynths, [\nFreq, (~chordnote-24).midicps, \gate, ~yBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-17).midicps, \gate, ~yBut]);
		Synth(\butsynths, [\nFreq, (~chordnote-12).midicps, \gate, ~yBut]);
		Synth(\butsynths, [\nFreq, ~chordnote.midicps, \gate, ~yBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+3).midicps, \gate, ~yBut]);
		Synth(\butsynths, [\nFreq, (~chordnote+6).midicps, \gate, ~yBut]);
		}
	};

	if (elid==10)
	{
		~l1But = value;
		if (~l1But==1)
		{~sncnt = ((~sncnt-1)%(~selectednotes2.size));};
		~fok.set(\fq, ~selectednotes2[~sncnt].midicps);
	};

	if (elid==11)
	{
		~r1But = value;
		if (~r1But==1)
		{~sncnt = ((~sncnt+1)%(~selectednotes2.size));};
		~fok.set(\fq, ~selectednotes2[~sncnt].midicps);
	};

	if (elid==12)
	{
		~backBut = value;
	};

	if (elid==13)
	{
		~startBut = value;
	};

	if (elid==14)
	{
		~lsclick = value;
		if (~lsclick ==1)
		{
		~playctrls = (~playctrls+1)%2;
		};
		if ((~playctrls == 1) && (~lsclick ==1))
		{~fok.set(\gate, 1);};
		if ((~playctrls == 0) && (~lsclick ==0))
		{~fok.set(\gate, 0);};
	};

	if (elid==15)
	{
		~rsclick = value;
		if (~rsclick ==1)
		{
		~chrdctrls = (~chrdctrls+1)%2;
		};
		if ((~chrdctrls == 1) && (~rsclick ==1))
		{~bind = (Pbind(\instrument, \butsynths, \nFreq, Prand([[~selectednotes3.choose.midicps,~selectednotes3.choose.midicps,~selectednotes3.choose.midicps],[~selectednotes3.choose.midicps,~selectednotes3.choose.midicps,~selectednotes3.choose.midicps],[~selectednotes3.choose.midicps,~selectednotes3.choose.midicps,~selectednotes3.choose.midicps],[~selectednotes3.choose.midicps,~selectednotes3.choose.midicps,~selectednotes3.choose.midicps]], inf),\dur, Pseq([20], inf), \durl, Pseq([28], inf),\amp, Pseq([0.05], inf))).play;"start chords".postln;};
		if ((~chrdctrls == 0) && (~rsclick ==0))
		{~bind.stop;"stahp chords".postln;};
	};

/*
	//Tester
	if (elid<=3)
	{
	"Stick Controls: ".post; "LSY:".post; ~leftStickY.round(0.01).post;  " LSX:".post; ~leftStickX.round(0.01).post;  " RSY:".post; ~rightStickY.round(0.01).post;  " RSX:".post; ~rightStickX.round(0.01).post; " LSC:".post; ~lsclick.post;  " RSC:".post; ~rsclick.postln;
	};
	if (elid==4)
	{
	"Trigger Controls: ".post; "Trigger:".post; ~triggers.round(0.01).postln;
	};
	if (elid==5)
	{
	"Arrow:".post; ~arrow.postln;
	};
	if (elid>=6)
	{
	"But Controls: ".post; "A:".post; ~aBut.post;  " B:".post; ~bBut.post;  " X:".post; ~xBut.post;  " Y:".post; ~yBut.post; " L1:".post; ~l1But.post;  " R1:".post; ~r1But.post;  " Back:".post; ~backBut.post;  " Start:".post; ~startBut.postln;
	};
*/
};
);

	~event6control = 1;
	~ptselector = 0;

(
MIDIdef.noteOn(\playtrons, {
	arg vel, nn, chan, src;
	[vel, nn, chan, src].postln; //may delete later
	case
	{src==1 && nn==36 && ~ptselector == 0;} {e[\event1].value;"event1".postln;}
	{src==1 && nn==37 && ~ptselector == 0;} {e[\event2].value;"event2".postln;}
	{src==1 && nn==38 && ~ptselector == 0;} {e[\event3].value;"event3".postln;}
	{src==1 && nn==39 && ~ptselector == 0;} {e[\event4].value;"event4".postln;}
	{src==1 && nn==40 && ~ptselector == 0;} {e[\event5].value;"event5".postln;}
	{src==1 && nn==41 && ~ptselector == 0;} {e[\event6].value;"event6".postln;}
	{src==1 && nn==42 && ~ptselector == 0 && ~event6control == 1;} {e[\event7].value;"event7".postln; ~event6control = 0}
	{src==1 && nn==43 && ~ptselector == 0 && ~event6control == 0;} {e[\event8].value;"event8".postln; ~event6control = 1}
	{src==1 && nn==44 && ~ptselector == 0;} {e[\event9].value;"event9".postln;}
	{src==1 && nn==45 && ~ptselector == 0;} {e[\event10].value;"event10".postln;}
	{src==1 && nn==46 && ~ptselector == 0;} {e[\event11].value;"event11".postln;}
	{src==1 && nn==47 && ~ptselector == 0;} {e[\event12].value;"event12".postln;}
	{src==1 && nn==48 && ~ptselector == 0;} {e[\event13].value;"event13".postln;}
	{src==1 && nn==49 && ~ptselector == 0;} {e[\event14].value;"event14".postln;}
	{src==1 && nn==50 && ~ptselector == 1;} {e[\event15].value;"event15".postln;}
	{src==1 && nn==51 && ~ptselector == 1;} {e[\event15].value;"event15".postln;}
	//{src==1 && nn==50 && ~ptselector == 0;} {~ptselector = ~ptselector+1;("Page:"++(~ptselector+1)).postln;}
	//{src==1 && nn==51 && ~ptselector == 1;} {~ptselector = ~ptselector-1;("Page:"++(~ptselector+1)).postln;}
	//{src==1 && nn==50 && ~ptselector == 1;} {~ptselector = ~ptselector+1;("Page:"++(~ptselector+1)).postln;}
	//{src==1 && nn==51 && ~ptselector == 2;} {~ptselector = ~ptselector-1;("Page:"++(~ptselector+1)).postln;}
	//{src==1 && nn==50 && ~ptselector == 2;} {~ptselector = ~ptselector+1;("Page:"++(~ptselector+1)).postln;}
	//{src==1 && nn==51 && ~ptselector == 3;} {~ptselector = ~ptselector-1;("Page:"++(~ptselector+1)).postln;}
	{src==1 && nn==36 && ~ptselector == 1;} {e[\event15].value;"event15".postln;}
	{src==1 && nn==37 && ~ptselector == 1;} {e[\event16].value;"event16".postln;}
	{src==1 && nn==38 && ~ptselector == 1;} {e[\event17].value;"event17".postln;}
	{src==1 && nn==39 && ~ptselector == 1;} {e[\event18].value;"event18".postln;}
	{src==1 && nn==40 && ~ptselector == 1;} {e[\event19].value;"event19".postln;}
	{src==1 && nn==41 && ~ptselector == 1;} {e[\event20].value;"event20".postln;}
	{src==1 && nn==42 && ~ptselector == 1;} {e[\event21].value;"event21".postln;}
	{src==1 && nn==43 && ~ptselector == 1;} {e[\event22].value;"event22".postln;}
	{src==1 && nn==44 && ~ptselector == 1;} {e[\event23].value;"event23".postln;}
	{src==1 && nn==45 && ~ptselector == 1;} {e[\event24].value;"event24".postln;}
	{src==1 && nn==46 && ~ptselector == 1;} {e[\event25].value;"event25".postln;}
	{src==1 && nn==47 && ~ptselector == 1;} {e[\event26].value;"event26".postln;}
	{src==1 && nn==48 && ~ptselector == 1;} {e[\event27].value;"event27".postln;}
	{src==1 && nn==49 && ~ptselector == 1;} {e[\event28].value;"event28".postln;}
	{src==1 && nn==36 && ~ptselector == 2;} {e[\event29].value;"event29".postln;}
	{src==1 && nn==37 && ~ptselector == 2;} {e[\event30].value;"event30".postln;}
	{src==1 && nn==38 && ~ptselector == 2;} {e[\event31].value;"event31".postln;}
	{src==1 && nn==39 && ~ptselector == 2;} {e[\event32].value;"event32".postln;}
	{src==1 && nn==40 && ~ptselector == 2;} {e[\event33].value;"event33".postln;}
	{src==1 && nn==41 && ~ptselector == 2;} {e[\event34].value;"event34".postln;}
	{src==1 && nn==42 && ~ptselector == 2;} {e[\event35].value;"event35".postln;}
	{src==1 && nn==43 && ~ptselector == 2;} {e[\event36].value;"event36".postln;}
	{src==1 && nn==44 && ~ptselector == 2;} {e[\event37].value;"event37".postln;}
	{src==1 && nn==45 && ~ptselector == 2;} {e[\event38].value;"event38".postln;}
	{src==1 && nn==46 && ~ptselector == 2;} {e[\event39].value;"event39".postln;}
	{src==1 && nn==47 && ~ptselector == 2;} {e[\event40].value;"event40".postln;}
	{src==1 && nn==48 && ~ptselector == 2;} {e[\event41].value;"event41".postln;}
	{src==1 && nn==49 && ~ptselector == 2;} {e[\event42].value;"event42".postln;}
	{src==1 && nn==36 && ~ptselector == 2;} {e[\event43].value;"event43".postln;}
	{src==1 && nn==37 && ~ptselector == 2;} {e[\event44].value;"event44".postln;}
	{src==1 && nn==38 && ~ptselector == 2;} {e[\event45].value;"event45".postln;}
	{src==1 && nn==39 && ~ptselector == 2;} {e[\event46].value;"event46".postln;}
	{src==1 && nn==40 && ~ptselector == 2;} {e[\event47].value;"event47".postln;}
	{src==1 && nn==41 && ~ptselector == 2;} {e[\event48].value;"event48".postln;}
	{src==1 && nn==42 && ~ptselector == 2;} {e[\event49].value;"event49".postln;}
	{src==1 && nn==43 && ~ptselector == 2;} {e[\event50].value;"event50".postln;}
	{src==1 && nn==44 && ~ptselector == 2;} {e[\event51].value;"event51".postln;}
	{src==1 && nn==45 && ~ptselector == 2;} {e[\event52].value;"event52".postln;}
	{src==1 && nn==46 && ~ptselector == 2;} {e[\event53].value;"event53".postln;}
	{src==1 && nn==47 && ~ptselector == 2;} {e[\event54].value;"event54".postln;}
	{src==1 && nn==48 && ~ptselector == 2;} {e[\event55].value;"event55".postln;}
	{src==1 && nn==49 && ~ptselector == 2;} {e[\event56].value;"event56".postln;}
};
));
});

)

///////////////////////////***********************************END CODE********************************************//////////////////////////////////
s.prepareForRecord; // if you want to start recording on a precise moment in time, you have to call this first.

// set location to your home folder (change user with your username)
thisProcess.platform.recordingsDir = "C:/Users/lordr/OneDrive/Desktop/THESIS 4 13/recs";

// instantiate the Recorder
r = Recorder.new(s);

// set very obvious prefix for files
r.filePrefix = "TezPerfKayitCOIL_";

// start recording:
r.record;

// stop recording
r.stopRecording;



		