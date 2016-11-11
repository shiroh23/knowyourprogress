//
//  launchScreen.swift
//  KnowYourProgress
//
//  Created by shiroh23 on 2016. 10. 03..
//  Copyright © 2016. Horváth Richárd. All rights reserved.
//

import Foundation
import UIKit
import CoreData

class launchScreen: UIViewController {

    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var nextLbl: UILabel!
    
    var searchResults = [NSManagedObject]()
    let IDs = [1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]
    let Names = ["Teiermayer Attila","Medvegy Tibor","Görbe Péter","Dr. Pituk Mihály","Dr. Simon Gyula","Dr. Heckl István","Dr. Leitold Adrien Ilona","Dr. Hartung Ferenc","Székelyné Kovács Katalin","Hegyháti Máté","Dr. Pituk Mihály","Harmat István","Dr. Hartung Ferenc","Dr. Vassányi István","Piglerné dr. Lakner Rozália","Dr. Mihálykóné dr. Orbán Éva","Dr. Vassányi István","Dulai Tibor","Katonáné dr. Tömördi Katalin","Dr. Süle Zoltán","Dr. Simon Gyula","Dr. Vörösházi Zsolt","Dr. Bertók Ákos Botond"]
    let review = 0
    let subjects = ["Fizika I.","Fizika I.","Bevezetés a számítástechnikába","Matematikai analízis I.","Programozás alapjai","Programozás I.","Lineáris algebra","Az informatika logikai és algebrai alapjai","Közgazdaságtan","A digitális számítás elmélete","Matematikai analízis II.","Számítógépes perifériák","Diszkrét matematika","Digitális technika I.","Mesterséges intelligencia","Valószínűségszámítás és matematikai statisztika","Digitális technika II.","Számítógép-hálózatok I.","Elektromosságtan","Adatstruktúrák és algoritmusok","Operációs rendszerek","Digitális rendszerek és számítógép architektúrák","Korszerű programozási technikák"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let count = getTeachers()
        if (count == 0)
        {
            for i in (0..<23)
            {
                saveTeacher(id: IDs, nev: Names, subject: subjects, review: review, index: i)
                print("ciklusban vagyok \(i)")
            }
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.progressView.setProgress(1.0, animated: true)
            })
            
            UIView.animate(withDuration: 4) {
                self.nextLbl.alpha = 1.0
            }
        }
        else
        {
            UIView.animate(withDuration: 3, animations: { () -> Void in
                self.progressView.setProgress(1.0, animated: true)
            })
            
            UIView.animate(withDuration: 4) {
                self.nextLbl.alpha = 1.0
            }
        }
        
        
    }
    
    func saveTeacher(id: [Int], nev: [String], subject: [String], review: Int, index: Int)
    {
        let context = getContext()
        let entity =  NSEntityDescription.entity(forEntityName: "Teacher", in: context)
        
        let tanar = NSManagedObject(entity: entity!, insertInto: context)
        
        print("hozzaadom őtet:")
        print("\(id[index]) \(nev[index]) \(subject[index]) \(review) index értéke: \(index)")
        
        tanar.setValue(id[index], forKey: "id")
        tanar.setValue(nev[index], forKey: "name")
        tanar.setValue(subject[index], forKey: "subject")
        tanar.setValue(review, forKey: "review")
        
        
        do
        {
            try context.save()
            print("saved!")
        } catch let error as NSError
        {
            print("Could not save \(error), \(error.userInfo)")
        }
        catch
        {
            print("Error with: \(error)")
        }
    }
    
    func getTeachers () -> Int {
        
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            print ("találatok száma = \(searchResults.count)")
            
            for teacher in searchResults as [NSManagedObject]
            {
                print("\(teacher.value(forKey: "id")!) - \(teacher.value(forKey: "name")!)")
            }
            
            
        }
        catch
        {
            print("Error with request: \(error)")
        }
        
        return searchResults.count
    }
    
    func deleteTeachers()
    {
        let fetchRequest: NSFetchRequest<Teacher> = Teacher.fetchRequest()
        let managedContext = getContext()
        
        do
        {
            searchResults = try getContext().fetch(fetchRequest)
            
            for teacher in searchResults as [NSManagedObject]
            {
                let managedObjectData:NSManagedObject = teacher 
                managedContext.delete(managedObjectData)
            }
        }
        catch
        {
            print("Error with request: \(error)")
        }
        print("deleted them all")
    }
    
    func getContext () -> NSManagedObjectContext {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.persistentContainer.viewContext
    }
    
    @IBAction func tapped(_ sender: UITapGestureRecognizer)
    {
        self.openNewPage(name: "welcome")
    }
    
    func openNewPage(name: String){
        let theDelegate:AppDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let storyboard = theDelegate.window?.rootViewController?.storyboard
        
        let vc = storyboard!.instantiateViewController(withIdentifier: name) 
        navigationController?.pushViewController(vc, animated: true)
    }
}
