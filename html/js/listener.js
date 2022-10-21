$(document).ready(function(){
    window.addEventListener('message', function(event) {

        // show or hide #lasergun
        if (event.data.action == 'open') {
            $('#radarGun').fadeIn("slow");
        } else if (event.data.action == 'close') {
            $('#radarGun').fadeOut("slow");
        }
        
        // show or hide #gunScope
        if (event.data.zoom == 'open') {
            $('#gunScope').show();
        } else if (event.data.zoom == 'close') {
            $('#gunScope').hide();
        }

        // show all the other features
        $('#speed').text(event.data.speed);
        $('#range').text(event.data.range);
        $('#speedPrefix').text(event.data.speedPrefix);
        $('#rangePrefix').text(event.data.rangePrefix);
        $('#fastsl').text(event.data.fastsl);
        $('#slowsl').text(event.data.slowsl);
        $('#triggeredSpeed').text(event.data.triggeredSpeed);
        $('#scopeSpeed').text(event.data.speed);
        $('#plate').text(event.data.plate);
    });
});