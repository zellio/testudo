function is_function(fn) {
    return !!(fn && fn.constructor && fn.call && fn.apply);
}

function suppress_event(event) {
    is_function(event.preventDefault) && !event.preventDefault.passive && event.preventDefault();
    event.returnValue = false;
}

var EpubReader = (function() {
    function EpubReader() {
        this.url = new URL(document.URL);
        this.currentLocationCfi = new ePub.CFI(this.url.hash.slice(1));
        this.book = ePub(this.url.pathname + "/");
        this.rendition = this.book.renderTo("display", {
            width: "100%",
            height: "100%",
        });
        this.display = null;
    }

    function prev_page(event) {
        return this.rendition.prev();
    }

    function next_page(event) {
        return this.rendition.next();
    }

    function draw(target) {
        return this.display = this.rendition.display(target);
    }

    EpubReader.prototype = {
        nextPage: next_page,
        prevPage: prev_page,
        draw: draw,
    };

    return EpubReader;
}());

$(document).ready(() => {
    const KBD_ARROW_DIRECTION = {
        rtl: { prev: "ArrowRight", next: "ArrowLeft" },
        ltr: { prev: "ArrowLeft", next: "ArrowRight" },
    };

    let epub_reader = new EpubReader();

    epub_reader.book.loaded.navigation.then((navigation) => {
        let nav_list = [];
        function _load_list(items) {
            items.forEach((i) => {
                nav_list.push(i);
                i.subitems && i.subitems.length > 0 && _load_list(i.subitems);
            });
        }
        _load_list(navigation.toc);
        epub_reader.chapter_list = nav_list;

        $("nav").html($("<select/>", {
            id: "toc-selector",
            class: "custom-select custom-control-inline",
            html: epub_reader.chapter_list.map((chapter) => {
                return $("<option/>", {
                    id: "toc-option-" + chapter.id,
                    text: chapter.label,
                    value: (new URL(chapter.href, "file://")),
                });
            }),
            change: (event) => {
                let url = new URL(event.currentTarget.value),
                    target = decodeURIComponent(url.pathname).slice(1) + url.hash;
                epub_reader.draw(target)
                suppress_event(event);
            },
        }));
    });

    epub_reader.rendition.on("keydown", (event) => {
        parent.$(parent.document).trigger($.Event("keydown", event));
    });

    epub_reader.rendition.on("relocated", (location) => {
        let cfi = location.start.cfi;
        window.location.hash = cfi;
    });

    // rendition.on("relocated", (location) => {
    //   console.log("rendition:relocated");
    //   console.log(location);
    //   let cfi = location.start.cfi;
    //   currentLocationCfi = cfi;
    //   window.location.hash = cfi;
    //   history.pushState({}, "", "#" + cfi);
    // });

    $(".arrow").on("touchstart mousedown", (event) => {
        let $arrow_button = $(event.currentTarget);
        $arrow_button.css({"opacity": 1});
        $arrow_button.on("touchend mouseup", (event) => {
            setTimeout(() => {$arrow_button.css({"opacity": 0})}, 100);
        });
    });

    $("#prev").on("click", epub_reader.prevPage.bind(epub_reader));
    $("#next").on("click", epub_reader.nextPage.bind(epub_reader));

    $(window).on("keydown", (event) => {
        let direction = epub_reader.book.package.metadata.direction || "ltr";

        switch (event.key) {
        case KBD_ARROW_DIRECTION[direction].prev: epub_reader.prevPage(event); break;
        case KBD_ARROW_DIRECTION[direction].next: epub_reader.nextPage(event); break;
        }
    });

    let currentLocationCfi = epub_reader.url.hash.slice(1);
    if (currentLocationCfi) {
        epub_reader.draw(currentLocationCfi);
    } else {
        epub_reader.draw();
    }
});
