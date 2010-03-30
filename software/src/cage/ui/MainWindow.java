package cage.ui;

import cage.port.PointSource;
import cage.ui.LiveDisplay;
import cage.ui.OSXAdapter;
import org.jruby.embed.LocalContextScope;
import org.jruby.embed.PathType;
import org.jruby.embed.ScriptingContainer;

import javax.swing.*;
import java.awt.event.ItemListener;
import java.awt.event.WindowEvent;
import java.awt.event.WindowListener;
import java.util.concurrent.ConcurrentLinkedQueue;

public class MainWindow extends JFrame {

    private JPanel mainPanel;
    private JToggleButton newGesture;
    private JToggleButton matchGesture;
    private JEditorPane script;
    private JToggleButton startStop;
    private JButton showLiveDisplay;
    private JButton plotGesture;
    private JButton saveAllGestures;
    private JTextField gestureName;
    private JButton testScript;
    private JList gestureList;

    public MainWindow() {
        super("CAGE");
        this.setContentPane(mainPanel);
        this.setBounds(100, 100, 700, 400);
        try{
            OSXAdapter.setQuitHandler(this, MainWindow.class.getMethod("quit"));
        } catch(NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }

    public boolean quit(){
        this.processWindowEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING));
        return true;
    }
}
