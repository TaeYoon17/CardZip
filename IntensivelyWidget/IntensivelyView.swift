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
                Spacer()
                Text("집중 단어").font(.title3.bold())
                Text("\(0)개").font(.system(.title3,weight: .heavy))
            }
            if entry.background.isEmpty{
                ForEach(0..<3,id:\.self){idx in
                    HStack{
                        Text("Term: ")
                        Text("Milk")
                        Text("Description: ")
                        Text("")
                    }
                }
            }else{
                VStack(spacing:0){
                    Image("SwiftUI")
                        .resizable().scaledToFill()
                        .frame(width: 66,height:66)
                    HStack{
                        Text("SwiftUI")
                        Text("스위프트 UI")
                    }
                }
            }
            Spacer()
        }
    }
}
//                Text(entry.date, style: .time)
//                Text(entry.emoji)
//#Preview(as: .systemSmall) {
//    IntensivelyWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀", background: "Metal")
//     SimpleEntry(date: .now, emoji: "🤩",background: "ARKit")
//}

