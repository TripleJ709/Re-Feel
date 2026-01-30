//
//  EmotionTransforming.swift
//  ReFeel
//
//  Created by 장주진 on 1/19/26.
//

import Foundation
import Combine

protocol EmotionTransforming {
    func transform(text: String) -> AnyPublisher<String, Error>
}
