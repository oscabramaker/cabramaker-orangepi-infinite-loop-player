#!/bin/bash
# Small offline support report; never stops the player or powers off the board.
set +e
sleep 45
out=/boot/firmware/STATUS-PI3.tmp
{
 echo '=== CABRAMAKER PI3: INICIO AUTOMATICO ==='
 date -Is
 uptime
 cat /proc/cmdline
 timeout 10 systemctl status cabramaker-video cabramaker-splash --no-pager -l
 cat /run/cabramaker/player.json
 timeout 5 kmsprint
 timeout 5 vcgencmd get_throttled
 timeout 5 vcgencmd measure_temp
 echo '--- REGISTROS DO BOOT ---'
 journalctl -b --no-pager -n 300
 echo '=== FIM; REPRODUCAO CONTINUA ==='
} >"$out" 2>&1
mv "$out" /boot/firmware/STATUS-PI3.txt
sync
