import Photos
@testable import PhotoSwipe

final class FakePHAsset: PHAsset {
    private let _localIdentifier: String

    init(identifier: String) {
        _localIdentifier = identifier
        super.init()
    }

    override var localIdentifier: String { _localIdentifier }
}

func makeTestPhoto(id: String = UUID().uuidString) -> PhotoModel {
    PhotoModel(id: id, asset: FakePHAsset(identifier: id))
}
