package cage.port;

import cage.AccelerometerPoint;
import cage.port.NoDataReceivedException;

import java.io.IOException;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * Exposes an interface for getting a stream of points from the Chronos watch accelerometer via a separate thread.
 * @author Eric Allen
 */
public class PointSource {
    private LinkedBlockingQueue<AccelerometerPoint> points = new LinkedBlockingQueue<AccelerometerPoint>();
    private Exception problem = null;
    private Usbmodem modem = new Usbmodem();
    private ModemThread runLoop;

    private volatile boolean doConnect = false;
    private volatile boolean doDisconnect = false;
    private volatile boolean connected = false;

    /**
     * The class's constructor; it creates and starts a new instance of <code>ModemThread</code>.
     */
    public PointSource(){
        runLoop = new ModemThread();
        runLoop.start();
    }

    /**
     * Tells the modem thread to connect to the watch.
     */
    public void connect() {
        doConnect = true;
    }

    /**
     * Tells the modem thread to disconnect from the watch.
     */
    public void disconnect() {
        doDisconnect = true;
    }


    /**
     * Returns the <code>AccelerometerPoint</code> from the head of the {@link LinkedBlockingQueue} if there are no errors to be dealt with.
     * @return <code>AccelerometerPoint</code> at the head of the <code>LinkedBlockingQueue</code>. If the queue is empty, the thread waits for a point to be put in the queue.
     * @throws Exception
     */
    public AccelerometerPoint take() throws Exception {
        if(problem != null){
            Exception temp = problem;
            problem = null;
            throw temp;
        }
        return points.take();
    }

    /**
     * Clears the queue of all points.
     */
    public void clear(){
        points.clear();
    }

    /**
     * Returns the status of the dongle.
     * @return <code>boolean</code> based on the connection status to the Chronos dongle
     */
    public boolean isConnected() {
        return connected;
    }

    /**
     * A subclass of the {@link Thread} class to talk to the Chronos wireless dongle.
     * @author Eric Allen
     */
    private class ModemThread extends Thread {
        @Override
        /**
         * Connects the <code>ModemThread</code> to the dongle. If the connection doesn't succeed, throws an error to the <code>problem</code> exception.
         * <p>
         * The thread will loop in this run command until the thread is killed.
         */
        public void run() {
            for(;;) {
                if(doConnect){
                    doConnect = false;
                    try {
                        modem.connect("COM4"); //Windows
                        connected = true;
                    } catch (Exception e) {
                        try {
                            modem.connect("/dev/tty.usbmodem001"); //Mac
                            connected = true;
                        } catch (Exception f) {
                                try {
                                modem.connect("/dev/ttyACM0"); //Linux
                                connected = true;
                            } catch (Exception g) {
                                problem = g;
                            }
                        }
                    }
                }

                if(doDisconnect){
                    try {
                        if(modem != null)
                            modem.closePort();
                        connected = false;
                    } catch (IOException e){
                        problem = e;
                    }
                    doDisconnect = false;
                }

                if(connected) {
                    try {
                        points.add(new AccelerometerPoint(modem.getAccelerometerData()));
                    } catch (NoDataReceivedException e){
                        // silently ignore
                    } catch (IOException e){
                        problem = e;
                    }
                }
                try {
                    sleep(connected ? 50 : 500);
                } catch (InterruptedException e) {}
            }
        }
    }
}
