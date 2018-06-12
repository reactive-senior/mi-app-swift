

import UIKit
import SwiftHTTP


class Controller_AddContact: UIViewController {
    var preferences : UserDefaults = UserDefaults.standard

    @IBOutlet weak var ViewDemandechat: UIView!
    @IBOutlet weak var btnDC_Attn: UIButton!
    @IBOutlet weak var btnDC_Go: UIButton!
    
    
    @IBOutlet weak var ViewBonus: UIView!
    @IBOutlet weak var ViewBonus2: UIView!
    @IBOutlet weak var ViewBonus3: UIView!
    
    @IBOutlet weak var lContactFB_Like: UILabel!
    @IBOutlet weak var lContactFB_5stars: UILabel!
    @IBOutlet weak var lContactStore_5stars: UILabel!
    @IBOutlet weak var lContactMail: UILabel!
    
    @IBOutlet weak var iContactFB_Like: UIImageView!
    @IBOutlet weak var iContactFB_5stars: UIImageView!
    @IBOutlet weak var iContactStore_5stars: UIImageView!
    @IBOutlet weak var iContactMail: UIImageView!

    @IBOutlet weak var tContactMail: UITextField!

    
    
    var bonus_apple = "0"
    var bonus_facebook = "0"
    var bonus_facebook5s = "0"

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        btnDC_Attn.layer.borderColor = UIColor.lightGray.cgColor
        btnDC_Attn.layer.borderWidth = 2.0
        btnDC_Attn.layer.cornerRadius = 5.0

        btnDC_Go.layer.borderColor = UIColor.lightGray.cgColor
        btnDC_Go.layer.borderWidth = 2.0
        btnDC_Go.layer.cornerRadius = 5.0

        
        tContactMail.layer.borderColor = PrimaryColor.cgColor
        tContactMail.layer.borderWidth = 2.0
        tContactMail.layer.cornerRadius = 5.0

//        self.hideKeyboardWhenTappedAround()

        initialisation();

