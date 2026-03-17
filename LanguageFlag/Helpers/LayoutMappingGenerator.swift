// swiftlint:disable all
#if DEBUG
import Carbon

/// Run once to generate a complete Layout.json keyed by stable source IDs.
/// Call `LayoutMappingGenerator.printMapping()` from AppDelegate in DEBUG builds,
/// copy the console output to Layout.json, then remove the call.
enum LayoutMappingGenerator {

    // BCP 47 language tag (first 2 chars) → flag asset name
    private static let languageToFlag: [String: String] = [
        "af": "200-south-africa",
        "ak": "053-ghana",
        "am": "005-ethiopia",
        "ar": "133-saudi-arabia",
        "az": "141-azerbaijan",
        "be": "135-belarus",
        "bg": "168-bulgaria",
        "bn": "246-india",
        "bo": "142-tibet",
        "cs": "149-czech-republic",
        "cy": "014-wales",
        "da": "174-denmark",
        "de": "162-germany",
        "dv": "225-maldives",
        "dz": "040-bhutan",
        "el": "170-greece",
        "es": "128-spain",
        "et": "008-estonia",
        "fa": "136-iran",
        "fi": "125-finland",
        "fo": "122-faroe-islands",
        "fr": "195-france",
        "ga": "179-ireland",
        "gu": "246-india",
        "he": "155-israel",
        "hi": "246-india",
        "hr": "164-croatia",
        "hu": "115-hungary",
        "hy": "108-armenia",
        "ig": "086-nigeria",
        "is": "080-iceland",
        "it": "013-italy",
        "ja": "063-japan",
        "ka": "256-georgia",
        "kk": "074-kazakhstan",
        "km": "159-cambodia",
        "kn": "246-india",
        "ko": "094-south-korea",
        "ku": "020-iraq",
        "ky": "152-kyrgyzstan",
        "lo": "112-laos",
        "lt": "064-lithuania",
        "lv": "044-latvia",
        "mg": "242-madagascar",
        "mi": "121-new-zealand",
        "mk": "236-republic-of-macedonia",
        "ml": "246-india",
        "mn": "258-mongolia",
        "mr": "246-india",
        "ms": "118-malasya",
        "mt": "194-malta",
        "my": "058-myanmar",
        "ne": "016-nepal",
        "nl": "237-netherlands",
        "no": "143-norway",
        "or": "246-india",
        "pa": "246-india",
        "pl": "211-poland",
        "ps": "111-afghanistan",
        "pt": "255-brazil",
        "ro": "109-romania",
        "ru": "248-russia",
        "si": "127-sri-lanka",
        "sk": "091-slovakia",
        "sl": "010-slovenia",
        "sm": "251-samoa",
        "sq": "099-albania",
        "sr": "071-serbia",
        "sv": "184-sweden",
        "ta": "246-india",
        "te": "246-india",
        "tg": "196-tajikistan",
        "th": "238-thailand",
        "tk": "229-turkmenistan",
        "to": "191-tonga",
        "tr": "218-turkey",
        "uk": "145-ukraine",
        "ur": "100-pakistan",
        "uz": "190-uzbekistn",
        "vi": "220-vietnam",
        "wo": "227-senegal",
        "yi": "155-israel",
        "yo": "086-nigeria",
        "zh": "034-china",
    ]

