import SwiftUI

struct ContentView: View {
    @State private var activeCase: Case?
    @State private var clues: [Clue] = []
    @State private var suspects: [Suspect] = []
    @State private var activeTab: SidebarTab = .dashboard
    
    enum SidebarTab {
        case dashboard, corkboard, database, signal, decryption, interrogation
    }
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()
            
            Group {
                if horizontalSizeClass == .compact {
                    TabView(selection: $activeTab) {
                        if let caseFolder = activeCase {
                            DashboardView(activeCase: caseFolder, clues: $clues, suspects: $suspects)
                                .tabItem {
                                    Label("Dossier", systemImage: "folder.badge.gearshape")
                                }
                                .tag(SidebarTab.dashboard)
                            
                            CorkboardView(caseId: caseFolder.id, clues: $clues)
                                .tabItem {
                                    Label("Corkboard", systemImage: "lasso.and.app.badge")
                                }
                                .tag(SidebarTab.corkboard)
                            
                            DatabaseQueryView()
                                .tabItem {
                                    Label("Intel DB", systemImage: "server.rack")
                                }
                                .tag(SidebarTab.database)
                            
                            AudioSpectrogramView()
                                .tabItem {
                                    Label("Signal", systemImage: "waveform.path")
                                }
                                .tag(SidebarTab.signal)
                            
                            HackingMinigameView()
                                .tabItem {
                                    Label("Decrypt", systemImage: "lock.laptopcomputer")
                                }
                                .tag(SidebarTab.decryption)
                            
                            InterrogationView(caseId: caseFolder.id, suspects: $suspects)
                                .tabItem {
                                    Label("Interrogate", systemImage: "bubble.left.and.exclamationmark.bubble.right")
                                }
                                .tag(SidebarTab.interrogation)
                        } else {
                            ProgressView("LOADING SYSTEM SEEDS...")
                                .tint(.green)
                                .foregroundColor(.green)
                                .font(.system(.body, design: .monospaced))
                        }
                    }
                    .tint(.green)
                } else {
                    NavigationSplitView {
                        // Sidebar Navigation Drawer
                        VStack(alignment: .leading, spacing: 20) {
                            // Tactical Title
                            VStack(alignment: .leading, spacing: 4) {
                                Text("BLACKBOX DETECTIVE")
                                    .font(.system(.headline, design: .monospaced))
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.2))
                                    .bold()
                                Text("SECURE OS v4.09")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                            }
                            .padding(.horizontal)
                            .padding(.top, 20)
                            
                            Divider().background(Color.green.opacity(0.3))
                            
                            // Navigation Options
                            ScrollView {
                                VStack(spacing: 8) {
                                    SidebarButton(
                                        title: "CASE DOSSIER",
                                        icon: "folder.badge.gearshape",
                                        isActive: activeTab == .dashboard
                                    ) {
                                        activeTab = .dashboard
                                    }
                                    
                                    SidebarButton(
                                        title: "CORKBOARD",
                                        icon: "lasso.and.app.badge",
                                        isActive: activeTab == .corkboard
                                    ) {
                                        activeTab = .corkboard
                                    }
                                    
                                    SidebarButton(
                                        title: "INTEL DATABASE",
                                        icon: "server.rack",
                                        isActive: activeTab == .database
                                    ) {
                                        activeTab = .database
                                    }
                                    
                                    SidebarButton(
                                        title: "SIGNAL ANALYZER",
                                        icon: "waveform.path",
                                        isActive: activeTab == .signal
                                    ) {
                                        activeTab = .signal
                                    }
                                    
                                    SidebarButton(
                                        title: "DECRYPT PORTAL",
                                        icon: "lock.laptopcomputer",
                                        isActive: activeTab == .decryption
                                    ) {
                                        activeTab = .decryption
                                    }
                                    
                                    SidebarButton(
                                        title: "INTERROGATION",
                                        icon: "bubble.left.and.exclamationmark.bubble.right",
                                        isActive: activeTab == .interrogation
                                    ) {
                                        activeTab = .interrogation
                                    }
                                }
                                .padding(.horizontal, 8)
                            }
                            
                            Spacer()
                            
                            // Agency Badge/Logo simulation
                            VStack(alignment: .center, spacing: 6) {
                                Image(systemName: "shield.lefthalf.filled")
                                    .font(.system(size: 32))
                                    .foregroundColor(.green.opacity(0.5))
                                Text("CLASSIFIED AGENT USE ONLY")
                                    .font(.system(.caption2, design: .monospaced))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.bottom, 20)
                        }
                        .background(Color(red: 0.08, green: 0.08, blue: 0.1))
                        .navigationBarBackButtonHidden()
                    } detail: {
                        ZStack {
                            Color(red: 0.05, green: 0.05, blue: 0.07).ignoresSafeArea()
                            if let caseFolder = activeCase {
                                switch activeTab {
                                case .dashboard:
                                    DashboardView(activeCase: caseFolder, clues: $clues, suspects: $suspects)
                                case .corkboard:
                                    CorkboardView(caseId: caseFolder.id, clues: $clues)
                                case .database:
                                    DatabaseQueryView()
                                case .signal:
                                    AudioSpectrogramView()
                                case .decryption:
                                    HackingMinigameView()
                                case .interrogation:
                                    InterrogationView(caseId: caseFolder.id, suspects: $suspects)
                                }
                            } else {
                                ProgressView("LOADING SYSTEM SEEDS...")
                                    .tint(.green)
                                    .foregroundColor(.green)
                                    .font(.system(.body, design: .monospaced))
                            }
                        }
                    }
                }
            }
            
            // CRT Retro Overlay (Subtle scanline shader simulation)
            CRTScanlinesOverlay()
                .allowsHitTesting(false)
        }
        .preferredColorScheme(.dark)
        .onAppear {
            loadInitialData()
        }
    }
    
    private func loadInitialData() {
        let db = DatabaseManager.shared
        let cases = db.fetchCases()
        if let firstCase = cases.first {
            self.activeCase = firstCase
            self.clues = db.fetchClues(caseId: firstCase.id)
            self.suspects = db.fetchSuspects(caseId: firstCase.id)
        }
    }
}

// MARK: - Sidebar Button Helper

struct SidebarButton: View {
    let title: String
    let icon: String
    let isActive: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16))
                    .foregroundColor(isActive ? .black : Color(red: 0.0, green: 0.9, blue: 0.2))
                
                Text(title)
                    .font(.system(.subheadline, design: .monospaced))
                    .bold()
                    .foregroundColor(isActive ? .black : .white)
                
                Spacer()
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(isActive ? Color(red: 0.0, green: 0.9, blue: 0.2) : Color.clear)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .stroke(Color(red: 0.0, green: 0.9, blue: 0.2).opacity(0.3), lineWidth: isActive ? 0 : 1)
            )
        }
    }
}

// MARK: - Retro Visual Overlay

struct CRTScanlinesOverlay: View {
    var body: some View {
        GeometryReader { geo in
            Path { path in
                let spacing: CGFloat = 4
                var y: CGFloat = 0
                while y < geo.size.height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: geo.size.width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.black.opacity(0.12), lineWidth: 1)
        }
    }
}
