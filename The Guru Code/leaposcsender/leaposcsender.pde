//variable Declarations
import netP5.*;    //importing for OSC communication
import oscP5.*;    //importing for OSC communication
import de.voidplus.leapmotion.*; //Leap Motion Control library import
LeapMotion leap; //defining leap
OscP5 oscP5;        //for OSC communication var
NetAddress myRemoteLocationSC;    //variable for sending OSC to SC
NetAddress myRemoteLocationMax;   //variable for sending OSC to Max

float solexek, soleyek, sagexek, sageyek, sag1px, sag1py, sag2px, sag2py, sag3px, sag3py, sag4px, sag4py, sag5px, sag5py, sol1px, sol1py, sol2px, sol2py, sol3px, sol3py, sol4px, sol4py, sol5px, sol5py;  // variables defining leap***
PVector solepoz, sagepoz, sag1p, sag2p, sag3p, sag4p, sag5p, sol1p, sol2p, sol3p, sol4p, sol5p;

void setup() {
frameRate(50);
size(100,100); //resoulution (it has to be same with Guda picture size)
background(255); //background color
leap = new LeapMotion(this); //define leap   *****************************************************************************
leap = new LeapMotion(this).allowGestures("circle"); //circle gesture only allowed
oscP5 = new OscP5(this, 8080); //OSCpath
myRemoteLocationSC = new NetAddress("127.0.0.1", 57120); //osc NetAdress
println(oscP5); //osc coms printing
};

