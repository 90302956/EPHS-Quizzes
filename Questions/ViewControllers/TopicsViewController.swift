//
//  TopicsViewController.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import UIKit

class TopicsViewController: UITableViewController, UIPopoverPresentationControllerDelegate, UISearchBarDelegate {
	
	@IBOutlet weak var addBarButtonItem: UIBarButtonItem!
	@IBOutlet weak var refreshBarButtonItem: UIBarButtonItem!
	
	let searchController = SearchTableViewController()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.navigationItem.title = SetOfTopics.shared.current == .community ? Localized.Topics_Community_Title : Localized.Topics_AllTopics_Title
		
		self.editButtonItem.isEnabled = SetOfTopics.shared.current != .community
		if let rightBarButtonItems = self.navigationItem.rightBarButtonItems {
			self.navigationItem.rightBarButtonItems = [self.editButtonItem] + rightBarButtonItems
		}
		self.tableView.allowsMultipleSelectionDuringEditing = true
		self.clearsSelectionOnViewWillAppear = true
		
		self.isEditing = false

		let allowedBarButtonItems: [UIBarButtonItem]?
		if SetOfTopics.shared.current != .community {
			allowedBarButtonItems = self.navigationItem.rightBarButtonItems?.filter { $0 != self.refreshBarButtonItem}
		} else {
			allowedBarButtonItems = [self.addBarButtonItem, self.refreshBarButtonItem]
		}
		self.navigationItem.setRightBarButtonItems(allowedBarButtonItems, animated: false)
		
