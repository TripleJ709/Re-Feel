//
//  EmotionRepositoryProtocol.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine

protocol EmotionRepositoryProtocol {
    func fetchAll() -> AnyPublisher<[Emotion], Never>
    func save(_ emotion: Emotion)
}
