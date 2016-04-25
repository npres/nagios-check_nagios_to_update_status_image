#!/bin/bash
#
# check_nagios_to_update_status_image.bash
#
# v0.0.1 - 2016-04-22 - NPR3S <npres.inc@gmail.com>
# v0.0.2 - 2016-04-22 - NPR3S <npres.inc@gmail.com>
# v0.0.3 - 2016-04-24 - NPR3S <npres.inc@gmail.com>
# v0.0.4 - 2016-04-24 - NPR3S <npres.inc@gmail.com>
#
# http://www.flaticon.com/packs/thick-icons
#

get_status_of_nagios() {
  if [ -n "$port" ]; then
    ssh -p $port -o ConnectTimeout=$timeout ${user}@${system} $check_nagios
  else
    $check_nagios
  fi
  status=$?
}

set_status_of_image() {
  if [ "$status" -lt "$STATE_OK" -o "$status" -gt "$STATE_UNKNOWN" ]; then
    status=$STATE_CRITICAL
  fi
  cp $dirbase/templates/${images[$status]} $dirbase/status1.png
  color_background=${colors_background[$status]}
  color_front=${colors_front[$status]}
}

set_update_of_image() {
  convert -define png:size=80x64 $dirbase/status1.png -thumbnail '32x32' -background '#f2f3f3' -gravity North -extent 80x45 $dirbase/status2.png

  width=$(identify -format %w $dirbase/status2.png)
  convert -background $color_background -fill $color_front -gravity South -size ${width}x12 -font Helvetica-Bold caption:"$fechahora" $dirbase/status2.png +swap -gravity south -composite $dirbase/status3.png 

  convert $dirbase/status3.png -fill transparent -stroke $color_background -linewidth 1 -draw "rectangle 0,0 79,44" $dirbase/status4.png
}

# main()

# Constants:
declare -a images=(ok-up.png warning-exclamation.png critical-down.png unknown-question.png)
declare -a colors_background=('#498022' '#DB952B' '#D80027' '#933EC5')
declare -a colors_front=('#ffffff' '#000000' '#ffffff' '#ffffff')
STATE_OK=0
STATE_WARNING=1
STATE_CRITICAL=2
STATE_UNKNOWN=3
fechahora=$(date +'%Y-%m-%d %H:%M')

# Configuration:
check_nagios=/etc/NPRES/scripts/nagios/check_nagios.bash
dirbase=/home/nelbren/dev/npres/output/theme/images/nagios
port=22 # If port is null then run local check_nagios
timeout=3
user=nagios
system=nagios.host

get_status_of_nagios
set_status_of_image
set_update_of_image
