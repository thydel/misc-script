# https://calculateaspectratio.com/
# https://linux-actif.fr/timelapse
# https://ubuntuforums.org/showthread.php?t=2022316

# https://www.ostechnix.com/20-ffmpeg-commands-beginners/

args () { paste <(echo $@ | xargs -n1) <(seq $#) | awk '{ print "local " $1 "=$" $2 }'; }
pipe () { test -p $1 || mknod $1 p; }
input () { cut -d/ -f2 | sort | xargs -i echo file {}; }
list_range () { . <(args p f l); find -maxdepth 1 -name '*.jpg' -newer $f.jpg ! -newer $l.jpg | input > $p; }
list_all () { find -maxdepth 1 -name '*.jpg' | input > $p; }

# -pix_fmt yuvj422p
# -pix_fmt yuv420p

mpeg2 () {
    . <(args p r s m)
    ffmpeg -y -r ${r:=24} -f concat -safe 0 -i ./$p -s ${s:=1280x960} -vcodec libx264 ${m:=out}-$(today)_$(date +%y-%m-%d-%H-%M)-$s-$r.mp4
}

mpeg () {
    . <(args p r s m)
    ffmpeg -y -r ${r:=24} -f concat -safe 0 -i ./$p -s ${s:=640x480} -vcodec libx264 ${m:=out}-$(today)_$(date +%y-%m-%d-%H-%M)-$s-$r.mp4
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

interpolate_ () { ffmpeg -i $1.mp4 -filter minterpolate $1-i.mp4; }
today () { echo $(basename $(pwd)); }
last () { ls out*[0-9].mp4 | tail -1; }
base () { echo out-$(today); }
link () { ln -f $(last) $(base)-b.mp4; }
interpolate () {
    local ftp pts file; local "$@"; f=$(base);
    ffmpeg -i ${file:=$f}-b.mp4 -filter "minterpolate='fps=${fps:=48}',setpts=${pts:=1}*PTS" ${file=:$f}-i.mp4;
}

################

today () { echo $(basename $(pwd)); }
tomorrow () { date +%F -d "$(today) + 1 day"; }
next-firsts () { find ../$(tomorrow) -maxdepth 1 -name '*.jpg' | sort | head -${1:-24}; }
add-next-first () { next-firsts $1 | xargs ln -fst .; }
point () { echo $(today)T${1}:00; }

init () { mkdir -p .stone .hide; }
stone () { touch -d "$2" .stone/$1; }
stones () { stone start $(point $1); stone end $(point $2); }
start () { echo .stone/start; }
end () { echo .stone/end; }
tv () { wc -l | tee /dev/stderr | xargs -i echo {}/24 | bc | xargs -i date -d@{} -u +%M:%S; }
t () { wc -l | xargs -i echo {}/24 | bc | xargs -i date -d@{} -u +%M:%S; }

jpgs () { find -maxdepth 1 -name '*.jpg'; }
find-range () { find -maxdepth 1 -newer $(start) ! -newer $(end); }
time-all () { jpgs | t; }
time-range () { find-range | t; }
time-hiden () { find .hide -name '*.jpg' | t; }
time-shorten () { find-range | awk NR%2 | t; }
hide () { find-range | awk NR%2 | xargs mv -t .hide; }

tag () { ffmpeg -i $1.mp4 -c copy -map 0 -metadata creation_time="$(today)T12:00:00.0Z" $1-t.mp4; }

################

paris () { echo 48.8566N 2.3522E; }
sun () { sunwait list $1 $(paris); }
now () { date +%s; }
before () { date -d "$(sun rise) 30 minutes ago" +%s; }
after () { date -d "$(sun set) 30 minutes" +%s; }
pause () { if test $(now) -lt $(before) -o $(now) -gt $(after); then echo 60; else echo 10; fi; }

the-day-file () { ls *.jpg | head -1; }
the-day-sunwait () { the-day-file | xargs -i date -r {} +'d %d m %m y %y'; }
the-day-sun () { sunwait list $1 $(the-day-sunwait); }
the-day-start () { the-day-file | xargs -i date -r {} +%F; }
the-day-end () { date -d "$(the-day-start) + 1 day - 1 second" +%s; }
the-day-rise () { date +%s -d "$(date -d $(the-day-start)T$(the-day-sun rise)) - 1 hour"; }
the-day-set ()  { date +%s -d "$(date -d $(the-day-start)T$(the-day-sun set))  + 1 hour"; }

stones-rise () { stone start "$(the-day-start)"; stone end @$(the-day-rise); }
stones-set  () { stone start @$(the-day-set); stone end @$(the-day-end); }

url () { echo https://manin/shot.jpg; }
geto () { wget -q --no-check-certificate --user=manin --password="$(pass ipcam/nexus4)" $(url) -O $(date +%FT%T).jpg; }
export ipcam_nexus4=$(pass ipcam/nexus4)
get () { wget -q --no-check-certificate --user=manin --password="$ipcam_nexus4" $(url) -O $(date +%FT%T).jpg; }
loop () { while true; do get; sleep $(pause); done; }
endloop () { pgrep sleep | xargs ps -ho ppid | xargs kill; }

mpvx () { mpv -vo=xv $1; }

################

jpegoptim -pvm95 *.jpg
jpgs | xargs jpegoptim -pvm95
init; add-next-first

stones-rise; hide; hide; hide
stones-set; hide; hide; hide

#time-all; time-range; time-hiden

all

mpvx $(ls *.mp4 | tail -1)

################

loop() { while read; do eval $@ $REPLY; done; }
list() { find ${1:?} -type f -name '*.jpg' -mtime +0 | sort; }
optim() { list $1 | xargs -r jpegoptim -pvm95; }
move1() { d=$(date +%F -r $2); echo mkdir -p $1/$d; echo mv $2 $1/$d; }
move() { list $1 | loop move1 $2; }

optim()(list()(find ${1:?} -type f -name '*.jpg' -mtime +0 | sort); list $1 | xargs -r jpegoptim -pvm95)

cd ~/Downloads/nexus4/shot
optim .
move . ~/ipwebcam/shots

################
