//
//  Controller_Accueil.swift
//  Timi
//
//  Created by Julien on 15/05/2017.
//  Copyright © 2017 Julien. All rights reserved.
//

import UIKit
import Foundation
import XLPagerTabStrip
import MapKit
import CoreLocation
import SwiftHTTP

class Controller_Accueil: ButtonBarPagerTabStripViewController, CLLocationManagerDelegate {
    
    @IBOutlet weak var shadowView: UIView!
    let blueInstagramColor = UIColor(red: 240/255.0, green: 88/255.0, blue: 42/255.0, alpha: 1.0)

    var locationManager:CLLocationManager!

    var envoilocation = false

    var preferences : UserDefaults = UserDefaults.standard

    override func viewDidLoad() {
        

        print("Controller_Accueil ---")

        // change selected bar color
        settings.style.buttonBarBackgroundColor = .white
        settings.style.buttonBarItemBackgroundColor = .white
        settings.style.selectedBarBackgroundColor = blueInstagramColor
        settings.style.buttonBarItemFont = .boldSystemFont(ofSize: 18)
        settings.style.selectedBarHeight = 2.0
        settings.style.buttonBarMinimumLineSpacing = 0
        settings.style.buttonBarItemTitleColor = .black
        settings.style.buttonBarItemsShouldFillAvailiableWidth = true
        settings.style.buttonBarLeftContentInset = 0
        settings.style.buttonBarRightContentInset = 0
        self.moveToViewController(at: 1, animated: false)
        changeCurrentIndexProgressive = { [weak self] (oldCell: ButtonBarViewCell?, newCell: ButtonBarViewCell?, progressPercentage: CGFloat, changeCurrentIndex: Bool, animated: Bool) -> Void in
            guard changeCurrentIndex == true else { return }
            oldCell?.label.textColor = .black
            newCell?.label.textColor = self?.blueInstagramColor
        }
        super.viewDidLoad()
    }
    
    override func viewControllers(for pagerTabStripController: PagerTabStripViewController) -> [UIViewController] {

        let child_1 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accueilProfil")
        let child_2 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accueilRecherche")
        let child_3 = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "accueilChat")
        return [ child_1, child_2, child_3 ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        determineMyCurrentLocation()
    }
    
    
    //***********************************
    //***********************************
    //***********************************

    func determineMyCurrentLocation() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestAlwaysAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
            //locationManager.startUpdatingHeading()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation:CLLocation = locations[0] as CLLocation
        
        // Call stopUpdatingLocation() to stop listening for location updates,
        // other wise this function will be called every time when user location changes.
        
        // manager.stopUpdatingLocation()
        
        print("============>> user latitude = \(userLocation.coordinate.latitude)")
        print("============>> user longitude = \(userLocation.coordinate.longitude)")
        
        if( !envoilocation && Global().isConnectedToNetwork() ) {
            envoilocation = true

            locationManager.stopUpdatingLocation()
            
            print("envoi position")
            
            self.envoiPosition(latitude: String(userLocation.coordinate.latitude), longitude: String(userLocation.coordinate.longitude))
        }
        
        locationManager.stopUpdatingLocation()
    }
    
    func envoiPosition(latitude: String, longitude : String) {
        let params = ["type":"send_geolocalisation", "userid":preferences.string(forKey: "userid") ?? "", "latitude":latitude, "longitude":longitude] as [String : Any]
        
        do {
            let opt = try HTTP.POST(Global().url+"gestion_user.php", parameters: params)
            opt.start { response in
                if (response.error != nil) {
                    return
                }
                
                print(response.text!)
            }
        } catch { }
    }
    
    //***********************************
    //***********************************
    //***********************************

    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
