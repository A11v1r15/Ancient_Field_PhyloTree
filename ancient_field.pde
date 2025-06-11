class PhyloNode {
  String label;
  ArrayList<PhyloNode> children = new ArrayList<PhyloNode>();
  PhyloNode parent;
  float branchLength;
  PImage sprite;
  color branchColor = 0;

  PhyloNode(String label, float branchLength) {
    this.branchLength = branchLength;
    this.label = label;
    String[] parts = label.split("#");
    String baseName = parts[0];
    String hexColor = parts.length > 1 ? parts[1] : null;
    this.label = baseName;

    // Use preloaded sprites if available
    this.sprite = sprites.getOrDefault(baseName, null);

    // Handle color parsing with error checking
    if (hexColor != null && hexColor.length() == 6) {
      try {
        branchColor = unhex("FF" + hexColor);
      }
      catch (Exception e) {
        println(hexColor + " is not a valid color for " + baseName);
      }
    }
  }

  PhyloNode addChild(PhyloNode child) {
    if (child.branchColor == 0)
      child.branchColor = branchColor;
    children.add(child);
    child.parent = this;
    return this;
  }

  PhyloNode changeColor(color c) {
    branchColor = c;
    for (PhyloNode child : children)
      child.changeColor(branchColor);
    return this;
  }
}

// Global variables
PhyloNode root;
HashMap<PhyloNode, Float> angles = new HashMap<PhyloNode, Float>();
HashMap<PhyloNode, Float> radii = new HashMap<PhyloNode, Float>();
float maxDepth;
boolean saveImage = false;
PhyloNode hoveredNode = null;

// Image caching
HashMap<String, PImage> sprites = new HashMap<String, PImage>();

// View controls
float userScale = 0;
float userTranslateX = 0;
float userTranslateY = 0;

void setup() {
  size(3000, 3000);
  imageMode(CENTER);
  noFill();
  strokeWeight(3);

  // Preload all sprites
  preloadSprites();
  loadTree("testTree.nwk");
  buildMenuBar();
}

void preloadSprites() {
  File dir = new File(sketchPath() + "/data/png/");
  if (dir.exists() && dir.isDirectory()) {
    File[] files = dir.listFiles();
    for (File file : files) {
      if (file.isFile() && file.getName().toLowerCase().endsWith(".png")) {
        String name = file.getName().substring(0, file.getName().lastIndexOf('.'));
        sprites.put(name, loadImage("png/" + file.getName()));
      }
    }
  }
}

void loadTree(String url) {
  try {
    String newick = join(loadStrings(url), "");
    root = parseNewick(newick);
    updateTreeLayout();
  }
  catch (Exception e) {
    println("Error loading tree: " + e.getMessage());
    // Create empty root node to prevent crashes
    root = new PhyloNode("Root", 0);
  }
}

void updateTreeLayout() {
  maxDepth = calcMaxDepth(root, 0);
  angles.clear();
  radii.clear();
  calcLayout(root, 0, HALF_PI + 0.1, TAU - 0.1);
}

void draw() {
  background(255);
  pushMatrix();
  translate(width/2 + userTranslateX, height/2 + userTranslateY);
  float scale = min(width, height) * 0.45 / (maxDepth + 1);
  hoveredNode = null;  // Reset hover state
  drawNode(root, 0, 0, scale + userScale);
  popMatrix();

  if (saveImage) {
    JFileChooser chooser = new JFileChooser(sketchPath());
    FileNameExtensionFilter filter = new FileNameExtensionFilter("PNG image", "png");
    chooser.setFileFilter(filter);
    int returnVal = chooser.showSaveDialog(mp);
    if (returnVal == JFileChooser.APPROVE_OPTION) {
      String path = chooser.getSelectedFile().getPath();
      if (!path.endsWith(".png")) path += ".png";
      save(path);
    }
    saveImage = false;
  }
}

void mouseWheel(processing.event.MouseEvent event) {
  float zoomChange = event.getCount() * 10;
  // Set minimum zoom boundary
  if (userScale + zoomChange > -min(width, height)*0.4) {
    userScale -= zoomChange;
  }
}

PVector mouseDelta = new PVector();
void mousePressed() {
  mouseDelta = new PVector(mouseX, mouseY);
}

