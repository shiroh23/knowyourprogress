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

struct Oktato
{
    var name: String = ""
    var subject: String = ""
    var id: Int16 = 0
    var review: Int16 = 0
}

class main: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    var productArray = NSArray()
    var currentSubjects = [String]()
    var melyiket: Int = 0
    var semesterSubjCount: Int = 0
    var felh = Felh()
    var tanar = Oktato()
    var index: IndexPath = []
    var alertIndex: IndexPath = []
    
    var searchResults = [NSManagedObject]()
    var teacherResults = [NSManagedObject]()
    var subjResults = [NSManagedObject]()
    
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
        var elvegzett: Bool = false
        var rekord: Dictionary<String, AnyObject>
        
        for i in (0..<productArray.count)
        {
            rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
            felev = rekord["felev"] as! String
            //itt keressük meg hogy el van e végezve a tárgy
            
            nev = rekord["nev"] as! String
            elvegzett = self.getSubject(keresettTargy: nev)
            
            if (felev == String(felh.currSem) && elvegzett == false)
            {
                currentSubjects.append(nev)
                //print(currentSubjects.last!)
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
            self.index = tableView.indexPathForSelectedRow!
            
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
                    tanar = self.getTeachers(keresettTargy: keresettTargy)
                    destination.tutor = tanar
                    destination.path = self.index
                }
            }
        }
        if (segue.identifier == "segueBefore")
        {
            
        }
        if (segue.identifier == "segueAfter")
        {
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let favorite = UITableViewRowAction(style: .normal, title: "Elvégezve") { action, index in
            self.melyiket = indexPath.row
            self.saveSubject(index: self.melyiket)
            self.alertIndex = indexPath
            self.alert(msg1: "Tárgy az elvégzettek közé téve!")
            tableView.deselectRow(at: indexPath, animated: true)
        }
        favorite.backgroundColor = UIColor.green
        
        let share = UITableViewRowAction(style: .normal, title: "Elbukva") { action, index in
            self.melyiket = indexPath.row
        }
        share.backgroundColor = UIColor.red
        
        return [share, favorite]
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
    
    // MARK: CoreData tárgyelvégzése
    
    func saveSubject(index: Int)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "DoneSubj", in: context)
        
        let doneSubj = NSManagedObject(entity: entity!, insertInto: context)
        
        let keresettTargy = self.currentSubjects[index]
        var targyString: String = ""
        var rekord: Dictionary<String, AnyObject>
        
        for i in (0..<productArray.count)
        {
            rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
            targyString = rekord["nev"] as! String
            if (targyString == keresettTargy)
            {
                let newSubject = self.productArray.object(at: i) as! Dictionary<String, AnyObject>
                doneSubj.setValue(newSubject["nev"] as! String, forKey: "nev")
                doneSubj.setValue(newSubject["kredit"] as! String, forKey: "kredit")
                doneSubj.setValue(newSubject["felev"] as! String, forKey: "felev")
                doneSubj.setValue(newSubject["targykod"] as! String, forKey: "targykod")
                doneSubj.setValue(true, forKey: "elvegzett")
                doneSubj.setValue(felh.email, forKey: "userEmail")
                print("\(targyString) elvégezve!")
                break
            }
        }
        
        do
        {
            try context.save()
            print("targy elvegzese mentve!")
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            print("Error with: \(error)")
        }
    }
    
    // MARK: CoreData egy tárgy kinyerése
    
    func getSubject (keresettTargy: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<DoneSubj> = DoneSubj.fetchRequest()
        var elvegzett: Bool = false
        var keres: String = ""
        
        do
        {
            subjResults = try getContext().fetch(fetchRequest)
            
            for targy in subjResults as [NSManagedObject]
            {
                keres = targy.value(forKey: "nev") as! String
                
                if (keres == keresettTargy)
                {
                    elvegzett = targy.value(forKey: "elvegzett") as! Bool
                    break
                }
            }
            
        }
        catch
        {
            print("Error with request: \(error)")
        }
        return elvegzett
    }
    
    func alert(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { action in self.someHandler(index: self.alertIndex) } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func someHandler (index: IndexPath)
    {
        
        self.tableView.reloadRows(at: [index], with: UITableViewRowAnimation.left)
        
    }
    
}
