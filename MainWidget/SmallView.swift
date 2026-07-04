//
//  SmallView.swift
//  footage
//
//  Created by Wootae on 10/11/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import SwiftUI

private enum WidgetAppGroup {
    static let suiteName = "group.footage"
    static let isTracking = "isTracking"
    static let distanceToday = "distanceToday"
    static let distanceTotal = "distanceTotal"
}

struct SmallView: View {
    let selectedColor: String
    let widgetSize: CGSize
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: WidgetAppGroup.suiteName)
    }
    private var isTracking: Bool {
        defaults?.bool(forKey: WidgetAppGroup.isTracking) ?? false
    }
    private var distanceToday: Double {
        defaults?.double(forKey: WidgetAppGroup.distanceToday) ?? 0
    }
    private var distanceTotal: Double {
        defaults?.double(forKey: WidgetAppGroup.distanceTotal) ?? 0
    }
    
    var distanceToShow: String {
        if isTracking { return String(format: "%.2f", distanceToday / 1000) + "km" }
        else { return String(format: "%.f", distanceTotal / 1000) + "km" }
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            Color.white
            .edgesIgnoringSafeArea(.all)
            VStack(alignment: .center, spacing: 4) {
                let screenWidth = UIScreen.main.bounds.width
                TopView(selectedColor: selectedColor, isTracking: isTracking)
                Text(distanceToShow)
                    .foregroundColor(.black)
                    .font(.custom("NanumBarunpen", size: 35))
                Image(isTracking ? "stopButton" : "startButton")
                    .resizable()
                    .frame(width: screenWidth * 0.3, height: screenWidth * 0.14)
                    .widgetURL(URL(string: "widget://smallWidget"))
            }.padding(.top, 10)
        }
    }
}

struct TopView: View {
    let selectedColor: String
    let isTracking: Bool
    private var defaults: UserDefaults? {
        UserDefaults(suiteName: WidgetAppGroup.suiteName)
    }
    
    var body: some View {
        HStack(alignment: .center, spacing: 7, content: {
            Image(selectedColor).resizable()
                .frame(width: 20, height: 32, alignment: .center)
            let selectedCategory = defaults?.string(forKey: selectedColor) ?? "노란색"
            Text(isTracking ? selectedCategory : "총")
                .foregroundColor(.black)
                .font(.custom("NanumBarunpen-Bold", size: 22))
                .frame(width: 100, alignment: .leading)
        })
    }
}
