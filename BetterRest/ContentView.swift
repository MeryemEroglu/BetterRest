//
//  ContentView.swift
//  BetterRest
//
//  Created by Meryem Eroğlu on 26.08.2025.
//

import CoreML
import SwiftUI

struct ContentView: View {
    @State private var sleepAmount = 8.0
    @State private var wakeUp = defaultWakeTime
    @State private var coffeeAmount = 1
    
    static var defaultWakeTime: Date {
        var components = DateComponents()
        components.hour = 8
        components.minute = 0
        return Calendar.current.date(from: components) ?? Date.now
    }
    
    var recommendedSleepTime: String {
        do {
            let config = MLModelConfiguration()
            let model = try SleepCalculator(configuration: config)
            
            let components = Calendar.current.dateComponents([.hour, .minute], from: wakeUp)
            let hour = (components.hour ?? 0) * 60 * 60
            let minute = (components.minute ?? 0) * 60
            
            let prediction = try model.prediction(wake: Double(hour + minute), estimatedSleep: sleepAmount, coffee: Double(coffeeAmount))
            
            let sleepTime = wakeUp - prediction.actualSleep
            return sleepTime.formatted(date: .omitted, time: .shortened)
            
        } catch {
            return "Sorry, there was a problem calculating your sleep time"
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Your recommend sleep time is..."){
                    Text(recommendedSleepTime)
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(.indigo)
                }
                Section("When do you want to wake up?") {
                    DatePicker("Please enter a time", selection: $wakeUp, displayedComponents: .hourAndMinute)
                        .labelsHidden()
                }
                Section("Desired amount of sleep") {
                    Stepper("\(sleepAmount.formatted()) hours", value: $sleepAmount, in: 4...12,
                            step: 0.25)
                }
                Section("Daily coffee intake") {
                    Picker("^[\(coffeeAmount) cup](inflect: true)", selection: $coffeeAmount) {
                        ForEach(1...20, id: \.self) {
                            Text("\($0) \($0 == 1 ? "cup" : "cups")")
                        }
                    }
                }
            }
            .navigationTitle("BetterRest")
            
        }
    }
}

#Preview {
    ContentView()
}
