#!/bin/sh -x
src=raw-searches.md
dst=old-searches.md
tmp=/tmp/tsfy-feed.diff
stamp=`datestamp --utc --split`
dir=rss
feed=UPDATES.rss

test -d $dir || mkdir $dir || exit 1

test -f $dst || cp $src $dst

diff -c $dst $src > $tmp

if [ -s $tmp ] ; then
    cp $tmp $dir/$stamp.diff.txt || exit 1
    cp $src $dst || exit 1
fi

./dir2rss.pl $dir/*.txt > $feed || exit 1

exit 0
