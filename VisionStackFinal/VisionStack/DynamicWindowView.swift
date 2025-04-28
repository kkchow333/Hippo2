import SwiftUI

struct DynamicWindowView: View {
    @State private var inputText: String = ""
    @State private var hasSubmittedText: Bool = false
    @State private var isEditing: Bool = false
    @State private var selectedTags: Set<String> = []
    
    // Customizable window dimensions
    let windowWidth: CGFloat = 500
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Main Window Content
            HStack(alignment: .center, spacing: 12) {
                // Profile Image
                Circle()
                    .fill(Color(.systemGray5))
                    .frame(width: 40, height: 40)
                    .overlay(
                        Image(systemName: "person.fill")
                            .foregroundColor(Color(.systemGray2))
                    )
                
                if !hasSubmittedText || isEditing {
                    TextInputView(
                        inputText: $inputText,
                        hasSubmittedText: $hasSubmittedText,
                        isEditing: $isEditing
                    )
                } else {
                    SubmittedTextView(
                        text: inputText,
                        onEdit: {
                            isEditing = true
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

// MARK: - Other Subviews
private struct TextInputView: View {
    @Binding var inputText: String
    @Binding var hasSubmittedText: Bool
    @Binding var isEditing: Bool
    
    var body: some View {
        HStack {
            TextField("Add reminder", text: $inputText)
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
