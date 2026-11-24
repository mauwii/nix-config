{ lib, ... }:
{
  # -dict-add keeps the other hotkeys; targets.darwin.defaults would replace the whole dict
  home.activation.symbolicHotkeys = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # 27: move focus to next window, Cmd+< (Cmd+Shift+< backwards)
    run /usr/bin/defaults write com.apple.symbolichotkeys AppleSymbolicHotKeys -dict-add 27 \
      '<dict><key>enabled</key><true/><key>value</key><dict><key>parameters</key><array><integer>60</integer><integer>50</integer><integer>1048576</integer></array><key>type</key><string>standard</string></dict></dict>'
    # apply now instead of at the next login
    run /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
  '';
}
