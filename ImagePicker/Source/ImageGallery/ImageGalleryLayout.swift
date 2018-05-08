import UIKit

class ImageGalleryLayout: UICollectionViewFlowLayout {

  override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
    guard let attributes = super.layoutAttributesForElements(in: rect) else {
      return super.layoutAttributesForElements(in: rect)
    }

    var newAttributes = [UICollectionViewLayoutAttributes]()
    for attribute in attributes {
      let abc = attribute.copy() as! UICollectionViewLayoutAttributes
      abc.transform = Helper.rotationTransform()
      newAttributes.append(abc)
    }

    return newAttributes
  }
}
