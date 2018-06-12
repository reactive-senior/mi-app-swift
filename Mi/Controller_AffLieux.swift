
//
//  Controller_AffLieux
//  Timi
//
//  Created by Julien on 15/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftHTTP
import Nuke
import MapKit

class Controller_AffLieux: UIViewController, IndicatorInfoProvider, UICollectionViewDataSource, UICollectionViewDelegate {
    
    var preferences : UserDefaults = UserDefaults.standard

    var chatid = ""
    var lieuid = ""
    var demande = ""

    var aff = ""

    var Lieux = [Lieu]()
    var tmplieu = Lieu()
    
    @IBOutlet weak var txtInfo: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!


    
    /*
     SELECT  lieu_cat , lieu_sscat ,lieu_cat = "1" and lieu_sscat = "1" as zzz
     FROM UTILISATEUR order by zzz DESC
     
     */
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
        self.collectionView.collectionViewLayout = CustomImageFlowLayoutlieux()
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Controller_AffLieux.tapFunction))
        txtInfo.isUserInteractionEnabled = true
        txtInfo.addGestureRecognizer(tap)
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
    }
    
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if( Lieux.count == 0 && Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                self.lancerRercherche()
            }
        } else {
            DispatchQueue.main.async {
                self.afficherListe()
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Recherche")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("==>> Controller_AffLieux viewDidAppear")
        

        if( Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                self.lancerRercherche()
            }
        }
    }
    
    func lancerRercherche() {
        
        var params = [String : Any]()
        

        print ("lieuid", lieuid, "demande" , demande)
        
        if (lieuid != "0" && demande == "2")
            {
            params = ["type":"SelectLieuid", "lieuid" : lieuid] as [String : Any]
            }
        else if (self.aff == "1")
        {
            params = ["type":"SelectLieuid", "lieuid": lieuid] as [String : Any]
            
        }
        else {
            params = ["type":"SelectLieux", "userid1":preferences.string(forKey: "userid") ?? "","userid2":preferences.string(forKey: "AutreId") ?? ""] as [String : Any]
            }

        do {
            let opt = try HTTP.POST(Global().url+"gestion_lieux.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger votre recherche" )
                    
                    return
                }
                print(response.text!)

                
                do {
                        let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>

                        if !json.isEmpty {
                            if json["success"] as! Int == 1 {
                                self.Lieux.removeAll()
                                if let Testexist  = json["Lieux"]  {
                                let jsonUsers = json["Lieux"] as! [[String: Any]]
                                
                                    print("Lieux")

                                for jsonUser in jsonUsers{
                                    let lieu = Lieu()

                                    if let id = jsonUser["id"] as? String{
                                        lieu.id = id
                                        print("id", id)
                                        
                                    }

                                    if let nom = jsonUser["nom"] as? String{
                                        lieu.nom = nom
                                        
                                        print("nom", nom)

                                    }
                                    if let description = jsonUser["description"] as? String{
                                        lieu.descr = description
                                    }
                                    if let lieu_cat = jsonUser["lieu_cat"] as? String{
                                        lieu.lieu_cat = lieu_cat
                                    }
                                    if let lieu_sscat = jsonUser["lieu_sscat"] as? String{
                                        lieu.lieu_sscat = lieu_sscat
                                    }
                                    if let url = jsonUser["url"] as? String{
                                        lieu.url = url
                                    }
                                    if let photo = jsonUser["photo"] as? String{
                                        lieu.photo = photo
                                    }
                                    if let latitude = jsonUser["latitude"] as? String{
                                        lieu.latitude = latitude
                                    }
                                    if let longitude = jsonUser["longitude"] as? String{
                                        lieu.longitude = longitude
                                    }


                                    self.Lieux.append(lieu)
                                }
                                }

                                print("Count Lieux", self.Lieux.count)
                                
                                if( self.Lieux.count == 0 ) {
                                    self.afficherMessageErreur( message: "Aucun profil ne correspond à votre recherche ... Modifiez vos paramètres de recherche et cliquez pour recharger votre recherche !" )

                                } else {
                                    DispatchQueue.main.async {
                                        self.afficherListe()
                                    }
                                }
                            }
                            else {
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
    }
    
    func afficherMessageErreur( message: String ) {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = false
            self.collectionView.isHidden = true
            self.txtInfo.text = message
        }
    }
    
    func afficherListe() {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = true
            self.collectionView.isHidden = false
            self.collectionView.reloadData()
        }
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
    


    //************************************************
    //************************************************
    //************************************************

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath as IndexPath) as! LieuViewCell
        
        let Lieu = self.Lieux[indexPath.item]
        cell.txtnom.text = Lieu.nom
        cell.txtdescr.text = Lieu.descr

        let isscat = Int(Lieu.lieu_sscat)! - 1
        switch (Lieu.lieu_cat) {
        case "1"  :
            cell.imageLieu.image = UIImage(named: ssCatImg1Array[isscat])
        case "2"  :
            cell.imageLieu.image = UIImage(named: ssCatImg2Array[isscat])
        case "3"  :
            cell.imageLieu.image = UIImage(named: ssCatImg3Array[isscat])
        default:
            cell.imageLieu.image = UIImage(named: ssCatImg1Array[0])
        }
        circularImage(photoImageView: cell.viewLieu)
        if( Lieu.photo == "" ) {
            cell.image.image = nil
            cell.image.image = UIImage(named: "hourglass")
        } else {
            DispatchQueue.main.async {
                cell.image.image = nil
                Nuke.loadImage(with: URL(string: Global().url+"photo_partenaire/"+(Lieu.photo))!, into: cell.image)
            }
        }
        
        cell.btnINV.isHidden = (self.aff == "1")

                
        cell.btnWWW.tag = indexPath.row
        cell.btnWWW.addTarget(self, action: #selector(self.btnWWWTap), for: .touchUpInside)

        cell.btnINV.tag = indexPath.row
        cell.btnINV.addTarget(self, action: #selector(self.btnINVTap), for: .touchUpInside)

        cell.btnLOC.tag = indexPath.row
        cell.btnLOC.addTarget(self, action: #selector(self.btnLOCTap), for: .touchUpInside)

        
        return cell
    }

    func circularImage(photoImageView: UIView?)
    {
        photoImageView!.layer.frame = photoImageView!.layer.frame.insetBy(dx: 0, dy: 0)
        photoImageView!.layer.borderColor = PrimaryColor.cgColor
        photoImageView!.layer.backgroundColor = UIColor.white.cgColor
        photoImageView!.layer.borderWidth = 2
        photoImageView!.layer.cornerRadius = photoImageView!.frame.height/2
        photoImageView!.layer.masksToBounds = false
        photoImageView!.clipsToBounds = true
        photoImageView!.contentMode = UIViewContentMode.scaleAspectFill
    }

    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return Lieux.count
    }
    
    @objc func btnWWWTap(sender : UIButton)
    {
        let Lieu = self.Lieux[sender.tag]
        print("btnWWWTap", Lieu.nom)
        open(scheme: Lieu.url)
    }
    
    @objc func btnINVTap(sender : UIButton)
    {
        let Lieu = self.Lieux[sender.tag]
        print("btnINVTap", Lieu.nom)

        
        
        //dem_env(Lieuid : Lieu.id)
        
        
        if (lieuid != "0" && demande == "2")
        {
            rec_env()
        }
        else
        {
            dem_env(Lieuid : Lieu.id)
        }

        
        
    }

    @objc func btnLOCTap(sender : UIButton)
    {
        let Lieu = self.Lieux[sender.tag]
        print("btnLOCTap", Lieu.nom)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "Controller_carte") as! Controller_carte
        
        let lat = Double(Lieu.latitude)!
        let long = Double(Lieu.longitude)!
        
        
        vc.currentLocation = CLLocation(latitude: lat, longitude: long)
        vc.wtitle = Lieu.nom
        AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)

        
        
    }
    

    
    //**************************************
    //**************************************
    //**************************************

    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }

    
    //**************************************
    //**************************************
    //**************************************

    func open(scheme: String) {
        if let url = URL(string: scheme) {
            if #available(iOS 10, *) {
                UIApplication.shared.open(url, options: [:],
                                          completionHandler: {
                                            (success) in
                                            print("Open \(scheme): \(success)")
                })
            } else {
                let success = UIApplication.shared.openURL(url)
            }
        }
    }

    //**************************************
    //**************************************
    //**************************************

    
    func dem_env(Lieuid : String) {
        print("Lieuid" ,Lieuid)

        let params = ["type":"dem_env", "idchat":chatid, "Lieuid":Lieuid] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("dem_env" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.dismiss(animated: true, completion: nil)

                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }

    func rec_env() {
        let params = ["type":"rec_env", "idchat":chatid] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("rec_env" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.dismiss(animated: true, completion: nil)
                            
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }

    
}
