//
//  Controller_InscriptionEtape1.swift
//  Timi_Test1
//
//  Created by Julien on 03/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import DatePickerDialog



class Controller_InscriptionEtape1: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate
    
{

    @IBOutlet weak var BtnFemme: UIButton!
    @IBOutlet weak var BtnHomme: UIButton!
    
    var imgProfil : UIImage? = nil
    @IBOutlet weak var imageViewSelfie: UIImageView!
    var imagePicker = UIImagePickerController()

    @IBOutlet weak var btnDateNaissance: UIButton!
    @IBOutlet weak var btnSexualité: UIButton!

    @IBOutlet weak var editPrenom: UITextField!
    @IBOutlet weak var editEmail: UITextField!
    @IBOutlet weak var editMotDePasse: UITextField!
    
    @IBOutlet weak var Checkbox_1: Checkbox!
    @IBOutlet weak var Checkbox_2: Checkbox!

    @IBOutlet weak var Cgu: UITextView!

    
    @IBOutlet weak var wView: UIView!

    @IBOutlet weak var BtnValider: UIButton!
    
    var prenom = "", email = "", pass = "", datenaissance = "", sexe = "", sexualite = ""
    
    let pickerSexeOptions = ["Homme","Femme"]
    let pickerSexualiteOptions = ["Hétérosexuel","Homosexuel","Bisexuel"]
    
    var preferences : UserDefaults = UserDefaults.standard
    var fimgProfil  = false
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var code : Int = 123456

    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.hideKeyboardWhenTappedAround()

        editPrenom.layer.borderColor = PrimaryColor.cgColor
        editPrenom.layer.borderWidth = 2.0
        editPrenom.layer.cornerRadius = 5.0

        btnDateNaissance.layer.borderColor = PrimaryColor.cgColor
        btnDateNaissance.layer.borderWidth = 2.0
        btnDateNaissance.layer.cornerRadius = 5.0

        btnSexualité.layer.borderColor = PrimaryColor.cgColor
        btnSexualité.layer.borderWidth = 2.0
        btnSexualité.layer.cornerRadius = 5.0

        
        editEmail.layer.borderColor = PrimaryColor.cgColor
        editEmail.layer.borderWidth = 2.0
        editEmail.layer.cornerRadius = 5.0

        editMotDePasse.layer.borderColor = PrimaryColor.cgColor
        editMotDePasse.layer.borderWidth = 2.0
        editMotDePasse.layer.cornerRadius = 5.0

        circularImage(photoImageView: imageViewSelfie)
        
