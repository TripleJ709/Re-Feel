//
//  DateFormatter+.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import Foundation

// MARK: - TODO: 날짜 사용하는 부분은 모두 여기 확장에서 구현해서 사용하기(지금은 귀찮아서 각각 만들어둔 상태)
extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
    
    static let yyyyMMdd: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월 d일"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter
    }()
}
