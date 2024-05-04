set -e

# <First folder to compare> <Second folder to compare> <Destination folder>

if [ -d $1 ] && [ -d $2 ]; then
    mainTime=$(cat $1/.pipeline_start_time)
    prTime=$(cat $2/.pipeline_start_time)

    if  [ $mainTime -ge $prTime ]; then
        mv $1 $3
    else
        mv $2 $3
    fi
else
    if [ -d $1 ]; then
        mv $1 $3
    else
        mv $2 $3
    fi
fi