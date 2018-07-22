//
//  ARViewController.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import UIKit
import AVFoundation
import ARCL
import CoreLocation
import Firebase

class ARViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate {

    var sceneLocationView = SceneLocationView()
    var db: Firestore!
    var spots = [Spot]()
    var hitSpot: Spot?
    var hitAlert: UIAlertController?
    var locationNodes = [LocationNode]()
    var timer: Timer!
    var isEnabled = true
    var locationManager = CLLocationManager()
    var location: CLLocation?
    var storageRef: StorageReference!
    
    
    @IBOutlet weak var cameraButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sceneLocationView.run()
        view.addSubview(sceneLocationView)
        

        // TODO: しばらくそこに待機したら、開くようにする　
        timer = Timer.scheduledTimer(withTimeInterval: 0.2, repeats: true) { (timer) in
            let hitResults = self.sceneLocationView.hitTest(CGPoint(x: self.sceneLocationView.bounds.width / 2, y: self.sceneLocationView.bounds.height / 2) , options: [:])
            if let hitResult = hitResults.first, self.isEnabled && (self.hitAlert == nil || !self.hitAlert!.isBeingDismissed) {
                let hitNode = self.locationNodes.filter { $0.contains(hitResult.node)  }.first
                self.hitSpot = self.spots.filter {$0.documentID == hitNode?.name}.first
                
                if let hitComment = self.hitSpot {
                    self.isEnabled = false
                    self.hitAlert = UIAlertController(title: hitComment.title, message: hitComment.description, preferredStyle: .alert)
                    self.hitAlert?.addAction(UIAlertAction(title: "🔍 Show", style: .cancel, handler: { (action) in
                        self.performSegue(withIdentifier: "ShowSpotDetail", sender: nil)
                    }))
                    self.hitAlert?.addAction(UIAlertAction(title: "× Close", style: .default, handler: { (action) in
                        self.isEnabled = true
                    }))
                    self.present(self.hitAlert!, animated: true, completion: nil)
                }
            }
        }
        view.bringSubview(toFront: cameraButton)
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        sceneLocationView.frame = view.bounds
    }
    
    @IBAction func take(_ sender: UIButton) {
        sceneLocationView.pause()
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        present(vc, animated: true, completion: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        isEnabled = true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        timer.invalidate()
        timer = nil
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        sceneLocationView.run()
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) {
            if let pickedImage = info[UIImagePickerControllerOriginalImage]
                as? UIImage {
                let alert = UIAlertController(title: "📝Add Title and Description", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "× Cancel", style: .cancel, handler: { (action) in
                    self.sceneLocationView.run()
                }))
                alert.addAction(UIAlertAction(title: "📤 Send", style: .default, handler: { (action) in
                    var title = ""
                    var description = ""
                    
                    guard let location = self.location else {
                        return
                    }
                    
                    alert.textFields?.forEach {
                        switch $0.tag {
                        case 1:
                            if let tmpTitle = $0.text {
                                title = tmpTitle
                            }
                            break
                        case 2:
                            if let tmpDescription = $0.text {
                                description = tmpDescription
                            }
                        default:
                            break
                        }
                    }
                    
                    
                    let fileName = NSUUID().uuidString + ".jpg"
                    let photoRef = self.storageRef.child(fileName)
                    
                    let _ = photoRef.putData(UIImageJPEGRepresentation(pickedImage.resized(toWidth: 1024)!, 0.7)!, metadata: nil) { (metadata, error) in
                        self.db.collection("spots").addDocument(data: [
                            "title":title,
                            "description":description,
                            "geopoint":GeoPoint(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude),
                            "photo":fileName
                            ])
                        self.sceneLocationView.run()
                    }
                    
                    
                    
                }))
                alert.addTextField { (textField) in
                    textField.tag = 1
                    textField.placeholder = "Title"
                }
                alert.addTextField { (textField) in
                    textField.tag = 2
                    textField.placeholder = "Description"
                }
                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
    }
    

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let vc = segue.destination as? SpotDetailViewController
        vc?.geoPoint = hitSpot!.geopoint
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let isFirst = location == nil
        location = locations.first
        
        if let location = location, isFirst {
            let lat = 0.0144927536231884
            let lon = 0.0181818181818182
            let distance = 10.0
            
            let lowerLat = location.coordinate.latitude - (lat * distance)
            let lowerLon = location.coordinate.longitude - (lon * distance)
            
            let greaterLat = location.coordinate.latitude + (lat * distance)
            let greaterLon = location.coordinate.longitude + (lon * distance)
            
            let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
            let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
            
            db = Firestore.firestore()
            storageRef = Storage.storage().reference()
            db.collection("spots")
                .whereField("geopoint", isGreaterThan: lesserGeopoint)
                .whereField("geopoint", isLessThan: greaterGeopoint)
                .getDocuments { (querySnapShot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        querySnapShot?.documents.forEach {
                            let comment = Spot(document: $0)
                            self.spots.append(comment)
                            
                            let coordinate = CLLocationCoordinate2D(latitude: comment.geopoint.latitude, longitude: comment.geopoint.longitude)
                            let location = CLLocation(coordinate: coordinate, altitude: 10)
                            let image = #imageLiteral(resourceName: "icon_108190_256")
                            
                            let annotationNode = LocationAnnotationNode(location: location, image: image)
                            annotationNode.name = comment.documentID
                            self.sceneLocationView.addLocationNodeWithConfirmedLocation(locationNode: annotationNode)
                            self.locationNodes.append(annotationNode)
                        }
                    }
            }
        }
        
    }

}
