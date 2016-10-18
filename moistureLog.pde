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
  String portName = Serial.list()[3];
  myPort = new Serial(this, portName, 9600);
}

void draw(){
  currentTime = hour()+":"+minute()+":"+second()+"."+millis();
  if ( myPort.available() > 0) 
  {
  val = myPort.readStringUntil('\n');
  } 
  println(val);
  
  runAppendValuesChoreo();

  //println("data uploaded");
}

void runAppendValuesChoreo() {  
  multiReadingValues += "[\"" + currentTime + "\", \"" + val + "\"], ";
  
  if(numReadingsAppended == 100) 
  {
    println(multiReadingValues);
    println("sending data!!!!!!!!!!!!!!!!!!!!!!!!!");
    multiReadingValues += "]";
    appendValuesChoreo.setValues(multiReadingValues);
  
    AppendValuesResultSet appendValuesResults = appendValuesChoreo.run();    
    appendValuesChoreo = new AppendValues(session);  
    appendValuesChoreo.setCredential(googleProfile);
    numReadingsAppended = 0;
    multiReadingValues = "[";
  } else {    
    numReadingsAppended++;
  }
}