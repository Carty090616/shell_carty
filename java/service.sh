#!/bin/bash
app_name="$2"
activeup="$3"
if [ $# -lt 1 ];
then
  echo "USAGE: $0 classname opts"
  exit 1
fi

JAR_PATH=`ls /usr/local/${app_name}/*.jar`
if [[ ! "$?" == "0" || ! -e $JAR_PATH ]]; then
	echo "Do you forget ./package.sh ?"
	exit 2
fi

SERVICE_NAME="${app_name}""-server"

PID_FILE="$JAR_PATH.pid"
JDK_PATH=/usr/local/jdk1.8
KEYWORD="$JAR_PATH"

JAVA_OPTS="$JAVA_OPTS -server -Xms512m -Xmx512m -Xmn256m"
JAVA_OPTS="$JAVA_OPTS -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=70 -XX:+CMSParallelRemarkEnabled -XX:SoftRefLRUPolicyMSPerMB=0 -XX:+CMSClassUnloadingEnabled -XX:SurvivorRatio=8 -XX:+DisableExplicitGC"
JAVA_OPTS="$JAVA_OPTS -verbose:gc -Xloggc:/usr/local/${app_name}/gc.log -XX:+PrintGCDetails"
JAVA_OPTS="$JAVA_OPTS -XX:-OmitStackTraceInFastThrow"
JAVA_OPTS="$JAVA_OPTS -Djava.ext.dirs=/usr/local/jdk1.8/jre/lib/ext"
JAVA_OPTS="$JAVA_OPTS -jar "
JAVA="$JDK_PATH/bin/java"

KEYWORD="$JAR_PATH"

RUN_PARAM="--spring.profiles.active=""${activeup}  "

# Returns 0 if the process with PID $1 is running.
function checkProcessIsRunning {
   local pid="$1"
   ps -ef | grep java | grep $pid | grep "$KEYWORD" | grep -q --binary -F java
   if [ $? -ne 0 ]; then return 1; fi
   return 0;
}

# Returns 0 when the service is running and sets the variable $pid to the PID.
# 获取服务的pid
function getServicePID {
   if [ ! -f $PID_FILE ]; then return 1; fi
   pid="$(<$PID_FILE)"
   checkProcessIsRunning $pid || return 1
   return 0; }

function startServiceProcess {
   touch $PID_FILE
   rm -rf nohup.log
   nohup $JAVA $JAVA_OPTS $KEYWORD $RUN_PARAM >> /usr/local/${app_name}/nohup.log 2>&1 & echo $! > $PID_FILE
   sleep 0.1
   pid="$(<$PID_FILE)"
   if checkProcessIsRunning $pid; then :; else
      echo "$SERVICE_NAME start failed, see nohup.log."
      return 1
   fi
   return 0;
}

function stopServiceProcess {
   STOP_DATE=`date +%Y%m%d%H%M%S`
   kill $pid || return 1
   for ((i=0; i<3; i++)); do
      checkProcessIsRunning $pid
      if [ $? -ne 0 ]; then
         rm -f $PID_FILE
         return 0
         fi
      sleep 1
      done
   echo "\n$SERVICE_NAME did not terminate within 10 seconds, sending SIGKILL..."
   kill -s KILL $pid || return 1
   local killWaitTime=15
   for ((i=0; i<3; i++)); do
      checkProcessIsRunning $pid
      if [ $? -ne 0 ]; then
         rm -f $PID_FILE
         return 0
         fi
      sleep 1
      done
   echo "Error: $SERVICE_NAME could not be stopped within 10 + 10 seconds!"
   return 1;
}

# 启动服务的主方法
function startService {
   getServicePID
   if [ $? -eq 0 ]; then echo "$SERVICE_NAME is already running"; RETVAL=0; return 0; fi
   echo -n "Starting $SERVICE_NAME..."
   startServiceProcess
   if [ $? -ne 0 ]; then RETVAL=1; echo "failed"; return 1; fi
   COUNT=0
   while [ $COUNT -lt 1 ]; do
    for (( i=0;  i<15;  i=i+1 )) do
        STR=`grep "started success" /usr/local/${app_name}/nohup.log`
        if [ ! -z "$STR" ]; then
            echo "PID=$pid"
            echo "Server start OK in $i seconds."
            break;
        fi
	    echo -e ".\c"
	    sleep 1
	done
	break
    done
echo "OK!"
#START_PIDS=`ps  --no-heading -C java -f --width 1000 | grep "$DEPLOY_HOME" |awk '{print $2}'`
#echo "PID: $START_PIDS"
#   echo "started PID=$pid"
   RETVAL=0
   return 0;
}

# 停止服务的主方法
function stopService {
   getServicePID
   if [ $? -ne 0 ]; then echo -n "$SERVICE_NAME is not running"; RETVAL=0; echo ""; return 0; fi
   echo "Stopping $SERVICE_NAME... "
   stopServiceProcess
   if [ $? -ne 0 ]; then RETVAL=1; echo "failed"; return 1; fi
   echo "stopped PID=$pid"
   RETVAL=0
   return 0;
}

# 检查服务状态
function checkServiceStatus {
   echo -n "Checking for $SERVICE_NAME: "
   if getServicePID; then
	echo "running PID=$pid"
	RETVAL=0
   else
	echo "stopped"
	RETVAL=3
   fi
   return 0;
}

# 主方法
function main {
   RETVAL=0
   case "$1" in
      start)
         startService
         ;;
      stop)
         stopService
         ;;
      restart)
         stopService && startService
         ;;
      status)
         checkServiceStatus
         ;;
      *)
         echo "Usage: $0 {start|stop|restart|status}"
         exit 1
         ;;
      esac
   exit $RETVAL
}

# 启动主方法
main $1
