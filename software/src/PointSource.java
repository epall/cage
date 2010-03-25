import javax.swing.*;
import java.io.IOException;
import java.util.concurrent.ConcurrentLinkedQueue;

/**
 * Exposes an interface for getting a stream of points from the accelerometer
 */
public class PointSource {
    private ConcurrentLinkedQueue<AccelerometerPoint> points = new ConcurrentLinkedQueue<AccelerometerPoint>();
    private ConcurrentLinkedQueue<Exception> errors = new ConcurrentLinkedQueue<Exception>();
    private Usbmodem modem = new Usbmodem();
    private ModemThread runLoop;

    private volatile boolean doConnect = false;
    private volatile boolean doDisconnect = false;
    private volatile boolean connected = false;

    public PointSource(){
        runLoop = new ModemThread();
        runLoop.start();
    }

    public void connect() {
        doConnect = true;
    }

    public void disconnect() {
        doDisconnect = true;
    }


    public AccelerometerPoint poll() {
        return points.poll();
    }

    public Exception pollErrors() {
        return errors.poll();
    }

    public boolean isConnected() {
        return connected;
    }

    private class ModemThread extends Thread {
        @Override
        public void run() {
            for(;;) {
                if(doConnect){
                    doConnect = false;
                    try {
                        modem.connect("COM4");
                        connected = true;
                    } catch (Exception e) {
                        try {
                            modem.connect("/dev/tty.usbmodem001");
                            connected = true;
                        } catch (Exception f) {
                            errors.add(f);
                        }
                    }
                }

                if(doDisconnect){
                    try {
                        modem.closePort();
                        connected = false;
                    } catch (IOException e){
                        errors.add(e);
                    }
                    doDisconnect = false;
                }

                if(connected) {
                    try {
                        points.add(new AccelerometerPoint(modem.getAccelerometerData()));
                    } catch (NoDataReceivedException e){
                        // silently ignore
                    } catch (IOException e){
                        errors.add(e);
                    }
                }
                try {
                    sleep(connected ? 50 : 500);
                } catch (InterruptedException e) {}
            }
        }
    }
}
