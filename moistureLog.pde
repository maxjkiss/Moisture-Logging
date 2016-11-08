import processing.serial.*;
import com.temboo.core.*;
import java.util.Timer;
import java.util.TimerTask;
import java.util.Date;
import com.temboo.Library.Google.Sheets.*;

TembooSession session = new TembooSession("moisture", "growMoistureSensor", "8RabXg4VFekSislcTDCXIMasy61tIKHN");

Serial tenHSPort;
Serial gS1Port;
Serial eC5Port;
 
String googleProfile = "allSensorIncremental";

String multiReadingValues = "[";

AppendValues appendValuesChoreo; 
static Timer timer;

String val;

Boolean nextReadingReady = false;

void setup() {
  appendValuesChoreo = new AppendValues(session);  
  appendValuesChoreo.setCredential(googleProfile);
  
//  String entry = "[[TimeStamp, 10HS, gH1Reading, eC5Reading]]";  
  println("Serial 0" + Serial.list()[0]);
  println("Serial 1" + Serial.list()[1]);
  println("Serial 2" + Serial.list()[2]);
  println("Serial 3" + Serial.list()[3]);
  
  tenHSPort = new Serial(this, Serial.list()[1], 9600);
  gS1Port = new Serial(this, Serial.list()[2], 9600);
  eC5Port = new Serial(this, Serial.list()[3], 9600);
   
  timer = new Timer();
  
  timer.scheduleAtFixedRate(new TimerTask() {
    public void run() {
            nextReadingReady = true;
        }
  }, 0, 5000);  
}

void draw() {
  if(nextReadingReady) {
    takeReading();
    nextReadingReady = false;
  }
}

void takeReading() {
  Float gS1Reading = valueFromPort(gS1Port);
  Float tenHSReading = valueFromPort(tenHSPort);
  Float eC5Reading = valueFromPort(eC5Port);
  
  Date currentDate = new Date();
  String entry = "[[" + currentDate.getTime()+ "," + gS1Reading + "," + tenHSReading + "," + eC5Reading + "]]";
  
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

  {    
    String strval = port.readStringUntil('\n');
    if(strval != null) {
      String trimmedVal = strval.trim();
      if(trimmedVal != null && !trimmedVal.isEmpty()){      
        println("Reading:" + trimmedVal + "<---");
        val = Float.valueOf(trimmedVal);
      }
    }
  } 
  return val;
}