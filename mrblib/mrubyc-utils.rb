def __main__(argv)
  opts = case argv[1]
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
  when 'test', 'debugger' #  for wrapping gems 'mrubyc-test' and 'mrubyc-debugger'
    config = MrubycUtils.load_config(true)
    cruby_version = config['cruby_version']
    command_entity = "mrubyc-#{argv[1]}"
    cmd = "PATH=#{ENV['PATH']} RBENV_VERSION=#{cruby_version} #{command_entity} #{argv[2]}"
    exit_code = system cmd
    exit (exit_code ? 0 : 1)
  else
    puts 'Invalid argument. see --help'
    puts opts
    return 1
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

