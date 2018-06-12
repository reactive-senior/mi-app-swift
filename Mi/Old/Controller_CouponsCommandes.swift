//
//  Controller_CouponsCommandes.swift
//  Timi
//
//  Created by Julien on 23/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP

class Controller_CouponsCommandes: UIViewController, UITableViewDataSource, UITableViewDelegate {
    var coupons = [Coupon]()
    
    var preferences : UserDefaults = UserDefaults.standard
    
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        //self.tableView.separatorStyle = .none
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coupons.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "couponCommandeCell", for: indexPath as IndexPath) as! CouponCommandeCell
        
        cell.selectionStyle = .none
        
        let coupon = self.coupons[indexPath.item]
        
        let infos = coupon.infos.components(separatedBy: [";"])

        cell.labelLibelle.text = coupon.libelle
        
        if( infos.count == 4 ) {
            cell.labelPrenomNom.text = infos[0]
            cell.labelAdresse.text = infos[1]
            cell.labelTelephone.text = infos[2]
            cell.labelHoraire.text = infos[3]
        } else {
            cell.labelPrenomNom.text = "Erreur"
            cell.labelAdresse.text = "Erreur"
            cell.labelTelephone.text = "Erreur"
            cell.labelHoraire.text = "Erreur"
        }
        
        cell.buttonValider.tag = indexPath.row
        cell.buttonValider.addTarget(self, action: #selector(Controller_CouponsCommandes.clickValider), for: .touchUpInside)
        
        return cell
    }
    
    @objc func clickValider(sender: UIButton){
        let buttonTag = sender.tag
        
        let coupon = self.coupons[buttonTag]
        
        
        let alert = UIAlertController(title: "Commande bien effectuée ?", message: "Êtes-vous sûr ?", preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "Confirmer", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            self.confirmerCoupon(coupon: coupon, index: buttonTag)
        }
        
        let annulerAction = UIAlertAction(title: "Annuler", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(annulerAction)
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func confirmerCoupon(coupon : Coupon, index: Int) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = [ "type":"valider_coupon_petiteattention", "idcoupon": coupon.id] as [String : Any]
        
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
                                self.afficherPopup(title : "Coupon confirmé", message : "Ce coupon a bien été confirmé")
                                
                                self.coupons.remove(at: index)
                                
                                DispatchQueue.main.async {
                                    self.tableView.reloadData()
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
