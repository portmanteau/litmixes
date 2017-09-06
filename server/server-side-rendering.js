import { onPageLoad } from "meteor/server-render";

onPageLoad(sink => {
  const slugArray = sink.request.url.path.split('/')

  if (slugArray.length > 0) {
    slug = slugArray[1]

    const mix = Mixes.findOne({ slug: slug })
    const backgroundUrl = mix.backgroundUrl || "/space-sun-solar-flare-animation-8.gif"

    sink.appendToHead(`<title>${slug}</title>`)
    sink.appendToHead(`<meta property="og:image" content="${backgroundUrl}" />`)
    sink.appendToHead(`<link rel="icon" href="${backgroundUrl}"/>`)
  } else {
    sink.appendToHead(`<title>LitMixes</title>`)
    sink.appendToHead(`<link rel="icon" href="/space-sun-solar-flare-animation-8.gif"/>`)
  }
})
