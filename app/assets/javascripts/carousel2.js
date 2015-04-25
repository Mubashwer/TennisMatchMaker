var FULL_TURN_DEGREE = 360;

// Index of panel to display. Initialised in init().
var carouselCurrentPanelIndex = null;

function getPanels() {
    // Get all carousel panels.
    return $("#carousel .carousel-panel");
}

function getPanelAt(index) {
    // Get carousel panel at the specified index.
    return getPanels().eq(index);
}

function getPanelSize() {
    // Get carousel panel width, in pixels, as a number.
    var panel = getPanels().first();
    return (panel.outerWidth() + 2 * parseInt(panel.css("left"), 10));
}

function getPanelRotateY() {
    // Get first carousel panel Y rotation, in degrees, as a number.
    // Second carousel panel Y rotation would be 2 times this number;
    // Third carousel panel Y rotation would be 3 times this number;
    // and so on.
    return FULL_TURN_DEGREE / getPanels().length;
}

function getPanelTranslateZ() {
    // Get carousel panel Z translation, in pixels, as a number.
    var numberOfPanels = getPanels().length;
    var panelSize = getPanelSize();
    return Math.round((panelSize / 2) / Math.tan(Math.PI / numberOfPanels));
}

function getCarouselCurrentRotateY() {
    // Get carousel Y rotation, in pixels, as a number.
    return carouselCurrentPanelIndex * getPanelRotateY();
}

function scrollCarousel(direction) {
    // Scroll the carousel in the specified direction.
    if (String(direction).toLowerCase() == "prev" ||
            String(direction).toLowerCase() == "previous" ||
            direction == -1) {
        carouselCurrentPanelIndex--;
    } else if (String(direction).toLowerCase() == "next" || direction == 1) {
        carouselCurrentPanelIndex++;
    }

    // Determine the transformation for each carousel panel.
    var rotateY = getPanelRotateY();
    var translateZ = getPanelTranslateZ();
    for (var i = 0; i < getPanels().length; i++) {
        getPanelAt(i).css("-webkit-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("-moz-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("-o-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
    }

    // Determine the transformation for the carousel.
    var carousel = $("#carousel");
    carousel.css("-webkit-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * getCarouselCurrentRotateY()) + "deg" + ")");
    carousel.css("-moz-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * getCarouselCurrentRotateY()) + "deg" + ")");
    carousel.css("-o-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * getCarouselCurrentRotateY()) + "deg" + ")");
    carousel.css("transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * getCarouselCurrentRotateY()) + "deg" + ")");

    return;
}

function addPanel() {
    // Append carousel panel to end.
    var carousel = $("#carousel");
    carouselCurrentPanelIndex += Math.floor(carouselCurrentPanelIndex / getPanels().length);
    carousel.append("<figure class=\"carousel-panel\"><div class=\"carousel-content\">" +
                    "<img src=\"https://dl.dropboxusercontent.com/u/73445707/info30005/workshop/images/Cloud.jpg\" alt=\"Cloud\">" +
                    "<h2>" + "Display Name" + "</h2>" +
                    "<p><strong>Email: </strong><br>" + "local@domain.com" + "</p>" +
                    "<p><strong>Biography: </strong><br>" + "Biography description about display name." + "</p>" +
                    "</div></figure>");
    scrollCarousel();
    return;
}
function removePanel() {
    // Remove carousel panel at end.
    carouselCurrentPanelIndex -= Math.floor(carouselCurrentPanelIndex / getPanels().length);
    getPanelAt(getPanels().length - 1).remove();
    scrollCarousel();
    return;
}

function initCarousel() {
    // Initialise the carousel.
    carouselCurrentPanelIndex = 0;
    scrollCarousel();

    // Attach onclick handler to #next, #prev, #add, #remove
    $("#next").click(function() { scrollCarousel("next"); return false; });
    $("#prev").click(function() { scrollCarousel("previous"); return false; });
    $("#add").click(function() { addPanel(); return false; });
    $("#remove").click(function() { removePanel(); return false; });
    return;
}