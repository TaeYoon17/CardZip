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
    @DefaultsState(\.intensivelies,path: \.intensivelyShared) var intensivelies
    func placeholder(in context: Context) -> IntensivelyEntry {
        IntensivelyEntry(date: Date(), term: "Card.Zip", description: "", cnt: 0, image: Image("cardzip"))
    }
    
//    : high watermark memory limit exceeded
    func getSnapshot(in context: Context, completion: @escaping (IntensivelyEntry) -> ()) {
        let image = Image(uiImage: UIImage.downSample(name: "cardzip", size: .init(width: 144, height: 144)))
        let entry = IntensivelyEntry(date: Date(), term: "Card.Zip", description: "", cnt: 0, image: image)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<IntensivelyEntry>) -> ()) {
        var intensivelyEntries:[IntensivelyEntry] = intensivelies?.map{ intensively in
            let image:Image? = if let imageData = intensively.image {
                Image(uiImage: UIImage.fetchBy(data: imageData, size: .init(width: 144, height: 144)))
            }else{ nil }
            return IntensivelyEntry(date: Date(), term: intensively.term, description: intensively.descripotion, cnt: intensively.cnt, image: image)
        } ?? []
        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< intensivelyEntries.count{
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            intensivelyEntries[hourOffset].date = entryDate
        }
        
        let timeline = Timeline(entries: intensivelyEntries, policy: .atEnd)
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
                        Color.bg
                    })
            } else {
                IntensivelyWidgetEntryView(entry: entry)
                    .background {
                        Color.bg
                    }
            }
        }
        .supportedFamilies([.systemSmall])
        .configurationDisplayName("Liked Card Widget")
        .description("")
    }
}
//struct IntensivelyWidget_Previews: PreviewProvider{
//    static var previews: some View{
//        IntensivelyWidgetEntryView(entry: <#T##Provider.Entry#>)
//    }
//}

//#Preview(as: .systemSmall) {
//    IntensivelyWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀", background: "ARKit")
//    SimpleEntry(date: .now, emoji: "🤩",background: "SwiftUI")
//}
