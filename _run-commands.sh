
APP=retailsales_datagenerator && run --env=dev --purpose=database --app=${APP} mysql/mysql-server:5.7

#  RUN SANDBOX CONTAINER
APP=retailsales_datagenerator && \
run --rm --env=dev --purpose=sandbox --container=${APP} --app=${APP} -v=${APP}:/usr/local/${APP} local/${APP}


SEARCH0=build && ENDWORD=r && \
history | awk '{$1=$2=$3="";print $0}' | grep -E "^(\s)*${SEARCH0}(\s)+([ -~])+[(${ENDWORD})]$"

SEARCH0=run && ENDCHAR=7 && history|awk '{$1=$2=$3="";print $0}'| \
grep -E "^(\s)+${SEARCH0}(\s)+([ -~])+${ENDCHAR}$"


# END EITHER 7 || a
SEARCH0=run && ENDCHAR=7a && SEARCH1=aifmda && history | awk '{$1=$2=$3="";print $0}' | \
grep -E "^(\s)*${SEARCH0}(\s)+([ -~])+(${SEARCH1})+([ -~])+([${ENDCHAR}])$"


SEARCH0=run && DATEFILTER="2021-02-11|2021-02-12" && SEARCH1=sandbox && SEARCH2=-v && \
history | grep -E "${DATEFILTER}" | awk '{$1=$2=$3="";print $0}' | \
grep -E "^(\s)*${SEARCH0}(\s)+([ -~])+(${SEARCH1})+([ -~])+(${SEARCH2})+([ -~])+"


SEARCH0=run && DATEFILTER="2021-02-11|2021-02-12" && SEARCH1=sandbox && SEARCH2=-v && \
history | grep -E "${DATEFILTER}" | awk '{$1=$2=$3="";print $0}' | \
grep -E "^(\s)*${SEARCH0}(\s)+([ -~])+(${SEARCH1})+([ -~])+(${SEARCH2})+([ -~])+"


SEARCH0=run && DATEFILTER="2021-02-11|2021-02-12" && SEARCH1=sandbox && SEARCH2=-v && \
history | grep -E "${DATEFILTER}" | awk '{$1="";print $0}' |   \
grep -E "^(\s)*(\d){4}-(\d){2}-(\d){2}(\s)*(\d){2}:(\d){2}:(\d){2}(\s)*${SEARCH0}(\s)+([ -~])+(${SEARCH1})+([ -~])+" |  \
sort -k1 -k2
