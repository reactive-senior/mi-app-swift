
//
//  Controller_AccueilRecherche.swift
//  Timi
//
//  Created by Julien on 15/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftHTTP
import Nuke



class Controller_AccueilRecherche: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var preferences : UserDefaults = UserDefaults.standard

    var utilisateurs = [Utilisateur]()
    var tmputilisateur = Utilisateur()
    var demandechat = ""

    @IBOutlet weak var txtInfo: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!




    /*
     SELECT  lieu_cat , lieu_sscat ,lieu_cat = "1" and lieu_sscat = "1" as zzz
     FROM UTILISATEUR order by zzz DESC
     */
    
    var CatImgArray = ["cat_bar", "cat_restaurant", "cat_sorties"]
    
    var ssCatImg1Array = ["bar_1_cocktail", "bar_2_jus_de_fruits", "bar_3_vin", "bar_4_biere.png", "bar_5_thes", "bar_6_musical_culturel"]
    var ssCatImg2Array = ["resto_1_Francais", "resto_2_Fruits-de-mer", "resto_3_Asiatique", "resto_4_Japonnais", "resto_5_Veggie", "resto_6_Oriental", "resto_7._Street-food", "resto_8_Italien", "resto_9_Exotique"]
    var ssCatImg3Array = ["Sortie_1_Theatre", "Sortie_2_Soirée"]
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        self.collectionView.delegate = self;
        self.collectionView.dataSource = self;
        self.collectionView.collectionViewLayout = CustomImageFlowLayout()
        
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Controller_AccueilRecherche.tapFunction))
        txtInfo.isUserInteractionEnabled = true
        txtInfo.addGestureRecognizer(tap)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Recherche")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("==>> Controller_AccueilRecherche viewDidAppear")
        
        
        if( Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                
                print("==>> Controller_AccueilRecherche lancerRercherche")
                
                
                self.lancerRercherche()
            }
        }
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! UtilisateurViewCell
        
        let utilisateur = self.utilisateurs[indexPath.item]
        
        print ("collectionView >>>" + utilisateur.prenom)

        
        
        let formattedString = NSMutableAttributedString()
        
        formattedString
            .normal(utilisateur.prenom+", ")
            .normal(utilisateur.ageuser)
        
        cell.txtPrenomAge.attributedText = formattedString
            
        //self.stringFromHtml(string: "<b>\(utilisateur.prenom)</b>, \(utilisateur.ageuser)")
        
        cell.txtDistance.text = "À \( String(describing: Int(Double(utilisateur.distance_in_km)!)) ) km de vous"
        //sellieu
        switch (utilisateur.symbole) {
            case "pique"  :
                cell.imageSymbole.image = UIImage(named: "pique_red")
            case "coeur"  :
                cell.imageSymbole.image = UIImage(named: "coeur_red")
            case "carreau"  :
                cell.imageSymbole.image = UIImage(named: "carreau_red")
            case "trefle"  :
                cell.imageSymbole.image = UIImage(named: "trefle_red")
            default :
                cell.imageSymbole.image = UIImage(named: "coeur_red")
        }
        
    
        var lieu_cat = utilisateur.lieu_cat
        if (lieu_cat == "0")
        {
            lieu_cat = "1"
        }
        let icat = Int(lieu_cat)! - 1
        let CatImg = CatImgArray[icat]
        cell.imageLieu.image = UIImage(named: CatImg)

        
    
        if( utilisateur.photoprofil == "" ) {
            cell.image.image = nil
            
            print(utilisateur.sexe)
            
            if( utilisateur.sexe == "Homme" ) {
                cell.image.image = UIImage(named: "boy")
            } else {
                cell.image.image = UIImage(named: "girl")
            }
        } else {
            if( utilisateur.photoprofil_valide == "1" ) {
                DispatchQueue.main.async {
                    cell.image.image = nil
                    
                    Nuke.loadImage(with: URL(string: Global().url+"photo_profil/"+(utilisateur.photoprofil))!, into: cell.image)
                }
            } else {
                cell.image.image = nil
                cell.image.image = UIImage(named: "hourglass")
            }
        }
        
        cell.btnChat.tag = indexPath.row
        cell.btnChat.addTarget(self, action: #selector(self.btnChatTap), for: .touchUpInside)
        cell.btnDelete.tag = indexPath.row
        cell.btnDelete.addTarget(self, action: #selector(self.btnDeleteTap), for: .touchUpInside)
        return cell
    }

    @objc func btnDeleteTap(sender : UIButton){
        
        tmputilisateur = self.utilisateurs[sender.tag]
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
        
        let params = ["type":"bloquer_utilisateur", "userid":preferences.string(forKey: "userid") ?? "", "autreid":tmputilisateur.id, "note":motif] as [String : Any]
        
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

    
    @objc func btnChatTap(sender : UIButton){
        
        self.present(alertController, animated: true, completion: nil)
        let utilisateur = self.utilisateurs[sender.tag]
        
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
                                let jsonChat = json["chat"]!
                                
                                let chat = Chat()
                                chat.id = jsonChat["id"] as! String
                                chat.user1 = self.preferences.string(forKey: "userid")!
                                chat.user2 = utilisateur.id
                                chat.prenom = utilisateur.prenom
                                chat.symbole = utilisateur.symbole
                                let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatController") as! Controller_Chat
                                vc.chat = chat
                                
                                self.present(vc, animated: true, completion: nil)
                            })
                        } else if json["success"] as! Int == 2 {
                            self.alertController.dismiss(animated: true, completion: {
                                
                                DispatchQueue.main.async(){
                                    let vc = self.storyboard?.instantiateViewController(withIdentifier: "AddContactController") as! Controller_AddContact
                                    vc.view.backgroundColor = .clear
                                    self.modalPresentationStyle = .currentContext
//                                    vc.chat = chat
                                    self.present(vc, animated: false, completion: nil)
                                }
                            })
                        } else if json["success"] as! Int == 3 {
                            self.alertController.dismiss(animated: true, completion: {
                                let chat = Chat()
                                print ("json", json)
                                let jsonChat = json["chat"]!
                                chat.id = jsonChat["id"] as! String
                                chat.user1 = self.preferences.string(forKey: "userid")!
                                chat.user2 = utilisateur.id
                                chat.prenom = utilisateur.prenom
                                chat.symbole = utilisateur.symbole
                                
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
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return utilisateurs.count
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "profil") as! Controller_Profil
        vc.utilisateur = utilisateurs[indexPath.item]
        vc.AccueilRecherche = self
        self.present(vc, animated: true, completion: nil)

    }
    

    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if( utilisateurs.count == 0 && Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                self.lancerRercherche()
            }
        } else {
            DispatchQueue.main.async {
                self.afficherListeUtilisateurs()
            }
        }
    }
    


    func afficherMessageErreur( message: String ) {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = false
            self.collectionView.isHidden = true
            self.txtInfo.text = message
        }
    }
    
    func afficherListeUtilisateurs() {
        print ("afficherListeUtilisateurs >>>")
        self.txtInfo.isHidden = true
        self.collectionView.isHidden = false
        self.collectionView.reloadData()
        print ("afficherListeUtilisateurs <<<")

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
    
    func afficherPopupFermante( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            self.lancerRercherche()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    //*******************************
    //*******************************
    //*******************************

    func lancerRercherche() {
        
        print ("lancerRercherche >>>")
        
        let params = ["type":"recherche_personne4", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
                    return
                }
                
                //print(response.text!)
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            
                            self.demandechat  = json["demandechat"] as! String
                            
                            self.utilisateurs.removeAll()
                            if let Testexist  = json["utilisateurs"]  {
                                
                                let jsonUsers = json["utilisateurs"] as! [[String: Any]]
                                
                                
                                for jsonUser in jsonUsers{
                                    let user = Utilisateur()
                                    if let photoprofil = jsonUser["photoprofil"] as? String{
                                        user.photoprofil = photoprofil
                                    }
                                    
                                    if let prenom = jsonUser["prenom"] as? String{
                                        user.prenom = prenom
                                    }
                                    
                                    if let sexualite = jsonUser["sexualite"] as? String{
                                        user.sexualite = sexualite
                                    }
                                    
                                    if let ageuser = jsonUser["ageuser"] as? String{
                                        user.ageuser = ageuser
                                    }
                                    
                                    if let distance_in_km = jsonUser["distance_in_km"] as? String{
                                        user.distance_in_km = distance_in_km
                                    }
                                    
                                    if let id = jsonUser["id"] as? String{
                                        user.id = id
                                    }
                                    
                                    if let symbole = jsonUser["symbole"] as? String{
                                        user.symbole = symbole
                                    }
                                    
                                    if let description = jsonUser["description"] as? String{
                                        user.descr = description
                                    }
                                    
                                    if let couleuryeux = jsonUser["couleuryeux"] as? String{
                                        user.couleuryeux = couleuryeux
                                    }
                                    
                                    if let couleurcheveux = jsonUser["couleurcheveux"] as? String{
                                        user.couleurcheveux = couleurcheveux
                                    }
                                    
                                    if let longueurcheveux = jsonUser["longueurcheveux"] as? String{
                                        user.longueurcheveux = longueurcheveux
                                    }
                                    
                                    if let physique = jsonUser["physique"] as? String{
                                        user.physique = physique
                                    }
                                    
                                    if let taille = jsonUser["taille"] as? String{
                                        user.taille = taille
                                    }
                                    
                                    if let style = jsonUser["style"] as? String{
                                        user.style = style
                                    }
                                    
                                    if let origine = jsonUser["origine"] as? String{
                                        user.origine = origine
                                    }
                                    
                                    if let religion = jsonUser["religion"] as? String{
                                        user.religion = religion
                                    }
                                    
                                    if let profession = jsonUser["profession"] as? String{
                                        user.profession = profession
                                    }
                                    
                                    if let fleurschocolats = jsonUser["fleurschocolats"] as? String{
                                        user.fleurschocolats = fleurschocolats
                                    }
                                    
                                    if let filmprefere = jsonUser["filmprefere"] as? String{
                                        user.filmprefere = filmprefere
                                    }
                                    
                                    if let musiqueprefere = jsonUser["musiqueprefere"] as? String{
                                        user.musiqueprefere = musiqueprefere
                                    }
                                    
                                    if let lieuprefere = jsonUser["lieuprefere"] as? String{
                                        user.lieuprefere = lieuprefere
                                    }
                                    
                                    if let photo1 = jsonUser["photo1"] as? String{
                                        user.photo1 = photo1
                                    }
                                    
                                    if let photo2 = jsonUser["photo2"] as? String{
                                        user.photo2 = photo2
                                    }
                                    
                                    if let photo3 = jsonUser["photo3"] as? String{
                                        user.photo3 = photo3
                                    }
                                    
                                    if let photo1_valide = jsonUser["photo1_valide"] as? String{
                                        user.photo1_valide = photo1_valide
                                    }
                                    
                                    if let photo2_valide = jsonUser["photo2_valide"] as? String{
                                        user.photo2_valide = photo2_valide
                                    }
                                    
                                    if let photo3_valide = jsonUser["photo3_valide"] as? String{
                                        user.photo3_valide = photo3_valide
                                    }
                                    
                                    if let photoprofil_valide = jsonUser["photoprofil_valide"] as? String{
                                        user.photoprofil_valide = photoprofil_valide
                                    }
                                    
                                    if let sexe = jsonUser["sexe"] as? String{
                                        user.sexe = sexe
                                    }
                                    if let lieu_cat = jsonUser["lieu_cat"] as? String{
                                        user.lieu_cat = lieu_cat
                                    }
                                    if let lieu_sscat = jsonUser["lieu_sscat"] as? String{
                                        user.lieu_sscat = lieu_sscat
                                    }
                                    if let sellieu = jsonUser["sellieu"] as? String{
                                        user.sellieu = sellieu
                                    }
                                    
                                    self.utilisateurs.append(user)
                                }
                            }
                            
                            print(self.utilisateurs.count)
                            
                            if( self.utilisateurs.count == 0 ) {
                                self.afficherMessageErreur( message: "Aucun profil ne correspond à votre recherche ... Modifiez vos paramètres de recherche et cliquez pour recharger votre recherche !" )
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.afficherListeUtilisateurs()
                                }
                            }
                        } else if json["success"] as! Int == 0 {
                            self.afficherMessageErreur( message: "Vous n'avez encore jamais été géolocalisé ! Activez votre GPS et relancez une recherche" )
                        } else {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
                        }
                    } else {
                        self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
                }
            }
        } catch {
            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
        }
        
        
        print ("lancerRercherche <<<<")
        
    }

}
