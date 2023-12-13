//
//  IntensivelyView.swift
//  CardZip
//
//  Created by 김태윤 on 12/12/23.
//

import SwiftUI
import WidgetKit
struct IntensivelyWidgetEntryView : View {
    var entry: Provider.Entry
    var body: some View {
        VStack {
            HStack{
                Text("집중 단어")
                Spacer()
                Text("\(0) 개")
            }
            VStack{
                ForEach(0..<3,id:\.self){idx in
                    Text("\(idx) 단어")
                }
            }
            Spacer()
        }
    }
}
//                Text(entry.date, style: .time)
//                Text(entry.emoji)
#Preview(as: .systemSmall) {
    IntensivelyWidget()
} timeline: {
    SimpleEntry(date: .now, emoji: "😀")
    SimpleEntry(date: .now, emoji: "🤩")
}

