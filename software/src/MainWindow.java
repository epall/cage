import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.io.IOException;

/**
 * Created by IntelliJ IDEA.
 * User: okeefm
 * Date: Feb 8, 2010
 * Time: 2:15:41 PM
 * To change this template use File | Settings | File Templates.
 */
public class MainWindow {

    private JPanel mainPanel;
    private JButton StartAccelerometer;
    private JButton newGesture;
    private JButton MatchGesture;
    private JEditorPane AppScriptPane;
    private JButton StopAccelerometerButton;
    private Usbmodem dongle;
    

    public MainWindow() {

    StartAccelerometer.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {
                try {
                dongle.connect("COM4");
                }
                catch(Exception ex) {
                    ex.printStackTrace();
                }
            }
        });

      StopAccelerometerButton.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {
                dongle.closePort();
            }
        });

      newGesture.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {

            }
        });

        MatchGesture.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {

            }
        });

    }

    public void setDongle(Usbmodem dongle) {
        this.dongle = dongle;
    }

    public static void main(String[] args) {
        final JFrame window = new JFrame("CAGE");
        window.setBounds(100, 100, 500, 400);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setVisible(true);
    }

}
