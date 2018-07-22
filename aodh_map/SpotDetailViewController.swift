//
//  SpotDetailViewController.swift
//  aodh_map
//
//  Created by 海崎惇志 on 2018/07/21.
//  Copyright © 2018年 宮川奈々. All rights reserved.
//

import UIKit
import Firebase
import Kingfisher

class SpotDetailViewController: UIViewController, UITableViewDataSource, RateDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var photoCollectionView: UICollectionView!
    
    var comments = [Comment]()
    var listner: ListenerRegistration!
    var db: Firestore!
//    var geoPoint = GeoPoint(latitude: 35.416294, longitude: 136.746457)
    var geoPoint = GeoPoint(latitude: 0, longitude: 0)
//    var photoComments: [Comment] {
//        return comments.filter { $0.photo != nil && $0.photo != "" }
//    }
    var photoComments = [Comment]()
    
    var storageRef: StorageReference!

    override func viewDidLoad() {
        super.viewDidLoad()
        

        // Do any additional setup after loading the view.
        db = Firestore.firestore()
        storageRef = Storage.storage().reference()

        // ~1 mile of lat and lon in degrees
        let lat = 0.0144927536231884
        let lon = 0.0181818181818182
        let distance = 1.0
        
        let lowerLat = geoPoint.latitude - (lat * distance)
        let lowerLon = geoPoint.longitude - (lon * distance)
        
        let greaterLat = geoPoint.latitude + (lat * distance)
        let greaterLon = geoPoint.longitude + (lon * distance)
        
        let lesserGeopoint = GeoPoint(latitude: lowerLat, longitude: lowerLon)
        let greaterGeopoint = GeoPoint(latitude: greaterLat, longitude: greaterLon)
        
        listner = db.collection("comments")
            .whereField("geopoint", isGreaterThan: lesserGeopoint)
            .whereField("geopoint", isLessThan: greaterGeopoint)
            .addSnapshotListener { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                querySnapshot?.documentChanges.forEach({ (documentChange) in
                    switch documentChange.type {
                    case .added:
                        self.comments.append(Comment(document: documentChange.document))
                    case .modified:
                        let index = self.comments.index(where: { (comment) -> Bool in
                            comment.documentID == documentChange.document.documentID
                        })
                        
                        if let index = index {
                            self.comments[index] = Comment(document: documentChange.document)
                        }
                    case .removed:
                        let index2 = self.comments.index(where: { (comment) -> Bool in
                            comment.documentID == documentChange.document.documentID
                        })
                        if let index2 = index2 {
                            self.comments.remove(at: index2)
                        }
                    }
                })
                self.comments.sort(by: { (a, b) -> Bool in
                    (a.goodCount - a.badCount) > (b.goodCount - b.badCount)
                })
                self.tableView.reloadData()
                self.photoCollectionView.reloadData()
            }
        }
        
        db.collection("spots")
            .whereField("geopoint", isGreaterThan: lesserGeopoint)
            .whereField("geopoint", isLessThan: greaterGeopoint)
            .getDocuments { (querySnapShot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    querySnapShot?.documents.forEach {
                        var comment = Comment()
                        comment.photo = $0.get("photo") as! String
                        self.photoComments.append(comment)
                        self.photoCollectionView.reloadData()
                    }
                }
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        listner.remove()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell") as! CommentTableViewCell
        let comment = comments[indexPath.row]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .medium
        
        
        cell.commentLabel.text = comment.text
        cell.goodButton.setTitle("👍\(comment.goodCount!)", for: .normal)
        cell.badButton.setTitle("👎\(comment.badCount!)", for: .normal)
        cell.dateLabel.text = dateFormatter.string(from: comment.createdAt)
        cell.comment = comment
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photoComments.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "photoCell", for: indexPath) as! PhotoCollectionViewCell
        let comment = photoComments[indexPath.row]
        let imageRef = storageRef.child(comment.photo!)
        imageRef.downloadURL { (url, error) in
            if let _ = error {
                
            } else {
                cell.imageView.kf.setImage(with: url)
            }
        }
        
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func good(comment: Comment) {
        db.collection("comments").document(comment.documentID).updateData(["good_count":comment.goodCount + 1])
    }
    
    func bad(comment: Comment) {
        db.collection("comments").document(comment.documentID).updateData(["bad_count":comment.badCount + 1])
    }
    
    @IBAction func add(_ sender: UIBarButtonItem) {
        let alert = UIAlertController(title: "📝Add Comment", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "× Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "📤 Send", style: .default, handler: { (action) in
            if let text = alert.textFields?.first?.text, text != "" {
                self.db.collection("comments").addDocument(data: [
                    "bad_count":0,
                    "created_at":Date(),
                    "geopoint":self.geoPoint,
                    "good_count":0,
                    "text":text
                    ])
            }
        }))
        alert.addTextField { (textField) in
        }
        present(alert, animated: true, completion: nil)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

protocol RateDelegate {
    func good(comment: Comment)
    func bad(comment: Comment)
}
