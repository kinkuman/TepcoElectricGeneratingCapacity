//
//  ViewController.swift
//  TepcoElectricGeneratingCapacity
//
//  Created by user on 2018/10/25.
//  Copyright © 2018年 user. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // %表示のラベル
    @IBOutlet weak var percentLabel: UILabel!
    
    // プログレスビュー
    @IBOutlet var progressView: UIProgressView!
    
    // 現在地と最大値のラベル
    @IBOutlet weak var currentAndMaxLabel: UILabel!
    
    // アクティビティインジケーター
    weak var activityIndicatorView: UIActivityIndicatorView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // 大きいインジケータを作成
        let activityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        self.activityIndicatorView = activityIndicatorView
        // 背景うすい黒
        activityIndicatorView.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        // 角をまるく
        activityIndicatorView.layer.cornerRadius = 5
        // ちょっと大きめにしておく
        activityIndicatorView.frame.size = CGSize(width: 100, height: 100)
        // 真ん中に配置
        activityIndicatorView.center = self.view.center
        // 止まったら消える設定
        activityIndicatorView.hidesWhenStopped = true
        
        // すぐ使えるよう載せておく
        self.view.addSubview(activityIndicatorView)
        
        // プログレスビューを太らせる
        progressView.transform = CGAffineTransform(scaleX: 1, y: 10)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ボタンタップ
    @IBAction func tapButton(_ sender: UIButton) {
        
        // アクティビティインジケーター表示
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        // もっとおおきいインジケーターも回す
        self.activityIndicatorView.startAnimating()
        
        // ボタン連射できないようにする
        sender.isEnabled = false
        
        // 接続先URLを作成
        let url = URL(string: "https://tepco-usage-api.appspot.com/quick.txt")!
        
        // URLセッション
        let urlSession = URLSession.shared
        
        // タイムアウト30秒
        let urlRequest = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 30.0)
        
        let urlSessionTask = urlSession.dataTask(with: urlRequest) { (data, response, error) in
            
            if let error = error {
                // エラーだったら
                print(error.localizedDescription)
                
                DispatchQueue.main.async {
                    // アクティビティインジケーター非表示
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    self.activityIndicatorView.stopAnimating()
                    
                    // ボタンを押せるようにする
                    sender.isEnabled = true
                    
                    // アラート表示
                    self.showAlert(msg: "エラーです\(error.localizedDescription)")
                }
                
                return
            }
            
            // 得られたデータを文字列にする
            let result = String(data:data!,encoding:.utf8)!
            
            // CSVテキストを分解する
            let textArray = result.components(separatedBy: ",")
            
            // 時間は画面に出していないの捨ててる
            _ = textArray[0]
            let now = Double(textArray[1])!
            let max = Double(textArray[2])!
            
            // 使用量の割合を計算
            let percent = now / max
            
            // UIの更新はやはりメインスレッドでやらなけらばならない
            let mainQueue = DispatchQueue.main
            mainQueue.async {
                
                // UIの更新処理
                self.percentLabel.text = String(Int(percent * 100))
                self.percentLabel.text?.append("%")
                self.currentAndMaxLabel.text = "\(now)/\(max)"
                
                // プログレスビューの更新（値は0-1.0)
                self.progressView.progress = Float(percent)
                
                // 値によってプログレスビューの色を変える
                if percent > 0.9 {
                    self.progressView.tintColor = UIColor.red
                } else if percent > 0.8 {
                    self.progressView.tintColor = UIColor.yellow
                } else {
                    self.progressView.tintColor = UIColor.blue
                }
                
                // アクティビティインジケーター非表示
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
                self.activityIndicatorView.stopAnimating()
                
                // ボタンを押せるようにする
                sender.isEnabled = true
            }
        }
        
        // URLセッションタスクの実行
        urlSessionTask.resume()
    }
    
    // アラート表示
    func showAlert(msg:String) {
        let alertController = UIAlertController(title: "メッセージ", message: msg, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    
//    func makeCircleChart(value:Double,denominator:Double) -> UIImage {
//        
//        UIGraphicsBeginImageContext(CGSize(width: 300, height: 300))
//        
//        // 円の360を最大値で割って割合を出す
//        let raito = 360.0/denominator
//        
//        // 消費量の割合
//        let consumeValue = value * raito
//        
//        // 円弧を描く
//        
//        // 開始は時計でいう12時ぴったりとする
//        let startAngle = -Double.pi/2
//        
//        
//        
//        
//        let image = UIGraphicsGetImageFromCurrentImageContext()
//        
//        UIGraphicsEndImageContext()
//        
//        return image
//    }
}
