//
//  FakeEmotionTransformer.swift
//  ReFeel
//
//  Created by 장주진 on 1/19/26.
//

import Foundation
import Combine

final class FakeEmotionTransformer: EmotionTransforming {
    func transform(text: String) -> AnyPublisher<String, Error> {
        let result = "괜찮아. 오늘 하루도 충분히 잘 해냈어."
        return Just(result)
            .setFailureType(to: Error.self)
            .delay(for: .seconds(1), scheduler: DispatchQueue.global())
            .eraseToAnyPublisher()
    }
}
