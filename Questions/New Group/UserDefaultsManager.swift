import Foundation

struct UserDefaultsManager {
	
	private static func get<T>(property: PreferencesManager.Properties) -> T {
		return PreferencesManager.standard.valueOrDefault(for: property)
	}
	private static func set<T>(property: PreferencesManager.Properties, value: T) {
		PreferencesManager.standard[property] = value
	}
	
	static var backgroundMusicSwitchIsOn: Bool {
		get { return get(property: .backgroundMusicSwitch) }
		set { set(property: .backgroundMusicSwitch, value: newValue) }
	}
	
	static var darkThemeSwitchIsOn: Bool {
		get { return get(property: .darkThemeSwitch) }
		set { set(property: .darkThemeSwitch, value: newValue) }
	}
	
	static var score: Int {
		get { return get(property: .score) }
		set { set(property: .score, value: newValue) }
	}
	
	static var correctAnswers: Int {
		get { return get(property: .correctAnswers) }
		set { set(property: .correctAnswers, value: newValue) }
	}
	
	static var incorrectAnswers: Int {
		get { return get(property: .incorrectAnswers) }
		set { set(property: .incorrectAnswers, value: newValue) }
	}
	
	static var savedQuestionsCounter: Int {
		get { return get(property: .savedQuestionsCounter) }
		set { set(property: .savedQuestionsCounter, value: newValue) }
	}
}
