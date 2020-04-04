import Cocoa
import Foundation

/// Source: Gifski
/// v2.7.0
/// https://github.com/sindresorhus/Gifski
///
/// MIT License
///
/// © 2019 Sindre Sorhus <sindresorhus@gmail.com> (sindresorhus.com)
/// © 2019 Kornel Lesiński <kornel@pngquant.org> (gif.ski)
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy of this software
/// and associated documentation files (the "Software"), to deal in the Software without
/// restriction, including without limitation the rights to use, copy, modify, merge, publish,
/// distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
/// Software is furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in all copies or
/// substantial portions of the Software.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
/// BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
/// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
/// DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

final class ObjectAssociation<T: Any> {
	subscript(index: AnyObject) -> T? {
		get {
			objc_getAssociatedObject(index, Unmanaged.passUnretained(self).toOpaque()) as! T?
		} set {
			objc_setAssociatedObject(
				index,
				Unmanaged.passUnretained(self).toOpaque(),
				newValue,
				.OBJC_ASSOCIATION_RETAIN_NONATOMIC
			)
		}
	}
}

extension NSMenuItem {
	typealias ActionClosure = ((NSMenuItem) -> Void)

	private struct AssociatedKeys {
		static let onActionClosure = ObjectAssociation<ActionClosure>()
	}

	@objc
	private func callClosureGifski(_ sender: NSMenuItem) {
		onAction?(sender)
	}

	/// Closure version of `.action`
	///
	/// ```
	/// let menuItem = NSMenuItem(title: "Unicorn")
	/// menuItem.onAction = { sender in
	///     print("NSMenuItem action: \(sender)")
	/// }
	/// ```
	var onAction: ActionClosure? {
		get { AssociatedKeys.onActionClosure[self] }
		set {
			AssociatedKeys.onActionClosure[self] = newValue
			action = #selector(callClosureGifski)
			target = self
		}
	}
}
