//
//  GptEmotionTransformer.swift
//  ReFeel
//
//  Created by 장주진 on 1/19/26.
//

import Foundation
import Combine
import Alamofire

final class GptEmotionTransformer: EmotionTransforming {
    private let apiKey = Secrets.openAIKey
    private let url = "https://api.openai.com/v1/chat/completions"
    
    func transform(text: String) -> AnyPublisher<String, Error> {
        let header: HTTPHeaders = [
            "Authorization": "Bearer \(apiKey)",
            "Content-Type": "application/json"
        ]
        
        let parameter: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "너는 다정하고 공감 능력이 뛰어난 심리 상담가야. 사용자의 일기를 읽고 2문장 이내로 따뜻한 위로와 짧은 명언을 건네줘."],
                ["role": "user", "content": text]
            ]
        ]
        
        return Future { [weak self] promise in
            guard let self else { return }
            
            AF.request(self.url, method: .post, parameters: parameter, encoding: JSONEncoding.default, headers: header)
                .validate()
                .responseDecodable(of: OpenAIResponse.self) { response in
                    switch response.result {
                    case .success(let data):
                        let content = data.choices.first?.message.content ?? "답변을 가져올 수 없어요"
                        promise(.success(content))
                        
                    case .failure(let error):
                        print("GPT통신 에러: \(error)")
                        promise(.failure(error))
                    }
                }
        }.eraseToAnyPublisher()
    }
}
