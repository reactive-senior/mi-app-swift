//
//  Controller_ModifierProfil.swift
//  Timi
//
//  Created by Julien on 20/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import MVHorizontalPicker
import DatePickerDialog

class Controller_ModifierProfil: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    
    @IBOutlet weak var pickerCouleurYeux: MVHorizontalPicker!
    @IBOutlet weak var pickerCouleurCheveux: MVHorizontalPicker!
    @IBOutlet weak var pickerLongueurCheveux: MVHorizontalPicker!
    @IBOutlet weak var pickerTaille: MVHorizontalPicker!
    @IBOutlet weak var pickerStyle: MVHorizontalPicker!
    @IBOutlet weak var pickerProfession: MVHorizontalPicker!
    
    @IBOutlet weak var btnDateNaissance: UIButton!
    @IBOutlet weak var btnSexualité: UIButton!

    @IBOutlet weak var img1: UIImageView!
    @IBOutlet weak var img2: UIImageView!
    @IBOutlet weak var img3: UIImageView!
    
    @IBOutlet weak var editFilm: UITextField!
    @IBOutlet weak var editMusique: UITextField!
    @IBOutlet weak var editDescription: UITextField!
    
    @IBOutlet weak var scrollView: UIScrollView!

    @IBOutlet weak var wView: UIView!

    @IBOutlet weak var BtnValider: UIButton!

    let pickerSexualiteOptions = ["Hétérosexuel","Homosexuel","Bisexuel"]
    
    
    var datenaissance = "", sexualite = ""

    
    var alertController =  UIAlertController(title: nil, message: "Enregistrement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var photo1 = false, photo2 = false, photo3 = false
    
    var photomodifie = 1
    
    var imagePicker = UIImagePickerController()
    
    var symbole = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        pickerCouleurYeux.titles = [ "Noir", "Marron", "Ambre", "Noisette", "Marron-vert", "Marron-bleu", "Vert", "Bleu", "Turquoise", "Gris", "Vairons" ]
        pickerCouleurCheveux.titles = [ "Noir", "Brun", "Aubrun", "Châtain", "Roux", "Blond", "Blanc", "Chauve", "Rouge", "Rose", "Vert", "Bleu", "Gris" ]
        pickerLongueurCheveux.titles = [ "Rasés","Courts", "Mi-longs", "Longs" ]
        pickerTaille.titles = [ "1,40 m", "1,45 m", "1,50 m", "1,55 m", "1,60 m", "1,65 m", "1,70 m", "1,75 m", "1,80 m", "1,85 m", "1,90 m", "1,95 m", "2,00 m", "2,05 m", "2,10 m" ]
        pickerStyle.titles = [ "Classique", "BCBG", "Sportif", "Skateur", "Fashion", "Grunge", "Bobo Chic", "Hipster", "Costume", "Kiff kiff" ]
        pickerProfession.titles = [ "Étudiant", "Employé", "Cadre", "Manager", "Ouvrier", "Indépendant", "Sans emploi" ]


        self.scrollView.contentSize = CGSize(width :320, height :900);

    
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        initialisation()
        
        circularImage(photoImageView: img1)
        circularImage(photoImageView: img2)
        circularImage(photoImageView: img3)
        
        BtnValider.layer.borderColor = PrimaryColor.cgColor
        BtnValider.layer.borderWidth = 2.0
        BtnValider.layer.cornerRadius = 5.0

        
        img1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(image1Tapped(tapGestureRecognizer:))))
        
        img2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(image2Tapped(tapGestureRecognizer:))))
        
        img3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(image3Tapped(tapGestureRecognizer:))))
        
        datenaissance = preferences.string(forKey: "inscription_datenaissance") ?? ""
        print("datenaissance" + datenaissance)
        self.btnDateNaissance.setTitle("   " + datenaissance, for: UIControlState.normal)
        self.btnDateNaissance.setTitleColor(PrimaryColor, for: UIControlState.normal)

        sexualite = preferences.string(forKey: "inscription_sexualite") ?? "Hétérosexuel"
        self.btnSexualité.setTitle("   " + self.sexualite, for: UIControlState.normal)

        editFilm.layer.borderColor = PrimaryColor.cgColor
        editFilm.layer.borderWidth = 2.0
        editFilm.layer.cornerRadius = 5.0

        editMusique.layer.borderColor = PrimaryColor.cgColor
        editMusique.layer.borderWidth = 2.0
        editMusique.layer.cornerRadius = 5.0

        editDescription.layer.borderColor = PrimaryColor.cgColor
        editDescription.layer.borderWidth = 2.0
        editDescription.layer.cornerRadius = 5.0

        alertController.view.addSubview(spinnerIndicator)
        let button = UIButton(frame: CGRect(x: 1, y: 15, width: 90, height: 40))
        button.setTitleColor(PrimaryColor,  for: .normal)
        
        button.setTitle("Retour", for: .normal)
        button.addTarget(self, action: #selector(Retour), for: .touchUpInside)
        view.addSubview(button)
        
        
        
    }
    
    @objc func Retour () {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
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
                                
// TED
                                
                                self.preferences.set(data["datenaissance"] as? String, forKey: "inscription_datenaissance")
                                self.preferences.set(data["sexualite"] as? String, forKey: "inscription_sexualite")

                            
                                self.preferences.set(data["couleuryeux"] as? String, forKey: "inscription_couleuryeux")
                                self.preferences.set(data["couleuryeux"] as? String, forKey: "inscription_couleuryeux")
                                self.preferences.set(data["couleurcheveux"] as? String, forKey: "inscription_couleurcheveux")
                                self.preferences.set(data["longueurcheveux"] as? String, forKey: "inscription_longueurcheveux")
                                self.preferences.set(data["physique"] as? String, forKey: "inscription_physique")
                                self.preferences.set(data["taille"] as? String, forKey: "inscription_taille")
                                self.preferences.set(data["style"] as? String, forKey: "inscription_style")
                                self.preferences.set(data["origine"] as? String, forKey: "inscription_origine")
                                self.preferences.set(data["religion"] as? String, forKey: "inscription_religion")
                                self.preferences.set(data["profession"] as? String, forKey: "inscription_profession")
                                self.preferences.set(data["fleurschocolats"] as? String, forKey: "inscription_fleurchocolat")
                                self.preferences.set(data["lieuprefere"] as? String, forKey: "inscription_rdv")

                                self.preferences.synchronize()
                                

                                self.pickerCouleurYeux.setSelectedItemIndex(selectedItemIndex: self.pickerCouleurYeux.titles.index(of: self.preferences.string(forKey: "inscription_couleuryeux") ?? "") ?? 0, animated: true)
                                self.pickerCouleurCheveux.setSelectedItemIndex(selectedItemIndex: self.pickerCouleurCheveux.titles.index(of: self.preferences.string(forKey: "inscription_couleurcheveux") ?? "") ?? 0, animated: true)
                                self.pickerLongueurCheveux.setSelectedItemIndex(selectedItemIndex: self.pickerLongueurCheveux.titles.index(of: self.preferences.string(forKey: "inscription_longueurcheveux") ?? "") ?? 0, animated: true)
                                self.pickerTaille.setSelectedItemIndex(selectedItemIndex: self.pickerTaille.titles.index(of: self.preferences.string(forKey: "inscription_taille") ?? "") ?? 0, animated: true)
                                self.pickerStyle.setSelectedItemIndex(selectedItemIndex: self.pickerStyle.titles.index(of: self.preferences.string(forKey: "inscription_style") ?? "") ?? 0, animated: true)
                                self.pickerProfession.setSelectedItemIndex(selectedItemIndex: self.pickerProfession.titles.index(of: self.preferences.string(forKey: "inscription_profession") ?? "") ?? 0, animated: true)

                                self.editFilm.text = data["filmprefere"] as? String
                                self.editMusique.text = data["musiqueprefere"] as? String
                                self.editDescription.text = data["description"] as? String
                                self.symbole = (data["symbole"] as? String)!
                                
                                let datenaissance = self.preferences.string(forKey: "inscription_datenaissance") ?? ""
                                self.btnDateNaissance.setTitle("   " + datenaissance, for: UIControlState.normal)
                               
                                let sexualite = self.preferences.string(forKey: "inscription_sexualite") ?? ""
                                self.btnSexualité.setTitle("   " + self.sexualite, for: UIControlState.normal)

                                
                                
                                if( data["photo1"] as! String != "" ) {
                                    self.photo1 = true

                                    if( data["photo1_valide"] as! String == "1" ) {
                                        self.getImageFromWeb(Global().url+"photos/"+(data["photo1"] as! String)) { (image) in
                                            if let image = image {
                                                self.img1.image = image
                                            }
                                        }
                                    } else {
                                        self.img1.image = UIImage(named: "hourglass")!
                                    }
                                }
                                
                                if( data["photo2"] as! String != "" ) {
                                    self.photo2 = true

                                    if( data["photo2_valide"] as! String == "1" ) {
                                        self.getImageFromWeb(Global().url+"photos/"+(data["photo2"] as! String)) { (image) in
                                            if let image = image {
                                                self.img2.image = image
                                            }
                                        }
                                    } else {
                                        self.img2.image = UIImage(named: "hourglass")!
                                    }
                                }
                                
                                if( data["photo3"] as! String != "" ) {
                                    self.photo3 = true

                                    if( data["photo3_valide"] as! String == "1" ) {
                                        self.getImageFromWeb(Global().url+"photos/"+(data["photo3"] as! String)) { (image) in
                                            if let image = image {
                                                self.img3.image = image
                                            }
                                        }
                                    } else {
                                        self.img3.image = UIImage(named: "hourglass")!
                                    }
                                }
                            })
                        }
                    }
                } catch { }
            }
        } catch { }
    }
    
    @objc func image1Tapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        self.photomodifie = 1
        
        modifierPhotoSupplementaire()
    }
    
    @objc func image2Tapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if( !photo1 ) {
            self.photomodifie = 1
        } else {
            self.photomodifie = 2
        }
        
        modifierPhotoSupplementaire()
    }
    
    @objc func image3Tapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if( !photo1 ) {
            self.photomodifie = 1
        } else if( !photo2 ) {
            self.photomodifie = 2
        } else {
            self.photomodifie = 3
        }
        
        modifierPhotoSupplementaire()
    }
    
    func modifierPhotoSupplementaire() {
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        if( Global().isConnectedToNetwork() == true ) {
            let img = resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, targetSize: CGSize(width: 500, height: 500))
            
            self.uploadPhoto(img: img)
        } else {
            self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadPhoto( img: UIImage ) {
        let imageData:NSData = UIImagePNGRepresentation(img)! as NSData
        
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let params = ["type":"sendimagesupp", "userid":preferences.string(forKey: "userid") ?? "", "photomodifie":String(photomodifie), "imagestring":strBase64] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print(response.text!)
                
                self.afficherPopup(title: "Photo envoyée", message: "Veuillez attendre sa validation")
                
                self.initialisation()
            }
        } catch { }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    @IBAction func clickEnregistrer(_ sender: Any) {
        
        print("clickEnregistrer")
        if( Global().isConnectedToNetwork() == true ) {
            print("Call enregistrerDonnees")
            self.enregistrerDonnees()
        } else {
            print("Not isConnectedToNetwork ")
            self.afficherPopup(title : "Action impossible", message : "Aucune connection internet")
        }
    }
    
    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true

    }
    
    
    func enregistrerDonnees() {
    
        print("enregistrerDonnees")

        self.preferences.set(datenaissance, forKey: "inscription_datenaissance")
        self.preferences.set(sexualite, forKey: "inscription_sexualite")
        self.preferences.synchronize()

        self.present(alertController, animated: true, completion: nil)
        let params = ["type":"modifierprofil_ios", "userid":preferences.string(forKey: "userid") ?? "", "filmprefere":editFilm.text!, "musiqueprefere": editMusique.text!, "description":editDescription.text!, "symbole":symbole,"datenaissance":datenaissance,"sexualite":sexualite] as [String : Any]
        
        let wCouleurYeux = pickerCouleurYeux.titles[pickerCouleurYeux.selectedItemIndex]
        let wCouleurCheveux = pickerCouleurCheveux.titles[pickerCouleurCheveux.selectedItemIndex]
        let wLongueurCheveux = pickerLongueurCheveux.titles[pickerLongueurCheveux.selectedItemIndex]
        
        let paramsn = ["type":"modifierprofil_iOs_V2", "userid":preferences.string(forKey: "userid") ?? "","filmprefere":editFilm.text!,"musiqueprefere":editMusique.text!,"description":editDescription.text!,"symbole":symbole,"couleuryeux":wCouleurYeux,"couleurcheveux":wCouleurCheveux,"longueurcheveux":wLongueurCheveux,"physique":"","taille":pickerTaille.titles[pickerTaille.selectedItemIndex],"style":pickerStyle.titles[pickerStyle.selectedItemIndex],"origine":"","religion":"","profession":pickerProfession.titles[pickerProfession.selectedItemIndex],"fleurschocolats":"","lieuprefere":"","datenaissance":datenaissance,"sexualite":sexualite] as [String : Any]

        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: paramsn)
            opt.start { response in
                if (response.error != nil) {
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                    
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.alertController.dismiss(animated: true, completion: {
//                                self.performSegue(withIdentifier: "ModifProfil2", sender: self)

                              self.afficherPopupFermable(title : "Profil modifié", message : "")
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
                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
            })
        }
        
    }
    
    func afficherPopup( title : String, message : String ) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func afficherPopupFermable( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            //self.dismiss(animated: true)
            
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func circularImage(photoImageView: UIImageView?)
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
    func circularImagevp(photoImageView: UIImageView?)
    {
        
        
        photoImageView!.layer.frame = photoImageView!.layer.frame.insetBy(dx: 0, dy: 0)
        photoImageView!.layer.borderColor = UIColor.white.cgColor
        photoImageView!.layer.borderWidth = 2
        photoImageView!.layer.cornerRadius = photoImageView!.frame.height/2
        photoImageView!.layer.masksToBounds = false
        photoImageView!.clipsToBounds = true
        photoImageView!.contentMode = UIViewContentMode.scaleAspectFill
    }
    
    func getImageFromWeb(_ urlString: String, closure: @escaping (UIImage?) -> ()) {
        guard let url = URL(string: urlString) else {
            return closure(nil)
        }
        let task = URLSession(configuration: .default).dataTask(with: url) { (data, response, error) in
            guard error == nil else {
                print("error: \(String(describing: error))")
                return closure(nil)
            }
            guard response != nil else {
                print("no response")
                return closure(nil)
            }
            guard data != nil else {
                print("no data")
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
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
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
                if( self.daysBetweenDate(startDate: date!, endDate: Date()) >= 18 ) {
                    let dateFormatter = DateFormatter()
                    dateFormatter.dateFormat = "yyyy-MM-dd"
                    self.datenaissance = dateFormatter.string(from:date!)
                    self.btnDateNaissance.setTitle("   " + self.datenaissance, for: UIControlState.normal)
                    self.btnDateNaissance.setTitleColor(PrimaryColor, for: UIControlState.normal)
                    
                } else {
                    self.afficherPopup(title: "Action impossible", message: "Vous devez avoir 18 ans pour utiliser Mi")
                }
            }
        }
    }
    
    func daysBetweenDate(startDate: Date, endDate: Date) -> Int {
        
        let calendar = NSCalendar.current
        
        let components = calendar.dateComponents([.year], from: startDate, to: endDate)
        
        return components.year!
    }
    
    
    
    
    
    
}