void mouseDragged() {
  userTranslateX += mouseX - mouseDelta.x;
  userTranslateY += mouseY - mouseDelta.y;
  mouseDelta.set(mouseX, mouseY);
}

void mouseReleased() {
  if (hoveredNode != null && !dialogOpened) {
    dialogOpened = true;
    EditNodeDialog dialog = new EditNodeDialog(this, hoveredNode.label, hoveredNode.branchColor);
    if (dialog.confirmed) {
      hoveredNode.label = dialog.newName;
      hoveredNode.changeColor(dialog.newColor);
      updateTreeLayout(); // Update layout after changes
    }
    dialogOpened = false;
  }
}

float calcMaxDepth(PhyloNode node, float depth) {
  if (node.children.isEmpty()) return depth;
  float maxD = depth;
  for (PhyloNode child : node.children) {
    maxD = max(maxD, calcMaxDepth(child, depth + child.branchLength));
  }
  return maxD;
}

void calcLayout(PhyloNode node, float depth, float startAngle, float sweep) {
  float midAngle = startAngle + sweep / 2;
  angles.put(node, midAngle);
  radii.put(node, depth + ((node == root) ? 0.5 : 1));

  if (node.children.isEmpty()) return;

  float total = 0;
  for (PhyloNode c : node.children) total += countLeaves(c);

  float angleOffset = 0;
  for (PhyloNode c : node.children) {
    float proportion = countLeaves(c) / total;
    float childSweep = sweep * proportion;
    calcLayout(c, depth + c.branchLength, startAngle + angleOffset, childSweep);
    angleOffset += childSweep;
  }
}

int countLeaves(PhyloNode node) {
  if (node.children.isEmpty()) return 1;
  int sum = 0;
  for (PhyloNode c : node.children) sum += countLeaves(c);
  return sum;
}

boolean dialogOpened = false;

void drawNode(PhyloNode node, float cx, float cy, float scale) {
  float angle = angles.get(node);
  float radius = radii.get(node) * scale;
  float x = cx + cos(angle) * radius;
  float y = cy - sin(angle) * radius;

  for (PhyloNode child : node.children) {
    float cAngle = angles.get(child);
    float cRadius = radii.get(child) * scale;
    float cX1 = cx + cos(cAngle) * radius;
    float cY1 = cy - sin(cAngle) * radius;
    float cX2 = cx + cos(cAngle) * cRadius;
    float cY2 = cy - sin(cAngle) * cRadius;

    // Draw branch
    stroke(child.branchColor);
    line(cX1, cY1, cX2, cY2);
    float start = min(angle, cAngle);
    float end = max(angle, cAngle);
    arc(0, 0, radius * 2, radius * 2, -end, -start);

    drawNode(child, cx, cy, scale);
  }

  float nodeRadius = 16;
  boolean isHovered = dist(mouseX - width/2 - userTranslateX, mouseY - height/2 - userTranslateY, x, y) < nodeRadius;

  // Draw node
  if (node.sprite != null) {
    image(node.sprite, x, y, isHovered ? 48 : 32, isHovered ? 48 : 32);
  } else {
    pushStyle();
    noStroke();
    fill(node.branchColor);
    circle(x, y, isHovered ? 16 : 8);
    popStyle();
  }

  if (isHovered) {
    hoveredNode = node;
    if (!node.label.isEmpty()) {
      float tw = textWidth(node.label) + 10;

      // Draw tooltip
      float tooltipOffset = 24;
      float angleToCenter = atan2(cy - y, x - cx);
      float tx = x + cos(angleToCenter) * (tooltipOffset + tw/2);
      float ty = y - sin(angleToCenter) * tooltipOffset;

      pushStyle();
      float th = 20;
      noStroke();
      fill(255, 230);
      rect(tx - tw/2, ty - th/2, tw, th, 5);
      fill(0);
      textAlign(CENTER, CENTER);
      text(node.label, tx, ty);
      popStyle();
    }
  }
}

PhyloNode parseNewick(String nwk) {
  nwk = nwk.trim();
  if (nwk.endsWith(";")) nwk = nwk.substring(0, nwk.length()-1);
  int[] index = {0};
  return parseNode(nwk, index);
}

