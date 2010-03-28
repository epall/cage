package cage;

import cage.AccelerometerPoint;

/**
 * Created by IntelliJ IDEA.
 * User: epall
 * Date: Feb 21, 2010
 * Time: 1:25:41 PM
 * To change this template use File | Settings | File Templates.
 */
public interface Gesture {
    public AccelerometerPoint getPoint(int index);
    public int numPoints();
}
