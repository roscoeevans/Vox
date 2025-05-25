Vox Recommendation Algorithm Requirements
🎯 Purpose
Deliver a highly personalized, up-to-date feed for each user by surfacing the most relevant, timely, and impactful content, while ensuring users never miss important conversations or major trends—even outside their immediate network.

📝 Requirements
1. Timeliness & Relevance
Prioritize recent content, especially posts that have high engagement or are rapidly gaining traction (think “Twitter, but with a caffeine addiction”).

Ensure users see what’s happening now, not just what’s popular from earlier.

2. Content Dependencies & Thread Awareness
Detect when a post is a reply, quote, or reaction.

If a reply/reaction is highly engaging, ensure the user sees the original post first, or at least has easy access to context.

Highlight impactful or “root” posts in a thread before their replies, unless the reply is especially relevant to the user’s interests.

3. Trending Topics & News
Identify trending topics within the app, as well as major news stories relevant to user interests or location.

Surface major news and trending topics from outside a user’s follow network, similar to TikTok’s “For You” or Twitter’s “Trends for you.”

Give extra weight to trends relevant to a user’s declared or inferred interests.

4. Personalization
Build a user profile based on interactions (likes, replies, reposts, follows, swipes).

Support a “swipe” interface for stronger feedback:

Swipe left: Mark content as highly interesting (strong positive signal).

Swipe right: Mark content as not interested (strong negative signal).

Swipes should weigh more than passive interactions (likes, time spent).

Continuously refine recommendations based on feedback and new user behaviors.

5. Content Diversity & Discovery
Occasionally surface diverse content from outside a user’s normal bubble to promote discovery and avoid echo chambers.

Algorithmically inject content from new creators, emerging topics, or underrepresented voices.

6. Major Moments First
Prioritize surfacing major events, breaking news, or viral content—even if it comes from users the person doesn’t follow.

7. Contextual Awareness
Factor in the dependencies between posts (original, reply, reaction, quote) to avoid surfacing confusing fragments.

Optionally, group related posts or show context with a “thread preview.”

8. Scalability
Ensure the algorithm is performant and scales gracefully with growing users and content volume.

9. Transparency & User Control
Allow users to adjust their content preferences (topics, interests, muted keywords, etc.).

Clearly communicate how recommendations are generated.

Provide an option for users to “reset” or retrain their feed preferences.

10. Privacy
Handle all user data according to the app’s privacy policy and regulatory requirements.

Allow users to opt out of personalized recommendations if desired.

✨ Stretch Goals (Nice-to-Have)
Contextual surfacing for local events or region-specific news.

Real-time adjustments: Update feed order as breaking news or trends emerge.

Summaries or highlights for long threads or trending topics.

Let users “pin” interests/topics they want more or less of.