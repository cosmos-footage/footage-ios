//
//  NotificationScheduling.swift
//  footage
//
//  Created by Codex on 2026/07/04.
//

import Foundation
import UserNotifications

protocol NotificationScheduling {
    func requestAuthorization(completion: ((Bool, Error?) -> Void)?)
    func scheduleRecordingStoppedBySpeed(completion: ((Error?) -> Void)?)
    func scheduleRecordingStoppedByNoSpeed(completion: ((Error?) -> Void)?)
    func scheduleBadgeEarned(completion: ((Error?) -> Void)?)
    func scheduleEverydayAlert(completion: ((Error?) -> Void)?)
    func scheduleEveryMonthAlert(completion: ((Error?) -> Void)?)
}

final class UserNotificationSchedulingService: NotificationScheduling {
    private let notificationCenter: UNUserNotificationCenter
    private let userDefaults: UserDefaults

    init(
        notificationCenter: UNUserNotificationCenter = .current(),
        userDefaults: UserDefaults = .standard
    ) {
        self.notificationCenter = notificationCenter
        self.userDefaults = userDefaults
    }

    func requestAuthorization(completion: ((Bool, Error?) -> Void)? = nil) {
        notificationCenter.requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            completion?(granted, error)
        }
    }

    func scheduleRecordingStoppedBySpeed(completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "속도 제한 초과"
        content.body = "발자취를 남긴다는 건, 주위를 온전히 담아낼 수 있어야 한다는 것."
        content.badge = 1
        content.sound = .default

        schedule(content: content, trigger: oneSecondTrigger(), completion: completion)
    }

    func scheduleRecordingStoppedByNoSpeed(completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "기록 중지"
        content.body = "어딘가에 머물러 짙은 발자취를 남기시나보군요. 잠시 기록을 중단하겠습니다."
        content.badge = 1
        content.sound = .default

        schedule(content: content, trigger: oneSecondTrigger(), completion: completion)
    }

    func scheduleBadgeEarned(completion: ((Error?) -> Void)? = nil) {
        let content = UNMutableNotificationContent()
        content.title = "새로운 배지를 획득하였습니다!"
        content.badge = 0
        content.sound = .default

        schedule(content: content, trigger: oneSecondTrigger(), completion: completion)
    }

    func scheduleEverydayAlert(completion: ((Error?) -> Void)? = nil) {
        var dateComponents = DateComponents()
        if userDefaults.object(forKey: "everydayPushHour") != nil {
            dateComponents.hour = userDefaults.integer(forKey: "everydayPushHour")
            dateComponents.minute = userDefaults.integer(forKey: "everydayPushMinute")
        } else {
            dateComponents.hour = 10
            dateComponents.minute = 30
        }

        let content = UNMutableNotificationContent()
        content.body = "오늘도 세상에 당신의 발자취를 남겨볼까요?"
        content.badge = 1
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        schedule(content: content, trigger: trigger, completion: completion)
    }

    func scheduleEveryMonthAlert(completion: ((Error?) -> Void)? = nil) {
        var dateComponents = DateComponents()
        dateComponents.day = 1
        dateComponents.hour = 00
        dateComponents.minute = 00

        let content = UNMutableNotificationContent()
        content.title = "새로운 달의 시작이에요."
        content.body = "월간 리포트가 초기화되었습니다. 지난 달 기록은 '지난 기록 보기'에 잘 보관되었습니다:-)"
        content.badge = 1
        content.sound = .default

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        schedule(content: content, trigger: trigger, completion: completion)
    }

    private func oneSecondTrigger() -> UNTimeIntervalNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
    }

    private func schedule(
        content: UNNotificationContent,
        trigger: UNNotificationTrigger,
        completion: ((Error?) -> Void)?
    ) {
        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: trigger
        )

        notificationCenter.add(request) { error in
            completion?(error)
        }
    }
}
