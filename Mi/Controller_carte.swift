

import UIKit
import MapKit

class Controller_carte: UIViewController, MKMapViewDelegate {
    
    @IBOutlet weak var mapView: MKMapView!
    let regionRadius: CLLocationDistance = 1000
    var currentLocation: CLLocation?
    
    var wtitle = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        
        if currentLocation != nil {
            let coordinateRegion = MKCoordinateRegionMakeWithDistance((currentLocation?.coordinate)!, regionRadius, regionRadius)
            mapView.setRegion(coordinateRegion, animated: true)
            
            let annotation = MKPointAnnotation()
            
            annotation.coordinate = (currentLocation?.coordinate)!
            annotation.title = wtitle
            mapView.addAnnotation(annotation)
            
        }
    }
    
    @IBAction func dismissVC(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}

