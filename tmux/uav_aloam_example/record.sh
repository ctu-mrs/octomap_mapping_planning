#!/bin/bash

path="/home/\$(optenv USER mrs)/bag_files/latest/"

# By default, we record everything.
# Except for this list of EXCLUDED topics:
exclude=(

# IN GENERAL, DON'T RECORD CAMERAS
#
# If you want to record cameras, create a copy of this script
# and place it at your tmux session.
#
# Please, seek an advice of a senior researcher of MRS about
# what can be recorded. Recording too much data can lead to
# ROS communication hiccups, which can lead to eland, failsafe
# or just a CRASH.

# EXCLUDE PCL FILTER
'(.*)pcl_filter(.*)'

# OUSTER
'(.*)/os_cloud_nodelet/(.*)'

# EXCLUDE OCTOMAP VISUALIZATION
# full unthrothled
'(.*)/octomap_global_full(.*)'
'(.*)/octomap_local(.*)'

'(.*)/octomap_(.*)_vis/(.*)'

# EXCLUDE SLAM
'(.*)slam/map'
'(.*)slam/scan_registered'

)

# file's header
filename=`mktemp`
echo "<launch>" > "$filename"
echo "<arg name=\"UAV_NAME\" default=\"\$(env UAV_NAME)\" />" >> "$filename"
echo "<group ns=\"\$(arg UAV_NAME)\">" >> "$filename"

echo -n "<node pkg=\"rosbag\" type=\"record\" name=\"rosbag_record\" args=\"-o $path -a" >> "$filename"

# if there is anything to exclude
if [ "${#exclude[*]}" -gt 0 ]; then

  echo -n " -x " >> "$filename"

  # list all the string and separate the with |
  for ((i=0; i < ${#exclude[*]}; i++));
  do
    echo -n "${exclude[$i]}" >> "$filename"
    if [ "$i" -lt "$( expr ${#exclude[*]} - 1)" ]; then
      echo -n "|" >> "$filename"
    fi
  done

fi

echo "\" />" >> "$filename"

# file's footer
echo "</group>" >> "$filename"
echo "</launch>" >> "$filename"

cat $filename
roslaunch $filename
