//
//  ViewController.swift
//  Timi_Test1
//
//  Created by Julien on 21/04/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import Crashlytics
import FirebaseMessaging

class Controller_SplashScreen: UIViewController {
    var preferences : UserDefaults = UserDefaults.standard
    var actif = "0"
    
    var indicator: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        indicator.frame = CGRect(x: 0.0, y: 0.0, width: 40.0, height: 40.0)
        indicator.center = view.center
        view.addSubview(indicator)
        indicator.bringSubview(toFront: view)
        //UIApplication.shared.isNetworkActivityIndicatorVisible = true
        checkDatas()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func checkDatas() {
        print("check datas")
        
        if preferences.object(forKey: "userid") != nil && preferences.object(forKey: "email") != nil {
            if( Global().isConnectedToNetwork() == true ) {
                print("checkConnection")
                checkConnection()
            } else {
                print("redirectionPageConnection A")
                redirectionPageConnection()
            }
        } else {
            print("redirectionPageConnection B")
            redirectionPageConnection()
        }
    }
    
    func checkConnection() {
        let params = ["type":"autologin", "userid":preferences.string(forKey: "userid") ?? "", "email":preferences.string(forKey: "email") ?? "", "token":Messaging.messaging().fcmToken ?? "null"] as [String : Any]
        
        do {
            indicator.startAnimating()
            self.indicator.hidesWhenStopped = true

            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.redirectionPageConnection()
                    return
                }
                
                print(response.text!)
                
                do {
                    DispatchQueue.main.async {
                        self.indicator.hidesWhenStopped = true
                        self.indicator.isHidden = true
                        self.indicator.stopAnimating()
                        
                    }

                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            print("success 1")
                            
                            let data = json["data"] as! Dictionary<String,AnyObject>
                            
                            self.actif = "1" // data["actif"] as! String
                            
                            if self.actif == "1" {
                                print("auto connection ok")
                                
                                self.preferences.set(data["photoprofil"], forKey: "photoprofil")
                                self.preferences.set(data["photoprofil_valide"], forKey: "photoprofil_valide")
                                self.preferences.set(data["prenom"], forKey: "prenom")
                                self.preferences.set(data["datenaissance"], forKey: "datenaissance")
                                self.preferences.set(data["sexe"], forKey: "sexe")
                                
                                self.preferences.set(data["bonus_apple"], forKey: "bonus_apple")
                                self.preferences.set(data["bonus_facebook"], forKey: "bonus_facebook")
                                self.preferences.set(data["bonus_facebook5s"], forKey: "bonus_facebook5s")

                                self.preferences.synchronize()
                                
                                self.logUser(userid: self.preferences.string(forKey: "userid") ?? "0", email: self.preferences.string(forKey: "email") ?? "0")
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
                                self.present(vc, animated: true, completion: nil)

                            
                            } else {
                                self.redirectionPageConnection()
                            }
                        } else {
                            print("Success pas 1")
                            
                            self.redirectionPageConnection()
                        }
                    } else {
                        self.redirectionPageConnection()
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.indicator.hidesWhenStopped = true
                    self.indicator.isHidden = true
                    self.indicator.stopAnimating()
                    
                    self.redirectionPageConnection()
                }
            }
        } catch {
            self.redirectionPageConnection()
        }
    }
    
    func logUser(userid: String, email: String) {
        Crashlytics.sharedInstance().setUserEmail(email)
        Crashlytics.sharedInstance().setUserIdentifier(userid)
    }

    func redirectionPageConnection() {
        self.indicator.hidesWhenStopped = true
        self.indicator.isHidden = true
        self.indicator.stopAnimating()
        
        /*let appDomain = Bundle.main.bundleIdentifier!
        UserDefaults.standard.removePersistentDomain(forName: appDomain)*/
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Main") as! Controller_Main
        self.present(vc, animated: true, completion: nil)
    }
}
