[![Trent Reads Feature Graphic](https://github.com/TrentSPalmer/trentreads/blob/master/trent_reads_feature_graphic.png)](https://play.google.com/store/apps/details?id=org.trentpalmer.trentreads)
# About

[Trent Reads](https://play.google.com/store/apps/details?id=org.trentpalmer.trentreads)
is a [flutter](https://flutter.dev/) application for consuming content from
[trentpalmer.org](https://github.com/TrentSPalmer/trentpalmerdotorg),
a [Django web application](https://www.djangoproject.com/) I built for hosting public domain
audio books I read, serialized as podcasts.

![Screen Shot](https://github.com/TrentSPalmer/trentreads/blob/master/screenshots/Screenshot_20210923-015633_trentreads.png)

# Tools
The Application is built in Android Studio on Arch Linux, with
flutter integrations_tests deployed from
[Debian 11 Nspawn Containers](https://blog.trentsonlinedocs.xyz/posts/debian-11-nspawn-flutter-integration-test-server/).

The BackEnd server is build using vim in an Arch Linux virtual machine in my (homelab), and
deployed on Arch Linux, using [minio](https://min.io/) for S3-compatible object storage.

I record in between naps and cigars, in Audacity on a refurb Dell Optiplex Running Debian 11 on a software raid1 mirror, using a
[Samson Meteor USB microphone](http://www.samsontech.com/samson/products/microphones/usb-microphones/meteormic/).

![Screen Shot](https://github.com/TrentSPalmer/trentreads/blob/master/screenshots/Screenshot_20210923-015815_trentreads.png)

# Hire Me, Call Me
If you are interested in hiring a Linux fanatic who is learning Django and Flutter,
call or text me at <a href="tel:503-515-8072">503-515-8072</a>.

# RoadMap
* Extend Flutter application to run on other platforms.
* chromecast, playback-speed, snooze, eq, interface tweaks, splash screen(s), etc
* testing, testing, testing.