        imageViewSelfie.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageProfilTapped(tapGestureRecognizer:))))
        
        
        sexe = pickerSexeOptions[0]
        self.sexualite = pickerSexualiteOptions[0]

        initialiserChampsFacebook()
        
        SetBtnSexe ()

        self.btnSexualité.setTitle("   " + self.sexualite, for: UIControlState.normal)
        self.btnSexualité.setTitleColor(UIColor.black, for: UIControlState.normal)

        
        

        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)

        let button = UIButton(frame: CGRect(x: 1, y: 15, width: 90, height: 40))
        button.setTitleColor(PrimaryColor,  for: .normal)
        
        button.setTitle("Retour", for: .normal)
        button.addTarget(self, action: #selector(Retour), for: .touchUpInside)
        view.addSubview(button)
        
        
        
        Checkbox_1.isChecked = false
        Checkbox_1.borderStyle = .square
        Checkbox_1.checkmarkStyle = .tick
        Checkbox_1.borderWidth = 1

        Checkbox_2.isChecked = false
        Checkbox_2.borderStyle = .square
        Checkbox_2.checkmarkStyle = .tick
        Checkbox_2.borderWidth = 1

        
        let wLargeText = "J’accepte <u>les C.G.U.</u> de Mi";
        Cgu.attributedText = wLargeText.htmlToAttributedString
        Cgu.textColor = PrimaryColor
        let fGuesture = UITapGestureRecognizer(target: self, action: #selector(Cgu(sender:)))
        Cgu.addGestureRecognizer(fGuesture)

    }
    
    @objc func Cgu(sender: AnyObject){
        UIApplication.shared.open(URL(string: "http://mi-app.fr/CGU-MI.pdf")!, options: [:], completionHandler: nil)
    }

    
    @objc func Retour () {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "controllerAccueilConnection") as! Controller_AccueilConnection
        self.present(vc, animated: true, completion: nil)
    }

    func initialiserChampsFacebook() {
        

        let FBID = preferences.string(forKey: "fbid")
        if(FBID == nil)
        {
            return
        }

        editPrenom.text = preferences.string(forKey: "fbprenom")
        editEmail.text = preferences.string(forKey: "fbemail")
        let fbgender = preferences.string(forKey: "fbgender")
        
        self.datenaissance = preferences.string(forKey: "fbdatenaissance")!
        self.btnDateNaissance.setTitle("   " + self.datenaissance, for: UIControlState.normal)
        self.btnDateNaissance.setTitleColor(.black, for: UIControlState.normal)

        
        self.sexe = pickerSexeOptions[1]
        if (fbgender == "male")
        {
            self.sexe = pickerSexeOptions[0]
        }
        self.sexualite = pickerSexualiteOptions[0]

        

        let wImgFB = "http://graph.facebook.com/" + preferences.string(forKey: "fbid")! + "/picture?type=normal"
        getImageFromWeb(wImgFB) { (image) in
            if let image = image {
                self.imgProfil = self.resizeImage(image: image, targetSize: CGSize(width: 500, height: 500))
                self.imageViewSelfie.image = self.imgProfil
                self.imageViewSelfie.backgroundColor = UIColor.white
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.hideKeyboardWhenTappedAround()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickAnnuler(_ sender: Any) {
        self.dismiss(animated: true)
    }

    
    @IBAction func HommeClick(_ sender: Any) {
        self.sexe = pickerSexeOptions[0]
        SetBtnSexe ()

    }
    
    
    @IBAction func FemmeClick(_ sender: Any) {
        self.sexe = pickerSexeOptions[1]
        SetBtnSexe ()
    }
    
    func SetBtnSexe ()
    {
        if (self.sexe == pickerSexeOptions[0])
        {
            
            BtnFemme.layer.backgroundColor = UIColor.white.cgColor
            BtnFemme.layer.borderColor = PrimaryColor.cgColor
            BtnFemme.layer.borderWidth = 2.0
            BtnFemme.layer.cornerRadius = 5.0
            BtnFemme.setTitleColor(PrimaryColor, for: .normal)
            
            BtnHomme.layer.backgroundColor = PrimaryColor.cgColor
            BtnHomme.layer.borderColor = PrimaryColor.cgColor
            BtnHomme.layer.borderWidth = 2.0
            BtnHomme.layer.cornerRadius = 5.0
            BtnHomme.setTitleColor(UIColor.white, for: .normal)

            
        }
        else
        {
            BtnFemme.layer.backgroundColor = PrimaryColor.cgColor
            BtnFemme.layer.borderColor = PrimaryColor.cgColor
            BtnFemme.layer.borderWidth = 2.0
            BtnFemme.layer.cornerRadius = 5.0
            BtnFemme.setTitleColor(UIColor.white, for: .normal)

            BtnHomme.layer.backgroundColor = UIColor.white.cgColor
            BtnHomme.layer.borderColor = PrimaryColor.cgColor
            BtnHomme.layer.borderWidth = 2.0
            BtnHomme.layer.cornerRadius = 5.0
            BtnHomme.setTitleColor(PrimaryColor, for: .normal)

        }
    }

    @IBAction func clickSexualite(_ sender: Any) {
    
 
        let alert = UIAlertController(title: "Sexualité",
                                      message: "",
                                      preferredStyle: UIAlertControllerStyle.alert)
        
        for i in pickerSexualiteOptions {
            alert.addAction(UIAlertAction(title: i, style: .default, handler: doSexualite))
        }
        self.present(alert, animated: true, completion: nil)
        
        
        
    }
    func doSexualite(action: UIAlertAction) {
        self.sexualite = action.title!
        self.btnSexualité.setTitle("   " + self.sexualite, for: UIControlState.normal)

    }
    
    @IBAction func clickDateNaissance(_ sender: Any) {
        
        var dateNaiss = Date()
        if (datenaissance != "")
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            dateNaiss =  dateFormatter.date(from: datenaissance)!
        }
        
        DatePickerDialog().show("Date de naissance", doneButtonTitle: "Ok", cancelButtonTitle: "Annuler", buttonColor : PrimaryColor, defaultDate: dateNaiss, maximumDate: Date(), datePickerMode: .date) {
            (date) -> Void in
            if( date != nil ) {
                if( Global().daysBetweenDate(startDate: date!, endDate: Date()) >= 18 ) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.datenaissance = dateFormatter.string(from:date!)
                    self.btnDateNaissance.setTitle("   " + self.datenaissance, for: UIControlState.normal)
                    self.btnDateNaissance.setTitleColor(.black, for: UIControlState.normal)
                } else {
                    self.afficherPopup(title: "Action impossible", message: "Vous devez avoir 18 ans pour utiliser Mi")
                }
            }
        }
    }
    
    

    @objc func imageProfilTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            imagePicker.delegate = self as? UIImagePickerControllerDelegate & UINavigationControllerDelegate
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        
        
        imgProfil = resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, targetSize: CGSize(width: 500, height: 500))

        imageViewSelfie.image = imgProfil
        imageViewSelfie.backgroundColor = UIColor.white

        picker.dismiss(animated: true, completion: nil)
        
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
    
    
    func circularImagevp(photoImageView: UIImageView?)
    {
        
        photoImageView!.layer.borderColor = PrimaryColor.cgColor
        photoImageView!.layer.borderWidth = 2
        photoImageView!.layer.cornerRadius = photoImageView!.frame.height/2
        photoImageView!.layer.masksToBounds = false
        photoImageView!.clipsToBounds = true

        let iwidth = photoImageView!.layer.bounds.width
        let wwidth = wView!.layer.bounds.width

        let x = (wwidth-iwidth)/2
        let yPosition = photoImageView!.frame.origin.y
        let height = photoImageView!.frame.height
        let width = photoImageView!.frame.width
        photoImageView!.frame = CGRect(x: x, y: yPosition, width: width, height: height)
        
    }
    
    
    func circularImage(photoImageView: UIImageView?)
    {
        photoImageView!.layer.frame = photoImageView!.layer.frame.insetBy(dx: 0, dy: 0)
        photoImageView!.layer.borderColor = PrimaryColor.cgColor
        photoImageView!.layer.borderWidth = 2
        photoImageView!.layer.cornerRadius = photoImageView!.frame.height/2
        photoImageView!.layer.masksToBounds = false
        photoImageView!.clipsToBounds = true
        photoImageView!.contentMode = UIViewContentMode.scaleAspectFill
    }


    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

            if let insEtape3 = segue.destination as? Controller_InscriptionEtape3 {
                insEtape3.imageProfil = imgProfil!
            }
    }
    

    @IBAction func ValiderClick(_ sender: Any) {
            prenom = editPrenom.text!
            email = editEmail.text!
            pass = editMotDePasse.text!

        
        
        
        
            if( prenom == "" || email == "" || pass == ""  || sexualite == "") {
                afficherPopup(title: "Action impossible",message: "Veuillez remplir tous les champs")
            } else if self.imgProfil == nil {
                afficherPopup(title: "Action impossible",message: "Veuillez choisir une photo de profil")
            } else if self.datenaissance == "" {
                afficherPopup(title: "Action impossible",message: "Veuillez renseigner votre date de naissance")
            } else if !isValidEmail(testStr: email) {
                afficherPopup(title: "Action impossible",message: "Votre email n'est pas valide")
            } else if pass.count < 6 {
                afficherPopup(title: "Action impossible",message: "Votre mot de passe est trop court")
            }
            else if !Checkbox_1.isChecked || !Checkbox_2.isChecked {
                afficherPopup(title: "Action impossible",message: "Les CGU et l'utilisatiuon de données doivent etre acceptées pour pouvoir continuer l'inscription.")
            }
            else {
                self.preferences.set(prenom, forKey: "inscription_prenom")
                self.preferences.set(email, forKey: "inscription_email")
                self.preferences.set(pass, forKey: "inscription_pass")
                self.preferences.set(datenaissance, forKey: "inscription_datenaissance")
                self.preferences.set(sexe, forKey: "inscription_sexe")
                self.preferences.set(sexualite, forKey: "inscription_sexualite")
                self.preferences.synchronize()
                sendinscriptionEtape1()
                }
        }
    
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
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

    //********************************
    //********************************
    //********************************
    

    func sendinscriptionEtape1() {
        print("etape 1")
        
        var params = [String : Any]()
        
        params["type"] = "sendinscription"
        params["prenom"] = preferences.string(forKey: "inscription_prenom") ?? ""
        params["email"] = preferences.string(forKey: "inscription_email") ?? ""
        params["pass"] = preferences.string(forKey: "inscription_pass") ?? ""
        params["datenaissance"] = preferences.string(forKey: "inscription_datenaissance") ?? ""
        params["sexe"] = preferences.string(forKey: "inscription_sexe") ?? ""
        params["sexualite"] = preferences.string(forKey: "inscription_sexualite") ?? ""
        params["symbole"] = preferences.string(forKey: "inscription_symbole") ?? ""
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
        
        alertController =  UIAlertController(title: nil, message: "Enregistrement\n1/2", preferredStyle: .alert)
        
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
                            
                            self.preferences.synchronize()
                            
                            self.alertController.dismiss(animated: true, completion: {
                                self.sendinscriptionEtape2()
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
        params["userid"] = preferences.string(forKey: "userid") ?? ""
        params["imageprofil"] = strBase64
        
        alertController =  UIAlertController(title: nil, message: "Enregistrement\n2/2", preferredStyle: .alert)
        
        self.present(alertController, animated: true, completion: nil)
        
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
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "Controller_Symboles") as! Controller_Symboles
                                
                                vc.wTitle = "Choisissez votre Symbole"
                                self.present(vc, animated: true, completion: nil)
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
    
    func afficherPopupFermable( title : String, message : String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            self.dismiss(animated: true)
        }
        
        alertController.addAction(okAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
    
    
    
}
