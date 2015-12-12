Audio cutter

## Dependent
  * ffmpeg

## Usage

```
# cutter audio_file [global_options] [range range_options] [range2 range2_options] ..."

# Example: 
$ cutter audio_file.mp3 -r1.2,3 -r3,5.5 -v3 -r5.5,7 -v-3
# out 1.mp3 2.mp3 3.mp3 
```

* `-r1.2,3` audio range, start timestamp `1.2`, end timestamp `3`, volume `0`
* `-v3` range volume, unit `dB`, defualt `0`

