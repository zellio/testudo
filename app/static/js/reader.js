"use strict";

function is_function(fn) {
    return !!(fn && fn.constructor && fn.call && fn.apply);
}

function suppress_event(event) {
    is_function(event.preventDefault) && !event.preventDefault.passive && event.preventDefault();
    event.returnValue = false;
}

var EpubReader = (function() {
    function EpubReader(book_url, zip_source) {
        this.url = new URL(document.URL);
        this.source_url = new URL($('#reader-source-url').val());
        this.currentLocationCfi = new ePub.CFI(this.url.hash.slice(1));

        // epub.js doesn't pass options correctly so we have this ugly hack in
        // out code
        if (this.source_url.href.endsWith('/epub')) {
            let c = this.source_url.href.split('');
            c.splice(this.source_url.href.lastIndexOf('/'), 1, '.');
            this.source_url.href = c.join('');
        }

        // this doesn't work so ugly hack above.
        this.book = ePub(this.source_url.href, {openAs: "epub"});
        this.rendition = this.book.then((book) => {
            return book.renderTo("display", {
                width: "100%",
                height: "100%",
            });
        });
        this.display = null;
    }

    function prev_page(event) {
        return this.rendition.then((rendition) => {
            rendition.prev();
        });
    }

    function next_page(event) {
        return this.rendition.then((rendition) => {
            rendition.next();
        });
    }

    function draw(target) {
        target = target || this.currentLocationCfi.str;

        this.rendition.then(((rendition) => {
            if (target) {
                this.display = rendition.display(target);
            } else {
                this.display = rendition.display();
            }
        }).bind(this));
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

    epub_reader.book.then((book) => {
        let section_keys = {};
        Object.keys(book.sections.spineByHref).forEach((key) => {
            let index = book.sections.spineByHref[key];
            section_keys[index] = section_keys[index] || {}
            section_keys[index][key] = true;
        });

        let nav = $("nav");

        nav.addClass("mb-3");
        nav.html($('<div/>', {
            class: "container",
            html: $("<select/>", {
                id: "toc-selector",
                class: "form-select form-select-lg",
                html: book.sections.items.map((section, index) => {
                    let toc_entry = book.navigation.toc.find((element) => {
                        let element_href = decodeURIComponent(element.href);
                        if (element_href.indexOf('#') > 0) {
                            element_href = element_href.substring(0, element_href.lastIndexOf('#'));
                        }
                        let possible_keys = section_keys[index];
                        return possible_keys[element_href] || possible_keys[element_href.substring(1)];

                    });

                    let title = toc_entry ? toc_entry.title.trim() : "Entry " + index;
                    return $("<option/>", {
                        id: "toc-option-" + section.idref,
                        label: title,
                        text: title,
                        value: decodeURIComponent(section.href),
                        'data-section-index': section['index'],
                        'data-section-source': section['source'],
                    });
                }),
                change: (event) => {
                    epub_reader.draw(event.currentTarget.value);
                    suppress_event(event);
                },
            })
        }));
    });

    epub_reader.rendition.then((rendition) => {
        rendition.on("keydown", (event) => {
            parent.$(parent.document).trigger($.Event("keydown", event));
        });
    });

    epub_reader.rendition.then((rendition) => {
        rendition.on("relocated", (location) => {
            let cfi = location.start.cfi;
            epub_reader.currentLocationCfi = new ePub.CFI(cfi);
            window.location = '#' + cfi;
            let $option = $('option[data-section-source="' + location.start.href + '"]');
            if ($option.length > 0) {
                $('option').removeAttr('selected');
                $option.attr('selected', true);
            }
            else {
                console.log('No toc entry found.');
            }
        });
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
        epub_reader.book.then((book) => {
            let direction = book.manifest.metadata.direction || "ltr";
            switch (event.key) {
            case KBD_ARROW_DIRECTION[direction].prev: epub_reader.prevPage(event); break;
            case KBD_ARROW_DIRECTION[direction].next: epub_reader.nextPage(event); break;
            }
        });
    });

    $(window).on('hashchange', (event) => {
        let current_location_cfi = epub_reader.currentLocationCfi.str;
        let current_window_cfi = new ePub.CFI(window.location.hash.slice(1)).str;
        if (!(current_location_cfi == current_window_cfi)) {
            epub_reader.draw(current_window_cfi);
        }
    });

    epub_reader.draw();
});
