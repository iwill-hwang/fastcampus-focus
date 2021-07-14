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
            return UIColor(red: 255 / 255, green: 208 / 255, blue: 81 / 255, alpha: 1)
        case .silver:
            return UIColor(red: 177 / 255, green: 161 / 255, blue: 182 / 255, alpha: 1)
        case .bronze:
            return UIColor(red: 225 / 255, green: 179 / 255, blue: 170 / 255, alpha: 1)
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

enum TimerStatus {
    case active
    case background
    case lockscreen
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
        
        self.iconView.image = currentMedal.icon
        self.slider.thumbTintColor = currentMedal.color
        self.slider.value = 0
        self.startButton.backgroundColor = currentMedal.color
        self.startButton.makeRound()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let identifier = segue.identifier
        
        if identifier == "Timer" {
            let timerViewController = segue.destination as? TimerViewController
            let minutes = Int(from + ((to - from) * slider.value)) * 60
            
            timerViewController?.duration = minutes
        }
    }
    
    @IBAction func sliderValueDidChange() {
        let value = slider.value
        let time = Int(from + ((to - from) * value))
        
        let medal = Medal.init(by: TimeInterval(time))
        
        if currentMedal != medal {
            iconView.animateHighlight()
        }
        
        slider.thumbTintColor = currentMedal.color
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
