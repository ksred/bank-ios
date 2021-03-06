//
//  LoginViewController.swift
//  Bank
//
//  Created by Kyle Redelinghuys on 2015/12/03.
//  Copyright © 2015 Kyle Redelinghuys. All rights reserved.
//

import Foundation

import UIKit

class LoginViewController: UIViewController {
    
    struct HTTPResult {
        var message: String!
        var error: String!
    }
    
    @IBOutlet weak var loginOutlet: UIButton!
    @IBOutlet weak var loginOutletButton: UILabel!
    @IBOutlet weak var idNumberField: UITextField!
    @IBOutlet weak var passwordText: UITextField!
    @IBOutlet weak var errorLabel: UILabel!
    
    @IBAction func logInButton(sender: AnyObject) {
        
        // Check defaults
        let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID");
        let password = NSUserDefaults.standardUserDefaults().stringForKey("userPassword");
        
        print(password)
        print(userID)
        
        if (passwordText.text == "") {
            // @TODO Check to see if this fails
            errorLabel.text = "Please input password"
            return
        }
        
        if (password != nil && userID != nil) {
            if passwordText.text == password! {
                let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
                if (token.characters.count == 0) {
                    let alertController = UIAlertController(title: "Bank", message:
                        "Could not get new token", preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                print("Testing token")
                let tokenTest = HTTPClient.doCheckToken(token)
                print(tokenTest)
                
                // Test token
                if ( tokenTest.error != "" ) {
                    
                    // Log in for user and get new token
                    let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")!;
                    let password = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")!;
                    
                    let accountDetails = UserAccount(userID: userID, userPassword: password)
                    
                    // Log in
                    let token = HTTPClient.doLogin(accountDetails)
                    if token.error != "" {
                        let alertController = UIAlertController(title: "Bank", message:
                            "Could not get new token. "+token.error!, preferredStyle: UIAlertControllerStyle.Alert)
                        alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                        
                        self.presentViewController(alertController, animated: true, completion: nil)
                        return
                    }
                    
                    // Set token if not blank
                    NSUserDefaults.standardUserDefaults().setObject(token.message, forKey: "userToken")
                    
                    // Load view
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
                    self.showViewController(vc as! UIViewController, sender: vc)
                } else {
                    // Load view
                    let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
                    self.showViewController(vc as! UIViewController, sender: vc)
                }
            } else {
                errorLabel.text = "Password incorrect"
                return
            }
        } else {
            idNumberField.hidden = false;
            let idNumber = idNumberField.text;
            if (idNumber! == "") {
                errorLabel.text = "Please input ID Number"
                return
            }
            
            // Check if account exists with ID Number
            //@TODO Might have to remove the token from this API call, or find another way
            let token = NSUserDefaults.standardUserDefaults().stringForKey("userToken")!;
            let idResult = HTTPClient.doCheckAccountByID(token, idNumber: idNumber!)
            if (idResult.error != "") {
                // Set userid
                NSUserDefaults.standardUserDefaults().setObject(idResult.message, forKey: "userID")
                // Do login
                let accountDetails = UserAccount(userID: idResult.message!, userPassword: password!)
                
                // Log in
                let token = HTTPClient.doLogin(accountDetails)
                if token.error != "" {
                    let alertController = UIAlertController(title: "Bank", message:
                        "Could not get new token. "+token.error!, preferredStyle: UIAlertControllerStyle.Alert)
                    alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                    
                    self.presentViewController(alertController, animated: true, completion: nil)
                    return
                }
                
                // Set token if not blank
                NSUserDefaults.standardUserDefaults().setObject(token.message, forKey: "userToken")
                
                // Load view
                let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
                self.showViewController(vc as! UIViewController, sender: vc)

            } else {
                // Go to sign up screen
                // Load view
                let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("SignUpView")
                self.showViewController(vc as! UIViewController, sender: vc)
            }
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //loginOutletButton
        loginOutlet.backgroundColor = UIColor.clearColor()
        //loginOutlet.layer.cornerRadius = 5
        loginOutlet.layer.borderWidth = 1
        loginOutlet.layer.borderColor = UIColor.whiteColor().CGColor
        
        // Swipes
        let leftSwipe = UISwipeGestureRecognizer(target: self, action: Selector("handleSwipes:"))
        leftSwipe.direction = .Left
        view.addGestureRecognizer(leftSwipe)
       
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func handleSwipes(sender:UISwipeGestureRecognizer) {
        if (sender.direction == .Left) {
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("MainController")
            self.showViewController(vc as! UIViewController, sender: vc)
        }
    }
    
    func TestToken (tokenTest: HTTPResult) {
        // Test token
        if ( tokenTest.error != "" ) {
            
            // Log in for user and get new token
            let userID = NSUserDefaults.standardUserDefaults().stringForKey("userID")!;
            let password = NSUserDefaults.standardUserDefaults().stringForKey("userPassword")!;
            
            let accountDetails = UserAccount(userID: userID, userPassword: password)
            
            // Log in
            let token = HTTPClient.doLogin(accountDetails)
            if token.error != "" {
                let alertController = UIAlertController(title: "Bank", message:
                    "Could not get new token. "+token.error!, preferredStyle: UIAlertControllerStyle.Alert)
                alertController.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.Default,handler: nil))
                
                self.presentViewController(alertController, animated: true, completion: nil)
                return
            }
            
            // Set token if not blank
            NSUserDefaults.standardUserDefaults().setObject(token.message, forKey: "userToken")
            
            // Load view
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
            self.showViewController(vc as! UIViewController, sender: vc)
        } else {
            // Load view
            let vc : AnyObject! = self.storyboard!.instantiateViewControllerWithIdentifier("AccountLanding")
            self.showViewController(vc as! UIViewController, sender: vc)
        }

    }
}
