import javax.swing.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.filechooser.*;
import javax.swing.UIManager;
import java.awt.FlowLayout;
import java.awt.GridLayout;
import java.awt.BorderLayout;
import java.awt.datatransfer.*;
import java.awt.Toolkit;

public class Menu_bar extends JFrame implements ActionListener {
  PApplet chain;
  JFrame frame;
  JMenu import_menu = new JMenu("File");
  JMenuItem load = new JMenuItem("Load NWK");
  JMenuItem save = new JMenuItem("Save NWK");
  JMenuItem export = new JMenuItem("Export Image");

  JMenu options_menu = new JMenu("Options");
  JMenuItem reset_view = new JMenuItem("Reset View");
  JMenuItem subtitles = new JMenuItem("Subtitles");
  JMenuItem preferences = new JMenuItem("Preferences");

  JMenu about_menu = new JMenu("About");
  JMenuItem help = new JMenuItem("Help");
  JPanel panel;

  public Menu_bar(PApplet app) {
    chain = app;
    frame = (JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas)app.getSurface().getNative()).getFrame();
    panel =  new JPanel();
    panel.setOpaque(false);

    // Creates a menubar for a JFrame
    JMenuBar menu_bar = new JMenuBar();
    frame.setJMenuBar(menu_bar);

    import_menu.setMnemonic('F');
    load.setMnemonic('L');
    save.setMnemonic('S');
    export.setMnemonic('E');
    options_menu.setMnemonic('O');
    reset_view.setMnemonic('R');
    subtitles.setMnemonic('t');
    about_menu.setMnemonic('A');
    help.setMnemonic('H');

    menu_bar.add(import_menu);
    save.addActionListener(this);
    load.addActionListener(this);
    export.addActionListener(this);
    import_menu.add(save);
    import_menu.add(load);
    import_menu.add(export);

    menu_bar.add(options_menu);
    reset_view.addActionListener(this);
    subtitles.addActionListener(this);
    preferences.addActionListener(this);
    options_menu.add(reset_view);
    options_menu.add(subtitles);
    options_menu.add(preferences);

    menu_bar.add(about_menu);
    help.addActionListener(this);
    about_menu.add(help);

    frame.setVisible(true);
  }

  public void actionPerformed(ActionEvent e) {
    Object source = e.getSource();
    if (source == save) {
      JFileChooser chooser = new JFileChooser(sketchPath());
      FileNameExtensionFilter filter = new FileNameExtensionFilter("Newick tree format", "nwk");
      chooser.setFileFilter(filter);
      int returnVal = chooser.showSaveDialog(this);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
        String path = chooser.getSelectedFile().getPath();
        if (!path.endsWith(".nwk")) path += ".nwk";
        saveAsNewick(root, path);
      }
    } else if (source == load) {
      JFileChooser chooser = new JFileChooser(sketchPath());
      FileNameExtensionFilter filter = new FileNameExtensionFilter("Newick tree format", "nwk");
      chooser.setFileFilter(filter);
      int returnVal = chooser.showOpenDialog(this);
      if (returnVal == JFileChooser.APPROVE_OPTION) {
        loadTree(chooser.getSelectedFile().getPath());
      }
    } else if (source == export) {
      saveImage = true;
    } else if (source == reset_view) {
      userScale = 0;
      userTranslateX = 0;
      userTranslateY = 0;
    } else if (source == subtitles) {
      SubtitlesPopUp subtitlesPopUp = new SubtitlesPopUp(chain);
    } else if (source == preferences) {
      PreferencesDialog preferencesDialog = new PreferencesDialog(chain);
    } else if (source == help) {
      CreditsPopUp creditsPopUp = new CreditsPopUp(chain);
    }
  }
}

Menu_bar mp;
void buildMenuBar() {
  mp = new Menu_bar(this);
}

public class CreditsPopUp {
  PApplet chain;
  final JFrame parent = new JFrame("Help");
  JLabel playersPanel = new JLabel();

  public CreditsPopUp(PApplet app) {
    chain = app;
    playersPanel.setText("<html>Click and drag the mouse to navigate<br>"+
      "<html>Scroll the wheel to zoom in/out<br>"+
      "<html>Click on a node to change its color and label<br><br>"+
      "App created by <a href='https://github.com/a11v1r15/'>A11v1r15</a></html>");
    playersPanel.setVerticalAlignment(JLabel.NORTH);
    parent.setLayout(new FlowLayout());
    parent.add(playersPanel);
    parent.pack();
    parent.setResizable(false);
    parent.setLocation((displayWidth - parent.getWidth())/2, (displayHeight - parent.getHeight())/2);
    parent.setVisible(true);
  }
}

public class SubtitlesPopUp {
  PApplet chain;
  final JFrame parent = new JFrame("Subtitles");
  JLabel playersPanel = new JLabel();

