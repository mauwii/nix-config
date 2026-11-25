{ lib, ... }:
let
  # fixed, so the default profile survives every switch
  itermProfileGuid = "2FE51D9D-6AB4-47E2-B00F-2A00ECD7DE19";

  # iTerm2 stores a color as sRGB components from 0 to 1
  itermColor = hex: {
    "Color Space" = "sRGB";
    "Red Component" = lib.fromHexString (builtins.substring 1 2 hex) / 255.0;
    "Green Component" = lib.fromHexString (builtins.substring 3 2 hex) / 255.0;
    "Blue Component" = lib.fromHexString (builtins.substring 5 2 hex) / 255.0;
  };

  # Code 2026 Dark and Light from github.com/mbadolato/iTerm2-Color-Schemes
  # Ansi 0-15: black, red, green, yellow, blue, magenta, cyan, white, then the bright ones
  colors = {
    Dark = {
      "Ansi 0 Color" = "#202122";
      "Ansi 1 Color" = "#ff7b72";
      "Ansi 2 Color" = "#7ee787";
      "Ansi 3 Color" = "#cd9731";
      "Ansi 4 Color" = "#79c0ff";
      "Ansi 5 Color" = "#d2a8ff";
      "Ansi 6 Color" = "#4ec9b0";
      "Ansi 7 Color" = "#bbbebf";
      "Ansi 8 Color" = "#555555";
      "Ansi 9 Color" = "#ffa198";
      "Ansi 10 Color" = "#91eb99";
      "Ansi 11 Color" = "#ffa657";
      "Ansi 12 Color" = "#a5d6ff";
      "Ansi 13 Color" = "#b267e6";
      "Ansi 14 Color" = "#71d4c0";
      "Ansi 15 Color" = "#ffffff";
      "Background Color" = "#121314";
      "Foreground Color" = "#bbbebf";
      "Bold Color" = "#bbbebf";
      "Cursor Color" = "#bbbebf";
      "Cursor Guide Color" = "#bbbebf";
      "Cursor Text Color" = "#121314";
      "Selected Text Color" = "#ffffff";
      "Selection Color" = "#276782";
    };
    Light = {
      "Ansi 0 Color" = "#f0f1f2";
      "Ansi 1 Color" = "#cf222e";
      "Ansi 2 Color" = "#116329";
      "Ansi 3 Color" = "#953800";
      "Ansi 4 Color" = "#0550ae";
      "Ansi 5 Color" = "#8250df";
      "Ansi 6 Color" = "#116329";
      "Ansi 7 Color" = "#202020";
      "Ansi 8 Color" = "#999999";
      "Ansi 9 Color" = "#cf222e";
      "Ansi 10 Color" = "#116329";
      "Ansi 11 Color" = "#953800";
      "Ansi 12 Color" = "#0550ae";
      "Ansi 13 Color" = "#8250df";
      "Ansi 14 Color" = "#116329";
      "Ansi 15 Color" = "#ffffff";
      "Background Color" = "#ffffff";
      "Foreground Color" = "#202020";
      "Bold Color" = "#202020";
      "Cursor Color" = "#0069cc";
      "Cursor Guide Color" = "#0069cc";
      "Cursor Text Color" = "#ffffff";
      "Selected Text Color" = "#202020";
      "Selection Color" = "#c2daf5";
    };
  };
in
{
  # explicit, because home-manager never reverts a default it has written
  targets.darwin.defaults."com.googlecode.iterm2" = {
    SUAutomaticallyUpdate = true;
    SUEnableAutomaticChecks = true;
    "Default Bookmark Guid" = itermProfileGuid;
  };

  # iTerm2 only reads Dynamic Profiles, so the read-only link into the store works
  home.file."Library/Application Support/iTerm2/DynamicProfiles/nix.json".text = builtins.toJSON {
    Profiles = [
      (
        lib.concatMapAttrs (
          mode: lib.mapAttrs' (key: hex: lib.nameValuePair "${key} (${mode})" (itermColor hex))
        ) colors
        // {
          Name = "Nix";
          Guid = itermProfileGuid;
          # without a parent it inherits from the default profile, which is this one
          "Dynamic Profile Parent Name" = "Default";
          # follow the system appearance with the (Dark) and (Light) colors
          "Use Separate Colors for Light and Dark Mode" = true;
          "Normal Font" = "FiraCodeNFM-Med 12";
          "ASCII Ligatures" = true;
          "Blinking Cursor" = true;
          "Cursor Smooth Blink" = true;
          "Blink Allowed" = true;
          "Terminal Type" = "xterm-256color";
          Columns = 120;
          Rows = 40;
        }
      )
    ];
  };
}
