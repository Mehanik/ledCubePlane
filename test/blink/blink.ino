int rsPin = 8;
int ePin  = 9;

inline void please_wait()
{
 delayMicroseconds(100) ;
}

// the setup routine runs once when you press reset:
void setup() {                
  // initialize the digital pin as an output.
  pinMode(rsPin, OUTPUT);
  pinMode(ePin, OUTPUT);

  DDRD = B11111111;
  
  // Clear memory
  digitalWrite(ePin, HIGH);
  digitalWrite(rsPin, HIGH);
  PORTD = B00000001;
  please_wait();
  digitalWrite(ePin, LOW);
  please_wait();

  // Set address to 0
  digitalWrite(ePin, HIGH);
  digitalWrite(rsPin, HIGH);
  PORTD = B00000010;
  please_wait();
  digitalWrite(ePin, LOW);
  please_wait();
  
  // Set address incrementation
  digitalWrite(ePin, HIGH);
  digitalWrite(rsPin, HIGH);
  PORTD = B00000110;
  please_wait();
  digitalWrite(ePin, LOW);
  please_wait();
  
  // Enable PWM
  digitalWrite(ePin, HIGH);
  digitalWrite(rsPin, HIGH);
  PORTD = B00001100;
  please_wait();
  digitalWrite(ePin, LOW);
  please_wait();
}

// the loop routine runs over and over again forever:
void loop() {

  for (uint8_t br = 0; br < 32; br++) // brightness
  {
    for (uint8_t num = 0; num < 64; num++)
    {
      digitalWrite(ePin, HIGH);
      digitalWrite(rsPin, LOW);
      PORTD = br;
      please_wait();
      digitalWrite(ePin, LOW);     
      please_wait();
    }
    delay(100);

    digitalWrite(ePin, HIGH);
    digitalWrite(rsPin, HIGH);
    PORTD = B00000010;
    please_wait();
    digitalWrite(ePin, LOW);
    please_wait();

    //delay(2);
  }
}







