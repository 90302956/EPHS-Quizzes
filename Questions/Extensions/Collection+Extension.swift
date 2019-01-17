//
//  Collection+Extension.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import GameplayKit.GKRandomSource

extension MutableCollection {
	mutating func shuffle() {
		let c = count
		guard c > 1 else { return }
		
		for (firstUnshuffled, unshuffledCount) in zip(indices, stride(from: c, to: 1, by: -1)) {
			
			let d: Int = numericCast(arc4random_uniform(numericCast(unshuffledCount)))
			let i = index(firstUnshuffled, offsetBy: d)
			swapAt(firstUnshuffled, i)
		}
	}
}

extension Sequence {
	var shuffled: [Element] {
		var result = Array(self)
		result.shuffle()
		return result
	}
}
