package cage;

import cage.AccelerometerPoint;

/**
 * An interface between the Java world and the Ruby <code>Gesture</code> class.
 * @author Eric Allen
 */
public interface Gesture {
    public AccelerometerPoint getPoint(int index);
    public int numPoints();
}
