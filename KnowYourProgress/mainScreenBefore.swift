//
//  mainScreenBefore.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 11..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

struct Elvegzett
{
    var name: String = ""
    var targykod: String = ""
    var kredit: String = ""
    var felev: String = ""
    var elvegzett: Bool = false
}

class mainBefore: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var productArray = NSArray()
    var finishedSubjects = [String]()
    var melyiket: Int = 0
    var semesterSubjCount: Int = 0
    var finishedSubjCount: Int = 0
    var felh = Felh()
    var tanar = Oktato()
    var elvegzettek = [Elvegzett]()
    var index: IndexPath = []
    
    var searchResults = [NSManagedObject]()
    var teacherResults = [NSManagedObject]()
    var doneSubjResults = [NSManagedObject]()
    
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
        self.finishedSubjCount = self.getDoneSubjData(email: felh.email)
        //semesterSubjCount = self.targyCounter()
        
        felevLbl.text = "Az elvegzett felevek: \(felh.finiSem)"
        felevLbl.adjustsFontSizeToFitWidth = true
        felevLbl.minimumScaleFactor = 0.5
        
        //profil adatlap megtekintése
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
        swipeDown.direction = UISwipeGestureRecognizerDirection.down
        self.felevLbl.addGestureRecognizer(swipeDown)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectRow(at: self.index, animated: true)
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
        return finishedSubjCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        let row = indexPath.row
        //cell.textLabel?.text = getNev(pId: row)
        cell.textLabel?.text = finishedSubjects[row]
        //cell.textLabel?.text = elvegzettek[row].name
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segue") {
            let destination = segue.destination as! detailviewScreen
            let index = tableView.indexPathForSelectedRow?.row
            self.index = tableView.indexPathForSelectedRow!
            
            let keresettTargy = self.finishedSubjects[index!]
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
                    tanar = self.getTeachers(keresettTargy: keresettTargy)
                    destination.tutor = tanar
                    destination.path = self.index
                    //destination.completedBtn.isHidden = true
                }
            }
        }
        else if (segue.identifier == "segueAfter")
        {
            
        }
    }
    
    private func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> UITableViewRowAction? {
        
        let favorite = UITableViewRowAction(style: .normal, title: "Favorite") { action, index in
            print("favorite button tapped")
            self.melyiket = indexPath.row
        }
        favorite.backgroundColor = UIColor.orange
        
        return favorite
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
    
    // MARK: CoreData felhasználói adatok kinyerése
    
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
    
    // MARK: CoreData tanárkereső
    
    func getTeachers (keresettTargy: String) -> Oktato {
        
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        var tanarka = Oktato()
        var talalt: Bool = false
        
        do
        {
            teacherResults = try getContext().fetch(fetchRequest)
            
            for teacher in teacherResults as [NSManagedObject]
            {
                tanarka.subject = (teacher.value(forKey: "subject") as! String)
                
                if (tanarka.subject == keresettTargy)
                {
                    tanarka.id = Int16(teacher.value(forKey: "id") as! Int)
                    tanarka.review = Int16(teacher.value(forKey: "review") as! Int)
                    tanarka.name = (teacher.value(forKey: "name") as! String)
                    talalt = true
                }
            }
            
        }
        catch
        {
            print("Error with request: \(error)")
        }
        if (talalt == true)
        {
            return tanarka
        }
        else
        {
            tanarka.name = "nincs"
            return tanarka
        }
    }
    
    // MARK: CoreData elvégzett tárgykereső
    
    func getDoneSubjData (email: String) -> Int
    {
        
        let fetchRequest: NSFetchRequest<DoneSubj> = DoneSubj.fetchRequest()
        var useableEmail: String = ""
        var nev: String = ""
        var isDone: Bool = false
        //var doneSubj = Elvegzett()
        var counter: Int = 0
        
        do
        {
            doneSubjResults = try getContext().fetch(fetchRequest)
            
            print ("elvégzett tárgyak száma = \(doneSubjResults.count)")
            
            for targy in doneSubjResults as [NSManagedObject]
            {
                useableEmail = targy.value(forKey: "userEmail") as! String
                isDone = targy.value(forKey: "elvegzett") as! Bool
                print ("\(isDone) = true és az email: \(useableEmail)")
                if (useableEmail == email && isDone == true)
                {
                    print("megtalalta")
                    nev = targy.value(forKey: "nev") as! String
                    finishedSubjects.append(nev)
                    /*
                     doneSubj.felev = targy.value(forKey: "felev") as! String
                     doneSubj.kredit = targy.value(forKey: "kredit") as! String
                     doneSubj.name = targy.value(forKey: "nev") as! String
                     doneSubj.targykod = targy.value(forKey: "targykod") as! String
                     doneSubj.elvegzett = true
                     self.elvegzettek.append(doneSubj)*/
                    counter+=1
                }
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        return counter
    }
    
}
