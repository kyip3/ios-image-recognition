//
//  ViewController.swift
//  SeeFood
//
//  Created by yip kayan on 17/8/22.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate{

    @IBOutlet weak var imageView: UIImageView!
    
    let imagePicker = UIImagePickerController()
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        //implementing camera function in app
        imagePicker.delegate = self
        
        imagePicker.allowsEditing = false
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("picking image")
        //pass in what the image user selected.
        if let userPickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            imageView.image = userPickedImage
            print("image picked")
            guard let ciimage = CIImage(image: userPickedImage) else {
                fatalError("Could not convert to CI image")
            }
            
            detect(image: ciimage)
        }
        
        imagePicker.dismiss(animated: true)
        
        

    }
    
    //process the image using ML model
    func detect(image: CIImage) {
        print("detecting image")
        guard let model = try? VNCoreMLModel(for: Inceptionv3().model) else {
            print("Loading coreML model failed")
            fatalError("Loading coreML model failed")
        }
        print("detecting image request...")
        let request = VNCoreMLRequest(model: model) { request, error in
            print("requst returning \(request)")
            print("error returning \(error)")
            
            guard let results = request.results as? [VNClassificationObservation] else {
                print("no results found.")
                fatalError("Model request fail to process")
            }
            
            print("printing results...")
            //print(results)
            if let firstResult = results.first{
                self.navigationItem.title = firstResult.identifier
                print(firstResult.identifier)
            }
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        
        do{
            try handler.perform([request])
        }catch {
            print("error occured in handler \(error)")
        }
        print(request)
    }

    @IBAction func photoTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        imagePicker.sourceType = .camera
        present(imagePicker, animated: true, completion: nil)
    }
    
}

