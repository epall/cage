package cage;

/**
 * A container for a single point of acceleration data.
 * 
 * @author Eric Allen
 *
 */
public class AccelerometerPoint {
    public byte x;
    public byte y;
    public byte z;

    public AccelerometerPoint(byte[] data){
        x = data[0];
        y = data[1];
        z = data[2];
    }

    public AccelerometerPoint(byte x1, byte y1, byte z1) {
        x = x1;
        y = y1;
        z = z1;
    }

    public byte [] intArray() {
        byte[] retArray = new byte[3];
        retArray[0] = this.x;
        retArray[1] = this.y;
        retArray[2] = this.z;
        return retArray;
    }

}
