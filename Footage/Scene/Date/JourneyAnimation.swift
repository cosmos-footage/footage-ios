//
//  JourneyAnimation.swift
//  footage
//
//  Created by 녘 on 2020/06/15.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import UIKit
import EFCountingLabel

extension JourneyViewController {
    
    var date: Int { // 20200604 || 202006 || 2020
        get {
            Int(journeyManager.journey.date)
        }
    }
    
    func alphaToOne(object: UIView, time: Double) {
        Timer.scheduledTimer(withTimeInterval: time, repeats: false) { (_) in
            object.alpha = 1
        }
    }
    
    func animateDateLabel() {
        let presentation = JourneyDateDetailPresentation(legacyDateKey: date)

        if presentation.shouldHideDay {
            dayLabel.removeFromSuperview()
            dayText.removeFromSuperview()
        }
        if presentation.shouldHideMonth {
            monthLabel.removeFromSuperview()
            monthText.removeFromSuperview()
        }

        if let day = presentation.dayCounterEnd {
            addNecessaryZeros(day, label: dayLabel)
            dayLabel.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 3)
            dayLabel.countFrom(0, to: CGFloat(day), withDuration: 2)
            alphaToOne(object: dayLabel, time: 0.5)
        }

        if let month = presentation.monthCounterEnd {
            addNecessaryZeros(month, label: monthLabel)
            monthLabel.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 3)
            monthLabel.countFrom(0, to: CGFloat(month), withDuration: 2)
            alphaToOne(object: monthLabel, time: 0.5)
        }

        yearLabel.counter.timingFunction = EFTimingFunction.easeOut(easingRate: 3)
        yearLabel.countFrom(
            CGFloat(presentation.yearCounterStart),
            to: CGFloat(presentation.yearCounterEnd),
            withDuration: 2
        )
        alphaToOne(object: yearLabel, time: 0.5)
    }
    
    func addNecessaryZeros(_ date: Int, label: EFCountingLabel) {
        if date < 10 {
            label.setUpdateBlock{ (value, label) in
                label.text = String(format: "0%.f", value)
            }
        }
    }
    
}
