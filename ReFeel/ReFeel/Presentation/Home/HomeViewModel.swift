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
    let transformer: EmotionTransforming
    
    private var cancellables = Set<AnyCancellable>()
    
    init(repository: EmotionRepositoryProtocol, transformer: EmotionTransforming) {
        self.repository = repository
        self.transformer = transformer
    }
    
    func fetchEmotions() {
        isLoading = true
        
        repository.fetchAll()
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] completion in
                self?.isLoading = false
                
                if case .failure(let error) = completion {
                    self?.errorMessage = error.localizedDescription
                }
            }, receiveValue: { [weak self] emotions in
                self?.emotions = emotions
            })
            .store(in: &cancellables)
    }
}
