//
//  ATStringConvertible.swift
//  AnimatedTransitions
//
//  Created by NaYfront on 19.10.2023.
//

import Foundation

public protocol ATStringConvertible {
  static func from(node: ExprNode) -> Self?
}

extension String {
  func parse<T: ATStringConvertible>() -> [T]? {
    let lexer = Lexer(input: self)
    let parser = Parser(tokens: lexer.tokenize())
    do {
      let nodes = try parser.parse()
      var results = [T]()
      for node in nodes {
        if let modifier = T.from(node: node) {
          results.append(modifier)
        } else {
          print("\(node.name) doesn't exist in \(T.self)")
        }
      }
      return results
    } catch let error {
      print("failed to parse \"\(self)\", error: \(error)")
    }
    return nil
  }

  func parseOne<T: ATStringConvertible>() -> T? {
    return parse()?.last
  }
}
