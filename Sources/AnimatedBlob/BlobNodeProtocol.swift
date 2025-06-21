import UIKit

@MainActor
public protocol BlobNodeProtocol: AnyObject {
    var pointsCount: Int { get set }
    var isCircle: Bool { get set }
    var color: UIColor? { get }
    var level: CGFloat { get set }
}
