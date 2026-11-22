_: {
  # explicit, because home-manager never reverts a default it has written
  targets.darwin.defaults."com.googlecode.iterm2" = {
    SUAutomaticallyUpdate = true;
    SUEnableAutomaticChecks = true;
  };
}
