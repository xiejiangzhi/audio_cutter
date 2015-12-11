class Cutter
  attr_reader :options

  def initialize(options)
    @options = options
  end

  def cut
    cut_index = 0
    cmd = ['ffmpeg', '-y', "-i #{options[:audio_file]}"]

    options[:range].each_with_index do |end_ts, index|
      next if index == 0 || end_ts < 0
      cut_index += 1
      start_ts = options[:range][index - 1].abs
      duration = end_ts - start_ts
      volume = options[:volumes][cut_index - 1]

      cmd << ("-ss %.1f -t %.1f" % [start_ts, duration])
      cmd << ("-af 'volume=%sdB'" % volume) if volume
      cmd << ("#{options[:out]}/%s.mp3" % cut_index.to_s)
    end

    puts cmd.join(' ')
    system(cmd.join(' '))
  end
end

