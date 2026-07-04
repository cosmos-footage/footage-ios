//
//  HomeAnimation.swift
//  footage
//
//  Created by 녘 on 2020/06/11.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import EFCountingLabel


class HomeAnimation {
    
    static let screenWidth = UIScreen.main.bounds.size.width
    static let screenHeight = UIScreen.main.bounds.size.height
    
    //MARK- homeStartAnimation
    
    @MainActor static func homeStartAnimation(_ homeVC: HomeViewController) {
        // start button pressed
        
        UIView.animate(withDuration: 1, animations: {
            homeVC.startButton.alpha = 0
        })
        UIView.animate(withDuration: 2, animations: {
            homeVC.startButton.alpha = 1
        })
        UIView.animate(withDuration: 1, animations: {
            homeVC.startButton.setImage(#imageLiteral(resourceName: "stopButton"), for: .normal)
        })
        //        UIView.animate(withDuration: 1) {
        //            homeVC.mainMap.alpha = 0
        //        }
        
        // 0. Counting Rate
        homeVC.distanceView.alpha = 0
        UIView.animate(withDuration: 3.5, animations: {
            homeVC.distanceView.alpha = 1
        })
        homeVC.unitLabel.alpha = 0
        UIView.animate(withDuration: 3, animations: {
            homeVC.unitLabel.alpha = 1
        })
        homeVC.distance.setUpdateBlock { (value, label) in
            label.text = String(format: "%.2f", value)
        }
        homeVC.distance.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 7)
        homeVC.distance.countFrom(0, to: CGFloat(HomeViewController.distanceToday / 1000), withDuration: 5)
        
        // 1. Text Animation
        
        homeVC.todayString.text = "오늘"
        homeVC.youString.text = "당신이 새로 남긴"
        homeVC.footString.text = "발자취"
        
        homeVC.todayString.alpha = 0.0
        homeVC.youString.alpha = 0.0
        homeVC.footString.alpha = 0.0
        
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.todayString.alpha = 1
            })
        }
        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.youString.alpha = 1
            })
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.footString.alpha = 1
            })
        }
        // Text Animation Ends
        
    }
    //MARK- homeStopAnimation
    
    @MainActor static func homeStopAnimation(_ homeVC: HomeViewController) {
        
        UIView.animate(withDuration: 1, animations: {
            homeVC.startButton.alpha = 0
        })
        UIView.animate(withDuration: 2, animations: {
            homeVC.startButton.alpha = 1
        })
        UIView.animate(withDuration: 1, animations: {
            homeVC.startButton.setImage(#imageLiteral(resourceName: "startButton"), for: .normal)
        })
        UIView.animate(withDuration: 1) {
            homeVC.mainMap.alpha = 0
        }
        
        // 0. Counting Rate
        homeVC.distanceView.alpha = 0
        UIView.animate(withDuration: 3.5, animations: {
            homeVC.distanceView.alpha = 1
        })
        homeVC.unitLabel.alpha = 0
        UIView.animate(withDuration: 3, animations: {
            homeVC.unitLabel.alpha = 1
        })
        homeVC.distance.setUpdateBlock { (value, label) in
            label.text = String(format: "%.f", value)
        }
        homeVC.distance.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 7)
        homeVC.distance.countFrom(0, to: CGFloat(HomeViewController.distanceTotal / 1000), withDuration: 5)
        
        // 1. Text Animation
        homeVC.todayString.text = "오늘까지"
        homeVC.youString.text = "당신이 남긴"
        homeVC.footString.text = "발자취"
        
        homeVC.todayString.alpha = 0.0
        homeVC.youString.alpha = 0.0
        homeVC.footString.alpha = 0.0
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.todayString.alpha = 1
            })
        }
        Timer.scheduledTimer(withTimeInterval: 0.75, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.youString.alpha = 1
            })
        }
        Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { (timer) in
            UIView.animate(withDuration: 1, animations: {
                homeVC.footString.alpha = 1
            })
        }
        // 1
    }
    
    static func buttonChanger(homeVC: HomeViewController, pressedbutton: UIButton) {
        
        let mainButtonClass = Buttons(className: homeVC.MainButton.restorationIdentifier!)
        let pressedButtonClass = Buttons(className: pressedbutton.restorationIdentifier!)
        
        homeVC.MainButton.setImage(pressedButtonClass.imageBig, for: .normal)
        pressedbutton.setImage(mainButtonClass.image, for: .normal)
        
        homeVC.MainButton.restorationIdentifier = pressedButtonClass.name
        pressedbutton.restorationIdentifier = mainButtonClass.name
        
        homeVC.selectedButtonLabel.text = UserDefaults(suiteName: "group.footage")!.string(forKey:pressedButtonClass.color)
        
        homeVC.mainMap.tintColor = UIColor(hex: pressedButtonClass.color)
        HomeViewController.selectedColor = pressedButtonClass.color
        
        UserDefaults(suiteName: "group.footage")!.set(pressedButtonClass.color, forKey: "selectedColor")
        
    }
    
    static func colorSelected(homeVC: HomeViewController, pressedbutton: UIButton) {
        
        DispatchQueue.global().sync {
            UIView.animate(withDuration: 0.3, animations: {
                homeVC.currentColorIndicator.frame.origin.y -= 10
                homeVC.selectedButtonStackView.frame.origin.y -= 10
            })
        }
        DispatchQueue.global().sync {
            UIView.animate(withDuration: 1, animations: {
                homeVC.currentColorIndicator.frame.origin.y += 10
                homeVC.selectedButtonStackView.frame.origin.y += 10
            })
        }
        
        
    }
}
