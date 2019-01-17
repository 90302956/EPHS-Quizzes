//
//  MainViewController.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import AVFoundation
import UIKit

class MainViewController: UIViewController {
	
	@IBOutlet weak var startButton: UIButton!
	@IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var gameButton: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
	@IBOutlet weak var backgroundImageView: UIImageView!
	
	static var backgroundView: UIView?

	@IBOutlet weak var mainMenuStack: UIStackView!
	
	override func viewDidLoad() {
		
		super.viewDidLoad()
		
		MainViewController.backgroundView = backgroundImageView

		self.initializeSounds()
		self.initializeLables()
		
		NotificationCenter.default.addObserver(self, selector: #selector(loadTheme), name: UIApplication.didBecomeActiveNotification, object: nil)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		
		let answersScore = UserDefaultsManager.score
        scoreLabel.text = "Score: \(answersScore)pts"
		
		if answersScore == 0 {
			scoreLabel.textColor = .white
		} else if answersScore < 0 {
            scoreLabel.textColor = .darkRed
		} else {
			scoreLabel.textColor = .darkGreen
		}
		loadTheme()
	}
	
	override func viewWillLayoutSubviews() {
		super.viewWillLayoutSubviews()
		[self.startButton, self.settingsButton, self.gameButton].forEach { $0?.setNeedsDisplay() }
	}

	@IBAction func unwindToMainMenu(_ unwindSegue: UIStoryboardSegue) {
		AudioSounds.bgMusic?.setVolumeLevel(to: AudioSounds.bgMusicVolume)
	}
	
	@IBAction func loadAppTopics(_ sender: UIButton) {
		SetOfTopics.shared.current = .app
	}

	@IBAction func loadCommunityTopics(_ sender: UIButton) {
		
		SetOfTopics.shared.current = .community
		
		if CommunityTopics.shared == nil {
			DispatchQueue.global().async {
				SetOfTopics.shared.loadCommunityTopics()
			}
		}
	}
	
	private func initializeSounds() {
		
		AudioSounds.bgMusic = AVAudioPlayer(file: "kahootmusic", type: .mp3, volume: AudioSounds.bgMusicVolume)
		AudioSounds.correct = AVAudioPlayer(file: "correct", type: .mp3, volume: 0.10)
		AudioSounds.incorrect = AVAudioPlayer(file: "incorrect", type: .wav, volume: 0.25)
		
		if UserDefaultsManager.backgroundMusicSwitchIsOn {
			AudioSounds.bgMusic?.play()
		}
		
		AudioSounds.bgMusic?.numberOfLoops = -1
	}
	
	private func initializeLables() {
		self.startButton.setTitle(Localized.MainMenu_Entries_Topics, for: .normal)
		self.settingsButton.setTitle(Localized.MainMenu_Entries_Settings, for: .normal)
	}
	
	@IBAction func loadTheme() {
		self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .red, light: .defaultTintColor)
		self.backgroundImageView.dontInvertColors()
		self.startButton.dontInvertColors()
		self.settingsButton.dontInvertColors()
		self.scoreLabel.dontInvertColors()
	}
}
