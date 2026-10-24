import SwiftUI

// MARK: - SkillSwap Design System Tokens

enum SkillSwapTheme {
    // Colors inspired by reference image
    static let backgroundCream = Color(red: 247/255, green: 244/255, blue: 236/255)
    static let backgroundWarmBeige = Color(red: 244/255, green: 238/255, blue: 227/255)
    static let cardBackground = Color(red: 247/255, green: 244/255, blue: 236/255)
    static let cardBorder = Color(red: 236/255, green: 230/255, blue: 218/255)
    
    // Primary Forest Green
    static let forestGreen = Color(red: 28/255, green: 65/255, blue: 53/255)
    static let forestGreenDark = Color(red: 20/255, green: 48/255, blue: 39/255)
    
    // Coral Accent
    static let coral = Color(red: 230/255, green: 122/255, blue: 90/255)
    static let coralLight = Color(red: 248/255, green: 185/255, blue: 160/255)
    
    // Sage Green Accents
    static let sage = Color(red: 163/255, green: 184/255, blue: 163/255)
    static let sageLight = Color(red: 209/255, green: 222/255, blue: 209/255)
    
    // Neutral text & borders
    static let textDark = Color(red: 28/255, green: 45/255, blue: 38/255)
    static let textSecondary = Color(red: 108/255, green: 118/255, blue: 110/255)
    static let inputBackground = Color(red: 247/255, green: 244/255, blue: 238/255)
    static let inputBorder = Color(red: 228/255, green: 222/255, blue: 210/255)
    static let inputBorderFocused = Color(red: 28/255, green: 65/255, blue: 53/255)
    static let segmentedTrack = Color(red: 236/255, green: 230/255, blue: 218/255)
}

// MARK: - Logo & Decorative Elements

struct SkillSwapLogoIcon: View {
    var size: CGFloat = 48

    var body: some View {
        ZStack {
            // Left circle (Deep Forest Green)
            Circle()
                .fill(SkillSwapTheme.forestGreen)
                .frame(width: size, height: size)
                .offset(x: -size * 0.22)
            
            // Right circle (Warm Coral with blend mode)
            Circle()
                .fill(SkillSwapTheme.coral)
                .opacity(0.92)
                .frame(width: size, height: size)
                .offset(x: size * 0.22)
                .blendMode(.multiply)
        }
        .frame(width: size * 1.5, height: size)
    }
}

struct BackgroundOrganicShapes: View {
    @State private var animate = false

    var body: some View {
        GeometryReader { proxy in
            let w = proxy.size.width
            let h = proxy.size.height
            
            ZStack {
                // Background warm gradient
                LinearGradient(
                    colors: [
                        SkillSwapTheme.backgroundCream,
                        SkillSwapTheme.backgroundWarmBeige
                    ],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                // Top-left sage organic blob
                Ellipse()
                    .fill(SkillSwapTheme.sage.opacity(0.40))
                    .frame(width: 170, height: 210)
                    .position(x: 10, y: 110)
                    .blur(radius: 20)
                    .offset(x: animate ? 4 : -4, y: animate ? -6 : 6)
                
                // Top-right peach/coral gentle glow
                Ellipse()
                    .fill(SkillSwapTheme.coralLight.opacity(0.35))
                    .frame(width: 190, height: 190)
                    .position(x: w - 20, y: 120)
                    .blur(radius: 30)
                    .offset(x: animate ? -6 : 6, y: animate ? 4 : -4)
                
                // Bottom left subtle blob
                Circle()
                    .fill(SkillSwapTheme.sageLight.opacity(0.45))
                    .frame(width: 220, height: 220)
                    .position(x: 20, y: h - 60)
                    .blur(radius: 25)
                
                // Bottom right peach wave accent
                Ellipse()
                    .fill(SkillSwapTheme.coral.opacity(0.20))
                    .frame(width: 160, height: 160)
                    .position(x: w - 10, y: h - 30)
                    .blur(radius: 25)
                
                // Subtle doodle loop line near top-left
                DoodleLoop()
                    .stroke(SkillSwapTheme.coral.opacity(0.45), style: StrokeStyle(lineWidth: 1.8, lineCap: .round))
                    .frame(width: 32, height: 50)
                    .position(x: 60, y: 110)
                    .rotationEffect(.degrees(animate ? 6 : -6))
                
                // Decorative spark near top right of team
                SparksShape()
                    .fill(SkillSwapTheme.coral)
                    .frame(width: 20, height: 20)
                    .position(x: w * 0.52, y: 195)
                    .opacity(0.85)
            }
            .animation(
                Animation.easeInOut(duration: 5).repeatForever(autoreverses: true),
                value: animate
            )
            .onAppear {
                animate = true
            }
        }
    }
}

struct DoodleLoop: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addCurve(
            to: CGPoint(x: rect.maxX, y: rect.midY),
            control1: CGPoint(x: rect.minX - 10, y: rect.midY),
            control2: CGPoint(x: rect.midX, y: rect.minY)
        )
        p.addCurve(
            to: CGPoint(x: rect.midX, y: rect.maxY),
            control1: CGPoint(x: rect.maxX + 10, y: rect.maxY),
            control2: CGPoint(x: rect.midX, y: rect.maxY)
        )
        return p
    }
}

struct SparksShape: Shape {
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        p.addLine(to: CGPoint(x: rect.maxX * 0.4, y: rect.minY))
        p.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        p.closeSubpath()
        return p
    }
}

// MARK: - Floating Collaboration Illustration

struct CollaborationIllustrationView: View {
    @State private var floatOffset: CGFloat = 0

