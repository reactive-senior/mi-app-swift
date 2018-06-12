//
//  AppDelegate.swift
//  Timi_Test1
//
//  Created by Julien on 21/04/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

import EventKit
import Stripe

import SwiftHTTP

import Fabric
import Crashlytics

import Firebase
import FirebaseCore
import FirebaseMessaging
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    var window: UIWindow?
    
    func applicationWillResignActive(_ application: UIApplication) {}
    func applicationDidEnterBackground(_ application: UIApplication) {}
    func applicationWillEnterForeground(_ application: UIApplication) {}
    func applicationDidBecomeActive(_ application: UIApplication) {}
    func applicationWillTerminate(_ application: UIApplication) {}

    public func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey : Any]? = nil) -> Bool
    {
        
        FirebaseApp.configure()
        Fabric.sharedSDK().debug = true
        Fabric.with([STPAPIClient.self, Crashlytics.self])
        
        
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(options: authOptions, completionHandler: {_, _ in })
            
            UNUserNotificationCenter.current().delegate = self
            Messaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        STPPaymentConfiguration.shared().publishableKey = "pk_live_hdVsoNwrYNSV49HUwlThxugB"
        //STPPaymentConfiguration.shared().publishableKey = "pk_test_dDH8nSrG1aGG5TaX7PvoElHK"
        
        return FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //*********************************
    
    class func getCurrentViewController() -> UIViewController? {
        
        if let navigationController = getNavigationController() {
            return navigationController.visibleViewController
        }
        
        if let rootController = UIApplication.shared.keyWindow?.rootViewController {
            var currentController: UIViewController! = rootController
            while( currentController.presentedViewController != nil ) {
                currentController = currentController.presentedViewController
            }
            return currentController
        }
        return nil
    }
    
    class func getNavigationController() -> UINavigationController? {
    
        if let navigationController = UIApplication.shared.keyWindow?.rootViewController  {
            return navigationController as? UINavigationController
        }
        return nil
    }
    //*********************************

    

    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }

    func openProfil(Donnees: String){

        let jsonUser = convertToDictionary(text: Donnees)
        let distancemax = jsonUser!["distancemax"]! as! String
        print("message distancemax ", distancemax)
        
        let user = Utilisateur()
        if let photoprofil = jsonUser!["photoprofil"] as? String{
            user.photoprofil = photoprofil
        }
        
        if let prenom = jsonUser!["prenom"] as? String{
            user.prenom = prenom
        }
        
        if let sexualite = jsonUser!["sexualite"] as? String{
            user.sexualite = sexualite
        }
        
        if let ageuser = jsonUser!["ageuser"] as? String{
            user.ageuser = ageuser
        }
        
        if let distance_in_km = jsonUser!["distance_in_km"] as? String{
            user.distance_in_km = distance_in_km
        }
        
        if let id = jsonUser!["id"] as? String{
            user.id = id
        }
        
        if let symbole = jsonUser!["symbole"] as? String{
            user.symbole = symbole
        }
        
        if let description = jsonUser!["description"] as? String{
            user.descr = description
        }
        
        if let couleuryeux = jsonUser!["couleuryeux"] as? String{
            user.couleuryeux = couleuryeux
        }
        
        if let couleurcheveux = jsonUser!["couleurcheveux"] as? String{
            user.couleurcheveux = couleurcheveux
        }
        
        if let longueurcheveux = jsonUser!["longueurcheveux"] as? String{
            user.longueurcheveux = longueurcheveux
        }
        
        if let physique = jsonUser!["physique"] as? String{
            user.physique = physique
        }
        
        if let taille = jsonUser!["taille"] as? String{
            user.taille = taille
        }
        
        if let style = jsonUser!["style"] as? String{
            user.style = style
        }
        
        if let origine = jsonUser!["origine"] as? String{
            user.origine = origine
        }
        
        if let religion = jsonUser!["religion"] as? String{
            user.religion = religion
        }
        
        if let profession = jsonUser!["profession"] as? String{
            user.profession = profession
        }
        
        if let fleurschocolats = jsonUser!["fleurschocolats"] as? String{
            user.fleurschocolats = fleurschocolats
        }
        
        if let filmprefere = jsonUser!["filmprefere"] as? String{
            user.filmprefere = filmprefere
        }
        
        if let musiqueprefere = jsonUser!["musiqueprefere"] as? String{
            user.musiqueprefere = musiqueprefere
        }
        
        if let lieuprefere = jsonUser!["lieuprefere"] as? String{
            user.lieuprefere = lieuprefere
        }
        
        if let photo1 = jsonUser!["photo1"] as? String{
            user.photo1 = photo1
        }
        
        if let photo2 = jsonUser!["photo2"] as? String{
            user.photo2 = photo2
        }
        
        if let photo3 = jsonUser!["photo3"] as? String{
            user.photo3 = photo3
        }
        
        if let photo1_valide = jsonUser!["photo1_valide"] as? String{
            user.photo1_valide = photo1_valide
        }
        
        if let photo2_valide = jsonUser!["photo2_valide"] as? String{
            user.photo2_valide = photo2_valide
        }
        
        if let photo3_valide = jsonUser!["photo3_valide"] as? String{
            user.photo3_valide = photo3_valide
        }
        
        if let photoprofil_valide = jsonUser!["photoprofil_valide"] as? String{
            user.photoprofil_valide = photoprofil_valide
        }
        
        if let sexe = jsonUser!["sexe"] as? String{
            user.sexe = sexe
        }
        
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "profil") as! Controller_Profil
        vc.utilisateur = user
        AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)
    }

    func openChat(userInfo: [AnyHashable: Any])
        {
            let chat = Chat()
            if let id = userInfo["idchat"] as? String{chat.id = id}
            if let prenom = userInfo["prenom"] as? String{chat.prenom = prenom}
            let preferences : UserDefaults = UserDefaults.standard
            chat.user1 = preferences.string(forKey: "userid")!
            if let user2 = userInfo["idutilisateur"] as? String{chat.user2 = user2}

            print ("nibName", AppDelegate.getCurrentViewController()?.nibName)

            
            if (AppDelegate.getCurrentViewController()?.nibName == "Io3-hg-XMm-view-1Zs-1Z-Jms")
            {
                let vc = AppDelegate.getCurrentViewController() as! Controller_Chat
                vc.chat = chat
                vc.initialisation()
            }
            else
            {
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "chatController") as! Controller_Chat
                vc.chat = chat
                AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)
            }
            
    }
    
    
    func openScreen(userInfo: [AnyHashable: Any]){
        let type = userInfo["type"] as? String
        if (type == "visite_profil")
        {
            let Donnees = userInfo["donnees"] as? String
            self.openProfil(Donnees : Donnees!)
        }
            /*
        else if (type == "send_message")
            {
            let prenom = userInfo["prenom"] as? String
            let msg = prenom! + " a accepté votre invitation, retrouvez l'offre dans mes coupons, PS : N'oubliez pas d'appeler pour réserver."
                let alert = UIAlertController(title: "Mi", message: msg, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
                UIAlertAction in
                alert.dismiss(animated: true, completion: nil)
                self.openChat(userInfo : userInfo)
                }
            alert.addAction(okAction)
            }
 */
        else
            {
            self.openChat(userInfo : userInfo)
            }
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {

        print("userNotificationCenter")
        let userInfo = notification.request.content.userInfo
        let chatid = userInfo["idchat"] as? String

        
        if (AppDelegate.getCurrentViewController()?.nibName == "Io3-hg-XMm-view-1Zs-1Z-Jms")
        {
            let vc = AppDelegate.getCurrentViewController() as! Controller_Chat

            if (vc.chat.id == chatid)
            {
                return
            }
        }
        
        let text = userInfo["text"] as? String
        let TitleString = NSAttributedString(string: "MI", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 18), NSAttributedStringKey.foregroundColor : PrimaryColor])
        
        
        let alert = UIAlertController(title: "MI", message: "", preferredStyle: .alert)
        
        alert.setValue(TitleString, forKey: "attributedTitle")
        
        let textView = UITextView()
        textView.text = text
        textView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        textView.isUserInteractionEnabled = false
        textView.isEditable = false
        let controller = UIViewController()
        textView.frame = controller.view.frame
        controller.view.addSubview(textView)
        alert.setValue(controller, forKey: "contentViewController")
        
        let height: NSLayoutConstraint = NSLayoutConstraint(item: alert.view, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: (AppDelegate.getCurrentViewController()?.view.frame.height)! * 0.3)
        alert.view.addConstraint(height)
        

        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.openScreen(userInfo: userInfo)
        
        }
        alert.view.tintColor = PrimaryColor
        alert.addAction(okAction)
        AppDelegate.getCurrentViewController()?.present(alert, animated: true, completion: nil)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print("message recu 1")
        self.openScreen(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.newData)
    }

    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print("Message ID: \(userInfo.description)")
        print("message recu 2")
        print(userInfo)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        Messaging.messaging().appDidReceiveMessage(userInfo)
        print("message recu 3")
    }

    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")
        
        let preferences : UserDefaults = UserDefaults.standard

        if( preferences.string(forKey: "userid") ?? "" != "" ) {
            let params = ["type":"refresh_token", "userid":preferences.string(forKey: "userid") ?? "", "token":fcmToken] as [String : Any]
            do {
                let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
                opt.start { response in
                    if (response.error != nil) {
                        return
                    }
                    
                    print(response.text!)
                }
            } catch { }
        }
    }

    public func application(_ app: UIApplication, open url: URL, options: [UIApplicationOpenURLOptionsKey : Any] = [:]) -> Bool
    {
        return FBSDKApplicationDelegate.sharedInstance().application(app, open: url, options: options)
    }
    
    func application(received remoteMessage: MessagingRemoteMessage) {
        print("received remoteMessage %@", remoteMessage.appData)
    }

    
}



