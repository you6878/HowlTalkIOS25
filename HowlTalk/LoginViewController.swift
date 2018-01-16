//
//  LoginViewController.swift
//  HowlTalk
//
//  Created by 유명식 on 2017. 8. 8..
//  Copyright © 2017년 swift. All rights reserved.
//

import UIKit
import Firebase

class LoginViewController: UIViewController {
    
    
    @IBOutlet weak var password: UITextField!
    @IBOutlet weak var email: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var signup: UIButton!
    let remoteconfig = RemoteConfig.remoteConfig()
    var color : String!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        try! Auth.auth().signOut()
        let statusBar = UIView()
        self.view.addSubview(statusBar)
        statusBar.snp.makeConstraints { (m) in
            m.right.top.left.equalTo(self.view)
            if(UIScreen.main.nativeBounds.height == 2436){
                    m.height.equalTo(40)
            }else{
                m.height.equalTo(20)
            }
            
        }
        color = remoteconfig["splash_background"].stringValue
        
        statusBar.backgroundColor = UIColor(hex: color)
        loginButton.backgroundColor = UIColor(hex: color)
        signup.backgroundColor = UIColor(hex: color)
        
        loginButton.addTarget(self, action: #selector(loginEvent), for: .touchUpInside)

        signup.addTarget(self, action: #selector(presentSignup), for: .touchUpInside)
        
        
        Auth.auth().addStateDidChangeListener { (auth, user) in
            if(user != nil){
                let view = self.storyboard?.instantiateViewController(withIdentifier: "MainViewTabBarController") as! UITabBarController
                self.present(view, animated: true, completion: nil)
                let uid = Auth.auth().currentUser?.uid
                let token = InstanceID.instanceID().token()
                Database.database().reference().child("users").child(uid!).updateChildValues(["pushToken":token!])
                
            }
        }
        // Do any additional setup after loading the view.
    }
    func loginEvent(){
        
        Auth.auth().signIn(withEmail: email.text!, password: password.text!) { (user, err) in
            
            if(err != nil){
                let alret = UIAlertController(title: "에러", message: err.debugDescription, preferredStyle: UIAlertControllerStyle.alert)
                alret.addAction(UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: nil))
                self.present(alret, animated: true, completion: nil)
            }
        }
    }
    
    func presentSignup(){
        let view = self.storyboard?.instantiateViewController(withIdentifier: "SignupViewController") as! SignupViewController
        self.present(view, animated: true, completion: nil)
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
