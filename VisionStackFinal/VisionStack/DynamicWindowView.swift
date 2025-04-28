import SwiftUI

// MARK: - Tag Types and Models
private enum TagType: String, Hashable {
    case time = "Time"
    case date = "Date"
    case location = "Location"
    case color = "Color"
    case repeating = "Repeating"
    case alarm = "Alarm"
    case plus = "+"
}

private struct Tag: Hashable {
    let type: TagType
    var title: String
    var isSelected: Bool
}

struct DynamicWindowView: View {
    @State private var inputText: String = ""
    @State private var isEditing: Bool = false
    @State private var hasSubmittedText: Bool = false
    @State private var selectedTags: Set<String> = []
    @State private var isImageLoaded: Bool = false
    @FocusState private var isInputFocused: Bool
    
    // Customizable window dimensions
    let windowWidth: CGFloat = 500
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Main Window Content
            HStack(alignment: .top, spacing: 12) {
                // Profile Image
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color(.systemGray2))
                    )
                
                // Text Input or Message
                if !hasSubmittedText || isEditing {
                    ZStack(alignment: .leading) {
                        if inputText.isEmpty {
                            Text("What would you like to do?")
                                .foregroundColor(Color(.placeholderText))
                                .font(.system(size: 16))
                                .padding(.horizontal, 4)
                                .padding(.vertical, 8)
                        }
                        
                        TextEditor(text: $inputText)
                            .font(.system(size: 16))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: max(36, min(120, CGFloat(inputText.count / 30) * 20)))
                            .scrollContentBackground(.hidden)
                            .background(Color(.lightGray))
                            .cornerRadius(8)
                            .focused($isInputFocused)
                            .onChange(of: inputText) { newValue in
                                if newValue.contains("\n") {
                                    inputText = newValue.replacingOccurrences(of: "\n", with: "")
                                    if !inputText.isEmpty {
                                        hasSubmittedText = true
                                        isEditing = false
                                        isInputFocused = false
                                    }
                                }
                            }
                    }
                } else {
                    SubmittedTextView(
                        text: inputText,
                        onEdit: {
                            isEditing = true
                            isInputFocused = true
                        }
                    )
                }
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 16)
            .frame(width: windowWidth)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 25))
            
            // Tags Section
            TagListView(selectedTags: $selectedTags)
                .frame(height: 40)
                .frame(maxWidth: windowWidth)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
}

// MARK: - Tag Views
private struct TagListView: View {
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
        GeometryReader { geometry in
            FlexibleLayoutView(
                availableWidth: geometry.size.width,
                data: visibleTags + [plusTag] + (showHiddenTags ? hiddenTags : []),
                spacing: 8,
                alignment: .leading
            ) { tag in
                TagButton(tag: tag) {
                    if tag.type == .plus {
                        showHiddenTags.toggle()
                    } else {
                        handleTagTap(tag)
                    }
                }
                .opacity(showHiddenTags && !tag.isSelected && tag.type != .plus ? 0.6 : 1.0)
            }
            .padding(.horizontal, 8)
            .animation(.easeInOut, value: showHiddenTags)
        }
    }
    
    private func handleTagTap(_ tag: Tag) {
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

private struct TagButton: View {
    private let tag: Tag
    private let action: () -> Void
    
    fileprivate init(tag: Tag, action: @escaping () -> Void) {
        self.tag = tag
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
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

// MARK: - Other Subviews
private struct TextInputView: View {
    @Binding var inputText: String
    @Binding var hasSubmittedText: Bool
    @Binding var isEditing: Bool
    @FocusState private var isFocused: Bool
    
    var body: some View {
        TextField("What would you like to do?", text: $inputText, axis: .vertical)
            .textFieldStyle(PlainTextFieldStyle())
            .font(.system(size: 16))
            .foregroundColor(.black)
            .lineLimit(1...5)
            .frame(maxWidth: .infinity)
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemBackground))
            )
            .focused($isFocused)
            .onSubmit {
                if !inputText.isEmpty {
                    hasSubmittedText = true
                    isEditing = false
                    isFocused = false
                }
            }
            .submitLabel(.done)
    }
}

private struct SubmittedTextView: View {
    let text: String
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text(text)
                .font(.system(size: 16))
                .foregroundColor(.black)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DynamicWindowView()
} 
