//
//  LoginViewController.swift
//  ChatApp01
//
//  Created by 中塚富士雄 on 2020/05/27.
//  Copyright © 2020 中塚富士雄. All rights reserved.
//

import UIKit
import Firebase
import Lottie

class LoginViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    let animationView = AnimationView()
    //LottieはJSONを読み込んで作動させるライブラリ
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    

    @IBAction func login(_ sender: Any) {
        
        startAnimation()
        //ログインに成功したらアニメーションを動かす。
        Auth.auth().signIn(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
           if error != nil{
               print("error")
           }else{
        print("ログインに成功")
//⭐️ログインに失敗してもエラーがでず、アニメーションが動き続け、その後にクラッシュ
               self.stopAnimation()
//⭐️アニメーションの停止、ログイン成功でも失敗でも停止のはずが
            self.performSegue(withIdentifier: "chat", sender: nil)
//segue(id)chatを動かしてLoginViewControllerに戻る。
                
            }

        }
        
    }
    
    
    func startAnimation(){
        
        let animation = Animation.named("loading")
        //Lottieの仕様、ローディングをanimationに入れる。
        
        animationView.frame = CGRect(
            x: 0, y: 0,width: view.frame.size.width,height: view.frame.size.height/1.5)

        animationView.animation = animation
        //ローディングという名前のアニメーションには、animationViewが持つプロパティ「makeAnimationLayer」（動作）を入れる。
        
        animationView.contentMode = .scaleAspectFit
        
        animationView.loopMode = .loop
        animationView.play()
        
        view.addSubview(animationView)
        
    }

    func stopAnimation(){
        
        animationView.removeFromSuperview()
        
    }
    
    
}
