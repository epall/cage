import gnu.io.NoSuchPortException;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionListener;
import java.awt.event.ActionEvent;
import java.io.IOException;

public class MainWindow {

    public JPanel mainPanel;
    public JButton StartAccelerometer;
    public JButton newGesture;
    public JButton MatchGesture;
    public JEditorPane AppScriptPane;
    public JButton StopAccelerometerButton;
    public Usbmodem dongle;
    private ScriptingContainer ruby;


    public MainWindow() {
        this.dongle = new Usbmodem();

        StartAccelerometer.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {
                try {
                    dongle.connect("COM4");
                }
                catch(Exception ex1){
                    try {
                        dongle.connect("/dev/tty.usbmodem001");
                    }
                    catch(Exception ex2) {
                        JOptionPane.showMessageDialog(null, "Unable to connect to dongle");
                    }
                }
                ruby.runScriptlet("$run = true");
                StopAccelerometerButton.setEnabled(true);
                StartAccelerometer.setEnabled(false);
            }
        });

        StopAccelerometerButton.addActionListener(new ActionListener() {
            public void actionPerformed(final ActionEvent e) {
                ruby.runScriptlet("$die = true");
                StopAccelerometerButton.setEnabled(false);
                StartAccelerometer.setEnabled(true);
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

    public static void main(String[] args) {
        final JFrame window = new JFrame("CAGE");
        final MainWindow main = new MainWindow();
        window.setBounds(100, 100, 610, 400);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setContentPane(main.mainPanel);
        SwingUtilities.invokeLater(new Runnable() {
            public void run() {
                window.setVisible(true);
            }
        });
        main.initJRuby();
    }

    private void initJRuby() {
        ruby = new ScriptingContainer();
        ruby.put("$win", this);
        ruby.runScriptlet(PathType.RELATIVE, "src/main.rb");
    }

}
