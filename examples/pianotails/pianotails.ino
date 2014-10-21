// TODO: Test this example
#define BLACK_VALUE

void setup()
{
  // Configure as OUTPUT pin from 2 to 5
  for(int i = 2; i < 6; i++)
    pinMode(2, OUTPUT);
}

void loop()
{
  for(int i = 0; i < 4; i++)
    {
      // Check if pin is black
      if((analogRead(i) - BLACK_VALUE) > 10)
	{
	  tap(i+2);
	  break;
	}
    }
  delay(200);
}

void tap(int pin)
{
  digitalWrite(pin, HIGH);
  delay(25);
  digitalWrite(pin, LOW);
}
