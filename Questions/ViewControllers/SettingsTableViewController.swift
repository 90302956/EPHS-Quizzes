//
//  SettingsTableViewController.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import UIKit

class SettingsTableViewController: UITableViewController {
	
	private class cellLabelsForSection0 {
		
		static let backgroundMusic = Localized.Settings_Options_Music
		static let darkTheme = "Light Theme"
		
		static let labels: [String] = [cellLabelsForSection0.backgroundMusic, cellLabelsForSection0.darkTheme]
		static let count = labels.count
	}
	
	let backgroundMusicSwitch = UISwitch()
	let darkThemeSwitch = UISwitch()
	
	var switches: [UISwitch] {
		return [backgroundMusicSwitch, darkThemeSwitch]
	}
	
	private class cellLabelsForSection1 {
		
		static let resetProgress = Localized.Settings_Options_ResetProgress
		static let resetCachedImages = Localized.Settings_Options_ClearCachedImages
		
		static let labels: [String] = [cellLabelsForSection1.resetProgress, cellLabelsForSection1.resetCachedImages]
		static let count = labels.count
	}

    override func viewDidLoad() {
        super.viewDidLoad()
		
		self.navigationItem.title = Localized.Settings_Title
		
		self.setUpSwitches()
		self.loadSwitchesStates()
		UserDefaultsManager.darkThemeSwitchIsOn = true
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.loadCurrentTheme(animated: false)
		}
		self.clearsSelectionOnViewWillAppear = true
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? cellLabelsForSection0.count : cellLabelsForSection1.count
    }
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 4:
				DispatchQueue.main.async {
					self.performSegue(withIdentifier: "segueToLicenses", sender: nil)
				}
			default: break
			}
		case 1:
			switch indexPath.row {
			case 0:
				self.resetProgressAlert(cellIndexpath: indexPath)
				self.viewWillAppear(false)
			default: break
			}
		default: break
		}
	}

	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		switch indexPath.section {
		case 0: cell.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		case 1: cell.textLabel?.textColor = UIColor.themeStyle(dark: .darkRed, light: .alternativeRed)
		default: break
		}
		cell.backgroundColor = .themeStyle(dark: .veryDarkGray, light: .white)
	}
	
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "myCell", for: indexPath)
		
		cell.textLabel?.font = .preferredFont(forTextStyle: .body)
		cell.accessoryView = nil

		switch indexPath.section {
		case 0:
			switch indexPath.row {
			case 0:
				cell.textLabel?.text = cellLabelsForSection0.backgroundMusic
				cell.accessoryView = self.backgroundMusicSwitch
			case 1:
				cell.textLabel?.text = cellLabelsForSection0.darkTheme
				cell.accessoryView = self.darkThemeSwitch
			default: break
			}
		case 1:
			switch indexPath.row {
			case 0: cell.textLabel?.text = cellLabelsForSection1.resetProgress
			case 1: cell.textLabel?.text = cellLabelsForSection1.resetCachedImages
			default: break
			}
		default: break
		}
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			let view = UIView()
			view.backgroundColor = UIColor.darkGray
			cell.selectedBackgroundView = view
		} else {
			cell.selectedBackgroundView = nil
		}
		
        return cell
    }
	
	override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
		
		guard section == 0 else { return nil }
		
		var completedSets = UInt()

		for topicQuiz in DataStoreArchiver.shared.completedSets {
			for setQuiz in topicQuiz.value where setQuiz.value == true {
				completedSets += 1
			}
		}
		
		let correctAnswers = UserDefaultsManager.correctAnswers
		let incorrectAnswers = UserDefaultsManager.incorrectAnswers
		let numberOfAnswers = Float(incorrectAnswers + correctAnswers)
		let correctAnswersPercent = (numberOfAnswers > 0) ? Int(round((Float(correctAnswers) / numberOfAnswers) * 100.0)) : 0
		
		return "\n\(Localized.Settings_Statistics_Title): \n\n" +
			"\(Localized.Settings_Statistics_CompletedSets): \(completedSets)\n" +
			"\(Localized.Settings_Statistics_CorrectAnswers): \(correctAnswers)\n" +
			"\(Localized.Settings_Statistics_IncorrectAnswers): \(incorrectAnswers)\n" +
			"\(Localized.Settings_Statistics_Ratio): \(correctAnswersPercent)%\n\n" +
			Localized.Settings_Options_HapticFeedback_Info + "\n"
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		let footer = view as? UITableViewHeaderFooterView
		footer?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
		footer?.contentView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return tableView.cellForRow(at: indexPath)?.accessoryView == nil
	}
	
	@IBAction func backgroundMusicSwitchAction(sender: UISwitch) {
		if sender.isOn { AudioSounds.bgMusic?.play() }
		else { AudioSounds.bgMusic?.pause() }
		
		UserDefaultsManager.backgroundMusicSwitchIsOn = sender.isOn
	}
	
	@IBAction func darkThemeSwitchAction(sender: UISwitch) {
		UserDefaultsManager.darkThemeSwitchIsOn = sender.isOn
		self.loadCurrentTheme(animated: true)
	}
	
	private func loadSwitchesStates() {
		backgroundMusicSwitch.setOn(AudioSounds.bgMusic?.isPlaying ?? false, animated: true)
		darkThemeSwitch.setOn(UserDefaultsManager.darkThemeSwitchIsOn, animated: true)
		
	}
	
	private func setUpSwitches() {
		
		self.backgroundMusicSwitch.addTarget(self, action: #selector(backgroundMusicSwitchAction(sender:)), for: .touchUpInside)
		self.darkThemeSwitch.addTarget(self, action: #selector(darkThemeSwitchAction(sender:)), for: .touchUpInside)
	
		let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
		self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }
	}
	
	private func resetProgressStatistics() {
		
		DataStoreArchiver.shared.completedSets.removeAll()
		CachedImages.shared.clear()
		SetOfTopics.shared.loadAllTopicsStates()
		guard DataStoreArchiver.shared.save() else { print("Error saving settings"); return }
		
		UserDefaultsManager.correctAnswers = 0
		UserDefaultsManager.incorrectAnswers = 0
		UserDefaultsManager.score = 0
		
		self.tableView.reloadData()
	}
	
	private func resetProgressOptions() {
		
		self.resetProgressStatistics()
		
		UserDefaultsManager.backgroundMusicSwitchIsOn = true
		UserDefaultsManager.darkThemeSwitchIsOn = false
		
		self.darkThemeSwitch.setOn(false, animated: true)
		self.backgroundMusicSwitch.setOn(true, animated: true)
		
		AudioSounds.bgMusic?.play()
		
		self.loadCurrentTheme(animated: true)
	}
	
	private func loadCurrentTheme(animated: Bool) {
		
		let duration: TimeInterval = animated ? 0.2 : 0
		
		if #available(iOS 10.0, *) {
			UIView.animate(withDuration: duration) {
				self.navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
			}
		}
		else {
			navigationController?.navigationBar.barStyle = .themeStyle(dark: .black, light: .default)
		}
		self.navigationController?.toolbar.tintColor = .themeStyle(dark: .red, light: .defaultTintColor)
		self.navigationController?.toolbar.barStyle = UIBarStyle.themeStyle(dark: .blackTranslucent, light: .default)
		
		UIView.transition(with: self.view, duration: duration, options: [.transitionCrossDissolve], animations: {
			
			self.navigationController?.navigationBar.tintColor = .themeStyle(dark: .red, light: .defaultTintColor)
			
			self.tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
			self.tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
			
			let switchTintColor = UIColor.themeStyle(dark: .warmColor, light: .coolBlue)
			self.switches.forEach { $0.onTintColor = switchTintColor; $0.dontInvertColors() }

		}, completion: { completed in
			if completed {
				self.tableView.reloadData()
			}
		})
		
		AppDelegate.windowReference?.dontInvertIfDarkModeIsEnabled()
	}
	
	private func resetProgressAlert(cellIndexpath: IndexPath) {
		
		let alertViewController = UIAlertController(title: Localized.Settings_Alerts_ResetProgress_Title, message: nil, preferredStyle: .actionSheet)
		
		alertViewController.addAction(title: Localized.Common_Cancel, style: .cancel)
		alertViewController.addAction(title: Localized.Settings_Alerts_ResetProgress_Everything, style: .destructive) { action in
			self.resetProgressOptions()
		}
		alertViewController.addAction(title: Localized.Settings_Alerts_ResetProgress_OnlyStatistics, style: .default) { action in
			self.resetProgressStatistics()
		}
		
		alertViewController.popoverPresentationController?.sourceView = self.tableView
		alertViewController.popoverPresentationController?.sourceRect = self.tableView.rectForRow(at: cellIndexpath)
		
		self.present(alertViewController, animated: true)
	}
}
