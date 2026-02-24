//
//  NotificationManager.swift
//  ReFeel
//
//  Created by 장주진 on 1/30/26.
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    
    private init() {}
    
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let option: UNAuthorizationOptions = [.alert, .sound, .badge]
        UNUserNotificationCenter.current().requestAuthorization(options: option) { granted, error in
            if let error {
                print("알림 권한 에러: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(granted)
            }
        }
    }
    
    func scheduleNotification(at date: Date) {
        removeNotification()
        
        let content = UNMutableNotificationContent()
        content.title = "Re:Feel"
        content.body = "오늘 하루는 어떠셨나요? 감정을 기록해보세요. 😄"
        content.sound = .default
        
        var skipToday = false
        if let lastDiaryDate = UserDefaults.standard.object(forKey: "lastDiaryDate") as? Date {
            skipToday = Calendar.current.isDateInToday(lastDiaryDate)
        }
        
        let calendar = Calendar.current
        let timeComponents = calendar.dateComponents([.hour, .minute], from: date)
        
        guard let hour = timeComponents.hour, let minute = timeComponents.minute else {
            print("시간 설정 실패")
            return
        }
        
        let startIndex = skipToday ? 1 : 0
        
        for i in startIndex..<60 {
            guard let triggerDate = calendar.date(byAdding: .day, value: i, to: Date()),
                  var triggerComponents = calendar.dateComponents([.year, .month, .day], from: triggerDate) as DateComponents? else { continue }
            
            triggerComponents.hour = hour
            triggerComponents.minute = minute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
            let request = UNNotificationRequest(identifier: "DailyReminder_\(i)", content: content, trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error {
                    print("\(i)일 뒤 알림 예약 실패: \(error.localizedDescription)")
                }
            }
        }
        
        print("알림 60일치 예약 완료 (오늘 알림 스킵 여부: \(skipToday))")
    }
    
    func reschedule() {
        if UserDefaults.standard.bool(forKey: "isNotificationOn") {
            if let savedTime = UserDefaults.standard.object(forKey: "notificationTime") as? Date {
                scheduleNotification(at: savedTime)
            }
        }
    }
    
    func removeNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("알림 예약 취소됨")
    }
    
    func checkPermisstion(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized)
            }
        }
    }
}

