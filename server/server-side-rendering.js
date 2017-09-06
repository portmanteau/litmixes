import { onPageLoad } from "meteor/server-render";

onPageLoad(sink => {
  const slugArray = sink.request.url.path.split('/')

  if (slugArray.length > 0) {
    slug = slugArray[1]

    mix = Mixes.findOne({ slug: slug })

    console.log(mix)

    sink.appendToHead(`<title>litmix.es/${slug} -- LitMixes</title>`)
    sink.appendToHead(`<meta property="og:image" content="${mix.backgroundUrl}" />`)
    sink.appendToHead(`<link rel="icon" href="${mix.backgroundUrl}"/>`)
  } else {
    sink.appendToHead(`<title>LitMixes</title>`)
    sink.appendToHead(`<link rel="icon" href="/space-sun-solar-flare-animation-8.gif"/>`)
  }
})

