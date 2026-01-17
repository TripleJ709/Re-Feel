//
//  HomeViewModel.swift
//  ReFeel
//
//  Created by 장주진 on 1/17/26.
//

import Foundation
import Combine

final class HomeViewModel {
    @Published private(set) var emotions: [Emotion] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?
    
    let repository: EmotionRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: EmotionRepositoryProtocol) {
        self.repository = repository
    }
    
    func fetchEmotions() {
        isLoading = true
        
        repository.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink { [weak self] emotions in
                self?.isLoading = false
                self?.emotions = emotions
            }
            .store(in: &cancellables)
    }
}
