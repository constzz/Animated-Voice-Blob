//
//  ViewController.swift
//  AnimatedVoiceBlob
//
//  Created by Konstantin Bezzemelnyi on 15.01.2023.
//

import UIKit
import AnimatedBlob

final class ViewController: ViewControllerWithStackInScroll {
    private enum PrefferedValues {
        static let stackInset: CGFloat = 20
        static let bulbHeight: CGFloat = 200
        static let bulbWidth: CGFloat = 200
        
        static let blobMaxLevel = CGFloat(50)
        
        static let smallBlobPrefferedRange: VoiceBlobView.BlobRange = (0.40, 0.54)
        static let mediumBlobPrefferedRange: VoiceBlobView.BlobRange = (0.52, 0.87)
        static let bigBlobPrefferedRange: VoiceBlobView.BlobRange = (0.55, 1.00)
    }
    
    private var tintColor: UIColor {
        didSet { updateTintColor(tintColor) }
    }
    
    private lazy var colorPickerBlob: VoiceBlobView = makeDefaultVoiceBlob()
    
    private lazy var voiceBlobDefault: VoiceBlobView = makeDefaultVoiceBlob()
    
    private lazy var voiceBlobCircleOnly: VoiceBlobView = {
        let blob = makeDefaultVoiceBlob()
        blob.updateMediumBlob({ $0.isCircle = true })
        blob.updateBigBlob({ $0.isCircle = true })
        return blob
    }()
    
    private lazy var voiceBlobDetailedCorners: VoiceBlobView = {
        let blob = makeDefaultVoiceBlob()
        let pointsCount = 200
        blob.updateMediumBlob({ $0.pointsCount = pointsCount })
        blob.updateBigBlob({ $0.pointsCount = pointsCount })
        blob.updateSmallBlob({
            $0.pointsCount = pointsCount
            $0.isCircle = false
        })
        return blob
    }()
    
    private var voiceBlobs: [VoiceBlobView] {
        return [voiceBlobDefault, voiceBlobCircleOnly, voiceBlobDetailedCorners]
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    private lazy var startStopControl: UISegmentedControl = makeStartStopControl()
    
    private lazy var colorPickButton: UIButton = makeColorPickButton()
    
    init(tintColor: UIColor = .white) {
        self.tintColor = tintColor
        super.init()
    }
    
    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        addBlobsSetupControls()
        addVoiceBlob()
        animate()
        updateTintColor(tintColor)
    }
    
    private func updateTintColor(_ color: UIColor) {
        voiceBlobs.forEach { voiceBlob in
            voiceBlob.setColor(color, animated: true)
        }
        colorPickButton.tintColor = color.withAlphaComponent(0.8)
        startStopControl.selectedSegmentTintColor = color.withAlphaComponent(0.4)
    }
}

// MARK: - Animations

private extension ViewController {
    private func animate() {
        DispatchQueue.main.asyncAfter(deadline: .now().advanced(by: .seconds(1))) { [weak self] in
            let randomValue = CGFloat.random(in: 1 ... 50)
            self?.voiceBlobDefault.updateLevel(randomValue)
            self?.voiceBlobCircleOnly.updateLevel(randomValue)
            self?.voiceBlobDetailedCorners.updateLevel(randomValue)
            self?.animate()
        }
    }
    
    private func startBlobsAnimations() {
        voiceBlobDefault.startAnimating()
        voiceBlobCircleOnly.startAnimating()
        voiceBlobDetailedCorners.startAnimating()
    }
    
    private func stopBlobsAnimations(duration: CGFloat = 1.0) {
        voiceBlobDefault.stopAnimating(duration: duration)
        voiceBlobCircleOnly.stopAnimating(duration: duration)
        voiceBlobDetailedCorners.stopAnimating(duration: duration)
    }
}

// MARK: - Layouting subviews

private extension ViewController {
    func addVoiceBlob() {
        view.addSubview(voiceBlobDefault)
        voiceBlobDefault.prepareForAutoLayout()
        NSLayoutConstraint.activate([
            voiceBlobDefault.heightAnchor.constraint(equalToConstant: PrefferedValues.bulbHeight),
            voiceBlobDefault.widthAnchor.constraint(equalToConstant: PrefferedValues.bulbWidth),
            voiceBlobDefault.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            voiceBlobDefault.leadingAnchor.constraint(equalTo: view.leadingAnchor)
        ])
        
        view.addSubview(voiceBlobCircleOnly)
        voiceBlobCircleOnly.prepareForAutoLayout()
        NSLayoutConstraint.activate([
            voiceBlobCircleOnly.heightAnchor.constraint(equalToConstant: PrefferedValues.bulbHeight),
            voiceBlobCircleOnly.widthAnchor.constraint(equalToConstant: PrefferedValues.bulbWidth),
            voiceBlobCircleOnly.topAnchor.constraint(equalTo: view.topAnchor, constant: 44),
            voiceBlobCircleOnly.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        view.addSubview(voiceBlobDetailedCorners)
        voiceBlobDetailedCorners.prepareForAutoLayout()
        NSLayoutConstraint.activate([
            voiceBlobDetailedCorners.heightAnchor.constraint(equalToConstant: PrefferedValues.bulbHeight),
            voiceBlobDetailedCorners.widthAnchor.constraint(equalToConstant: PrefferedValues.bulbWidth),
            voiceBlobDetailedCorners.topAnchor.constraint(equalTo: voiceBlobDefault.bottomAnchor, constant: 44),
            voiceBlobDetailedCorners.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    func addBlobsSetupControls() {
        stackView.addArrangedSubview(.init(frame: .zero),
                                     withSpacing: PrefferedValues.bulbHeight * 3)
        stackView.addArrangedSubview(startStopControl, withSpacing: 15)
        stackView.addArrangedSubview(colorPickButton)
        
        startStopControl.selectedSegmentIndex = 0
        startBlobsAnimations()
    }
}

// MARK: - Subviews factories

private extension ViewController {
    func makeDefaultVoiceBlob() -> VoiceBlobView {
        return VoiceBlobView(
            frame: .zero,
            maxLevel: PrefferedValues.blobMaxLevel,
            smallBlobRange: PrefferedValues.smallBlobPrefferedRange,
            mediumBlobRange: PrefferedValues.mediumBlobPrefferedRange,
            bigBlobRange: PrefferedValues.bigBlobPrefferedRange)
    }
    
    func makeStartStopControl() -> UISegmentedControl {
        let control = UISegmentedControl(items: ["", ""])
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        control.selectedSegmentTintColor = .darkGray
        control.setAction(.init(title: "Start", handler: { [weak self] _ in
            self?.startBlobsAnimations()
        }), forSegmentAt: 0)
        control.setAction(.init(title: "Pause", handler: { [weak self] _ in
            self?.stopBlobsAnimations()
        }), forSegmentAt: 1)
        return control
    }
    
    func makeColorPickButton() -> UIButton {
        var config = UIButton.Configuration.tinted()
        config.title = "Pick new color"
        let button = UIButton(configuration: config, primaryAction: .init(handler: { [weak self] _ in
            guard let self = self else { return }
            let alert = UIAlertController()
            
            alert.addColorPicker(
                currentColor: self.tintColor,
                selection: { color in self.tintColor = color },
                colorView: self.colorPickerBlob)
            
            alert.addAction(title: "Cancel", style: .cancel)
            
            self.present(alert, animated: true)
            self.colorPickerBlob.startAnimating()
        }))
        button.constraint(height: 44)
        return button
    }
}
