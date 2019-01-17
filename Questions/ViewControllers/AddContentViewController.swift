//
//  AddContentViewController.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import UIKit

class CustomUITableViewCell: UITableViewCell {
	@IBInspectable
	override var imageView: UIImageView? { return self.viewWithTag(1) as? UIImageView }
	@IBInspectable
	override var textLabel: UILabel? { return self.viewWithTag(2) as? UILabel }
}

class PopoverTableViewController: UITableViewController {
	
	var parentVC: UITableViewController?
	
	override func viewDidLoad() {
		self.modalPresentationStyle = .popover
	}
	func presentOnParent(_ viewController: UIViewController) {
		self.dismiss(animated: true) {
			self.parentVC?.present(viewController, animated: true)
		}
	}
}

class AddContentTableVC: PopoverTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.tableView.backgroundColor = .popoverVCBackground
		self.view.backgroundColor = .popoverVCBackground
		self.tableView.separatorColor = .clear
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		switch indexPath.row {
		case 0:
			self.dismiss(animated: true)
			self.parentVC?.performSegue(withIdentifier: "createNewTopicSegue", sender: nil)
		default: break
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.textLabel?.textColor = .white
		cell.tintColor = .white
		cell.backgroundColor = .popoverVCBackground
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		guard let cell = tableView.dequeueReusableCell(withIdentifier: "addContentCell", for: indexPath) as? CustomUITableViewCell else { return UITableViewCell() }
		
		switch indexPath.row {
		case 0:
			cell.imageView?.image = #imageLiteral(resourceName: "addTopicCreate")
			cell.textLabel?.text = Localized.Topics_Saved_Add_Menu_Create
			cell.textLabel?.adjustsFontSizeToFitWidth = true
		default: break
		}
		
		let view = UIView()
		view.backgroundColor = .popoverVCBackgroundSelected
		cell.selectedBackgroundView = view
		
		return cell
	}
	
	// Convenience

	private func addRemoteTopicOrContent() {
		
		let titleText = Localized.Topics_Saved_Add_Download_Title
		let messageText = Localized.Topics_Saved_Add_Download_Info
		
		let newTopicAlert = UIAlertController(title: titleText.localized, message: messageText.localized, preferredStyle: .alert)
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Saved_Add_Download_TopicName
			textField.keyboardType = .alphabet
			textField.autocapitalizationType = .sentences
			textField.autocorrectionType = .yes
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Saved_Add_Download_TopicContent
			textField.keyboardType = .URL
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Saved_Add_Download_Help, style: .default) { _ in
			if let url = URL(string: "https://github.com/illescasDaniel/Questions#topics-json-format") {
				if #available(iOS 10.0, *) {
					UIApplication.shared.open(url, options: [:])
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Saved_Add_Download_Action, style: .default) { _ in
			
			if let topicName = newTopicAlert.textFields?.first?.text,
				let topicURLText = newTopicAlert.textFields?.last?.text, !topicURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				
				DispatchQueue.global().async {
					
					let quizContent: String
					if let topicURL = URL(string: topicURLText), let validTextFromURL = try? String(contentsOf: topicURL) {
						quizContent = validTextFromURL
					} else {
						quizContent = topicURLText
					}
					
					if let validQuiz = SetOfTopics.shared.quizFrom(content: quizContent) {
						SetOfTopics.shared.save(topic: TopicEntry(name: topicName, content: validQuiz))
						DispatchQueue.main.async {
							self.parentVC?.tableView.reloadData()
							
						}
					}
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Common_Cancel, style: .cancel)
		
		self.presentOnParent(newTopicAlert)
	}
}
