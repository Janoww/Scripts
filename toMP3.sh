
# Loop through all .mp4 files in the current directory
for file in *.mp4; do
    # Skip if no .mp4 files are found
    [ -e "$file" ] || continue

    # Get the base filename without extension
    base="${file%.mp4}"

    # Convert to mp3
    ffmpeg -i "$file" -q:a 0 -map a "${base}.mp3"
done

echo "Conversion complete."
tput bel

