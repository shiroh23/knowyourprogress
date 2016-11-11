//
//  mainScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 10..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Felh
{
    var email: String = ""
    var currSem: Int = 0
    var finiSem: Int = 0
    var password: String = ""
    var szak: String = ""
}

struct Targy
{
    var nev: String = ""
    var kredit: String = ""
    var felev: String = ""
    var targykod: String = ""
}

class main: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var productArray = NSArray()
    var currentSubjects = [String]()
    var melyiket: Int = 0
    var semesterSubjCount: Int = 0
    var felh = Felh()
    
    var searchResults = [NSManagedObject]()
    
    func readPropertyList(szak: String)
    {
        let plistPath:String? = Bundle.main.path(forResource: szak, ofType: "plist")!
        productArray = NSArray(contentsOfFile: plistPath!)!
    }
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.getUserData()
        print(felh)
        
        readPropertyList(szak: felh.szak)
        
        semesterSubjCount = self.targyCounter()
        
        felevLbl.text = "\(felh.currSem). félév"
        
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
        return semesterSubjCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let row = indexPath.row
        //cell.textLabel?.text = getNev(pId: row)
        cell.textLabel?.text = currentSubjects[row]
        return cell
    }
 
    func getNev(pId: Int) -> String{
        var nev: String = ""
        
        var rekord: Dictionary<String, AnyObject>
        rekord = productArray.object(at: pId) as! Dictionary<String, AnyObject>
        
        nev = rekord["nev"] as! String
        
        return nev;
    }
    
    func targyCounter() -> Int
    {
        var count: Int = 0
        var felev: String = ""
        var nev: String = ""
        var rekord: Dictionary<String, AnyObject>
        
        for i in (0..<productArray.count)
        {
            rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
            felev = rekord["felev"] as! String
            if (felev == String(felh.currSem))
            {
                nev = rekord["nev"] as! String
                currentSubjects.append(nev)
                print(currentSubjects.last!)
                count += 1
            }
        }
        
        return count
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
            
            let keresettTargy = self.currentSubjects[index!]
            var targy: String = ""
            var rekord: Dictionary<String, AnyObject>
            
            for i in (0..<productArray.count)
            {
                rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
                targy = rekord["nev"] as! String
                if (targy == keresettTargy)
                {
                    let newSubject = self.productArray.object(at: i) as! Dictionary<String, AnyObject>
                    destination.subject = newSubject
                }
            }
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
    
    // MARK: CoreData cucc
    
    func getUserData ()
    {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        var useableszak: String = ""
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            //print ("találatok száma = \(searchResults.count)")
            
            for users in searchResults as [NSManagedObject]
            {
                if (users.value(forKey: "logged") as! Bool == true)
                {
                    //print("megtalalta")
                    felh.email = users.value(forKey: "email") as! String
                    felh.currSem = users.value(forKey: "currentSemester") as! Int
                    felh.finiSem = users.value(forKey: "finishedSemester") as! Int
                    felh.password = users.value(forKey: "password") as! String
                    useableszak = users.value(forKey: "major") as! String
                    
                    switch useableszak {
                    case "mérnökinformatikus":
                        felh.szak = "mernokinfoData"
                        break
                    case "programtervező informatikus":
                        felh.szak = "proginfoData"
                        break
                    case "gazdasági informatikus":
                        felh.szak = "gazdinfoData"
                        break
                    default:
                        felh.szak = ""
                        break
                    }
                    
                    break
                }
            }
            
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
    }
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
}
