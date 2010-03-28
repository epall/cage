package cage.port;

import java.io.IOException;

public class NoDataReceivedException extends IOException {
    public NoDataReceivedException(String s) {
        super(s);
    }
}