import SwiftUI

struct AuthView: View {
    @EnvironmentObject var session: AuthSession
    @EnvironmentObject var config: AppConfig
    @EnvironmentObject var app: AppModel

    @State private var creating = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var gender = "unspecified"
    @State private var error: String?
    @State private var successInfo: String?
    @State private var busy = false
    @State private var showSettings = false
    @State private var showResetAlert = false
    @State private var resetEmailInput = ""
    @State private var showResetDialog = false
    
    // Smooth entrance state
    @State private var hasAppeared = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Warm organic background with gentle ambient gradients & shapes
                BackgroundOrganicShapes()
                    .ignoresSafeArea()

                // Responsive container
                ScrollView {
                    VStack(spacing: 0) {
                        // Header with Logo and Brand
                        headerSection
                            .padding(.top, 16)
                            .padding(.bottom, 12)
                        
                        // Illustration with subtle floating animation
                        CollaborationIllustrationView()
                            .padding(.bottom, 14)
                        
                        // Authentication Card
                        authCardView
                            .frame(maxWidth: 480) // Perfectly proportioned on iPhone, iPad & Mac
                            .padding(.horizontal, 20)
                            .padding(.bottom, 24)
                    }
                    .frame(maxWidth: .infinity)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
            .opacity(hasAppeared ? 1 : 0)
            .offset(y: hasAppeared ? 0 : 16)
            .animation(.easeOut(duration: 0.45), value: hasAppeared)
            .onAppear {
                hasAppeared = true
            }
            .alert("Reset Password", isPresented: $showResetDialog) {
                TextField("Your email address", text: $resetEmailInput)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)
                Button("Send link") {
                    handlePasswordReset(email: resetEmailInput)
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Enter your email address and we'll send you a password reset link.")
            }
            .alert("Check your inbox", isPresented: $showResetAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(successInfo ?? "Password reset instructions have been sent.")
            }
        }
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: 10) {
            // Overlapping circles icon
            SkillSwapLogoIcon(size: 44)
            
            // SkillSwap Title
            Text("SkillSwap")
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundColor(SkillSwapTheme.forestGreen)
            
            // App Tagline
            Text("Find teammates who complement your skills, and build a reputation in every domain.")
                .font(.system(size: 13.5, weight: .regular))
                .foregroundColor(SkillSwapTheme.textSecondary)
                .multilineTextAlignment(.center)
                .lineSpacing(2)
                .padding(.horizontal, 32)
        }
    }

    // MARK: - Auth Card

    private var authCardView: some View {
        VStack(spacing: 16) {
            // Segmented Sign in / Create account selector
            AuthSegmentedControl(isCreateAccount: $creating)
                .padding(.bottom, 4)

            // Setup problem banner (e.g. Firebase plist missing)
            if let problem = session.setupProblem {
                ErrorBanner(message: problem)
            }
            
            // Action error banner
            if let err = error {
                ErrorBanner(message: err)
            }

            // Mode content: Sign in & Create account forms strictly matching reference image
            firebaseModeContent
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color.white.opacity(0.82))
                .shadow(color: Color.black.opacity(0.04), radius: 16, x: 0, y: 6)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(SkillSwapTheme.cardBorder, lineWidth: 1)
        )
    }

    // MARK: - Firebase Mode Forms

    private var firebaseModeContent: some View {
        VStack(spacing: 14) {
            // Inputs with transition
            VStack(spacing: 12) {
                if creating {
                    // Full Name input
                    SkillSwapInputField(
                        icon: "person",
                        placeholder: "Full name",
                        text: $name,
                        contentType: .name,
                        autocapitalization: .words
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .top)),
                        removal: .opacity
                    ))

                    // Avatar / Gender picker
                    avatarPickerRow
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity
                        ))
                }

                // Email Input
                SkillSwapInputField(
                    icon: "envelope",
                    placeholder: "Email",
                    text: $email,
                    contentType: .emailAddress,
                    keyboardType: .emailAddress,
                    autocapitalization: .never
                )

                // Password Input
                SkillSwapInputField(
                    icon: "lock",
                    placeholder: "Password (6+ characters)",
                    text: $password,
                    isSecure: true,
                    contentType: creating ? .newPassword : .password
                )
            }
            .animation(.easeInOut(duration: 0.28), value: creating)

            // Forgot Password (only in Sign In mode)
            if !creating {
                HStack {
                    Spacer()
                    Button {
                        resetEmailInput = email
                        showResetDialog = true
                    } label: {
                        Text("Forgot password?")
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(SkillSwapTheme.forestGreen)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, 2)
            }

            // Primary Submit Button
            SkillSwapPrimaryButton(
                title: creating ? "Create account" : "Sign in",
                isLoading: busy,
                isDisabled: !canSubmit
            ) {
                submit()
            }
            .padding(.top, 4)

            // Footnote / Helper Message
            if creating {
                Text("Gender is optional and only picks your avatar.")
                    .font(.system(size: 11.5))
                    .foregroundColor(SkillSwapTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 2)
            } else {
                // Social Auth Separator & Buttons
                socialAuthSection
            }
        }
    }

    // MARK: - Avatar Picker Row

    private var avatarPickerRow: some View {
        HStack(spacing: 12) {
            Image(systemName: "person.crop.circle")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(SkillSwapTheme.textSecondary)
                .frame(width: 22)
            
            Text("Avatar")
                .font(.system(size: 15))
                .foregroundColor(SkillSwapTheme.textDark)
            
            Spacer()
            
            Menu {
                Picker("Avatar", selection: $gender) {
                    genderOptions
                }
            } label: {
                HStack(spacing: 6) {
                    Text(avatarLabel(gender))
                        .font(.system(size: 14))
                        .foregroundColor(SkillSwapTheme.textSecondary)
                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(SkillSwapTheme.textSecondary)
                }
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(SkillSwapTheme.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(SkillSwapTheme.inputBorder, lineWidth: 1)
        )
    }

    // MARK: - Social Authentication Section

    private var socialAuthSection: some View {
        VStack(spacing: 12) {
            HStack {
                Rectangle()
                    .fill(SkillSwapTheme.inputBorder)
                    .frame(height: 1)
                Text("or continue with")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(SkillSwapTheme.textSecondary.opacity(0.8))
                    .padding(.horizontal, 8)
                Rectangle()
                    .fill(SkillSwapTheme.inputBorder)
                    .frame(height: 1)
            }
            .padding(.top, 8)

            HStack(spacing: 12) {
                SocialAuthButton(type: .google) {
                    error = "Google Sign-In is configured on backend Firebase. Use email/password or Dev mode for local testing."
                }
                
                SocialAuthButton(type: .apple) {
                    error = "Apple Sign-In is configured on backend Firebase. Use email/password or Dev mode for local testing."
                }
            }
        }
    }

    // MARK: - Dev Mode Section

    private var devModeContent: some View {
        VStack(spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Dev mode active")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(SkillSwapTheme.forestGreen)
                    Text("No password required. Connects to local server.")
                        .font(.system(size: 11.5))
                        .foregroundColor(SkillSwapTheme.textSecondary)
                }
                Spacer()
            }
            .padding(10)
            .background(SkillSwapTheme.sageLight.opacity(0.4))
            .cornerRadius(10)

            SkillSwapInputField(
                icon: "person",
                placeholder: "Your Name",
                text: $name,
                contentType: .name,
                autocapitalization: .words
            )

            avatarPickerRow

            SkillSwapPrimaryButton(
                title: "Continue to SkillSwap",
                isLoading: busy,
                isDisabled: name.trimmingCharacters(in: .whitespaces).count < 2
            ) {
                attempt($error, busy: $busy) {
                    session.devSignIn(name: name)
                    let _: UserProfile = try await API.shared.put("/api/me", body: ["name": name, "gender": gender])
                    await app.loadMe()
                }
            }
            .padding(.top, 4)

            // Seeded Demo Students
            VStack(alignment: .leading, spacing: 8) {
                Text("Demo students (after running seed.sh)")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(SkillSwapTheme.textSecondary)
                    .padding(.top, 6)

                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 8) {
                    ForEach(["demo_aditi", "demo_meera", "demo_ananya", "demo_rohan"], id: \.self) { uid in
                        Button {
                            session.devSignInRaw(token: "dev:\(uid)")
                        } label: {
                            HStack(spacing: 6) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 12))
                                    .foregroundColor(SkillSwapTheme.forestGreen)
                                Text(uid.replacingOccurrences(of: "demo_", with: "").capitalized)
                                    .font(.system(size: 12.5, weight: .medium))
                                    .foregroundColor(SkillSwapTheme.textDark)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: 36)
                            .background(SkillSwapTheme.inputBackground)
                            .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10, style: .continuous)
                                    .stroke(SkillSwapTheme.inputBorder, lineWidth: 1)
                            )
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private var genderOptions: some View {
        Group {
            Text("Prefer not to say").tag("unspecified")
            Text("Female").tag("female")
            Text("Male").tag("male")
            Text("Other").tag("other")
        }
    }

    private func avatarLabel(_ key: String) -> String {
        switch key {
        case "female": return "Female"
        case "male": return "Male"
        case "other": return "Other"
        default: return "Prefer not to say"
        }
    }

    private var canSubmit: Bool {
        let okBasics = email.contains("@") && password.count >= 6
        return creating ? (okBasics && name.trimmingCharacters(in: .whitespaces).count >= 2) : okBasics
    }

    private func submit() {
        attempt($error, busy: $busy) {
            if config.authMode == .dev {
                let displayName = creating ? name : (email.components(separatedBy: "@").first ?? "Student")
                session.devSignIn(name: displayName)
                let _: UserProfile = try await API.shared.put("/api/me", body: ["name": displayName, "gender": gender])
                await app.loadMe()
            } else {
                if creating {
                    try await session.signUp(email: email, password: password)
                    let _: UserProfile = try await API.shared.put("/api/me", body: ["name": name, "gender": gender])
                    await app.loadMe()
                } else {
                    try await session.signIn(email: email, password: password)
                }
            }
        }
    }

    private func handlePasswordReset(email: String) {
        guard !email.isEmpty, email.contains("@") else {
            error = "Please enter a valid email address."
            return
        }
        attempt($error, busy: $busy) {
            try await session.resetPassword(email: email)
            successInfo = "Password reset instructions have been sent to \(email)."
            showResetAlert = true
        }
    }
}
