import Foundation

func blueskyBlobURL(pds: String, did: String, cid: String) -> URL {
    let base = "https://\(pds)/xrpc/com.atproto.sync.getBlob"
    var comps = URLComponents(string: base)!
    comps.queryItems = [
        .init(name: "did", value: did),
        .init(name: "cid", value: cid)
    ]
    return comps.url!
} 