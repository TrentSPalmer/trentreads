import 'package:flutter_html/flutter_html.dart';
import 'package:html/dom.dart' as dom;
import 'package:url_launcher/url_launcher.dart';

Future<void> _launch(String url) async {
  if (await canLaunch(url)) await launch(url);
}

Html aboutHtml() {
  return Html(
    data: """<!DOCTYPE html>
<html lang="en">
  <head>
    <style>
    p, li {
      font-size: 1.2rem;
      font-family: monospace;
      line-height: 1.5;
      text-align: justify;
    }
    h2 {
      font-family: Sans-serif;
    }
    hr { 
      margin-top: 3rem;
      margin-bottom: 3rem;
    }
    </style>
  </head>
  <body>
    <div style="display: flex; justify-content: space-around;">
      <div style="max-width: 1000px;">
        <h2>About</h2>

        <p>
        <a href="https://play.google.com/store/apps/details?id=org.trentpalmer.trentreads" target="_blank" rel="noopener noreferrer"> Trent Reads </a>
        is a
        <a href="https://flutter.dev/" target="_blank" rel="noopener noreferrer">flutter</a>
        application for consuming content from
        <a href="https://github.com/TrentSPalmer/trentpalmerdotorg" rel="noopener noreferrer" target="_blank">trentpalmer.org</a>, a
        <a href="https://www.djangoproject.com/"rel="noopener noreferrer" target="_blank">Django web application</a>
        I built for hosting public domain audio books I read, serialized as podcasts.
        </p>

        <hr>
        <h2>Tools</h2>

        <p>
          The Application is built in Android Studio on Arch Linux, with flutter integrations_tests deployed from
          <a href="https://blog.trentsonlinedocs.xyz/posts/debian-11-nspawn-flutter-integration-test-server/" rel="noopener noreferrer" target="_blank">Debian 11 Nspawn Containers</a>.
        </p>

        <p>
          The BackEnd server is build using vim in an Arch Linux virtual machine in my (homelab), and
          deployed on Arch Linux, using
          <a href="https://min.io/" rel="noopener noreferrer" target="_blank">minio</a>
          for S3-compatible object storage.
        </p>

        <p>
          I record in between naps and cigars, in Audacity on a refurb Dell Optiplex Running Debian 11 on a software raid1 mirror, using a
          <a href="http://www.samsontech.com/samson/products/microphones/usb-microphones/meteormic/" rel="noopener noreferrer" target="_blank">Samson Meteor USB microphone</a>.
        </p>
        <hr>

        <h2>Hire Me, Call Me</h2>
        <p>
          Call or text me at <a href="tel:503-515-8072">503-515-8072</a>
          if you require the services of a Linux fanatic who is
          having a lot of fun learning Django and Flutter.
        </p>

        <hr>
        <h2>RoadMap</h2>
        <ul>
          <li>Extend Flutter application to run on other platforms.</li>
          <li>chromecast, playback-speed, snooze, eq, interface tweaks, splash screen(s), etc</li>
          <li>testing, testing, testing.</li>
        </ul>
      </div>
    </div>
  </body>
</html>""",
    onLinkTap: (String? url, RenderContext context,
        Map<String, String> attributes, dom.Element? element) {
      if (url != null) _launch(url);
    },
  );
}
