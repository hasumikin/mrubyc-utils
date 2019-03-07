module MrubycUtils
  class << self
    CONFIGURATIONS = {
      'target' => {
        'question' => "target microcontroller",
        'default' => 'psoc5lp|esp32|posix',
        'match' => /\A(psoc5lp|esp32|posix)\z/
      },
      'mruby_version' => {
        'question' => "mruby version that you want to compile your firmware with",
        'default' => 'mruby-x.x.x',
        'match' => /\Amruby-\d+\.\d+\.\d+\z/,
        'proc' => Proc.new { |mruby_version| system "echo #{mruby_version} > .ruby-version"},
      },
      'cruby_version' => {
        'question' => "CRuby version that you want to use for mrubyc-test",
        'default' => 'x.x.x',
        'match' => /\A\d+\.\d+\.\d+\z/
      },
      'mrubyc_repo_dir' => {
        'skip' => true,
        'question' => 'dir name of mruby/c repository',
        'psoc5lp' => '.mrubyc',
        'esp32' => '.mrubyc',
        'posix' => '.mrubyc'
      },
      'mrubyc_src_dir' => {
        'skip' => true,
        'question' => 'dir name where mruby/c\'s sources are located (main.c will include them)',
        'esp32' => 'components/mrubyc/mrubyc_src',
        'default' => 'mrubyc_src'
      },
      'mrubyc_mrblib_dir' => {
        'skip' => true,
        'question' => 'dir name where mruby/c\'s mrblib files are located (they will are compiled as [mrubyc_src_dir]/mrblib.c)',
        'esp32' => 'components/mrubyc/mrubyc_mrblib',
        'default' => 'mrubyc_mrblib'
      },
      'mruby_lib_dir' => {
        'skip' => true,
        'question' => 'dir name where your mruby code are lacated',
        'default' => 'mrblib'
      },
      'c_lib_dir' => {
        'skip' => true,
        'question' => 'dir name where your compiled mruby byte codes are located',
        'esp32' => '_skip_',
        'default' => 'src'
      }
    }
    NO_OVERWRITES = ['vm_config.h']
    INVALID = "\e[31;1m  Invalid input. Try agin\e[0m"

    def install
      config = {}
      CONFIGURATIONS.each do |key, value|
        next if value[config['target']] == '_skip_'
        default = value[config['target']] || value['default']
        if value['skip']
          config[key] = default
          next
        end
        while true
          print "#{value['question']} [#{default}]: "
          config[key] = gets.chomp
          config[key] = default if config[key].empty?
          if value['match'].nil?
            break
          else
            if config[key].match(value['match'])
              break
            else
              puts INVALID
            end
          end
        end
        if value['proc']
          value['proc'].call(config[key])
        end
      end
      return false unless confirm(config)
      save_config(config)
      return false unless git_submodule_add_mrubyc(config)
      create_main_dir if config['target'] == 'esp32'
      create_mrubyc_src_dir(config)
      create_mrubyc_mrblib_dir(config)
      copy_mrubyc_to_src(config)
      create_mruby_lib_dir(config)
      download_templates(config)
      create_c_lib_dir(config)
    end

    YES = ['yes']
    OBSCURITY = ['y', 'Y', 'YES']
    NO = ['n', 'N', 'NO', 'no', 'No']
    def confirm(config)
      puts "\nmruby/c and templates will be installed with configuration below:"
      config.each do |key, value|
        next if key == 'target'
        puts "  #{CONFIGURATIONS[key]['question']}: #{value}"
      end
      puts 'Note that some file may be overwritten.'
      while true
        print 'continue to install? (yes/no): '
        answer = gets.chomp
        break if (YES + NO).include?(answer)
        puts 'You should type exactly `yes`.' if OBSCURITY.include?(answer)
      end
      return true if YES.include?(answer)
      if NO.include?(answer)
        puts "\e[31mabort\e[0m"
        return false
      end
    end

    def git_submodule_add_mrubyc(config)
      if Dir.exist?(config['mrubyc_repo_dir'])
        puts "\e[31;1mFATAL - #{config['mrubyc_repo_dir']} already exists!\e[0m"
        return false
      end
      puts "INFO - git init"
      `git init`
      puts "INFO - git submodule add git://github.com/mrubyc/mrubyc.git #{config['mrubyc_repo_dir']}"
      `git submodule add git://github.com/mrubyc/mrubyc.git #{config['mrubyc_repo_dir']}`
      return true
    end

    def create_main_dir
      mkdir_p('main')
    end

    def create_mrubyc_src_dir(config)
      mkdir_p(config['mrubyc_src_dir'])
    end

    def create_mrubyc_mrblib_dir(config)
      mkdir_p(config['mrubyc_mrblib_dir'])
    end

    def create_c_lib_dir(config)
      mkdir_p(config['c_lib_dir'])
    end

    def create_mruby_lib_dir(config)
      mkdir_p(config['mruby_lib_dir'] + '/loops')
      mkdir_p(config['mruby_lib_dir'] + '/models')
    end

    def download_templates(config)
      mruby_lib_dir = config['mruby_lib_dir']
      http = HttpRequest.new()
      loops = case config['target']
      when 'esp32'
        [ { from: "targets/#{config['target']}/Makefile.erb", to: 'Makefile' },
          { from: "targets/#{config['target']}/components/mrubyc/component.mk.erb", to: 'components/mrubyc/component.mk' },
          { from: "targets/#{config['target']}/main/main.c.erb", to: 'main/main.c' },
          { from: "targets/#{config['target']}/main/component.mk.erb" , to: 'main/component.mk' } ]
      when 'posix'
        [ { from: "targets/#{config['target']}/Makefile.erb", to: 'Makefile' },
          { from: "targets/#{config['target']}/main.c.erb", to: 'main.c' } ]
      when 'psoc5lp'
        [ { from: "targets/#{config['target']}/main.c.erb", to: 'main.c' } ]
      end
      (loops + [
        { from: "targets/#{config['target']}/gitignore.erb", to: '.gitignore' },
        { from: 'mrblib/loops/main_loop.rb.erb', to: "#{mruby_lib_dir}/loops/main_loop.rb" },
        { from: 'mrblib/loops/sub_loop.rb.erb', to: "#{mruby_lib_dir}/loops/sub_loop.rb" },
        { from: 'mrblib/models/operations.rb.erb', to: "#{mruby_lib_dir}/models/operations.rb" }
      ]).each do |template|
        url = sprintf("https://%s/%s/%s", 'raw.githubusercontent.com', 'hasumikin/mrubyc-utils/master/templates', template[:from])
        puts "INFO - downloading a template from #{url}"
        request = http.get(url, {})
        if request.code != 200
          puts "\e[31;1mFATAL - template file '#{url}' was not found\e[0m"
          raise RuntimeError
        end
        File.open(template[:to], 'w') do |f|
          f.puts erb_result(request.body, config)
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

  end
end
