import Foundation
import Photos

struct PhotoModel: Identifiable, Equatable {
    let id: String
    let asset: PHAsset
    
    var creationDate: Date? {
        asset.creationDate
    }
    
    var location: CLLocation? {
        asset.location
    }
    
    static func == (lhs: PhotoModel, rhs: PhotoModel) -> Bool {
        lhs.id == rhs.id
    }
}
