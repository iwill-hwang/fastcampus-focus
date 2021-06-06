//
//  ViewController.swift
//  Focus
//
//  Created by donghyun on 2021/05/30.
//

import UIKit

enum Medal {
    case gold
    case silver
    case bronze
    
    init(by duration: TimeInterval) {
        if duration <= 5 {
            self = .bronze
        } else if 5 < duration && duration <= 7 {
            self = .silver
        } else {
            self = .gold
        }
    }
}

extension Medal {
    var icon: UIImage{
        switch self {
        case .gold:
            return UIImage(named: "gold")!
        case .silver:
            return UIImage(named: "silver")!
        case .bronze:
            return UIImage(named: "bronze")!
        }
    }
    
    var color: UIColor {
        switch self {
        case .gold:
            return UIColor(red: 251 / 255, green: 203 / 255, blue: 81 / 255, alpha: 1)
        case .silver:
            return UIColor(red: 174 / 255, green: 174 / 255, blue: 174 / 255, alpha: 1)
        case .bronze:
            return UIColor(red: 248 / 255, green: 164 / 255, blue: 125 / 255, alpha: 1)
        }
    }
}

extension UIView {
    func animateHighlight() {
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }, completion: { _ in
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseOut, animations: {
                self.transform = .identity
            })
        })
    }
}

extension UIView {
    func makeRound()  {
        self.layer.cornerRadius = self.frame.height / 2
        self.layer.cornerCurve = .continuous
        self.layer.masksToBounds = true
    }
}

class ViewController: UIViewController {
    var currentMedal = Medal.bronze
    
    private let from: Float = 3
    private let to: Float = 10
    
    @IBOutlet weak private var iconView: UIImageView!
    @IBOutlet weak private var timeLabel: UILabel!
    @IBOutlet weak private var slider: UISlider!
    @IBOutlet weak private var startButton: UIButton!
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.iconView.image = Medal.bronze.icon
        
        self.slider.value = 0
        
        self.startButton.makeRound()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        
        if identifier == "Timer" {
            let timerViewController = segue.destination as? TimerViewController
            timerViewController?.duration = Int(from + ((to - from) * slider.value))
        }
    }
    
    @IBAction func sliderValueDidChange() {
        let value = slider.value
        let time = Int(from + ((to - from) * value))
        
        let medal = Medal.init(by: TimeInterval(time))
        
        if currentMedal != medal {
            iconView.animateHighlight()
        }
        
        slider.tintColor = medal.color
        timeLabel.text = "\(time) minutes"
        iconView.image = medal.icon
        startButton.backgroundColor = medal.color
        
        currentMedal = medal
    }
    
    @IBAction func presentHistory() {
        performSegue(withIdentifier: "History", sender: nil)
    }
    
    @IBAction func start() {
        performSegue(withIdentifier: "Timer", sender: nil)
    }
}

class TimerViewController: UIViewController {
    typealias Second = Int
    
    let cheerUpMessages = [
        "화이팅해요!",
        "조금 더 집중 해볼까요?"
    ]
    
    var duration: Second =  10
    
    var remaining: Second {
        duration - Int(Date().timeIntervalSince1970 - start.timeIntervalSince1970)
    }
    
    var timer: Timer!
    var start = Date()
    var deactiveTime: Date?
    
    var isActive = true
    
    @IBOutlet weak private var cheerUpLabel: UILabel!
    @IBOutlet weak private var durationLabel: UILabel!
    @IBOutlet weak private var progressContainer: UIView!
    @IBOutlet weak private var progressWidth: NSLayoutConstraint!
    @IBOutlet weak private var cancelButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.layoutIfNeeded()
        self.cheerUpLabel.text = cheerUpMessages.randomElement()
        self.progressContainer.makeRound()
        self.cancelButton.makeRound()
        self.updateDuration(seconds: duration)
        self.addObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if timer == nil {
            self.updateDuration(seconds: duration)
            self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(tick), userInfo: nil, repeats: true)
        }
    }

    private func addObservers() {
        let center = NotificationCenter.default
        
        center.addObserver(self, selector: #selector(didEnterBackground), name: UIApplication.didEnterBackgroundNotification, object: nil)
        center.addObserver(self, selector: #selector(didBecomeActive), name: UIApplication.didBecomeActiveNotification, object: nil)
    }
    
    private func updateDuration(seconds: Second) {
        let hours = seconds / 60
        let minutes = seconds % 60
        
        durationLabel.text = String(format: "%02d:%02d", hours, minutes)
        progressWidth.constant = CGFloat(remaining) / CGFloat(duration) * progressContainer.frame.width
    }
    
    @objc private func didEnterBackground(){
        self.isActive = false
        self.deactiveTime = Date()
        print(UIApplication.shared.isProtectedDataAvailable)
    }
    
    @objc private func didBecomeActive(){
        self.isActive = true
        self.updateDuration(seconds: remaining)
        
        if let deactiveTime = deactiveTime, Date().timeIntervalSince1970 - deactiveTime.timeIntervalSince1970 > 10 {
            
        }
    }
    
    @objc private func tick() {
        guard isActive else {
            return
        }
        
        if remaining > 0 && remaining % 15 == 0 {
            cheerUpLabel.text = cheerUpMessages.randomElement()
        }
        
        if remaining == 0 {
            self.timer.invalidate()
            self.save()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                let controller = UIAlertController(title: "성공했어요!", message: nil, preferredStyle: .alert)
                
                controller.addAction(UIAlertAction(title: "확인", style: .default, handler: { _ in
                    self?.dismiss(animated: true, completion: nil)
                }))
                    
                self?.present(controller, animated: true, completion: nil)
            }
        }
        
        updateDuration(seconds: remaining)
    }
    
    private func save() {
        let defaults = UserDefaults.standard
        
        var list = defaults.object(forKey: "list") as? [[String: Any]] ?? []
        
        list.append(["duration": self.duration, "date": Date()])
        
        defaults.setValue(list, forKey: "list")
        defaults.synchronize()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
