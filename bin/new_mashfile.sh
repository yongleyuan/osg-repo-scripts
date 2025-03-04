#!/bin/bash

usage () {
  echo "Usage: $(basename "$0") TAG [DESTDIR]"
  echo "Where:"
  echo "  TAG is osg-SERIES-DVER-REPO or devops-DVER-REPO"
  echo "  SERIES is: 3.X (3.5, 3.6, etc), or 3.X-upcoming"
  echo "  DVER is: el7, el8, etc."
  echo "  REPO is: contrib, development, testing, or release for osg"
  echo "       or: itb or production for devops (formerly goc)"
  echo "  DESTDIR defaults to /etc/mash/"
  echo
  echo "Writes DESTDIR/TAG.mash"
  exit
}

case $# in
  1 ) DESTDIR=/etc/mash ;;
  2 ) DESTDIR=$2 ;;
  * ) usage ;;
esac


upper () { python -c 'import sys; print sys.argv[1].upper()' "$*" ; }
title () { python -c 'import sys; print sys.argv[1].title()' "$*" ; }

TAG=$1
case $TAG in
  osg-3.*-upcoming-*-* ) IFS='-' read osg SERIES upcoming DVER REPO <<< "$TAG"
                         SERIES+=-$upcoming ;;
  osg-*-*-* ) IFS='-' read osg SERIES DVER REPO <<< "$TAG" ;;
  devops-*-*) IFS='-' read SERIES DVER REPO <<< "$TAG" ;;
          * ) usage ;;
esac

# repoviewtitle looks something like: OSG 3.1 RHEL5 Contrib
REPOVIEWTITLE="OSG $(title $SERIES) RH$(upper $DVER) $(title $REPO)"

case $REPO in
  release | rolling | itb | production ) LATEST="latest=false" ;;
        * ) LATEST="" ;;
esac

case $DVER in
  el5|el6 ) ARCHES="i386 x86_64" ;;
        * ) ARCHES="x86_64" ;;
esac

TEMPLATEDIR=/usr/share/repo

sed "
  s/{YUMREPO}/$TAG/
  s/{REPO}/$REPO/
  s/{DVER}/$DVER/
  s/{SERIES}/$SERIES/
  s/{REPOVIEWTITLE}/$REPOVIEWTITLE/
  s/{KOJI_TAG}/$TAG/
  s/{ARCHES}/$ARCHES/
  s/{LATEST}/$LATEST/
" "$TEMPLATEDIR"/mash.template > "$DESTDIR/$TAG.mash"

