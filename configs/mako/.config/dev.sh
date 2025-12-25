#!/usr/bin/env fish

watchexec -w ~/.config/mako/config 'pkill mako; mako & sleep 0.5; 
    notify-send -u low -t 20000 -i dialog-information "📊 Low Priority" "This is a low urgency notification for testing";
    sleep 0.2;
    notify-send -u normal -t 5000 -i preferences-system "🔄 Normal Priority" "Mako configuration reloaded\nTime: (date +\"%H:%M:%S\")\nProcess: (pgrep mako)\nMultiple lines of text to test wrapping and spacing";
    sleep 0.2;
    notify-send -u critical -t 0 -i dialog-error "⚠️ Critical Alert" "This is a critical notification that won\'t auto-dismiss\nTesting different urgency levels\nClick to dismiss";
    sleep 0.2;
    notify-send -a "Test App" -c "network" -h string:desktop-entry:firefox -i firefox "Firefox" "Network notification from Firefox\nCategory: network\nApp name: Test App";
    sleep 0.2;
    notify-send -h int:value:75 -h string:x-canonical-private-synchronous:volume -i audio-volume-high "🔊 Volume" "Volume: 75%\nProgress indicator test";
    sleep 0.2;
    notify-send -u normal -t 8000 -i folder "📁 File Manager" "Long notification text to test text wrapping behavior. This notification contains multiple sentences to see how your mako configuration handles longer content. It should wrap nicely according to your width settings.";'

