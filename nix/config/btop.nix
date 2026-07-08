{pkgs}: {
  enable = true;
  package = pkgs.btop.override {rocmSupport = true;};
  settings = {
    color_theme = "kanagawa-wave";
    vim_keys = true;
    shown_boxes = "cpu mem net proc gpu0";
  };
}
