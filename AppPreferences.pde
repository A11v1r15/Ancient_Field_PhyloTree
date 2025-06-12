class AppPreferences {
  boolean alwaysShowTooltips = false;
  boolean useImages = true;
  boolean showNodes = true;
  color backgroundColor = color(255);
  color branchColor = color(0);
  String lastPath = "data" + File.separator + "testTree.nwk";
  
  void save() {
    JSONObject json = new JSONObject();
    json.setBoolean("alwaysShowTooltips", alwaysShowTooltips);
    json.setBoolean("useImages", useImages);
    json.setBoolean("showNodes", showNodes);
    json.setInt("backgroundColor", backgroundColor);
    json.setInt("branchColor", branchColor);
    json.setString("lastPath", lastPath);
    saveJSONObject(json, sketchPath("preferences.json"));
  }
  
  void load() {
    try {
      JSONObject json = loadJSONObject(sketchPath("preferences.json"));
      alwaysShowTooltips = json.getBoolean("alwaysShowTooltips");
      useImages = json.getBoolean("useImages");
      showNodes = json.getBoolean("showNodes");
      backgroundColor = json.getInt("backgroundColor");
      branchColor = json.getInt("branchColor");
      lastPath = json.getString("lastPath");
    } catch (Exception e) {
      println("No preferences found, using defaults");
      save();
    }
  }
}

AppPreferences prefs = new AppPreferences();
