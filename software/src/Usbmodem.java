import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.lang.Byte;
import java.lang.String;

public class Usbmodem {
    private InputStream input; //input for dongle
    private OutputStream output; //output for dongle
    private SerialPort serialPort;

    public void connect (String portName ) throws Exception
	{
		CommPortIdentifier portIdentifier = CommPortIdentifier.getPortIdentifier(portName);
		if (portIdentifier.isCurrentlyOwned())
		{
			System.out.println("Error: Port is currently in use");
		}
		else
		{
			CommPort commPort = portIdentifier.open(this.getClass().getName(),2000);

			if (commPort instanceof SerialPort)
			{
				serialPort = (SerialPort) commPort;
				//set parameters for usb dongle serial port.
				serialPort.setSerialPortParams(115200,SerialPort.DATABITS_8,SerialPort.STOPBITS_1,SerialPort.PARITY_NONE);

				input = serialPort.getInputStream();
				output = serialPort.getOutputStream();

				byte[] startDongle = {-1, 0x07, 0x03};
				output.write(startDongle);
			}
			else
			{
				System.out.println("Error: Only serial ports are handled by this example");
			}
		}
	}

    public int[] getAccelerometerData() throws Exception
    {
	Usbmodem dongle = this;
	byte[] getAccData = {-1, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00};
	byte[] accData = new byte[24];
	Byte dataHandler;
	int[] accxyz = new int[3];

	dongle.output.write(getAccData);
	dongle.output.flush();
	int len = dongle.input.read(accData);

	while ((len != 7) | ((accData[4] == 0) & (accData[5] == 0) & (accData[6] == 0)))
	{
	    dongle.output.write(getAccData);
	    dongle.output.flush();
	    len = dongle.input.read(accData);
	}
	dataHandler = accData[4];
	accxyz[0] = dataHandler.intValue();
	dataHandler = accData[5];
	accxyz[1] = dataHandler.intValue();
	dataHandler = accData[6];
	accxyz[2] = dataHandler.intValue();

	return accxyz;
    }

    void closePort()
    {
        byte[] startDongle = {-1, 0x07, 0x03};
        byte[] stopDongle = {-1, 0x09, 0x03};

        //Apparently you need to write startDongle before StopDongle in order to actually stop the access point
        try{
            this.output.write(startDongle);
            this.output.write(stopDongle);
        }
        catch(Exception e) {}
	    this.serialPort.close();
    }
}
