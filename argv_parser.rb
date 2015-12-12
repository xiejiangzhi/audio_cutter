require 'optparse'

class ArgvParser
  attr_reader :argv

  def self.parse(argv)
    self.new(argv).options
  end

  def initialize(argv)
    @argv = argv.clone
  end

  def options
    @options ||= parse_options
  end


  private

  def parse_options
    options = {
      range_list: [],
      volume_list: []
    }

    OptionParser.new do |opts|
      opts.banner = "Usage: cutter audio_file [range range_options] [range2 range2_options] ..."

      opts.on('-oOUT', '--out=OUT', 'Out result to folder') do |out_dir|
        error! "Invalid out dir" unless Dir.exist?(out_dir)
        options[:out_dir] = out_dir
      end

      # range: 0,1.2
      # out:
      #   0-1.2s {index}.mp3
      opts.on('-rRANGE', '--range=RANGE', Array, 'Audio range definition, 0,2') do |range|
        error! "Invalid range" unless valid_range?(range)
        options[:range_list] << range.map(&:to_f)
        options[:volume_list] << 0
      end

      opts.on('-vVOLUMES', '--volumes=VOLUMES', 'Audio volume definition, 0') do |volume|
        error! "Invalid volume" unless valid_volume?(volume)
        options[:volume_list][-1] = volume.to_i
      end

      # TODO
      #   audio encode
    end.parse!(argv)


    error! "No input audio file" unless argv.first
    error! "Not found audio file" unless File.exist?(argv.first)
    error! "No input range" unless options[:range_list]
    options[:audio_file] = argv.first
    options[:out_dir] ||= default_dir

    options
  end

  def valid_range?(range)
    return false if range.length != 2
    return false unless range.all? {|str| str =~ /^\-?\d{1,4}(\.\d)?$/ }
    return false if range[0].to_f >= range[1].to_f

    true
  end

  def valid_volume?(volume)
    volume =~ /^\-?\d{1,3}$/
  end

  def default_dir
    system('mkdir -p ./tmp')
    './tmp'
  end

  def error!(msg)
    puts msg
    exit
  end
end

