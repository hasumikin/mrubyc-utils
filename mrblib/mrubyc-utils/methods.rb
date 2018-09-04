module MrubycUtils
  class << self
    def methods(klass)
      config = load_config
      return 1 unless config
      klass.downcase!
      klass.sub!(/class$/, '')
      indent = ''
      while true
        puts klass.capitalize
        show_methods(config, klass, indent)
        klass = ancestor(config, klass)
        if klass
          indent << '  '
          print "#{indent}< "
        else
          break
        end
      end
    end

    def show_methods(config, klass, indent)
      methods = Array.new
      Dir.foreach("#{config['mrubyc_src_dir']}/") do |filename|
        next if File.extname(filename) != '.c'
        File.foreach("#{config['mrubyc_src_dir']}/#{filename}") do |line|
          match = line.match(/mrbc_define_method\([^,]+,\s*mrbc_class_#{klass},\s*"([^"]+)"/)
          methods << match[1] if match
          match = line.match(/mrbc_define_method\([^,]+,\s*c_#{klass},\s*"([^"]+)"/)
          methods << match[1] if match
        end
      end
      Dir.foreach("#{config['mrubyc_mrblib_dir']}/") do |filename|
        next if File.basename(filename) != "#{klass}.rb"
        File.foreach("#{config['mrubyc_mrblib_dir']}/#{filename}") do |line|
          match = line.match(/def\s+([^(]+)/)
          methods << match[1] if match
        end
      end
      methods.uniq.sort.each do |method|
        puts "#{indent}- #{method}"
      end
    end

    def ancestor(config, klass)
      Dir.foreach("#{config['mrubyc_src_dir']}/") do |filename|
        next if File.extname(filename) != '.c'
        File.foreach("#{config['mrubyc_src_dir']}/#{filename}") do |line|
          match = line.match(/mrbc_class_#{klass}\s*=\s*mrbc_define_class\([^,]+,\s*[^,]+,\s*mrbc_class_(\w+)/)
          return match[1] if match
        end
      end
      return nil
    end

  end
end

