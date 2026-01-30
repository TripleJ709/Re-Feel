//
//  DetailViewModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/26/26.
//

import Foundation
import Combine

final class DetailViewModel {
    let emotion: Emotion
    private let repository: EmotionRepositoryProtocol
    
    let didDeleteEmotion = PassthroughSubject<Void, Never>()
    private var cancellables = Set<AnyCancellable>()
    
    init(emotion: Emotion, repository: EmotionRepositoryProtocol) {
        self.emotion = emotion
        self.repository = repository
    }
    
    func deleteEmotion() {
        repository.delete(emotion)
            .sink { completion in
                if case .failure(let error) = completion {
                    print("삭제 실패: \(error)")
                }
            } receiveValue: { [weak self] _ in
                print("삭제 성공")
                self?.didDeleteEmotion.send(())
            }
            .store(in: &cancellables)
    }
}
