import Cocoa
import os.log
import Quartz

/// Max size of files to render: 100000 B = 100 KB
let MAX_FILE_SIZE = 100_000

class PreviewViewController: NSViewController, QLPreviewingController {
	var webView: PreviewWebView!

	override func loadView() {
		// Do not call `super.loadView()` (related to storybooks)

		// Create NSView (overrides inherited storybook logic)
		view = NSView(frame: NSRect(x: 0, y: 0, width: 200, height: 100))
	}

	// swiftlint:disable:next overridden_super_call
	override func viewDidLoad() {
		// Do not call `super.viewDidLoad()` (related to storybooks)

		// Create web view for rendering file preview (subview of NSView)
		webView = PreviewWebView(frame: view.bounds)
		webView.autoresizingMask = [.height, .width]
		view.addSubview(webView)
	}

	/// Handles file previews. Called e.g. for previews in the Finder, when pressing space on a file
	/// or in Spotlight
	func preparePreviewOfFile(
		at fileUrl: URL,
		completionHandler handler: @escaping (Error?) -> Void
	) {
		os_log("Generating Quick Look preview for file %s", type: .debug, fileUrl.path)
		previewFile(fileUrl: fileUrl, completionHandler: handler)
	}

	/// Loads a HTML preview of the selected file in the `webView`
	private func previewFile(fileUrl: URL, completionHandler handler: @escaping (Error?) -> Void) {
		// TODO: Display errors to user

		do {
			// Retrieve information about previewed file
			let fileInfo = try FileInfo(url: fileUrl)
			let fileExtension = fileInfo.url.pathExtension

			// Exit if file is too large to preview
			if fileInfo.getSize() > MAX_FILE_SIZE {
				os_log("Not loading file preview for %s: File too large", type: .info, fileUrl.path)
				handler(nil)
				return
			}

			// Convert file content to HTML
			let renderer = RendererFactory.getRenderer(
				fileContent: try fileInfo.getContent(),
				fileExtension: fileExtension
			)

			// Render file preview in web view
			webView.renderPage(
				contentHtml: try renderer.getHtml(),
				css: renderer.getCss(),
				js: renderer.getJs()
			)
		} catch {
			os_log("Error loading file preview: %s", type: .error, error.localizedDescription)
		}

		// Stop displaying Quick Look loading spinner
		handler(nil)
	}
}
