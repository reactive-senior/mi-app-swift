//
//  Controller_Chat.swift
//  Timi
//
//  Created by Julien on 06/06/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import SwiftHTTP
import QuartzCore

class Controller_Chat: UIViewController, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var labelPrenom: UILabel!
    @IBOutlet weak var editMessage: UITextField!
    @IBOutlet weak var btnEnvoyer: UIButton!
    
    @IBOutlet weak var btnGift: UIButton!
    @IBOutlet weak var btnSignaler: UIButton!
    @IBOutlet weak var btnRafraichir: UIButton!
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var ViewSaisie: UIView!

   
    var bottomConstraintView: NSLayoutConstraint!

    
    @IBOutlet weak var fullViewCoupon: UIView!
    @IBOutlet weak var fullBoutonsCoupon: UIStackView!
    
    @IBOutlet weak var labelInformation: UILabel!
    
    @IBOutlet weak var fullViewBoutonsInformations: UIView!
    
    @IBOutlet weak var labelCouponInformation: UILabel!
    
    @IBOutlet weak var fullViewCouponImg1: UIImageView!
    @IBOutlet weak var fullViewCouponImg2: UIImageView!
    
    @IBOutlet weak var fullViewCouponLabel1: UILabel!
    @IBOutlet weak var fullViewCouponLabel2: UILabel!

    
    
    var chat = Chat()
    let coupon = Coupon()

    var messages = [Message]()

    var statut = ""
    var chat_demande = "0"
    var chat_demandeur = "0"
    var chat_receveur = "0"
    var chat_dem_st = "0"
    var chat_rec_st = "0"
    var chat_lieu = "0"
    var chat_rowcountlieux = "0"

    var preferences : UserDefaults = UserDefaults.standard
    var alertController =  UIAlertController(title: nil, message: "Chargement\n\n", preferredStyle: .alert)
    let spinnerIndicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    
    let CatLib2Bar = "Il est l'heure de s'hydrater !"
    let CatLib2Restau = "Il est l'heure de passer à table !"
    let CatLib2Sortie = "Il est l'heure de sortir !"
    var CatLib2Array = [String]()

    let CatImgBar = "cat_bar"
    let CatImgRestau = "cat_restaurant"
    let CatImgSortie = "cat_sorties"
    var CatImgArray = [String]()

    var ssCatImg1Array = [String]()
    var ssCatImg2Array = [String]()
    var ssCatImg3Array = [String]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        var wCat = preferences.integer(forKey: "inscription_iCat")
        if (wCat == 0)
            {
            wCat = 1
            }
        var wSsCat = preferences.integer(forKey: "inscription_iSsCat")
        if (wSsCat == 0)
        {
            wSsCat = 1
        }

        ssCatImg1Array = ["bar_1_cocktail", "bar_2_jus_de_fruits", "bar_3_vin", "bar_4_biere.png", "bar_5_thes", "bar_6_musical_culturel"]
        ssCatImg2Array = ["resto_1_Francais", "resto_2_Fruits-de-mer", "resto_3_Asiatique", "resto_4_Japonnais", "resto_5_Veggie", "resto_6_Oriental", "resto_7._Street-food", "resto_8_Italien", "resto_9_Exotique"]
        ssCatImg3Array = ["Sortie_1_Theatre", "Sortie_2_Soirée"]
        
    
        CatLib2Array = [CatLib2Bar, CatLib2Restau, CatLib2Sortie]
        fullViewCouponLabel1.text = CatLib2Array[wCat - 1]

        CatImgArray = [CatImgBar, CatImgRestau, CatImgSortie]
        
        fullViewCouponImg1.image = UIImage(named: CatImgArray[wCat - 1])
        fullViewCouponImg2.image = UIImage(named: CatImgArray[wCat - 1])
        
        fullViewCoupon.isHidden = true
        
        
        //self.hideKeyboardWhenTappedAround()
        
        self.toutCacher()
        
        spinnerIndicator.center = CGPoint(x: 135.0, y: 65.5)
        spinnerIndicator.color = UIColor.black
        spinnerIndicator.startAnimating()
        
        alertController.view.addSubview(spinnerIndicator)
        
        self.tableView.delegate = self;
        self.tableView.dataSource = self;

        //self.tableView.rowHeight = UITableViewAutomaticDimension
        //self.tableView.estimatedRowHeight = 140
        
        self.editMessage.delegate = self

        self.tableView.separatorStyle = .none

        self.labelPrenom.text = chat.prenom
        
        labelPrenom.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(prenomTapped(tapGestureRecognizer:))))
        
        print("chat id", chat.id)
        print("chat prenom", chat.prenom)
        print("chat user1", chat.user1)
        print("chat user2", chat.user2)

        NotificationCenter.default.addObserver(self, selector: #selector(Controller_Chat.keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(Controller_Chat.keyboardWillHide(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.initialisation()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    //************************************************
    //************************************************
    //************************************************

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellMessage", for: indexPath as IndexPath) as! MessageViewCell
        let msg = messages[indexPath.row]

        let width = cell.frame.width
        
        cell.labelvu.isHidden = true
        
        if (indexPath.row == messages.count - 1 && msg.user != String(getAutreId()))
        {
            print("cell.labelvu 1 ")
            
            cell.labelvu.isHidden = false
            if (msg.vu == "1")
            {
                cell.labelvu.text = "Vu"
            }
            else
            {
                cell.labelvu.text = "Pas Vu"
            }
        }
        else
        {
//            print("cell.labelvu 2 " + msg.vu)

        }
        
        cell.selectionStyle = .none
        cell.labelMessage.text = msg.message
        cell.labelMessage.sizeToFit()
        cell.labelMessage.padding = UIEdgeInsets(top: 5, left: 7, bottom: 5, right: 7)

        cell.labelMessage.layer.masksToBounds = true
        cell.labelMessage.layer.cornerRadius = 8
        
        if( msg.user == String(getAutreId()) ) {
            cell.labelMessage.backgroundColor = UIColor.init(string: "#EEEEEE")
            cell.labelMessage.textColor = PrimaryColor
            cell.contrainteDroite.constant = width / 4
            cell.contrainteGauche.constant = 10

            //cell.labelMessage.textAlignment = .left

        } else {
            cell.labelMessage.backgroundColor = PrimaryColor
            cell.labelMessage.textColor = UIColor.init(string: "#FFFFFF")
            cell.contrainteGauche.constant = width / 4
            cell.contrainteDroite.constant = 10

            //cell.labelMessage.textAlignment = .right
        }

        //cell.layoutIfNeeded()
        
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    {

//        let height:CGFloat = self.calculateHeight(inString: messages[indexPath.row].message)  + 30;
//                print(">>>>>>>>>>>>>>>> " , height , " => " , messages[indexPath.row].message)
        let height1:CGFloat = self.calculateSizes(string: messages[indexPath.row].message) + 30;
//            print(">>>>>>>>>>>>>>>> " , height , " => " , messages[indexPath.row].message)

        return height1
    }
    
    func calculateSizes(string: String)-> CGFloat
    {
        
        let wWidth = ( self.tableView.frame.width * 3 / 4 ) - 10

        
        let maxSize = CGSize(width: wWidth, height: 99999)
        
        let stringSize = string.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin, .usesFontLeading], context: nil).size
