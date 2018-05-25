module MrubycUtils
  class << self
    def classes
      config = load_config
      return 1 unless config
      klasses = Array.new
      Dir.foreach("#{config['mrubyc_src_dir']}/") do |filename|
        next if File.extname(filename) != '.c'
        File.foreach("#{config['mrubyc_src_dir']}/#{filename}") do |line|
          match = line.match(/mrbc_define_class\([^,]+,\s*"([^"]+)"/)
          klasses << match[1] if match
        end
      end
      klasses.uniq.sort.each do |klass|
        puts "- #{klass.sub(/Class$/, '')}"
      end
    end
  end
end

