module MrubycUtils
  class << self

    def checkout(tag)
      config = load_config
      command = "cd #{config['mrubyc_repo_dir']} && git checkout #{tag}; cd -"
      puts command
      `#{command}`
      copy_mrubyc_to_src(config)
    end

  end
end


