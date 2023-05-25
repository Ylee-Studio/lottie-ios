//
//  InstoriesLottieTests.swift
//  LottieTests
//
//  Created by Vlad Zhavoronkov on 25.05.2023.
//

import Foundation
import Lottie
import XCTest

// MARK: - ParsingTests

final class InstoriesLottieTests: XCTestCase {

  func testParsingIsTheSameForBothImplementations() throws {
    let url = Bundle.lottie.url(forResource: "Sticker2_1_merged", withExtension: "json", subdirectory: Samples.directoryName)!
    do {
      let data = try Data(contentsOf: url)
      let codableAnimation = try LottieAnimation.from(data: data, strategy: .legacyCodable)
      let dictAnimation = try LottieAnimation.from(data: data, strategy: .dictionaryBased)
      XCTAssertNoDiff(codableAnimation, dictAnimation)
    } catch {
      XCTFail(error.localizedDescription)
    }
//    for url in Samples.sampleAnimationURLs {
//      guard url.pathExtension == "json" else { continue }
//
//      do {
//        let data = try Data(contentsOf: url)
//        let codableAnimation = try LottieAnimation.from(data: data, strategy: .legacyCodable)
//        let dictAnimation = try LottieAnimation.from(data: data, strategy: .dictionaryBased)
//
//        XCTAssertNoDiff(codableAnimation, dictAnimation)
//      } catch {
//        XCTFail("Error for \(url.lastPathComponent): \(error)")
//      }
//    }
  }
}

// Sticker2_1_merged.json
