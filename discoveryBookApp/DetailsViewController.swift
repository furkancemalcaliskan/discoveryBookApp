//
//  DetailsViewController.swift
//  discoveryBookApp
//
//  Created by Furkan Cemal Çalışkan on 18.08.2022.
//

import UIKit
import CoreData

class DetailsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var inventionName: UITextField!
    @IBOutlet weak var inventorName: UITextField!
    @IBOutlet weak var yearText: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var chosenInvention = ""
    var chosenInventionId : UUID?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chosenInvention != "" {
            
            saveButton.isHidden = true
            
            //Core Data
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let context = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Invention")
            let idString = chosenInventionId?.uuidString
            fetchRequest.predicate = NSPredicate(format: "id = %@", idString!)
            fetchRequest.returnsObjectsAsFaults = false
            
            do {
                let results = try context.fetch(fetchRequest)
                
                if results.count > 0 {
                    for result in results as! [NSManagedObject] {
                        
                        if let name = result.value(forKey: "name") as? String {
                            inventionName.text = name
                        }
                        
                        if let inventor = result.value(forKey: "inventor") as? String {
                            inventorName.text = inventor
                        }
                        
                        if let year = result.value(forKey: "year") as? Int {
                            yearText.text = String(year)
                        }
                        
                        if let imageData = result.value(forKey: "image") as? Data {
                            let image = UIImage(data: imageData)
                            imageView.image = image
                        }
                    }
                }
            } catch {
                print("error")
            }
            
            
            
        }else{
            saveButton.isHidden = false
            saveButton.isEnabled = false
            inventionName.text = ""
            inventorName.text = ""
            yearText.text = ""
            
        }

        //Recognizers
        
        let gestureRecogizer = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        view.addGestureRecognizer(gestureRecogizer)
        
        imageView.isUserInteractionEnabled = true
        
        let imageTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageSelect))
        
        imageView.addGestureRecognizer(imageTapRecognizer)
        
    }
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let newInvention = NSEntityDescription.insertNewObject(forEntityName: "Invention", into: context)
        
        //Attributes
        
        newInvention.setValue(inventionName.text!, forKey: "name")
        newInvention.setValue(inventorName.text!, forKey: "inventor")
        
        if let year = Int(yearText.text!) {
            
            newInvention.setValue(year, forKey: "year")
            
        }
        
        newInvention.setValue(UUID(), forKey: "id")
        
        let data = imageView.image?.jpegData(compressionQuality: 0.5)
        
        newInvention.setValue(data, forKey: "image")
        
        do {
            try context.save()
            print("success")
        } catch {
            print("error")
        }
        
        
        NotificationCenter.default.post(name: NSNotification.Name("newData"), object: nil)
        self.navigationController?.popViewController(animated: true)
        
    }
    
    @objc func hideKeyboard() {
        
        view.endEditing(true)
        
    }
    
    @objc func imageSelect() {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        present(imagePicker, animated: true, completion: nil)
        
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        imageView.image = info[.originalImage] as? UIImage
        saveButton.isEnabled = true
        self.dismiss(animated: true, completion: nil)
    }
    
}
