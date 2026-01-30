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
    
    // 권한 요청하기
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
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        // let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false) // 알림 테스트용(5초후 실행 코드)
        let request = UNNotificationRequest(identifier: "DailyReminder", content: content, trigger: trigger)
        
        guard let componentsHour = components.hour,
              let componentsMinute = components.minute else {
            print("시간 설정 실패")
            return
        }
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error {
                print("알람 스케쥴링 실패: \(error.localizedDescription)")
            } else {
                print("알람 설정 완료: \(componentsHour)시 \(componentsMinute)분")
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

