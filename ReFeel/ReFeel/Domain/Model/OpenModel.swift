//
//  OpenModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/19/26.
//

import Foundation

struct OpenAIResponse: Codable {
    let choices: [Choice]
}

struct Choice: Codable {
    let message: Message
}

struct Message: Codable {
    let content: String
}
