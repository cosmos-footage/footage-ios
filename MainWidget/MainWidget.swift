//
//  MainWidget.swift
//  MainWidget
//
//  Created by Wootae on 10/18/20.
//  Copyright © 2020 DreamPizza. All rights reserved.
//

import WidgetKit
import SwiftUI

private enum WidgetDefaults {
    static let suiteName = "group.footage"
    static let selectedColor = "selectedColor"
    static let defaultSelectedColor = "#EADE4Cff"
}

struct MainWidgetProvider: TimelineProvider {
    func getSnapshot(in context: Context, completion: @escaping (WidgetEntry) -> Void) {
        let userDefaults = UserDefaults(suiteName: WidgetDefaults.suiteName)
        let selectedColor = userDefaults?.string(forKey: WidgetDefaults.selectedColor) ?? WidgetDefaults.defaultSelectedColor
        let entry = WidgetEntry(date: Date(), selectedColor: selectedColor, widgetSize: context.displaySize)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WidgetEntry>) -> Void) {
        let userDefaults = UserDefaults(suiteName: WidgetDefaults.suiteName)
        let selectedColor = userDefaults?.string(forKey: WidgetDefaults.selectedColor) ?? WidgetDefaults.defaultSelectedColor
        let entry = WidgetEntry(date: Date(), selectedColor: selectedColor, widgetSize: context.displaySize)
        let timeline = Timeline(entries: [entry], policy: .never)
        completion(timeline)
    }
    
    func placeholder(in context: Context) -> WidgetEntry {
        return WidgetEntry(date: Date(), selectedColor: WidgetDefaults.defaultSelectedColor, widgetSize: context.displaySize)
    }
}

struct WidgetEntry: TimelineEntry {
    let date: Date
    var selectedColor = WidgetDefaults.defaultSelectedColor
    let widgetSize: CGSize
}

struct MainWidgetEntryView : View {
    var entry: MainWidgetProvider.Entry
    @Environment(\.widgetFamily) var family
    @ViewBuilder
    var body: some View {
        switch family {
        case .systemSmall:
            SmallView(selectedColor: entry.selectedColor, widgetSize: entry.widgetSize)
        //case .systemMedium:
        default:
            SmallView(selectedColor: entry.selectedColor, widgetSize: entry.widgetSize)
        }
    }
}

@main
struct MainWidget: Widget {
    let kind: String = "MainWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MainWidgetProvider()) { entry in
            SmallView(selectedColor: entry.selectedColor, widgetSize: entry.widgetSize)
        }
        .configurationDisplayName("발자취 위젯")
        .description("위젯을 추가해 홈 화면에서 기록을 시작하세요")
        .supportedFamilies([.systemSmall])
    }
}
