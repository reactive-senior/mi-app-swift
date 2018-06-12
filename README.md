This branch was to setup Firebase Crashlytics environment into an existing app.

Below the process and the changes I have made the project can be found. <br>

#Step by Step

##Set up Crashlytics in the [here](https://console.firebase.google.com/project/_/crashlytics)

While that you should download GoogleService-info.plist from the firebase console and copy it to the project main directory.


1. Open a new terminal window, and navigate to your Xcode project’s directory.

2. Open your Podfile, and add some lines below.

```
# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

target 'MyProject' do
# Comment the next line if you're not using Swift and don't want to use dynamic frameworks
use_frameworks!

# Pods for PodTest
pod 'Fabric', '~> 1.7.7'
pod 'Crashlytics', '~> 3.10.2'

end

```

3.If you get an error about CocoaPods being unable to find compatible versions, run
```
pod repo update

```
4.From your terminal, install the pod’s dependencies:
```
pod install

```

5.In the AppDelegate.swift file add following lines
```
import Fabric
import Crashlytics

public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
        
        FirebaseApp.configure()								//enable firebase app in the project
        Fabric.sharedSDK().debug = true						//enable debug mode so that the sdk send the report to the fabric dashboard and firebase console
        Fabric.with([STPAPIClient.self, Crashlytics.self])	//Fabric settings with Crashlytics


		…
```

6. Add lines that occur the crash manually

First of all you should import crashylitics library to the swift file
```
import Crashlytics
```

In the Controller_Main.swift after view loaded add following line
```
Crashlytics.sharedInstance().crash()
```

7. Change the build settings.
Navigate to the main project’s root. There you should change build settings so that the app make send report to firebase console and fabric also.

Build Settings/Debug Information Format/“DWARF” to “DWARF with dSYM FILE”

8. Connect your app with fabric to be monitored inside fabric dashboard.

You should create a new app with fabric and add Build Phases script.
Build Phases/New Run Script Phase/	Here add script to connect with fabric and rebuild the project.
e.g:
```
./Fabric.framework/run f4f44296c9d034405fee2211c4b308bbeb7511e9 6c2ceadaed70ca55e6ab023dd79a279696b5c9295d88195384da4713252472b2
```

9. Testing the app

Build the project and run inside the XCode.
Press stop button in the Xcode.
Then run the app through device or emulator.
It should crash and turn off.
Please rerun the app so that the app can send report to the firebase console and the fabric dashboard!

