import { onPageLoad } from "meteor/server-render";

onPageLoad(sink => {
  const slugArray = sink.request.url.pathname.split('/');

  if (slugArray.length > 0) {
    slug = slugArray[1];

    const mix = Mixes.findOne({ slug: slug });
    const backgroundUrl = mix && mix.backgroundUrl || "/space-sun-solar-flare-animation-8.gif";

    sink.appendToHead(`<title>${slug}</title>`);
    sink.appendToHead(`<meta property="og:type" content="article" />`);
    sink.appendToHead(`<meta property="og:url" content="http://www.litmix.es/${slug}" />`);
    sink.appendToHead(`<meta property="og:image" content="${backgroundUrl}" />`);
    sink.appendToHead(`<meta property="og:title" content="${slug}" />`);
    sink.appendToHead(`<link rel="icon" href="${backgroundUrl}"/>`);
  } else {
    sink.appendToHead(`<title>LitMixes</title>`);
    sink.appendToHead(`<meta property="og:type" content="website" />`);
    sink.appendToHead(`<meta property="og:url" content="http://www.litmix.es/" />`);
    sink.appendToHead(`<meta property="og:image" content="/space-sun-solar-flare-animation-8.gif" />`);
    sink.appendToHead(`<meta property="og:title" content="LitMixes" />`);
    sink.appendToHead(`<link rel="icon" href="/space-sun-solar-flare-animation-8.gif"/>`);
  }
})
