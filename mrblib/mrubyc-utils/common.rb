module MrubycUtils
  class << self
    CONFIG_FILE = '.mrubycconfig'

    def cp(from, to)
      unless File.exists?(from)
        puts "WARN - skippeng copy because '#{from}' does not exist"
        return false
      end
      puts "INFO - '#{to}' will be overwritten" if File.exists?(to)
      File.open(from) do |f_from|
        File.open(to, 'w') do |f_to|
          f_to.puts f_from.read
        end
      end
      puts "INFO - copied from '#{from}' to '#{to}'"
    end

    def mkdir(dir)
      if !File.directory?(dir)
        if !Dir.mkdir(dir)
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
        { from: "#{config['mrubyc_repo_dir']}/src/hal_#{config['target']}", to: "#{config['mrubyc_src_dir']}/hal" } ].each do |src|
        Dir.foreach(src[:from]) do |filename|
          next if ['.', '..'].include?(filename)
          from = "#{src[:from]}/#{filename}"
          next if File.directory?(from)
          to = "#{src[:to]}/#{filename}"
          if NO_OVERWRITES.include?(filename) && File.exist?(to)
            puts "WARM - skip copying #{from} because #{to} exists"
            next
          end
          cp(from, to)
        end
        mkdir("#{config['mrubyc_src_dir']}/hal")
      end
    end

  end
end
