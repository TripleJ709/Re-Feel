//
//  EmotionRepository.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine

final class EmotionRepository: EmotionRepositoryProtocol {
    private var emotionsSubject = CurrentValueSubject<[Emotion], Never>([
        Emotion(id: UUID(), content: "오늘 너무 피곤하다", createdAt: Date()),
        Emotion(id: UUID(), content: "그래도 시작은 했다", createdAt: Date())
    ])
    
    func fetchAll() -> AnyPublisher<[Emotion], Never> {
        emotionsSubject.eraseToAnyPublisher()
    }
    
    func save(_ emotion: Emotion) {
        var current = emotionsSubject.value
        current.insert(emotion, at: 0)
        emotionsSubject.send(current)
    }
}
