## Issues loading videos from PHPickerViewController

This is a sample app to reproduce and debug issues loading videos using `PHPickerViewController`. We are seeing a number of errors when users attempt to upload media from their iOS devices. 

One of the errors we are investigating is

> ``` Error Domain=NSItemProviderErrorDomain Code=-1000 "Cannot load representation of type com.apple.quicktime-movie" UserInfo={NSLocalizedDescription=Cannot load representation of type com.apple.quicktime-movie, NSUnderlyingError=0x2810d1b60 {Error Domain=NSCocoaErrorDomain Code=4097 "Couldn’t communicate with a helper application." UserInfo={NSUnderlyingError=0x2810d6d60 {Error Domain=NSCocoaErrorDomain Code=4097 "connection from pid 3677 on anonymousListener or serviceListener" UserInfo={NSDebugDescription=connection from pid 3677 on anonymousListener or serviceListener}}}}} ```

<img src=/screenshots/preview.png width=320 />

### Test Environment
Xcode 14.2 (14C18) \
macOS Ventura 13.2.1 (22D68) \
iPhone SE 1st Gen, iOS 14.8.1 \
iPhone 12 mini, iOS 16.4.1

### Steps to reproduce:
1. Download [dji_example_video.mov](https://github.com/opfeffer/photo-picker-sandbox/releases/download/v0.1/dji_example_video.mov) from Releases page.
1. Airdrop `dji_example_video.mov` to your test device a couple of times, adding multiple selectable videos to your iOS Photos app. 
1. Run `PhotoPicker` on the test device you just added the video to.
1. Hit the + icon in the nav bar, select the video you added, and select "Add" to dismiss the media picker.
1. Observe Xcode debug console output and see result of `loadFileRepresentation(forTypeIdentifier:completionHandler:)`. Depending on your device it may succeed with just a single asset selected, in the event it succeeds, start adding multiple assets until you start seeing errors.

### Observations
1. This error is more easily reproduced on device than the simulator. It is seemingly related to available device resources since it fails with a single picker item on an iPhone SE 1st gen, whereas it requires two items on an iPhone 12 mini.
1. It seems to happen more frequently with 60 fps videos captured by action cameras such as DJI Action cams.
1. The issue seems to be worse when calling `NSItemProvider`'s `loadFileRepresentation(forTypeIdentifier:completionHandler:)` in parallel. Nowhere in the documentation could I find any references that this is not recommended/to be avoided.'
1. Apple Developer Forums are full with similar reports without much resolution (eg https://developer.apple.com/forums/thread/672379)
1. I saw some comments indicating that this could be related to videos being stored in iCloud and failing to download in time due to network conditions however in my testing I specifically disabled iCloud photo gallery download.
