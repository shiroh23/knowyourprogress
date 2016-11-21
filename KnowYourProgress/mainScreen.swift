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
    var currSem: Int16 = 0
    var finiSem: Int16 = 0
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
    
    @IBOutlet weak var afterBtn: UIButton!
    @IBOutlet weak var beforeBtn: UIButton!
    @IBOutlet weak var felevLbl: UILabel!
    @IBOutlet weak var tableView: UITableView!
    
    let backgroundImage = UIImage(named: "489812_Pannonia.jpg")
    var productArray = NSArray()
    var currentSubjects = [String]()
    var melyiket: Int = 0
    var semesterSubjCount: Int = 0
    var felh = Felh()
    var tanar = Oktato()
    var index: IndexPath = []
    var alertIndex: IndexPath = []
    var felevValtas: Bool = false
    var gombLetiltva: Bool = false
    
    var searchResults = [NSManagedObject]()
    var teacherResults = [NSManagedObject]()
    var subjResults = [NSManagedObject]()
    var doneSubjRes = [NSManagedObject]()
    var loadSubjResults = [NSManagedObject]()
    var lostSubjResults = [NSManagedObject]()
    
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
        
        if (felh.email != "")
        {
            gombLetiltva = self.getDoneSubjects(email: felh.email)
            if (gombLetiltva == true)
            {
                beforeBtn.isHidden = true
                beforeBtn.isEnabled = false
            }
            else
            {
                beforeBtn.isEnabled = true
                beforeBtn.isHidden = false
            }
            
            if (self.felevValtas == true)
            {
                let count = self.targyCounter()
                self.updateUserData()
                self.felevValtas = false
            }
            
            readPropertyList(szak: felh.szak)
        
            semesterSubjCount = self.targyCounter()
            if (semesterSubjCount == 0)
            {
                beforeBtn.isHidden = true
                beforeBtn.isEnabled = false
                afterBtn.isHidden = true
                afterBtn.isEnabled = false
                felevLbl.text = "Minden tárgy teljesítve!"
                felevLbl.adjustsFontSizeToFitWidth = true
                felevLbl.minimumScaleFactor = 0.5
            }
            else
            {
                felevLbl.text = "\(felh.currSem). félév"
                felevLbl.adjustsFontSizeToFitWidth = true
                felevLbl.minimumScaleFactor = 0.5
            }
        
            //profil adatlap megtekintése
            let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(self.respondToSwipeGesture))
            swipeDown.direction = UISwipeGestureRecognizerDirection.down
            self.felevLbl.addGestureRecognizer(swipeDown)
            
            //időszakok megtekintése
            let pressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(main.handlePress))
            self.felevLbl.addGestureRecognizer(pressGestureRecognizer)
                
        }
        else
        {
            felevLbl.text = "Nincs bejelentkezett felhasznalo"
            felevLbl.adjustsFontSizeToFitWidth = true
            felevLbl.minimumScaleFactor = 0.5
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool)
    {
        tableView.deselectRow(at: self.index, animated: true)
    }
    
    // MARK: Gesture észlelők
    
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
    
    func handlePress(sender: UILongPressGestureRecognizer) {
        if sender.state == UIGestureRecognizerState.began {
            self.openNewPage(name: "periods")
        }
        else if sender.state == UIGestureRecognizerState.ended {
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
        cell.backgroundColor = .clear
        let row = indexPath.row
        if (currentSubjects[row] != "")
        {
            cell.textLabel?.text = currentSubjects[row]
        }
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
        var elbukott: Bool = false
        var felvett: Bool = false
        var rekord: Dictionary<String, AnyObject>
        
        for i in (0..<productArray.count)
        {
            rekord = productArray.object(at: i) as! Dictionary<String, AnyObject>
            felev = rekord["felev"] as! String
            
            nev = rekord["nev"] as! String
            elvegzett = self.getSubject(keresettTargy: nev)
            felvett = self.getLoadSubject(keresettTargy: nev)
            elbukott = self.getLostSubject(keresettTargy: nev)
            
            if ( (felev == String(felh.currSem) && elvegzett == false && elbukott == false) || (felvett == true && elbukott == false ) )
            {
                currentSubjects.append(nev)
                count += 1
            }
        }
        
        return count
    }
    
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
                    destination.felh.szak = self.felh.szak
                }
            }
        }
        if (segue.identifier == "segueBefore")
        {
            var maradtTargyCount = 0
            for i in (0..<self.currentSubjects.count)
            {
                if (currentSubjects[i] != "")
                {
                    maradtTargyCount += 1
                }
            }
            
            let destination = segue.destination as! mainBefore
            destination.maradtTargyCount = maradtTargyCount
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
            self.alert(msg1: "Áthelyezve az elvégzett tárgyak közé!")
            tableView.deselectRow(at: indexPath, animated: true)
        }
        favorite.backgroundColor = UIColor.green
        
        let share = UITableViewRowAction(style: .normal, title: "Elbukva") { action, index in
            self.melyiket = indexPath.row
            self.saveLostSubject(index: self.melyiket)
            self.alertIndex = indexPath
            self.alert2(msg1: "Áthelyezve az összes maradék tárgy közé!")
            tableView.deselectRow(at: indexPath, animated: true)
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
            
            
            for users in searchResults as [NSManagedObject]
            {
                if (users.value(forKey: "logged") as! Bool == true)
                {
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
    
    // MARK: CoreData user frissítés ha elvégezte az adott félévet
    
    func updateUserData ()
    {
        
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            for users in searchResults as [NSManagedObject]
            {
                if (users.value(forKey: "logged") as! Bool == true)
                {
                    felh.currSem = Int16(felh.currSem+1)
                    felh.finiSem = Int16(felh.finiSem+1)
                    users.setValue(felh.currSem, forKey: "currentSemester")
                    users.setValue(felh.finiSem, forKey: "finishedSemester")
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
                break
            }
        }
        
        do
        {
            try context.save()
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            print("Error with: \(error)")
        }
        
        let fetchRequest: NSFetchRequest<LoadSubj> = LoadSubj.fetchRequest()
        do
        {
            loadSubjResults = try getContext().fetch(fetchRequest)
            
            for subject in loadSubjResults as [NSManagedObject]
            {
                if (subject.value(forKey: "nev") as! String == keresettTargy)
                {
                    context.delete(subject)
                    break
                }
            }
            
            try context.save()
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
    }
    
    // MARK: CoreData elbukott tárgy felvétele
    
    func saveLostSubject(index: Int)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "LostSubj", in: context)
        
        let lostSubj = NSManagedObject(entity: entity!, insertInto: context)
        
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
                lostSubj.setValue(newSubject["nev"] as! String, forKey: "nev")
                lostSubj.setValue(newSubject["kredit"] as! String, forKey: "kredit")
                lostSubj.setValue(newSubject["felev"] as! String, forKey: "felev")
                lostSubj.setValue(newSubject["targykod"] as! String, forKey: "targykod")
                lostSubj.setValue(false, forKey: "elvegzett")
                lostSubj.setValue(felh.email, forKey: "userEmail")
                break
            }
        }
        
        do
        {
            try context.save()
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            print("Error with: \(error)")
        }
        
        let fetchRequest: NSFetchRequest<LoadSubj> = LoadSubj.fetchRequest()
        do
        {
            loadSubjResults = try getContext().fetch(fetchRequest)
            
            for subject in loadSubjResults as [NSManagedObject]
            {
                if (subject.value(forKey: "nev") as! String == keresettTargy)
                {
                    context.delete(subject)
                    break
                }
            }
            
            try context.save()
        }
        catch
        {
            print("Error with request: \(error)")
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
    
    // MARK: CoreData előzetesen felvett tárgyak, bukottak újrafelvétele
    
    func getLoadSubject (keresettTargy: String) -> Bool
    {
        
        let fetchRequest: NSFetchRequest<LoadSubj> = LoadSubj.fetchRequest()
        var felvett: Bool = false
        var keres: String = ""
        
        do
        {
            loadSubjResults = try getContext().fetch(fetchRequest)
            
            for targy in loadSubjResults as [NSManagedObject]
            {
                keres = targy.value(forKey: "nev") as! String
                let email = targy.value(forKey: "userEmail") as! String
                if (keres == keresettTargy && self.felh.email == email)
                {
                    felvett = true
                    break
                }
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
       if (felvett == true)
       {
        return true
        }
        else
       {
        return false
        }
    }
    
    // MARK: CoreData tárgyak kinyerése
    
    func getDoneSubjects(email: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<DoneSubj> = DoneSubj.fetchRequest()
        var keres: String = ""
        var counter: Int = 0
        
        do
        {
            doneSubjRes = try getContext().fetch(fetchRequest)
            
            for targy in doneSubjRes as [NSManagedObject]
            {
                keres = targy.value(forKey: "userEmail") as! String
                
                if (keres == email)
                {
                    counter += 1
                }
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        if (counter == 0)
        {
            return true
        }
        else
        {
            return false
        }
    }
    
    // MARK: CoreData elbukott tárgyakat ne írjuk ki, melyek az adott félévben még lennének
    
    func getLostSubject (keresettTargy: String) -> Bool {
        
        let fetchRequest: NSFetchRequest<LostSubj> = LostSubj.fetchRequest()
        var elvegzett: Bool = false
        var keres: String = ""
        
        do
        {
            lostSubjResults = try getContext().fetch(fetchRequest)
            
            for targy in lostSubjResults as [NSManagedObject]
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
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in self.someHandler(index: self.alertIndex) } ))
        self.present(alert, animated: true, completion: nil)
    }
    
    func alert2(msg1: String){
        let alert = UIAlertController(title: "", message: msg1, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.destructive, handler: { action in self.someHandler(index: self.alertIndex)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func someHandler (index: IndexPath)
    {
        
        self.currentSubjects.remove(at: index.row)
        self.semesterSubjCount -= 1
        self.tableView.deleteRows(at: [index], with: .left)
        self.tableView.reloadData()
        
        gombLetiltva = self.getDoneSubjects(email: felh.email)
        if (gombLetiltva == true)
        {
            beforeBtn.isHidden = true
            beforeBtn.isEnabled = false
        }
        else
        {
            beforeBtn.isEnabled = true
            beforeBtn.isHidden = false
        }
    }
    
}
