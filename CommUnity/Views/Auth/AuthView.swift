import SwiftUI

struct AuthView: View {
    @EnvironmentObject private var authViewModel: AuthViewModel
    @State private var isSignUp = false
    @State private var name = ""
    @State private var location = ""
    @State private var email = ""
    @State private var password = ""

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [AppTheme.background, Color.white, AppTheme.background],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 26) {
                    VStack(alignment: .leading, spacing: 16) {
                        Label("CommUnity", systemImage: "person.3.sequence.fill")
                            .font(.title2.weight(.bold))
                            .foregroundStyle(AppTheme.primary)

                        Text("Your local space for updates, concerns, and trusted selling.")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(AppTheme.textPrimary)

                        Text("Start with a simple mocked account, then step into your barangay, campus, or subdivision feed.")
                            .font(.subheadline)
                            .foregroundStyle(AppTheme.textSecondary)
                    }

                    VStack(alignment: .leading, spacing: 18) {
                        Picker("Auth Mode", selection: $isSignUp) {
                            Text("Login").tag(false)
                            Text("Sign Up").tag(true)
                        }
                        .pickerStyle(.segmented)

                        Group {
                      
                            labeledField(title: "Email", text: $email, placeholder: "you@example.com")
                                .textInputAutocapitalization(.never)
                                .keyboardType(.emailAddress)

                            secureField
                          
                        }

                        if let error = authViewModel.authErrorMessage {
                            Text(error)
                                .font(.footnote.weight(.medium))
                                .foregroundStyle(.red)
                        }

                        Button(isSignUp ? "Create Account" : "Continue") {
                            if isSignUp {
                                authViewModel.signUp(email: email, password: password)
                            } else {
                                authViewModel.login(email: email, password: password)
                            }
                        }
                        .buttonStyle(PrimaryButtonStyle())

                        Text("Mocked authentication only. Any name can be used to enter the app.")
                            .font(.caption)
                            .foregroundStyle(AppTheme.textSecondary)
                    }
                    .padding(22)
                    .background(AppTheme.card)
                    .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
                    .shadow(color: Color.black.opacity(0.06), radius: 18, y: 10)
                }
                .padding(24)
            }
        }
    }

    private func labeledField(title: String, text: Binding<String>, placeholder: String) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            TextField(placeholder, text: text)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .autocorrectionDisabled()
        }
    }

    private var secureField: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Password")
                .font(.subheadline.weight(.semibold))
                .foregroundStyle(AppTheme.textPrimary)

            SecureField("Enter any password", text: $password)
                .padding(.horizontal, 16)
                .frame(height: 54)
                .background(AppTheme.background)
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
        }
    }
}

private struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline.weight(.bold))
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [AppTheme.primary, AppTheme.secondary],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct AuthView_Previews: PreviewProvider {
    static var previews: some View {
        AuthView()
            .environmentObject(AuthViewModel.preview)
    }
}