//        print("boundingRect: \(stringSize.height)  \(wWidth)")
        
        return stringSize.height * 2;
    }

    
    func calculateHeight(inString:String) -> CGFloat
    {
        let wWidth = self.tableView.frame.width * 2 / 4
        let messageString = inString
        let attributes = [NSAttributedStringKey.font:  UIFont.systemFont(ofSize: 13.0), NSAttributedStringKey.foregroundColor: UIColor.white]
        let attributedString : NSAttributedString = NSAttributedString(string: messageString, attributes: attributes)
        let rect : CGRect = attributedString.boundingRect(with: CGSize(width: wWidth, height: CGFloat.greatestFiniteMagnitude), options: .usesLineFragmentOrigin, context: nil)
        let requredSize:CGRect = rect
        return requredSize.height
    }
    
    
    func initialisation() {
        let params = ["type":"infos_chat", "userid":preferences.string(forKey: "userid") ?? "", "autreuserid":String(getAutreId()), "idchat":chat.id] as [String : Any]
        
        self.preferences.set(getAutreId(), forKey: "AutreId")
        self.preferences.synchronize()

        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez rafraichir la conversation" )
                    return
                }
                
                print(">>>>>>>>>>>>>>>>>>" + response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.statut = json["donnees"]!["statut"] as! String
                            
                            self.chat_demande = json["donnees"]!["demande"] as! String
                            self.chat_demandeur = json["donnees"]!["demandeur"] as! String
                            self.chat_receveur = json["donnees"]!["receveur"] as! String
                            self.chat_dem_st = json["donnees"]!["dem_st"] as! String
                            self.chat_rec_st = json["donnees"]!["rec_st"] as! String
                            self.chat_lieu = json["donnees"]!["lieu"] as! String
                            self.chat_rowcountlieux = json["rowcountlieux"] as! String
                            
                            //print(self.statut)
                            let jsonMessages = json["messages"] as! [[String: Any]]
                            
                            self.messages.removeAll()
                            
                            for jsonMessage in jsonMessages {
                                let msg = Message()
                                
                                if let id = jsonMessage["id"] as? String{
                                    msg.id = id
                                }
                                
                                if let chat = jsonMessage["chat"] as? String{
                                    msg.chat = chat
                                }
                                
                                if let user = jsonMessage["user"] as? String{
                                    msg.user = user
                                }
                                
                                if let message = jsonMessage["message"] as? String{
                                    msg.message = message
                                }
                                
                                if let datemessage = jsonMessage["datemessage"] as? String{
                                    msg.datemessage = datemessage
                                }
                                
                                if let vu = jsonMessage["vu"] as? String{

                                    //
                                    


                                    msg.vu = vu
                                }
                                
                                self.messages.append(msg)
                            }
                            
                            
                            DispatchQueue.main.async {
                                self.tableView.reloadData()
                                
                                print("chat_rec_st" + self.chat_rec_st)
                                
                                self.btnGift.isHidden = true
                                
                                if (self.chat_rec_st == "3" )
                                {
                                    self.btnGift.isHidden = false
                                }

                                var stringHaut = ""
//self.statut = "1";
                                if( self.messages.count == 0 ) {
                                    stringHaut = "Fais le premier pas et écris un message à "+self.chat.prenom
                                    self.activerEnvoiMessage()
                                    self.labelInformation.isHidden = false
                                    self.fullViewBoutonsInformations.isHidden = true
                                } else {
                                    if( self.messages.count == 1 && self.statut == "0" ) {
                                        if( self.messages[0].user == self.preferences.string(forKey: "userid") ) {
                                            stringHaut = self.chat.prenom+" doit accepter ta demande de chat, patiente encore un peu !"
                                            self.bloquerEnvoiMessage()
                                            self.labelInformation.isHidden = false
                                            self.fullViewBoutonsInformations.isHidden = true
                                        } else {
                                            stringHaut = self.chat.prenom+" t'a envoyé un message"
                                            self.bloquerEnvoiMessage()
                                            self.labelInformation.isHidden = false
                                            self.fullViewBoutonsInformations.isHidden = false
                                        }
                                    } else if( self.messages.count == 1 && self.statut == "1" ) {
                                        self.activerEnvoiMessage()
                                        self.labelInformation.isHidden = true
                                        self.fullViewBoutonsInformations.isHidden = true
                                    } else if( self.statut == "2" ) {
                                        stringHaut = "Malheureusement, cette conversation n'a pas pu aboutir ..."
                                        self.bloquerEnvoiMessage()
                                        self.labelInformation.isHidden = false
                                        self.fullViewBoutonsInformations.isHidden = true
                                    } else if( self.messages.count > 1 ) {
                                        self.activerEnvoiMessage()
                                        self.labelInformation.isHidden = true
                                        self.fullViewBoutonsInformations.isHidden = true
                                        
                                        let LibCasADemandeur = "Nous avons trouvé le lieu parfait en fonction de vos goûts communs pour vous rencontrer.\n\nChoisissez Allons-y pour le découvrir"
                                        let LibCasAReceveur  = "Nous avons trouvé le lieu parfait en fonction de vos goûts communs pour vous rencontrer.\n\nChoisissez Allons-y pour le découvrir"
                                        
                                        let LibCasBDemandeur = "Nous avons sélectionnés 3 lieux en fonction de vos goûts commun ou vous pourriez rencontrer " + self.chat.prenom + ".\n\nChoisissez Allons-y pour le découvrir"
                                        let LibCasBReceveur = self.chat.prenom + " a trouvé le lieu parfait en fonction de vos goûts communs et souhaiterait vous y rencontrer.\n\nChoisissez Allons-y pour découvrir ce lieu"
                                        
                                        let LibCasCDemandeur = "Le courant semble passer pourquoi ne pas vous rencontrez autour d’un verre ?\n\nChoisissez allons-y pour proposer à " + self.chat.prenom + " un rendez vous"
                                        let LibCasCReceveur = "Le courant semble passer, " + self.chat.prenom + " aimerait vous proposer un rendez vous.\n\nChoisissez allons y pour accepter."


                                        
                                        
                                        print("self.chat_demande", self.chat_demande)
                                        if (self.chat_demande == "1" && self.chat_demandeur == self.preferences.string(forKey: "userid"))
                                            {
                                            if (self.chat_rowcountlieux == "0")
                                                {
                                                    print("fullViewCoupon aff C")
                                                self.fullViewCouponLabel2.text = LibCasCDemandeur
                                                }
                                            else
                                                {
                                                    print("fullViewCoupon aff B")
                                                self.fullViewCouponLabel2.text = LibCasBDemandeur
                                                }
                                                
                                            self.fullViewCoupon.isHidden = false
                                            }
                                        else if (self.chat_demande == "2" && self.chat_receveur == self.preferences.string(forKey: "userid"))
                                            {
                                            print("fullViewCoupon aff")
                                            if (self.chat_rowcountlieux == "0")
                                                {
                                                    self.fullViewCouponLabel2.text = LibCasCReceveur
                                                }
                                                else
                                                {
                                                    self.fullViewCouponLabel2.text = LibCasBReceveur
                                                }
                                            self.fullViewCoupon.isHidden = false
                                            }
                                    }
                                }
                                
                                self.labelInformation.text = stringHaut
                                
                                var x = self.tableView.frame.origin.x
                                var y = self.tableView.frame.origin.y
                                var width = self.view.frame.width
                                var height = self.tableView.frame.height

                                if( self.labelInformation.isHidden ) {
                                    y = 0
                                } else {
                                    y = 120
                                }
                                height = height - y
                                self.tableView.frame = CGRect(x: x, y: y, width: width, height: height)
                                
                                self.loadViewIfNeeded()
                                self.tableViewScrollToBottom()
                            }
                        } else {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez rafraichir la conversation" )
                        }
                    } else {
                        self.afficherMessageErreur( message: "Une erreur est survenue, veuillez rafraichir la conversation" )
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez rafraichir la conversation" )
                }
            }
        } catch {
            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez rafraichir la conversation" )
        }

    
    
    }
    
    func tableViewScrollToBottom()
    {
        
        if( self.statut == "2" ) {
            print("tableViewScrollToBottom 2")
            if self.tableView.contentSize.height > self.tableView.frame.size.height
            {
                let offset:CGPoint = CGPoint(x: 0,y :self.tableView.contentSize.height+110-self.tableView.frame.size.height)
                self.tableView.setContentOffset(offset, animated: false)
            }
        } else {
            print("tableViewScrollToBottom else ")
            if self.tableView.contentSize.height > self.tableView.frame.size.height
            {
                let offset:CGPoint = CGPoint(x: 0,y :self.tableView.contentSize.height + 20 - self.tableView.frame.size.height)
                print("tableViewScrollToBottom" , offset)
                self.tableView.setContentOffset(offset, animated: false)
            }
        }
 
    }
    
    //************************************
    //************************************
    //************************************
    
    override func viewWillDisappear(_ animated: Bool) {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if self.ViewSaisie.frame.origin.y == 80{
                self.ViewSaisie.frame.origin.y -= keyboardSize.height - 10
                tableViewScrollToBottom()
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.ViewSaisie.frame.origin.y != 80 {
                self.ViewSaisie.frame.origin.y = 80
                tableViewScrollToBottom()
            }
    }
    
    func toutCacher() {
        
        
        //self.tableView.isHidden = true
        self.fullViewCoupon.isHidden = true
        self.labelInformation.isHidden = true
        self.fullViewBoutonsInformations.isHidden = true
        self.editMessage.isEnabled = false
        self.btnEnvoyer.isEnabled = false
        print ("toutCacher")
    }
    
    func afficherInformationErreur( message : String) {
        //self.tableView.isHidden = true
        self.fullViewCoupon.isHidden = true
        self.labelInformation.isHidden = false
        self.labelInformation.text = message
        self.fullViewBoutonsInformations.isHidden = true
        
        self.loadViewIfNeeded()
        
        bloquerEnvoiMessage()
    }
    
    func bloquerEnvoiMessage() {
        
        self.editMessage.isEnabled = false
        self.btnEnvoyer.isEnabled = false
        print ("bloquerEnvoiMessage")
    }
    
    func activerEnvoiMessage() {
        self.editMessage.isEnabled = true
        self.btnEnvoyer.isEnabled = true
        print ("activerEnvoiMessage")
    }
    
    func afficherMessageErreur( message : String) {
        let alert = UIAlertController(title: "Action impossible", message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: UIAlertActionStyle.default) {
            UIAlertAction in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        //let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        
        
        let keyboardFrame = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
        let animationDurarion = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)

        UIView.animate(withDuration: animationDurarion, animations: { () -> Void in
            print("self.bottomConstraintView.constant", changeInHeight)
//            self.bottomConstraintView.constant += changeInHeight
        })
        
    }
    
    //*******************************************************************
    //*******************************************************************
    //*******************************************************************

    @IBAction func clickEnvoyer(_ sender: Any) {

        envoiMessage()
    }
    
    func envoiMessage() {
        if( editMessage.text != "" ) {
            //self.present(alertController, animated: false, completion: nil)
            
            let params = ["type":"send_message", "userid":preferences.string(forKey: "userid") ?? "", "prenom":preferences.string(forKey: "prenom") ?? "", "symbole":preferences.string(forKey: "symbole") ?? "", "autreid":String(getAutreId()), "idchat":chat.id, "message":editMessage.text!] as [String : Any]
            
            do {
                let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
                opt.start { response in
                    if (response.error != nil) {
                       // self.alertController.dismiss(animated: false, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        //})
                        
                        return
                    }
                    

                    
                    do {
                        let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                        
                        if !json.isEmpty {
                            if json["success"] as! Int == 1 {
                                //self.alertController.dismiss(animated: false, completion: {
                                    DispatchQueue.main.async {
                                        self.editMessage.text = ""
                                        self.initialisation()
                                    }
                                //})
                            } else {
                                //self.alertController.dismiss(animated: false, completion: {
                                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                                //})
                            }
                        } else {
                            //self.alertController.dismiss(animated: false, completion: {
                                self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                            //})
                        }
                    } catch {
                        print("json error: \(error.localizedDescription)")
                        
                        //self.alertController.dismiss(animated: false, completion: {
                            self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                        //})
                    }
                }
            } catch {
                self.alertController.dismiss(animated: false, completion: {
                    self.afficherPopup(title : "Action impossible", message : "Une erreur est survenue, veuillez réessayer")
                })
            }
        }
    }

    
    
    //*******************************************************************
    //*******************************************************************
    //*******************************************************************

    
    @IBAction func clickSignaler(_ sender: Any) {
        if( self.statut == "2" ) {
            self.afficherPopup(title : "Action impossible", message : "Cette conversation est finie")
        } else if( self.messages.count == 0 ) {
            self.afficherPopup(title : "Action impossible", message : "Il n'y a aucun message !")
        } else {
            let alert = UIAlertController(title: "Signaler et bloquer", message: "Pour quel motif ?", preferredStyle: .actionSheet)
            
            alert.addAction(UIAlertAction(title: "Messages inappropriés", style: .default, handler: { (action) in
                self.envoyerSignalement(motif: "Messages inappropriés")
            }))
            
            alert.addAction(UIAlertAction(title: "Harcèlement", style: .default, handler: { (action) in
                self.envoyerSignalement(motif: "Harcèlement")
            }))
            
            alert.addAction(UIAlertAction(title: "Spam", style: .default, handler: { (action) in
                self.envoyerSignalement(motif: "Spam")
            }))
            
            alert.addAction(UIAlertAction(title: "Autre", style: .default, handler: { (action) in
                self.envoyerSignalement(motif: "Autre")
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }

    func envoyerSignalement( motif : String ) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"signaler_chat", "userid":preferences.string(forKey: "userid") ?? "", "autreid":String(getAutreId()), "idchat":chat.id, "note":motif] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
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
                                self.afficherPopup(title : "Signalement envoyé", message : "Votre signalement a bien été reçu")
                                
                                DispatchQueue.main.async {
                                    self.initialisation()
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
    
    //*******************************************************************
    //*******************************************************************
    //*******************************************************************

    
    @IBAction func clickInformationRefuser(_ sender: Any) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"refuser_chat", "userid":preferences.string(forKey: "userid") ?? "", "autreid":String(getAutreId()), "idchat":chat.id] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
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
                                self.afficherPopup(title : "Chat refusé", message : "Vous avez bien refusé ce chat !")
                                self.initialisation()
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
    
    @IBAction func clickInformationAccepter(_ sender: Any) {
        self.present(alertController, animated: true, completion: nil)
        
        let params = ["type":"valider_chat", "userid":preferences.string(forKey: "userid") ?? "", "autreid":String(getAutreId()), "idchat":chat.id] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
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
                                self.afficherPopup(title : "Chat accepté", message : "Vous avez bien accepté ce chat !")
                                self.initialisation()
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
    

    //*******************************************************************
    //*******************************************************************
    //*******************************************************************
    

    @IBAction func clickRafraichir(_ sender: Any) {
        initialisation()
    }
    
    func getAutreId() -> Int {
        if( preferences.string(forKey: "userid") == self.chat.user1 ) {
            return Int(chat.user2)!
        } else {
            return Int(chat.user1)!
        }
    }
    
    @IBAction func clickRetour(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
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
    
    //*******************************************
    //*******************************************
    //*******************************************

    
    @objc func prenomTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        print("prenom tapped")
        
        let params = ["type":"recupererinfos", "userid":String(getAutreId())] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
                    
                    return
                }
                
                //print(response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            let jsonUser = json["data"]!
                            
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
                            
                            let vc = self.storyboard?.instantiateViewController(withIdentifier: "profil") as! Controller_Profil
                            
                            vc.utilisateur = user
                            
                            self.present(vc, animated: false, completion: nil)
                        } else if json["success"] as! Int == 0 {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
                        } else {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
                        }
                    } else {
                        self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
                    }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
                }
            }
        } catch {
            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez réessayer" )
        }
    }
    //*******************************************************************
    //*******************************************************************
    //*******************************************************************
    
    @IBAction func clickGift(_ sender: Any) {
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "AffLieux") as! Controller_AffLieux
        vc.chatid = self.chat.id
        vc.lieuid = self.chat_lieu
        vc.demande = self.chat_demande
        
        if (self.chat_rec_st == "3" )
            {
            vc.aff = "1"
            }
        
        AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func clickCont(_ sender: Any) {
        
        if (chat_demandeur == preferences.string(forKey: "userid"))
            {
            if (self.chat_rowcountlieux == "0")
                {
                    dem_Acc_Cas_C()
                }
            else
                {
                    dem_Acc()
                }
                fullViewCoupon.isHidden = true
            }
        
        if (chat_receveur == preferences.string(forKey: "userid"))
        {
            if (self.chat_rowcountlieux == "0")
            {
                rec_Acc_Cas_C()
            }
            else
            {
                rec_Acc()
            }
            fullViewCoupon.isHidden = true
        }
    }

    @IBAction func clickRef(_ sender: Any) {
        
        if (chat_demandeur == preferences.string(forKey: "userid"))
        {
            dem_ref()
            fullViewCoupon.isHidden = true
        }

        if (chat_receveur == preferences.string(forKey: "userid"))
        {
            rec_ref()
            fullViewCoupon.isHidden = true
        }
    }

    
    func dem_Acc() {
        let params = ["type":"dem_Acc", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("dem_Acc" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.fullViewCoupon.isHidden = true
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "AffLieux") as! Controller_AffLieux
                            
                            vc.chatid = self.chat.id
                            AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)

                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    func rec_Acc() {
        let params = ["type":"rec_Acc", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("rec_Acc" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            self.fullViewCoupon.isHidden = true
                            let storyboard = UIStoryboard(name: "Main", bundle: nil)
                            let vc = storyboard.instantiateViewController(withIdentifier: "AffLieux") as! Controller_AffLieux
                            vc.chatid = self.chat.id
                            vc.lieuid = self.chat_lieu
                            vc.demande = self.chat_demande
                            AppDelegate.getCurrentViewController()?.present(vc, animated: true, completion: nil)                            
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    func rec_Acc_Cas_C() {
        let params = ["type":"rec_Acc_Cas_C", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("rec_Acc" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    func dem_ref() {
        let params = ["type":"dem_ref", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("dem_ref" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    func rec_ref() {
        let params = ["type":"rec_ref", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                print("rec_ref" ,response.text!)
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                            
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    //*****************************
    //*****************************
    //*****************************

    func dem_Acc_Cas_C() {
        let params = ["type":"dem_Acc_Cas_C", "idchat":chat.id] as [String : Any]
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print("dem_Acc" ,response.text!)
                
                do {
                    let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    if !json.isEmpty {
                        if json["success"] as! Int == 1 {
                        }
                    }
                } catch {
                }
            }
        } catch {
        }
    }
    
    //*****************************
    //*****************************
    //*****************************

}
