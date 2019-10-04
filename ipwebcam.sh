# https://calculateaspectratio.com/
# https://linux-actif.fr/timelapse
# https://ubuntuforums.org/showthread.php?t=2022316

date=2019-09-30
start=16-55-05
end=19-52-11

date=2019-10-01
start=05-01-40
end=22-17-47

first=photo_${date}_$start
last=photo_${date}_$end
out=mov_${date}_${start}_${end}

args () { paste <(echo $@ | xargs -n1) <(seq $#) | awk '{ print "local " $1 "=$" $2 }'; }

pipe () { test -p $1 || mknod $1 p; }

input () { cut -d/ -f2 | sort | xargs -i echo file {}; }

list_range () { . <(args p f l); find -maxdepth 1 -name '*.jpg' -newer $f.jpg ! -newer $l.jpg | input > $p; }

list_all () { find -maxdepth 1 -name '*.jpg' | input > $p; }

# -pix_fmt yuvj422p
# -pix_fmt yuv420p

mpeg () {
    . <(args p r s m)
    ffmpeg -y -r ${r:=24} -f concat -safe 0 -i ./$p -s ${s:=1280x960} -vcodec libx264 ${m:=out}-$(date +%y-%m-%d-%H-%M)-$s-$r.mp4
}

mov_range () {
    local p f l r s m; local "$@"
    pipe $p; list_range $p $f $l & mpeg $p "$r" "$s" "$m"
}

mov_all () {
    local p r s m; local "$@"
    pipe $p; list_all $p & mpeg $p "$r" "$s" "$m"
}

range () { mov_range p=list f=$first l=$last m=$out; }
all () { mov_all r=$1 s=$2 p=list m=$out; }

interpolate () { ffmpeg -i $1.mp4 -filter minterpolate $1-i.mp4; }

################

start=2019-10-03T00:00:00
  end=2019-10-03T06:00:00

start=2019-10-03T20:30:00
  end=2019-10-03T23:59:00

start () { echo 00-stone/$start; }
end () { echo 00-stone/$end; }
stone () { touch -d $1 00-stone/$1; }
t () { wc -l | tee /dev/stderr | xargs -i echo {}/24 | bc -l; }

stone $start
stone $end

find -maxdepth 1 -name '*.jpg' | t
find 00-rm -name '*.jpg' | t
find -maxdepth 1 -newer $(start) ! -newer $(end) | t
find -maxdepth 1 -newer $(start) ! -newer $(end) | awk NR%2 | t
find -maxdepth 1 -newer $(start) ! -newer $(end) | awk NR%2 | xargs mv -t 00-rm
