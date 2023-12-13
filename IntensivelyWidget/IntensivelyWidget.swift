//
//  IntensivelyWidget.swift
//  IntensivelyWidget
//
//  Created by 김태윤 on 12/10/23.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀")
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
}

struct IntensivelyWidget: Widget {
    let kind: String = "IntensivelyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                IntensivelyWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget, alignment: .center, content: {
                        Image("ARKit")
                            .resizable()
                            .scaledToFill()
                            .overlay(.ultraThinMaterial.opacity(0.95))
                            
                    })
            } else {
                IntensivelyWidgetEntryView(entry: entry)
                //                    .padding()
                    .background {
                        Image("ARKit").resizable().scaledToFill().overlay(.ultraThinMaterial)
                    }.ignoresSafeArea(.all,edges:.all)
                    .frame(width: .infinity,height: .infinity)
                    .background(.red)
            }
        }
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

#Preview(as: .systemSmall) {
    IntensivelyWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}
