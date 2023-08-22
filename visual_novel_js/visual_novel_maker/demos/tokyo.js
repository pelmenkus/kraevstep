//mr.cat's neighborhood

if(window.speechSynthesis){
    // https://stackoverflow.com/questions/49506716/speechsynthesis-getvoices-returns-empty-array-on-windows
    var voices = window.speechSynthesis.getVoices();
    if(voices.length > 0){
        setupGame(voices);
    }else{
        // at least on chrome, voices may not be available right away so we need this event listener
        window.speechSynthesis.addEventListener("voiceschanged", () => {
            voices = window.speechSynthesis.getVoices();
            setupGame(voices);
        });
    } 
}else{
    setupGame();
}

function setupGame(voices=null){
    Screen.menuScreen("artAssets/10.png", "col");
    Screen.setDialogBox("artAssets/dialogBar.png");

    //set up characters
    //for better cross-browser experience, only microsoft david and zira are used (since they seem to be available on chrome, edge and firefox)
    var david = voices.filter(v => v.name.toLowerCase().indexOf("david") >= 0)[0];
    var zira = voices.filter(v => v.name.toLowerCase().indexOf("zira") >= 0)[0];
    
    Game.character("cat", '#000', (voices ? david : null));
    Game.character("Богдан", '#000', (voices ? david : null));
    //Game.character("", '#000', (voices ? david : null));
    //Game.character("kitty", '#000');
    //Game.character("tabby", '#000');
    Game.character("Ника", '#000', (voices ? zira : null));
    Game.character("Ева", '#000', (voices ? zira : null)); // if on Chrome, I would use voices[12] - google uk english female
    Game.character("Кристина", '#000', (voices ? zira : null));  // if on Chrome, I would use voices[13] - google uk english male
    Game.character("Лена", '#000', (voices ? zira : null));
    //always need main route - where the game starts
    Routes["mainRoute"] = [
        SetScene.newBGwithMusic("artAssets/53.png", "audioAssets/112316energeticbgm.wav"),
        SetScene.dialog("Богдан", "Тогда  я с матерью только переехал в другой город из-за ее работы. "),
        SetScene.dialog("Богдан", "В новой школе я не успел еще завести себе друзей, потому что был занят помощью по дому, разбирать коробки и все такое"),
        SetScene.dialog("Богдан", "учитель дал классу групповое задание. В одной группе должно быть до трех человек и большинство групп было сформировано, а я все еще не мог найти с кем работать."),
        SetScene.background("artAssets/17.png"),
        SetScene.dialog("", "Понедельник, утро, распределение по группам"),
        SetScene.showCharacter("Ника","artAssets/Nika.png","left",true),
        SetScene.showCharacter("Ева","artAssets/Eva.png","right",true),
        SetScene.dialog("Ника", "Новенький, ты же еще без группы? Можешь присоединиться к нам, нам как раз нужен еще человек! "),
        SetScene.backgroundClearChar("artAssets/17.png"),
        SetScene.showCharacter("Лена","artAssets/Lena.png","left",true),
        SetScene.showCharacter("Кристина","artAssets/Kris.png","right",true),
        SetScene.dialog("Лена","Ну вот, я только хотела предложить присоединиться к нам. Если хочешь, можешь все-таки работать с нами."),
        Screen.routeScreen("Группа Лены", "Выбрать группу Лены и Кристины", "Группа Ники", "Выбрать группу Ники и Евы", "", "")
    ];

    Routes["Группа Лены"] = [
        SetScene.newBGwithMusic("artAssets/17.png", "audioAssets/112316happybgm.wav"),
        SetScene.showCharacter("Лена", "artAssets/Lena.png", "left", false),
        SetScene.showCharacter("Кристина","artAssets/Kris.png","right",false),
        SetScene.dialog("Лена", "Добро пожаловать в группу! Я Лена, а это Кристина. Тебя ведь зовут Богдан? "), 
        SetScene.dialog("Богдан", "Все верно. Приятно познакомиться."),
        SetScene.dialog("Кристина", "Я хочу кушать, давайте после урока сходим в столовую и купим покушать?"),
        SetScene.dialog("Ленa", "Ты же на прошлой перемене ходила покупать еду! Давайте лучше сходим после школы покушать?"),
        SetScene.dialog("Кристина","А Богдана с собой возьмем? "),
        SetScene.dialog("Богдан","Я, пожалуй, откажусь, мне нужно будет домой. Можно будет как-нибудь в другой раз."),
        SetScene.dialog("Лена","Mожет сходим на фестиваль?"),
        SetScene.dialog("Кристина","А можно с ночевкой ко мне. Салют можно посмотреть с окна."),
        SetScene.dialog("Лена","Так тоже, конечно, можно, но Богдан же будет впервые на фестивале в нашем городе…"),
        Screen.routeScreen("Ночевка", "Остаться на ночёвке у Кристины", "Фестиваль", "Сходить на фестиваль", "", "")
    ];

    Routes["Группа Ники"] = [
        SetScene.newBGwithMusic("artAssets/17.png", "audioAssets/112316happybgm.wav"),
        SetScene.changeCharacter("cat", "artAssets/cat6.png"),
        SetScene.dialog("cat", "Yay, thank youuuuuu!!!! (purring sounds)"),
        SetScene.dialog("cat", "Let me show you another room."),
        SetScene.background("artAssets/room1.png"),
        SetScene.changeCharacter("cat", "artAssets/cat3.png"),
        SetScene.dialog("cat", "This is where one of my pets sleeps. Pretty nice, eh?"),
        SetScene.dialog("cat", "I actually designed this room myself."),
        SetScene.changeCharacter("cat", "artAssets/cat6.png"),
        SetScene.dialog("cat", "I forget, have we gone to the park yet? I like the park!"),
        Screen.routeScreen("end", "yes, we have", "park", "not yet", "", "")
    ];

    Routes["Ночевка"] = [
        SetScene.changeCharacter("cat", "artAssets/cat4.png"),
        SetScene.dialog("cat", "I'll be watching you...:3"),
        SetScene.dialog("cat", "Let's go to the park."),
        SetScene.moveToRoute("park")
    ];

    Routes["Фестиваль"] = [
        SetScene.newBGwithMusic("artAssets/17.png", "audioAssets/112316happybgm.wav"),
        SetScene.showCharacter("Лена", "artAssets/Lena.png", "left", false),
        SetScene.showCharacter("Кристина","artAssets/Kris.png","right",false),
        SetScene.dialog("Кристина","Ну тогда в другой раз. "),
        SetScene.dialog("Лена","Ура! Тогда давайте встретимся у входа?"),
        SetScene.dialog("Кристина","Хорошо. А мы в юкатах же?"),
        SetScene.dialog("Лена","Не думаю, пойдём как обычно"),
        SetScene.backgroundClearChar("artAssets/56.png"),
        SetScene.newBGwithMusic("artAssets/56.png", "audioAssets/112316energeticbgm.wav"),
        SetScene.showCharacter("Лена", "artAssets/Lena.png", "right", true),
        SetScene.showCharacter("Кристина","artAssets/Kris.png","left",true),
        SetScene.dialog("","Среда, вечер, уже на фестивале"),
        SetScene.dialog("Лена","Тут столько разных вкусностей, глаза разбегаются."),
        SetScene.dialog("Богдан","Почему у вас руки ленточкой связаны?"),
        SetScene.dialog("Лена","Она постоянно теряется на фестивалях, или в толпе людей, поэтому я связываю руки ленточкой."),
        SetScene.dialog("Кристина","…"),
        SetScene.dialog("Богдан","Понятно."),
        SetScene.dialog("Лена","Пойдемте возьмем яблоки в карамели и будем искать место, откуда можно салют посмотреть? Он уже совсем скоро начнется."),
        
        Screen.routeScreen("end", "yes", "visitHouse", "no", "", "")
    ];

    Routes["end"] = [
        SetScene.showCharacter("cat", "artAssets/cat6.png", "left", false),
        SetScene.dialog("cat", "I take it you can find your way home? I'm glad to have met you, thanks for visiting!!"),
        SetScene.backgroundClearChar("artAssets/fin.png"),
        SetScene.background("artAssets/credits.png"),
        SetScene.background("artAssets/thankyou.png")
    ];
}