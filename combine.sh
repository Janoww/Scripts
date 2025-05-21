# >bash combine.sh param1 param2 param3

# $1: orizzontal res (ex: 1920)
# $2: vertical res (ex: 1080)
# $3: output name (ex: Lezione-4)

rm -rf normalized_videos
rm -f filelist.txt

mkdir -p normalized_videos

ls *.wmv > filelist.txt
while IFS= read -r file; do
  echo "wmv-mp4 conversion: $file"
  ffmpeg -i "$file" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 192k "$(basename "$file" .wmv).mp4" &
done < filelist.txt

ls *.m4v > filelist.txt
while IFS= read -r file; do
  echo "m4v-mp4 conversion: $file"
  ffmpeg -i "$file" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 192k "$(basename "$file" .m4v).mp4" &
done < filelist.txt

wait

ls *.mp4 > filelist.txt

filelist=()
while IFS= read -r line; do
  filelist+=("$line")
done < filelist.txt

echo "Total files: ${#filelist[@]}"
for f in "${filelist[@]}"; do
  echo "$f"
done

for file in "${filelist[@]}"; do
  echo "The file is: $file"

  resolution=$(ffprobe -v error -select_streams v:0 -show_entries stream=width,height -of csv=p=0 "$file")

  if [ "$resolution" != "$1,$2" ]; then
    ffmpeg -i "$file" -vf "scale=$1:$2:force_original_aspect_ratio=decrease,pad=$1:$2:(ow-iw)/2:(oh-ih)/2" -c:v libx264 -crf 23 -preset fast -c:a aac -b:a 192k "normalized_videos/$(basename "$file" .mp4)_n.mp4" &
  else
    ffmpeg -i "$file" -c:v copy -c:a copy "normalized_videos/$(basename "$file" .mp4)_n.mp4" &
  fi

  echo '...........................................................................................'
done

wait

echo 'GOING IN NORMALIZED_VIDEOS # # # # # # # # # # # # # # # # # # # # # # # # # # # # '
cd normalized_videos || exit
ls *.mp4 > filelist.txt

while IFS= read -r file; do
  ffmpeg -i "$file" -c copy -bsf:v h264_mp4toannexb -f mpegts "$(basename "$file" .mp4).ts"
done < filelist.txt

for f in *.ts; do
  echo "file '$f'"
done > concat_list.txt

ffmpeg -f concat -safe 0 -i concat_list.txt -c copy "$3.mp4"

echo "All videos have been processed!"
tput bel
