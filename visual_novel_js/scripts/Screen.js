//Screen.js - to use for 'visual novel' engine
//holds the Screen object and its methods
//as well as the important variables

var Screen = {};
var SetScene = {};
var Game = {};
var Routes = {};
var bookmark = 0;
var textSpeed = 42;
var voiceToggle = false;
var update = false; //if an update to the screen is happening, prevent spacebar press from advancing
var currentRoute = "mainRoute"; //keep track of current route - start at main route


//stuff this array with all your setScenes()
//var stack = [];

//should max chars on screen be 2? 3? there should be limits on how many characters can show up right?
//var characters = [];

//if back button click, go back (this is used in Screen.menuScreen() - should there just be one instance of this function?)
/*
            $(".options").click(function(){
            //show option screen
            $("#optionScreen").css({"z-index": 1, "opacity": 1});
            
            //if back button click, go back 
            $("#back").click(function(){
                //hide option screen
                $("#optionScreen").css({"z-index": -1, "opacity": 0});
            });
        });
*/

/**
* SCREEN OBJECT ================================================
* functions that pertain to the screens (menu, option, game) for the game
**/
var canvas;
var ctx;

Screen.make = function(width, height){
    $('#rowDialog').css({"width": width});
    
    //what about a progress bar, showing you how far in the game you are?
    //like a simple graph with nodes showing you what node you're on.
    //maybe create something like that upon screen make?
    //one problem is the user is making up the game as they go along.
    //maybe make another function, like screen.makeProgressBar, to be called
    //AFTER all the dialog is typed in and stuff. also, another function, maybe
    //called game.createCheckpoint, can put in the stack variable a string "marker"
    //to indicate a node in the progress bar. then makeProgressBar will loop through 
    //the stack, find all the checkpoints, and create nodes that way. 
    
    //put canvas in div, give it a border
    canvas = $(`<canvas id='theScreen' width=${width} height=${height}></canvas>`);
    canvas.appendTo($('#rowScreen'))
    .css("border", "#fff 1px solid")
    .css("width", width)
    .css("height", height);
    
    var offsetTop = $('#theScreen').position()["top"];
    var offsetLeft = $('#theScreen').position()["left"];
    
    // we need to set up 4 separate screens: 
    // one for displaying just the characters (to allow for easy animation, ideally),
    // one for displaying route options, one for the menu and one for options.
    // these screens are overlayed on top of each other
    var screens = ['char', 'route', 'menu', 'option'];
    screens.forEach((screenName) => {
        // note that each screenName will be part of an HTML id, which the css will depend on
        var screen = $(`<div id='${screenName}Screen'></div>`);
        screen.appendTo($('#rowScreen'))
        .css({"top": `${offsetTop}px`, "left": `${offsetLeft}px`, "width": width, "height": height});
    });
    
    createOptionsMenu(width, height, offsetLeft, offsetTop);
    
    // audio element for music
    var audioElement = $("<audio id='music' preload='auto'></audio>");
    audioElement.appendTo($('#screen'));
    $('#music').prop("volume", .8);
    
    // audio element for sound effects
    var audioElement2 = $("<audio id='effects'></audio>");
    audioElement2.appendTo($('#screen')); 
}

Screen.setDialogBox = function(imageSrc){
    $('#rowDialog').css({"background-image": `url("${imageSrc}")`});
}

//only three options?
//also, how to customise buttons??
Screen.routeScreen = function(option1, option1Name, option2, option2Name, option3, option3Name){
    //another function wraps the code because we want this stuff to get executed when called, not
    //immediately. even if a function is placed in an array, it'll still get executed without the
    //additional inner function.
    return function(){
        $('#routeScreen').empty();
        
        //set update to true so spacebar won't be active
        update = true;
        
        //update option screen with new choices
        var choice1 = $('.option1')
        var choice2 = $('.option2')
        var choice3 = $('.option3');
        
        //check if the choice button elements don't exist yet
        if(option1 !== "" && option2 !== "" && !$('.option1').length){
            choice1 = createChoiceButton(option1Name, 1);
            choice2 =  createChoiceButton(option2Name, 2);
        }
        
        //option3 separated here because at the minimum, there should be 2 options. 3rd is optional.
        if(option3 !== "" && !$('.option3').length){
            choice3 = createChoiceButton(option3Name, 3);
        }
        
        choice1.appendTo($('#routeScreen'));
        choice2.appendTo($('#routeScreen'));
        choice3.appendTo($('#routeScreen'));

        //show screen by changing opacity
        //good read on z-index, may be relevant: https://philipwalton.com/articles/what-no-one-told-you-about-z-index/
        $('#charScreen').css("opacity", .4);
        $('#theScreen').css("opacity", .4);
        $('#routeScreen').css({"opacity": 1, "z-index": 1});
        
        SetScene.fadeAudio(0)();
        //execute route according to btn click
        $(".option1").click(function(){
            Screen.closeOpScreen();
            Game.branch(option1)();
        });
        $(".option2").click(function(){
            Screen.closeOpScreen();
            Game.branch(option2)();
        });
        $(".option3").click(function(){
            Screen.closeOpScreen();
            Game.branch(option3)();
        });
    }
}

