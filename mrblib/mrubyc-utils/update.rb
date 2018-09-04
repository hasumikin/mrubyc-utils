module MrubycUtils
  class << self

    def update
      config = load_config
      while true
        print "update command will overwrite *.rb files in #{config['mrubyc_mrblib_dir']}. Are you OK? [Y/n]: "
        answer = gets.chomp
        if ['n', 'no'].include?(answer.downcase)
          puts "\e[31mabort\e[0m"
          return nil
        end
        break if ['y', 'yes'].include?(answer.downcase)
      end
      command = "cd #{config['mrubyc_repo_dir']} && git pull; cd -"
      puts command
      `#{command}`
      copy_mrubyc_to_src(config)
    end

  end
end

