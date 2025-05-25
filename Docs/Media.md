Media Support in Vox (BlueSky AT Protocol & SwiftUI 2025)
This guide shows how to upload, fetch, and display images and videos in Vox, a SwiftUI-based iOS client for BlueSky (AT Protocol), including special “mutuals-only” posts. We cover using the official blob APIs, handling caching and limits, building SwiftUI media views, and ensuring a performant, minimal UI. Code samples use TypeScript (AT Protocol SDK) or Swift paradigms. For official details see BlueSky docs
docs.bsky.app
bsky.social
 and AT Protocol specs
atproto.com
docs.bsky.app
.
1. Uploading Images & Videos to BlueSky
Authentication: First create an AT Protocol session (com.atproto.server.createSession) with the user’s handle and app-password to get an access JWT. Use this token in Authorization: Bearer <token> headers for upload calls.
Image upload: Resize/strip metadata (e.g. EXIF) to meet the 1 MB limit. Then POST the raw image bytes to com.atproto.repo.uploadBlob on the user’s PDS (e.g. https://bsky.social/xrpc/com.atproto.repo.uploadBlob) with Content-Type: image/jpeg (or PNG) and the access JWT
docs.bsky.app
. The response JSON gives a blob ref (CID, MIME, size), e.g.:
python
Copy
Edit
resp = requests.post(
    "https://bsky.social/xrpc/com.atproto.repo.uploadBlob",
    headers={
        "Content-Type": "image/png",
        "Authorization": f"Bearer {token}"
    },
    data=img_bytes,
)
blob = resp.json()["blob"]  # {"$type":"blob", "ref":{"$link":"bafkrei..."}, ...}
This blob can then be embedded in a post. Each image must have an alt text (even an empty string)
docs.bsky.app
. For example:
python
Copy
Edit
post_record = {
  "$type": "app.bsky.feed.post",
  "text": "My photo post",
  "createdAt": datetime.utcnow().isoformat() + "Z",
  "embed": {
    "$type": "app.bsky.embed.images",
    "images": [
      {"alt": "A sunset view", "image": blob}
    ]
  }
}
BlueSky limits up to 4 images per post and each ≤1 000 000 bytes
docs.bsky.app
. You must also supply each image’s aspect ratio; otherwise official clients may not render it correctly
kesdev.com
. Strip metadata beforehand (a recommended best practice
docs.bsky.app
) to reduce size.
Video upload: Videos (≤60 sec, formats .mp4/.mov/.webm/.mpeg) are handled differently
bsky.social
. First call com.atproto.server.getServiceAuth with {aud: did, lxr: "com.atproto.repo.uploadBlob", exp: ...} to get a temporary upload token. Then build a URL:
php-template
Copy
Edit
POST https://video.bsky.app/xrpc/app.bsky.video.uploadVideo?did=<userDid>&name=<filename>
Include headers Authorization: Bearer <serviceToken>, Content-Type: video/mp4, and the raw video bytes in the body. For example, in TypeScript:
ts
Copy
Edit
const uploadUrl = new URL("https://video.bsky.app/xrpc/app.bsky.video.uploadVideo");
uploadUrl.searchParams.append("did", agent.session!.did);
uploadUrl.searchParams.append("name", videoPath.split("/").pop()!);
const uploadResponse = await fetch(uploadUrl, {
  method: "POST",
  headers: {
    Authorization: `Bearer ${token}`,
    "Content-Type": "video/mp4",
    "Content-Length": String(size)
  },
  body: videoStream,
});
const jobStatus = await uploadResponse.json();
The response gives a jobId. Poll app.bsky.video.getJobStatus with that ID until processing finishes and a final blob is returned. Finally, post it similarly with app.bsky.embed.video. For example:
ts
Copy
Edit
await agent.app.bsky.feed.post({
  text: "Check out this video!",
  embed: {
    $type: "app.bsky.embed.video",
    video: jobStatus.blob,  // blob from getJobStatus
    aspectRatio: { width: 1920, height: 1080 }
  }
});
This attaches the video to a feed post. BlueSky currently allows one video per post and up to 25 uploads (10 GB) per day
bsky.social
bsky.social
.
2. Fetching & Displaying Media in SwiftUI
Once a user’s feed/thread data is fetched via AT Protocol (e.g. com.atproto.sync.getRecord or PDS feed APIs), each post’s JSON will contain blob references for images or videos in the embed field. To display these:
Extract blob IDs: For each image embed, get the CID from post.embed.images[i].image.ref.$link. For a video, similarly use post.embed.video.video.ref.$link.
Download blob: Call the PDS sync endpoint to fetch the raw media:
php-template
Copy
Edit
GET /xrpc/com.atproto.sync.getBlob?did=<ownerDid>&cid=<blobCid>
No auth is needed. The PDS returns the binary with the correct Content-Type. For example, in Swift:
swift
Copy
Edit
let blobUrl = URL(string: "https://bsky.social/xrpc/com.atproto.sync.getBlob?did=\(ownerDid)&cid=\(blobCid)")!
let (data, _) = try await URLSession.shared.data(from: blobUrl)
let uiImage = UIImage(data: data)
The AT Protocol spec confirms that getBlob returns the original content with proper headers
atproto.com
.
SwiftUI display: Use SwiftUI’s views to show the media. For images:
swift
Copy
Edit
AsyncImage(url: blobUrl) { phase in
  switch phase {
  case .success(let image):
    image.resizable().scaledToFill()
  case .empty:
    ProgressView()
  case .failure:
    Image(systemName: "photo").padding()  // error placeholder
  }
}
.frame(maxWidth: .infinity)  // adjust layout
.clipped()
Here AsyncImage (iOS 15+) automatically uses URLSession and a shared URLCache
avanderlee.com
. You can configure URLCache.shared capacity if needed. For videos, use VideoPlayer (AVKit):
swift
Copy
Edit
VideoPlayer(player: AVPlayer(url: blobUrl))
  .frame(height: 250)
This provides native playback controls. Attach .accessibilityLabel(altText) to the image or video view using the post’s alt text. The example app UI might look like the Bluesky screenshot below:


Figure: Example feed UI with a video post (play icon) and composer. Tapping an image/video should expand it to full-screen or start playback.
Profile & Thread Views: The same blob-URL approach works in profile or thread screens. For a user’s profile grid (e.g. gallery of posts), fetch each post’s images as above and display them in a SwiftUI LazyVGrid or horizontal carousel. In a thread view (reply to a post), show the parent’s media similarly at the top.
3. Mutuals-Only (“Circle”) Posts
BlueSky currently treats all posts as public
bsky.social
. To emulate a “mutuals-only” or circle feature in Vox, you must layer on a private backend:
Private storage: Store the media (image/video files) on your own secure server (e.g. CloudKit or custom API) rather than uploading to the public PDS. Only users in the poster’s circle have permission to fetch these.
Encryption: Encrypt each media file with a symmetric key (DEK). Then encrypt that DEK individually for each authorized mutual’s public key
github.com
. Store the encrypted file on the backend and include only a reference or ID in the AT Protocol record (e.g. in a special metadata field).
Signed reference: In the BlueSky post (still using app.bsky.feed.post), include a custom embed or extra data that contains the private-media ID. Sign the record with the user’s DID key (AT Protocol handles this). For example:
json
Copy
Edit
{
  "$type": "app.bsky.feed.post",
  "text": "Friends-only photo",
  "createdAt": "...",
  "embed": {
    "$type": "app.bsky.embed.images",
    "images": [
      {
        "alt": "Secret meetup pic",
        "image": { "$type": "blob", "ref": {"$link": "PLACEHOLDER"} }
      }
    ]
  },
  "attachments": {
    "privateImageId": "12345"
  }
}
Client fetching: When a mutual (follower-friend) views this post in Vox, the app sees the privateImageId and authenticates to the private server (e.g. using the user’s credentials). The server checks if the viewer is allowed (e.g. their DID is in the poster’s circle). If allowed, it returns the encrypted blob, which the app decrypts using the shared DEK. This way the media is visible only to authorized users, even though the post record is public.
Implementing this requires careful key management. BlueSky’s AT Protocol provides DID-based identity and signing, but end-to-end encryption is still a work in progress
github.com
. The approach above follows one proposed scheme: encrypt media with a random key, then share that key only with authorized DIDs
github.com
. (Effectively, we layer privacy on top of AT Protocol using our own crypto.)
4. Caching, Limits, Alt Text & Accessibility
Caching: Network media (images/videos) should be cached to improve performance. SwiftUI’s AsyncImage already uses URLCache by default
avanderlee.com
. Configure it for your app: e.g.
swift
Copy
Edit
URLCache.shared.memoryCapacity = 50_000_000
URLCache.shared.diskCapacity = 500_000_000
For finer control or transformations, consider a caching library (e.g. Kingfisher, Nuke). Cache video data or thumbnails if repeatedly accessed. Also implement in-memory caches if showing the same image multiple times (e.g. profile grid and detail view).
Media size limits: Enforce the protocol’s limits on the client side. For images: check file size ≤1 MB before upload
docs.bsky.app
. For videos: check duration ≤60s and file format
bsky.social
. Notify the user if exceeded. You may also downscale images/videos or compress them to meet limits (e.g. reduce resolution, bitrate, or metadata).
Alt text: Provide descriptive alt text for every image. The protocol requires an alt string for each image
docs.bsky.app
. In your UI, ensure the alt text is set on the image view for accessibility, e.g.:
swift
Copy
Edit
Image(uiImage: uiImage)
  .resizable()
  .scaledToFit()
  .accessibilityLabel(Text(altText))
This allows VoiceOver to read the description. If no description is available, pass an empty string to satisfy the API, but encourage users to add text to make content accessible.
Accessibility: In addition to alt text, follow Apple’s HIG. Make sure tappable media elements have sufficient hit targets. Support Dynamic Type and contrast. For videos, provide subtitles/captions if possible (the uploader can attach subtitle files; if so, display a CC toggle). For images, consider using accessibilityAddTraits(.isImage) where appropriate. Also, if a media load fails, voice a fallback description.
Blob management: Unreferenced blobs may be garbage-collected on the server
docs.bsky.app
atproto.com
, so don’t rely on fetching old, unused blobs. Locally, clean up any caches you use for media when posts are deleted. Consider pruning large caches on disk if not accessed recently.
5. SwiftUI Media Display Components
Use modern SwiftUI views to present media attractively:
Image carousel: For multi-photo posts, use a TabView with .page style. Example:
swift
Copy
Edit
TabView(selection: $currentIndex) {
  ForEach(post.images, id: \.cid) { img in
    AsyncImage(url: img.url) { phase in
      if let img = phase.image {
        img.resizable().scaledToFill()
      } else if phase.error != nil {
        Image(systemName: "photo").resizable().scaledToFit()
      } else {
        ProgressView()
      }
    }
    .tag(img.cid)
  }
}
.tabViewStyle(.page(indexDisplayMode: .automatic))
.frame(height: 300)
This allows swiping through images. You can overlay page indicators or custom controls as needed.
Full-screen modals: Tapping an image or video should present a full-screen viewer. Use .fullScreenCover (or .sheet) for this. For example:
swift
Copy
Edit
.fullScreenCover(isPresented: $showingFullScreen) {
  ZStack {
    Color.black.ignoresSafeArea()
    AsyncImage(url: selectedImageURL) { image in
      image.resizable().scaledToFit()
    }
    .onTapGesture { showingFullScreen = false }
  }
}
This opens the image in a dark background. You can add pinch-to-zoom or swipe-to-dismiss gestures for a polished feel.
Video player: Use SwiftUI’s VideoPlayer (iOS 14+) with an AVPlayer. For example:
swift
Copy
Edit
VideoPlayer(player: AVPlayer(url: videoURL))
  .frame(height: 250)
  .onAppear { player.play() }  // auto-play if desired
This gives native controls (play/pause, scrub). You can customize the overlay by layering SwiftUI views on top. Ensure videos pause when leaving the view to save resources.
Responsive layouts: Use GeometryReader or .aspectRatio to maintain proper sizing. For example, ensure video covers width with correct aspect:
swift
Copy
Edit
VideoPlayer(player: AVPlayer(url: videoURL))
  .aspectRatio(CGFloat(width)/CGFloat(height), contentMode: .fit)
Design consistency: Match Apple’s UI standards (e.g. rounded corners, shadows). The Bluesky app uses a clean feed with large media previews. Consider the iOS 17 (2024) design language: minimal chrome, emphasis on content. Example styles:
swift
Copy
Edit
AsyncImage(...) 
  .cornerRadius(12)
  .shadow(radius: 4)
Performance in views: Prefer LazyVStack/LazyHStack for scrollable lists of posts
fatbobman.com
. This avoids preloading off-screen media. Wrap media fetching in asynchronous tasks (.task or onAppear) so the UI thread stays smooth.
6. UX: Minimalism, Performance & Responsiveness
Minimal UI: Keep controls hidden unless needed. For example, overlay a translucent play button on videos only on hover/tap
bsky.social
. Use gesture controls (swipe to dismiss) instead of extra buttons. Follow Apple’s Human Interface Guidelines: strong focus on content, consistent iconography, spacing and typography.
Lazy loading: Do not preload all images/videos at once. Fetch media only when a post scrolls into view. SwiftUI’s List or LazyVStack loads views on demand. Combine this with Swift concurrency: e.g.
swift
Copy
Edit
Task {
  self.image = try await downloadImageBlob(blobCid)
}
This avoids blocking the UI.
Concurrency & Throttling: Use async/await or Combine to handle network calls. Limit simultaneous downloads (e.g. max 3 at a time). Consider using Actor or TaskQueue patterns if many media loads.
Adaptive layout: Support all device sizes and orientations. Use adaptive stacks (HStack for landscape, VStack for portrait via GeometryReader). Support Dynamic Type (e.g. use .font(.body)). In landscape or iPad, present a sidebar or grid view of posts.
Progress indicators: Show a ProgressView or placeholder for loading media. For large videos, display a thumbnail frame or spinner until ready.
Memory use: Large images and videos consume memory. Release caches when low-memory warning arrives (onReceive(NotificationCenter.default.publisher(for: UIApplication.didReceiveMemoryWarningNotification))). Use scaled-down images when possible (UIImage(data: data, scale: 2.0)).
Examples: Third-party SwiftUI patterns like “peek and pop” (Preview) or transition animations can add polish. For instance, use .animation(.easeInOut, value: showingFullScreen) for smooth fades. But avoid heavy animations that tax GPU.
fatbobman.com
avanderlee.com
 Fatbobman’s SwiftUI tips and Apple’s examples reinforce lazy containers and AsyncImage caching for smooth, lightweight feeds.
7. Error Handling & Fallback Strategies
Even with best efforts, media may fail to load or be unavailable. Handle these gracefully:
Blob not found: If getBlob returns 404 (e.g. deleted post or circle content), show a placeholder and a note like “Image unavailable” or a lock icon if it’s private. Do not crash. For AsyncImage, use the .failure case (or check phase.error) to replace the image.
Video errors: If video fails, stop any loaders and show a button to retry or a thumbnail. Catch errors from AVPlayer (observe its status) and display an alert or overlay icon if “Playback failed.”
Network issues: If offline or timed out, indicate network error. Cache any already-viewed media so some content remains. Consider retry policies or “pull to refresh” to try again.
Fallback UI: Provide defaults. E.g., use Image(systemName: "photo") for missing images and Image(systemName: "film") for missing video. Use Text("Unable to load media") with .foregroundColor(.secondary) for elegance.
Alt text missing: If somehow alt is empty, still call .accessibilityHidden(true) on the image so VoiceOver skips it (since it’s purely decorative then).
Logging: Log upload/download errors for analytics. E.g. send error to your crash reporting or show a toast “Upload failed, try again.”
Testing: Simulate failures (no internet, malformed blob) to verify fallbacks work.
By following these steps, Vox will robustly handle media. Users get seamless image carousels, inline videos, and clear alt text/feedback, all in a responsive SwiftUI interface that feels native. Sources: Official BlueSky/AT Protocol docs and examples
docs.bsky.app
bsky.social
atproto.com
avanderlee.com
; BlueSky blog posts
bsky.social
bsky.social
; and SwiftUI best-practice articles
fatbobman.com
.