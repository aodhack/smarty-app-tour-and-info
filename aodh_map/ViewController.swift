//
//  ViewController.swift
//  aodh_map
//
//  Created by 宮川奈々 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import UIKit
import NMAKit
import Firebase

class ViewController: UIViewController,NMAMapViewDelegate {
    
    @IBOutlet weak var mapView: NMAMapView!
    
    var publics = [[String:Any]]()
    var events = [[String:Any]]()
    
    @IBOutlet weak var placeNameLabel: UILabel!
    @IBOutlet weak var townAndVillageNameLabel: UILabel!
    @IBOutlet weak var describeLabel: UILabel!
    
    var selectedAnnotationLatitude : Double?
    var selectedAnnotationLongitude : Double?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.23.466683, 120.444607
        let geoCoordCenter = NMAGeoCoordinates(latitude: 23.466683, longitude: 120.444607)
        self.mapView.set(geoCenter: geoCoordCenter, animation: .none)
        self.mapView.delegate = self
        mapView.copyrightLogoPosition = NMALayoutPosition.bottomCenter
        mapView.projectionType = .mercator
        mapView.zoomLevel = 15.2
        self.loadJSON()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //set map view with geo center
        
        //        addMapCircle()
    }
    
    func loadJSON() {
        guard let publicsPath = Bundle.main.path(forResource: "tw_public", ofType: "json") else { return }
        let publicsUrl = URL(fileURLWithPath: publicsPath)
        
        guard let eventsPath = Bundle.main.path(forResource: "tw_event", ofType: "json") else { return }
        let eventsUrl = URL(fileURLWithPath: eventsPath)
        
        do {
            //公共施設のJSON読み込み
            let publicsData = try Data(contentsOf: publicsUrl)
            publics =  try JSONSerialization.jsonObject(with: publicsData, options: []) as! [[String : Any]]
            
            //イベントのJSON読み込み
            let eventsData = try Data(contentsOf: eventsUrl)
            events =  try JSONSerialization.jsonObject(with: eventsData, options: []) as! [[String : Any]]
            self.setAnnotation()
        } catch  {
            print(error)
        }
    }
    
    func setAnnotation() {
        print("publics count : \(publics.count)")
        var count = 0
        for public_info in publics {
            if let longitude  = public_info["X"] as? Double,
                let latitude  = public_info["Y"] as? Double {
                //25.362029, 119.775953　台湾の左上
                //21.892394, 122.010813 台湾の右上
                if longitude > 119.775953 && longitude < 122.010813 && latitude > 21.892394 && latitude < 25.362029 {
                    count += 1
                    let annotation = NMAMapMarker()
                    annotation.coordinates = NMAGeoCoordinates(latitude: latitude, longitude: longitude)
                    annotation.icon = NMAImage(uiImage: UIImage(named: "blue_pin")!)
                    annotation.setSize(CGSize(width: 100.0, height: 100.0), forZoomLevel: UInt(13))
                    annotation.isDraggable = false
//                    annotation.setValue(public_info["Place_name"] ?? "", forKey: "Place_name")
//                    annotation.setValue(public_info["Town"] ?? "", forKey: "Town")
//                    annotation.setValue(public_info["Village"] ?? "", forKey: "Village")
//                    annotation.setValue(public_info["Place_describe"] ?? "", forKey: "Place_describe")
//                    annotation.setValuesForKeys(public_info)
                    
                    self.mapView.add(mapObject: annotation)
                }
            }
            if count >= 5000 {
                break
            }
        }
        
        count = 0
        print(events.count)
        for event_info in events {
            if let longitude  = event_info["latitude"] as? Double,
                let latitude  = event_info["longitude"] as? Double {
                count += 1
                let annotation = NMAMapMarker()
                annotation.coordinates = NMAGeoCoordinates(latitude: latitude, longitude: longitude)
                annotation.icon = NMAImage(uiImage: UIImage(named: "green_pin")!)
                annotation.setSize(CGSize(width: 100.0, height: 100.0), forZoomLevel: UInt(13))
                annotation.isDraggable = false
//                annotation.setValuesForKeys(event_info)
                self.mapView.add(mapObject: annotation)
            }
        }
    }
    
    func mapView(_ mapView: NMAMapView, didSelect objects: [NMAViewObject]) {
        print("osareta!!!!!!")
        let annotation : NMAMapMarker = objects.first as! NMAMapMarker
        selectedAnnotationLongitude = annotation.coordinates.longitude
        selectedAnnotationLatitude = annotation.coordinates.latitude
        self.performSegue(withIdentifier: "ShowDetail", sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        var detailVC = segue.destination as? SpotDetailViewController
        detailVC?.geoPoint = GeoPoint(latitude: selectedAnnotationLatitude!, longitude: selectedAnnotationLongitude!)
    }
}
