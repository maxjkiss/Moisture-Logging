import processing.serial.*;
import com.temboo.core.*;
import com.temboo.Library.Google.Sheets.*;

TembooSession session = new TembooSession("moisture", "myFirstApp", "8RabXg4VFekSislcTDCXIMasy61tIKHN");

Serial myPort;
 
String googleProfile = "clickProfile";
String currentTime;
String val;
String multiReadingValues = "[";
Integer numReadingsAppended = 0;
AppendValues appendValuesChoreo; 

void setup() {
  appendValuesChoreo = new AppendValues(session);  
  appendValuesChoreo.setCredential(googleProfile);
  
  numReadingsAppended = 0;
  String portName = Serial.list()[1];
  myPort = new Serial(this, portName, 9600);
}

void draw(){
  currentTime = hour()+":"+minute()+":"+second()+"."+millis();
  if ( myPort.available() > 0) 
  {
  val = myPort.readStringUntil('\n');
  } 
  //println(val);
  
  try {
        if(val != null){
          Float intVal = Float.valueOf(val);
        
          if (intVal > 67 && intVal < 6000){
             runAppendValuesChoreo(intVal);
          }
        }
      } 
  catch (NumberFormatException e) {
        //Log exception?
  }

  //println("data uploaded");
}

void runAppendValuesChoreo(Float newValue) { 
  multiReadingValues += "[";
  //multiReadingValues += currentTime;
  //multiReadingValues += ",";
  multiReadingValues += newValue;
  multiReadingValues += "], ";

  if(numReadingsAppended == 2000) 
  {
    //println(multiReadingValues);
    println("sending data!!!!!!!!!!!!!!!!!!!!!!!!!");
    multiReadingValues += "]";
    appendValuesChoreo.setValues(multiReadingValues);
  
    AppendValuesResultSet appendValuesResults = appendValuesChoreo.run();    
    appendValuesChoreo = new AppendValues(session);  
    appendValuesChoreo.setCredential(googleProfile);
    numReadingsAppended = 0;
    multiReadingValues = "[";
    exit();
  } else {    
    println(numReadingsAppended);
    numReadingsAppended++;
  }
}