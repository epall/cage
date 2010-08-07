package cage.ui;

import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

/**
 * This class is the UI creation class for the Ruby <code>live_display</code> class.
 * It creates a window with a close button and 3 sliders, which the Ruby class can manipulate.
 *
 * @author Eric Allen
 */

public class LiveDisplay extends JDialog {
    public JPanel contentPane;
    public JButton buttonClose;
    public JSlider sliderX;
    public JSlider sliderY;
    public JSlider sliderZ;

    public LiveDisplay() {
        setContentPane(contentPane);
        setModal(true);
        getRootPane().setDefaultButton(buttonClose);
//        buttonClose.addActionListener(new ActionListener() {
//            public void actionPerformed(ActionEvent e) {
//                LiveDisplay.this.setVisible(false);
//            }
//        });
        this.setBounds(300, 150, 400, 300);
    }
}
