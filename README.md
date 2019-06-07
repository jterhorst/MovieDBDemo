### MovieDBDemo app

## Important

When you check out a copy of this, you _MUST_ place your own TMDB v3 API key into a copy of `MovieDBDemo/APIKeys.plist.template`, removing `.template` from the copy's filename. The app needs this key to run. It must be a v3 API key. Do not check that file with your key into Git.

## Notes

Built in Xcode 10.1 for iOS 12.1. I haven't tested it with iOS 13 yet.

## Design

The design was kept intentionally simple. No pagination for this example, but wouldn't be too difficult to add it to the existing structure.

CoreData made persistence automatic, and I used the prescribed NSPersistentContainer with its context-thread model. Basically, you can ask it to give you a background queue and an associated context to safely do background ops. I passed the container to my `MovieDBCoordinator`, where I executed requests on background queues, parsed the JSON, and then notified the UI of changes on the main thread.

The NSFetchedResultsController in my MovieListViewController handles the sorting and filtering for the different tabs and search results. If you're loading many pages of movies, it should be able to handle that well with automatic fetching.

The AppDelegate starts up the UI, and then passes the coordinator to where it's needed between the two view controllers.

After the JSON is converted into a dictionary, that is passed to `Movie+CoreDataClass`, where `updateWithJson` ensures we're getting what we need from the data.

## Tests

You can run tests within Xcode with the app target selected, and clicking Product > Test.

The unit test target has one test, focused around integrity of the JSON dictionary conversion to the Movie object.

The UI test target ensures that the search field works, and that the segments (or "tabs") are selectable.

## Appearance

I did some simple skinning with the appearance proxies in the AppDelegate. With additional design work and more data from the endpoint, the details view could likely support more scrolling data, images, and more. What you see is what made the most sense to me for browsing info about movies.
