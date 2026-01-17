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
    @Published private(set) var isSaving = false
    @Published private(set) var errorMessage: String?

    private let repository: EmotionRepositoryProtocol

    init(repository: EmotionRepositoryProtocol) {
        self.repository = repository
    }

    func saveEmotion() {
        guard !text.trimmingCharacters(in: .whitespaces).isEmpty else {
            errorMessage = "내용을 입력해주세요."
            return
        }

        let emotion = Emotion(
            id: UUID(),
            content: text,
            createdAt: Date()
        )

        isSaving = true
        repository.save(emotion)
        isSaving = false
    }
}
