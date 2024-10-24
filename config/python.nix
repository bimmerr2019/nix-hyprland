# python.nix
{ pkgs }:

{
  basePython = pkgs.python311.withPackages (ps: with ps; [
    # LSP and development tools
    pip
    python-lsp-server
    pylint
    black
    
    # Additional development tools
    pytest
    
    # Common libraries
    requests
    python-dateutil
    
    # Qt-related packages
    pyqt5
    pyqtwebengine
  ]);

  # Specific environment for QTodoTxt
  qtodotxtPython = pkgs.python39.withPackages (ps: with ps; [
    pyqt5
    python-dateutil
    pyqtwebengine
  ]);
}

