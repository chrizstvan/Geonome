//
//  SceneDelegate.swift
//  Geonome
//
//  Created by Chris Stev on 02/12/20.
//  Copyright © 2020 Setel. All rights reserved.
//

import UIKit
import CoreLocation

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    let locationManager = CLLocationManager()
    var vc = GeotifBuilder().build()

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let ws = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: ws)
        window?.rootViewController = UINavigationController(rootViewController: vc)
        window?.makeKeyAndVisible()
        configureLocation()
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }

    // configureLocation handle configure location manager
    private func configureLocation() {
        locationManager.delegate = self
        locationManager.requestAlwaysAuthorization()
    }
    
    // showingAreaStatus shows status to user or handle triger notification when condition meet
    func showingAreaStatus(for region: CLRegion!, state: CLRegionState) {
        // Show an alert if application is active
        if UIApplication.shared.applicationState == .active {
            guard let message = note(from: region.identifier) else { return }
            vc.title = state == .inside ? "Inside \(message) Area"
                : state == .outside ? Constant.statusOutside
                : Constant.statusUnknown
        } else {
            // Otherwise present a local notification
            guard let body = note(from: region.identifier) else { return }
            let notificationContent = UNMutableNotificationContent()
            notificationContent.sound = UNNotificationSound.default
            notificationContent.badge = UIApplication.shared.applicationIconBadgeNumber + 1 as NSNumber
            notificationContent.body = state == .inside ? "Inside \(body) Area"
                : state == .outside ? Constant.statusOutside
                : Constant.statusUnknown
            
            sendNotification(with: notificationContent)
        }
    }
    
    // note handle passing string note to alert
    private func note(from identifier: String) -> String? {
        let geotifications = GeotificationViewModel.allGeotifications()
        guard let matched = geotifications.filter({ $0.identifier == identifier}).first else { return nil }
        return matched.note
    }
    
    // sendNotification hanlde triggering local notification
    private func sendNotification(with content: UNMutableNotificationContent) {
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        let request = UNNotificationRequest(
            identifier: "location_change",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error: \(error)")
            }
        }
    }
}

extension SceneDelegate: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didDetermineState state: CLRegionState, for region: CLRegion) {
        showingAreaStatus(for: region, state: state)
    }
}

