import processing.serial.*;

import net.java.games.input.*;
import org.gamecontrolplus.*;
import org.gamecontrolplus.gui.*;

import cc.arduino.*;
import org.firmata.*;

ControlDevice cont;
ControlIO control;

Arduino arduino;

// VARIABLES PARA MAPEAR INPUTS DEL CONTROL
float thumbRight;
float thumbLeft;
float trigger;
float bumperR;
float bumperL;
float rotOFF;

// VARIABLES QUE CONTROLAN MOVIMIENTOS DE SERVO
float estadoBase=90;
float thumbRight0 = 90;
float thumbLeft0 = 90;
float trigger0 = 90;



void setup() {
  size(500,500);
  control = ControlIO.getInstance(this);
  cont = control.getMatchedDevice("xbox_control");
  
  if(cont == null){
    println("El control no está conectado.");
    System.exit(-1);
  }
  
  println(Arduino.list());
  arduino = new Arduino(this, Arduino.list()[1], 57600);
  arduino.pinMode(8, Arduino.SERVO);
  arduino.pinMode(7, Arduino.SERVO);
  arduino.pinMode(6, Arduino.SERVO);
  arduino.pinMode(5, Arduino.SERVO);
}

public void getUserInput(){
  
  ////////////////////////////  MAPEO DE CADA INPUT DEL CONTROL  /////////////////////////////
  
  trigger = map(cont.getSlider("Shoulder").getValue(), -1, 1, 0, 180);
  thumbRight = map(cont.getSlider("Wrist").getValue(), -1, 1, 0, 180);
  thumbLeft = map(cont.getSlider("Elbow").getValue(), -1, 1, 0, 180);  
  bumperR = map(cont.getButton("BaseRight").getValue(), 0, 1, 0, 1);
  bumperL = map(cont.getButton("BaseLeft").getValue(), 0, 1, 0, 1);
  rotOFF = map(cont.getButton("RotateOFF").getValue(), 0, 1, 0, 1);

  ////////////////////////////  MOVIMIENTO DE SERVO BASE  /////////////////////////////

  if(bumperR==8){
    estadoBase=80;
  }
  if(bumperL==8){
    estadoBase=100;
  }
  if(rotOFF==8){
    estadoBase=90;
  }
  
  ////////////////////////////  MOVIMIENTO DE SERVO SHOULDER  /////////////////////////////
  
  if(trigger == 0.35156786){
      trigger0 = trigger0 + 1;
      if(trigger0 > 179.65118){
        trigger0 = 179.65118;
      }
  }
  if(trigger == 179.65118){
      trigger0 = trigger0 - 1;
      if(trigger0 < 0.35156786){
        trigger0 = 0.35156786;
      }
  }
  
  ////////////////////////////  MOVIMIENTO DE SERVO ELBOW  /////////////////////////////
  
   if(thumbLeft == 0){
      thumbLeft0 = thumbLeft0 + 1;
      if(thumbLeft0 > 180){
        thumbLeft0 = 180;
      }
  }
  if(thumbLeft == 180){
      thumbLeft0 = thumbLeft0 - 1;
      if(thumbLeft0 < 0){
        thumbLeft0 = 0;
      }
  }
    
  ////////////////////////////  MOVIMIENTO DE SERVO WRIST  /////////////////////////////
  
  if(thumbRight == 0){
      thumbRight0 = thumbRight0 + 1;
      if(thumbRight0 > 180){
        thumbRight0 = 180;
      }
  }
  if(thumbRight == 180){
      thumbRight0 = thumbRight0 - 1;
      if(thumbRight0 < 0){
        thumbRight0 = 0;
      }
  }
    
  ////////////////////////////  IMPRIMIR ESTADO DE TODOS LOS SERVOS  /////////////////////////////
  
  if(estadoBase==80){
    println("Base rotation: clockwise");
  }
  else if(estadoBase==100){
    println("Base rotation: counter-clockwise");
  }
  else if(estadoBase==90){
    println("Base rotation: static");
  }
  println("Shoulder: ", trigger0);
  println("Elbow: ", thumbLeft0);
  println("Wrist: ", thumbRight0);
}

void draw(){
  getUserInput();
  arduino.servoWrite(8, (int)estadoBase);
  arduino.servoWrite(7, (int)thumbRight0);
  arduino.servoWrite(6, (int)trigger0);
  arduino.servoWrite(5, (int)thumbLeft0);    
}
