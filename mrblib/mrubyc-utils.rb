def __main__(argv)
  config = MrubycUtils.load_config(true)
  proprietary_commands = ['test', 'debugger'] # gem `mrubyc-test` `mrubyc-debugger`
  opts = case argv[1]
  when '', nil
    puts 'Invalid argument. see --help'
    puts opts
    return 1
  when 'install'
    !argv[2]
  when 'update'
    !argv[2]
  when 'checkout'
    Getopts.getopts('t:', 'tag:')
  when 'tag'
    !argv[2]
  when 'classes'
    !argv[2]
  when 'methods'
    Getopts.getopts('c:', 'class:')
  when 'compile'
    Getopts.getopts('w', 'watch')
  when '-v', '--version', 'version'
    puts "mrubyc-utils #{MrubycUtils::VERSION}"
    return
  when '-h', '--help', 'help'
    MrubycUtils.usage
    return
  else
    command_entity = proprietary_commands.include?(argv[1]) ? "mrubyc-#{argv[1]}" : argv[1]
    envs = ["RBENV_VERSION=#{config['cruby_version']}"]
    ENV.keys.each { |key| envs << "#{key}='#{ENV[key]}'" }
    cmd = "#{envs.join(' ')} #{command_entity} #{argv.last(argv.size - 2).join(' ')}"
    exit_code = system cmd
    exit (exit_code ? 0 : 1)
  end

  if (opts.is_a?(Hash) && opts.has_key?('?')) || opts == false
    puts 'Invalid argument. see --help'
    return 1
  end

  # 引数を処理
  return case argv[1]
  when 'install'
    MrubycUtils.install
  when 'update'
    MrubycUtils.update
  when 'checkout'
    tag = opts['t'] || opts['tag']
    if tag.empty?
      puts 'option --tag is required. see --help'
      return 1
    end
    MrubycUtils.checkout(tag)
  when 'tag'
    MrubycUtils.tag
  when 'classes'
    MrubycUtils.classes
  when 'methods'
    klass = opts['c'] || opts['class']
    if klass.empty?
      puts 'option --class is required. see --help'
      return 1
    end
    MrubycUtils.methods(klass)
  when 'compile'
    mode = if opts['w'] || opts['watch']
      'watch'
    else
      'once'
    end
    MrubycUtils.compile(mode)
  else
    puts 'ERROR - unknown error'
    puts opts
    false
  end

end

