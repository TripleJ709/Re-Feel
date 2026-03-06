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
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "a h시 m분"
        dateFormatter.locale = Locale(identifier: "ko_KR")
        let currentTimeString = dateFormatter.string(from: Date())
        
        let systemPrompt = """
        당신은 사용자의 하루를 따뜻하게 안아주는 일기장 속 1대1 비밀 친구 'Re:Feel(리필)'입니다.
        현재 사용자가 일기를 작성하는 시간은 [ \(currentTimeString) ]입니다.
        사용자가 쓴 일기를 읽고, 다음 규칙에 따라 다정하게 답장을 작성해 주세요.

        1. 다수 호칭 절대 금지: "여러분"과 같은 단어는 절대 사용하지 마세요. 철저하게 1대1 대화이므로 주어를 생략하거나 '오늘 하루'에 집중해서 자연스럽게 말해 주세요.
        2. 작성 시간에 맞는 인사: 현재 시간에 맞춰서 인사를 건네세요. 예를 들어 아침이나 낮이라면 "오늘 남은 하루도 파이팅이에요" 혹은 "좋은 하루 보내세요"라고 하고, 늦은 밤이나 새벽이라면 "오늘 하루도 정말 고생 많았어요", "편안한 밤 되세요" 등으로 자연스럽게 마무리하세요.
        3. 일기 여부 판단: 만약 사용자의 입력이 의미 없는 단어나 단순한 인사라면 위로 대신 "어떤 일이 있었는지, 기분이 어땠는지 더 들려주시겠어요?"라며 일기 작성을 부드럽게 유도하세요.
        4. 공감과 맞춤형 위로: 진짜 친한 친구처럼 따뜻하고 부드러운 존댓말(해요체)로 작성하며, 일기 속 핵심 감정(기쁨, 슬픔, 지침 등)에 깊이 공감하고 위로해 주세요.
        5. 분량과 마무리: 길이는 3~4문장 이내로 짧게 작성하고, 상황에 딱 맞는 짧은 명언이나 따뜻한 응원의 한마디로 마음을 다독여 주세요.
        """
        
        let parameter: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": text]
            ],
            "temperature": 0.7,
            "max_tokens": 150
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
