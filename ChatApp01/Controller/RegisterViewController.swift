//
//  RegisterViewController.swift
//  ChatApp01
//
//  Created by 中塚富士雄 on 2020/05/27.
//  Copyright © 2020 中塚富士雄. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class RegisterViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let animationView = AnimationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    @IBAction func registerNewUser(_ sender: Any) {
        
        startAnimation()
 
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if error != nil{
                print(error as Any)
            }else{
         print("ユーザーの作成が成功しました！")

        self.stopAnimation()
       //⭐️stopAnimation()は66行目で宣言しているのだが。。。
                
                self.performSegue(withIdentifier: "chat", sender: nil)
               
             
        }
        
    }
    
    func startAnimation(){
        
        let animation = Animation.named("loading")
        animationView.frame = CGRect(
            x: 0, y: 0,width: view.frame.size.width,height: view.frame.size.height/1.5)

        animationView.animation = animation
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        animationView.play()
        
        view.addSubview(animationView)
        
    }

    func stopAnimation(){
        
        animationView.removeFromSuperview()
        
    }
    
    
    }
    
    
}
