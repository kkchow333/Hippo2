//
//  TagListView.swift
//  VisionStack
//
//  Created by Esther Kim on 4/28/25.
//

import SwiftUI

// MARK: - Tag Types and Models
enum TagType: String, Hashable {
    case time = "Time"
    case date = "Date"
    case location = "Location"
    case color = "Color"
    case repeating = "Repeating"
    case alarm = "Alarm"
    case plus = "+"
}

struct Tag: Hashable {
    let type: TagType
    var title: String
    var isSelected: Bool
}

// MARK: - Tag Views
struct TagListView: View {
    @Binding var selectedTags: Set<String>
    
    @State private var tags: [Tag] = [
        Tag(type: .time, title: "Time", isSelected: true),
        Tag(type: .date, title: "Date", isSelected: true),
        Tag(type: .location, title: "Front door", isSelected: true),
        Tag(type: .plus, title: "+", isSelected: false),
        Tag(type: .color, title: "Color", isSelected: false),
        Tag(type: .repeating, title: "Repeating", isSelected: false),
        Tag(type: .alarm, title: "Alarm", isSelected: false)
    ]
    
    @State private var showHiddenTags: Bool = false
    @State private var selectedTime: Date = Date()
    @State private var selectedDate: Date = Date()
    @State private var showTimePicker: Bool = false
    @State private var showDatePicker: Bool = false
    @State private var timePickerPosition: CGPoint = .zero
    @State private var datePickerPosition: CGPoint = .zero
    
    var visibleTags: [Tag] {
        tags.filter { $0.isSelected && $0.type != .plus }
    }
    
    var plusTag: Tag {
        tags.first { $0.type == .plus }!
    }
    
    var hiddenTags: [Tag] {
        tags.filter { !$0.isSelected && $0.type != .plus }
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                FlexibleLayoutView(
                    availableWidth: geometry.size.width,
                    data: visibleTags + [plusTag] + (showHiddenTags ? hiddenTags : []),
                    spacing: 8,
                    alignment: .leading
                ) { tag in
                    TagButton(
                        tag: tag,
                        showTimePicker: $showTimePicker,
                        showDatePicker: $showDatePicker,
                        selectedTime: $selectedTime,
                        selectedDate: $selectedDate,
                        timePickerPosition: $timePickerPosition,
                        datePickerPosition: $datePickerPosition
                    ) {
                        if tag.type == .time {
                            timePickerPosition = geometry.frame(in: .local).origin
                        } else if tag.type == .date {
                            datePickerPosition = geometry.frame(in: .local).origin
                        } else if tag.type == .plus {
                            showHiddenTags.toggle()
                        }
                        handleTagTap(tag)
                    }
                    .opacity(showHiddenTags && !tag.isSelected && tag.type != .plus ? 0.6 : 1.0)
                }
                .padding(.horizontal, 8)
                .animation(.easeInOut, value: showHiddenTags)
            }
            
            if showTimePicker {
                VStack(spacing: 0) {
                    DatePicker("", selection: $selectedTime, displayedComponents: .hourAndMinute)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 200, height: 150)
                        .colorScheme(.light)
                        .accentColor(.blue)
                    
                    Spacer()
                    
                    Button("Set") {
                        let formatter = DateFormatter()
                        formatter.timeStyle = .short
                        if let index = tags.firstIndex(where: { $0.type == .time }) {
                            tags[index].title = formatter.string(from: selectedTime)
                        }
                        showTimePicker = false
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(20)
                .frame(width: 240, height: 250)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .position(x: timePickerPosition.x + 150, y: timePickerPosition.y + 100)
                .zIndex(9999)
            }
            
            if showDatePicker {
                VStack(spacing: 0) {
                    DatePicker("", selection: $selectedDate, displayedComponents: .date)
                        .datePickerStyle(.wheel)
                        .labelsHidden()
                        .frame(width: 300, height: 150)
                        .colorScheme(.light)
                        .accentColor(.blue)
                    
                    Spacer()
                    
                    Button("Set") {
                        let formatter = DateFormatter()
                        formatter.dateStyle = .medium
                        if let index = tags.firstIndex(where: { $0.type == .date }) {
                            tags[index].title = formatter.string(from: selectedDate)
                        }
                        showDatePicker = false
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                }
                .padding(20)
                .frame(width: 340, height: 250)
                .background(Color.white)
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                .position(x: datePickerPosition.x + 150, y: datePickerPosition.y + 100)
                .zIndex(9999)
            }
        }
    }
    
    private func handleTagTap(_ tag: Tag) {
        if tag.type == .time || tag.type == .date {
            return
        }
        
        if selectedTags.contains(tag.title) {
            selectedTags.remove(tag.title)
        } else {
            selectedTags.insert(tag.title)
        }
        
        if let index = tags.firstIndex(where: { $0.type == tag.type }) {
            tags[index].isSelected.toggle()
        }
    }
}

struct TagButton: View {
    private let tag: Tag
    @Binding var showTimePicker: Bool
    @Binding var showDatePicker: Bool
    @Binding var selectedTime: Date
    @Binding var selectedDate: Date
    @Binding var timePickerPosition: CGPoint
    @Binding var datePickerPosition: CGPoint
    private let action: () -> Void
    
    fileprivate init(
        tag: Tag,
        showTimePicker: Binding<Bool>,
        showDatePicker: Binding<Bool>,
        selectedTime: Binding<Date>,
        selectedDate: Binding<Date>,
        timePickerPosition: Binding<CGPoint>,
        datePickerPosition: Binding<CGPoint>,
        action: @escaping () -> Void
    ) {
        self.tag = tag
        self._showTimePicker = showTimePicker
        self._showDatePicker = showDatePicker
        self._selectedTime = selectedTime
        self._selectedDate = selectedDate
        self._timePickerPosition = timePickerPosition
        self._datePickerPosition = datePickerPosition
        self.action = action
    }
    
    var body: some View {
        Button(action: {
            if tag.type == .time {
                showTimePicker = true
            } else if tag.type == .date {
                showDatePicker = true
            }
            action()
        }) {
            HStack(spacing: 4) {
                Text(tag.title)
                    .font(.system(size: 15))
                    .fontWeight(.medium)
                
                if tag.type == .time || tag.type == .date {
                    Image(systemName: "chevron.down")
                        .font(.system(size: 10))
                        .rotationEffect(.degrees(tag.isSelected ? 180 : 0))
                } else if tag.type == .location {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 10))
                }
            }
            .padding(.vertical, 8)
            .padding(.horizontal, 16)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white)
            )
            .foregroundColor(Color(.darkGray))
        }
        .buttonStyle(PlainButtonStyle())
    }
}



//#Preview {
//    TagListView(selectedTags: selectedTags)
//}