// used to display buttons you'd expect to see in a menu like start, save, load, etc.
Screen.menuScreen = function(menuBG, style){
    if(style === "col"){
        //create the new elements if they don't exist
        if(!$('#left').length){
            var col = $("<div id='left' class='col-lg-12 col-md-12 col-sm-12'> <div id='right'></div> </div>");
            col.appendTo($('#menuScreen'));
        
            var choice1 = $("<div class='row'><button class='btn-primary' id='start'>start</button></div>");
            //var choice2 =  $("<div class='row'><button class='btn-primary' id='save'>load</button></div>");
            //var choice3 =  $("<div class='row'><button class='btn-primary' id='options'>options</button></div>");
        
            choice1.appendTo($('#right'));
            //choice2.appendTo($('#right'));
            //choice3.appendTo($('#right'));
        }
        
        $('#left').css({"background-image": "url(" + menuBG + ")"});
    
    //show the menu screen in a different way
    }else if(style === "row"){
    }
}

Screen.closeOpScreen = function(){
    $('#charScreen').css("opacity", 1);
    $('#theScreen').css("opacity", 1);
    $('#routeScreen').css({"opacity": 0, "z-index": -1});
}

function createChoiceButton(choiceName, choiceNum){
    return $(`<div class='row'><button class='btn routeOptionBtn option${choiceNum}'>${choiceName}</button></div>`);
}

function createOptionsMenu(width, height, offsetLeft, offsetTop){
    var optionHeader = $("<h1> options! </h1>");
    optionHeader.appendTo($('#optionScreen'));
    
    var toggleVolume = $(
        "<div><label for='volControl'>volume:</label> <input id='volControl' type='range' min='0' max='1' step='.1' value='.8' /> <p id='volCtrlVal' class='optionVal'>0.8</p></div>"
    );
    
    var toggleTextSpeed = $(
        "<div><label for='textControl'>text speed:</label> <input id='textControl' type='range' min='-80' max='-1' step='1' /> <p id='txtCtrlVal' class='optionVal'>42</p></div>"
    );
    
    var toggleVoice = $(
        "<div><label for='voiceToggle'>character voice:</label> <br /><input type='radio' name='voiceToggle' id='voiceOn' value='on' /><label for='voiceOn'> on </label> <input type='radio' name='voiceToggle' id='voiceOff' value='off' checked /><label for='voiceOff'> off </label> </div>"
    );
    
    toggleVolume.appendTo($("#optionScreen"));
    $('<br />').appendTo($("#optionScreen"));
    toggleTextSpeed.appendTo($("#optionScreen"));
    $('<br />').appendTo($("#optionScreen"));
    toggleVoice.appendTo($("#optionScreen"));
    
    // add event listeners
    var volController = document.getElementById('volControl');
    volController.oninput = function(){
        var audioVolume = document.getElementById('music');
        audioVolume.volume = parseFloat($('#volControl').val());
        $('#volCtrlVal').text($('#volControl').val());
    }
    
    var textSpeedController = document.getElementById('textControl');
    textSpeedController.oninput = function(){
        // we want the slider to get more negative (decrease in seconds) as we move left to right
        SetScene.setDialogSpeed(textSpeedController.value * -1);
        $('#txtCtrlVal').text(textSpeedController.value * -1);
    }
    
    var voiceToggleBtns = [$('#voiceOn'), $('#voiceOff')];
    voiceToggleBtns.forEach((radioButton) => {
        radioButton.on('input', function(){
            var val = radioButton.val();
            if(val === "on"){
                voiceToggle = true;
            }else{
                voiceToggle = false;
            }
        });
    });
    
    var backButton = $("<button id='back' class='btn'> go back </button>");
    backButton.appendTo($("#optionScreen"));
    
    return optionScreen;
}

//start the game on click!
//placing this event under .on() allows for the event to 
//be bound to a dynamically created element (in this case, buttons)
$(document).on('click', '#start', function(){
    $('#menuScreen').css({"z-index": -1, "opacity": 0});
    Game.nextScene();
    gameStart();
});
        
//load option screen to change volume, text speed, etc.
$(document).on('click', ".options", function(){
    //show option screen
    $("#optionScreen").css({"z-index": 1, "opacity": 1});
            
    //if back button click, go back 
    $(document).on('click', "#back", function(){
        //hide option screen
        $("#optionScreen").css({"z-index": -1, "opacity": 0});
    });
});
