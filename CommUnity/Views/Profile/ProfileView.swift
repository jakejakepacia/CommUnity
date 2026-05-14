import SwiftUI

struct ProfileView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @EnvironmentObject private var communityViewModel: CommunityViewModel
    @FocusState private var focusedField: EditableField?
    @State private var isEditing = false
    @State private var editedFirstName = ""
    @State private var editedLastName = ""
    @State private var editedEmail = ""

    private enum EditableField {
        case firstName
        case lastName
        case email
    }

    var body: some View {
        let user = authViewModel.currentUser

        List {
            Section {
                HStack(spacing: 16) {
                    Image(systemName: user?.photoSystemName ?? "person.crop.circle.fill")
                        .font(.system(size: 42))
                        .foregroundStyle(AppTheme.primary)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(user?.fullName ?? "Guest")
                            .font(.title3.weight(.bold))
                        
                        Text(user?.email.isEmpty == false ? user?.email ?? "" : "No email set")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
        
                }
                .padding(.vertical, 6)
            }

            Section {
                editableRow(
                    title: "First name",
                    text: $editedFirstName,
                    placeholder: "Enter first name",
                    field: .firstName,
                    keyboardType: .default
                )

                editableRow(
                    title: "Last name",
                    text: $editedLastName,
                    placeholder: "Enter lastname",
                    field: .lastName,
                    keyboardType: .default
                )
                
                editableRow(
                    title: "Email",
                    text: $editedEmail,
                    placeholder: "Enter email",
                    field: .email,
                    keyboardType: .emailAddress
                )
                
            } header: {
                HStack {
                       Text("Profile Info")

                       Spacer()

                       Button {
                           if isEditing {
                               authViewModel.updateProfile(firstName: editedFirstName, lastName: editedLastName, email: editedEmail)
                               focusedField = nil
                           } else {
                               focusedField = .firstName
                           }
                           withAnimation(.easeInOut(duration: 0.2)) {
                               isEditing.toggle()
                           }
                       } label: {
                           if isEditing {
                               Label("Save", systemImage: "checkmark.seal.fill")
                              
                           }else{
                               Label("Edit", systemImage: "pencil")
                           }
                       }
                   }
            }

            Section("Community stats") {
                statRow(title: "Joined communities", value: "\(communityViewModel.joinedCommunities.count)")
                statRow(title: "Selected community", value: communityViewModel.selectedCommunity?.name ?? "None")
                statRow(title: "Admin access", value: (user?.isAdmin ?? false) ? "Enabled" : "Disabled")
            }

            Section("About") {
                Text("CommUnity is a localized mobile hub for announcements, issue reporting, and neighborhood selling.")
                    .foregroundStyle(AppTheme.textSecondary)
            }

            Section {
                Button("Log Out", role: .destructive) {
                    authViewModel.logout()
                }
            }
        }
        .listStyle(.insetGrouped)
        .scrollContentBackground(.hidden)
        .background(AppTheme.background)
        .toolbar(.hidden, for: .navigationBar)
        /* .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "Save" : "Edit") {
                    if isEditing {
                        appViewModel.updateProfile(firstName: editedFirstName, email: editedEmail)
                        focusedField = nil
                    } else {
                        focusedField = .firstName
                    }
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isEditing.toggle()
                    }
                }
            }
        } */
        .onAppear {
            syncDrafts()
        }
        .onChange(of: authViewModel.currentUser?.firstName) { _, _ in
            if !isEditing { syncDrafts() }
        }
        .onChange(of: authViewModel.currentUser?.email) { _, _ in
            if !isEditing { syncDrafts() }
        }
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
            Spacer()
            Text(value)
                .foregroundStyle(AppTheme.textSecondary)
        }
    }

    private func editableRow(
        title: String,
        text: Binding<String>,
        placeholder: String,
        field: EditableField,
        keyboardType: UIKeyboardType
    ) -> some View {
        HStack {
            Text(title)
            Spacer()

            Group {
                if isEditing {
                    TextField(placeholder, text: text)
                        .multilineTextAlignment(.trailing)
                        .textInputAutocapitalization(field == .email ? .never : .words)
                        .autocorrectionDisabled(field == .email)
                        .keyboardType(keyboardType)
                        .focused($focusedField, equals: field)
                } else {
                    Text(text.wrappedValue.isEmpty ? "Not set" : text.wrappedValue)
                        .foregroundStyle(AppTheme.textSecondary)
                }
            }
            .frame(maxWidth: 180, alignment: .trailing)
        }
        .contentShape(Rectangle())
        .onTapGesture {
            if !isEditing {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isEditing = true
                }
            }
            focusedField = field
        }
    }

    private func syncDrafts() {
        editedFirstName = authViewModel.currentUser?.firstName ?? ""
        editedEmail = authViewModel.currentUser?.email ?? ""
        editedLastName = authViewModel.currentUser?.lastName ?? ""
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationStack {
            ProfileView()
                .environmentObject(AuthViewModel.preview)
                .environmentObject(CommunityViewModel.preview)
        }
    }
}
