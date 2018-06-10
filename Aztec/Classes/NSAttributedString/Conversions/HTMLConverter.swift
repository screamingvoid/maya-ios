import Foundation

/// This is the main converter class in Aztec.
/// It takes care of converting HTML text to NSAttributedString and vice-versa.
///
public class HTMLConverter {
    
    // MARK: - Plugins & Parsing
    
    let pluginManager: PluginManager
    
    // MARK: - Initializers
    
    public init() {
        pluginManager = PluginManager()
    }
    
    init(with pluginManager: PluginManager) {
        self.pluginManager = pluginManager
    }
    
    // MARK: - Converters: HTML -> AttributedString
    
    let htmlToTree = HTMLParser()
    
    private(set) lazy var treeToAttributedString: AttributedStringSerializer = {
        return AttributedStringSerializer(customizer: pluginManager)
    }()
    
    // MARK: - Converters: AttributedString -> HTML
    
    private(set) lazy var attributedStringToTree: AttributedStringParser = {
        return AttributedStringParser(customizer: pluginManager)
    }()
    
    private(set) lazy var treeToHTML: HTMLSerializer = {
        return HTMLSerializer(customizer: pluginManager)
    }()
    
    // MARK: - Conversion Logic
    
    func attributedString(from html: String, defaultAttributes: [NSAttributedStringKey: Any]? = [:]) -> NSAttributedString {
        let processedHTML = pluginManager.process(inputHTML: html)
        let rootNode = htmlToTree.parse(processedHTML)
        
        pluginManager.process(inputHTMLTree: rootNode)
        
        let defaultAttributes = defaultAttributes ?? [:]
        let attributedString = treeToAttributedString.serialize(rootNode, defaultAttributes: defaultAttributes)
        
        return attributedString
    }
    
    func html(from attributedString: NSAttributedString, prettify: Bool = false) -> String {
        let rootNode = attributedStringToTree.parse(attributedString)
        
        pluginManager.process(outputHTMLTree: rootNode)
        
        let html = treeToHTML.serialize(rootNode, prettify: prettify)
        
        return pluginManager.process(outputHTML: html)
    }
    
}
