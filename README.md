# EmulatorKit

This project provides a set of Ada 2012 components out of which one can build an x86_64 emulator for the x86_64 architecture. The README file you are currently reading summarizes what we believe is most important for project newcomers, and you can learn more about the project in [its Wiki](https://github.com/Neolander/emulatorkit/wiki).

## Release model redux

The project uses a three stage rolling release model, inspired by that of Debian GNU/Linux.

* Code in the unstable branch is not feature-frozen and only partially tested. Functions are still likely to move around in the package hierarchy. Use at your own risk.
* Code in the testing branch is feature-frozen, but not yet fully tested. Feel free to experiment with it and tell us everything that's wrong !
* Code in the release branch is considered stable. We will do everything possible not to break compatibility with it, and if we end up having to do so, we will maintain the pre-breach code as a feature-frozen branch for one year to give you time to adjust.

## Compiler configuration and portability

The main.adb source file gives an example of how to instantiate and use the library. To build this code, you will need a recent release of GNAT, which is distributed either as part of GCC or directly from Adacore at <http://libre.adacore.com>.

Portability to other Ada compilers is not currently envisioned, as we make use of GNAT-specific features such as inline assembly, but we will nonetheless try to stick with standard Ada whenever it does what we want without too much hassle.

We also provide [a gprbuild-compatible project file](https://github.com/Neolander/emulatorkit/blob/unstable/emulatorkit.gpr), which features the recommended compiler switches to build the library.

## Licensing and reuse

This library is released under the GPLv3 license. Please feel free to study its code and make use of it for your own GPL-licensed projects !

## Acknowledgements

This project was started in 2015 and is currently being maintained by Hadrien G. Want to see your name here? Please do not hesitate to submit your own contribution!
