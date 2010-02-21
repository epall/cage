import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class GesturePlotter extends JDialog {
    private JPanel contentPane;
    private JButton buttonOK;
    private JButton buttonCancel;
    private JPanel plotArea;
    private Gesture gesture;

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
    }

    public void setGesture(Gesture g){
        this.gesture = g;
        this.plotArea.invalidate();
    }

    private void onOK() {
        dispose();
    }

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
                    int x = (int)p.y*255/bounds.width+(bounds.width/2);
                    int y = (int)p.z*255/bounds.height+(bounds.height/2);
                    g2d.fillOval(x, y, 7, 7);
                }
            }
        }
    }
}
