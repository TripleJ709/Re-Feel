//
//  AddEmotionViewModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine

final class AddEmotionViewModel {
    
    @Published var text: String = ""
    @Published private(set) var isLoading = false
    @Published private(set) var errorMessage: String?
    
    let didCreateEmotion = PassthroughSubject<Emotion, Never>()

    private let transformer: EmotionTransforming
    private let repository: EmotionRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()

    init(transformer: EmotionTransforming, repository: EmotionRepositoryProtocol) {
        self.repository = repository
        self.transformer = transformer
    }

    func submit() {
        guard !text.isEmpty else { return }

        isLoading = true

        transformer.transform(text: text)
            .flatMap { [repository] transformedText in
                let emotion = Emotion(
                    id: UUID(),
                    rawText: self.text,
                    transformedText: transformedText,
                    createdAt: Date()
                )
                return repository.save(emotion)
                    .map { emotion }
            }
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                self?.isLoading = false
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            } receiveValue: { [weak self] emotion in
                self?.didCreateEmotion.send(emotion)
            }
            .store(in: &cancellables)
    }
}
