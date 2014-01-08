AOFrameworks
============

All of AppOrchard's reusable frameworks are in this repository. You should use CocoaPods to include the frameworks you want in your project. See below for information on how to contribute to AOFrameworks.

## Using frameworks in your project

You should already have [CocoaPods installed](https://github.com/apporchard/apporchard.github.com/wiki/Use-CocoaPods) and pointed at our internal podspec repository. 

    pod repo add apporchard git@github.com:apporchard/PodSpecs.git

In your Podfile, simply add the frameworks you want to use. Here's an example of a project using AFNetworking and our internal AOCoreData framework:
  
    platform :ios, 6.0
    xcodeproj "MyCrazyApp.xcodeproj"
    pod 'AFNetworking', '~> 1.3'
    pod 'AOFrameworks/AOCoreData', '~> 0.1'

That's it! For information about each framework navigate into the framework's root directory and see the readme file.

## Contributing to AOFrameworks

### Basics

* Fork this repository. You'll notice each framework has its own workspace. Open that, make your changes, commit and push to your fork, and submit a pull request. 

* Note that when you've opened a framework in its workspace, you can also edit any AOFrameworks it depends on from that workspace. The "Local Pods" group under the Pods project has a reference to the files in your local repo.

### Adding a new framework / changing dependencies

* Use Xcode to create a new framework at the root of the repository.

* Edit the AOFrameworks.podspec to add a new subspec for your framework. (Use existing subspecs as a guide.)

* Create a Podfile for your framework and add any dependencies you defined in the subspec. For local AOFramework dependencies, be sure to use the :path directive rather than pointing to a specific version. Use an eixsting Podfile from one of the other frameworks for reference. This podfile exists to set up a workspace for your framework that can be used for unit testing and modifying the framework in isolation -- without an app.

* Run `pod install`. 
    
* Note that your framework cannot depend on a different version of the same framework that another AOFramework depends on. If a different version of your dependency already exists in the Podspec we'll have to work out if the other frameworks that depend on that framework can use the version you need.

### Versioning

We're using semantic versioning: #.#.#  Generally, the first number is incremented for major new features or breaking API changes. The second number is incremented for new features and the third number is incremented for bug fixes.

To change the version, edit it in the AOFrameworks.podspec file. When your pull request is merged into master, master will be tagged with the new version number, and the podspec in our private podspec repository will also be updated.

