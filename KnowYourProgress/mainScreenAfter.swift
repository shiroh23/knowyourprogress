//
//  mainScreenAfter.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 11. 11..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//
import Foundation
import UIKit
import CoreData


class mainAfter: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let backgroundImage = UIImage(named: "489812_Pannonia.jpg")
    var productArray = NSArray()
    var allSubjects = [String]()
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
        
        //background beállítása
        let imageView = UIImageView(image: backgroundImage)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0.05
        self.tableView.backgroundView = imageView
        
        self.getUserData()
        print(felh)
        
        readPropertyList(szak: felh.szak)
        
        semesterSubjCount = self.targyCounter()
        
        felevLbl.text = "Összes félév"
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tableView.deselectRow(at: self.index, animated: true)
    }
    
    private func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return semesterSubjCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath as IndexPath)
        cell.backgroundColor = .clear
        let row = indexPath.row
        cell.textLabel?.text = allSubjects[row]
        return cell
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
            
            nev = rekord["nev"] as! String
            elvegzett = self.getSubject(keresettTargy: nev)
            
            if (felev != String(felh.currSem) && elvegzett == false)
            {
                allSubjects.append(nev)
                count += 1
            }
        }
        
        return count
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "segue") {
            let destination = segue.destination as! detailviewafterScreen
            let index = tableView.indexPathForSelectedRow?.row
            self.index = tableView.indexPathForSelectedRow!
            
            let keresettTargy = self.allSubjects[index!]
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
                    destination.felh.szak = self.felh.szak
                }
            }
        }
        if (segue.identifier == "segueAfter")
        {
            
        }
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let favorite = UITableViewRowAction(style: .normal, title: "Felvétel") { action, index in
            self.melyiket = indexPath.row
            self.alertIndex = indexPath
            self.alert(msg1: "Tárgy felvéve!")
            tableView.deselectRow(at: indexPath, animated: true)
        }
        favorite.backgroundColor = UIColor.green
        
        return [favorite]
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
                    felh.currSem = users.value(forKey: "currentSemester") as! Int16
                    felh.finiSem = users.value(forKey: "finishedSemester") as! Int16
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
                    elvegzett = true
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

