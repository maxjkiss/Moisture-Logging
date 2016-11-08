import processing.serial.*;
import com.temboo.core.*;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Date;
import com.temboo.Library.Google.Sheets.*;

TembooSession session = new TembooSession("moisture", "growMoistureSensor", "8RabXg4VFekSislcTDCXIMasy61tIKHN");

Serial tenHSPort;
Serial gH1Port;
Serial eC5Port;
 
String googleProfile = "allSensorIncremental";

String multiReadingValues = "[";

AppendValues appendValuesChoreo; 
static Timer timer;

void setup() {
  println("setting up");
  appendValuesChoreo = new AppendValues(session);  
  appendValuesChoreo.setCredential(googleProfile);
  
//  String entry = "[[TimeStamp, 10HS, gH1Reading, eC5Reading]]";  
  println("Serial list" + Serial.list().length);
  tenHSPort = new Serial(this, Serial.list()[0], 9600);
  gH1Port = new Serial(this, Serial.list()[1], 9600);
  //eC5Port = new Serial(this, Serial.list()[2], 9600);
    
  timer = new Timer();
  
  timer.scheduleAtFixedRate(new TimerTask() {
    public void run() {
            takeReading();
        }
  }, 0, 5000);
}

void takeReading() {
  String currentTime = hour()+":"+minute()+":"+second()+"."+millis();
  println("timer triggered:" + currentTime);  
  
  //tenHSPort = new Serial(this, Serial.list()[2], 9600);
  //gH1Port = new Serial(this, Serial.list()[1], 9600);
  
  Float tenHSReading = valueFromPort(tenHSPort);
  Float gH1Reading = valueFromPort(gH1Port);
  Float eC5Reading = 3.0; //valueFromPort(eC5Port);
  
 
  Date currentDate = new Date();
  String entry = "[[" + currentDate.getTime() + "," + tenHSReading + "," + gH1Reading + "," + eC5Reading + "]]";
  
  appendEntry(entry);
}

void appendEntry(String entry) {    
  println("Appending entry: " + entry);
  appendValuesChoreo.setValues(entry);  
  appendValuesChoreo.run();    
  appendValuesChoreo = new AppendValues(session);  
  appendValuesChoreo.setCredential(googleProfile);
}

Float valueFromPort(Serial port) {
  Float val = 0.0;
  if ( port.available() > 0) 
  {
    String strval = port.readStringUntil('\n');
    if(strval == null){
      
    println("Reading: " + strval);
    val = Float.valueOf(strval);
    }
  } 
  return val;
}