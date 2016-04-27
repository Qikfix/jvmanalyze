#!/bin/bash


#
# Date ......: 04/27/2016
# Developer .: Waldirio Pinheiro <waldirio@redhat.com>
# Purpose ...: Monitoring the heap size (JVM)
# Changelog .:
#

BASE_OPENJDK_BIN="/usr/lib/jvm/java-1.7.0-openjdk-1.7.0.101.x86_64/bin"
STAGE="/tmp"
LOG="/var/log/rhn/jvm_usage_report.log"


CheckReq()
{
  packageTest1=$(rpm -qa |grep java-1.7.0-openjdk-devel|wc -l)
  if [ $packageTest1 -eq 1 ]; then
    echo "Ok, OpenJDK Devel Installed, we can continue"
  else
    echo "Please install the package java-1.7.0-openjdk-devel (yum install java-1.7.0-openjdk-devel)"
    echo "Will be necessary to execute the script and generate the report. Exiting ...."
    exit 1
  fi


  packageTest2=$(rpm -qa |grep java-1.7.0-openjdk-debuginfo|wc -l)
  if [ $packageTest2 -eq 1 ]; then
    echo "Ok, OpenJDK Debuginfo installed, we can continue"
  else
    echo "It's extremelly recommended add a repo rhel-x86_64-server-6-debuginfo and execute the command below:"
    echo "# debuginfo-install java-1.7.0-openjdk"  
    echo "Will be installed some packages, this will enable some aditional information about JVMs"
    exit 1
  fi

}

Collect()
{

  Date=$(date +'%m-%d-%Y')
  Time=$(date +'%H:%M:%S')

  # Header Log File
  echo "Date,Time,JVM Process,JVM Name,HC-MinHeapFreeRatio,HC-MaxHeapFreeRatio,HC-MaxHeapSize,HC-NewSize,HC-MaxNewSize,HC-OldSize,HC-NewRatio,HC-SurvivorRatio,HC-PermSize,HC-MaxPermSize,HC-G1HeapRegionSize,HU-NG-capacity,HU-NG-used,HU-NG-free,HU-NG-perc-used,HU-Eden-capacity,HU-Eden-used,HU-Eden-free,HU-Eden-perc-used,HU-FromSpace-capacity,HU-FromSpace-used,HU-FromSpace-free,HU-FromSpace-perc-used,HU-ToSpace-capacity,HU-ToSpace-used,HU-ToSpace-free,HU-ToSpace-perc-used,HU-OldGen-capacity,HU-OldGen-used,HU-OldGen-free,HU-OldGen-perc-used,HU-Perm-capacity,HU-Perm-used,HU-Perm-free,HU-Perm-perc-used" | tee -a $LOG

  listJvmProcess=$($BASE_OPENJDK_BIN/jps | grep -v Jps | sed -e 's/ /-/g')


  for b in $listJvmProcess
  do
    jvmPID=$(echo "$b" | cut -d"-" -f1)
    jvmName=$(echo "$b" | cut -d"-" -f2)
    
    echo "===> $jvmPID"
    echo "===> $jvmName"
    heapDesc=$($BASE_OPENJDK_BIN/jmap -heap $jvmPID)

    countHeap=$(echo "$heapDesc"|wc -l)
    if [ $countHeap -ne 1 ]; then
      echo "$heapDesc" > $STAGE/$jvmPID-$jvmName.txt
      Process $STAGE/$jvmPID-$jvmName.txt
    fi

  done

}

