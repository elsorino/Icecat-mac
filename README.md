# Icecat-mac

Scripts to compile IceCat for macOS

Should work on macOS 10.11+ but only verified working on macOS 



## Installation

### Using brew(recommended)

It is recommended to use brew for installation so you have automatic updates. To install IceCat using brew insert the following into a terminal:

`brew cask install elsorino/homebrew-elso/icecat`

This will also add my cask repo to your tap, allowing you to update IceCat with `brew cask upgrade`

### .dmg Files

.dmg files are available under releases

### Compilation

#### Dependencies

Xcode & command line tools are required

`brew install yasm mercurial gawk ccache python autoconf@2.13` will install remaining dependencies

Compiling firefox currently requires a macOS SDK below 14, it is recommended to get an SDK from https://github.com/phracker/MacOSX-SDKs and moving it to /Applications/Xcode.app/Contents/Developer/Platforms/MacOSX.platform/Developer/SDKs/



After the dependencies are installed run `cd build` & `./icebuild` to automatically compile IceCat 



## Credit & Licensing

Essentially a combination of the scripts at https://notabug.org/h3nn3s/icecat-mac  but with Fedora's more updated IceCat at https://gitlab.com/anto.trande/icecat though currently using source tarballs at https://sagitter.fedorapeople.org/icecat/ 



IceCat itself is licensed under MPL 2.0 and GPLv3. The remaining code in this repository is subject to GPLv3.