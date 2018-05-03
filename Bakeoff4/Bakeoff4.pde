import java.util.ArrayList;
import java.util.Collections;
import ketai.sensors.*;

KetaiSensor sensor;

float cursorX, cursorY;
float light = 0; 
float proxSensorThreshold = 20; //you will need to change this per your device.

private class Target
{
  int target = 0;
  int action = 0;
}

int trialCount = 5; //this will be set higher for the bakeoff
int trialIndex = 0;
ArrayList<Target> targets = new ArrayList<Target>();

int startTime = 0; // time starts when the first click is captured
int finishTime = 0; //records the time of the final click
boolean userDone = false;
int countDownTimerWait = 0;
float dy,dz= 0;

void setup() {
  size(600, 600); //you can change this to be fullscreen
  frameRate(60);
  sensor = new KetaiSensor(this);
  sensor.start();
  orientation(PORTRAIT);

  rectMode(CENTER);
  textFont(createFont("Arial", 40)); //sets the font to Arial size 20
  textAlign(CENTER);

  for (int i=0; i<trialCount; i++)  //don't change this!
  {
    Target t = new Target();
    t.target = ((int)random(1000))%4;
    t.action = ((int)random(1000))%2;
    targets.add(t);
    println("created target with " + t.target + "," + t.action);
  }
  Collections.shuffle(targets); // randomize the order of the button;
}

void draw() {
  int index = trialIndex;

  //uncomment line below to see if sensors are updating
  //println("light val: " + light +", cursor accel vals: " + cursorX +"/" + cursorY);
  background(80); //background is light grey
  noStroke(); //no stroke

  countDownTimerWait--;

  if (startTime == 0)
    startTime = millis();

  if (index>=targets.size() && !userDone)
  {
    userDone=true;
    finishTime = millis();
  }
  if (userDone)
  {
    text("User completed " + trialCount + " trials", width/2, 50);
    text("User took " + nfc((finishTime-startTime)/1000f/trialCount, 1) + " sec per target", width/2, 150);
    return;
  }
  // left to right 
  if (dz > 0){
    fill(#FAAC4C); 
    rect(10*abs(dz), 300, 20*abs(dz), 600);
  }
  else if (dz < 0) {
    fill(#9095FF); 
    rect(600-10*abs(dz), 300, 20 * abs(dz), 600);
  }
  // down to up
  if (dy>0) {
    fill(#FF6767); 
    rect(300,10*abs(dy),600, 20 * abs(dy));
  }
  else if (dy < 0) {
    fill(#68E580); 
    rect(300, 600-10*abs(dy), 600, 20 * abs(dy));
  }
  Target t = targets.get(index);
  if (t.target==0){fill(#FAAC4C); rect(25, 300, 50, 600);}
  else if (t.target==2){fill(#9095FF); rect(575, 300, 50, 600);}
  else if (t.target==1){fill(#FF6767);rect(300,25,600,50);}
  else if (t.target==3){fill(#68E580);rect(300,575,600,50);}
  fill(255);
  text("Trial " + (index+1) + " of " +trialCount, width/2, 50);
  text("Target #" + (targets.get(index).target)+1, width/2, 100);
  
}

void onOrientationEvent(float x, float y, float z) 
{
  int index = trialIndex;
  dy = y;
  dz = z;
  Target t = targets.get(index);
  int li = (light <= proxSensorThreshold )? 1:0;
  if (userDone || index>=targets.size())
    return;
  if (((z > 30)||(z<30) || (y<30) || (y>30)) && countDownTimerWait<0)
  {
    if (li == t.action)
    {
       print(y,z);
       if (z>30 && t.target == 0) {
         trialIndex++;
       }
       else if (y>30 && t.target == 1){
         trialIndex++;
       }
       else if (z < 30 && t.target == 2){
         trialIndex ++;
       }
       else if (y<30 && t.target == 3){
         trialIndex++;
       }
       else
       {
         if (trialIndex > 0)
           trialIndex--;
           countDownTimerWait = 30;
         print("you failed1");
       }
    }else{
      if (trialIndex > 0) trialIndex--;
       countDownTimerWait = 30;
       print("you failed2");
    }
  }
}


int hitTest() 
{
  for (int i=0; i<4; i++)
    if (dist(300, i*150+100, cursorX, cursorY)<100)
      return i;
  return -1;
}


void onLightEvent(float v) //this just updates the light value
{
  light = v;
}