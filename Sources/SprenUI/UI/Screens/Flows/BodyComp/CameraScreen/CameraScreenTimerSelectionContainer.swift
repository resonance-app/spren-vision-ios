//
//  CameraScreenTimerSelectionContainer.swift
//  SprenInternal
//
//  Created by Fernando on 8/18/22.
//

import SwiftUI

struct CameraScreenTimerSelectionContainer: View {
    
    var model: CameraViewModel
    var buttonCallBack : () -> Void
    
    var body: some View {
        ZStack {
            VisualEffectView(effect: UIBlurEffect(style: .dark)).edgesIgnoringSafeArea(.bottom)
            
            HStack(spacing: Autoscale.convert(30)) {
                Button {
                    model.setTimer(nil)
                    buttonCallBack()
                } label: {
                    Text("timer off")
                        .font(.sprenParagraph)
                        .foregroundColor(model.isTimerOn == nil ? Color.sprenUISecondaryColor : .white).padding()
                }

                Button {
                    model.setTimer(5)
                    buttonCallBack()
                } label: {
                    Text("5s")
                        .font(.sprenParagraph)
                        .foregroundColor(model.isTimerOn == 5 ? Color.sprenUISecondaryColor : .white).padding()
                }
                
                Button {
                    model.setTimer(10)
                    buttonCallBack()
                } label: {
                    Text("10s")
                        .font(.sprenParagraph)
                        .foregroundColor(model.isTimerOn == 10 ? Color.sprenUISecondaryColor : .white).padding()
                }
            }
        }.frame(height: Autoscale.convert(44)).cornerRadius(Autoscale.convert(44))
            .padding()
            .animation(.easeInOut)
    }
}

struct CameraScreenTimerSelectionContainer_Previews: PreviewProvider {
    static var previews: some View {
        CameraScreenTimerSelectionContainer(model: CameraViewModel(), buttonCallBack: {
            return
        })
    }
}