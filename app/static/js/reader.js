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
        this.currentLocationCfi = this.url.hash.slice(1);
        this.book = ePub(this.url.pathname + "/");
        this.rendition = this.book.renderTo("display", {
            width: "100%",
            height: "100%",
        });
        this.display = null;
    }

    function prev_page(event) {
        this.rendition.prev();
    }

    function next_page(event) {
        this.rendition.next();
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

function run() {
    const KBD_ARROW_DIRECTION = {
        rtl: { prev: "ArrowRight", next: "ArrowLeft" },
        ltr: { prev: "ArrowLeft", next: "ArrowRight" },
    };

    let epub_reader = new EpubReader();

    epub_reader.book.loaded.navigation.then((navigation) => {
        $('nav').html($('<select/>', {
            class: "custom-select",
            html: navigation.toc.map((chapter) => {
                return $('<option/>', {
                    id: "toc-li-" + chapter.id,
                    class: "toc-list-item",
                    value: chapter.href,
                    text: chapter.label,
                });
            }),
            change: (event) => {
                let target = decodeURIComponent(event.currentTarget.value);
                epub_reader.draw(target);
            },
        }));
    });

    epub_reader.rendition.on("keydown", (event) => {
        parent.$(parent.document).trigger($.Event('keydown', event));
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
    //   history.pushState({}, '', "#" + cfi);
    // });

    $(".arrow").on("touchstart mousedown", (event) => {
        let arrow_button = $(event.currentTarget);
        arrow_button.css({'opacity': 1});
        arrow_button.on("touchend mouseup", (event) => {
            setTimeout(() => {arrow_button.css({'opacity': 0})}, 100);
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
}
