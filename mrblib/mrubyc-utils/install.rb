module MrubycUtils
  class << self
    CONFIGURATIONS = {
      target: {
        question: 'target microcontroller',
        default: 'psoc5lp'
      },
      mrubyc_repo_dir: {
        question: 'dir name of mruby/c repository',
        default: '.mrubyc'
      },
      mrubyc_src_dir: {
        question: 'dir name where mruby/c\'s sources are located (main.c will include them)',
        default: 'mrubyc_src'
      },
      mruby_lib_dir: {
        question: 'dir name where your mruby code are lacated',
        default: 'mrblib'
      },
      c_lib_dir: {
        question: 'dir name where your compiled mruby byte codes are located',
        default: 'src'
      },
      prefix: {
        question: 'prefix of your mruby source file name',
        default: 'job'
      }
    }

    def install
      config = {}
      CONFIGURATIONS.each do |key, value|
        print "#{value[:question]} [#{value[:default]}]: "
        config[key] = gets.chomp
        config[key] = value[:default] if config[key].empty?
      end
      save_config(config)
      git_clone_mrubyc(config)
      create_mrubyc_src_dir(config)
      copy_mrubyc_to_src(config)
      create_mruby_lib_dir(config)
      download_templates(config)
      create_c_lib_dir(config)
      add_gitignore(config)
    end

    def git_clone_mrubyc(config)
      `git clone https://github.com/mrubyc/mrubyc.git #{config[:mrubyc_repo_dir]}`
    end

    def copy_mrubyc_to_src(config)
      src = "#{config[:mrubyc_repo_dir]}/src"
      Dir.foreach(src) do |filename|
        next if ['.', '..'].include?(filename)
        from = "#{src}/#{filename}"
        next if File.directory?(from)
        to = "#{config[:mrubyc_src_dir]}/#{filename}"
        cp(from, to)
      end
      mkdir("#{config[:mrubyc_src_dir]}/hal")
      ['h', 'c'].each do |ext|
        cp("#{config[:mrubyc_repo_dir]}/src/hal_#{config[:target]}/hal.#{ext}", "#{config[:mrubyc_src_dir]}/hal/hal.#{ext}")
      end
    end

    def create_mrubyc_src_dir(config)
      mkdir(config[:mrubyc_src_dir])
    end

    def create_c_lib_dir(config)
      mkdir(config[:c_lib_dir])
    end

    def create_mruby_lib_dir(config)
      mkdir(config[:mruby_lib_dir])
    end

    def download_templates(config)
      mruby_lib_dir = config[:mruby_lib_dir]
      prefix = config[:prefix]
      http = HttpRequest.new()
      [ { from: "targets/#{config[:target]}/main.c.erb", to: 'main.c' },
        { from: "targets/#{config[:target]}/gitignore", to: '.gitignore' },
        { from: 'mrblib/prefix_main_loop.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_main_loop.rb" },
        { from: 'mrblib/prefix_sub_loop.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_sub_loop.rb" },
        { from: 'mrblib/prefix_operations.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_operations.rb" }
      ].each do |template|
        url = sprintf("https://%s/%s/%s", 'raw.githubusercontent.com', 'hasumon/mrubyc-utils/master/templates', template[:from])
        puts "INFO - download #{url}"
        request = http.get(url, {})
        if request.code != 200
          puts "FATAL - template file '#{url}' was not found"
          raise RuntimeError
        end
        erb = if File.extname(template[:to]) == '.c'
          request.body.gsub(/\n/, "\r\n")
        else
          request.body
        end
        File.open(template[:to], 'w') do |f|
          f.puts erb_result(erb, config)
        end
        puts "INFO - saved #{template[:to]}"
      end
    end

    def erb_result(erb, hash)
      hash.each do |key, value|
        erb.gsub!("<%= #{key} %>", value)
      end
      erb
    end

    def add_gitignore(config)
      File.open('.gitignore', 'a') do |f|
        ['# added by mrubyc-utils', "#{config[:mrubyc_repo_dir]}/"].each do |line|
          f.puts line
          puts "INFO - \"#{line}\" was added to .gitignore"
        end
      end
    end

  end
end
