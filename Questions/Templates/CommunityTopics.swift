//
//  CommunityTopics.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import Foundation

struct CommunityTopic: Codable {
    let name: String?
    let remoteContentURL: URL
    var isVisible: Bool
}

struct CommunityTopics: Codable {
    
    let topics: [CommunityTopic]
    
    static var shared: CommunityTopics? = nil
    static var areLoaded: Bool = false
    
    static func initialize(completionHandler: ((CommunityTopics?) -> ())? = nil) {
        DispatchQueue.global().async {
            if let communityTopicsURL = URL(string: QuestionsAppOptions.communityTopicsURL),
                let data = try? Data(contentsOf: communityTopicsURL),
                let communityTopics = try? JSONDecoder().decode(CommunityTopics.self, from: data) {
                CommunityTopics.shared = communityTopics
            }
            completionHandler?(CommunityTopics.shared)
        }
    }
    
    static func initializeSynchronously() {
        if let communityTopicsURL = URL(string: QuestionsAppOptions.communityTopicsURL),
            let data = try? Data(contentsOf: communityTopicsURL),
            let communityTopics = try? JSONDecoder().decode(CommunityTopics.self, from: data) {
            CommunityTopics.shared = communityTopics
        }
    }
}

