module MrubycUtils
  class << self
    def usage
      msg =<<EOS
Usage: mrubyc-utils COMMAND [ARGS]

 install        Install mruby/c repo into your local and setup templates.
                Please run this command at the top directory
                of your firmware project.
 update         Update mruby/c repo to the newest master branch.
 checkout       Checkout specified tag or commit of mruby/c repo.
  -t | --tag      [required] You can specify anything that
                  `git checkout` will accept.
 tag            Show all tags of mruby/c repogitory that you installed.
 classes        Show all the classes that are defined in
                mruby/c's virtual machine.
 methods        Show all the methods that are available
                in a class of mruby/c.
  -c | --class    [required] You have to specify class name
 compile        Compile your mruby source into C byte code.
                This command is for PSoC Creator project. Use make command instead
                if your project is dedicated to ESP32 or POSIX
  -w | --watch    [optional] Monitoring loop runs and will
                  compile mruby source every time you touched it.

-v | --version  Show version.
-h | --help     Show usage. (this message)

Dependencies:
 git
 mrbc (mruby compiler)
EOS
      print msg
    end
  end
end
