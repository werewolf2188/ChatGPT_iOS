//
//  ContentView.swift
//  ChatGPT
//
//  Created by Enrique Ricalde on 7/23/24.
//

import SwiftUI
import Combine



struct ContentView: View {
    @State var input: String = ""
    @State var dialogue: [DialogueEntry] = []
    @State var textFieldDisable = false
    @State var subscriptions: Set<AnyCancellable> = []

    let network = NetworkHandler()

    var body: some View {
        VStack {
            List(dialogue) { entry in
                Text(entry.prompt)
            }
            TextField("Input here", text: $input)
                .onSubmit {
                    sendRequest()
                    input = ""
                }
                .submitLabel(.search)
                .disabled(textFieldDisable)
        }.padding()
    }

    func sendRequest() {
        dialogue.append(DialogueEntry(prompt: input, character: .user))
        textFieldDisable = true
        do {
            try network.send(prompt: input)
                .catch({ _ in
                    Empty()
                })
                .last()
                .sink { response in
                    if let choices = response.choices,
                       let choice = choices.first {
                        self.dialogue.append(DialogueEntry(prompt: choice.message.content, character: .system))
                    } else if let error = response.error {
                        self.dialogue.append(DialogueEntry(prompt: error.message, character: .system))
                        
                    }
                    self.textFieldDisable = true
                }.store(in: &subscriptions)
        } catch {
            print("Failure")
        }
    }
}

#Preview {
    ContentView()
}
