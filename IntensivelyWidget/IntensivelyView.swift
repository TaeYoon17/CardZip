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
        VStack(alignment: .leading, spacing:4){
            if let image = entry.image{
                HStack{
                    image
                        .resizable().scaledToFill()
                        .frame(width: 66,height:66)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    Spacer()
                }
                VStack(alignment:.leading,spacing: 4){
                    Text(entry.term).font(.headline).fontWeight(.heavy)
                        .minimumScaleFactor(0.9)
                        .lineLimit(1)
                    Text(entry.description).font(.system(size: 12))
                        .multilineTextAlignment(.leading).padding(.bottom,-4)
                        .minimumScaleFactor(0.9)
                }
            }else{
                VStack(spacing:6){
                    HStack(alignment: .firstTextBaseline, spacing:0){
                        (Text("⭐️").font(.system(size: 9)).bold() + Text("Focus".localized)).foregroundStyle(.cardSecondary)
                        Spacer()
                        (Text("\(entry.cnt) ")+Text("counts".localized))
                    }.font(.system(size: 13)).fontWeight(.bold)
                        
                    Divider().frame(height: 1).foregroundStyle(.cardSecondary)
                    VStack(alignment:.center,spacing: 4){
                        Text(entry.term).font(.title2).fontWeight(.heavy)
                            .minimumScaleFactor(0.666)
                            .lineLimit(2)
                        Text(entry.description).font(.system(size: 13))
                            .multilineTextAlignment(.center).padding(.bottom,-4)
                            .minimumScaleFactor(0.9)
                    }
                }
            }
            Spacer()
        }.overlay(alignment:.topTrailing){
            if entry.image != nil{
                VStack(alignment:.trailing, spacing:0){
                    Text("Focus".localized).foregroundStyle(.cardSecondary).fontWeight(.semibold)
                    (Text("\(entry.cnt) ")+Text("counts".localized))
                }.font(.system(size: 13)).fontWeight(.bold)
            }
        }.padding(-4)
        .widgetURL(URL(string: API_Key.intensivelyWidgetKey))
    }
}
//                Text(entry.date, style: .time)
//                Text(entry.emoji)
//#Preview(as: .systemSmall) {
//    IntensivelyWidget()
//} timeline: {
//    SimpleEntry(date: .now, emoji: "😀", background: "Metal")
//    SimpleEntry(date: .now, emoji: "🤩",background: "Metal")
//}

