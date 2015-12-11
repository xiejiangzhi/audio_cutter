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
    options = {}

    OptionParser.new do |opts|
      opts.banner = "Usage: cutter audio_file [options]"

      opts.on('-oOUT', '--out=OUT', 'Out result to folder') do |out|
        error! "Invalid out dir" unless Dir.exist?(out)
        options[:out] = out
      end

      # range: 0,1.2,-3,5
      # out:
      #   0-1.2s as 1.mp3
      #   1.2-3s ignore
      #   3-5 as 2.mp3
      opts.on('-rRANGE', '--range=RANGE', Array, 'Audio range definition, 1,-2,3') do |range|
        error! "Invalid range" unless valid_range?(range)
        options[:range] = range.map(&:to_f)
      end

      opts.on('-vVOLUMES', '--volumes=VOLUMES', Array, 'Audio volumes definition, 1,-2') do |volumes|
        error! "Invalid volumes" unless valid_volumes?(volumes)
        options[:volumes] = volumes.map(&:to_i)
      end

      # TODO
      #   audio encode
    end.parse!(argv)


    error! "No input audio file" unless argv.first
    error! "Not found audio file" unless File.exist?(argv.first)
    error! "No input range" unless options[:range]
    options[:audio_file] = argv.first
    options[:out] ||= default_dir
    options[:volumes] ||= []

    options
  end

  def valid_range?(range)
    return false if range.length < 2
    return false unless range.all? {|str| str =~ /^\-?\d{1,4}(\.\d)?$/ }
    float_range = range.map(&:to_f)

    float_range.each_with_index do |val, index|
      next if index == 0
      return false if float_range[index - 1] >= val
    end

    true
  end

  def valid_volumes?(volumes)
    volumes.all? {|str| str =~ /^\-?\d{1,3}$/ }
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

