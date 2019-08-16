function run() {
  let url = new URL(document.URL),
      currentLocationCfi = url.hash.slice(1),
      book = ePub(url.pathname + "/"),
      rendition = book.renderTo("display", { width: "100%", height: "100%"}),
      display,
      arrow_direction = {
        rtl: { prev: "ArrowRight", next: "ArrowLeft" },
        ltr: { prev: "ArrowLeft", next: "ArrowRight" },
      }

  function silenceClick(e) {
    e.preventDefault && e.preventDefault();
    e.returnValue = false;
  }

  function prevPage(e) {
    rendition.prev();
    silenceClick(e);
  }

  function nextPage(e) {
    rendition.next();
    silenceClick(e);
  }

  if (currentLocationCfi) {
    display = rendition.display(currentLocationCfi);
  } else {
    display = rendition.display();
  }

  rendition.on("relocated", (location) => {
    console.log(location);
    let cfi = location.start.cfi;
    currentLocationCfi = cfi;
    window.location.hash = cfi;
    history.pushState({}, '', "#" + cfi);
  });

  rendition.on("rendered", (section) => {
    console.log(section);
  });

  rendition.on("keydown", (e) => {
    console.log("container event");
    silenceClick(e);
    parent.$(parent.document).trigger($.Event('keydown', e));
  });

  $("#prev").on("click", prevPage);

  $("#next").on("click", nextPage);

  $(window).on("keydown", (e) => {
    let direction = book.package.metadata.direction || "ltr";

    switch (e.key) {
      case arrow_direction[direction].prev: prevPage(e); break;
      case arrow_direction[direction].next: nextPage(e); break;
    }
  });
}
