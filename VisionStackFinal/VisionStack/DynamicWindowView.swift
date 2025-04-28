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
    
    // Customizable window dimensions
    let windowWidth: CGFloat = 500
    let windowHeight: CGFloat = 300
    
    var body: some View {
        VStack(spacing: 16) {
            // Main Content
            VStack(spacing: 20) {
                HStack(alignment: .top, spacing: 15) {
                    // Profile Image
                    ProfileImageView(
                        imageURL: URL(string: "https://example.com/profile.jpg")!,
                        isLoaded: $isImageLoaded
                    )
                    
                    // Text Input or Message
                    if !hasSubmittedText || isEditing {
                        TextInputView(
                            inputText: $inputText,
                            hasSubmittedText: $hasSubmittedText,
                            isEditing: $isEditing
                        )
                    } else {
                        SubmittedTextView(
                            text: inputText,
                            onEdit: { isEditing = true }
                        )
                    }
                }
            }
            .padding(20)
            .background(Color.white)
            .cornerRadius(20)
            
            // Tags Section
            TagListView(selectedTags: $selectedTags)
                .frame(height: 60)
        }
        .frame(width: windowWidth, height: windowHeight)
        .background(Color.white)
        .cornerRadius(20)
    }
}

// MARK: - Tag Views
private struct TagListView: View {
    @Binding var selectedTags: Set<String>
    
    @State private var tags: [Tag] = [
        Tag(type: .time, title: "Time", isSelected: true),
        Tag(type: .date, title: "Date", isSelected: true),
        Tag(type: .location, title: "Location", isSelected: true),
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
            .padding([.leading, .trailing], 8)
            .padding([.top, .bottom], 8)
            .background(Color.black.opacity(0.2))
            .cornerRadius(12)
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
                    .fontWeight(tag.isSelected ? .medium : .regular)
                
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
                    .fill(tag.isSelected || tag.type == .plus ? Color.white : Color.white.opacity(0.3))
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color(.systemGray4), lineWidth: 1)
                    )
            )
            .foregroundColor(tag.isSelected || tag.type == .plus ? Color(.darkGray) : .white)
        }
    }
}

// MARK: - Other Subviews
private struct ProfileImageView: View {
    let imageURL: URL
    @Binding var isLoaded: Bool
    
    var body: some View {
        AsyncImage(url: imageURL) { phase in
            switch phase {
            case .empty:
                ProgressView()
                    .frame(width: 80, height: 80)
                    .onAppear { isLoaded = false }
            case .success(let image):
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .clipShape(Circle())
                    .onAppear { isLoaded = true }
            case .failure(_):
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.gray)
                    .onAppear { isLoaded = true }
            @unknown default:
                EmptyView()
                    .onAppear { isLoaded = false }
            }
        }
        .background(
            Circle()
                .stroke(Color.gray.opacity(0.3), lineWidth: 2)
        )
        .padding(10)
        .background(
            Circle()
                .fill(Color.white)
                .shadow(color: .gray.opacity(0.2), radius: 5)
        )
    }
}

private struct TextInputView: View {
    @Binding var inputText: String
    @Binding var hasSubmittedText: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            TextField("Text Input", text: $inputText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.black)
                .accentColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .onSubmit {
                    if !inputText.isEmpty {
                        hasSubmittedText = true
                        isEditing = false
                    }
                }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .cornerRadius(25)
    }
}

private struct SubmittedTextView: View {
    let text: String
    let onEdit: () -> Void
    
    var body: some View {
        HStack(alignment: .top) {
            Text(text)
                .font(.system(size: 20))
                .foregroundColor(.black)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
            
            Spacer()
            
            Button(action: onEdit) {
                Image(systemName: "pencil")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
        .frame(maxWidth: .infinity)
        .cornerRadius(25)
    }
}

#Preview {
    DynamicWindowView()
} 
