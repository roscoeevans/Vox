Building a SwiftUI Bluesky Social App with the AT Protocol – Step-by-Step Guide
1. Overview of Bluesky and the AT Protocol
Bluesky is a decentralized social network built on the Authenticated Transfer Protocol (AT Protocol). The AT Protocol is an open standard for social apps that defines how users, posts, follows, and other social data are managed and transferred in a federated network
docs.bsky.app
. In this system, users have portable identity: they are identified by globally unique handles (often domain names) that map to DIDs (decentralized identifiers)
docs.bsky.app
. User data lives in personal data repositories (PDS) that contain records (posts, likes, follows, etc.), cryptographically signed by the user’s keys, enabling account portability between servers
docs.bsky.app
. The network is federated, meaning multiple servers (PDS instances) sync user repositories and interoperate, rather than a single centralized server
docs.bsky.app
. A key concept in AT Protocol is Lexicon, the global schema definition system for data and APIs. Lexicons define the structure of all records and method calls in the network
docs.bsky.app
docs.bsky.app
. Bluesky’s social features (posts, profiles, etc.) are defined in the app.bsky.* lexicon namespace
docs.bsky.app
. This ensures different apps can understand each other’s data. For example, the Bluesky app’s microblogging schema includes a post type (app.bsky.feed.post), profile type, follow type, etc. In practice, this means a Bluesky post is just a record conforming to the app.bsky.feed.post lexicon, stored in a user’s data repository
docs.bsky.app
. As developers, you don’t usually need to define new lexicons for basic social features – you use the existing Bluesky ones. Understanding that posts, likes, follows, and other objects are all structured records defined by lexicons will help in working with the API. In summary, Bluesky + AT Protocol provide an open, federated social networking backend with formal schemas. Your SwiftUI app will act as a client to a user’s chosen Bluesky server (e.g. bsky.social), interacting with it via HTTP XRPC calls defined by the AT Protocol. Next, we’ll set up authentication to start making those calls.
2. User Authentication via the AT Protocol
To call Bluesky’s AT Protocol APIs, the client must authenticate the user and obtain a session token. Bluesky currently supports a client-server authentication model where the app logs in with the user’s credentials to get a JWT token for API calls
docs.bsky.app
. There is no OAuth flow (as of early 2025) for third-party apps, so the common approach is to have users enter their Bluesky handle (e.g. alice.bsky.social or a custom domain handle) and an app-specific password. App Passwords: For security, Bluesky supports app-specific passwords. Users can generate an “App Password” in their account settings on the official app, which is used instead of their main password for third-party clients
christophertkenny.com
github.com
. Your app should instruct users to create an app password and use that for login. The authentication flow in code is the same whether it’s their main password or an app password – but using an app password is highly recommended
github.com
. Authenticating: The AT Protocol login is performed by calling the com.atproto.server.createSession XRPC endpoint with the user’s identifier (their handle or DID) and password. In practice, if using a high-level library, you might have a method like login() or authenticate() that wraps this call. For example, using the community Swift library ATProtoKit, you can do:
swift
Copy
Edit
let config = ATProtocolConfiguration()
try await config.authenticate(handle: "alice.bsky.social", password: "APP_PASSWORD")
let atProtoKit = await ATProtoKit(sessionConfiguration: config)
This will contact the server (e.g. https://bsky.social/xrpc/com.atproto.server.createSession) and log in the user
docs.bsky.app
. On success, the server returns a session object containing an accessJwt and refreshJwt
docs.bsky.app
. The access JWT is a short-lived token your app will use in the Authorization header for subsequent API requests (“Authorization: Bearer <token>”). The refresh JWT is used to refresh the session when the access token expires
docs.bsky.app
. The library will store these tokens in ATProtocolConfiguration (or similar), and automatically include the Authorization header on future calls. If you are not using a library, you would manually make an HTTP POST request to the session endpoint, for example:
swift
Copy
Edit
var request = URLRequest(url: URL(string: "https://bsky.social/xrpc/com.atproto.server.createSession")!)
request.httpMethod = "POST"
request.addValue("application/json", forHTTPHeaderField: "Content-Type")
let credentials = ["identifier": "alice.bsky.social", "password": "APP_PASSWORD"]
request.httpBody = try JSONSerialization.data(withJSONObject: credentials)
After sending this request (e.g. via URLSession), parse the JSON response to extract accessJwt. Store the access token securely (e.g. in the iOS Keychain) for authorized calls. With a valid session token, you can now fetch data and post on behalf of the user.
3. Fetching Timeline Feeds (Home Timeline)
Once authenticated, the first major feature is to load the user’s Twitter-style home timeline – i.e. the feed of posts from accounts they follow. In Bluesky terms, this is the “timeline” feed. The AT Protocol defines an endpoint for this: app.bsky.feed.getTimeline, which returns the latest posts from followed users
docs.bsky.app
. Feeds in Bluesky are generally paginated with cursors, meaning you can fetch a page of posts and get a cursor value to retrieve the next page
docs.bsky.app
docs.bsky.app
. Using a Swift SDK or the XRPC call directly, you will query the timeline after login. For example, with a library that models the Bluesky API (such as ATProtoKit or others), you might call a method like:
swift
Copy
Edit
let timeline = try await atProtoKit.send(endpoint: "app.bsky.feed.getTimeline", parameters: ["limit": 50])
// or if the library provides a helper:
let feedResponse = try await atProtoBluesky.getTimeline(limit: 50)
This should send a GET request to https://bsky.social/xrpc/app.bsky.feed.getTimeline with an Authorization header. The response will include an array of feed posts and possibly a cursor if there are more posts
docs.bsky.app
. Each post item typically contains the post text, the author’s profile info, timestamps, and identifiers like the post’s URI and CID (more on these below). Response Data: The timeline data structure in Bluesky is usually an object with a feed array of posts and a cursor string for pagination
docs.bsky.app
. Each post in the feed (often called a FeedViewPost) includes the post record (text, createdAt, etc.), the author’s profile (display name, avatar, etc.), and any embedded media or reply/quote references. When you parse this in Swift, you can map it to your own model objects or use the ones provided by the SDK. For example, if using ATProtoKit or SwiftGraph (another library), the posts might be decoded into Swift structs for you. After fetching, you would update your SwiftUI view (e.g. a list) to display the posts. The important part on the protocol side is that to get older posts, you use the cursor returned: call getTimeline again with cursor as a parameter to get the next page
docs.bsky.app
. Continue until no cursor is returned or you have enough content. Author feeds: If you need to display a specific user’s posts (for example, on a profile screen showing “tweets” of that user), Bluesky provides an app.bsky.feed.getAuthorFeed endpoint. This works similarly but requires an actor parameter (the DID or handle of the user) whose posts you want
docs.bsky.app
. The response is a feed of that user’s posts in chronological order. Many SDKs will have a method like getAuthorFeed(actor:did) you can call. This is useful for profile timelines. At this stage, your app can load and display posts. Next, we will enable posting new content to Bluesky from the app.
4. Posting New Content (Creating Posts)
Creating a new post (analogous to tweeting) in Bluesky is done by writing a record to the user’s repository, of the type app.bsky.feed.post. The AT Protocol provides a generic endpoint com.atproto.repo.createRecord for adding any record to a repository. In practice, the Bluesky SDKs wrap this with a convenience method, often simply called post() or createPost. For example, the official TypeScript SDK allows agent.post({ text: "Hello world", createdAt: ... }) which under the hood calls com.atproto.repo.createRecord with the appropriate schema
docs.bsky.app
. In Swift, using a library like ATProtoKit, you might have a method createPostRecord(text:). From the ATProtoKit example:
swift
Copy
Edit
let atProtoBluesky = ATProtoBluesky(atProtoKitInstance: atProtoKit)
let postResult = try await atProtoBluesky.createPostRecord(text: "Hello Bluesky!")
print(postResult.uri)  // at://did:plc:.../app.bsky.feed.post/...
This call constructs a JSON payload containing your post’s text and timestamp, then POSTs it to the server. The server returns the URI of the new post and its CID
docs.bsky.app
. The URI (at:// DID/path) uniquely identifies the post in the network, and the CID is a content hash for the record (used for verification and deduplication)
docs.bsky.app
. For example, a returned URI might look like: at://did:plc:abcd1234/app.bsky.feed.post/3ghijk5
docs.bsky.app
. Your app can store or use this URI to refer to the post (e.g. for liking or replying later). Under the hood, if you were to call the API directly, it would look like this (simplified):
http
Copy
Edit
POST https://bsky.social/xrpc/com.atproto.repo.createRecord
Authorization: Bearer ACCESS_JWT
Content-Type: application/json

{
  "repo": "alice.bsky.social",            // the user’s handle (or DID)
  "collection": "app.bsky.feed.post",     // lexicon record type for posts
  "record": {
    "text": "Hello world!",
    "createdAt": "2025-05-23T20:15:00Z"
  }
}
In this JSON:
repo is the user’s account (their DID or handle) identifying which repo to write to.
collection is the record type’s lexicon ID (here the posts collection).
record is the data for the post, matching the schema for app.bsky.feed.post (at minimum it has text and createdAt; it can also include fields like reply or embed for images, etc as defined in the lexicon).
The response will contain the new record’s uri and cid
docs.bsky.app
. After posting, the new post should immediately appear in the user’s own timeline feed (and their followers’ feeds, via their servers). In your SwiftUI app, after successfully posting, you might optimistically update the UI by prepending the new post to the timeline list. Note on Rich Text: The Bluesky post schema supports facets for rich text (mentions, links) but to keep this guide focused on protocol usage, we won’t delve into constructing rich text facets. Basic plaintext posts just use the text field. Attachments like images involve uploading a blob via com.atproto.repo.uploadBlob and then referencing it in the post record – an advanced topic beyond this guide’s scope.
5. Managing User Profiles
Every user has a profile record (app.bsky.actor.profile) containing their display name, bio, avatar, etc. Your client will likely need to fetch profiles – both the logged-in user’s profile (to show their info or edit it) and other users’ profiles (to show when viewing posts or searching users). Fetching a profile: Use the app.bsky.actor.getProfile endpoint to retrieve a user’s profile by DID or handle. For example, if you have a handle alice.bsky.social, you can call:
swift
Copy
Edit
let profile = try await atProtoBluesky.getProfile(actor: "alice.bsky.social")
// or actor: "did:plc:123...xyz"
This returns the profile information including the user’s DID, handle, displayName, description (bio), avatar URL (if set), number of followers/following, etc
docs.bsky.app
docs.bsky.app
. The actor parameter accepts either the handle or the DID of the user, and returns the same data. If using a lower-level approach, you’d make a GET request to https://bsky.social/xrpc/app.bsky.actor.getProfile?actor=<handle>. For displaying posts in your app’s timeline, note that the feed fetch already provides each post’s author profile (e.g., FeedViewPost.author may include displayName, avatar, etc.), so you often don’t need to separately call getProfile for every post author. But you will use getProfile when, for instance, the user taps on someone’s name to view their profile screen. Editing a profile: To allow the user to update their profile (changing display name, bio, or avatar), Bluesky uses an upsert operation. The client needs to fetch the current profile, modify fields, and send it back via com.atproto.repo.putRecord or a convenience method. The official approach is to use upsertProfile logic: get the existing profile record, apply changes, and update. For example (pseudo-code using a library):
swift
Copy
Edit
try await atProtoBluesky.updateProfile { currentProfile in
    var updated = currentProfile ?? Profile()  // if profile record doesn’t exist, create new
    updated.displayName = "Alice A."
    updated.description = "iOS dev and Bluesky fan"
    return updated
}
This pattern fetches the profile, merges changes, and updates it
docs.bsky.app
. Behind the scenes it calls com.atproto.repo.putRecord with the app.bsky.actor.profile collection and your updated record data. Updating the avatar or banner image requires first uploading the image via uploadBlob and then including the returned blob reference in the profile record
docs.bsky.app
docs.bsky.app
. For a basic client, you might choose to implement just name/bio editing initially. Profile data in the app: Once fetched, you can display profile fields in SwiftUI views. For example, show the display name, handle, bio text, and download the avatar image (the profile will often include an avatar URL or blob reference you can convert to a URL). Ensure to handle cases where some fields might be nil (e.g. no bio or avatar).
6. Social Interactions: Follows, Likes, and Reposts
A Twitter-style app isn’t complete without the ability to follow users, like posts, and repost (reblog) posts. In the AT Protocol, follows, likes, and reposts are all implemented as records in the user’s repository, similar to posts. Each of these actions has a corresponding XRPC endpoint or can be done via the generic record creation/deletion endpoints. Here’s how to handle each:
6.1 Following and Unfollowing Users
Following someone on Bluesky creates a follow record of type app.bsky.graph.follow in your user’s repo. The minimal data needed is the DID of the user to follow. Most SDKs offer a simple method for this. For example:
swift
Copy
Edit
try await atProtoBluesky.follow(userDid: "did:plc:1234...abcd")
Calling follow with a DID will create the follow record. In the official SDKs, this returns the URI of the follow record that was created
docs.bsky.app
. Under the hood, it’s akin to calling com.atproto.repo.createRecord with collection: "app.bsky.graph.follow" and record content {"subject": "<DID of target>"} plus a timestamp. If you only have the handle of the user (e.g. bob.bsky.social), you should resolve it to a DID first. You can do this by calling com.atproto.identity.resolveHandle (which returns the DID for a handle) or by fetching the user’s profile (the profile contains their DID)
docs.bsky.app
. Unfollowing is achieved by deleting the follow record. If you use the high-level method, you likely call something like:
swift
Copy
Edit
try await atProtoBluesky.unfollow(followRecordUri: followUri)
When you followed a user, you got back a uri for that follow record
docs.bsky.app
. To unfollow, you supply that URI to the delete call. The official approach is agent.deleteFollow(uri) in TypeScript
docs.bsky.app
, which corresponds to calling com.atproto.repo.deleteRecord on the follow record’s URI. If you didn’t store the URI, you might need to retrieve your follows list (there’s an endpoint app.bsky.graph.getFollows to list who a user is following) and find the record. But typically, storing the URI from the initial follow action or checking the viewer state in a profile (which can indicate if you follow them) is easier. After a successful follow or unfollow, update your app’s state (e.g. toggle the “Follow” button). The changes should reflect in the user’s follower/following counts and in what content appears on their timeline (followed users’ posts will start/stop appearing).
6.2 Liking and Unliking Posts
Liking a post on Bluesky means creating a app.bsky.feed.like record in your repo. To like a post, you must know the URI and CID of that target post
docs.bsky.app
. The URI identifies which record to like, and the CID is used to ensure you’re liking a specific version of the content (preventing tampering). When you fetched the timeline or a post, these identifiers are included. For example, each post object from getTimeline has fields like post.uri and post.cid. Using a library, liking might look like:
swift
Copy
Edit
let post = somePostFromTimeline
try await atProtoBluesky.like(contentUri: post.uri, contentCid: post.cid)
This will call the like endpoint. In the official SDK, agent.like(uri, cid) returns the URI of the new like record
docs.bsky.app
. Internally, it’s creating a record in the app.bsky.feed.like collection with {"subject": { "uri": <postURI>, "cid": <postCID> }}. Unliking a post means deleting your like record. If you saved the like record’s URI from when you liked, you can call the delete. Some libraries provide a straightforward unlike(postUri) that finds and deletes the corresponding like record
docs.bsky.app
. In the Bluesky TypeScript agent, agent.deleteLike(uri) expects the like record’s URI (which in their implementation is the same as the post URI if they infer the like via state)
docs.bsky.app
. To clarify: the post’s URI and the like’s URI are different – the like’s URI is in your DID’s namespace (since it’s your record). However, the client may track which posts you’ve liked. An alternative approach is to call app.bsky.feed.getLikes on a post to get a list of likes and find if your DID liked it, but storing the like URI on creation is simpler. When a like is successful, update the UI (e.g. increment the post’s like count and highlight the like button). On unlike, decrement and un-highlight. The Bluesky API also provides in certain feed views a viewer state indicating if the current user has liked a post (and the URI of that like) which can help initialize UI state
docs.bsky.app
docs.bsky.app
.
6.3 Reposting (Reblueskying)
A repost (analogous to a retweet or reblog) is implemented very much like a like. The record type is app.bsky.feed.repost. To repost a post, you also need the target post’s URI and CID. The client library call might be:
swift
Copy
Edit
try await atProtoBluesky.repost(contentUri: post.uri, contentCid: post.cid)
This creates a repost record in your repo referencing that post
docs.bsky.app
. The response returns the repost record’s URI similar to like. Un-reposting means deleting that repost record (e.g. deleteRepost(uri))
docs.bsky.app
docs.bsky.app
. From the perspective of API, a repost record’s content might look like: {"subject": { "uri": <postURI>, "cid": <postCID> }}, same as like (except it’s stored in the repost collection). In feeds, reposts are often represented by a feed item that notes “Alice reposted Bob’s post”. The feed API (getTimeline) will actually include an embedded repost structure when someone you follow has reposted something, which contains the original post and the reposting user’s info. Handling that in the UI might require checking if a feed item is a repost and showing “Reposted by X” above the post content. The data model FeedViewPost in the Bluesky lexicon covers this scenario (it may have an reason: Repost field when applicable). Like with likes, the feed data often includes a viewer.repost field for each post, indicating if you have reposted it (and giving the repost record URI)
docs.bsky.app
. Use that to mark repost buttons as active/inactive. Summary: Follows, likes, and reposts all involve creating or deleting records via the AT Protocol. They require identifying the target (user DID for follows, post URI+CID for likes/reposts). Thanks to the lexicon definitions, the process is standardized and libraries provide convenient methods. After performing these actions, update your SwiftUI state to reflect the changes (e.g. update counts or button states). All these actions use the authenticated session token as they modify the user’s data.
7. Data Formats: Lexicons and Records in Practice
As mentioned earlier, Lexicons define the data schemas and API methods in the AT Protocol. For a developer, this means you should be aware of the structure of the data you send and receive. Bluesky maintains a lexicon repository (in the atproto GitHub) that includes JSON schema files for each record type and XRPC method. For example, there is a lexicon file for app.bsky.feed.post describing the fields of a post record, and one for app.bsky.feed.getTimeline describing its inputs and outputs
github.com
. When building your Swift app, you have a few ways to manage these data formats:
Use a Swift SDK with models: Libraries like ATProtoKit or swift-atproto include Swift structs/classes generated from the lexicon schemas
bskyinfo.com
. This means when you call, say, getProfile, the library will give you a Profile model object with properties like displayName, description, etc., corresponding to the lexicon. This is very convenient and ensures your app handles data types correctly according to the spec.
Manual decoding: If not using a full SDK, you can create your own Swift models conforming to Codable that match the JSON structure. For instance, you might define a struct FeedViewPost with nested structs for the post content and author, based on the lexicon spec or the JSON you see from the API. The lexicon definitions can guide you on field names and types (they are essentially JSON schemas). Additionally, Bluesky’s documentation often provides TypeScript interface examples for responses (as seen in the tutorial excerpts) which you can translate to Swift types
docs.bsky.app
docs.bsky.app
.
Lexicon IDs and XRPC: When calling endpoints directly, you’ll notice the URLs include the lexicon IDs (like app.bsky.feed.getTimeline). The payloads you send or receive will often include a $type field if needed to disambiguate the record type. For example, a reply post might include an $type: "app.bsky.feed.post" in the JSON. Most of the time you can ignore $type when using an SDK or if your models are specific to one type, but be aware it’s part of the protocol to identify record types.
Records: In AT Protocol, a Record refers to an instance of a lexicon-defined object stored in a user’s repo. Records are identified by a triple: the DID of the repo (user), the collection (lexicon record type), and the record key (like an ID or auto-generated key) – this forms that at:// URI. For example: at://did:plc:1234/app.bsky.feed.post/abcdefgh is a post record URI
docs.bsky.app
. The record’s contents conform to the schema for app.bsky.feed.post. When your app fetches data, you get records (like posts, likes, follows) in JSON form, which your code should decode. When you create or update records (posting, liking, etc.), you send JSON that must match the schema. The lexicons ensure both client and server agree on the data shape
docs.bsky.app
docs.bsky.app
. For most client developers, you don’t need to write or read the lexicon JSON files directly – you rely on documentation or SDK types. However, understanding that “a Bluesky post is just a record in the user’s repo, defined by a known schema” is useful, for instance when debugging or if you encounter a new field. If the Bluesky team extends the post schema (say to add polls), they will update the lexicon and you’d update your models accordingly. Dealing with Lexicon versioning: Bluesky is evolving, so lexicon schemas can change (though they strive for backwards compatibility). Keep an eye on official updates. The lexicon version 1 definitions mean fields might be added but rarely removed. Using a generator like lexicon-gen (a Swift tool to generate code from lexicons
bskyinfo.com
) can help keep models in sync. But if using community SDKs, they likely track the latest lexicon changes. In summary, lexicons and records are the backbone of data exchange in AT Protocol. In practice, use the provided models or carefully map JSON to Swift structures. Ensure you handle fields like cid and uri (often strings) properly, as they are important for performing actions (e.g., liking requires both). With the data layer understood, we can move to integrating more advanced features like custom feeds.
8. Custom Feeds and Recommendation Algorithms (Bluesky Feed Generators)
One of Bluesky’s unique protocol features is the ability to integrate custom algorithmic feeds via the feed generator system. In a Twitter-like app, this is akin to allowing different “algorithms” or curated timelines that the user can choose from (for example, a feed of only tech news posts, or a community-curated feed). Bluesky’s feed generator model lets anyone deploy a service that generates a feed, and users can subscribe to it. Let’s break down how your client can use this: Feed Generators: A feed generator is an independent service that produces a feed of posts according to some algorithm or criteria. It is identified by a URI (much like a user or record). In fact, a feed generator is itself represented by a record of type app.bsky.feed.generator in the feed generator’s own repo. The feed generator has a DID and possibly a handle. For example, Bluesky’s popular “What's Hot” feed might have a URI like at://did:xyz123/app.bsky.feed.generator/whats-hot
docs.bsky.app
. To the client, this is just an identifier to fetch posts from. Discovering Feed Generators: Currently, users typically find feed generator URIs via community sharing or a directory. There is an endpoint app.bsky.feed.getFeedGenerators which can fetch metadata of multiple feeds by URI, and app.bsky.feed.getSuggestedFeeds for suggestions
docs.bsky.app
docs.bsky.app
. For simplicity, you might hard-code or maintain a list of known feed URIs (or use Bluesky’s feed discovery API). Each feed generator has a display name and description you can show in the UI, which you get by calling app.bsky.feed.getFeedGenerator for that feed’s URI
docs.bsky.app
. Example: To get info about a feed generator (say we have its URI in feedUri):
swift
Copy
Edit
let feedInfo = try await atProtoBluesky.getFeedGenerator(feed: feedUri)
print(feedInfo.view.displayName, feedInfo.view.description)
This returns data including the feed’s uri, the DID of its creator, its displayName, description, and an optional avatar image
docs.bsky.app
docs.bsky.app
. It also tells you if the feed is currently online and valid (feed generators can go offline)
docs.bsky.app
. The viewer section in the response indicates if the current user has liked (subscribed to) this feed
docs.bsky.app
. Viewing a custom feed’s posts: To actually retrieve posts from a custom feed, use the app.bsky.feed.getFeed endpoint, providing the feed generator’s URI. This works similarly to getTimeline, but for an arbitrary feed. For example:
swift
Copy
Edit
let feedResponse = try await atProtoBluesky.getFeed(feed: feedUri, limit: 30)
let posts = feedResponse.feed  // array of FeedViewPost
This will give you up to 30 posts from that feed generator
docs.bsky.app
docs.bsky.app
, plus a cursor if there are more. The structure of each post in the feed is the same as the normal timeline. Your UI can present it just like the home timeline. Essentially, you are just calling a different XRPC method to fetch a different set of posts. A user might switch between “Following” (their timeline) and other custom feeds in the app’s UI, and you would call getTimeline for the former and getFeed(feed: someURI) for the latter. Subscribing (Liking a feed): Bluesky uses a clever mechanism to let users subscribe to (follow) a custom feed: the user likes the feed generator record. Liking a feed generator is analogous to following that feed. In the official app, when a user “stars” a custom feed, it creates a like on the feed’s record. You can do the same via the API. Given a feed generator’s URI and its cid (obtained from getFeedGenerator), you call the same like function as for liking a post:
swift
Copy
Edit
try await atProtoBluesky.like(contentUri: feedUri, contentCid: feedInfo.view.cid)
This creates a like record that ties the user to the feed generator
docs.bsky.app
. There’s no separate “subscribe feed” endpoint – it’s just a like on that generator record. The feed generator’s viewer info will then show a like URI, indicating the user is subscribed
docs.bsky.app
. To unsubscribe, you unlike that feed (delete the like record)
docs.bsky.app
. As a client developer, you may want to list the feeds the user is subscribed to. Currently, the easiest way is to fetch the user’s likes (app.bsky.feed.getLikes for the user’s DID) and filter those where the URI is a feed generator (they start with .../feed.generator/). However, Bluesky may provide a more direct way or suggestions API as it evolves. Using the feed in-app: Once subscribed, you might show the custom feed in a switcher or as an alternate timeline. You’ll fetch it with getFeed when selected. If the feed generator goes offline or returns an error, handle that gracefully (perhaps show a message). The isOnline/isValid flags from getFeedGenerator can be used to warn the user if a feed is unavailable
docs.bsky.app
. In summary, integrating custom feeds involves:
Knowing or discovering feed generator URIs.
Using getFeedGenerator to get metadata (name, etc.) for UI and the feed’s CID.
Allowing the user to “follow” the feed by liking the feed generator (and unfollow by unliking).
Fetching posts from the feed with getFeed(feed: uri) and displaying them.
This opens the door for personalized or community-curated timelines right in your app. As the Bluesky ecosystem grows, you might fetch a list of popular feeds from a community API or allow entering a feed URI manually.
9. Swift Libraries and SDKs for Bluesky Integration
Building on top of the raw AT Protocol is made easier by several community-maintained Swift libraries. You should consider using one of these to speed up development, as they handle the networking, data models, and endpoints for you:
ATProtoKit – A comprehensive Swift package for Bluesky/AT Protocol. It provides type-safe methods for all the common operations (login, fetch timeline, create posts, like, follow, etc.) in a style familiar to Swift developers
github.com
. For example, it has authenticate(handle:password:), createPostRecord(text:), follow(did:), etc. It wraps low-level XRPC calls into convenient async functions, and uses Swift’s Codable to map JSON to models. ATProtoKit is a great choice for building a client from scratch, and its README offers example usage
github.com
github.com
. Keep in mind it’s still pre-1.0, so some API changes are possible as the protocol evolves.
swift-atproto – Another Swift SDK which automatically generates models from the official lexicon specs
bskyinfo.com
. It includes modules for the atproto core and Bluesky-specific APIs. By using code generation, it stays very up-to-date with the latest schema. This library provides a low-level XRPC client (ATProtoXRPC) and high-level API functions via ATProtoAPI that correspond to each lexicon method. If you prefer a more auto-generated approach or want to contribute, this is an interesting project. (It even provides Swift macros to help with lexicon IDs.)
SwiftSky – An unofficial Bluesky client app written in SwiftUI (open-source on GitHub)
github.com
. While not a library per se, SwiftSky’s code can serve as a reference for implementing features. It likely uses one of the above SDKs or its own minimal networking. Similarly, IcySky is another open-source iOS Bluesky client
bskyinfo.com
. Reading through these codebases can give practical insight into how to structure your app, handle authentication flows, and present data in SwiftUI.
Others: The Bluesky community is active, and new tools keep emerging. For instance, there are packages like BlueSkyKit or others listed on community sites like BskyInfo. Also, some developers use cross-platform solutions (like using the TypeScript API via a bridging layer, or simple URLSession calls) for specific needs. But for a pure Swift solution, the ones above are the primary options as of 2025.
When choosing a library, consider its completeness and activity. ATProtoKit (by @aaronvegh) is MIT-licensed and has been updated frequently
bskyinfo.com
, covering most of the API surface. swift-atproto (by @andooown) is also MIT and actively updated through 2025
bskyinfo.com
bskyinfo.com
. Both should let you do everything described in this guide without reimplementing the wheel. If you opt not to use a library, you’ll be writing networking code for each endpoint (as sketched in earlier sections). This is doable but tedious; you must manage the URLs, HTTP headers (auth token), JSON encoding/decoding, and error handling for dozens of endpoints. The SDKs abstract that for you and reduce boilerplate. Finally, keep an eye on official Bluesky development. They have official SDKs in TypeScript and Python, and while a first-party Swift SDK isn’t out yet, one could appear. There’s also work on an OAuth-based auth flow
docs.bsky.app
 which might change how clients authenticate in the future (making it more like traditional Twitter API apps). Engaging with the Bluesky developer community (Discord, GitHub discussions, etc.) is a good way to stay updated on best practices.
Conclusion
By focusing on the AT Protocol integration, you can now build your SwiftUI app’s core social features: authenticating via Bluesky, loading timelines, posting, displaying profiles, and handling interactions (follows/likes/reposts). The data is structured by the protocol’s lexicons, which the available Swift libraries help manage. You also have the ability to differentiate your app by incorporating custom feeds (recommendation algorithms) through feed generators – something not possible on closed platforms. Remember to handle network errors, rate limits, and the occasionally eventual consistency (e.g., after posting or following, data might not instantaneously refresh due to federation delays
docs.bsky.app
). But overall, the AT Protocol’s design and Bluesky’s API make it relatively straightforward to create a modern, Twitter-like client that can plug into the decentralized social web. With SwiftUI’s intuitive UI building and the robust Bluesky backend, you have all the pieces to deliver a full-featured social networking app on the App Store. Happy coding!