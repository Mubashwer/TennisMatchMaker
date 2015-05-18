var FULL_TURN_DEGREE = 360;
var MIN_DELTA_MOUSE_PRESS_X = 100;    /* Minimum x distance of mouse movement to
                                       * swipe carousel, in pixels, as a number.
                                       */

// Get all active carousel panels.
function getPanels() { return $("#carousel .carousel-panel"); }

// Get all active and hidden carousel panels.
function getAllPanels() { return getPanels().add("#carousel .carousel-panel-hidden"); }

// Get center panel (one or zero)
function getCenterPanel() { return $("#carousel .carousel-panel-center");}

// Get carousel panel at the specified index.
function getPanelAt(index) { return getPanels().eq(index); }

// Get carousel panel width, in pixels, as a number.
function getPanelSize() {
    var panel = getPanels().first();
    return (panel.outerWidth() + 2 * parseInt(panel.css("left"), 10));
}

/* Get first carousel panel Y rotation, in degrees, as a number.
 * Second carousel panel Y rotation would be 2 times this number;
 * Third carousel panel Y rotation would be 3 times this number;
 * and so on.
 */
function getPanelRotateY() { return FULL_TURN_DEGREE / getPanels().length; }

// Get carousel panel Z translation, in pixels, as a number.
function getPanelTranslateZ() {
    var numberOfPanels = getPanels().length;
    var panelSize = getPanelSize();
    return Math.round((panelSize / 2) / Math.tan(Math.PI / (numberOfPanels > 6 ? numberOfPanels : 6)));
}

// Get carousel displaying panel's index, as a number.
function getCarouselCurrentPanelIndex() {
    return $("#carousel").data("carousel-current-panel-index");
}

// Set carousel displaying panel's index, as a number.
function setCarouselCurrentPanelIndex(carouselCurrentPanelIndex) {
    $("#carousel").data("carousel-current-panel-index", carouselCurrentPanelIndex);
    return getCarouselCurrentPanelIndex();
}

// Get carousel Y rotation, in pixels, as a number.
function getCarouselCurrentRotateY() {
    return getCarouselCurrentPanelIndex() * getPanelRotateY();
}

// Orientate and transform the carousel.
function orientateCarousel() {
    var carousel = $("#carousel");
    var rotateY = getCarouselCurrentRotateY();
    var translateZ = getPanelTranslateZ();
    carousel.css("-webkit-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * rotateY) + "deg" + ")");
    carousel.css("-moz-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * rotateY) + "deg" + ")");
    carousel.css("-o-transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * rotateY) + "deg" + ")");
    carousel.css("transform", "translateZ(" + (-1 * translateZ) + "px" + ") rotateY(" + (-1 * rotateY) + "deg" + ")");

    // Rotate centre panel the opposite way to ensure stationary
    getCenterPanel().css("-webkit-transform", "rotateY(" + (rotateY) + "deg" + ")");
    getCenterPanel().css("-moz-transform", "rotateY(" + (rotateY) + "deg" + ")");
    getCenterPanel().css("-o-transform", "rotateY(" + (rotateY) + "deg" + ")");
    getCenterPanel().css("transform", "rotateY(" + (rotateY) + "deg" + ")");
    return;
}

// Orientate and transform all carousel panels.
function orientatePanels() {
    var rotateY = getPanelRotateY();
    var translateZ = getPanelTranslateZ();
    for (var i = 0; i < getPanels().length; i++) {
        getPanelAt(i).css("-webkit-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("-moz-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("-o-transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
        getPanelAt(i).css("transform", "rotateY(" + (i * rotateY) + "deg" + ") translateZ(" + translateZ + "px" + ")");
    }

    // Re-orientate and transform the carousel in response to changes to panels.
    orientateCarousel();

    /* Bug fixes for AJAX version of carousel.
     */
    // Remove images shadows while dragging.
    $("#carousel img").attr("draggable", "false");
    // Resize centre panel and its image with number of results.
    var centerPanelSize = 45 * getPanels().length + 450;
    getCenterPanel().width(centerPanelSize);
    getCenterPanel().height(centerPanelSize);
    getCenterPanel().css("margin-top", -centerPanelSize / 2);
    getCenterPanel().css("margin-left", -centerPanelSize / 2);
    $("img", getCenterPanel()).width(centerPanelSize);
    $("img", getCenterPanel()).height(centerPanelSize);
    return;
}

// Scroll the carousel in the specified direction.
function scrollCarousel(direction) {
    if (String(direction).toLowerCase() == "prev" ||
            String(direction).toLowerCase() == "previous" ||
            direction == -1) {
        setCarouselCurrentPanelIndex(getCarouselCurrentPanelIndex() - 1);
    } else if (String(direction).toLowerCase() == "next" || direction == 1) {
        setCarouselCurrentPanelIndex(getCarouselCurrentPanelIndex() + 1);
    }
    orientateCarousel();
    return;
}

// Append carousel panel to end.
function addPanel() {
    var carousel = $("#carousel");
    setCarouselCurrentPanelIndex(getCarouselCurrentPanelIndex() + Math.floor(getCarouselCurrentPanelIndex() / getPanels().length));
    carousel.append("<figure class=\"carousel-panel\"><div class=\"carousel-content\">" +
                    "<img src=\"https://dl.dropboxusercontent.com/u/73445707/info30005/workshop/images/Cloud.jpg\" alt=\"Cloud\">" +
                    "<h2>" + "Display Name" + "</h2>" +
                    "<p><strong>Email: </strong><br>" + "local@domain.com" + "</p>" +
                    "<p><strong>Biography: </strong><br>" + "Biography description about display name." + "</p>" +
                    "</div></figure>");
    // Remove images shadows while dragging.
    orientatePanels();
    return;
}

// Remove carousel panel at end.
function removePanel() {
    setCarouselCurrentPanelIndex(getCarouselCurrentPanelIndex() - Math.floor(getCarouselCurrentPanelIndex() / getPanels().length));
    getPanelAt(getPanels().length - 1).remove();
    orientatePanels();
    return;
}

// Initialise the carousel.
function initCarousel() {
    // Orientate panels and carousel.
    orientatePanels();

    // Attach mouse swipe to carousel container. 
    var startMousePressX = null, endMousePressX = null, deltaMousePressX = 0;
    $("#carousel-container").mousedown(function(e) {
        startMousePressX = e.pageX;
    });
    $(window).mousemove(function(e) {
        if (startMousePressX) {
            endMousePressX = e.pageX;
            deltaMousePressX = Math.abs(endMousePressX - startMousePressX);
            if (deltaMousePressX >= MIN_DELTA_MOUSE_PRESS_X) {
                scrollCarousel(-(endMousePressX - startMousePressX) / deltaMousePressX);
                startMousePressX = endMousePressX;
            }
        }
    });
    $(window).mouseup(function(e) { startMousePressX = null; });
    
    // Remove images shadows while dragging.
    $("#carousel img").attr("draggable", "false");

    // Attach onclick handler to #next, #prev, #add, #remove.
    $("#next").click(function() { scrollCarousel("next"); return false; });
    $("#prev").click(function() { scrollCarousel("previous"); return false; });
    $("#add").click(function() { addPanel(); return false; });
    $("#remove").click(function() { removePanel(); return false; });

    // Attach keypress handler to left arrow key, right arrow key.
    $(document).keydown(function(e) {
        switch(e.which) {
            case 37: // Left.
                scrollCarousel("previous"); break;
            case 39: // Right.
                scrollCarousel("next"); break;
            default:
                break;
        }
    });
    return;
}
