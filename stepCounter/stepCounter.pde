//STEP COUNTER
//Maayan Albert

import android.content.Context;
import android.hardware.Sensor;
import android.hardware.SensorManager;
import android.hardware.SensorEvent;
import android.hardware.SensorEventListener;

Context context;
SensorManager manager;
Sensor sensor;
AccelerometerListener listener;
float ax, ay, az, a, currentSlope, slope, slopeOfSlope, lastSlope, plotOne, plotTwo, totalMean, standardDev;
float[] aData, dataMeans;
IntList windowIndicator;
boolean recording, stepAvailible;
int dataLength, timeBetweenSlopes, windowSize=50, stepCount=0;

void setup() {
  fullScreen();
  
  context = getActivity();
  manager = (SensorManager)context.getSystemService(Context.SENSOR_SERVICE);
  sensor = manager.getDefaultSensor(Sensor.TYPE_ACCELEROMETER);
  listener = new AccelerometerListener();
  manager.registerListener(listener, sensor, SensorManager.SENSOR_DELAY_GAME);
  
  dataLength = 100;
  aData = new float[dataLength];
  dataMeans = new float[dataLength];
  recording = true;
  textFont(createFont("Arial", 60));
  
  for (int i = 0; i < dataLength; i = i+1) {
    aData[i] = 0;
  }
  
  stepAvailible = true;
 
  
}

void draw() {
  background(0);
  
  //draws text
  textAlign(LEFT);
  fill(255);
  textSize(50);
  text("X: " + ax, 10, 60);
  text("Y: " + ay, 10, 120);
  text("Z: " + az, 10, 180);
  textSize(100);
  textAlign(CENTER);
  text("Step: "+stepCount,width/2,380);
  
  
  ///UPDATE DATA SET---------------------------------------------------  
  if(recording){
      for (int i = 0; i < dataLength-1; i = i+1){
        aData[i] = aData[i + 1];
      }
      aData[dataLength - 1] = a;
  }
  
  if (mousePressed){
    recording = !recording;
  }
  //----------------------------------------------------------------- 
  
  ///MEAN LINE---------------------------------------------------
  //discussed with Marisa Lu
  float sum=0;
  float divideBy=0;
  for(int i=dataLength-50;i<dataLength;i++){
    sum +=aData[i]; 
    divideBy+=1;
  }
  float newMean = sum/divideBy;
  stroke(100,255,255);
  line(0, 700+newMean*50, width, 700+newMean*50);
  //-----------------------------------------------------------------
  
  ///DATA ANALYSIS & VISUALIZATION--------------------------------------------------- 
  //calculates slope / discussed with Marisa Lu
  totalMean = 0;
  for (int i = 1; i < dataLength - 1; i = i+1) {
    stroke(255);
    slope = aData[i+1] - aData[i];
    lastSlope = aData[i] - aData[i - 1];
    stroke(255);
    fill(255, 255, 255, 0);
    
    //draws data
    line(i * (1100/dataLength), 700 + aData[i]*50, (i+1) * (1100/dataLength), 700 + aData[i+1]*50);

    //makes more steps availible once the accelerometer crosses zero
    if(aData[i] - newMean < 0){
      stepAvailible = true;
    }

    //calculates standard deviation / discussed Marisa Lu  
    dataMeans[i] = abs(aData[i] - newMean);
    
    for (int j = 1; j < dataLength - 1; j = j+1) {
      totalMean += dataMeans[i];
    }
  
    standardDev = sqrt(totalMean/(dataLength-2));
    
    //counts steps
    if(((slope > 0 && lastSlope < 0) || (slope < 0 && lastSlope > 0)) 
        && (aData[i] - newMean > standardDev*.1) && (stepAvailible == true)){
      fill(255, 0, 0);
      stroke(255, 255, 255, 0);
      ellipse(i * (1100/dataLength), 700 + aData[i]*50, 10, 10);
      stepAvailible = false;
      if(i == dataLength- 2){
        stepCount = stepCount + 1;
      }
    }
  }
}
  ///-------------------------------------------------------------------

///GETS ACCELEROMETER DATA---------------------------------------------
class AccelerometerListener implements SensorEventListener {
  public void onSensorChanged(SensorEvent event) {
    ax = event.values[0];
    ay = event.values[1];
    az = event.values[2];
    a = sqrt(sq(az) + sq(sqrt(sq(ay) + sq(ax))));
  }
  public void onAccuracyChanged(Sensor sensor, int accuracy){
  } 
}
  ///-------------------------------------------------------------------