        ViewBonus.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnBack(tapGestureRecognizer:))))
        
        ViewDemandechat.isHidden = true
        ViewBonus.isHidden = true
        afficherdemandechat()

        print ("bonus_apple" , bonus_apple)
        print ("bonus_facebook" , bonus_apple)
        print ("bonus_facebook5s" , bonus_apple)

        lContactMail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnContactMail(tapGestureRecognizer:))))
        iContactMail.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(btnContactMail(tapGestureRecognizer:))))
        
    }
    

    @objc func textFieldShouldReturn(_ textField: UITextField) -> Bool
    {
        print ("textFieldShouldReturn" )
        
        DispatchQueue.main.async(){ textField.resignFirstResponder() }
            return true;

    }


    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    //*********************************************
    //*********************************************
    //*********************************************
    
    @IBAction func btnAttn(sender : UIButton){
        print("btnAttn")
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func btnGo(sender : UIButton){
        print("btnGo")
        afficherdemandechat()
        afficherViewBonus()
    }
    
    @objc func btnContactFB_Like(tapGestureRecognizer: UITapGestureRecognizer){

        UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/miapplicationmobile/")! as URL)
        let params = ["type":"activer_bonusfacebook", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                print(response.text!)
                self.preferences.set("0", forKey: "bonus_facebook")
                self.preferences.synchronize()
                
                self.afficherPopupClose(title : "Bravo !", message : "Vous avez gagné 2 contacts\nsupplémentaires pour aujourd'hui !")

            }
        } catch { }
    }
    
    @objc func btnContactFB_5stars(tapGestureRecognizer: UITapGestureRecognizer){
        
        UIApplication.shared.openURL(NSURL(string: "https://www.facebook.com/pg/miapplicationmobile/reviews/?ref=page_internal")! as URL)
        let params = ["type":"activer_bonusfacebook5s", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                print(response.text!)
                self.preferences.set("0", forKey: "bonus_facebook5s")
                self.preferences.synchronize()
                self.dismiss(animated: true, completion: nil)
                
                self.afficherPopupClose(title : "Bravo !", message : "Vous avez gagné 2 contacts\nsupplémentaires pour aujourd'hui !")

            }
        } catch { }
    }
    
    
    
    @objc func btnContactStore_5stars(tapGestureRecognizer: UITapGestureRecognizer){
        UIApplication.shared.openURL(NSURL(string: "https://itunes.apple.com/fr/app/mi-fit/id1279238907")! as URL)
        
        let params = ["type":"activer_bonusapple", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                print(response.text!)
                self.preferences.set("0", forKey: "bonus_apple")
                self.preferences.synchronize()
                self.dismiss(animated: true, completion: nil)
                
                self.afficherPopupClose(title : "Bravo !", message : "Vous avez gagné 2 contacts\nsupplémentaires pour aujourd'hui !")

            }
        } catch { }    }
    
    @objc func btnContactMail(tapGestureRecognizer: UITapGestureRecognizer){
        
        
        if !isValidEmail(testStr: tContactMail.text!) {
            afficherPopup(title: "Action impossible",message: "l'email n'est pas valide")
        }
        else
        {
            let params = ["type":"Parrainage", "userid":preferences.string(forKey: "userid") ?? "", "email": tContactMail.text!] as [String : Any]
            do {
                
                let opt = try HTTP.POST(Global().url+"gestion_parrainages.php", parameters: params)
                opt.start { response in
                    if (response.error != nil) {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue,\nveuillez réessayer.")
                        return
                    }
                    print(response.text!)

                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                        if !json.isEmpty
                            {
                                if ( json["success"] as! Int == 1 ) {
                                    self.afficherPopupClose(title : "Bravo !", message : "Maintenent il faut attendre\nl'inscription de votre ami")
                                    }
                                else if ( json["success"] as! Int == 2 ) {
                                    self.afficherPopup(title : "Action impossible", message : "Email d'ami déja parrainé")

                                }
                                else if ( json["success"] as! Int == 3 ) {
                                    self.afficherPopup(title : "Action impossible", message : "Ami déja inscrit sur MI")
                                    
                                }
                            }
                        else
                            {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue,\nveuillez réessayer..")
                            }
                        }
                    catch
                        {
                            print("json error: \(error.localizedDescription)")

                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue,\nveuillez réessayer...")
                        }
                    
                }
            } catch {
                print("post error: \(error.localizedDescription)")

            }    }

    }
    
    
    @objc func btnBack (tapGestureRecognizer: UITapGestureRecognizer) {
        dismiss(animated: true, completion: nil)
    }

    func afficherdemandechat() {
        
        DispatchQueue.main.async(){
            self.ViewDemandechat.isHidden = !self.ViewDemandechat.isHidden
            if (!self.ViewDemandechat.isHidden)
            {
                print("ViewDemandechat VISIBLE")
                
            }
            else
            {
                print("ViewDemandechat HiDE")
            }
        }
    }
    
    
    func afficherViewBonus() {
        
        DispatchQueue.main.async(){
            
        self.ViewBonus.isHidden = !self.ViewBonus.isHidden
        if (!self.ViewBonus.isHidden)
            {
                print("ViewBonus VISIBLE")
            }
            else
            {
                print("ViewBonus HiDE")
            }
        }
        
    }
    
    
    
    
    //*********************************************
    //*********************************************
    //*********************************************

    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }

    func afficherPopup( title : String, message : String) {
        
        DispatchQueue.main.async(){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)

        }
        
        }
    
    func afficherPopupClose( title : String, message : String) {
        
        DispatchQueue.main.async(){
            
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)

        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    
    //*********************************************
    //*********************************************
    //*********************************************
    
    func initialisation() {
        let params = ["type":"recupererinfos", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            
            print("Log " +  Global().url+"gestion_user.php");
            
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            DispatchQueue.main.async(execute: {
                                let data = json["data"] as! Dictionary<String,AnyObject>
                                
                                print("data", data.description)
                                // TED
                                self.preferences.set(data["bonus_apple"], forKey: "bonus_apple")
                                self.preferences.set(data["bonus_facebook"], forKey: "bonus_facebook")
                                self.preferences.set(data["bonus_facebook5s"], forKey: "bonus_facebook5s")
                                self.preferences.synchronize()
                                
                                self.bonus_apple = data["bonus_apple"] as! String
                                self.bonus_facebook = data["bonus_facebook"] as! String
                                self.bonus_facebook5s = data["bonus_facebook5s"] as! String

                                if (self.bonus_apple == "0")
                                {
                                    self.lContactStore_5stars.isHidden = true
                                    self.iContactStore_5stars.isHidden = true
                                }
                                else
                                {
                                    self.lContactStore_5stars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactStore_5stars(tapGestureRecognizer:))))
                                    self.iContactStore_5stars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactStore_5stars(tapGestureRecognizer:))))
                                    
                                }
                                
                                if (self.bonus_facebook == "0")
                                {
                                    self.lContactFB_Like.isHidden = true
                                    self.iContactFB_Like.isHidden = true
                                }
                                else
                                {
                                    self.lContactFB_Like.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactFB_Like(tapGestureRecognizer:))))
                                    self.iContactFB_Like.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactFB_Like(tapGestureRecognizer:))))
                                }
                                
                                if (self.bonus_facebook5s == "0")
                                {
                                    self.lContactFB_5stars.isHidden = true
                                    self.iContactFB_5stars.isHidden = true
                                }
                                else
                                {
                                    self.lContactFB_5stars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactFB_5stars(tapGestureRecognizer:))))
                                    self.iContactFB_5stars.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.btnContactFB_5stars(tapGestureRecognizer:))))
                                }
                                

                                
                                
                                
                            })
                        }
                    }
                } catch { }
            }
        } catch { }
    }
    
}

