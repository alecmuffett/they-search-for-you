#!/bin/sh -x
src=raw-searches.md
dst=raw-searches-current.md
tmp=/tmp/tsfy-feed.diff
stamp=`datestamp --utc --split`
dir=rss
feed=UPDATES.rss

test -f $dst || cp $src $dst

diff -c $dst $src > $tmp

if [ ! -s $tmp -a -f $feed ] ; then
    exec rm $tmp
    exit 1
fi

test -d $dir || mkdir $dir || exit 1

cp $tmp $dir/$stamp.diff.txt || exit 1

cp $src $dst || exit 1

./dir2rss.pl rss/*.txt > $feed || exit 1

exit 0
