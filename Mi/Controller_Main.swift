//
//  Controller_Main.swift
//  Mi
//
//  Created by TED on 14/02/2018.
//  Copyright © 2018 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

import FacebookCore
import FacebookLogin

import FBSDKCoreKit
import FBSDKLoginKit

import FirebaseMessaging

import Crashlytics


class Controller_Main: UIViewController {

    var preferences : UserDefaults = UserDefaults.standard
    
    @IBOutlet weak var BtnFB: UIButton!
    var dict : [String : AnyObject]!
    
    var code : Int = 123456

    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    var imgProfil : UIImage? = nil

    override func viewDidLoad() {
        super.viewDidLoad()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        Crashlytics.sharedInstance().crash()

    }
    
    func afficherPopup( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }

    //*******************************************
    //*************  M  A  I  L  ****************
    //*******************************************
    
    @IBAction func MailClick(_ sender: Any)
    {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "controllerAccueilConnection") as! Controller_AccueilConnection
        self.present(vc, animated: true, completion: nil)
    }
    
    
    //*******************************************
    //*******************************************
    //*******************************************
    
    //*******************************************
    //**********  F A C E B O O K  **************
    //*******************************************

    @IBAction func FBClick(_ sender: Any) {
        
        let loginManager = LoginManager()
        loginManager.logIn([ .publicProfile, .email, .userFriends, .custom("user_birthday") ], viewController: self) { loginResult in
            switch loginResult {
            case .failed(let error):
                let wErr = "Veuillez réessayer " + error.localizedDescription
                self.afficherPopup(title : "Connection à Facebook impossible (A)" , message :wErr)
            case .cancelled:
                print("User cancelled login.")
            case .success(_, _, _):
                print("Logged in!")
                
                FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, email, gender, birthday"]).start(completionHandler: { (connection, result, error) -> Void in
                    if (error == nil){

                        print(connection)
                        print(error)

                        
                        let fbDetails = result as! NSDictionary
                        print(fbDetails)
                        
                        if( fbDetails["id"] as! String != "" ) {
                            self.preferences.set(fbDetails["id"] as! String, forKey: "fbid")
                            self.preferences.set(fbDetails["first_name"] as! String, forKey: "fbprenom")
                            self.preferences.set(fbDetails["email"] as! String, forKey: "fbemail")
                            self.preferences.set(fbDetails["gender"] as! String, forKey: "fbgender")

                            
                            let wfbBd = fbDetails["birthday"] as! String
                            var fbdateNaissance = Date()
                            if (wfbBd.count == 10)
                            {
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "MM/dd/yyyy"
                                fbdateNaissance = dateFormatter.date(from: wfbBd)!
                            }
                            
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            let StrDatenaissance = dateFormatter.string(from:fbdateNaissance)
                            
                            self.preferences.set(StrDatenaissance, forKey: "fbdatenaissance")

                            
                            
                            print("birthday" ,wfbBd , " " , StrDatenaissance)
                            
                            
                            self.preferences.synchronize()
                            
                            if( Global().isConnectedToNetwork() == true ) {
                                self.checkFacebookConnection()
                            } else {
                                self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
                            }
                        }
                    }else{
                        
                        let wErr = "Veuillez réessayer" + error.debugDescription + " ///--> " + (error?.localizedDescription)!
                        
                        self.afficherPopup(title : "Connection à Facebook impossible (B)" , message : wErr)
                    }
                })
                
                
            }
        }
        
    }
    
    // 1946509288699168
    func checkFacebookConnection() {
        
        if let accessToken = FBSDKAccessToken.current(){

        
        print("connection facebook requête")
        
        let params = ["type":"loginfb",
                      "fbid":preferences.string(forKey: "fbid") ?? "",
                      "fbemail":preferences.string(forKey: "fbemail") ?? "",
                      "token":Messaging.messaging().fcmToken ?? "null"] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    return
                }
                print(response.text!)
                print("xxx")
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        print("xxx2")

                        if json["success"] as! Int == 1 {
                            
                            print("success 1")
                            let data = json["data"] as! Dictionary<String,AnyObject>
                            self.preferences.set(data["id"], forKey: "userid")
                            self.preferences.set(data["photoprofil"], forKey: "photoprofil")
                            self.preferences.set(data["photoprofil_valide"], forKey: "photoprofil_valide")
                            self.preferences.set(data["prenom"], forKey: "prenom")
                            self.preferences.set(data["datenaissance"], forKey: "datenaissance")
                            self.preferences.set(data["email"], forKey: "email")
                            self.preferences.set(data["sexe"], forKey: "sexe")
                            self.preferences.set(data["bonus_apple"], forKey: "bonus_apple")
                            self.preferences.set(data["bonus_facebook"], forKey: "bonus_facebook")
                            self.preferences.set(data["bonus_facebook5s"], forKey: "bonus_facebook5s")
                            self.preferences.synchronize()
                            
                            DispatchQueue.main.async(execute: {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
                                self.present(vc, animated: true, completion: nil)
                            })
                        }
                        else if json["success"] as! Int == 0
                        {
                            DispatchQueue.main.async(execute: {
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "inscriptionEtape1") as! Controller_InscriptionEtape1
                                self.present(vc, animated: true, completion: nil)
                            })

                            
                            
                            /*
                            let pfbdatenaissance = self.preferences.string(forKey: "fbdatenaissance") ?? ""
                            var fbdateNaissance = Date()
                            let dateFormatter = DateFormatter()
                            dateFormatter.dateFormat = "yyyy-MM-dd"
                            fbdateNaissance = dateFormatter.date(from: pfbdatenaissance)!

                            if( Global().daysBetweenDate(startDate: fbdateNaissance, endDate: Date()) < 18 )
                            {
                                DispatchQueue.main.async(execute: {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "inscriptionEtape1") as! Controller_InscriptionEtape1
                                    self.present(vc, animated: true, completion: nil)
                                })
                            }
                            else {
                                self.sendinscriptionEtape1()
                                
                            }
                            */
                        }
                        else
                        {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        }
                    }
                    else
                    {
                        print("bug 3")
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    }
                } catch {
                    print("bug 2")
                    print("json error: \(error.localizedDescription)")
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                }
            }
        } catch {
            print("bug 1")
            
            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
        }
    }
    

    }
    

    func sendinscriptionEtape1() {
        print("etape 1")
        let pickerSexeOptions = ["Homme","Femme"]
        let pickerSexualiteOptions = ["Hétérosexuel","Homosexuel","Bisexuel"]

        let fbgender = preferences.string(forKey: "fbgender")
        var params = [String : Any]()
        var sexe = pickerSexeOptions[1]
        if (fbgender == "male")
        {
            sexe = pickerSexeOptions[0]
        }
        let sexualite = pickerSexualiteOptions[0]

        params["type"] = "sendinscription"
        params["prenom"] = preferences.string(forKey: "fbprenom") ?? ""
        params["email"] = preferences.string(forKey: "fbemail") ?? ""
        params["pass"] = preferences.string(forKey: "inscription_pass") ?? ""
        params["datenaissance"] = preferences.string(forKey: "fbdatenaissance") ?? ""
        
        params["sexe"] = sexe
        params["sexualite"] = sexualite
        params["symbole"] = preferences.string(forKey: "inscription_symbole") ?? "coeur"
        params["code"] = String(code)
        params["couleuryeux"] = preferences.string(forKey: "inscription_couleuryeux") ?? ""
        params["couleurcheveux"] = preferences.string(forKey: "inscription_couleurcheveux") ?? ""
        params["longueurcheveux"] = preferences.string(forKey: "inscription_longueurcheveux") ?? ""
        params["physique"] = preferences.string(forKey: "inscription_physique") ?? ""
        params["taille"] = preferences.string(forKey: "inscription_taille") ?? ""
        params["style"] = preferences.string(forKey: "inscription_style") ?? ""
        params["origine"] = preferences.string(forKey: "inscription_origine") ?? ""
        params["religion"] = preferences.string(forKey: "inscription_religion") ?? ""
        params["profession"] = preferences.string(forKey: "inscription_profession") ?? ""
        params["fleurschocolats"] = preferences.string(forKey: "inscription_fleurchocolat") ?? ""
        params["filmprefere"] = ""
        params["musiqueprefere"] = ""
        params["lieuprefere"] = preferences.string(forKey: "inscription_rdv") ?? ""
        params["fbid"] = preferences.string(forKey: "fbid") ?? ""
        
        alertController =  UIAlertController(title: nil, message: "Enregistrement 1/2", preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    return
                }
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    print ("response" , json.debugDescription)
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            self.preferences.set(json["userid"], forKey: "userid")
                            self.preferences.set(params["prenom"] , forKey: "inscription_prenom")
                            self.preferences.set(params["email"] , forKey: "inscription_email")
                            self.preferences.set(params["pass"] , forKey: "inscription_pass")
                            self.preferences.set(params["datenaissance"], forKey: "inscription_datenaissance")
                            self.preferences.set(sexe, forKey: "inscription_sexe")
                            self.preferences.set(sexualite, forKey: "inscription_sexualite")
                            self.preferences.set(params["prenom"] , forKey: "prenom")
                            self.preferences.set(params["email"] , forKey: "email")
                            self.preferences.set(params["pass"] , forKey: "inscription_pass")
                            self.preferences.set(params["datenaissance"], forKey: "datenaissance")
                            self.preferences.set(sexe, forKey: "sexe")
                            self.preferences.set(sexualite, forKey: "sexualite")
                            self.preferences.synchronize()
                            print("synchronize")

                            self.alertController.dismiss(animated: true, completion: {
                                print("img")
                                let wImgFB = "http://graph.facebook.com/" + self.preferences.string(forKey: "fbid")! + "/picture?type=normal"
                                self.getImageFromWeb(wImgFB) { (image) in
                                    if let image = image {
                                        print("img OK")
                                        self.imgProfil = self.resizeImage(image: image, targetSize: CGSize(width: 500, height: 500))
                                        self.sendinscriptionEtape2()
                                        return
                                    }
                                    print("img pageAccueil")
                                    DispatchQueue.main.async(execute: {
                                        let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
                                        self.present(vc, animated: true, completion: nil)
                                    })
                                }
                            })
                        } else if ( json["success"] as! Int == 2 ) {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Votre adresse email est déjà utilisée")
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible ", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                }
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
            })
        }
    }
    
    
    func sendinscriptionEtape2() {
        print("etape 2")
        
        let imageData:NSData = UIImagePNGRepresentation(imgProfil!)! as NSData
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        var params = [String : Any]()
        
        params["type"] = "sendimageprofil"
        params["userid"] = self.preferences.string(forKey: "userid") ?? ""
        params["imageprofil"] = strBase64
        
        self.alertController =  UIAlertController(title: nil, message: "Enregistrement 2/2", preferredStyle: .alert)
        
        self.present(self.alertController, animated: true, completion: nil)
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    })
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            self.alertController.dismiss(animated: true, completion: {
                                DispatchQueue.main.async(execute: {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "pageAccueil") as! Controller_Accueil
                                    self.present(vc, animated: true, completion: nil)
                                })
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    } else {
                        
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        })
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                }
            }
        } catch {
            self.alertController.dismiss(animated: true, completion: {
                self.alertController.dismiss(animated: true, completion: {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                })
            })
        }
    }
    
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                //print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                //print("no response")
                return closure(nil)
            }
            guard data != nil else {
                //print("no data")
                return closure(nil)
            }
            DispatchQueue.main.async {
                closure(UIImage(data: data!))
            }
        }; task.resume()
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size
        
        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height
        
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)
        
        print("ns" +  String(describing: newSize.width) + " x " + String(describing: newSize.height))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
}
    


