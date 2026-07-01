import SwiftUI

struct AudioSpectrogramView: View {
    @State private var isPlaying = false
    @State private var isHighFreqFiltered = false
    @State private var isDeNoised = false
    @State private var isVocalIsolated = false
    
    @State private var waveformValues: [CGFloat] = Array(repeating: 10, count: 40)
    @State private var timer: Timer?
    @State private var analysisOutput = "STANDBY: PRESS PLAY TO ANALYZE AUDIO TAPE SIGNAL."
    
    var body: some View {
        VStack(spacing: 20) {
            // Header Info
            VStack(alignment: .leading, spacing: 4) {
                Text("EVIDENCE SIGNAL ANALYZER")
                    .font(.system(.headline, design: .monospaced))
                    .foregroundColor(.green)
                    .bold()
                Text("SOURCE: TAPE_409_INTERCEPT.RAW // SIGNAL ENHANCEMENT ENGINE")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.black.opacity(0.6))
            .overlay(Rectangle().stroke(Color.green.opacity(0.3), lineWidth: 1))
            
            // Interactive Waveform / Spectrogram Visualizer
            VStack(spacing: 8) {
                Text("DYNAMIC SIGNAL SPECTRUM (SPECTROGRAM)")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                
                HStack(spacing: 4) {
                    ForEach(0..<waveformValues.count, id: \.self) { index in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(waveformColor(for: index))
                            .frame(width: 8, height: isPlaying ? waveformValues[index] : 10)
                    }
                }
                .frame(height: 120)
                .frame(maxWidth: .infinity)
                .background(Color.black.opacity(0.8))
                .border(Color.green.opacity(0.3))
                
                // Play / Pause Controls
                HStack(spacing: 20) {
                    Button(action: {
                        togglePlay()
                    }) {
                        HStack {
                            Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                            Text(isPlaying ? "PAUSE SIGNAL" : "PLAY SIGNAL")
                        }
                        .font(.system(.body, design: .monospaced))
                        .foregroundColor(.black)
                        .padding(.vertical, 8)
                        .padding(.horizontal, 16)
                        .background(Color.green)
                        .cornerRadius(4)
                    }
                }
                .padding(.top, 8)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            // Filter Matrix Switches
            VStack(alignment: .leading, spacing: 16) {
                Text("FILTER ENHANCEMENT MATRIX")
                    .font(.system(.subheadline, design: .monospaced))
                    .foregroundColor(.white)
                    .bold()
                    .padding(.bottom, 4)
                
                Toggle(isOn: $isHighFreqFiltered) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("HIGH-FREQUENCY ISOLATION (4KHz - 8KHz)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Isolate background acoustics and environment reverb.")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .onChange(of: isHighFreqFiltered) { _ in runSignalAnalysis() }
                
                Toggle(isOn: $isDeNoised) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("ACTIVE NOISE CANCELLATION (DE-NOISE)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Filter white noise and electromagnetic tap interference.")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .onChange(of: isDeNoised) { _ in runSignalAnalysis() }
                
                Toggle(isOn: $isVocalIsolated) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("VOCAL COMPRESSION PATHWAY (ISOLATOR)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.white)
                        Text("Amplify voice print harmonics and voice amplitude ratios.")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .green))
                .onChange(of: isVocalIsolated) { _ in runSignalAnalysis() }
            }
            .padding()
            .background(Color.black.opacity(0.2))
            .border(Color.green.opacity(0.2))
            
            // Analysis Output Console
            VStack(alignment: .leading, spacing: 6) {
                Text("ANALYSIS CONSOLE OUTPUT:")
                    .font(.system(.caption2, design: .monospaced))
                    .foregroundColor(.gray)
                
                Text(analysisOutput)
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(isAnalysisUnlocked ? Color(red: 0.0, green: 0.9, blue: 0.2) : .yellow)
                    .lineSpacing(4)
                    .frame(maxWidth: .infinity, minHeight: 80, alignment: .topLeading)
                    .padding()
                    .background(Color.black)
                    .border(isAnalysisUnlocked ? Color.green.opacity(0.5) : Color.yellow.opacity(0.3))
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            if UserDefaults.standard.bool(forKey: "signal_solved") {
                isHighFreqFiltered = true
                isDeNoised = true
                isVocalIsolated = false
                isPlaying = true
                runSignalAnalysis()
            }
        }
    }
    
    private var isAnalysisUnlocked: Bool {
        return isHighFreqFiltered && isDeNoised && !isVocalIsolated
    }
    
    private func waveformColor(for index: Int) -> Color {
        if isAnalysisUnlocked {
            return .red
        }
        if isDeNoised {
            return .cyan
        }
        return .green
    }
    
    private func togglePlay() {
        isPlaying.toggle()
        if isPlaying {
            // Start simple dynamic waveform height animation loop
            timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
                withAnimation(.easeInOut(duration: 0.1)) {
                    for i in 0..<waveformValues.count {
                        let scale = isDeNoised ? 0.4 : 1.0
                        let maxVal = isAnalysisUnlocked ? 110.0 : 80.0
                        let rand = CGFloat.random(in: 10...maxVal) * scale
                        waveformValues[i] = rand + (isHighFreqFiltered && i % 3 == 0 ? 30 : 0)
                    }
                }
            }
        } else {
            timer?.invalidate()
            timer = nil
        }
        runSignalAnalysis()
    }
    
    private func runSignalAnalysis() {
        if !isPlaying {
            analysisOutput = "STANDBY: CHOOSE TAPE AND PRESS PLAY TO START DYNAMIC SPECTROGRAM SCAN."
            return
        }
        
        switch (isHighFreqFiltered, isDeNoised, isVocalIsolated) {
        case (true, true, false):
            analysisOutput = "🟢 SIGNAL INTRUSION EXTRACTED SUCCESSFULLY!\n\nBACKGROUND REVERB EXPOSED: Distinct train horn sequence detected at 400Hz frequency cycles. Cross-referencing timetable: Matches 'Cargo Train Express' passing Cargo Warehouse 4 adjacent to Airport Terminal 4. Dr. Vance was in the warehouse area at 4:15 PM!"
            UserDefaults.standard.set(true, forKey: "signal_solved")
        case (false, false, true):
            analysisOutput = "🟡 VOCALS AMPLIFIED. Vance: 'The delivery is delayed... formulation degrades at room temperature.' Reverb is heavily muffled by vocal boost. Background details are masked."
        case (true, false, false):
            analysisOutput = "🟡 HIGH-FREQUENCY FILTER CONFIGURED: Background hum isolated, but high static hiss interferes. Need noise reduction (De-Noise) to clean signal spikes."
        case (false, true, false):
            analysisOutput = "🟡 SPECTRUM DE-NOISED: Tap hiss filtered out, signal is smooth. Vocals clear, but background acoustics require High-Frequency Isolation to capture environmental echoes."
        default:
            analysisOutput = "⚠️ ACOUSTIC SCAN DISTORTED. Active filters are clashing. Adjust isolation frequencies and vocal isolation toggles to extract cleaner target indicators."
        }
    }
}