  public SubtitlesPopUp(PApplet app) {
    chain = app;
    ArrayList<PhyloNode> coloredNodes = getColoredNodes(root);
    String text = "<html>";
    for (PhyloNode node : coloredNodes) {
      if (!node.label.equals("") && node.branchColor != node.parent.branchColor)
        text += ("<span style='color: #" + hex(node.branchColor, 6) + ";'>■</span> " + node.label + "<br>");
    }
    playersPanel.setText(text + "</html>");
    playersPanel.setVerticalAlignment(JLabel.NORTH);
    parent.setLayout(new FlowLayout());
    parent.add(playersPanel);
    parent.pack();
    parent.setResizable(false);
    parent.setLocation((displayWidth - parent.getWidth())/2, (displayHeight - parent.getHeight())/2);
    parent.setVisible(true);
  }
}

class EditNodeDialog extends JDialog {
  String newName;
  color newColor;
  boolean confirmed = false;

  public EditNodeDialog(PApplet parent, String currentName, color currentColor) {
    super((JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas) parent.getSurface().getNative()).getFrame(), "Edit Node", true);

    setLayout(new BorderLayout());

    // Name field
    JPanel namePanel = new JPanel(new FlowLayout());
    namePanel.add(new JLabel("Name:"));
    JTextField nameField = new JTextField(currentName, 20);
    namePanel.add(nameField);
    add(namePanel, BorderLayout.NORTH);

    // Color selector
    JColorChooser colorChooser = new JColorChooser(new java.awt.Color(currentColor));
    add(colorChooser, BorderLayout.CENTER);

    // Buttons
    JPanel buttonPanel = new JPanel();
    JButton okButton = new JButton("OK");
    JButton cancelButton = new JButton("Cancel");

    okButton.addActionListener(e -> {
      newName = nameField.getText();
      java.awt.Color chosen = colorChooser.getColor();
      newColor = parent.color(chosen.getRed(), chosen.getGreen(), chosen.getBlue());
      confirmed = true;
      dispose();
    }
    );

    cancelButton.addActionListener(e -> {
      dispose();
    }
    );

    buttonPanel.add(okButton);
    buttonPanel.add(cancelButton);
    add(buttonPanel, BorderLayout.SOUTH);

    pack();
    setLocationRelativeTo(null);
    setVisible(true);
  }
}

class PreferencesDialog extends JDialog {
  public PreferencesDialog(PApplet parent) {
    super((JFrame) ((processing.awt.PSurfaceAWT.SmoothCanvas) parent.getSurface().getNative()).getFrame(), "Preferences", true);
    setLayout(new GridLayout(0, 2, 10, 10));
    
    // Tooltips
    add(new JLabel("Always Show Tooltips:"));
    JCheckBox tooltipsBox = new JCheckBox("", prefs.alwaysShowTooltips);
    add(tooltipsBox);
    
    // Images
    add(new JLabel("Use Images:"));
    JCheckBox imagesBox = new JCheckBox("", prefs.useImages);
    add(imagesBox);
    
    // Node Labels
    add(new JLabel("Show Nodes:"));
    JCheckBox labelsBox = new JCheckBox("", prefs.showNodes);
    add(labelsBox);
    
    // Background Color
    add(new JLabel("Background Color:"));
    JButton colorButton = new JButton("Choose");
    colorButton.setBackground(new java.awt.Color(prefs.backgroundColor));
    colorButton.addActionListener(e -> {
      java.awt.Color newColor = JColorChooser.showDialog(this, "Choose Background Color", colorButton.getBackground());
      if (newColor != null) {
        colorButton.setBackground(newColor);
      }
    });
    add(colorButton);
    
    // Branch Color
    add(new JLabel("Default Branch Color:"));
    JButton colorButtonB = new JButton("Choose");
    colorButtonB.setBackground(new java.awt.Color(prefs.branchColor));
    colorButtonB.addActionListener(e -> {
      java.awt.Color newColor = JColorChooser.showDialog(this, "Choose Default Branch Color", colorButton.getBackground());
      if (newColor != null) {
        colorButtonB.setBackground(newColor);
      }
    });
    add(colorButtonB);
    
    // Buttons
    JButton saveButton = new JButton("Save");
    JButton cancelButton = new JButton("Cancel");
    
    saveButton.addActionListener(e -> {
      prefs.alwaysShowTooltips = tooltipsBox.isSelected();
      prefs.useImages = imagesBox.isSelected();
      prefs.showNodes = labelsBox.isSelected();
      prefs.backgroundColor = colorButton.getBackground().getRGB();
      prefs.branchColor = colorButtonB.getBackground().getRGB();
      prefs.save();
      dispose();
    });
    
    cancelButton.addActionListener(e -> dispose());
    
    JPanel buttonPanel = new JPanel();
    buttonPanel.add(saveButton);
    buttonPanel.add(cancelButton);
    
    add(new JLabel()); // Spacer
    add(buttonPanel);
    
    pack();
    setLocationRelativeTo(null);
    setVisible(true);
  }
}
