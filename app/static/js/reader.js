"use strict";

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
        target = target || this.currentLocationCfi.str;
        if (target) {
            this.display = this.rendition.display(target);
        } else {
            this.display = this.rendition.display();
        }
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
        $("nav").html($("<select/>", {
            id: "toc-selector",
            class: "custom-select custom-control-inline",
            html: navigation.toc.map((chapter, index) => {
                return $("<option/>", {
                    id: "toc-option-" + chapter.id,
                    label: chapter.label,
                    value: decodeURIComponent(chapter.href),
                });
            }),
            change: (event) => {
                epub_reader.draw(event.currentTarget.value);
                suppress_event(event);
            },
        }));
    });

    epub_reader.rendition.on("keydown", (event) => {
        parent.$(parent.document).trigger($.Event("keydown", event));
    });

    epub_reader.rendition.on("relocated", (location) => {
        let cfi = location.start.cfi;
        epub_reader.currentLocationCfi = new ePub.CFI(cfi);
        window.location.hash = cfi;

        let $option = $('option[value="' + location.start.href + '"]');
        if ($option.length > 0) {
            $('option').removeAttr('selected');
            $option.attr('selected', true);
        }
    });

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

    epub_reader.draw();
});
