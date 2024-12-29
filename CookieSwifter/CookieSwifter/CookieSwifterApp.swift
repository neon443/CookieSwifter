//
//  CookieSwifterApp.swift
//  CookieSwifter
//
//  Created by Nihaal Sharma on 16/12/2024.
//

import SwiftUI

@main
struct CookieSwifterApp: App {
	let listOfNames = ["John", "Jane", "Alex", "Chris", "Taylor", "Morgan", "Emily", "Joshua", "Sophie", "Lucas", "Olivia", "Liam", "Isabella", "Ethan", "Amelia", "Aiden", "Mia", "James", "Charlotte", "Benjamin", "Ava", "Henry", "Ella", "Samuel", "Grace", "Daniel", "Zoe", "Matthew", "Madeline", "Ryan", "Chloe", "Michael", "Leah", "William", "Hannah", "David", "Scarlett", "Jack", "Victoria", "Noah", "Lily", "Gabriel", "Sophia", "Caleb", "Harper", "Mason", "Lillian", "Nathan", "Eleanor", "Jacob", "Ruby", "Isaac", "Harper", "Jackson", "Abigail", "Charlotte", "Oliver", "Ella", "Scarlett", "Henry", "Evelyn", "Elijah", "Aria", "Mason", "Amos", "Leo", "Luna", "Zachary", "Hazel", "Samuel", "Nora", "Owen", "Anna"]
    var body: some Scene {
        WindowGroup {
			ContentView(
				game: CookieGame(),
				gameName: (listOfNames.randomElement() ?? "Bob") + "'s Bakery"
			)
        }
    }
}
