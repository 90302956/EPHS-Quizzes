//
//  QuestionsAppOptions.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import Foundation

struct QuestionsAppOptions {
	
	static let correctAnswerPoints: Int = 20
	static let incorrectAnswerPoints: Int = -10
	static let helpActionPoints: Int = -5
	
	static let maximumHelpTries: UInt8 = 2
	static let isHelpEnabled: Bool = true
	
	static let maximumRepeatTriesPerQuiz: UInt8 = 2
	
	static let privacyFeaturesEnabled: Bool = false
    
    static let communityTopicsURL: String = "https://pastebin.com/raw/hgmNQ0xh"
	
	static let questionJSONFormatURL: String = "https://github.com/90302956/Quiz/blob/master/topicsjsonformat"
}
