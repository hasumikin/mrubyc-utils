module MrubycUtils
  class << self
    TARGETS = ['psoc5lp', 'esp32', 'posix']
    CONFIGURATIONS = {
      'mrubyc_repo_dir' => {
        'question' => 'dir name of mruby/c repository',
        'psoc5lp' => '.mrubyc',
        'esp32' => '.mrubyc',
        'posix' => '.mrubyc'
      },
      'mrubyc_src_dir' => {
        'question' => 'dir name where mruby/c\'s sources are located (main.c will include them)',
        'esp32' => 'components/mrubyc/mrubyc_src',
        'default' => 'mrubyc_src'
      },
      'mruby_lib_dir' => {
        'question' => 'dir name where your mruby code are lacated',
        'default' => 'mrblib'
      },
      'c_lib_dir' => {
        'question' => 'dir name where your compiled mruby byte codes are located',
        'esp32' => '_skip_',
        'default' => 'src'
      },
      'prefix' => {
        'question' => 'prefix of your mruby source file name',
        'default' => 'job'
      }
    }
    NO_OVERWRITES = ['vm_config.h']

    def install
      config = {}
      while true
        print "target microcontroller [#{TARGETS.join('/')}]"
        config['target'] = gets.chomp
        break if TARGETS.include?(config['target'])
      end
      CONFIGURATIONS.each do |key, value|
        default = value[config['target']] || value['default']
        next if default == '_skip_'
        print "#{value['question']} [#{default}]: "
        config[key] = gets.chomp
        config[key] = default if config[key].empty?
      end
      return false unless confirm(config)
      save_config(config)
      return false unless git_clone_mrubyc(config)
      create_main_dir if config['target'] == 'esp32'
      create_mrubyc_src_dir(config)
      copy_mrubyc_to_src(config)
      create_mruby_lib_dir(config)
      download_templates(config)
      create_c_lib_dir(config)
      add_gitignore(config)
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
      return false if NO.include?(answer)
    end

    def git_clone_mrubyc(config)
      if Dir.exist?(config['mrubyc_repo_dir'])
        puts "FATAL - #{config['mrubyc_repo_dir']} already exists!"
        return false
      end
      `git clone https://github.com/mrubyc/mrubyc.git #{config['mrubyc_repo_dir']}`
      return true
    end

    def create_main_dir
      mkdir_p('main')
    end

    def create_mrubyc_src_dir(config)
      mkdir_p(config['mrubyc_src_dir'])
    end

    def create_c_lib_dir(config)
      mkdir_p(config['c_lib_dir'])
    end

    def create_mruby_lib_dir(config)
      mkdir_p(config['mruby_lib_dir'])
    end

    def download_templates(config)
      mruby_lib_dir = config['mruby_lib_dir']
      prefix = config['prefix']
      http = HttpRequest.new()
      tasks = if config['target'] == 'esp32'
        [ { from: "targets/esp32/Makefile.erb", to: 'Makefile' },
          { from: "targets/esp32/components/mrubyc/component.mk.erb", to: 'components/mrubyc/component.mk' },
          { from: "targets/esp32/main/main.c.erb", to: 'main/main.c' },
          { from: "targets/esp32/main/component.mk.erb" , to: 'main/component.mk' } ]
      else
        [ { from: "targets/#{config['target']}/main.c.erb", to: 'main.c' } ]
      end
      (tasks + [
        { from: "targets/#{config['target']}/gitignore.erb", to: '.gitignore' },
        { from: 'mrblib/prefix_main_loop.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_main_loop.rb" },
        { from: 'mrblib/prefix_sub_loop.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_sub_loop.rb" },
        { from: 'mrblib/prefix_operations.rb.erb', to: "#{mruby_lib_dir}/#{prefix}_operations.rb" }
      ]).each do |template|
        url = sprintf("https://%s/%s/%s", 'raw.githubusercontent.com', 'hasumikin/mrubyc-utils/master/templates', template[:from])
        puts "INFO - download #{url}"
        request = http.get(url, {})
        if request.code != 200
          puts "FATAL - template file '#{url}' was not found"
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

    def add_gitignore(config)
      File.open('.gitignore', 'a') do |f|
        ['# added by mrubyc-utils', "#{config['mrubyc_repo_dir']}/"].each do |line|
          f.puts line
          puts "INFO - \"#{line}\" was added to .gitignore"
        end
      end
    end

  end
end
