# Tutorial

Episode 2 - Run on POSIX

## Environment and dependencies
- We don't need PSoC Creator this time!

## Target device
- POSIX compatible computer like Linux or macOS!
  - Windows should work, too. I did not confirm though

## Install mruby/c and templates with mrubyc-utils on Linux/macOS
super easy:
```
$ mkdir mrubyc_posix
$ cd mrubyc_posix
```

Type **posix** at the first question of `mrubyc-utils install`
```
$ mrubyc-utils install

target microcontroller [psoc5lp]: posix # <-here
```
you can hit enter with blank for rest questions. type `yes` at the last confirmation then you get mrubyc and templates.

## Compile `job_xxx.rb` into `job_xxx.c`
```
$ make
```
all the `mrblib/job_xxx.rb` will be compiled into `src/job_xxx.c`
and executable `main` will be created.

before this, you may have to specify mrbc version in case of using rbenv like:
```
$ echo 'mruby-1.4.1' > .ruby-version
```

## Run!
```
$ ./main
```

Then you will get debug print that is equivalent to the tutorial of PSoC5LP (see TUTORIAL_1.md)
