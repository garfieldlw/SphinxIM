//
//  PreferencesPaneStatistics.swift
//  SphinxIM
//
//  Created by Wei Lu on 2024/5/14.
//

import SwiftUI
import Combine

func formatCount(_ count: Int64) -> String {
    return NumberFormatter.localizedString(from: NSNumber(value: count), number: .decimal)
}

struct CountCircle: View {
    let data: EntityStatisticsData
    
    @State private var hovered = false
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            Circle()
                .stroke(
                    style: StrokeStyle(
                        lineWidth: 4,
                        lineCap: .round,
                        lineJoin: .round,
                        miterLimit: 80,
                        dash: [],
                        dashPhase: 0
                    )
                )
                .frame(width: 10, height: 10, alignment: .center)
                .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0))
                .background(Color.white)
                .cornerRadius(5)
                .scaleEffect(hovered ? 1.3 : 1)
                .onHover { state in
                    hovered = state
                }
                .popover(isPresented: $hovered) {
                    Text("\(data.date): \(formatCount(data.count))")
                        .padding(6)
                }
        }
    }
}

struct PreferencesPaneStatisics: View {
    @State private var startDate = Date().addingTimeInterval(-7 * 24 * 60 * 60)
    @State private var endDate = Date()
    @State private var data: [EntityStatisticsData] = []
    @State private var total: Int64 = 0
    
    func getPath(geo: GeometryProxy) -> Path {
        return Path { path in
            let maxVal = data.reduce(0) { (res, dateCount) -> Int64 in
                return max(res, dateCount.count)
            }
            let scale = geo.size.height / CGFloat(maxVal)
            let gap = data.count > 1 ? (geo.size.width - 16) / CGFloat(data.count - 1) : 0
            
            path.move(to: CGPoint(x: 8, y: geo.size.height - CGFloat((data[0].count)) * scale))
            
            data.enumerated().forEach { element in
                path.addLine(
                    to: CGPoint(
                        x: 8 + CGFloat(element.offset) * gap,
                        y: geo.size.height - CGFloat(element.element.count) * scale
                    )
                )
            }
            
            path.addLine(to: CGPoint(x: 8 + CGFloat(data.count - 1) * gap, y: geo.size.height))
            path.addLine(to: CGPoint(x: 8, y: geo.size.height))
            path.closeSubpath()
        }
    }
    
    func drawLogPoints(data: [EntityStatisticsData]) -> some View {
        return GeometryReader { geo in
            let maxNum = data.reduce(0) { (res, item) -> Int64 in
                return max(res, item.count)
            }
            
            let scale = geo.size.height / CGFloat(maxNum)
            let gap = data.count > 1 ? (geo.size.width - 16) / CGFloat(data.count - 1) : 0
            
            ForEach(data.indices, id: \.self) { index in
                CountCircle(data: data[index])
                    .offset(
                        x: 8 + gap * CGFloat(index) - 5,
                        y: (geo.size.height - (CGFloat(data.count) * scale)) - 5
                    )
            }
        }
    }
    
    func drawBackground(data: [EntityStatisticsData]) -> some View {
        return GeometryReader { geo in
            Path { path in
                let gap = data.count > 1 ? (geo.size.width - 16) / CGFloat(data.count - 1) : 0
                
                (0..<data.count).forEach { element in
                    path.move(to: CGPoint(x: 8 + CGFloat(element) * gap, y: geo.size.height))
                    path.addLine(to: CGPoint(x: 8 + CGFloat(element) * gap, y: 0))
                }
            }
            .stroke(
                style: StrokeStyle(
                    lineWidth: 1,
                    lineCap: .round,
                    lineJoin: .round,
                    miterLimit: 80,
                    dash: [],
                    dashPhase: 0
                )
            )
            .foregroundColor(Color.black.opacity(0.5))
        }
    }
    
    func drawData(data: [EntityStatisticsData]) -> some View {
        return VStack {
            GeometryReader { geo in
                getPath(geo: geo)
                    .fill(Color.red.opacity(0.2))
            }
            .frame(height: 320)
            .overlay(drawBackground(data: data))
            .overlay(GeometryReader(content: { geo in
                getPath(geo: geo)
                    .stroke(
                        style: StrokeStyle(
                            lineWidth: 2,
                            lineCap: .round,
                            lineJoin: .round,
                            miterLimit: 80,
                            dash: [],
                            dashPhase: 0
                        )
                    )
                    .foregroundColor(Color(red: 251/255, green: 82/255, blue: 0).opacity(0.6))
            }))
            .overlay(drawLogPoints(data: data))
            .background(Color.yellow.opacity(0.1))
            HStack {
                ForEach(data.indices, id: \.self) { index in
                    Text(data[index].date)
                    if index < data.count - 1 {
                        Spacer()
                    }
                }
            }
            Spacer(minLength: 20)
        }
    }
    
    var body: some View {
        Settings.Container(contentWidth: 450) {
            Settings.Section(title: "") {
                VStack(alignment: .leading) {
                    GroupBox(label: Text("Total")) {
                        HStack {
                            Text("\(formatCount(self.total))")
                            Spacer()
                        }
                        .frame(width: 420)
                    }
                    
                    GroupBox(label: Text("Statistics(Last 7 days)")) {
                        if data.count <= 0 {
                            HStack {
                                Spacer()
                                Text("Empty")
                                Spacer()
                            }
                            .frame(width: 420, height: 320)
                        } else {
                            drawData(data: data)
                        }
                    }
                }.onAppear(){
                    fetch()
                }
            }
        }
    }
    
    func fetch(){
        self.total = DaoStatistics.shared.queryCount()
        self.data = DaoStatistics.shared.queryDataByDate(startDate: self.startDate, endDate: self.endDate)
    }
}

#Preview {
    PreferencesPaneStatisics()
}
