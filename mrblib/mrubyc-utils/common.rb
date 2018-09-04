module MrubycUtils
  class << self
    CONFIG_FILE = '.mrubycconfig'

    def cp(from, to, from_str = nil, to_str = nil)
      unless File.exists?(from)
        puts "\e[31mWARN - skippeng copy because '#{from}' does not exist\e[0m"
        return false
      end
      puts "INFO - '#{to}' will be overwritten" if File.exists?(to)
      File.open(from) do |f_from|
        File.open(to, 'w') do |f_to|
          if from_str && to_str
            f_to.puts f_from.read.split(from_str).join(to_str) # String#tr の代わりのつもり
          else
            f_to.puts f_from.read
          end
        end
      end
      puts "INFO - copied from '#{from}' to '#{to}'"
    end

    def mkdir_p(dir)
      return unless dir
      if !File.directory?(dir)
        if !Dir.mkdir_p(dir)
          puts "FATAL - failed to create directory: #{dir}"
          raise RuntimeError
        end
      end
      puts "INFO - created '#{dir}/'"
    end

    def save_config(config)
      File.open(CONFIG_FILE, 'w') do |f|
        f.puts YAML.dump(config)
      end
    end

    def load_config
      unless File.exists?(CONFIG_FILE)
        puts "FATAL - #{CONFIG_FILE} is not found. You have to `mrubyc-utils install` first or confirm your current directory"
        return false
      end
      File.open(CONFIG_FILE) do |f|
        YAML.load(f.read)
      end
    end

    def copy_mrubyc_to_src(config)
      [ { from: "#{config['mrubyc_repo_dir']}/src", to: config['mrubyc_src_dir'] },
        { from: "#{config['mrubyc_repo_dir']}/src/hal_#{config['target']}", to: "#{config['mrubyc_src_dir']}/hal" },
        { from: "#{config['mrubyc_repo_dir']}/mrblib", to: config['mrubyc_mrblib_dir'] }].each do |src|
        Dir.foreach(src[:from]) do |filename|
          next if ['.', '..'].include?(filename)
          from = "#{src[:from]}/#{filename}"
          next if File.directory?(from)
          to = "#{src[:to]}/#{filename}"
          if NO_OVERWRITES.include?(filename) && File.exist?(to)
            puts "\e[31mWARM - skip copying #{from} because #{to} exists\e[0m"
            next
          end
          from_str, to_str = if from == "#{config['mrubyc_repo_dir']}/mrblib/Makefile"
            ['/src/', "/#{config['mrubyc_src_dir'].split('/').last}/"] # esp32は階層が深いので
          else
            [nil, nil]
          end
          cp(from, to, from_str, to_str)
        end
        mkdir_p("#{config['mrubyc_src_dir']}/hal")
      end
    end

  end
end

