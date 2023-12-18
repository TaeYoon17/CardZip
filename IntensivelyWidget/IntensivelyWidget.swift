//
//  IntensivelyWidget.swift
//  IntensivelyWidget
//
//  Created by 김태윤 on 12/10/23.
//

import WidgetKit
import SwiftUI
struct SimpleEntry: TimelineEntry {
    let date: Date
    let emoji: String
    let background:String
}
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), emoji: "😀",background: "")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), emoji: "😀",background: "")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, emoji: "😀",background: "ARKit")
            entries.append(entry)
        }
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}



struct IntensivelyWidget: Widget {
    
    let kind: String = "IntensivelyWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                IntensivelyWidgetEntryView(entry: entry)
                    .containerBackground(for: .widget, alignment: .center, content: {
                        Image(entry.background)
                            .resizable()
                            .scaledToFill()
                            .overlay(.ultraThinMaterial.opacity(0.95))
                            
                    })
            } else {
                IntensivelyWidgetEntryView(entry: entry)
                    .background {
                        Image(entry.background).resizable().scaledToFill().overlay(.ultraThinMaterial)
                    }.ignoresSafeArea(.all,edges:.all)
                    .frame(width: .infinity,height: .infinity)
                    .background(.red)
            }
        }
        
        .configurationDisplayName("My Widget")
        .description("This is an example widget.")
    }
}

//#Preview(as: .systemSmall) {
//    IntensivelyWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀", background: "ARKit")
//    SimpleEntry(date: .now, emoji: "🤩",background: "SwiftUI")
//}
