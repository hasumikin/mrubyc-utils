def __main__(argv)
  opts = case argv[1]
  when 'install'
    !argv[2]
  when 'update'
    !argv[2]
  when 'classes'
    !argv[2]
  when 'methods'
    Getopts.getopts('c', 'class:')
  when 'compile'
    Getopts.getopts('w', 'watch')
  when '-v', '--version'
    puts "mrubyc-utils #{MrubycUtils::VERSION}"
    return
  when '-h', '--help'
    MrubycUtils.usage
    return
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
  when 'classes'
    MrubycUtils.classes
  when 'methods'
    klass = opts['c'] || opts['class']
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

