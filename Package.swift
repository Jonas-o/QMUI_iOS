// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "QMUIKit",
    platforms: [
        .iOS(.v12)
    ],
    products: [
        .library(
            name: "QMUIKit",
            targets: ["QMUIKit"]
        )
    ],
    targets: [
        .target(
            name: "QMUIKit",
            path: "QMUIKit",
            exclude: ["Info.plist"],
            sources: [
                "QMUICore",
                "QMUIMainFrame",
                "QMUIComponents",
                "UIKitExtensions"
            ],
            resources: [
                .copy("PrivacyInfo.xcprivacy"),
                .process("QMUIResources")
            ],
            cSettings: [
                .headerSearchPath("include/QMUIKit"),
                .headerSearchPath("QMUICore"),
                .headerSearchPath("QMUIMainFrame"),
                .headerSearchPath("QMUIComponents"),
                .headerSearchPath("QMUIComponents/AssetLibrary"),
                .headerSearchPath("QMUIComponents/ImagePickerLibrary"),
                .headerSearchPath("QMUIComponents/NavigationBarTransition"),
                .headerSearchPath("QMUIComponents/QMUIAnimation"),
                .headerSearchPath("QMUIComponents/QMUIBadge"),
                .headerSearchPath("QMUIComponents/QMUIButton"),
                .headerSearchPath("QMUIComponents/QMUICellHeightKeyCache"),
                .headerSearchPath("QMUIComponents/QMUICellSizeKeyCache"),
                .headerSearchPath("QMUIComponents/QMUIConsole"),
                .headerSearchPath("QMUIComponents/QMUIImagePreviewView"),
                .headerSearchPath("QMUIComponents/QMUILayouter"),
                .headerSearchPath("QMUIComponents/QMUILog"),
                .headerSearchPath("QMUIComponents/QMUIMultipleDelegates"),
                .headerSearchPath("QMUIComponents/QMUIPopupMenuView"),
                .headerSearchPath("QMUIComponents/QMUIScrollAnimator"),
                .headerSearchPath("QMUIComponents/QMUISheetPresentation"),
                .headerSearchPath("QMUIComponents/QMUITheme"),
                .headerSearchPath("QMUIComponents/StaticTableView"),
                .headerSearchPath("QMUIComponents/ToastView"),
                .headerSearchPath("UIKitExtensions"),
                .headerSearchPath("UIKitExtensions/QMUIBarProtocol")
            ]
        )
    ]
)