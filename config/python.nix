# python.nix
{ pkgs }:

{
  basePython = pkgs.python312.withPackages (ps: with ps; [
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

  # Updated to Python 3.12
  qtodotxtPython = pkgs.python312.withPackages (ps: with ps; [
    pyqt5
    python-dateutil
    pyqtwebengine
  ]);
}
