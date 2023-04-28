#!/bin/bash

if [ -z  "$1" ]; then
  echo  "usage: shpl.sh book-url"
  exit  1
fi

if [ "$#" -ne  1 ]; then
  echo  "usage: shpl.sh book-url"
  exit  1
fi

URL="$1"
BOOKID=${URL#*nodes\/*}
BOOKID=${BOOKID%%-*}
INDEXP="./shpl-$BOOKID/$BOOKID-index.html"
CLEANL="./shpl-$BOOKID/$BOOKID-image_list.txt"
INDEXL="./shpl-$BOOKID/$BOOKID-initDocview.txt"

mkdir -p "shpl-$BOOKID"

echo  "Loading root page ..."
wget --quiet -O  $INDEXP  $URL
if \[ "$?" -ne  0 \]; then
  echo  "Unable to load the page"
  exit  1
fi

grep 'initDocview' $INDEXP > $INDEXL
awk  'BEGIN { RS = "{\"id\"" } ; { print $0 }' $INDEXL | grep -oG ':[1-9]......,' | tr -d ':,' > $CLEANL

NPAGES=`wc -l < $CLEANL`
echo  Number  of  pages: $NPAGES

PAGEIDS=`cat $CLEANL`
PAGE=1
for  ID  in  $PAGEIDS ; do
  echo  "Loading page $PAGE (of $NPAGES) ..."
  URL="http://elib.shpl.ru/pages/$ID/zooms/7"
  wget --quiet -O  ./shpl-$BOOKID/$BOOKID-$(printf '%04d' "$PAGE").jpg  $URL
  if [ "$?" -ne  0 ]; then
  echo  "Unable to load the page ($URL)"
  exit  1
  fi
  let  PAGE=PAGE+1
done

rm -f $CLEANL
rm -f $INDEXP
rm -f $INDEXL
