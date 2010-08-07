package cage.ui;

import cage.AccelerometerPoint;
import cage.Gesture;

import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * GesturePlotter is a class that plots a series of points (in this case, the points from a gesture) in a window using a rainbow of colors.
 * @author Eric Allen
 *
 */

public class GesturePlotter extends JDialog {
    private JPanel contentPane;
    private JButton buttonOK;
    private JPanel plotArea;
    private Gesture gesture;

    /**
     * Constructor. This sets the <code>contentPane</code>, and creates a screen with a <Code>PlotArea</code> 
     */
    public GesturePlotter() {
        setContentPane(contentPane);
        setModal(true);
        getRootPane().setDefaultButton(buttonOK);
        plotArea.add(new Plot(), BorderLayout.CENTER);

        buttonOK.addActionListener(new ActionListener() {
            public void actionPerformed(ActionEvent e) {
                onOK();
            }
        });
        this.setBounds(500, 200, 500, 520);
    }

    public void setGesture(Gesture g){
        this.gesture = g;
    }

    /**
     * when the user clicks the Ok button, this kills the window.
     */
    private void onOK() {
        dispose();
    }

    // for debugging only
    public static void main(String[] args) {
        JFrame frame = new JFrame("GesturePlotter");
        GesturePlotter plotter = new GesturePlotter();
        frame.setContentPane(plotter.contentPane);
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.setBounds(500, 200, 500, 520);
        frame.setVisible(true);
        plotter.setGesture(new Gesture(){
            public AccelerometerPoint getPoint(int index) {
                int positionInt = (12*(index-10));
                byte position = (byte)positionInt;
                return new AccelerometerPoint(new byte[]{position, position, position});
            }

            public int numPoints() {
                return 21;
            }
        });
    }

    /**
     * This is the class that actually does the 2D plotting of the points in the <code>GesturePlotter</code>.
     * It creates a new <code>Graphics2D</code> object, fills it with white, and draws each point as a circle
     * filled with a different color.
     *
     * @author Eric Allen
     */

    private class Plot extends JPanel {
        public Plot(){
            super();
        }
        
        @Override
        protected void paintComponent(Graphics g) {
            Graphics2D g2d = (Graphics2D)g;
            Rectangle bounds = g2d.getClipBounds();
            bounds.x += 5;
            bounds.y += 5;
            bounds.width -= 5;
            bounds.height -= 5;
            g2d.setPaint(Color.WHITE);
            g2d.fill(bounds);
            bounds.width -= 1;
            bounds.height -= 1;
            g2d.setPaint(Color.BLACK);
            g2d.draw(bounds);

            g2d.setPaint(Color.RED);
            if(gesture != null){
                for(int i = 0; i < gesture.numPoints(); i++){
                    g2d.setPaint(new Color(Color.HSBtoRGB((float)i/gesture.numPoints()*0.7f, 1.0f, 1.0f)));
                    AccelerometerPoint p = gesture.getPoint(i);
                    int x = (int)p.x*255/bounds.width+(bounds.width/2);
                    int y = (int)p.z*255/bounds.height+(bounds.height/2);
                    g2d.fillOval(x, y, 7, 7);
                }
            }
        }
    }
}
