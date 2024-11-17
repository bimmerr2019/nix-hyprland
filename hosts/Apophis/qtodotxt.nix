{ config, pkgs, ... }:

let
  pythonConfigs = import ../../config/python.nix { inherit pkgs; };
  pythonEnv = pythonConfigs.qtodotxtPython;


  launchQTodoTxt = pkgs.writeShellScriptBin "launch-qtodotxt" ''
    #!/bin/sh
    export QT_SCALE_FACTOR=1.5
    export QT_FONT_DPI=120
    
    # Set dark mode
    export QT_STYLE_OVERRIDE="Fusion"
    export QT_QPA_PLATFORMTHEME="qt5ct"
    
    # Set Qt plugin path
    export QT_PLUGIN_PATH="${pkgs.qt5.qtbase}/lib/qt-${pkgs.qt5.qtbase.version}/plugins"
    export QT_QPA_PLATFORM_PLUGIN_PATH="${pkgs.qt5.qtbase}/lib/qt-${pkgs.qt5.qtbase.version}/plugins/platforms"
    
    # Set QML import path
    export QML2_IMPORT_PATH="${pkgs.qt5.qtquickcontrols}/lib/qt-${pkgs.qt5.qtbase.version}/qml:${pkgs.qt5.qtquickcontrols2}/lib/qt-${pkgs.qt5.qtbase.version}/qml:${pkgs.qt5.qtgraphicaleffects}/lib/qt-${pkgs.qt5.qtbase.version}/qml"
    
    # Force the use of XCB
    export QT_QPA_PLATFORM=xcb
    
    # Attempt to set dark theme
    export QT_STYLE_FLAGS="dark"
    
    # Use the specific Python environment
    ${pythonEnv}/bin/python $HOME/QTodoTxt2/bin/qtodotxt.pyw
  '';
in
{
  environment.systemPackages = with pkgs; [
    pythonEnv
    launchQTodoTxt
    qt5.full
    qt5.qtquickcontrols
    qt5.qtquickcontrols2
    qt5.qtgraphicaleffects
    libsForQt5.qt5ct
    (makeDesktopItem {
      name = "QTodoTxt";
      exec = "launch-qtodotxt";
      icon = "accessories-text-editor";
      desktopName = "QTodoTxt";
      genericName = "Todo List Manager";
      categories = [ "Office" "ProjectManagement" ];
    })
  ];
}
