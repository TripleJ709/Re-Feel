//
//  EmotionRepository.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine
import FirebaseFirestore

final class EmotionRepository: EmotionRepositoryProtocol {
    private let db = Firestore.firestore()
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    func fetchAll() -> AnyPublisher<[Emotion], Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            
            self.db.collection("users").document(self.userId).collection("emotions")
                .order(by: "createdAt", descending: true)
                .getDocuments { snapshot, error in
                    if let error {
                        promise(.failure(error))
                        return
                    }
                    
                    let emotions = snapshot?.documents.compactMap { doc -> Emotion? in
                        try? doc.data(as: Emotion.self)
                    } ?? []
                    
                    promise(.success(emotions))
                }
        }
        .eraseToAnyPublisher()
    }
    
    func save(_ emotion: Emotion) -> AnyPublisher<Void, Error> {
        return Future { [weak self] promise in
            guard let self else { return }
            
            do {
                try self.db.collection("users").document(self.userId).collection("emotions")
                    .document(emotion.id.uuidString)
                    .setData(from: emotion) { error in
                        if let error {
                            promise(.failure(error))
                        } else {
                            promise(.success(()))
                        }
                    }
            } catch {
                promise(.failure(error))
            }
        }
        .eraseToAnyPublisher()
    }
}
