//
//  ReadinessResult.swift
//  
//
//  Created by Keith Carolus on 9/23/22.
//

import SwiftUI

struct ReadinessResult: View {
    
    @Environment(\.colorScheme) var colorScheme
    
    let readiness: Int?
    let onInfoButtonTap: () -> Void
    
    var body: some View {
        VStack {
            VStack {
                HStack {
                    Text("Recovery").font(.sprenAlertTitle)
                    Spacer()
                    Button(action: onInfoButtonTap, label: {
                        Image(systemName: "info.circle")
                            .foregroundColor(.sprenGray)
                    })
                }
                .sprenUIPadding()
                
                ZStack {
                    Circle()
                        .trim(from: 0.15, to: 0.85)
                        .rotation(.degrees(90))
                        .stroke(Color.gray.opacity(0.2), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .frame(height: 120)
                    
                    if let color = getGaugeColor() {
                        Circle()
                            .trim(from: 0.15, to: 0.15+(CGFloat(readiness ?? 10)/10)*0.7)
                            .rotation(.degrees(90))
                            .stroke(color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                            .frame(height: 120)
                    }

                    if let readiness = readiness {
                        VStack(spacing: 0) {
                            Text("\(readiness)")
                                .font(.sprenNumber)
                            Text(getGaugeCaption())
                                .font(.sprenLabelBold)
                                .padding(.vertical, -10)
                        }
                        .sprenUIPadding(.bottom)
                    } else {
                        Text("N/A")
                            .font(.sprenNumber)
                    }
                    
                    VStack {
                        Spacer()
                        HStack {
                            Spacer()
                            Text("Recover")
                                .font(.sprenLabel)
                                .frame(width: 80)
                            
                            Text("Train Hard")
                                .font(.sprenLabel)
                                .frame(width: 80)
                            Spacer()
                        }
                    }
                }
                .frame(height: 130)
                
                if let (blurbHeadline, blurb) = getBlurb() {
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text(blurbHeadline).font(.sprenAlertTitle)
                                .sprenUIPadding([.leading, .top, .trailing])
                            Spacer()
                        }
                        Text(blurb)
                            .fixedSize(horizontal: false, vertical: true)
                            .font(.sprenParagraph)
                            .sprenUIPadding([.leading, .bottom, .trailing])
                    }
                }
            }
            .sprenUIPadding()
            .background(colorScheme == .light ? Color.white : Color.black)
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.2), radius: 8)

        }
        .sprenUIPadding()
    }
}

extension ReadinessResult {
    
    func getGaugeCaption() -> String {
        switch readiness {
        case 1, 2, 3: return "Poor"
        case 4, 5, 6: return "Pay Attention"
        case 7, 8:    return "Good"
        case 9, 10:   return "Optimal"
        case .none:   fallthrough
        default:      return ""
        }
    }
        
    func getGaugeColor() -> Color? {
        switch readiness {
        case 1, 2, 3:     return .readinessRed
        case 4, 5, 6:     return .readinessAmber
        case 7, 8, 9, 10: return .readinessGreen
        case .none:       fallthrough
        default:          return nil
        }
    }
        
    func getBlurb() -> (String, String)? {
        switch readiness {
        case 1, 2, 3:
            return [
                ("Prioritize Recovery","Your resilience is low today. Focus on self-care activities such as relaxation, hydration, and supportive nutrition, and aim for a good night's sleep."),
                ("Give yourself a break","Your nervous system activity is unusually high. Engaging in too much physical or mental activity, or not allowing enough time for rest and recovery, can negatively impact your overall well-being. Take some time to rest and restore your energy."),
                ("It's all about balance","Your resilience is unusually low. Allowing yourself sufficient time for rest and recovery can lead to increased energy and overall well-being. Make self-care a priority today."),
            ].randomElement()
        case 4, 5, 6:
            return [
                ("Take it easier today","Your HRV balance indicates that your body is responding to more stress today. Consider engaging in lower intensity activities and prioritize self-care practices to support recovery."),
                ("Great day to check in","Your body's nervous system activity is elevated. Pay attention to how you are feeling and the impact of your activities on your overall well-being."),
                ("Listen to your body","Your resilience is lower than normal. Today, focus on self-care practices that can help reduce fatigue, improve flexibility, and support overall physical and mental well-being."),
            ].randomElement()
        case 7, 8:
            return [
                ("Do what feels good","Your overall resilience is good. Keep it up! Remember to prioritize self-care activities such as healthy sleep, nutrition, and resonance breathing to maintain your well-being."),
                ("Going strong","Your resilience is good, but your nervous system activity is slightly elevated. Listen to your body and engage in activities that feel manageable and sustainable."),
                ("How are you feeling?","Your overall resilience is at a good level. Listen to your body and do what feels good for you today."),
            ].randomElement()
        case 9, 10:
            return [
                ("Bring it on!","Your HRV balance indicates that you have recovered well and have the energy to tackle the day's challenges with moderate to high intensity."),
                ("Today’s your day","Compared to your recent baseline, your nervous system is well-balanced. Follow your body's lead and do what feels good for you today."),
                ("Remarkable Resilience","You are well-recovered! Your HRV balance indicates that you have the energy to give it your all and will likely recover quickly. Make it your day!"),
            ].randomElement()
        case .none: fallthrough
        default:
            return ("Take another reading","You haven’t taken enough readings recently to generate your personal baseline. Take one more HRV Readiness reading tomorrow to receive a Readiness score and guidance.")
        }
    }

    
}


struct ReadinessResult_Previews: PreviewProvider {
    static var previews: some View {
        ReadinessResult(readiness: 6, onInfoButtonTap: {})
    }
}
