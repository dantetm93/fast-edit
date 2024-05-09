# fast-edit
This project is a simple Image Editor iOS app.

It is created with UIKit, CoreImage, SnapKit, CoreGraphic,...

Thank TimOliver and all contributors for making a great [TOCropViewController](https://github.com/TimOliver/TOCropViewController)

Fast Edit requires iOS 13.0 or later. 

## Table of contents
* [General info](#general-info)
* [Technologies](#technologies)
* [How to run](#how-to-run)
* [Contribution](#contribution)

## General info
This project is a simple Image Editor iOS app. You can crop, rotate, or change the brightness, contrast, saturation,...
	
## Technologies
This project is created following the Presentation-Domain-Transfer structure and the MVVM pattern.
And these below iOS library:
  - SnapKit (5.7.1)
  - R.swift (7.3.2)
  - TOCropViewController (2.73)
	
## How to run
It requires `XCode 12.0 or later` to run directly from the source code. XCode 12 requires `MacOS 10.15.4+`.
This project was made using `XCode 15.2`.
You also need to install `cocoapod` to install the library for this project. More detailed information about `cocoapods` is here: https://cocoapods.org/

Steps:
  - Open `Terminal` on your MacOS machine, to use below these commands:
```
$ cd [path of the directory that contains FastEdit.xcodeproj and podfile]
$ pod install (wait a bit to let cocoapods download/install library and generate pod project for FastEdit)
```
  - Open `FastEdit.xcworkspace` by XCode, and click Run/CMD+R to build and run this project by XCode.
  - You can run directly on the iOS Simulator or your iPhone.
  
## Contribution
If you have anything to upgrade this project, feel free to contact me via email: `quytm.work.93@gmail.com` or skype: `tranquy239`.

Thank you!
