//
//  Context+UUID.swift
//  Engine
//
//  Created by Kota Nakano on 3/13/18.
//
import Foundation
extension Context {
	static var __uuid__: String {
		let id: Substring = "id" as Substring
		let array: [Substring] = [id] + UUID().uuidString.split(separator: "-")
		return array.joined()
	}
}
