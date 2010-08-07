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

/**
 * This class sets up all of the UI components that Ruby's <code>application_controller</code> and <code>application_View</code>
 * control, in conjunction with the UI designed in <code>MainWindow.form</code>.
 *
 * @author Eric Allen
 * @author Michael O'Keefe
 */
public class MainWindow extends JFrame {

    private JPanel mainPanel;
    private JButton newGesture;
    private JButton matchGesture;
    private JEditorPane script;
    private JButton startStop;
    private JButton showLiveDisplay;
    private JButton plotGesture;
    private JButton saveAllGestures;
    private JTextField gestureName;
    private JButton testScript;
    private JList gestureList;
    private JScrollPane gestureScroll;
    private JToggleButton continuousMatch;
    private JButton editGesture;
    private JButton deleteGesture;

    /**
     * Creates the class, and tries to set an OSX quitHandler, so you can quit out of the program using the Apple-Q command.
     */
    public MainWindow() {
        super("CAGE");
        this.setContentPane(mainPanel);
        this.setBounds(100, 100, 750, 400);
        try{
            OSXAdapter.setQuitHandler(this, MainWindow.class.getMethod("quit"));
        } catch(NoSuchMethodException e) {
            throw new RuntimeException(e);
        }
    }

    /**
     * is called when OSX "quits" the program. It tells the <code>MainWindow</code> to close.
     *
     * @return a boolean "true"
     */
    public boolean quit(){
        this.processWindowEvent(new WindowEvent(this, WindowEvent.WINDOW_CLOSING));
        return true;
    }
}
