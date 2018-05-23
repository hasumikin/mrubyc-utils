module MrubycUtils
  class << self

    def compile(watch)
      config = load_config
      if watch
      else
        compile_once(config)
      end
    end

    def compile_once(config)
      Dir.foreach("#{config['mruby_lib_dir']}") do |filename|
        next if ['.', '..'].include?(filename)
        basename = filename.sub(/\.rb$/, '')
        command = "mrbc -E -B#{basename} -o#{config['c_lib_dir']}/#{basename}.c #{config['mruby_lib_dir']}/#{filename}"
        puts command
        `#{command}`
      end
    end

  end
end

