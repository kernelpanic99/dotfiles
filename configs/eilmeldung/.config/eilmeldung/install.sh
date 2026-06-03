#!/bin/sh

cp ~/.config/eilmeldung/{eilmeldung-sync.timer,eilmeldung-sync.service} ~/.config/systemd/user/

systemctl --user daemon-reload
systemctl --user enable --now eilmeldung-sync.timer
