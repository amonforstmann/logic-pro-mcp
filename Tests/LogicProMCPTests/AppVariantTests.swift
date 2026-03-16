import XCTest
@testable import LogicProMCP

final class AppVariantTests: XCTestCase {

    // MARK: - AppVariant enum properties

    func testLogicProBundleID() {
        let variant = AppVariant.logicPro
        XCTAssertEqual(variant.bundleID, "com.apple.logic10")
    }

    func testCreatorStudioBundleID() {
        let variant = AppVariant.creatorStudio
        XCTAssertEqual(variant.bundleID, "com.apple.mobilelogic")
    }

    func testLogicProAppName() {
        let variant = AppVariant.logicPro
        XCTAssertEqual(variant.appName, "Logic Pro")
    }

    func testCreatorStudioAppName() {
        let variant = AppVariant.creatorStudio
        XCTAssertEqual(variant.appName, "Logic Pro Creator Studio")
    }

    func testAllBundleIDsContainsBothVariants() {
        let ids = AppVariant.allBundleIDs
        XCTAssertTrue(ids.contains("com.apple.logic10"))
        XCTAssertTrue(ids.contains("com.apple.mobilelogic"))
        XCTAssertEqual(ids.count, 2)
    }

    func testFromBundleIDLogicPro() {
        let variant = AppVariant(bundleID: "com.apple.logic10")
        XCTAssertEqual(variant, .logicPro)
    }

    func testFromBundleIDCreatorStudio() {
        let variant = AppVariant(bundleID: "com.apple.mobilelogic")
        XCTAssertEqual(variant, .creatorStudio)
    }

    func testFromBundleIDUnknownReturnsNil() {
        let variant = AppVariant(bundleID: "com.example.unknown")
        XCTAssertNil(variant)
    }

    // MARK: - Default variant

    func testDefaultVariantIsLogicPro() {
        // When no app is running, the default should be Logic Pro
        XCTAssertEqual(AppVariant.defaultVariant, .logicPro)
    }
}
