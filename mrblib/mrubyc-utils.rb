def __main__(argv)
  opts = Getopts.getopts('vhc', 'version', 'help', 'class:')

  # バージョンを表示
  if opts['v'] || opts['version']
    puts "mrubyc-utils #{MrubycUtils::VERSION}"
    return
  end

  # 使い方を表示
  if opts['h'] || opts['help']
    MrubycUtils.usage
    return
  end

  # 引数を処理
  case argv[1]
  when 'install'
    return MrubycUtils.install
  when 'update'
    return MrubycUtils.update
  when 'classes'
    return MrubycUtils.classes
  when 'methods'
    klass = opts['c'] || opts['class']
    return MrubycUtils.methods(klass)
  when 'compile'
    return MrubycUtils.compile(false)
  end

  MrubycUtils.usage
end
