//
//  Controller_Profil.swift
//  Timi
//
//  Created by Julien on 03/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_Profil: UIViewController , UITableViewDataSource, UITableViewDelegate
{
    @IBOutlet weak var imageProfil: UIImageView!
    @IBOutlet weak var imageCouverture: UIImageView!

    @IBOutlet weak var labelPrenomAge: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    
    @IBOutlet weak var labelAucunePhoto: UILabel!
    
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    @IBOutlet weak var image3: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var imageLieu: UIImageView!

    var CatImgArray = ["cat_bar", "cat_restaurant", "cat_sorties"]

    
    var utilisateur = Utilisateur()
   
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var AccueilRecherche : Controller_AccueilRecherche? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        DispatchQueue.main.async {
            self.labelPrenomAge.text = self.utilisateur.prenom+" , \(self.utilisateur.ageuser)"
            self.labelDescription.text = self.utilisateur.descr
            
            self.circularImage(photoImageView: self.imageProfil)
            
            self.circularImage(photoImageView: self.image1)
            self.circularImage(photoImageView: self.image2)
            self.circularImage(photoImageView: self.image3)
            
            
            self.alimProfil();
        }
        
        DispatchQueue.main.async(){
            self.visiteProfil()
        }
        
        
        if( utilisateur.photoprofil == "" ) {
            if( utilisateur.sexe == "Homme" ) {
                self.gererImageProfil( img: UIImage(named: "boy")! )
            } else {
                self.gererImageProfil( img: UIImage(named: "girl")! )
            }
        } else {
            if( utilisateur.photoprofil_valide == "1" ) {
                getImageFromWeb(Global().url+"photo_profil/"+utilisateur.photoprofil) { (image) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.gererImageProfil( img: image )
                        }
                    }
                }
            } else {
                self.gererImageProfil(img: UIImage(named: "hourglass")!)
            }
        }
        
        if( utilisateur.photo1 == "" ) {
            DispatchQueue.main.async(){
                self.image1.isHidden = true
            }
        } else {
            if( utilisateur.photo1_valide == "1" ) {
                getImageFromWeb(Global().url+"photos/"+utilisateur.photo1) { (image) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image1.image = image
                        }
                    }
                }
            } else {
                self.image1.image = UIImage(named: "hourglass")!
            }
        }
        
        if( utilisateur.photo2 == "" ) {
            DispatchQueue.main.async(){
                self.image2.isHidden = true
            }
        } else {
            if( utilisateur.photo2_valide == "1" ) {
                getImageFromWeb(Global().url+"photos/"+utilisateur.photo2) { (image) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image2.image = image
                        }
                    }
                }
            } else {
                self.image2.image = UIImage(named: "hourglass")!
            }
        }
        
        if( utilisateur.photo3 == "" ) {
            DispatchQueue.main.async(){
                self.image3.isHidden = true
            }
        } else {
            if( utilisateur.photo3_valide == "1" ) {
                getImageFromWeb(Global().url+"photos/"+utilisateur.photo3) { (image) in
                    if let image = image {
                        DispatchQueue.main.async {
                            self.image3.image = image
                        }
                    }
                }
            } else {
                self.image3.image = UIImage(named: "hourglass")!
            }
        }
        
        if utilisateur.photo1 == "" && utilisateur.photo2 == "" && utilisateur.photo3 == "" {
            DispatchQueue.main.async(){
                self.labelAucunePhoto.text = "Aucune photo supplémentaire !"
            }
        }
        
        imageProfil.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:))))
        image1.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:))))
        image2.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:))))
        image3.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:))))
        
        var lieu_cat = utilisateur.lieu_cat
        if (lieu_cat == "0" || lieu_cat == "" )
        {
            lieu_cat = "1"
        }
        let icat = Int(lieu_cat)! - 1
        let CatImg = CatImgArray[icat]
        imageLieu.image = UIImage(named: CatImg)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let imageView = tapGestureRecognizer.view as! UIImageView
        let newImageView = UIImageView(image: imageView.image)
        newImageView.frame = UIScreen.main.bounds
        newImageView.backgroundColor = .black
        newImageView.contentMode = .scaleAspectFit
        newImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissFullscreenImage))
        newImageView.addGestureRecognizer(tap)
        self.view.addSubview(newImageView)
        self.navigationController?.isNavigationBarHidden = true
        self.tabBarController?.tabBar.isHidden = true
    }
    
    @objc func dismissFullscreenImage(_ sender: UITapGestureRecognizer) {
        self.navigationController?.isNavigationBarHidden = false
        self.tabBarController?.tabBar.isHidden = false
        sender.view?.removeFromSuperview()
    }
    
    func visiteProfil() {
        let params = ["type":"visite_profil", "userid":preferences.string(forKey: "userid") ?? "", "autreid":utilisateur.id] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    print(response)
                    return
                }
            }
        } catch { }
    }

    func alimProfil() {

        
        /*
        labelInformation1.text = "Sexualité"
        labelValeur1.text = self.utilisateur.sexualite
        labelInformation2.text = "Yeux"
        labelValeur2.text = self.utilisateur.couleuryeux
        labelInformation3.text = "Cheveux"
        labelValeur3.text = self.utilisateur.couleurcheveux
        labelInformation4.text = "Longueur"
        labelValeur4.text = self.utilisateur.longueurcheveux
        labelInformation5.text = "Physique"
        labelValeur6.text = self.utilisateur.physique

        
        labelInformation6.text = "Taille"
        labelValeur6.text = self.utilisateur.taille
        labelInformation7.text = "Style"
        labelValeur7.text = self.utilisateur.style
        labelInformation8.text = "Origine"
        labelValeur8.text = self.utilisateur.origine
        labelInformation9.text = "Religion"
        labelValeur9.text = self.utilisateur.religion
        labelInformation10.text = "Profession"
        labelValeur10.text = self.utilisateur.profession

        labelInformation11.text = "Lieu idéal"
        labelValeur11.text = self.utilisateur.lieuprefere
        labelInformation12.text = "Je préfère les"
        labelValeur12.text = self.utilisateur.fleurschocolats
        labelInformation13.text = "Film préféré"
        labelValeur13.text = self.utilisateur.filmprefere
        labelInformation14.text = "Musique préférée"
        labelValeur14.text = self.utilisateur.musiqueprefere
 
 */
 
 
 }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellInfoProfil", for: indexPath as IndexPath) as! InfoProfilViewCell
        
        switch( indexPath.item ) {
        case 0:
            cell.labelInformation.text = "Sexualité"
            cell.labelValeur.text = self.utilisateur.sexualite
            break;
        case 1:
            cell.labelInformation.text = "Yeux"
            cell.labelValeur.text = self.utilisateur.couleuryeux
            break;
        case 2:
            cell.labelInformation.text = "Cheveux"
            cell.labelValeur.text = self.utilisateur.couleurcheveux
            break;
        case 3:
            cell.labelInformation.text = "Longueur"
            cell.labelValeur.text = self.utilisateur.longueurcheveux
            break;
        case 4:
            cell.labelInformation.text = "Taille"
            cell.labelValeur.text = self.utilisateur.taille
            break;
        case 5:
            cell.labelInformation.text = "Style"
            cell.labelValeur.text = self.utilisateur.style
            break;
        case 6:
            cell.labelInformation.text = "Profession"
            cell.labelValeur.text = self.utilisateur.profession
            break;
        case 7:
            cell.labelInformation.text = "Film préféré"
            cell.labelValeur.text = self.utilisateur.filmprefere
            break;
        case 8:
            cell.labelInformation.text = "Musique préférée"
            cell.labelValeur.text = self.utilisateur.musiqueprefere
            break;
        default :
            break;
        }
        
        return cell
    }
    
    

    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func circularImage(photoImageView: UIImageView?)
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
    
    func gererImageProfil(img : UIImage) {
        self.imageProfil.image = img
        self.imageCouverture.image = img
        
        self.imageCouverture.addBlurEffect()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickContacter(_ sender: Any) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"contacter_profil", "userid": preferences.string(forKey: "userid") ?? "", "usercontact": utilisateur.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    
                    self.alertController.dismiss(animated: true, completion: {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    })
                
                    return
                }
                //print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.alertController.dismiss(animated: true, completion: {
                                let chat = Chat()
                                print ("json", json)
                                let jsonChat = json["chat"]!
                                chat.id = jsonChat["id"] as! String
                                chat.user1 = self.preferences.string(forKey: "userid")!
                                chat.user2 = self.utilisateur.id
                                chat.prenom = self.utilisateur.prenom
                                chat.symbole = self.utilisateur.symbole
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatController") as! Controller_Chat
                                vc.chat = chat
                                self.present(vc, animated: true, completion: nil)
                            })
                        } else if json["success"] as! Int == 2 {
                            
                                self.alertController.dismiss(animated: true, completion: {
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddContactController") as! Controller_AddContact
                                    
                                    //                                    vc.chat = chat
                                    
                                    self.present(vc, animated: true, completion: nil)

                             })
                        } else if json["success"] as! Int == 3 {
                            self.alertController.dismiss(animated: true, completion: {
                                let chat = Chat()
                                let jsonChat = json["chat"]!
                                
                                
                                
                                
                                chat.id = jsonChat as! String
                                
                                
                                
                                chat.user1 = self.preferences.string(forKey: "userid")!
                                chat.user2 = self.utilisateur.id
                                chat.prenom = self.utilisateur.prenom
                                chat.symbole = self.utilisateur.symbole
                                
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatController") as! Controller_Chat
                                
                                vc.chat = chat
                                
                                self.present(vc, animated: true, completion: nil)
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
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
    
    func afficherPopup( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func buttonBloquer(_ sender: Any) {
        let alert = UIAlertController(title: "Ne plus voir ce profil", message: "Pour quel motif ?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Harcèlement", style: .default, handler: { (action) in
            self.envoyerBlocage(motif: "Harcèlement")
        }))
        
        alert.addAction(UIAlertAction(title: "Faux profil", style: .default, handler: { (action) in
            self.envoyerBlocage(motif: "Faux profil")
        }))
        
        alert.addAction(UIAlertAction(title: "Photo indésirable", style: .default, handler: { (action) in
            self.envoyerBlocage(motif: "Photo indésirable")
        }))
        
        alert.addAction(UIAlertAction(title: "Autre", style: .default, handler: { (action) in
            self.envoyerBlocage(motif: "Autre")
        }))

        alert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action) in
            
            return;
        }))

        
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func envoyerBlocage( motif : String ) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"bloquer_utilisateur", "userid":preferences.string(forKey: "userid") ?? "", "autreid":utilisateur.id, "note":motif] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
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
                                self.afficherPopupFermante(title : "Bloqué", message : "Votre blocage a bien été pris en compte")
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

    @IBAction func buttonSignaler(_ sender: Any) {
        let alert = UIAlertController(title: "Signaler ce profil", message: "Pour quel motif ?", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "Harcèlement", style: .default, handler: { (action) in
            self.envoyerSignalement(motif: "Harcèlement")
        }))
        
        alert.addAction(UIAlertAction(title: "Faux profil", style: .default, handler: { (action) in
            self.envoyerSignalement(motif: "Faux profil")
        }))
        
        alert.addAction(UIAlertAction(title: "Photo indésirable", style: .default, handler: { (action) in
            self.envoyerSignalement(motif: "Photo indésirable")
        }))
        
        alert.addAction(UIAlertAction(title: "Autre", style: .default, handler: { (action) in
            self.envoyerSignalement(motif: "Autre")
        }))
        
        alert.addAction(UIAlertAction(title: "Annuler", style: .default, handler: { (action) in
            
            return;
        }))
        

        self.present(alert, animated: true, completion: nil)
    }
    
    func envoyerSignalement( motif : String ) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"signaler_utilisateur", "userid":preferences.string(forKey: "userid") ?? "", "autreid":utilisateur.id, "note":motif] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
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
                                self.afficherPopupFermante(title : "Signalement", message : "Votre signalement a bien été reçu")
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
    
    func afficherPopupFermante( title : String, message : String) {
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
