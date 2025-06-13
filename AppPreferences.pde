class AppPreferences {
  boolean alwaysShowTooltips = false;
  boolean useImages = true;
  boolean showNodes = true;
  color backgroundColor = color(255);
  color branchColor = color(0);
  String lastPath = "data" + File.separator + "testTree.nwk";
  boolean radialLabels = false;

  void save() {
    JSONObject json = new JSONObject();
    json.setBoolean("alwaysShowTooltips", alwaysShowTooltips);
    json.setBoolean("useImages", useImages);
    json.setBoolean("showNodes", showNodes);
    json.setInt("backgroundColor", backgroundColor);
    json.setInt("branchColor", branchColor);
    json.setString("lastPath", lastPath);
    json.setBoolean("radialLabels", radialLabels);

    saveJSONObject(json, sketchPath("preferences.json"));
  }

  void load() {
    try {
      JSONObject json = loadJSONObject(sketchPath("preferences.json"));
      alwaysShowTooltips = json.getBoolean("alwaysShowTooltips", alwaysShowTooltips);
      useImages = json.getBoolean("useImages", useImages);
      showNodes = json.getBoolean("showNodes", showNodes);
      backgroundColor = json.getInt("backgroundColor", backgroundColor);
      branchColor = json.getInt("branchColor", branchColor);
      lastPath = json.getString("lastPath", lastPath);
      radialLabels = json.getBoolean("radialLabels", radialLabels);
    }
    catch (Exception e) {
      println("No preferences found, using defaults");
      save();
    }
  }
}

AppPreferences prefs = new AppPreferences();
