module MrubycUtils
  class << self

    def update
      config = load_config
      command = "cd #{config['mrubyc_repo_dir']} && git pull; cd -"
      puts command
      `#{command}`
      copy_mrubyc_to_src(config)
    end

  end
end

