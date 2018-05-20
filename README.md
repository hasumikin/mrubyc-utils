# mrubyc-utils
====

Utilities for developer who uses [mruby/c](https://github.com/mrubyc/mrubyc)

## Description
mrubyc-utils is built with [mruby-cli](https://github.com/hone/mruby-cli) and provides some usuful functions for your development with mruby/c.
Make your IoT development smooth and fun.

## Demo
[TBD]

## VS.
- N/A

## Requirement
mrubyc-utils assumes that you are using PSoC Creator to write firmware program and targetting PSoC5LP microcontrollers.

Though PSoC Creator works on only Windows platform, mrubyc-utils works on Linux and macOS. It is recommneded that you use Windows as a host machine to build firmware and Linux as a virtual client to write mruby code. Vice versa you can use Linux or macOS as a host to write mruby and Windows as a virtual client to build firmware with PSoC Creator.

### Linux and macOS
- git

### Windows(out of scope as of yet)
- git.exe[TBD]

## Usage
- hitting `mrubyc install` in your mruby/c project's directory will check out mruby/c repository from GitHub.com and create some files and directories. Note that this operation may overwrite main.c. See standard output to know more about its result
- `mrubyc update` pulls the newest master branch of mruby/c from GitHub.com. This operation will keep your modification of src/vm_config.h (so you can update mrubyc freely. I recommend you to use the newest mruby/c instead of release version)
- `mrubyc classes` shows list of class that you can use with mruby/c's VM
- `mrubyc methods --class=[Class Name]` shows list of methods that you can use with the class
- `mrubyc compile` compiles your mrblib/***xxx.rb into xxx.c
- see .mrubycconfig that `mrubyc install` created to know configurations you can modify
- `mrubyc --help` will show you more about usage

## Install
[TBD]

## Contribution
1. Fork this repository
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create new Pull Request

## Licence

MIT(see LICENSE)

## Author

[hasumon](https://github.com/hasumon)

