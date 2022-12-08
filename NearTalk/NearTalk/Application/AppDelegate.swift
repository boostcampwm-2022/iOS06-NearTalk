//
//  AppDelegate.swift
//  NearTalk
//
//  Created by lymchgmk on 2022/11/11.
//

import FirebaseCore
import FirebaseMessaging
import UIKit
import UserNotifications
import RxSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    private let disposeBag: DisposeBag = .init()

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter
            .current()
            .requestAuthorization(
                options: authOptions,completionHandler: { (result, error) in
                    if let error {
                        print(error)
                        return
                    }

                    if result {
                        DispatchQueue.main.async {
                            application.registerForRemoteNotifications()
                        }
                    }
                }
            )
        self.bindToUserDefaultsTheme()
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
}

extension AppDelegate : MessagingDelegate {
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        let fireStoreService: FirestoreService = DefaultFirestoreService()
        let firebaseAuthService: AuthService = DefaultFirebaseAuthService()
        let profileRepository: ProfileRepository = DefaultProfileRepository(
            firestoreService: fireStoreService,
            firebaseAuthService: firebaseAuthService
        )
        profileRepository.fetchMyProfile()
            .flatMap {
                var newProfile: UserProfile = $0
                newProfile.fcmToken = fcmToken
                return profileRepository.updateMyProfile(newProfile)
            }
            .subscribe(onSuccess: { _ in
                print("update profile with new FCM token: \(fcmToken ?? "")")
            }).disposed(by: disposeBag)
    }
}

extension AppDelegate : UNUserNotificationCenterDelegate {
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
            completionHandler([.alert, .badge, .sound])
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken;
    }
}

extension AppDelegate {
    func bindToUserDefaultsTheme() {
        UserDefaults.standard.rx
            .observe(String.self, AppTheme.keyName)
            .compactMap { $0 }
            .compactMap { AppTheme(rawValue: $0) }
            .asObservable()
            .subscribe { [weak self] in
                self?.applyTheme(theme: $0)
            }
            .disposed(by: self.disposeBag)
    }
    
    func initTheme() {
        if UserDefaults.standard.string(forKey: AppTheme.keyName) == nil {
            UserDefaults.standard.set(AppTheme.system.rawValue, forKey: AppTheme.keyName)
        }
    }
    
    func applyTheme(theme: AppTheme) {
        UIApplication.shared.connectedScenes.forEach { scene in
            (scene as? UIWindowScene)?.windows.forEach { window in
                window.applyTheme(theme: theme)
            }
        }
    }
}
