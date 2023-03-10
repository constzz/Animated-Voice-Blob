# Animated-Voice-Blob
Animated Voice Blob made like in Telegram mobile app.

# Sample View controller
The main and the only app's screen ```ViewController``` has sample usage of Telegram-like voice blobs in different styles and with a color picker. It creates Animated Blobs of different styles, simulates voice level changes, and has the color selection and starts/stop animation possibilities.

<div align = "center">
<img src="Assets/gifs/sample-controller.gif" width="350" />
</div>

# BlobNode class
BlobNode is a building block of VoiceBlobView. It can be made of different sizes and have different opacities of the primary color.
<div align = "center">
<img src="Assets/gifs/small-blob.gif" width="250" />
<img src="Assets/gifs/medium-blob.gif" width="250" />
<img src="Assets/gifs/big-blob.gif" width="250" />
</div>

Each BlobNode will have the following fields to be initialized with:

```swift
class BlobNode: UIView {  
	init(  
		pointsCount: Int,  
		minRandomness: CGFloat,  
		maxRandomness: CGFloat,  
		minSpeed: CGFloat,  
		maxSpeed: CGFloat,  
		minScale: CGFloat,  
		maxScale: CGFloat,  
		scaleSpeed: CGFloat,  
		isCircle: Bool  
	) ...  
}
``` 
    
It has some fields that could be changed dynamically via parameters and methods:
```swift
/// Makes more detailed view corners  
var pointsCount: Int  
var isCircle: Bool  
/// Controls the blob's size 
var level: CGFloat  
  
func setColor()  
func updateSpeedLevel(to newSpeedLevel: CGFloat)  
func startAnimating()  
func stopAnimating()
```

# VoiceBlobView class
VoiceBlobView controls how the blobs will look together.  
This class also has some place for configurations via init:
```swift
class VoiceBlobView: UIView {  
  // ...  
  typealias BlobRange = (min: CGFloat, max: CGFloat)  
  // ...
  init(  
    frame: CGRect,  
    maxLevel: CGFloat,  
    smallBlobRange: BlobRange,  
    mediumBlobRange: BlobRange,  
    bigBlobRange: BlobRange  
  ) 
}
```

After init, it is already configured and has added child blobs. 
Also, it sets up the animation loop, to keep the blobs animating:

```swift
// Init scope ...
displayLinkAnimator = ConstantDisplayLinkAnimator() { [weak self] in  
	guard let self = self else { return }  

	self.presentationAudioLevel = self.presentationAudioLevel * 0.9 + self.audioLevel * 0.1  

	self.smallBlob.level = self.presentationAudioLevel  
	self.mediumBlob.level = self.presentationAudioLevel  
	self.bigBlob.level = self.presentationAudioLevel  
}
// Init scope ...
```

# Adding views in ViewController
The default VoiceBlobView configuration, used in the project is the following:

```swift
VoiceBlobView(  
	frame: .zero,  
	maxLevel: 50,  
	smallBlobRange: (0.40, 0.54),  
	mediumBlobRange: (0.52, 0.87),  
	bigBlobRange: (0.55, 1.00))
```

By changing `pointsCount` and `isCircle` property of child blobs we have the following results:
<div align = "center">
<img src="Assets/gifs/circle-only-blob.gif" width="350" />
<img src="Assets/gifs/detailed-corners-blob.gif" width="350" />
</div>

We can also create the recursive `animate` method to test what updateLevel changes for the blob. And call `animate()` method  it in viewDidLoad:

```swift
override func viewDidLoad {
	super.viewDidLoad
	// ...
	animate()
}

private func animate() {  
	DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .milliseconds(500))) { [weak self] in  
		let randomValue = CGFloat.random(in: 10...50)  
		self?.voiceBlob1.updateLevel(randomValue)  
		self?.voiceBlob2.updateLevel(randomValue)  
		self?.voiceBlob3.updateLevel(randomValue)  
		self?.animate()  
	}
}
```

Instead of random values and time, this can be synced with the audio level.
For example, for the user???s audio messages (like Telegram did) or playing video/audio content. 

# Color picker 
The project also has a custom color picker, which changes the color of our blobs and the tint of the screen elements.

<div align = "center">
<img src="Assets/gifs/color-picker.gif" width="350" />
</div>

