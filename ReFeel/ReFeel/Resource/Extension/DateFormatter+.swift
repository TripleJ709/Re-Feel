//
//  DateFormatter+.swift
//  ReFeel
//
//  Created by 장주진 on 1/16/26.
//

import Foundation

extension DateFormatter {
    static let short: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter
    }()
}
