module MrubycUtils
  class << self

    def tag
      config = load_config
      command = "cd #{config['mrubyc_repo_dir']} && git tag"
      puts `#{command}`
      `cd -`
    end

  end
end


