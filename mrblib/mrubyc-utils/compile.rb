module MrubycUtils
  class << self

    def compile(mode)
      config = load_config
      print "\e[31m"
      puts 'Warning: you should compile by `make` and maintain Makefile. But compiling anyway...' if ['posix', 'esp32'].include?(config['target'])
      print "\e[0m"
      puts
      file_digests = Hash.new
      while true
        Dir.foreach("#{config['mruby_lib_dir']}") do |filename|
          next if File.extname(filename) != '.rb'
          next if file_digests[filename] == digest("#{config['mruby_lib_dir']}/#{filename}")
          file_digests[filename] = compile_it(config, filename)
        end
        #puts file_digests
        break unless mode == 'watch'
        sleep 1
      end
    end

    def compile_it(config, filename)
      filepath = "#{config['mruby_lib_dir']}/#{filename}"
      basename = filename.sub(/\.rb$/, '')
      command = "mrbc -E -B#{basename} -o#{config['c_lib_dir']}/#{basename}.c #{filepath}"
      puts command
      `#{command}`
      digest(filepath)
    end

    def digest(filepath)
      Digest::MD5.digest(File.open(filepath){ |f| f.read })
    end

  end
end

