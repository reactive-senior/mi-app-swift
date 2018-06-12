//
//  Controller_AccueilProfil.swift
//  Timi
//
//  Created by Julien on 15/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftHTTP

class Controller_AccueilProfil: UIViewController, IndicatorInfoProvider, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var imageCouverture: UIImageView!
    @IBOutlet weak var imageProfil: UIImageView!

    @IBOutlet weak var txtPrenom: UILabel!
    
    @IBOutlet weak var imageBonusGoogle: UIButton!
    @IBOutlet weak var imageBonusFacebook: UIButton!
    
    var preferences : UserDefaults = UserDefaults.standard

    var imagePicker = UIImagePickerController()

    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.imageBonusGoogle.isHidden = true
        self.imageBonusFacebook.isHidden = true
        

        imageProfil.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageProfilTapped(tapGestureRecognizer:))))
        
        imageCouverture.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imageProfilTapped(tapGestureRecognizer:))))
        
      
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        initialisation()


    }
    
    
    func gererImageProfil(img : UIImage) {
        
        
        self.imageProfil.image = img

        
        self.imageCouverture.clearSubviews()
        self.imageCouverture.image = img
        self.imageCouverture.addBlurEffect()

        circularImage(photoImageView: self.imageProfil)

    
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func imageProfilTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("photo click")
        
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum){
            print("Button capture")
            
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum;
            imagePicker.allowsEditing = false
            
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imageBonusFacebookTapped(tapGestureRecognizer: UITapGestureRecognizer) {
        let alert = UIAlertController(title: "Gagne 2 demandes de chat gratuites !", message: "Aime notre page Facebook !", preferredStyle: .actionSheet)
        
        let retourAction = UIAlertAction(title: "Retour", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(retourAction)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
            
            self.activerBonusFacebook()
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func activerBonusFacebook() {
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
                
                self.imageBonusFacebook.isHidden = true
            }
        } catch { }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any])
    {
        let imageprofil = resizeImage(image: info[UIImagePickerControllerOriginalImage] as! UIImage, targetSize: CGSize(width: 500, height: 500))
        
        gererImageProfil(img: imageprofil)
        circularImage(photoImageView: imageProfil)

        uploadPhotoProfil(img: imageprofil)
        
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadPhotoProfil(img : UIImage) {
        let imageData:NSData = UIImagePNGRepresentation(img)! as NSData
        
        let strBase64:String = imageData.base64EncodedString(options: .lineLength64Characters)
        
        let params = ["type":"sendimageprofil", "userid":preferences.string(forKey: "userid") ?? "", "imageprofil":strBase64] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print(response.text!)
                
                self.afficherPopup(title: "Photo envoyée", message: "Veuillez attendre sa validation")
            }
        } catch { }
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
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Profil")
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
        print("resizeImage" +  String(describing: newSize.width) + " x " + String(describing: newSize.height))
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func initialisation() {
        let params = ["type":"recupererinfos", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            
            print("params " +  params.description);
            
            opt.start { response in
                if (response.error != nil) {
                    print("error " +  response.description);

                    return
                }
                
                print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if ( json["success"] as! Int == 1 ) {
                            DispatchQueue.main.async(execute: {
                                let data = json["data"] as! Dictionary<String,AnyObject>
                                
                                
                                
                                self.preferences.set(data["datenaissance"], forKey: "datenaissance")
                                self.preferences.set(data["prenom"], forKey: "prenom")

                                print("==>> Controller_AccueilProfil viewDidAppear " + self.preferences.string(forKey: "datenaissance")!)
                                
                                let dateFormatter = DateFormatter()
                                dateFormatter.dateFormat = "yyyy-MM-dd"


                                let dateNaissance = dateFormatter.date(from: self.preferences.string(forKey: "datenaissance")!)

                                
                                
                                let calendar = NSCalendar.current
                                let date1 = calendar.startOfDay(for: dateNaissance!)
                                let date2 = calendar.startOfDay(for: Date())
                                let components = calendar.dateComponents([.year], from: date1, to: date2)
                                self.txtPrenom.text = self.preferences.string(forKey: "prenom")! + " , \(components.year!)"

                                self.preferences.set(data["photoprofil"], forKey: "photoprofil")
                                self.preferences.set(data["photoprofil_valide"], forKey: "photoprofil_valide")
                                self.preferences.synchronize()

                                if( self.preferences.string(forKey: "photoprofil")! == "" ) {
                                    if( self.preferences.string(forKey: "sexe")! == "Homme" ) {
                                        self.gererImageProfil( img: UIImage(named: "boy")! )
                                    } else {
                                        self.gererImageProfil( img: UIImage(named: "girl")! )
                                    }
                                } else {
                                    if( self.preferences.string(forKey: "photoprofil_valide")! == "1" ) {
                                        DispatchQueue.main.async {
                                            self.getImageFromWeb(Global().url+"photo_profil/"+self.preferences.string(forKey: "photoprofil")!) { (image) in
                                                if let image = image {
                                                    self.gererImageProfil( img: image )
                                                }
                                                
                                            }
                                        }
                                    } else {
                                        self.gererImageProfil( img: UIImage(named: "hourglass")! )
                                    }
                                }
                                

                                
                            })
                        }
                    }
                } catch let error as NSError{
                    
                    print("error " +  error.description);

                }
            }
        } catch let error as NSError{
            
            print("error2 " +  error.description);
            
        }

    }
    
}

extension UIImageView
{
    func addBlurEffect()
    {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.light)

        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
    }
    
    func clearSubviews()
    {
        for subview in self.subviews {
            subview.removeFromSuperview();
        }
    }
}