PhyloNode parseNode(String nwk, int[] index) {
  if (index[0] >= nwk.length()) return new PhyloNode("Error", 0);

  if (nwk.charAt(index[0]) == '(') {
    index[0]++;
    ArrayList<PhyloNode> children = new ArrayList<PhyloNode>();
    while (index[0] < nwk.length() && nwk.charAt(index[0]) != ')') {
      children.add(parseNode(nwk, index));
      if (index[0] < nwk.length() && nwk.charAt(index[0]) == ',') index[0]++;
    }
    if (index[0] < nwk.length() && nwk.charAt(index[0]) == ')') index[0]++;

    String label = "";
    float length = 0;

    if (index[0] < nwk.length() && nwk.charAt(index[0]) != ':' && nwk.charAt(index[0]) != ',' && nwk.charAt(index[0]) != ')') {
      int start = index[0];
      while (index[0] < nwk.length() && nwk.charAt(index[0]) != ':' && nwk.charAt(index[0]) != ',' && nwk.charAt(index[0]) != ')') {
        index[0]++;
      }
      label = nwk.substring(start, index[0]);
    }

    if (index[0] < nwk.length() && nwk.charAt(index[0]) == ':') {
      index[0]++;
      int start = index[0];
      while (index[0] < nwk.length() && (Character.isDigit(nwk.charAt(index[0])) || nwk.charAt(index[0]) == '.' ||
        nwk.charAt(index[0]) == 'E' || nwk.charAt(index[0]) == 'e' ||
        nwk.charAt(index[0]) == '-' || nwk.charAt(index[0]) == '+')) {
        index[0]++;
      }
      String lengthStr = nwk.substring(start, index[0]).replace(',', '.');
      try {
        length = Float.parseFloat(lengthStr);
      }
      catch (NumberFormatException e) {
        length = 1.0; // Default length
      }
    }

    PhyloNode node = new PhyloNode(label, length);
    for (PhyloNode c : children) node.addChild(c);
    return node;
  } else {
    int start = index[0];
    while (index[0] < nwk.length() && nwk.charAt(index[0]) != ':' && nwk.charAt(index[0]) != ',' && nwk.charAt(index[0]) != ')') {
      index[0]++;
    }
    String label = nwk.substring(start, index[0]);
    float length = 0;

    if (index[0] < nwk.length() && nwk.charAt(index[0]) == ':') {
      index[0]++;
      int startLen = index[0];
      while (index[0] < nwk.length() && (Character.isDigit(nwk.charAt(index[0])) || nwk.charAt(index[0]) == '.' ||
        nwk.charAt(index[0]) == 'E' || nwk.charAt(index[0]) == 'e' ||
        nwk.charAt(index[0]) == '-' || nwk.charAt(index[0]) == '+')) {
        index[0]++;
      }
      String lengthStr = nwk.substring(startLen, index[0]).replace(',', '.');
      try {
        length = Float.parseFloat(lengthStr);
      }
      catch (NumberFormatException e) {
        length = 1.0; // Default length
      }
    }

    // Handle empty labels
    if (label.isEmpty()) label = "Node_" + (int)random(10000);

    return new PhyloNode(label, length);
  }
}

ArrayList<PhyloNode> getColoredNodes(PhyloNode root) {
  ArrayList<PhyloNode> colored = new ArrayList<PhyloNode>();
  collectColoredNodes(root, colored);
  return colored;
}

void collectColoredNodes(PhyloNode node, ArrayList<PhyloNode> list) {
  if (node.branchColor != 0) {
    list.add(node);
  }
  for (PhyloNode child : node.children) {
    collectColoredNodes(child, list);
  }
}

String toNewick(PhyloNode node) {
  StringBuilder sb = new StringBuilder();

  if (!node.children.isEmpty()) {
    sb.append("(");
    for (int i = 0; i < node.children.size(); i++) {
      sb.append(toNewick(node.children.get(i)));
      if (i < node.children.size() - 1) sb.append(",");
    }
    sb.append(")");
  }

  if (node.label != null && !node.label.equals("")) {
    sb.append(node.label);
  }

  if (node.branchColor != 0 && !node.label.contains("#")) {
    sb.append("#").append(hex(node.branchColor, 6));
  }

  sb.append(":").append(node.branchLength);

  return sb.toString();
}

void saveAsNewick(PhyloNode root, String filename) {
  String nwk = toNewick(root) + ";";
  PrintWriter writer = createWriter(filename);
  writer.print(nwk);
  writer.flush();
  writer.close();
}
