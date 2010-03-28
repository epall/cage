package cage.ui;

import cage.port.PointSource;
import cage.ui.LiveDisplay;
import cage.ui.OSXAdapter;
import org.jruby.embed.LocalContextScope;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import javax.swing.*;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.util.concurrent.ConcurrentLinkedQueue;

public class MainWindow extends JFrame {

    public JPanel mainPanel;
    public JButton startAccelerometer;
    public JButton newGesture;
    public JButton matchGesture;
    public JEditorPane script;
    public JButton stopAccelerometer;
    public JButton stopGesture;
    public JButton showLiveDisplay;
    public JButton plotGesture;
    public JButton saveAllGestures;
    public JTextField gestureName;
    public JButton stopMatch;
    public LiveDisplay liveDisplay = new LiveDisplay();

    public MainWindow() {
        this.setContentPane(mainPanel);
        this.setBounds(100, 100, 700, 400);
        try{
            OSXAdapter.setQuitHandler(this, MainWindow.class.getMethod("quit"));
        } catch(NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }

    public void quit(){
        this.processWindowEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING));
    }
}
