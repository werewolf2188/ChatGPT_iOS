//
//  DialogueEntry.swift
//  ChatGPT
//
//  Created by Enrique Ricalde on 7/23/24.
//

import Foundation

struct DialogueEntry: Identifiable {
    private static var last: Int = 0

    enum Character {
        case user
        case system
    }

    var id: Int
    var prompt: String
    var character: Character

    init(prompt: String, character: Character) {
        self.id = DialogueEntry.last
        self.prompt = prompt
        self.character = character
        
        DialogueEntry.last += 1
    }
}
