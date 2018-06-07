//
//  LoginViewController.swift
//  thesisProject
//
//  Created by Nikita Kechinov on 23.03.2018.
//  Copyright © 2018 Nikita Kechinov. All rights reserved.
//

import UIKit
import Firebase

public enum TextFields: Int {
    case nameTextField           = 0
    case emailTextField          = 1
    case passwordTextField       = 2
}

enum TextFeildsErrorType: String {
    case invalidEmailFormat =    "wrong email address format"
    case invalidName =           "name contains invalid symbols"
    case passwordError =         "must be more than 8 letters"
}

class LoginViewController: UIViewController, UITextFieldDelegate {
    var passTextField: UITextField?
    var emailTextField: UITextField?
    var nameTextField: UITextField?
    var loginView: LoginView?
    var registrationIsAllowed = [false, false, false]
    var ref: DatabaseReference!
    
    
    
//    override func loadView() {
//        let scrollView = UIScrollView()
//        self.view = scrollView
//    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let loginView = LoginView(withAssociated: self)
        self.loginView = loginView
        //self.view.addSubview(self.loginView!)
        ref = Database.database().reference(withPath: "users")
        
        Auth.auth().addStateDidChangeListener { [weak self](auth, user) in
            if user != nil {
                self?.setViewController()
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(notification: )), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
        
    }
    
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let navVC = self.navigationController {
            navVC.navigationBar.isHidden = true
        }
    }
    
    
//    override func viewWillDisappear(_ animated: Bool) {
//        super.viewWillDisappear(animated)
//        self.resignFirstResponder()
//        
//    }
//    
    
    
    
    // MARK: - register and login methods
    
    @objc func loginActionMethod() {
        Auth.auth().signIn(withEmail: self.emailTextField!.text!, password: passTextField!.text!) { [weak self] (user, error) in
            guard error == nil, user != nil else {
                ErrorManager.shared.showErrorMessage(with: error!, shownAt: self!)
                return
            }
            
            self?.setViewController()
            
            
        }
    }
    
    
    
    @objc func registerActionMethod() {
        self.loginView!.createRegisterView()
        self.loginView!.setAnimationOf(type: .AppearingOfView)
        self.loginView!.setTextFeildsForRegisterUsage()
    
    }
    
    
    
    @objc func registerNewUser() {
        for bool in self.registrationIsAllowed {
            if !bool {
                return
            }
        }
        Auth.auth().createUser(withEmail: self.emailTextField!.text!, password: self.passTextField!.text!) { [weak self] (user, error) in
            
            let userName = self?.nameTextField?.text
            guard error == nil, user != nil else {
                ErrorManager.shared.showErrorMessage(with: error!, shownAt: self!)
                return
            }
            guard let userRef = self?.ref.child((user?.uid)!) else { return }
            userRef.setValue(["name": userName])
            
            
            self?.setViewController()
            
        }
    }
    
    
    
    
    
    // MARK: - keyboard notification methods
    
    @objc func keyboardDidShow(notification: Notification) {
        guard let userInfo = notification.userInfo else { return }
        let keyboardFrameSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        self.loginView!.increaseContentSizeOn(value: keyboardFrameSize.height)
        
    }
    
    
    
    @objc func keyboardDidHide() {
        self.loginView!.decreaseContentSizeToDefaultValues()
    }
    
    
    
    
    
    // MARK: - TextField delegate methods
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField.textColor == .red {
            textField.textColor = .black
            textField.text = ""
        }
        return true
    }
    
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        self.textFieldTextChecking(within: textField)
        return true
    }
    
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    
    
    
    
    
    // MARK: - Additional methods
    
    @objc func removeRegisterView() {
        self.loginView!.setAnimationOf(type: .DisappearingOfView)
    }
    
    
    
    func showError(with error: TextFeildsErrorType, within textField: UITextField) {
        switch error {
        case .invalidEmailFormat:
            textField.text = error.rawValue
        case .invalidName:
            textField.text = error.rawValue
        case .passwordError:
            textField.text = error.rawValue
        }
        textField.textColor = UIColor.red
    }
    
    
    
    func textFieldTextChecking(within textField: UITextField) {
        guard let resultText = textField.text else { return }
        guard !(resultText == "") else {
            self.registrationIsAllowed[textField.tag] = false
            return
        }
        switch textField.tag {
        case TextFields.nameTextField.rawValue:
            let allowedChars = CharacterSet.alphanumerics
            if (resultText.trimmingCharacters(in: allowedChars) != "") {
                self.showError(with: .invalidName, within: textField)
                self.registrationIsAllowed[TextFields.nameTextField.rawValue] = false
                return
            }
        case TextFields.emailTextField.rawValue:
            if !resultText.isEmail() {
                self.showError(with: .invalidEmailFormat, within: textField)
                self.registrationIsAllowed[TextFields.emailTextField.rawValue] = false
                return
            }
        case TextFields.passwordTextField.rawValue:
            if resultText.count < 8 {
                self.showError(with: .passwordError, within: textField)
                self.registrationIsAllowed[TextFields.passwordTextField.rawValue] = false
                return
            }
        default:
            break
        }
        
        self.registrationIsAllowed[textField.tag] = true
        
    }
    
    
    
    func setViewController() {
        let tabBarController = UITabBarController()
        
        let mainMapWindowNavVC = MapViewController()
        mainMapWindowNavVC.tabBarItem = UITabBarItem(title: "Spots", image: UIImage(named: "map.png"), tag: 0)
        
        let favouriteNavVC = FavoritesViewController()
        favouriteNavVC.tabBarItem = UITabBarItem(title: "Favorites", image: UIImage(named: "favorites.png"), tag: 1)
        
        let tabBarArray = [mainMapWindowNavVC, favouriteNavVC]
        tabBarController.viewControllers = tabBarArray.map { UINavigationController(rootViewController: $0)}
        
        self.present(tabBarController, animated: true, completion: nil)
        
        
    }
   
    
    
    
}




extension String {
    func isEmail() -> Bool {
        let firstPart = "[A-Z0-9a-z]([A-Z0-9a-z._%+-]{0,30}[A-Z0-9a-z])?"
        let serverPart = "([A-Z0-9a-z]([A-Z0-9a-z-]{0,30}[A-Z0-9a-z])?\\.){1,5}"
        let emailRegex = firstPart + "@" + serverPart + "[A-Za-z]{2,6}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: self)
    }
}



