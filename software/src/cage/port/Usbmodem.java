package cage.port;

import cage.port.NoDataReceivedException;
import gnu.io.CommPort;
import gnu.io.CommPortIdentifier;
import gnu.io.SerialPort;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;

import java.lang.String;

/**
 * This is a simple class for connecting to the Chronos watch dongle with the RXTX package.
 * @author Michael O'Keefe
 * @author Eric Allen
 */

public class Usbmodem {
    private InputStream input; //input for dongle
    private OutputStream output; //output for dongle
    private SerialPort serialPort; //the RXTX serial port used to talk to the dongle

    private static final int TIMEOUT = 100; // milliseconds

    /**
     * Connects the class's <code>SerialPort</code> object to the serial port defined by <code>portName</code>.
     * <p>
     * Parameters:
     * <p>
     * Baud: 115200
     * <p>
     * Data Bits: 8
     * <p>
     * Stop Bits: 1
     * <p>
     * Parity: None
     * <p>
     *
     *
     * @param portName the name of the serial port to be connected to (COM4, /dev/tty.usbmodem001, etc.)
     *
     * @throws Exception
     */
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
                commPort.enableReceiveTimeout(TIMEOUT);
				serialPort = (SerialPort) commPort;
				//set parameters for usb dongle serial port.
				serialPort.setSerialPortParams(115200,SerialPort.DATABITS_8,SerialPort.STOPBITS_1,SerialPort.PARITY_NONE);

				input = serialPort.getInputStream();
				output = serialPort.getOutputStream();

				byte[] startDongle = {-1, 0x07, 0x03}; //code that has to be written to the watch in order to 116
				output.write(startDongle);
			}
			else
			{
				System.out.println("Parallel ports not supported");
			}
		}
	}

    /**
     * Requests a byte of accelerometer data from the watch, and returns the raw values from the string written to the serial port.
     *
     * @return an array of 3 bytes containing the X, Y and Z values from the watch's accelerometer
     *
     * @throws IOException
     */
    public byte[] getAccelerometerData() throws IOException
    {
        byte[] getAccData = {-1, 0x08, 0x07, 0x00, 0x00, 0x00, 0x00};
        byte[] accData = new byte[24];
        byte[] accxyz = new byte[3];

        // sift through non-data packets
        int len;
        long start = System.currentTimeMillis();
        do {
            output.write(getAccData);
            output.flush();
            len = input.read(accData);
            if(len == 0) {
                // read timed out
                throw new NoDataReceivedException("No data received. Dongle dead?");
            }
            if(System.currentTimeMillis()-start > TIMEOUT){
                throw new NoDataReceivedException("No accelerometer data received. Watch not started?");
            }
        } while ((len != 7) | ((accData[4] == 0) & (accData[5] == 0) & (accData[6] == 0)));

        accxyz[0] = accData[4];
        accxyz[1] = accData[5];
        accxyz[2] = accData[6];

        return accxyz;
    }

    /**
     * Closes the <code>Usbmodem</code> port once the program is done accessing it, so that other programs can access the dongle.
     *
     * @throws IOException
     */
    public void closePort() throws IOException
    {
        byte[] startDongle = {-1, 0x07, 0x03};
        byte[] stopDongle = {-1, 0x09, 0x03};


        if(this.output != null){
            //Apparently you need to write startDongle before StopDongle in order to actually stop the access point
            this.output.write(startDongle);
            this.output.write(stopDongle);
            this.output.close();
            this.input.close();
            this.serialPort.close();
            System.err.println("Port closed");
        }
    }
}
