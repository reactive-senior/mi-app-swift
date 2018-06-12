//
//  Controller_MesCoupons.swift
//  Timi
//
//  Created by Julien on 15/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import Nuke
import MapKit

class Controller_MesCoupons: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    var coupons = [Coupon]()
    
    @IBOutlet weak var txtInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.tableView.separatorStyle = .none
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        DispatchQueue.main.async {
            self.chargerCoupons()
        }
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "couponCell", for: indexPath as IndexPath) as! CouponCell
        
        cell.selectionStyle = .none
        
        let coupon = self.coupons[indexPath.item]
        
        DispatchQueue.main.async {            
            Nuke.loadImage(with: URL(string: Global().url+"photo_partenaire/"+(coupon.photo))!, into: cell.imagePartenaire)
        }
        
        cell.buttonQRCode.isHidden = false
        cell.buttonNoter.isHidden = false
        cell.buttonAnnuler.isHidden = false
        
        if( coupon.etat != "0" ) {
            cell.buttonAnnuler.isHidden = true
        }
        
        if( coupon.etat != "1" || coupon.categorie == "petiteattention" ) {
            cell.buttonQRCode.isHidden = true
        }
        
        if( coupon.etat != "3" || coupon.note == "1" ) {
            cell.buttonNoter.isHidden = true
        }
        
        cell.labelEtat.text = etatToString(etat: coupon.etat)
        cell.labelEtat.textColor = UIColor(string: etatToColorString(etat: coupon.etat))
        
        cell.labelNom.text = coupon.nom
        cell.labelLibelle.text = coupon.libelle
        
        cell.buttonMaps.tag = indexPath.row
        cell.buttonMaps.addTarget(self, action: #selector(Controller_MesCoupons.clickMap), for: .touchUpInside)
        
        cell.buttonPhone.tag = indexPath.row
        cell.buttonPhone.addTarget(self, action: #selector(Controller_MesCoupons.clickPhone), for: .touchUpInside)
        
        cell.buttonAnnuler.tag = indexPath.row
        cell.buttonAnnuler.addTarget(self, action: #selector(Controller_MesCoupons.clickAnnuler), for: .touchUpInside)
        
        cell.buttonQRCode.tag = indexPath.row
        cell.buttonQRCode.addTarget(self, action: #selector(Controller_MesCoupons.clickQRCode), for: .touchUpInside)
        
        cell.buttonNoter.tag = indexPath.row
        cell.buttonNoter.addTarget(self, action: #selector(Controller_MesCoupons.clickNoter), for: .touchUpInside)

        return cell
    }
    
    @objc func clickNoter(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        let alert = UIAlertController(title: "Noter cet établissement", message: "Choisissez une note ci-dessous", preferredStyle: .actionSheet)
        
        alert.addAction(UIAlertAction(title: "1 / 5", style: .default, handler: { (action) in
            self.envoyerNote(note: "1", coupon: coupon)
        }))
        alert.addAction(UIAlertAction(title: "2 / 5", style: .default, handler: { (action) in
            self.envoyerNote(note: "2", coupon: coupon)
        }))
        alert.addAction(UIAlertAction(title: "3 / 5", style: .default, handler: { (action) in
            self.envoyerNote(note: "3", coupon: coupon)
        }))
        alert.addAction(UIAlertAction(title: "4 / 5", style: .default, handler: { (action) in
            self.envoyerNote(note: "4", coupon: coupon)
        }))
        alert.addAction(UIAlertAction(title: "5 / 5", style: .default, handler: { (action) in
            self.envoyerNote(note: "5", coupon: coupon)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func envoyerNote(note: String, coupon: Coupon) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"noter_etablissement", "idcoupon": coupon.id, "note": note, "commentaire": ""] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
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
                                self.afficherPopup(title : "Merci !", message : "Votre note a bien été prise en compte")
                                
                                DispatchQueue.main.async {
                                    coupon.note = "1"
                                    
                                    self.tableView.reloadData()
                                    
                                    self.chargerCoupons()
                                }
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer.")
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
    
    @objc func clickMap(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        let regionDistance:CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2DMake(Double(coupon.latitude)!, Double(coupon.longitude)!)
        let regionSpan = MKCoordinateRegionMakeWithDistance(coordinates, regionDistance, regionDistance)
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = coupon.nom
        mapItem.openInMaps(launchOptions: options)
    }
    
    @objc func clickPhone(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        if let url = URL(string: "tel://\(coupon.telephone)"), UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    @objc func clickQRCode(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "qrcodeController") as! Controller_QRCode
        
        vc.coupon = coupon
        
        let navController = UINavigationController(rootViewController: vc)
        
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func clickAnnuler(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        let alert = UIAlertController(title: "Annuler ce coupon", message: "Êtes-vous sûr ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Confirmer", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            self.annulerCoupon(coupon: coupon, index: buttonTag)
        }
        
        let annulerAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(annulerAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func annulerCoupon(coupon : Coupon, index: Int) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"annuler_coupon", "idcoupon": coupon.id] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
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
                                self.afficherPopup(title : "Coupon annulé", message : "Votre coupon a bien été annulé")
                                
                                self.coupons.remove(at: index)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
                                    
                                    self.chargerCoupons()
                                }
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
    
    func etatToString(etat: String) -> String {
        switch etat {
        case "0": return "En attente"
        case "1": return "Accepté"
        case "2": return "Refusé"
        case "3": return "Utilisé"
        case "4": return "Expiré"
        default: return "Erreur"
        }
    }
    
    func etatToColorString(etat: String) -> String {
        switch etat {
        case "0": return "#F39C12"
        case "1": return "#2ECC71"
        case "2": return "#E74C3C"
        case "3": return "#2ECC71"
        case "4": return "#E74C3C"
        default: return "#E74C3C"
        }
    }
    
    func chargerCoupons() {
        
 print("chargerCoupons")
        
        let params = ["type":"get_mescoupons", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez recharger la page pour rafraîchir vos coupons" )
                    
                    return
                }
                
                //print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            let jsonCoupons = json["coupons"] as! [[String: Any]]
                            
                            self.coupons.removeAll()
                            
                            for jsonCoupon in jsonCoupons{
                                let coupon = Coupon()
                                
                                coupon.id = jsonCoupon["id"] as! String
                                coupon.date = jsonCoupon["date"] as! String
                                coupon.acheteur = jsonCoupon["acheteur"] as! String
                                coupon.receveur = jsonCoupon["receveur"] as! String
                                coupon.offre = jsonCoupon["offre"] as! String
                                coupon.etat = jsonCoupon["etat"] as! String
                                coupon.code = jsonCoupon["code"] as! String
                                coupon.libelle = jsonCoupon["libelle"] as! String
                                coupon.nom = jsonCoupon["nom"] as! String
                                coupon.adresse = jsonCoupon["adresse"] as! String
                                coupon.telephone = jsonCoupon["telephone"] as! String
                                coupon.latitude = jsonCoupon["latitude"] as! String
                                coupon.longitude = jsonCoupon["longitude"] as! String
                                coupon.photo = jsonCoupon["photo"] as! String
                                coupon.categorie = jsonCoupon["categorie"] as! String
                                coupon.prenom = jsonCoupon["prenom"] as! String
                                coupon.photoprofil = jsonCoupon["photoprofil"] as! String
                                coupon.note = jsonCoupon["note"] as! String
                                
                                self.coupons.append(coupon)
                            }
                            
                            print(self.coupons.count)
                            
                            if( self.coupons.count == 0 ) {
                                self.afficherMessageErreur( message: "Aucun coupon à afficher ! :/" )
                                
                            } else {
                                DispatchQueue.main.async {
                                    self.afficherCoupons()
                                }
                            }
                        } else {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez recharger la page pour rafraîchir vos coupons" )
                        }
                    } else {
                        self.afficherMessageErreur( message: "Une erreur est survenue, veuillez recharger la page pour rafraîchir vos coupons" )
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez recharger la page pour rafraîchir vos coupons" )
                }
            }
        } catch {
            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez recharger la page pour rafraîchir vos coupons" )
        }
    }
    
    func afficherMessageErreur( message: String ) {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = false
            self.tableView.isHidden = true
            
            self.txtInfo.text = message
        }
    }
    
    func afficherCoupons() {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = true
            self.tableView.isHidden = false
            
            self.tableView.reloadData()
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
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
}
