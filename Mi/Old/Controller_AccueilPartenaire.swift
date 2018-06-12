//
//  Controller_AccueilPartenaire.swift
//  Timi
//
//  Created by Julien on 23/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import AVFoundation
//import QRCodeReader

class Controller_AccueilPartenaire: UIViewController /*,QRCodeReaderViewControllerDelegate*/ {
    @IBOutlet weak var labelNom: UILabel!
    @IBOutlet weak var labelNote: UILabel!
    
    @IBOutlet weak var buttonAction: UIButton!
    
    @IBOutlet weak var labelMoisVendus: UILabel!
    @IBOutlet weak var labelMoisUtilises: UILabel!
    @IBOutlet weak var labelMoisRevenus: UILabel!
    
    @IBOutlet weak var labelTotalVendus: UILabel!
    @IBOutlet weak var labelTotalUtilises: UILabel!
    @IBOutlet weak var labelTotalRevenus: UILabel!
    
    var partenaire = Partenaire()
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        definesPresentationContext = true
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)

        self.labelNom.text = partenaire.nom
        
        if( partenaire.categorie == "petiteattention" ) {
            self.buttonAction.setTitle("Coupons commandés", for: .normal)
        } else {
            self.buttonAction.setTitle("Scanner un QR Code", for: .normal)
        }
        
        self.initialisation()
    }

    func initialisation() {
        let params = ["type":"infos_stats", "idpartenaire":partenaire.id] as [String : Any]
 
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            DispatchQueue.main.async {
                                self.labelMoisVendus.text = "Coupons vendus : \(json["vendusmois"] as! String)"
                                self.labelMoisUtilises.text = "Coupons utilisés : \(json["utilisesmois"] as! String)"
                                self.labelMoisRevenus.text = "Revenus : \(self.prixFromString(value: json["revenusmois"] as! Int)) €"
                                
                                self.labelTotalVendus.text = "Coupons vendus : \(json["vendustotal"] as! String)"
                                self.labelTotalUtilises.text = "Coupons utilisés : \(json["utilisestotal"] as! String)"
                                self.labelTotalRevenus.text = "Revenus : \(self.prixFromString(value: json["revenustotal"] as! Int)) €"
                                
                                if( json["note"] as! String == "0" ) {
                                    self.labelNote.text = "Pas encore noté"
                                } else {
                                    self.labelNote.text = "\(json["note"] as! String) / 5"
                                }
                            }
                        } else if json["success"] as! Int == 0 {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        } else {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        }
                    } else {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez rééssayer")
                }
            }
        } catch {
            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
        }
    }
    
    func prixFromString( value: Int ) -> String {
        let prix = Double(value)/100.00

        return String(format: "%.2f", arguments: [prix])
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickExit(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func clickRefresh(_ sender: Any) {
        self.initialisation()
    }

    @IBAction func clickContact(_ sender: Any) {

    }

    @IBAction func clickOffres(_ sender: Any) {
        self.initialisation()
        
        
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"get_offres", "idpartenaire": partenaire.id ] as [String : Any]
        
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
                                var offres = [Offre]()
                                
                                let jsonOffres = json["offres"] as! [[String: Any]]
                                
                                for jsonOffre in jsonOffres{
                                    let offre = Offre()
                                    
                                    offre.id = jsonOffre["id"] as! String
                                    offre.partenaire = jsonOffre["partenaire"] as! String
                                    offre.libelle = jsonOffre["libelle"] as! String
                                    offre.prix = jsonOffre["prix"] as! String
                                    offre.photo = jsonOffre["photo"] as! String
                                    offre.actif = jsonOffre["actif"] as! String
                                    
                                    offres.append(offre)
                                }
                                
                                
                                
                                let PartenaireOffres = self.storyboard?.instantiateViewController(withIdentifier: "PartenaireOffres") as! Controller_PartenaireOffres
                                PartenaireOffres.PartenaireOffres = offres

                                let navController = UINavigationController(rootViewController: PartenaireOffres)
                                
                                
                                
                                
                                self.present(navController, animated: true, completion: nil)
                                
                            })
                        } else {
                            self.alertController.dismiss(animated: true, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            })
                        }
                    } else {
                        self.alertController.dismiss(animated: true, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Vous n'avez encore jamais eu de rendez-vous")
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

    
    
    @IBAction func clickAction(_ sender: Any) {
        
        /*
        if( partenaire.categorie == "petiteattention" ) {
            self.chargerCoupons()
        } else {
            
            let readerVC: QRCodeReaderViewController = {
                let builder = QRCodeReaderViewControllerBuilder {
                    $0.reader = QRCodeReader(metadataObjectTypes: [AVMetadataObject.ObjectType.qr.rawValue], captureDevicePosition: .back)
                }
                
                return QRCodeReaderViewController(builder: builder)
            }()
            
            readerVC.delegate = self
            
            readerVC.modalPresentationStyle = .formSheet
            present(readerVC, animated: true, completion: nil)
        }
 */
    }
    
    /*
    func reader(_ reader: QRCodeReaderViewController, didScanResult result: QRCodeReaderResult) {
        print(result.value)
            
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
        
        self.chercherQRCode(code: result.value)
    }
    
    func readerDidCancel(_ reader: QRCodeReaderViewController) {
        reader.stopScanning()
        
        dismiss(animated: true, completion: nil)
    }
    
    func chercherQRCode( code: String ) {
        let params = [ "type":"scan_codeV2", "idpartenaire": partenaire.id, "code":code ] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_partenaire.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            DispatchQueue.main.async {
                                print("success 1")
                                
                                let jsonData = json["data"]!

                                self.afficherPopup(title : "Coupon validé", message : jsonData["libelle"] as! String)
                            }
                        } else if json["success"] as! Int == 0 {
                            DispatchQueue.main.async {
                                print("success 0")
                                
                                self.afficherPopup(title : "Coupon invalide", message : "Coupon refusé, veuillez réessayer")
                            }
                        } else {
                            DispatchQueue.main.async {
                                print("success else")
                                
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            }
                        }
                    } else {
                        self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                }
            }
        } catch {
            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
        }
    }
    */
    func chargerCoupons() {
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"get_couponscommandes", "idpartenaire": partenaire.id ] as [String : Any]
        
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
                                var coupons = [Coupon]()
                                
                                let jsonCoupons = json["coupons"] as! [[String: Any]]
                                
                                for jsonCoupon in jsonCoupons{
                                    let coupon = Coupon()
                                    
                                    coupon.id = jsonCoupon["id"] as! String
                                    coupon.libelle = jsonCoupon["libelle"] as! String
                                    coupon.infos = jsonCoupon["infos"] as! String
                                    
                                    coupons.append(coupon)
                                }
                                                                
                                let couponsCommandes = self.storyboard?.instantiateViewController(withIdentifier: "couponsCommandes") as! Controller_CouponsCommandes
                                
                                couponsCommandes.coupons = coupons
                                
                                let navController = UINavigationController(rootViewController: couponsCommandes)
                                
                                self.present(navController, animated: true, completion: nil)
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
    
    func afficherPopup( title : String, message : String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
}