Process()
{
  echo "file $1"

  processId=$(echo $1|cut -d"-" -f1|cut -d"/" -f3)
  processName=$(echo $1|cut -d"-" -f2|cut -d. -f1)


  # All size here in Bytes

# Heap Configuration
  heapConf=$(cat $1 |awk '/^Heap Configuration:/,/^$/')

  MinHeapFreeRatio=$(echo "$heapConf"|grep " MinHeapFreeRatio" | awk '{print $3}')
  MaxHeapFreeRatio=$(echo "$heapConf"|grep " MaxHeapFreeRatio" | awk '{print $3}')
  MaxHeapSize=$(echo "$heapConf"|grep " MaxHeapSize" | awk '{print $3}')
  NewSize=$(echo "$heapConf"|grep " NewSize" | awk '{print $3}')
  MaxNewSize=$(echo "$heapConf"|grep " MaxNewSize" | awk '{print $3}')
  OldSize=$(echo "$heapConf"|grep " OldSize" | awk '{print $3}')
  NewRatio=$(echo "$heapConf"|grep " NewRatio" | awk '{print $3}')
  SurvivorRatio=$(echo "$heapConf"|grep " SurvivorRatio" | awk '{print $3}')
  PermSize=$(echo "$heapConf"|grep " PermSize" | awk '{print $3}')
  MaxPermSize=$(echo "$heapConf"|grep " MaxPermSize" | awk '{print $3}')
  G1HeapRegionSize=$(echo "$heapConf"|grep " G1HeapRegionSize" | awk '{print $3}')

  heapConfVars="$Date,$Time,$processId,$processName,$MinHeapFreeRatio,$MaxHeapFreeRatio,$MaxHeapSize,$NewSize,$MaxNewSize,$OldSize,$NewRatio,$SurvivorRatio,$PermSize,$MaxPermSize,$G1HeapRegionSize" 

# # # # # Heap Usage

# New Generation
  heapNewGen=$(cat $1 |awk '/^New Generation/,/used$/')

  capacity=$(echo "$heapNewGen"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapNewGen"|grep " used" | awk '{print $3}')
  free=$(echo "$heapNewGen"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapNewGen"|grep "%" | awk '{print $1}')

  heapNewGenVars="$capacity,$used,$free,$percentUsed"

# Eden Space
  heapEden=$(cat $1 |awk '/^New Generation/,/used$/')

  capacity=$(echo "$heapEden"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapEden"|grep " used" | awk '{print $3}')
  free=$(echo "$heapEden"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapEden"|grep "%" | awk '{print $1}')

  heapEdenVars="$capacity,$used,$free,$percentUsed"


# From Space
  heapFromSpace=$(cat $1 |awk '/^Eden Space/,/used$/')

  capacity=$(echo "$heapFromSpace"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapFromSpace"|grep " used" | awk '{print $3}')
  free=$(echo "$heapFromSpace"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapFromSpace"|grep "%" | awk '{print $1}')

  heapFromSpaceVars="$capacity,$used,$free,$percentUsed"


# To Space
  heapToSpace=$(cat $1 |awk '/^New Generation/,/used$/')

  capacity=$(echo "$heapToSpace"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapToSpace"|grep " used" | awk '{print $3}')
  free=$(echo "$heapToSpace"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapToSpace"|grep "%" | awk '{print $1}')

  heapToSpaceVars="$capacity,$used,$free,$percentUsed"


# Tenured Generation
  heapOldGen=$(cat $1 |awk '/^New Generation/,/used$/')

  capacity=$(echo "$heapOldGen"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapOldGen"|grep " used" | awk '{print $3}')
  free=$(echo "$heapOldGen"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapOldGen"|grep "%" | awk '{print $1}')

  heapOldGenVars="$capacity,$used,$free,$percentUsed"


# Perm Generation
  heapPermGen=$(cat $1 |awk '/^New Generation/,/used$/')

  capacity=$(echo "$heapPermGen"|grep " capacity" | awk '{print $3}')
  used=$(echo "$heapPermGen"|grep " used" | awk '{print $3}')
  free=$(echo "$heapPermGen"|grep " free" | awk '{print $3}')
  percentUsed=$(echo "$heapPermGen"|grep "%" | awk '{print $1}')

  heapPermGenVars="$capacity,$used,$free,$percentUsed"
#############################################################################




echo "$heapConfVars,$heapNewGenVars,$heapEdenVars,$heapFromSpaceVars,$heapToSpaceVars,$heapOldGenVars,$heapPermGenVars" | tee -a $LOG

}


# Main
CheckReq
Collect