    // Source IDs that need explicit overrides (language code alone is ambiguous)
    private static let idOverrides: [String: String] = [
        // English variants — language "en" defaults to US, override others
        "com.apple.keylayout.British":              "260-united-kingdom",
        "com.apple.keylayout.British-PC":           "260-united-kingdom",
        "com.apple.keylayout.Australian":           "234-australia",
        "com.apple.keylayout.Canadian":             "243-canada",
        "com.apple.keylayout.Canadian-CSA":         "243-canada",
        "com.apple.keylayout.Canadian-PC":          "243-canada",
        "com.apple.keylayout.Irish":                "179-ireland",
        "com.apple.keylayout.Irish-Extended":       "179-ireland",
        "com.apple.keylayout.NewZealand":           "121-new-zealand",
        "com.apple.keylayout.Hawaiian":             "262-hawaii",
        "com.apple.keylayout.Colemak":              "260-united-kingdom",
        "com.apple.keylayout.Dvorak":               "263-us",
        "com.apple.keylayout.Dvorak-Left":          "263-us",
        "com.apple.keylayout.Dvorak-Right":         "263-us",
        "com.apple.keylayout.DVORAK-QWERTYCMD":     "263-us",
        "com.apple.keylayout.ABC":                  "263-us",
        "com.apple.keylayout.ABC-AZERTY":           "195-france",
        "com.apple.keylayout.ABC-QWERTZ":           "162-germany",
        "com.apple.keylayout.ABC-Extended":         "263-us",
        "com.apple.keylayout.ABC-India":            "246-india",
        "com.apple.keylayout.Tongan":               "191-tonga",
        "com.apple.keylayout.Samoan":               "251-samoa",
        // Portuguese — default Brazil, Portugal is separate
        "com.apple.keylayout.Portuguese":           "224-portugal",
        // German variants
        "com.apple.keylayout.Austrian":             "003-austria",
        "com.apple.keylayout.SwissFrench":          "205-switzerland",
        "com.apple.keylayout.SwissGerman":          "205-switzerland",
        // Spanish
        "com.apple.keylayout.Spanish-ISO":          "128-spain",
        "com.apple.keylayout.LatinAmerican":        "252-mexico",
        // Norwegian Sámi / Finnish Sámi etc. → keep country flag
        "com.apple.keylayout.Sami-PC":              "143-norway",
        "com.apple.keylayout.InariSami":            "125-finland",
        "com.apple.keylayout.LuleSamiNorway":       "143-norway",
        "com.apple.keylayout.LuleSamiSweden":       "184-sweden",
        "com.apple.keylayout.NorthSami":            "143-norway",
        "com.apple.keylayout.PiteSami":             "184-sweden",
        "com.apple.keylayout.SkoltSami":            "125-finland",
        "com.apple.keylayout.SouthSami":            "143-norway",
        "com.apple.keylayout.UmeSami":              "184-sweden",
        "com.apple.keylayout.KildinSami":           "248-russia",
        "com.apple.keylayout.FinnishExtended":      "125-finland",
        "com.apple.keylayout.FinnishSami-PC":       "125-finland",
        "com.apple.keylayout.NorwegianExtended":    "143-norway",
        "com.apple.keylayout.NorwegianSami-PC":     "143-norway",
        "com.apple.keylayout.SwedishSami-PC":       "184-sweden",
        // Inuktitut — Canada
        "com.apple.keylayout.Inuktitut-Nattilik":   "243-canada",
        "com.apple.keylayout.Inuktitut-Nunavut":    "243-canada",
        "com.apple.keylayout.Inuktitut-Nutaaq":     "243-canada",
        "com.apple.keylayout.Inuktitut-QWERTY":     "243-canada",
        "com.apple.keylayout.Inuktitut-Nunavik":    "243-canada",
        // Tibetan — use Tibet flag
        "com.apple.keylayout.Tibetan-Otani":        "142-tibet",
        "com.apple.keylayout.Tibetan-QWERTY":       "142-tibet",
        "com.apple.keylayout.Tibetan-Wylie":        "142-tibet",
        // Korean input modes
        "com.apple.inputmethod.Korean.2SetKorean":          "094-south-korea",
        "com.apple.inputmethod.Korean.390Sebulshik":        "094-south-korea",
        "com.apple.inputmethod.Korean.3SetKorean":          "094-south-korea",
        "com.apple.inputmethod.Korean.GongjinCheongRomaja": "109-romania",
        "com.apple.inputmethod.Korean.HNCRomaja":           "094-south-korea",
        // Chinese
        "com.apple.inputmethod.SCIM.ITABC":         "034-china",
        "com.apple.inputmethod.SCIM.Shuangpin":     "034-china",
        "com.apple.inputmethod.SCIM.WBX":           "034-china",
        "com.apple.inputmethod.SCIM.WBH":           "034-china",
        "com.apple.inputmethod.TCIM.Cangjie":       "034-china",
        "com.apple.inputmethod.TCIM.Zhuyin":        "034-china",
        "com.apple.inputmethod.TCIM.ZhuyinEten":    "034-china",
        "com.apple.inputmethod.TCIM.Pinyin":        "034-china",
        "com.apple.inputmethod.TCIM.Shuangpin":     "034-china",
        "com.apple.inputmethod.TCIM.WBH":           "034-china",
        "com.apple.inputmethod.TCIM.Jianyi":        "034-china",
        "com.apple.inputmethod.TYIM.Stroke":        "034-china",
        "com.apple.inputmethod.TYIM.Sucheng":       "034-china",
        "com.apple.inputmethod.TYIM.Cangjie":       "034-china",
        "com.apple.inputmethod.TYIM.Phonetic":      "034-china",
        // Japanese
        "com.apple.inputmethod.Japanese":                       "063-japan",
        "com.apple.inputmethod.Japanese.Katakana":              "063-japan",
        "com.apple.inputmethod.Japanese.HalfWidthKana":         "063-japan",
        "com.apple.inputmethod.Japanese.FullWidthRoman":        "063-japan",
        "com.apple.inputmethod.Roman":                          "263-us",
        // Vietnamese
        "com.apple.inputmethod.VietnameseSimpleTelex":  "220-vietnam",
        "com.apple.inputmethod.VietnameseTelex":        "220-vietnam",
        "com.apple.inputmethod.VietnameseVIQR":         "220-vietnam",
        "com.apple.inputmethod.VietnameseVNI":          "220-vietnam",
    ]

    static func printMapping() {
        let sources = TISCreateInputSourceList(nil, true).takeRetainedValue() as? [TISInputSource] ?? []
        var mapping: [(key: String, value: String)] = []
        var unmapped: [String] = []

        for source in sources {
            let sourceID = source.id
            guard !sourceID.isEmpty else { continue }

            if let flag = idOverrides[sourceID] {
                mapping.append((sourceID, flag))
                continue
            }

            let lang = String((source.sourceLanguages.first ?? "").prefix(2))
            if let flag = languageToFlag[lang] {
                mapping.append((sourceID, flag))
            } else {
                unmapped.append("\(sourceID)  // \(source.name)  languages: \(source.sourceLanguages)")
            }
        }

        var output = "{\n"
        for (key, value) in mapping.sorted(by: { $0.key < $1.key }) {
            output += "    \"\(key)\": \"\(value)\",\n"
        }
        // Remove trailing comma from last entry
        if output.hasSuffix(",\n") {
            output = String(output.dropLast(2)) + "\n"
        }
        output += "}"
        print(output)

        if !unmapped.isEmpty {
            print("\n// ⚠️ UNMAPPED — add these manually:")
            unmapped.forEach { print("//   \($0)") }
        }
    }
}
#endif

// swiftlint:enable all
