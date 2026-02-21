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
    @Published private(set) var sections: [(date: Date, items: [Emotion])] = []
    
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
                self?.organizeByMonth(emotions: emotions)
            })
            .store(in: &cancellables)
    }
    
    func hasDiaryForToday() -> Bool {
        let todayStr = DateFormatter.yyyyMMdd.string(from: Date())
        
        for section in sections {
            for item in section.items {
                let itemDateStr = DateFormatter.yyyyMMdd.string(from: item.createdAt)
                if itemDateStr == todayStr {
                    return true
                }
            }
        }
        return false
    }
    
    private func organizeByMonth(emotions: [Emotion]) {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: emotions) { emotion -> Date in
            let components = calendar.dateComponents([.year, .month], from: emotion.createdAt)
            return calendar.date(from: components) ?? Date()
        }
        
        let sortedSection = grouped.sorted { $0.key > $1.key }
            .map { (date: $0.key, items: $0.value) }
        self.sections = sortedSection
    }
}
