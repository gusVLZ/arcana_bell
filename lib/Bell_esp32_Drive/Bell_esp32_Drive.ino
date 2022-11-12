#include "EEPROM.h"

#include "WiFi.h"
#include <HTTPClient.h>
#include <algorithm>

bool rebootButton;
bool isConnected;
int countSecsReboot;

void setup() {
  isConnected = false;
  String wifiSSID;
  String wifiPassword;
  float checkEEPROM;
  bool pisca;

  Serial.begin(115200);
  pinMode(LED_BUILTIN, OUTPUT);

  Serial.println("tentativa de iniciar eeprom");
  if (!EEPROM.begin(1000)) {
    Serial.println("erro ao iniciar eeprom");
    delay(1000);
    ESP.restart();
  }

  Serial.println("checando se eeprom já foi gravado");
  checkEEPROM = EEPROM.readFloat(5);
  Serial.println(checkEEPROM);
  if (checkEEPROM < 1) {
    Serial.println("eeprom vazio, iniciando smartconfig");
    WiFi.mode(WIFI_AP_STA);
    WiFi.beginSmartConfig();
    Serial.println("Aguardando configuração.");
    int timeOut = 0;
    while (!WiFi.smartConfigDone()) {
      pisca = !pisca;
      delay(500);

      digitalWrite(LED_BUILTIN, pisca ? HIGH : LOW);
      Serial.print(timeOut);
      Serial.print(" ");
      if(timeOut > 1000){
        ESP.restart();
      }
      timeOut++;
    }

    Serial.println("recebeu dados smartconfig");

    //Wait for WiFi to connect to AP
    Serial.println("tentando se conectar ao wifi");
    timeOut = 0;
    while (WiFi.status() != WL_CONNECTED) {
      delay(200);
      digitalWrite(LED_BUILTIN, HIGH);
      Serial.print(timeOut);
      Serial.print(" ");
      if(timeOut > 150){
        ESP.restart();
      }
      timeOut++;
    }
    Serial.println("WiFi conectado.");

    Serial.print("endereço ip: ");
    Serial.println(WiFi.localIP());

    Serial.println("armazenando endereços: ");
    EEPROM.writeFloat(5, 1);
    EEPROM.writeString(10, WiFi.SSID().c_str());
    EEPROM.writeString(100, WiFi.psk().c_str());
    EEPROM.commit();
    Serial.println("reiniciando placa");
    delay(4000);
    ESP.restart();
  }
  //lê memória eeprom no endereço 10 (90 chars) e no endereço 100 (90 chars);
  Serial.println("lendo ssid e senha do eeprom");
  wifiSSID = EEPROM.readString(10);
  wifiPassword = EEPROM.readString(100);
  Serial.println(wifiSSID.c_str());
  Serial.println(wifiPassword.c_str());
  Serial.println("tentando se conectar ao wifi a partir dos dados armazenados");
  WiFi.begin(wifiSSID.c_str(), wifiPassword.c_str());
  int timeOutWifi = 0;
  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_BUILTIN, pisca ? HIGH : LOW);
    delay(500);
    timeOutWifi++;
    Serial.print(".");
    if (timeOutWifi > 40) {
      break;
    }
  }
  if (timeOutWifi > 40) {
    digitalWrite(LED_BUILTIN, HIGH);
    Serial.println("não foi possível conectar ao wifi");
  } else {
    isConnected = true;
    digitalWrite(LED_BUILTIN, LOW);
    Serial.println("conectado ao wifi");
  }
}

String cleanMac(String mac) {
  String temp = "";
  for (int i = 0; i < mac.length(); ++i) {
    if (mac[i] != ':') {
      temp = temp + mac[i];
    }
  }
  return temp;
}

void loop() {
  // put your main code here, to run repeatedly:
  int bellButton = digitalRead(0);
  rebootButton = digitalRead(0);
  while (rebootButton == LOW) {
    rebootButton = digitalRead(0);

    if (countSecsReboot == 0) {
      Serial.println("botão da campainha foi pressionado");

      digitalWrite(LED_BUILTIN, HIGH);
      delay(500);
      digitalWrite(LED_BUILTIN, LOW);
    
      if (isConnected) {
        Serial.println("tentando enviar post");
        WiFiClientSecure client;
        client.setInsecure();
        const char* serverName = "https://us-central1-arcanabell-6c682.cloudfunctions.net/sendNotification";
        client.connect(serverName, 443);
        HTTPClient http;
        http.begin(client, serverName);
        http.addHeader("Content-Type", "application/json");
        
        Serial.print("mac da placa: ");
        Serial.println(WiFi.macAddress());
        String wifiMacString = cleanMac(WiFi.macAddress());
        Serial.print("mac da placa: ");
        Serial.println(wifiMacString);
        
        String json = "{\"topic\":\"bell_" + wifiMacString + "\",\"title\":\"ArcanaBell\",\"message\":\"Alguém se encontra em sua porta\"}";
        Serial.print("json da requisição: ");
        Serial.println(json);
        
        int httpResponseCode = http.POST(json);
        Serial.print("resposta do server: ");
        Serial.println(httpResponseCode);
        
        http.end();
      }
    }
    
    Serial.println(countSecsReboot);
    if (countSecsReboot > 9) {
      digitalWrite(LED_BUILTIN, HIGH);
      delay(200);
      digitalWrite(LED_BUILTIN, LOW);
      delay(200);
      digitalWrite(LED_BUILTIN, HIGH);
      delay(200);
      digitalWrite(LED_BUILTIN, LOW);
      delay(200);
      digitalWrite(LED_BUILTIN, HIGH);
      delay(200);
      digitalWrite(LED_BUILTIN, LOW);
      delay(200);
      digitalWrite(LED_BUILTIN, HIGH);
      EEPROM.writeFloat(5, 0);
      EEPROM.commit();
      delay(2000);
      ESP.restart();
    }
    countSecsReboot++;
  }

  delay(100);
  countSecsReboot = 0;
}
