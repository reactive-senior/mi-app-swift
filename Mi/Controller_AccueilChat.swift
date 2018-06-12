//
//  Controller_AccueilChat.swift
//  Timi
//
//  Created by Julien on 15/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import SwiftHTTP
import Nuke

import Crashlytics
import Firebase

class Controller_AccueilChat: UIViewController, IndicatorInfoProvider, UITableViewDataSource, UITableViewDelegate {
    var preferences : UserDefaults = UserDefaults.standard
    
    var chats = [Chat]()
    
    @IBOutlet weak var txtInfo: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.hideKeyboardWhenTappedAround()

        self.tableView.separatorStyle = .none

        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(Controller_AccueilChat.tapFunction))
        txtInfo.isUserInteractionEnabled = true
        txtInfo.addGestureRecognizer(tap)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Chat")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if( chats.count == 0 && Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                self.lancerRercherche()
            }
        }
    }
    
    @objc func tapFunction(sender:UITapGestureRecognizer) {
        if( chats.count == 0 && Global().isConnectedToNetwork() ) {
            DispatchQueue.main.async {
                self.lancerRercherche()
            }
        } else {
            DispatchQueue.main.async {
                self.afficherChats()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chats.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellChat", for: indexPath as IndexPath) as! ChatViewCell
        
        cell.selectionStyle = .none
        
        let chat = self.chats[indexPath.item]
        
        circularImage(photoImageView: cell.imageProfil)

        DispatchQueue.main.async {
            cell.imageProfil.image = nil
            
            Nuke.loadImage(with: URL(string: Global().url+"photo_profil/"+(chat.photoprofil))!, into: cell.imageProfil)
        }
        
        cell.txtPrenom.text = chat.prenom
        cell.txtDernierMessage.text = chat.lastmessage
        
        if (chat.datelastmessage == "0000-00-00 00:00:00")
        {
            cell.txtDate.text = ""
        }
        else
        {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateLastMessage = dateFormatter.date(from: chat.datelastmessage)
            print("dateLastMessage" + (dateLastMessage?.debugDescription)!)
            
            if( NSCalendar.current.isDateInToday(dateLastMessage!) ) {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "HH:mm"
                cell.txtDate.text = dateFormatter.string(from:dateLastMessage!)
            } else {
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "dd/MM/yyyy"
                cell.txtDate.text = dateFormatter.string(from:dateLastMessage!)
            }

        }
        
        if( chat.nbmessagesnonlus == "0" ) {
            cell.txtPrenom.font = UIFont.systemFont(ofSize: 14.0)
            cell.txtDernierMessage.font = UIFont.systemFont(ofSize: 12.0)
        } else {
            cell.txtPrenom.font = UIFont.boldSystemFont(ofSize: 14.0)
            cell.txtDernierMessage.font = UIFont.boldSystemFont(ofSize: 12.0)
        }
        
        if( chat.symbole == "pique" ) {
            cell.imageSymbole.image = UIImage(named: "pique_red")
        } else if( chat.symbole == "coeur" ) {
            cell.imageSymbole.image = UIImage(named: "coeur_red")
        } else if( chat.symbole == "carreau" ) {
            cell.imageSymbole.image = UIImage(named: "carreau_red")
        } else if( chat.symbole == "trefle" ) {
            cell.imageSymbole.image = UIImage(named: "trefle_red")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(indexPath.item)
        
        //Crashlytics.sharedInstance().crash()
        
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "chatController") as! Controller_Chat
        
        vc.chat = chats[indexPath.item]
        
        self.present(vc, animated: true, completion: nil)
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
    
    func lancerRercherche() {
        let params = ["type":"get_chats", "userid":preferences.string(forKey: "userid") ?? ""] as [String : Any]
        
        
        print ("params" , params)
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_message.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger vos conversations" )
                    print ("response erreur" , response)
                    return
                }
                
                print(response.text!)
                
                do {
                        let json = try JSONSerialization.jsonObject(with: response.data , options: .mutableContainers) as! Dictionary<String, AnyObject>
                    
                        if !json.isEmpty {
                                if json["success"] as! Int == 1 {
                                let jsonChats = json["chats"] as! [[String: Any]]
                            
                                self.chats.removeAll()
                            
                                for jsonChat in jsonChats{
                                    let chat = Chat()
                                    
                                    if let id = jsonChat["id"] as? String{
                                        chat.id = id
                                    }
                                        
                                    if let user1 = jsonChat["user1"] as? String{
                                        chat.user1 = user1
                                    }
                                        
                                    if let user2 = jsonChat["user2"] as? String{
                                        chat.user2 = user2
                                    }
                                    
                                    if let statut = jsonChat["statut"] as? String{
                                        chat.statut = statut
                                    }
                                    
                                    if let lastmessage = jsonChat["lastmessage"] as? String{
                                        chat.lastmessage = lastmessage
                                    }
                                    
                                    if let datelastmessage = jsonChat["datelastmessage"] as? String{
                                        chat.datelastmessage = datelastmessage
                                    }
                                    
                                    if let nbmessagesnonlus = jsonChat["nbmessagesnonlus"] as? String{
                                        chat.nbmessagesnonlus = nbmessagesnonlus
                                    }
                                    
                                    if let photoprofil = jsonChat["photoprofil"] as? String{
                                        chat.photoprofil = photoprofil
                                    }
                                    
                                    if let prenom = jsonChat["prenom"] as? String{
                                        chat.prenom = prenom
                                    }
                                    
                                    if let symbole = jsonChat["symbole"] as? String{
                                        chat.symbole = symbole
                                    }
                                    
                                    self.chats.append(chat)
                                }
                                
                                print(self.chats.count)
                                    
                                DispatchQueue.main.async {
                                    if( self.chats.count == 0 ) {
                                        self.afficherMessageErreur( message: "Vous n'avez pas encore de conversation en cours, veuillez cliquer pour actualiser" )
                                    } else {
                                        self.afficherChats()
                                    }
                                }
                            } else {
                                self.afficherMessageErreur( message: "Pas de conversation en cours" )
                            }
                        } else {
                            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger vos conversations" )
                        }
                } catch {
                    print("json error: \(error.localizedDescription)")
                    
                    self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger vos conversations" )
                }
            }
        } catch {
            self.afficherMessageErreur( message: "Une erreur est survenue, veuillez cliquer pour recharger vos conversations" )
        }
    }
    
    func afficherMessageErreur( message: String ) {
        DispatchQueue.main.async {
            self.txtInfo.isHidden = false
            self.tableView.isHidden = true
            
            self.txtInfo.text = message
        }
    }
    
    func afficherChats() {
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
}
