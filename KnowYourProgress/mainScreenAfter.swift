//
//  mainScreenAfter.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 11..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit

class mainAfter: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    var productArray = NSArray()
    var melyiket: Int = 0
    
    func readPropertyList(){
        
        let plistPath:String? = Bundle.main.path(forResource: "gazdinfoData", ofType: "plist")!
        
        productArray = NSArray(contentsOfFile: plistPath!)!
        
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        readPropertyList()
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeRight.direction = UISwipeGestureRecognizerDirection.right
        self.felevLbl.addGestureRecognizer(swipeRight)
        
        //profil adatlap megtekintése
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.felevLbl.addGestureRecognizer(swipeDown)
        
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeLeft.direction = UISwipeGestureRecognizerDirection.left
        self.felevLbl.addGestureRecognizer(swipeLeft)
        
        
    }
    
    func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case UISwipeGestureRecognizerDirection.right:
                print("Swiped right")
            case UISwipeGestureRecognizerDirection.down:
                print("Swiped down")
                self.openNewPage(name: "profile")
            case UISwipeGestureRecognizerDirection.left:
                print("Swiped left")
            case UISwipeGestureRecognizerDirection.up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return productArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let row = indexPath.row
        cell.textLabel?.text = getNev(pId: row)
        return cell
        
    }
    
    func getNev(pId: Int) -> String{
        var nev: String = ""
        var rekord: Dictionary<String, AnyObject>
        rekord = productArray.object(at: pId) as! Dictionary<String, AnyObject>
        
        nev = rekord["nev"] as! String
        return nev;
    }
    
    /*func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
     {
     self.melyiket = indexPath.row
     print("\(self.melyiket) na melyik lesz")
     let newSubject = self.productArray.object(at: self.melyiket) as! Dictionary<String, AnyObject>
     let nev: String = newSubject["nev"] as! String
     let targykod: String = newSubject["targykod"] as! String
     let kredit: String = newSubject["kredit"] as! String
     let felev: String = newSubject["felev"] as! String
     print("\(nev) es \(targykod) es \(kredit) es \(felev)")
     let destinationVC = detailviewScreen()
     destinationVC.targykod = "gagyi"
     destinationVC.kredit = "fos"
     destinationVC.nev = "ez egy csalas"
     destinationVC.felev = "utalom"
     self.present(destinationVC, animated: true, completion: nil)
     }*/
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segue") {
            let destination = segue.destination as! detailviewScreen
            let index = tableView.indexPathForSelectedRow?.row
            let newSubject = self.productArray.object(at: index!) as! Dictionary<String, AnyObject>
            destination.subject = newSubject
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let more = UITableViewRowAction(style: .normal, title: "More") { action, index in
            print("more button tapped")
            self.melyiket = indexPath.row
        }
        
        more.backgroundColor = UIColor.lightGray
        
        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
            print("favorite button tapped")
            self.melyiket = indexPath.row
        }
        favorite.backgroundColor = UIColor.orange
        
        let share = UITableViewRowAction(style: .normal, title: "Share") { action, index in
            print("share button tapped")
            self.melyiket = indexPath.row
        }
        share.backgroundColor = UIColor.blue
        
        return [share, favorite, more]
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name)
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