void draw(){
  for (Hand hand : leap.getHands ()) {
    

    // ==================================================
    // 2. Hand

    int     handId             = hand.getId();
    PVector handPosition       = hand.getPosition();
    PVector handStabilized     = hand.getStabilizedPosition();
    PVector handDirection      = hand.getDirection();
    PVector handDynamics       = hand.getDynamics();
    float   handRoll           = hand.getRoll();
    float   handPitch          = hand.getPitch();
    float   handYaw            = hand.getYaw();
    boolean handIsLeft         = hand.isLeft();
    boolean handIsRight        = hand.isRight();
    float   handGrab           = hand.getGrabStrength();
    float   handPinch          = hand.getPinchStrength();
    float   handTime           = hand.getTimeVisible();
    PVector spherePosition     = hand.getSpherePosition();
    float   sphereRadius       = hand.getSphereRadius();
    
    
    if (hand.isLeft()) {
      solepoz = hand.getPosition();
      solexek = solepoz.x;
      soleyek = solepoz.y;
      
      Finger sol1 = hand.getFinger(0);
      PVector sol1p = sol1.getPosition();
      sol1px = sol1p.x;
      sol1py = sol1p.y;
      
      Finger sol2 = hand.getFinger(1);
      PVector sol2p = sol2.getPosition();
      sol2px = sol2p.x;
      sol2py = sol2p.y;
      
      Finger sol3 = hand.getFinger(2);
      PVector sol3p = sol3.getPosition();
      sol3px = sol3p.x;
      sol3py = sol3p.y;
      
      Finger sol4 = hand.getFinger(3);
      PVector sol4p = sol4.getPosition();
      sol4px = sol4p.x;
      sol4py = sol4p.y;
      
      Finger sol5 = hand.getFinger(4);
      PVector sol5p = sol5.getPosition();
      sol5px = sol5p.x;
      sol5py = sol5p.y;
      
      float pinchsol = hand.getPinchStrength();
      int pinchsol2 = int(pinchsol*100);
      float grabsol = hand.getGrabStrength();
      int grabsol2 = int(grabsol*100);
      float rollsol = hand.getRoll();
      int rollsol2 = int(rollsol);
      
      OscMessage msg = new OscMessage("/proc/solel"); //constant send 0
      msg.add("Sol El X Ekseni:");  //1
      msg.add(int(solexek));  //2
      msg.add("Sol El Y Ekseni:"); //3
      msg.add(int(soleyek)); //4
      msg.add("Sol El Basparmak X:"); //5
      msg.add(int(sol1px));   //6
      msg.add("Sol El Basparmak Y:"); //7 
      msg.add(int(sol1py)); //8
      msg.add("Sol El Isaret X:"); //9
      msg.add(int(sol2px));  //10
      msg.add("Sol El Isaret Y:"); //11 
      msg.add(int(sol2py)); //12
      msg.add("Sol El Orta X:"); //13
      msg.add(int(sol3px));  //14
      msg.add("Sol El Orta Y:"); //15
      msg.add(int(sol3py)); //16
      msg.add("Sol El Yuzuk X:"); //17
      msg.add(int(sol4px));   //18
      msg.add("Sol El Yuzuk Y:"); //19
      msg.add(int(sol4py)); //20
      msg.add("Sol El Kucuk X:"); //21
      msg.add(int(sol5px));  //22
      msg.add("Sol El Kucuk Y:"); //23 
      msg.add(int(sol5py)); //24
      msg.add("Sol El Pinch:"); //25
      msg.add(pinchsol2); //26
      msg.add("Sol El Grab:"); //27 
      msg.add(grabsol2); //28
      msg.add("Sol El Roll:"); //29 
      msg.add(rollsol2); //30
      oscP5.send(msg, myRemoteLocationSC);
      
      OscMessage msgsolelpoz = new OscMessage("/proc/solelpoz"); //constant send
      msgsolelpoz.add("Sol El X Ekseni:"); 
      msgsolelpoz.add(int(solexek));  
      msgsolelpoz.add("Sol El Y Ekseni:");
      msgsolelpoz.add(int(soleyek));
      oscP5.send(msgsolelpoz, myRemoteLocationSC);
      
      OscMessage msgsolelparmak = new OscMessage("/proc/solelparmak"); //constant send
      msgsolelparmak.add("Sol El Basparmak X:");
      msgsolelparmak.add(int(sol1px));  
      msgsolelparmak.add("Sol El Basparmak Y:"); 
      msgsolelparmak.add(int(sol1py));
      msgsolelparmak.add("Sol El Isaret X:");
      msgsolelparmak.add(int(sol2px));  
      msgsolelparmak.add("Sol El Isaret Y:"); 
      msgsolelparmak.add(int(sol2py));
      msgsolelparmak.add("Sol El Orta X:");
      msgsolelparmak.add(int(sol3px));  
      msgsolelparmak.add("Sol El Orta Y:"); 
      msgsolelparmak.add(int(sol3py));
      msgsolelparmak.add("Sol El Yuzuk X:");
      msgsolelparmak.add(int(sol4px));  
      msgsolelparmak.add("Sol El Yuzuk Y:"); 
      msgsolelparmak.add(int(sol4py));
      msgsolelparmak.add("Sol El Kucuk X:");
      msgsolelparmak.add(int(sol5px));  
      msgsolelparmak.add("Sol El Kucuk Y:"); 
      msgsolelparmak.add(int(sol5py));
      oscP5.send(msgsolelparmak, myRemoteLocationSC);
      
      OscMessage msgsolelpinch = new OscMessage("/proc/solelpinch"); //constant send
      msgsolelpinch.add("Sol El Pinch:"); 
      msgsolelpinch.add(pinchsol2);
      oscP5.send(msgsolelpinch, myRemoteLocationSC);
      
      OscMessage msgsolelgrab = new OscMessage("/proc/solelgrab"); //constant send
      msgsolelgrab.add("Sol El Grab:"); 
      msgsolelgrab.add(grabsol2);
      msgsolelgrab.add("Sol El Y Ekseni:");
      msgsolelgrab.add(int(soleyek));
      msgsolelgrab.add("Sol El Pinch:"); 
      msgsolelgrab.add(pinchsol2);
      oscP5.send(msgsolelgrab, myRemoteLocationSC);
      
      OscMessage msgsolelgrab2 = new OscMessage("/proc/solelgrab2"); //constant send
      msgsolelgrab2.add("Sol El Grab:"); 
      msgsolelgrab2.add(grabsol2);
      oscP5.send(msgsolelgrab2, myRemoteLocationSC);
      
      OscMessage msgsolelroll = new OscMessage("/proc/solelroll"); //constant send
      msgsolelroll.add("Sol El Roll:"); 
      msgsolelroll.add(rollsol2);
      oscP5.send(msgsolelroll, myRemoteLocationSC);
      
    };
    
      
    if (hand.isRight()) {
      sagepoz = hand.getPosition();
      sagexek = sagepoz.x;
      sageyek = sagepoz.y;
      
      Finger sag1 = hand.getFinger(0);
      PVector sag1p = sag1.getPosition();
      sag1px = sag1p.x;
      sag1py = sag1p.y;
      
      Finger sag2 = hand.getFinger(1);
      PVector sag2p = sag2.getPosition();
      sag2px = sag2p.x;
      sag2py = sag2p.y;
      
      Finger sag3 = hand.getFinger(2);
      PVector sag3p = sag3.getPosition();
      sag3px = sag3p.x;
      sag3py = sag3p.y;
      
      Finger sag4 = hand.getFinger(3);
      PVector sag4p = sag4.getPosition();
      sag4px = sag4p.x;
      sag4py = sag4p.y;
      
      Finger sag5 = hand.getFinger(4);
      PVector sag5p = sag5.getPosition();
      sag5px = sag5p.x;
      sag5py = sag5p.y;
      
      float pinchsag = hand.getPinchStrength();
      int pinchsag2 = int(pinchsag*100);
      float grabsag = hand.getGrabStrength();
      int grabsag2 = int(grabsag*100);
      float rollsag = hand.getRoll();
      int rollsag2 = int(rollsag);
      
      OscMessage msg = new OscMessage("/proc/sagel"); //constant send
      msg.add("Sag El X Ekseni:"); 
      msg.add(int(sagexek));  
      msg.add("Sag El Y Ekseni:");
      msg.add(int(sageyek));
      msg.add("Sag El Basparmak X:");
      msg.add(int(sag1px));  
      msg.add("Sag El Basparmak Y:"); 
      msg.add(int(sag1py));
      msg.add("Sag El Isaret X:");
      msg.add(int(sag2px));  
      msg.add("Sag El Isaret Y:"); 
      msg.add(int(sag2py));
      msg.add("Sag El Orta X:");
      msg.add(int(sag3px));  
      msg.add("Sag El Orta Y:"); 
      msg.add(int(sag3py));
      msg.add("Sag El Yuzuk X:");
      msg.add(int(sag4px));  
      msg.add("Sag El Yuzuk Y:"); 
      msg.add(int(sag4py));
      msg.add("Sag El Kucuk X:");
      msg.add(int(sag5px));  
      msg.add("Sag El Kucuk Y:"); 
      msg.add(int(sag5py));
      msg.add("Sag El Pinch:"); 
      msg.add(pinchsag2);
      msg.add("Sag El Grab:"); 
      msg.add(grabsag2);
      msg.add("Sag El Roll:"); 
      msg.add(rollsag2);
      oscP5.send(msg, myRemoteLocationSC);
      
      OscMessage msgsagelpoz = new OscMessage("/proc/sagelpoz"); //constant send
      msgsagelpoz.add("Sağ El X Ekseni:"); 
      msgsagelpoz.add(int(sagexek));  
      msgsagelpoz.add("Sağ El Y Ekseni:");
      msgsagelpoz.add(int(sageyek));
      oscP5.send(msgsagelpoz, myRemoteLocationSC);
      
      OscMessage msgsagelparmak = new OscMessage("/proc/sagelparmak"); //constant send
      msgsagelparmak.add("Sag El Basparmak X:");
      msgsagelparmak.add(int(sag1px));  
      msgsagelparmak.add("Sag El Basparmak Y:"); 
      msgsagelparmak.add(int(sag1py));
      msgsagelparmak.add("Sag El Isaret X:");
      msgsagelparmak.add(int(sag2px));  
      msgsagelparmak.add("Sag El Isaret Y:"); 
      msgsagelparmak.add(int(sag2py));
      msgsagelparmak.add("Sag El Orta X:");
      msgsagelparmak.add(int(sag3px));  
      msgsagelparmak.add("Sag El Orta Y:"); 
      msgsagelparmak.add(int(sag3py));
      msgsagelparmak.add("Sag El Yuzuk X:");
      msgsagelparmak.add(int(sag4px));  
      msgsagelparmak.add("Sag El Yuzuk Y:"); 
      msgsagelparmak.add(int(sag4py));
      msgsagelparmak.add("Sag El Kucuk X:");
      msgsagelparmak.add(int(sag5px));  
      msgsagelparmak.add("Sag El Kucuk Y:"); 
      msgsagelparmak.add(int(sag5py));
      oscP5.send(msgsagelparmak, myRemoteLocationSC);
      
      OscMessage msgsagelpinch = new OscMessage("/proc/sagelpinch"); //constant send
      msgsagelpinch.add("Sag El Pinch:"); 
      msgsagelpinch.add(pinchsag2);
      oscP5.send(msgsagelpinch, myRemoteLocationSC);
      
      OscMessage msgsagelgrab = new OscMessage("/proc/sagelgrab"); //constant send
      msgsagelgrab.add("Sag El Grab:"); 
      msgsagelgrab.add(grabsag2);
      msgsagelgrab.add("Sağ El Y Ekseni:");
      msgsagelgrab.add(int(sageyek));
      msgsagelgrab.add("Sag El Pinch:"); 
      msgsagelgrab.add(pinchsag2);
      oscP5.send(msgsagelgrab, myRemoteLocationSC);
      
      OscMessage msgsagelgrab2 = new OscMessage("/proc/sagelgrab2"); //constant send
      msgsagelgrab2.add("Sag El Grab:"); 
      msgsagelgrab2.add(grabsag2);
      oscP5.send(msgsagelgrab2, myRemoteLocationSC);
      
      OscMessage msgsagelroll = new OscMessage("/proc/sagelroll"); //constant send
      msgsagelroll.add("Sag El Roll:"); 
      msgsagelroll.add(rollsag2);
      oscP5.send(msgsagelroll, myRemoteLocationSC);
    };
  };
};
