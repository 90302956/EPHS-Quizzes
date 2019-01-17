//
//  AppDelegate.swift
//  Questions
//
//  Created by 90302956 on 12/22/18.
//  Copyright © 2018 Michael Werdal. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var wasPlaying = Bool()
    private let blurView = UIVisualEffectView(frame: UIScreen.main.bounds)
    
    enum ShortcutItemType: String {
        case QRCode
    }
    
    static var windowReference: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        if let mySettings = NSKeyedUnarchiver.unarchiveObject(withFile: DataStoreArchiver.path) as? DataStoreArchiver {
            DataStoreArchiver.shared = mySettings
        }
        
        AppDelegate.windowReference = self.window
        
        let navController = window?.rootViewController as? UINavigationController
        
        if #available(iOS 11.0, *) {
            navController?.navigationBar.prefersLargeTitles = true
        }
        
        let readQRCode = UIMutableApplicationShortcutItem(type: ShortcutItemType.QRCode.rawValue,
                                                          localizedTitle: "Scan QR Code".localized,
                                                          localizedSubtitle: nil,
                                                          icon: UIApplicationShortcutIcon(templateImageName: "QRCodeIcon"))
        
        application.shortcutItems = [readQRCode]
        
        
        
        self.window?.dontInvertIfDarkModeIsEnabled()
        
        if QuestionsAppOptions.privacyFeaturesEnabled {
            self.setupBlurView()
        }
        
        return true
    }
    
    private func setupBlurView() {
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.effect = UserDefaultsManager.darkThemeSwitchIsOn ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
        blurView.isHidden = true
        self.window?.addSubview(blurView)
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        guard QuestionsAppOptions.privacyFeaturesEnabled else { return }
        blurView.isHidden = false
        self.window?.bringSubviewToFront(blurView)
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        if wasPlaying {
            AudioSounds.bgMusic?.play()
        }
        
        self.window?.dontInvertIfDarkModeIsEnabled()
        
        if QuestionsAppOptions.privacyFeaturesEnabled {
            self.blurView.isHidden = true
        }
    }
    
    @available(iOS 9.0, *)
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        
        if let itemType = ShortcutItemType(rawValue: shortcutItem.type) {
            
            switch itemType {
                
            case .QRCode:
                
                if let questionsVC = window?.rootViewController?.presentedViewController as? QuestionsViewController {
                    questionsVC.performSegue(withIdentifier: "unwindToMainMenu", sender: self)
                }
                
                if let presentedViewController = window?.rootViewController as? UINavigationController {
                    
                    if !(presentedViewController.topViewController is MainViewController) {
                        presentedViewController.popToRootViewController(animated: false)
                    }
                    
                    presentedViewController.topViewController?.performSegue(withIdentifier: "QRScannerVC", sender: self)
                }
                else if (window?.rootViewController == nil) {
                    
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let viewController = storyboard.instantiateViewController(withIdentifier: "mainViewController") as? MainViewController {
                        
                        let navController = UINavigationController(rootViewController: viewController)
                        if #available(iOS 11.0, *) {
                            navController.navigationBar.prefersLargeTitles = true
                        }
                        
                        window?.rootViewController?.present(navController, animated: false)
                        
                        viewController.performSegue(withIdentifier: "QRScannerVC", sender: self)
                    }
                }
            }
        }
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        
        if AudioSounds.bgMusic?.isPlaying ?? false {
            AudioSounds.bgMusic?.pause()
            wasPlaying = true
        }
        else {
            wasPlaying = false
        }
        
        guard DataStoreArchiver.shared.save() else { print("Error saving settings"); return }
        
        self.window?.dontInvertIfDarkModeIsEnabled()
    }
}
