var IMAGES_SRC = "https://dl.dropboxusercontent.com/u/73445707/TennisMatchmaker/HomePageImages.json";    // URL of JSON file.

/* Initialise the carousel. Carousel2 only used for home page, all other pages
 * should use Carousel (3D) instead.
 */
function initCarousel2() {
    // Use AJAX to get images, alternative texts and etc.
    $.getJSON(IMAGES_SRC, function(data) {
        $.each(data, function(index, picture) {
            $("#carousel2").append("<figure class=\"carousel2-panel\"><div class=\"carousel2-content\">" +
                                  "<img " +
                                  "src=\"" + picture.source_image + "\" " +
                                  "alt=\"" + picture.alternative_text + "\" " +
                                  "/>" +
                                  "</div></figure>");
        });

        /* Inside AJAX call, because getJSON is an asynchronouse call, and cycle
         * gets called before all images has loaded.
         */
        // Use malsup's JQuery Cycle Plugin to make a 2D carousel.
        $('#carousel2').cycle({
            random: true,
            timeout: 6000
        });
    });
    return;
}