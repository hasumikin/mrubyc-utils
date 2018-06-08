# Tutorial

Episode 1 - Run the template

## Environment and dependencies
- see README.md

## Target microcontroller
- PSoC5LP
- (PSoC6 may work. Please report if you try)

## PSoC project on Windows
### Create new project
- [File > New > Project] then Create Project dialog will open
- choose `PSoC 5LP` as Target device
  - select `Launch Device Selector...` , find `CY8C5888LTI-LP097` and choose it
  - click [Next]
![](/images/tutorials/1/ide_1.png)

![](/images/tutorials/1/ide_2.png)

- select `Empty schematic` and click [Next]
- change Workspace name, Location and Project name as you like
  - note that Location should be a shared directory with Linux/macOS
![](/images/tutorials/1/ide_3.png)


### Build setting
- [Projct > Build Settings...] then dialog will open
- add `m` to Additional Libraries as image below
![](/images/tutorials/1/ide_4.png)

- add `MRBC_DEBUG` to Preprocessor Definitions as image below
![](/images/tutorials/1/ide_5.png)

### Arrange peripherals
- drug and drop [Communications > UART] into TopDesign.cysch pane
  - this UART will work as debug console
![](/images/tutorials/1/uart.png)

- drug and drop [System > Interrupt] and [System > Clock] as well
- connect `isr_1` and `Clock_1`
![](/images/tutorials/1/isr_clock.png)

- double click `Clock_1` to open configure dialog and set Frequency 1 kHz
  - interrupt and clock will work as hardware timer so that `#sleep` method works properly

### Assign pins
- double click [Pins] in Workspace Explorer on the left side of window
- assign `Rx_1` to `P12[6]` and `Tx_1` to `P12[7]`
  - you cannot change this assignment as long as you use PSoC5LP Prototyping Kit because P12[6] and P12[7] are connected to USB terminal internally
  - you can ignore this restriction if you do some electric work. this tutorial will not cover it though
![](/images/tutorials/1/pin_assignment.png)

## Install mruby/c and templates with mrubyc-utils on Linux/macOS
quite easy:
```
$ cd path/to/mrubyc_tutorial.cydsn
```

```
$ mrubyc-utils install
```
you will be asked some questions. hit enter with blank for now. and type `yes` at the last confirmation then you get mrubyc and templates.

mrubyc-utils clones the newest master branch of mrubyc. to make things solid, I recommend you to checkout specified commit below
```
$ mrubyc-utils checkout -t b96c534
```

## add mruby/c sources to your project on Windows
- right click on [Source Files] in Workspace Explorer and select [Add > Existing Item...]
- select all the .c files in `mrubyc_tutorial.cydwr/mrubyc_src` and click open
![](/images/tutorials/1/add_mrubyc.png)

## Compile `job_xxx.rb` into `job_xxx.c` on Linux/macOS
```
$ mrubyc-utils compile
```
all the `mrblib/job_xxx.rb` will be compiled into `src/job_xxx.c`

before this, you may have to specify mrbc version in case of using rbenv like:
```
$ echo 'mruby-1.3.0' > .ruby-version
```

## Build and Run!
- make sure microcontroller connects to USB port of Windows
- [Debug > Program] will build project and install the firmware into your microcontroller. then it runs automatically

## See debug console
- use PuTTY or TeraTerm or other terminal that can be valid as a serial com console
- open connection through proper com port with configures below
  - baudrate: 57600bps
  - parity check: none
  - data bits: 8bit
  - stop bits: 1bit
- it works perfectly if you get outtput like this image
![](/images/tutorials/1/teraterm.png)

- you can easily understand what happens by seeing `job_xxx.rb` files if you are Rubyist :)
