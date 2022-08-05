# They Search For You

One of the most useful websites in British politics is
[They Work For You](https://www.theyworkforyou.com) which:

> takes open data from the UK Parliament, and presents it in a way
> that’s easy to follow – for everyone. So now you can check, with
> just a few clicks: are They Working For You?

...but building complex searches for civil society matters, and
accessing such searches in a consistent way (RSS is handy, but
sometimes you want to look something up *right now* and on a mobile
device) can be challenging.

Thus: [They Search For You](https://github.com/alecmuffett/they-search-for-you) — curated search for civil society purposes.

### RSS Feeds and OPML

All searches cite associated RSS feeds, **however** on occasion the
search query which powers those feeds may be improved or updated, and
you **will not** receive warning of those changes because the feed
comes from TheyWorkForYou and resubscription will be necessary.

To help address this, we publish two resources:

* :repeat: a [RSS Feed of Updates to Searches](https://raw.githubusercontent.com/alecmuffett/they-search-for-you/main/UPDATES.rss)
* :oil_drum: an [OPML bundle of all feeds, *including* the Updates feed](https://raw.githubusercontent.com/alecmuffett/they-search-for-you/main/ALL-RSS-FEEDS.opml)

...so from time to time you should be able to delete all feeds and
re-import them via OPML, watching the Update feed for a trigger.

**important:** if you download the OPML file, beware that your browser
might add or replace the `.opml` suffix with `.txt`.

### Suggestions and Improvements

If you would like to see something added or removed, please
[log an issue](https://github.com/alecmuffett/they-search-for-you/issues/new)
(Github account required) or
[message me on Twitter.](https://twitter.com/AlecMuffett/)

nb: I am aware that the search keyword syntax I've written is much
more limited than the TWFY website allows, and that in a couple of
places I am kludging around this; for the moment I am content, and
will see how it develops.
