module MrubycUtils
  class << self
    def usage
      msg =<<EOS
Usage: mrubyc-utils COMMAND [ARGS]

 install        Install mruby/c and setup some templates.
                Please run this command at the top directory
                of your project (it shoud have 'main.c').
 update         Update mruby/c to the newest master branch.
 classes        Show all the classes that are defined in
                mruby/c's virtual machine.
 methods        Show all the methods that are available
                in each classes of mruby/c.
  -c | --class    [optional] You can specify class name
 compile        Compile your mruby source into C byte code.
  -w | --watch    [optional] Monitoring loop runs and it will
                  compile mruby source every time you save.

-v | --version  Show version.
-h | --help     Show usage. (this message)

Dependency:
 git
 mrbc (mruby compiler)
EOS
      print msg
    end
  end
end
