//
//  ViewController.swift
//  MemeMe
//
//  Created by Michael Herman on 19/4/18.
//  Copyright © 2018 Michael Herman. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var memeImageView: UIImageView!
    @IBOutlet weak var topText: UITextField!
    @IBOutlet weak var bottomText: UITextField!
    @IBOutlet weak var albumBarItem: UIBarButtonItem!
    @IBOutlet weak var photoBarItem: UIBarButtonItem!
    @IBOutlet weak var fontBarItem: UIBarButtonItem!
    @IBOutlet var doneChoosingFontBarItem: UIBarButtonItem!
    @IBOutlet weak var topToolbar: UIToolbar!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var cancelTopBarItem: UIBarButtonItem!
    @IBOutlet weak var fontPicker: UIPickerView!
    
    struct Meme {
        let topText : String
        let bottomText : String
        let originalImage : UIImage?
        let memeImage : UIImage?
    }
    
    var fontPickerSourceData : [String] = [String]()
    var userChosenFont : Int = 0
    var memeTextAttribute : [String : Any] = [
        NSAttributedStringKey.strokeColor.rawValue : UIColor.black,
        NSAttributedStringKey.foregroundColor.rawValue : UIColor.white,
        NSAttributedStringKey.strokeWidth.rawValue : -3.0 as NSNumber,
        NSAttributedStringKey.font.rawValue : UIFont(name: "Impact", size: 40)!
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeMemeTextFields(nil)
        topText.text = "TOP"
        bottomText.text = "BOTTOM"
        
        fontPickerSourceData = ["Impact", "Super Comic","Comic Sans Ms","Blockt","Futura","HelveticaNeue-CondensedBlack"]
        fontPicker.delegate = self
        fontPicker.dataSource = self
        fontPicker.isHidden = true
        doneChoosingFontBarItem.isEnabled = false   // Done is a button to confirm font changes
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            photoBarItem.isEnabled = true
        } else {
            photoBarItem.isEnabled = false
        }
    }
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /**
        #Initialization of Texfields behavior
        * Default Attributes
        * Text Alignment
        * Border style
        * Delegates.
        - Parameter textAttribute: dictionary contains NSAttributedStringKey and its values
        - Returns: Void
     */
    func initializeMemeTextFields(_ textAttribute : [String : Any]?) -> Void {
        if let textAttribute = textAttribute {
            // Set text using the supplied textAttribute paramater
            topText.defaultTextAttributes = textAttribute
            bottomText.defaultTextAttributes = textAttribute
        }else {
            // Set text using default text attribute
            topText.defaultTextAttributes = memeTextAttribute
            bottomText.defaultTextAttributes = memeTextAttribute
        }
        topText.textAlignment = NSTextAlignment.center
        topText.borderStyle = UITextBorderStyle.none
        topText.delegate = self
        bottomText.textAlignment = NSTextAlignment.center
        bottomText.borderStyle = UITextBorderStyle.none
        bottomText.delegate = self
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        dismissKeyboard()
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        dismissKeyboard()
    }
    
    /// Font picker column
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    /// Font picker row
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return fontPickerSourceData.count
    }
    
    /// Font picker data
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return fontPickerSourceData[row]
    }
    
    /// Font picker user selection
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userChosenFont = row
        print("User Choose \(fontPickerSourceData[userChosenFont])")
    }
    
    /// Action triggers when user touch on Font Button
    @IBAction func userPickFontAction(_ sender: Any) {
        fontPicker.isHidden = false
        fontBarItem.isEnabled = false
        albumBarItem.isEnabled = false
        photoBarItem.isEnabled = false
        doneChoosingFontBarItem.isEnabled = true
    }
    /// Action triggers when user touch on Done Button
    @IBAction func donePickFontAction(_ sender: Any) {
        fontPicker.isHidden = true
        albumBarItem.isEnabled = true
        photoBarItem.isEnabled = true
        fontBarItem.isEnabled = true
        doneChoosingFontBarItem.isEnabled = false
        let font : String = fontPickerSourceData[userChosenFont]
        print("User Pick : \(font)")
        memeTextAttribute[NSAttributedStringKey.font.rawValue] = UIFont(name: font, size: 40)
        initializeMemeTextFields(memeTextAttribute)     // Refresh the text attribute after change fonts
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeToKeyboardNotification()
    }
    
    func subscribeToKeyboardNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
    }
    
    func unsubscribeToKeyboardNotification(){
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object : nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object :nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification){
        view.frame.origin.y -= getKeyboardHeight(notification)
        print("Frame Origin -Y \(view.frame.origin.y)")
    }
    
    @objc func keyboardWillHide(_ notification : Notification) {
        if view.frame.origin.y + getKeyboardHeight(notification) <= 0 {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
        print("Frame Origin +Y \(view.frame.origin.y)")
    }
    
    func getKeyboardHeight(_ notification : Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    func dismissKeyboard(){
        view.endEditing(true)
    }
    
    /// Action triggered when user touch on Camera / Library Button
    @IBAction func takePhoto(_ sender: Any) {
        var source : UIImagePickerControllerSourceType?
        var sourceName : String?             // Specify the name of source for alertview purpose
        
        // Photo and library button are given tag number to recognize who has triggered this function
        // Take photo camera action noted by 0
        // Take photo via library actio noted by 1
        if let button = sender as? UIBarButtonItem {
            let photoOrLibraryTag = button.tag
            switch photoOrLibraryTag {
            case 0 :
                source = UIImagePickerControllerSourceType.camera
                sourceName = "Camera"
            case 1 :
                source = UIImagePickerControllerSourceType.photoLibrary
                sourceName = "Photo Library"
            default :
                print("Unkown Source Type")
                sourceName = "Unkown"
                break
            }
        }
        // Making sure that source photo / library is available on the device
        if UIImagePickerController.isSourceTypeAvailable(source!){
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = source!
            imagePicker.allowsEditing = true
            present(imagePicker, animated: true, completion: nil)
        } else {
            print("Source \(sourceName!) not found!")
            sendAlertWithDismiss(title: "Not Found", msg: "Resource \(sourceName!) is not found", buttonTitle: "Dismiss")
        }
    }
    
    /// Executed when user done picking image from camera / library. Then put the image to imageView
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            memeImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    /// Cancel ImageView and reset all textFields on main screen
    @IBAction func cancelMeme(_ sender: Any) {
        let alert = UIAlertController(title: "Delete", message: "Are you sure want to cancel? Any changes made will be reset.", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.default, handler: {_ in
            self.topText.text = "TOP"
            self.bottomText.text = "BOTTOM"
            self.memeImageView.image = nil}))
        alert.addAction(UIAlertAction(title: "No", style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// Share that invokes UIActivityViewController that serve image sharing to other app
    @IBAction func actionShare(_ sender: Any) {
        let image : UIImage = generateMemeImage()
        let activityController = UIActivityViewController(activityItems : [image], applicationActivities: nil)
        present(activityController, animated: true, completion: {()->Void in print(self.view.frame)})
        activityController.completionWithItemsHandler = {(at: UIActivityType?, comp:Bool, it : [Any]?, error : Error?) -> Void in
            if let err : Error = error {
                print(err.localizedDescription)
                self.sendAlertWithDismiss(title: "Meme not saved", msg: "Fail to save meme to app library", buttonTitle: "Dismiss")
            }else{
                if at == UIActivityType.saveToCameraRoll || at == UIActivityType.airDrop || at == UIActivityType.postToFacebook || at == UIActivityType.copyToPasteboard || at == UIActivityType.mail || at == UIActivityType.postToTwitter || at == UIActivityType.message{
                    print("Save image successfully")
                    self.save()
                    self.sendAlertWithDismiss(title: "Meme Saved", msg: "Your meme is saved to photos", buttonTitle: "Ok")
                }else {
                    print("ActivityType is not recognized, keep safing the image anyway.")
                    self.save()
                }
            }
        }
    }
    
    /**
     # Send an alert view with dismiss action.
     - Parameter title:         The string for alertview header
     - Parameter msg:           The string for alertview description body
     - Parameter buttonTitle:   The String for alertview dismiss title (such as : Dismiss, ok )
     - Returns: Void
    */
    func sendAlertWithDismiss(title : String, msg : String, buttonTitle : String) -> Void {
        let alert = UIAlertController(title: title, message: msg, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     # Generate meme from main view
     - Returns: memedImage of UIImage
    */
    func generateMemeImage() -> UIImage {
        memeToolbarsIsHidden(true)
        UIGraphicsBeginImageContext(view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        memeToolbarsIsHidden(false)
        return memedImage
    }
    
    /// Save meme image to struct for future use
    func save(){
        if let image : UIImage = memeImageView.image {
            let meme = Meme(topText : topText.text!, bottomText : bottomText.text!, originalImage: image, memeImage : generateMemeImage())
        }
    }
    
    /**
     #Simple function to hide/unhide top and bottom toolbar
     - Parameter _ isHidden: true to hide / false otherwise
     - Returns: Void
    */
    func memeToolbarsIsHidden(_ isHidden : Bool) -> Void {
        topToolbar.isHidden = isHidden
        bottomToolbar.isHidden = isHidden
    }

}

