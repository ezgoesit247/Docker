APP=retailsales_datagenerator && run --env=dev --purpose=database --app=${APP} mysql/mysql-server:5.7

ENDCHAR=7 && history|awk '{$1=$2=$3="";print $0}'|grep -E "^(\s)+run(\s)+([ -~])+${ENDCHAR}$"
ENDCHAR=7 && history|awk '{$1=$2=$3="";print $0}'|grep -E "^(\s)+run(\s)+([ -~])+([${ENDCHAR}])$"

# END EITHER 7 || a
ENDCHAR=7a \
&& SEARCHSTR=aifmda \
&& history | awk '{$1=$2=$3="";print $0}' | \
   grep -E "^(\s)*run(\s)+([ -~])+(${SEARCHSTR})+([ -~])+([${ENDCHAR}])$"
