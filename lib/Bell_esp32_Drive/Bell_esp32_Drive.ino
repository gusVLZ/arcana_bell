#include "EEPROM.h"

#include "WiFi.h"

bool rebootButton;
int countSecsReboot;
void setup() {
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
    while (!WiFi.smartConfigDone()) {
      pisca = !pisca;
      delay(500);

      digitalWrite(LED_BUILTIN, pisca ? HIGH : LOW);
      Serial.print(".");
    }

    Serial.println("recebeu dados smartconfig");

    //Wait for WiFi to connect to AP
    Serial.println("tentando se conectar ao wifi");
    while (WiFi.status() != WL_CONNECTED) {
      delay(500);
      digitalWrite(LED_BUILTIN, pisca ? HIGH : LOW);
      Serial.print(".");
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

  while (WiFi.status() != WL_CONNECTED) {
    digitalWrite(LED_BUILTIN, pisca ? HIGH : LOW);
    delay(500);
    Serial.print(".");
  }
  digitalWrite(LED_BUILTIN, LOW);
  Serial.println("conectado ao wifi");

}

void loop() {
  // put your main code here, to run repeatedly:
  rebootButton = digitalRead(0);
  if (rebootButton == LOW) {
    Serial.println("botão da campainha foi pressionado");
    digitalWrite(LED_BUILTIN, HIGH);
    delay(500);
    digitalWrite(LED_BUILTIN, LOW);
  }
  while (rebootButton == LOW) {
    rebootButton = digitalRead(0);
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
    delay(500);
  }
}
