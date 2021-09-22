ScrollableFeed empty = ScrollableFeed(
  0,
  'waiting',
  0,
  'waiting',
  'waiting',
  0,
  'waiting',
  '',
  '',
  0,
  false,
  '',
  '',
);

ScrollableEpisode emptyEpisode = ScrollableEpisode(
    0, 'waiting', 0, 'waiting', 0, '', '', '', 0, '', '', 0, '');

class DownloadableContributor {
  final String name;

  DownloadableContributor(this.name);
}

class Contributor extends DownloadableContributor {
  final int id;

  Contributor(this.id, name) : super(name);
}

class IntermediateMediaItemQueryResult {
  final String mp3Url;
  final String mp3File;
  final int mp3FileSize;
  final String album;
  final String title;

  const IntermediateMediaItemQueryResult({
    required this.mp3Url,
    required this.mp3File,
    required this.mp3FileSize,
    required this.album,
    required this.title,
  });
}

class DownloadedEpisode {
  final String title;
  final String mp3Url;
  final String mp3File;
  final int mp3Filesize;
  String imageUrl;
  String imageFileName;
  int imageFileSize;
  String desc;

  DownloadedEpisode(
    this.title,
    this.mp3Url,
    this.mp3File,
    this.mp3Filesize,
    this.imageUrl,
    this.imageFileName,
    this.imageFileSize,
    this.desc,
  );
}

class ScrollableEpisode extends DownloadableEpisode {
  final int id;

  ScrollableEpisode(
    this.id,
    title,
    contributorID,
    contributor,
    feedID,
    feed,
    mp3Url,
    mp3File,
    mp3FileSize,
    imageUrl,
    imageFilename,
    imageFileSize,
    desc,
  ) : super(
          title,
          contributorID,
          contributor,
          feedID,
          feed,
          mp3Url,
          mp3File,
          mp3FileSize,
          imageUrl,
          imageFilename,
          imageFileSize,
          desc,
        );
}

class DownloadableEpisode {
  final String title;
  final int contributorID;
  String contributor;
  final int feedID;
  String feed;
  final String mp3Url;
  final String mp3File;
  final int mp3FileSize;
  String imageUrl;
  String imageFileName;
  int imageFileSize;
  String desc;

  DownloadableEpisode(
    this.title,
    this.contributorID,
    this.contributor,
    this.feedID,
    this.feed,
    this.mp3Url,
    this.mp3File,
    this.mp3FileSize,
    this.imageUrl,
    this.imageFileName,
    this.imageFileSize,
    this.desc,
  );
}

class DownloadedFeed {
  final String title;
  final String readBy;
  final String rssFeed;
  String imageUrl;
  String imageFileName;
  int imageFileSize;
  String desc;
  String imageDesc;

  DownloadedFeed(
    this.title,
    this.readBy,
    this.rssFeed,
    this.imageUrl,
    this.imageFileName,
    this.imageFileSize,
    this.desc,
    this.imageDesc,
  );
}

class DownloadableFeed {
  final String title;
  final int contributorID;
  String contributor;
  final String rssFeed;
  final int lastUpdate;
  final String link;
  final String imageUrl;
  final String imageFileName;
  int imageFileSize;
  final bool shouldDownLoad;
  String desc;
  String imageDesc;

  DownloadableFeed(
    this.title,
    this.contributorID,
    this.contributor,
    this.rssFeed,
    this.lastUpdate,
    this.link,
    this.imageUrl,
    this.imageFileName,
    this.imageFileSize,
    this.shouldDownLoad,
    this.desc,
    this.imageDesc,
  );
}

class ScrollableFeed extends DownloadableFeed {
  final int id;

  ScrollableFeed(
    this.id,
    title,
    contributorID,
    contributor,
    rssFeed,
    lastUpdate,
    link,
    imageUrl,
    imageFileName,
    imageFileSize,
    shouldDownLoad,
    desc,
    imageDesc,
  ) : super(
          title,
          contributorID,
          contributor,
          rssFeed,
          lastUpdate,
          link,
          imageUrl,
          imageFileName,
          imageFileSize,
          shouldDownLoad,
          desc,
          imageDesc,
        );
}