    var body: some View {
        ZStack {
            // Loaded illustration image
            if let illustrationImg = AuthIllustrationData.image {
                illustrationImg
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 330, maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            } else {
                Image("illustration")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 330, maxHeight: 150)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
            }
        }
        .offset(y: floatOffset)
        .onAppear {
            withAnimation(
                Animation.easeInOut(duration: 3.5)
                    .repeatForever(autoreverses: true)
            ) {
                floatOffset = -6
            }
        }
    }
}

struct LeavesBackgroundShape: View {
    var body: some View {
        HStack(spacing: 160) {
            // Left leaves
            VStack(spacing: -10) {
                Ellipse()
                    .frame(width: 28, height: 48)
                    .rotationEffect(.degrees(-35))
                Ellipse()
                    .frame(width: 24, height: 42)
                    .rotationEffect(.degrees(20))
            }
            // Right leaves
            VStack(spacing: -8) {
                Ellipse()
                    .frame(width: 28, height: 50)
                    .rotationEffect(.degrees(30))
                Ellipse()
                    .frame(width: 22, height: 38)
                    .rotationEffect(.degrees(-15))
            }
        }
    }
}

// MARK: - Animated Segmented Pill Picker

struct AuthSegmentedControl: View {
    @Binding var isCreateAccount: Bool
    @Namespace private var segmentNamespace

    var body: some View {
        HStack(spacing: 0) {
            // Sign in Tab
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isCreateAccount = false
                }
            } label: {
                Text("Sign in")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(!isCreateAccount ? .white : SkillSwapTheme.textDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background {
                if !isCreateAccount {
                    Capsule()
                        .fill(SkillSwapTheme.forestGreen)
                        .matchedGeometryEffect(id: "ACTIVE_SEGMENT", in: segmentNamespace)
                        .shadow(color: SkillSwapTheme.forestGreen.opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
            
            // Create account Tab
            Button {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isCreateAccount = true
                }
            } label: {
                Text("Create account")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(isCreateAccount ? .white : SkillSwapTheme.textDark)
                    .frame(maxWidth: .infinity)
                    .frame(height: 44)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .background {
                if isCreateAccount {
                    Capsule()
                        .fill(SkillSwapTheme.forestGreen)
                        .matchedGeometryEffect(id: "ACTIVE_SEGMENT", in: segmentNamespace)
                        .shadow(color: SkillSwapTheme.forestGreen.opacity(0.25), radius: 6, x: 0, y: 3)
                }
            }
        }
        .padding(4)
        .background(SkillSwapTheme.segmentedTrack)
        .clipShape(Capsule())
    }
}

// MARK: - Custom Rounded Input Fields

struct SkillSwapInputField: View {
    let icon: String
    let placeholder: String
    @Binding var text: String
    var isSecure: Bool = false
    @State private var showPassword: Bool = false
    @FocusState private var isFocused: Bool
    
    var contentType: UITextContentType? = nil
    var keyboardType: UIKeyboardType = .default
    var autocapitalization: TextInputAutocapitalization = .never

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(isFocused ? SkillSwapTheme.forestGreen : SkillSwapTheme.textSecondary)
                .frame(width: 22)
            
            if isSecure && !showPassword {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
                    .textContentType(contentType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 15))
                    .foregroundColor(SkillSwapTheme.textDark)
            } else {
                TextField(placeholder, text: $text)
                    .focused($isFocused)
                    .textContentType(contentType)
                    .keyboardType(keyboardType)
                    .textInputAutocapitalization(autocapitalization)
                    .autocorrectionDisabled(true)
                    .font(.system(size: 15))
                    .foregroundColor(SkillSwapTheme.textDark)
            }
            
            if isSecure {
                Button {
                    showPassword.toggle()
                } label: {
                    Image(systemName: showPassword ? "eye.slash" : "eye")
                        .font(.system(size: 15))
                        .foregroundColor(SkillSwapTheme.textSecondary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
        .frame(height: 52)
        .background(SkillSwapTheme.inputBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(isFocused ? SkillSwapTheme.inputBorderFocused : SkillSwapTheme.inputBorder, lineWidth: isFocused ? 1.5 : 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

// MARK: - Primary Action Button with Arrow

struct SkillSwapPrimaryButton: View {
    let title: String
    var isLoading: Bool = false
    var isDisabled: Bool = false
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Spacer()
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Image(systemName: "arrow.right")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white)
                }
                Spacer()
            }
            .frame(height: 52)
            .background(
                isDisabled ? SkillSwapTheme.forestGreen.opacity(0.45) : SkillSwapTheme.forestGreen
            )
            .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
            .shadow(
                color: isDisabled ? Color.clear : SkillSwapTheme.forestGreen.opacity(0.3),
                radius: 8,
                x: 0,
                y: 4
            )
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(ScaleButtonStyle())
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

// MARK: - Social Auth Button Option

struct SocialAuthButton: View {
    enum SocialType {
        case google
        case apple
    }
    
    let type: SocialType
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                if type == .google {
                    // Google stylized G
                    Text("G")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(SkillSwapTheme.coral)
                    Text("Google")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SkillSwapTheme.textDark)
                } else {
                    Image(systemName: "applelogo")
                        .font(.system(size: 16))
                        .foregroundColor(SkillSwapTheme.textDark)
                    Text("Apple")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(SkillSwapTheme.textDark)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: 46)
            .background(Color.white.opacity(0.85))
            .clipShape(RoundedRectangle(cornerRadius: 23, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 23, style: .continuous)
                    .stroke(SkillSwapTheme.inputBorder, lineWidth: 1)
            )
        }
        .buttonStyle(ScaleButtonStyle())
    }
}
