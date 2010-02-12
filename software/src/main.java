
public class main {

    public static void main(String[] args) {
        Usbmodem dongle = new Usbmodem();

	try
	{
	   dongle.connect("COM4");
	}
	catch ( Exception e)
	{
	    e.printStackTrace();
	}

	int[] accelerometerInts = new int[3];

	int i = 0;

	while (i < 10)
	{
	    try
	    {
		accelerometerInts = dongle.getAccelerometerData();
		System.out.print("X: ");
		System.out.print(accelerometerInts[0]);
		System.out.print(" Y: ");
		System.out.print(accelerometerInts[1]);
		System.out.print(" Z: ");
		System.out.println(accelerometerInts[2]);
		i++;
	    }
	    catch (Exception e)
	    {
		e.printStackTrace();
	    }
	}

	dongle.closePort();

    }

}
