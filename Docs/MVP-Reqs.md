**Vox: MVP Specification Document**

---

## 🌟 Overview

**Vox** is a beautifully minimalist, conversation-first social app built on the [BlueSky AT Protocol](https://atproto.com). Think of it as the Apple-designed Twitter alternative: elegant, intentional, and expressive without the noise. Threads (posts) are the heart of Vox, with curated features that promote meaningful interaction and curated expression. Vox prioritizes **discoverability** as a core pillar—helping users find content that resonates, and helping creators find an audience.

---

## 🌎 Design Philosophy

* **Minimalism with soul**: Clean typography, spacious UI, elegant interactions.
* **Intentionality over virality**: Users post thoughtfully and discover with purpose.
* **Creative self-expression**: Support for multiple tones, moods, and post types.
* **Respectful engagement**: Limited metrics, smart defaults, no algorithmic trickery.
* **Frictionless discovery**: Feeds, recommendations, and tags designed to surface timely and personalized content.

---

## ⚖️ Core Technologies

* **Frontend**: iOS (SwiftUI)
* **Backend**: BlueSky AT Protocol for identity, data, feeds
* **Custom Services**: Node.js or Swift-based microservices for private features (e.g., Circle, Discover Feed)
* **Architecture**: Monolithic for MVP

  * A monolithic architecture is preferred for the MVP due to its simplicity, speed of development, and reduced infrastructure complexity.
  * It allows for rapid iteration and tightly integrated feature development.
  * As the app scales and usage patterns emerge, components such as the feed engine or Circle mechanics can be modularized into separate services if needed.

---

## 🔧 Core Features

### 1. **Authentication**

* BlueSky AT Protocol login via `createSession`
* Support for BlueSky default PDS and third-party PDS

### 2. **Home Feed**

* Primary feed is a personalized **"For You" feed** powered by:

  * Content freshness
  * Relevance to followed topics or interactions
  * Engagement trends (likes, replies, reposts)
* Secondary feed: **"Following" feed**, showing only content from accounts the user follows, in chronological order
* Clean card-based UI for each Thread

### 3. **Thread Creation (Post)**

* Markdown-like formatting support
* Attach images (inline preview)
* Tag via metadata (not hashtags)
* Option to:

  * Hide like count below a certain threshold
  * Auto-delete (30-day timer, or "delete if < X likes")

### 4. **Circle** *(Mutuals-only posts)*

* Only shown to mutual followers
* Stored on private backend (not on AT feed)
* Signed with AT identity

### 5. **Profiles**

* Display name, handle, avatar, bio
* Show Threads and replies
* Follow/follower count

### 6. **Thread View**

* Nested replies
* Repost, like, reply
* Show tags as pill-style UI elements (non-intrusive)

### 7. **Custom Feeds**

* Subscribe to public or app-generated feeds
* "No Algorithm" toggle to default to pure chronological

### 8. **Daily Prompts**

* App provides a creative prompt each day
* Users can opt-in and respond as Threads

### 9. **Drafts**

* Save unfinished Threads
* Local persistence + optional AI suggestions

### 10. **Notifications**

* Replies, mentions, likes, follows
* Basic badge display

### 11. **Settings**

* Theme (only dark mode. always)
* Default feed selection
* Session/logout management

---

## 🌟 Advanced Features (Stretch Goals)

* Voice-to-text Threads
* Co-authored Threads with dual avatars
* Semantic tagging + AI topic suggestions
* Post rewind / "On This Day" feature

---

## 📊 BlueSky Integration

### Protocol: [AT Protocol](https://atproto.com)

* Use TypeScript SDK or REST for:

  * `createSession` (login)
  * `getTimeline` (feeds)
  * `post` (create content)
  * `getPostThread` (thread view)
  * `getProfile`, `getAuthorFeed` (profile data)
  * `getLikes`, `getRepostedBy`

### Extensions:

* Custom feed generation via external service (used for personalized "For You" feed)
* Circle and hidden tags managed via private backend with AT identity signatures

---

## 🎓 UX Notes

* Typography: SF Pro, medium weight
* Cards: Rounded corners, light shadows
* Icons: Line-based, animated on tap
* Colors: Muted gradient accent, light/dark adaptable
* Animations: Springy tab changes, fade-in feeds, swipe-to-reply

## 🪧 Final Notes

This MVP aims to show that social media can be clean, expressive, and user-first—**while still offering robust content discovery that benefits both creators and casual users**. Vox will create a new lane for people who want digital expression without digital exhaustion. Cursor, you know what to do ✨
