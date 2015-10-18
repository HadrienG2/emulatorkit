# EmulatorKit

This project provides a set of Ada 2012 components out of which one can build an x86_64 emulator that runs on x86_64 hosts. The README file you are currently reading summarizes what we believe is most important for project newcomers, and you can learn more about the project in [its Wiki](https://github.com/Neolander/emulatorkit/wiki).

## Release model redux

At the moment, this project is at a too early development stage to devise a complete release model. Ultimately, it should use a rolling release model.

## Compiler configuration and portability

The main.adb source file gives an example of how to use the library. To build this code, you will need a recent release of GNAT, which is distributed either as part of GCC or directly from Adacore at <http://libre.adacore.com>.

Portability to other Ada compilers is not currently envisioned, as we make use of GNAT-specific features such as inline assembly. We will nonetheless try to stick with standard Ada whenever it does what we want without too much hassle.

We also provide [a gprbuild-compatible project file](https://github.com/Neolander/emulatorkit/blob/unstable/emulatorkit.gpr), which features the recommended compiler switches to build the library.

## Licensing and reuse

This library is released under the GPLv3 license. Please feel free to study its code and make use of it for your own GPL-licensed projects !

## Acknowledgements

This project was started in 2015 and is currently being maintained by Hadrien G. Want to see your name here? Please do not hesitate to submit your own contribution!
