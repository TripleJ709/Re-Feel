//
//  EmotionRepository.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine

final class EmotionRepository: EmotionRepositoryProtocol {
    private let emotionsSubject = CurrentValueSubject<[Emotion], Never>([
        Emotion(id: UUID(), rawText: "오늘 너무 피곤하다", transformedText: "그래도 잘 버텼어요.", createdAt: Date()),
        Emotion(id: UUID(), rawText: "그래도 시작은 했다", transformedText: "시작했다는 게 가장 중요해요.", createdAt: Date())
    ])
    
    func fetchAll() -> AnyPublisher<[Emotion], Error> {
        emotionsSubject
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }
    
    func save(_ emotion: Emotion) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            
            var current = self.emotionsSubject.value
            current.insert(emotion, at: 0)
            self.emotionsSubject.send(current)
            
            promise(.success(()))
        }
        .eraseToAnyPublisher()
    }
}
