class AppPreferences {
  boolean darkMode = false;
  boolean alwaysShowTooltips = false;
  boolean useImages = true;
  boolean showNodeLabels = true;
  boolean smoothRendering = true;
  color backgroundColor = color(255);
  
  void save() {
    JSONObject json = new JSONObject();
    json.setBoolean("darkMode", darkMode);
    json.setBoolean("alwaysShowTooltips", alwaysShowTooltips);
    json.setBoolean("useImages", useImages);
    json.setBoolean("showNodeLabels", showNodeLabels);
    json.setBoolean("smoothRendering", smoothRendering);
    json.setInt("backgroundColor", backgroundColor);
    saveJSONObject(json, sketchPath("preferences.json"));
  }
  
  void load() {
    try {
      JSONObject json = loadJSONObject(sketchPath("preferences.json"));
      darkMode = json.getBoolean("darkMode");
      alwaysShowTooltips = json.getBoolean("alwaysShowTooltips");
      useImages = json.getBoolean("useImages");
      showNodeLabels = json.getBoolean("showNodeLabels");
      smoothRendering = json.getBoolean("smoothRendering");
      backgroundColor = json.getInt("backgroundColor");
    } catch (Exception e) {
      println("No preferences found, using defaults");
    }
  }
}

AppPreferences prefs = new AppPreferences();
