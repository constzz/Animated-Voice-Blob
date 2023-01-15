# Animated-Voice-Blob
Animated Voice Blob made like in Telegram mobile app.

# About this project
The project has folders for each of the custom components used:
- Voice Blob
- Color Picker
- Gradient Slider

Common utilities are placed in:
- Utility
 
And the main and the only app's screen ```ViewController``` has sample usage of Telegram-like voice blobs in different styles and with a color picker.

### BlobNode class
BlobNode is a building block of VoiceBlobView. It can be of different sizes and have different opacities of the primary color.

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

### BlobNode class
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

After init, it already has configured and placed child blobs. Also, it set ups the animation loop, to keep the blobs animating.

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

## Adding views in ViewController
The default VoiceBlobView configuration, used in the project is the following:

```swift
VoiceBlobView(  
	frame: .zero,  
	maxLevel: 50,  
	smallBlobRange: (0.40, 0.54),  
	mediumBlobRange: (0.52, 0.87),  
	bigBlobRange: (0.55, 1.00))
```

By changing `pointsCount` and `isCircle` property of child blobs we may have the following results:
// TODO: add gifs
We can also add the recursive animate method to test what updateLevel changes for the blob. Create and call `animate()` method  it in viewDidLoad:

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

Instead of random values and time, this can be synced with the audio level. For example, for the user’s audio messages (like Telegram did) or playing video/audio content. 

# Color picker 
The project also has a custom color picker, which changes the color of our blobs and the tint of the screen elements.

![](https://cdn-images-1.medium.com/max/1200/1*8y3G5MS9VKEH_DoptO0vsA.png)
## Sample View controller
The main sample class in the project is `ViewController`. It creates Animated Blobs of different styles, simulates voice level changes, and has the color selection and starts/stop animation possibilities.