		let shareItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareItems))
		let flexibleSpaceItem = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: self, action: nil)
		let trashItem = UIBarButtonItem(barButtonSystemItem: .trash, target: self, action: #selector(deleteItems))
		self.toolbarItems = [shareItem, flexibleSpaceItem, trashItem]
		
		if #available(iOS 11.0, *) {
			self.navigationItem.searchController = UISearchController(searchResultsController: self.searchController)
			self.searchController.parentVC = self
			self.navigationItem.searchController?.searchBar.delegate = self
			self.navigationItem.searchController?.delegate = self.searchController
			self.definesPresentationContext = true
			self.navigationItem.searchController?.obscuresBackgroundDuringPresentation = false
			self.navigationItem.hidesSearchBarWhenScrolling = true
			self.navigationItem.searchController?.searchBar.placeholder = Localized.Topics_AllTopics_SearchBar_PlaceholderText
		}
	
		if UserDefaultsManager.darkThemeSwitchIsOn {
			self.loadCurrentTheme()
		}
	}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.updateEditButton()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.setEditing(false, animated: true)
	}
	
	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
		
		DispatchQueue.global(qos: .userInitiated).async {
			
			var items: [SetOfTopics.Mode: [TopicEntry]] = [:]
			
			if SetOfTopics.shared.current == .community {
				
				items[.community] = Array(SetOfTopics.shared.communityTopics.sorted { lhs, rhs in
						return lhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText) > rhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText)
					}.prefix(10))
			}
			else {
				items[.app] = Array(SetOfTopics.shared.topics.sorted { lhs, rhs in
						return lhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText) > rhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText)
					}.prefix(10))
				items[.saved] = Array(SetOfTopics.shared.savedTopics.sorted { lhs, rhs in
						return lhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText) > rhs.displayedName.localized.levenshteinDistanceScoreTo(string: searchText)
					}.prefix(10))
			}
			
			DispatchQueue.main.async {
				self.searchController.items = items
				self.searchController.tableView.reloadData()
			}
		}
	}
	
	func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
		return .none
	}
	
	@objc internal func editModeAction() {
		self.setEditing(!self.isEditing, animated: true)
	}
	
	override func setEditing(_ editing: Bool, animated: Bool) {
		super.setEditing(editing, animated: animated)
		self.navigationController?.setToolbarHidden(!editing, animated: true)
		if editing { self.toolbarItems?.forEach { $0.isEnabled = false }}
	}
	
	override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
		switch indexPath.section {
		case SetOfTopics.Mode.app.rawValue: return false
		case SetOfTopics.Mode.saved.rawValue: return true
		default: return false
		}
	}
	
	override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
		switch indexPath.section {
		case SetOfTopics.Mode.app.rawValue: return .none
		case SetOfTopics.Mode.saved.rawValue: return .delete
		default: return .none
		}
	}
	
	override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
		guard editingStyle == .delete else { return }
		
		if let cell = tableView.cellForRow(at: indexPath), let labelText = cell.textLabel?.text {
			SetOfTopics.shared.removeSavedTopics(named: [labelText], reloadAfterDeleting: true)
			tableView.deleteRows(at: [indexPath], with: .fade)
		}
	}
	
	@objc private func reloadTopicIfCommunityTopicsLoaded(_ timer: Timer) {
		if CommunityTopics.shared != nil && CommunityTopics.areLoaded {
			DispatchQueue.main.async {
				(self.tableView?.backgroundView as? UIActivityIndicatorView)?.stopAnimating()
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
				self.tableView.reloadData()
			}
			timer.invalidate()
		}
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if SetOfTopics.shared.current == .community {
			if self.tableView.backgroundView == nil && SetOfTopics.shared.communityTopics.isEmpty {
				let activityIndicatorView = UIActivityIndicatorView(style: UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray)
				activityIndicatorView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
				activityIndicatorView.startAnimating()
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
				
				self.tableView?.backgroundView = activityIndicatorView
				
				if CommunityTopics.shared == nil || !CommunityTopics.areLoaded {
					
					if #available(iOS 10.0, *) {
						Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
							if CommunityTopics.shared != nil && CommunityTopics.areLoaded {
								DispatchQueue.main.async {
									activityIndicatorView.stopAnimating()
									self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
									self.tableView.reloadData()
								}
								timer.invalidate()
							}
						}
					} else {
						Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.reloadTopicIfCommunityTopicsLoaded), userInfo: nil, repeats: true)
					}
				}
			}
			return SetOfTopics.shared.communityTopics.count
		}
		else {
			switch section {
			case SetOfTopics.Mode.app.rawValue: return SetOfTopics.shared.topics.count
			case SetOfTopics.Mode.saved.rawValue: return SetOfTopics.shared.savedTopics.count
			default: return 0
			}
		}
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		if SetOfTopics.shared.current == .community {
			return 1
		} else {
			return SetOfTopics.shared.savedTopics.isEmpty ? 1 : 2
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
		cell.textLabel?.textColor = .themeStyle(dark: .white, light: .black)
		cell.tintColor = .themeStyle(dark: .red, light: .defaultTintColor)
		if UserDefaultsManager.darkThemeSwitchIsOn { cell.backgroundColor = .veryDarkGray }
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "setCell", for: indexPath)
		
		if SetOfTopics.shared.current == .community {
			cell.textLabel?.text = SetOfTopics.shared.communityTopics[indexPath.row].displayedName.localized
		}
		else {
			switch indexPath.section {
			case SetOfTopics.Mode.app.rawValue:
				cell.textLabel?.text = SetOfTopics.shared.topics[indexPath.row].displayedName.localized
			case SetOfTopics.Mode.saved.rawValue:
				cell.textLabel?.text = SetOfTopics.shared.savedTopics[indexPath.row].displayedName.localized
			default: break
			}
		}
		
		// Load theme
		cell.textLabel?.font = .preferredFont(forTextStyle: .body)
		
		if UserDefaultsManager.darkThemeSwitchIsOn {
			let view = UIView()
			view.backgroundColor = UIColor.darkGray
			cell.selectedBackgroundView = view
		}
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		switch section {
		case SetOfTopics.Mode.app.rawValue: return nil
		case SetOfTopics.Mode.saved.rawValue: return Localized.Topics_AllTopics_Type_Saved
		default: return nil
		}
	}
	
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		guard UserDefaultsManager.darkThemeSwitchIsOn else { return }
		let header = view as? UITableViewHeaderFooterView
		header?.textLabel?.textColor = .themeStyle(dark: .lightGray, light: .gray)
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		
		if self.isEditing { self.toolbarItems?.forEach { $0.isEnabled = true } }
		
		guard !self.isEditing, let currentCell = tableView.cellForRow(at: indexPath) else { return }
	
		if SetOfTopics.shared.current == .community {
			
			let activityIndicator = UIActivityIndicatorView(frame: currentCell.bounds)
			activityIndicator.style = (UserDefaultsManager.darkThemeSwitchIsOn ? .white : .gray)
			activityIndicator.autoresizingMask = [.flexibleWidth, .flexibleHeight]
			
			if SetOfTopics.shared.communityTopics[indexPath.row].quiz.sets.flatMap({ $0 }).isEmpty,
				let communityTopics = CommunityTopics.shared {
				
				activityIndicator.startAnimating()
				self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = false }
				currentCell.accessoryView = activityIndicator
				
				let currentTopic = communityTopics.topics[indexPath.row]
				
				DispatchQueue.global().async {
					if let validTextFromURL = try? String(contentsOf: currentTopic.remoteContentURL), let quiz = SetOfTopics.shared.quizFrom(content: validTextFromURL) {
						SetOfTopics.shared.communityTopics[indexPath.row].quiz = quiz
					}
					DispatchQueue.main.async {
						activityIndicator.stopAnimating()
						self.navigationItem.rightBarButtonItems?.forEach { $0.isEnabled = true }
						currentCell.accessoryView = nil
						self.performSegue(withIdentifier: "selectTopic", sender: indexPath)
					}
				}
				return
			}
		}
		self.performSegue(withIdentifier: "selectTopic", sender: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
		let selectedRows = tableView.indexPathsForSelectedRows
		if self.isEditing && (selectedRows == nil || selectedRows?.isEmpty == true) {
			self.toolbarItems?.forEach { $0.isEnabled = false }
		}
	}
	
	override func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
		return (self.isEditing && indexPath.section == SetOfTopics.Mode.saved.rawValue) || !self.isEditing
	}
	
	@IBAction func addTopicAction(_ sender: UIBarButtonItem) {
		
		guard SetOfTopics.shared.current == .community else {
			self.performSegue(withIdentifier: "addContentTableVC", sender: nil)
			return
		}
		
		let titleText = Localized.Topics_Community_Submission_Title
		let messageText = Localized.Topics_Community_Submission_Info
		
		let newTopicAlert = UIAlertController(title: titleText, message: messageText, preferredStyle: .alert)
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Community_Submission_TopicName
			textField.keyboardType = .alphabet
			textField.autocapitalizationType = .sentences
			textField.autocorrectionType = .yes
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addTextField { textField in
			textField.placeholder = Localized.Topics_Community_Submission_TopicContent
			textField.keyboardType = .URL
			textField.keyboardAppearance = UserDefaultsManager.darkThemeSwitchIsOn ? .dark : .light
			textField.addConstraint(textField.heightAnchor.constraint(equalToConstant: 25))
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Community_Submission_Help, style: .default) { _ in
			if let url = URL(string: QuestionsAppOptions.questionJSONFormatURL) {
				if #available(iOS 10.0, *) {
					UIApplication.shared.open(url, options: [:])
				} else {
					UIApplication.shared.openURL(url)
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Topics_Community_Submission_Action, style: .default) { _ in
			
			if let topicName = newTopicAlert.textFields?.first?.text,
				let topicURLText = newTopicAlert.textFields?.last?.text, !topicURLText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
				
				
				let messageBody = """
					Topic name: \(topicName)
					Topic URL or content: \(topicURLText)
					""".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "error"
				
				let devEmail = "placeholder@gmail.com"
				let subject = "Questions - Topic submission".addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? "Questions_Topic submission"
				let fullURL = "mailto:\(devEmail)?subject=\(subject)&body=\(messageBody)"
				
				if let validURL = URL(string: fullURL) {
					UIApplication.shared.openURL(validURL)
				}
			}
		}
		
		newTopicAlert.addAction(title: Localized.Common_Cancel, style: .cancel)
		self.present(newTopicAlert, animated: true)
	}
	
	@objc
	private func deleteItems() {
		
		guard let selectedItemsIndexPaths = self.tableView.indexPathsForSelectedRows, !selectedItemsIndexPaths.isEmpty else { return }
		
		let title = String.localizedStringWithFormat(Localized.Topics_Saved_DeleteAll, selectedItemsIndexPaths.count, selectedItemsIndexPaths.count > 1 ? "s" : "")
		let deleteItemsAlert = UIAlertController(title: title, message: nil, preferredStyle: .actionSheet)
		deleteItemsAlert.popoverPresentationController?.barButtonItem = self.toolbarItems?.last
		
		deleteItemsAlert.addAction(title: Localized.Topics_Saved_Delete, style: .destructive) { _ in
			SetOfTopics.shared.removeSavedTopics(withIndexPaths: selectedItemsIndexPaths, reloadAfterDeleting: true)
			let section = selectedItemsIndexPaths[0].section
			if self.tableView.numberOfRows(inSection: section) == selectedItemsIndexPaths.count {
				self.tableView.deleteSections([section], with: .fade)
				self.updateEditButton()
			} else {
				self.tableView.deleteRows(at: selectedItemsIndexPaths, with: .fade)
			}
			self.setEditing(false, animated: true)
		}
		deleteItemsAlert.addAction(title: Localized.Common_Cancel, style: .cancel)
		
		self.present(deleteItemsAlert, animated: true)
	}
	
	@objc
	private func shareItems() {
		
		guard let selectedItemsIndexPaths = self.tableView.indexPathsForSelectedRows, !selectedItemsIndexPaths.isEmpty else { return }
		
		var items: [Any] = []
		
		for index in selectedItemsIndexPaths.lazy.map ({ $0.row }) {
			let quizInJSON = SetOfTopics.shared.savedTopics[index].quiz.inJSON
			items.append(quizInJSON)
		}
		
		let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
		activityVC.completionWithItemsHandler = { _, completed, _, _ in
			if completed { self.setEditing(false, animated: true) }
		}
		
		activityVC.popoverPresentationController?.barButtonItem = self.toolbarItems?.first
		self.present(activityVC, animated: true)
	}
	
	@IBAction func refreshTopics(_ sender: UIBarButtonItem) {
		
		SetOfTopics.shared.communityTopics.removeAll(keepingCapacity: true)
		CommunityTopics.shared = nil
		CommunityTopics.areLoaded = false
		self.tableView.backgroundView = nil
		self.tableView.reloadData()
		
		DispatchQueue.global().async {
			SetOfTopics.shared.loadCommunityTopics()
			DispatchQueue.main.async {
				self.tableView.reloadData()
			}
		}
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		
		if segue.identifier == "selectTopic", let topicIndexPath = sender as? IndexPath {
			
			let controller = segue.destination as? QuizzesViewController
			
			if SetOfTopics.shared.current != .community {
				switch topicIndexPath.section {
				case SetOfTopics.Mode.app.rawValue: SetOfTopics.shared.current = .app
				case SetOfTopics.Mode.saved.rawValue: SetOfTopics.shared.current = .saved
				default: break
				}
			}
			controller?.currentTopicIndex = topicIndexPath.row
		}
		
		if segue.identifier == "addContentTableVC", let addContentTableVC = segue.destination as? AddContentTableVC, SetOfTopics.shared.current != .community {
			addContentTableVC.popoverPresentationController?.delegate = self
			addContentTableVC.parentVC = self
			self.setEditing(false, animated: true)
		}
	}
	
	private func updateEditButton() {
		self.editButtonItem.isEnabled = !SetOfTopics.shared.savedTopics.isEmpty
	}
	
	private func loadCurrentTheme() {
		self.tableView.backgroundColor = .themeStyle(dark: .black, light: .groupTableViewBackground)
		self.tableView.separatorColor = .themeStyle(dark: .black, light: .defaultSeparatorColor)
	}
}
