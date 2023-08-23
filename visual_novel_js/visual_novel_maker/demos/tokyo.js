if(window.speechSynthesis){
    
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
    Game.character("Друг", '#000', (voices ? david : null));
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
        SetScene.showCharacter("Ника","artAssets/Nika.png","left",false),
        SetScene.showCharacter("Ева","artAssets/Eva.png","right",false),
        SetScene.dialog("Ника","Отлично! Представлюсь, меня зовут Ника, вторую девушку зовут Евой. "),
        SetScene.dialog("Ева","Привет. Тебя то как зовут?"),
        SetScene.dialog("Богдан","Богдан."),
        SetScene.dialog("Ника","Хорошо, будем знакомы. Как насчет сходить в караоке, или кафешку какую после школы?"),
        Screen.routeScreen("Гулять", "согласиться погулять", "Уроки", "отказатья и пойти делать домашку", "", "")
    ];

    Routes["Уроки"]=[
        false,
        SetScene.dialog("Ева","Ника прям тут сейчас расплачется, хах."),
        SetScene.dialog("Ника","Не расплачусь я тут сейчас! Не при нем…"),
        SetScene.dialog("Богдан","Правда, простите, я все еще не разобрал большую часть коробок. На выходных, думаю, можно будет прогуляться."),
        SetScene.backgroundClearChar("artAssets/49.png"),
        SetScene.newBGwithMusic("artAssets/49.png", "audioAssets/112316happybgm.wav"),
        SetScene.dialog("","Понедельник, вечер, комната Богдана"),
        SetScene.dialog("Богдан","Мне и правда надо очень много разобрать, слишком много у меня вещей… Все разбираю, разбираю, разбираю и разбираю, а коробок меньше будто не становится. Да еще и мама задерживается на работе. Тут через дорогу есть забегаловка, схожу туда покушать."),
        SetScene.background("artAssets/7.png"),
        SetScene.dialog("Богдан","Повезло, народа нет. Я очень устал, так что сильно проголодался, надеюсь еда здесь вкусная и качественная. "),
        SetScene.dialog("Богдан","Тут довольно вкусная еда, надо будет сказать маме об этом месте."),
        SetScene.showCharacter("Ника","artAssets/Nika.png","right",true),
        SetScene.dialog("Ника","Богдан? Вот так встреча! Тоже ходишь сюда?"),
        SetScene.dialog("Богдан","Привет, нет, первый раз зашел пока разбирал вещи, проголодался, а мама задерживается на работе, так что пришлось сходить сюда. Но мне понравилась еда тут, может буду заглядывать сюда."),
        SetScene.dialog("Ника","Это просто обалденное место, мне так нравится еда отсюда! Рада, что и тебе тоже понравилось. Кстати, в школе я не спросила твой номер, может дашь сейчас? Мы ж теперь друзья, буду писать тебе! Может даже будем ходить сюда ужинать вместе!"),
        SetScene.dialog("Богдан","Хорошо, записывай."),
        SetScene.backgroundClearChar("artAssets/55.png"),
        SetScene.dialog("Богдан","(настоящее) Тот мужик выбежал так резко, что сбил меня и Нику с ног. А следом еще и прилетел тапок владельца той забегаловки. Кажется, после того случая алкоголь там больше не продавали."),
        SetScene.dialog("Друг","А что в итоге то? Того мужика поймали и заставили расплатиться, или он так и не попался?"),
        SetScene.dialog("Богдан","Честно, я не знаю. "),
    ];

    Routes["Гулять"]=[
        false,
        SetScene.dialog("Ника","Ура! Пройдемся по моим любимым местам и закончим прогулку моей любимой забегаловкой! Тебе точно понравится."),
        SetScene.dialog("Ева","Тогда после уроков по домам, переодеться, и встретимся около тц. Ты же уже знаешь где тц?"),
        SetScene.dialog("Богдан","Найдусь."),
        SetScene.backgroundClearChar("artAssets/23.png"),
        SetScene.newBGwithMusic("artAssets/23.png", "audioAssets/112316happybgm.wav"),
        SetScene.dialog("","Понедельник, день, около тц "),
        SetScene.showCharacter("Ника","artAssets/Nika.png","left",false),
        SetScene.showCharacter("Ева","artAssets/Eva.png","right",false),
        SetScene.dialog("Ника","Давно стоишь тут? Я все не могла решить что же мне надеть!"),
        SetScene.dialog("Ева:","На самом деле она просто не могла найти телефон, который бел у нее в кармане, и ключи от дома, которые лежали в школьной сумке."),
        SetScene.dialog("Ника","А ну цыц, не сдавай меня!"),
        SetScene.dialog("Богдан","Я совсем недавно пришел, все хорошо."),
        SetScene.dialog("Ника","Хорошо, тогда пошли! Зайдем сначала в магазин сладостей, мой любимый кстати, а потом сходим в самый центр к фонтану, там съедим вкусняшки, потом сходим в магазин мягких игрушек, давно я там не была, а потом…"),
        SetScene.dialog("Ева","Пока остановимся на этом, а то не успеем сходить поужинать."),
        SetScene.dialog("Богдан","Соглашусь с Евой."),
        SetScene.dialog("Ника","Ну хорошо, но тогда вместо магазина игрушек сходим в магазин дисков с разными играми, может какие новые игры в продажу вышли!"),
        SetScene.dialog("Богдан","О, я за, я давно ни во что не играл, а хочется. "),
        SetScene.background("artAssets/7.png"),
        SetScene.dialog("Ника","Я так сильно хочу есть, что сил нет идти!"),
        SetScene.dialog("Ева","Потерпи, тут сегодня пусто, так что поедим сидя. Осталось пройти пару шагов."),
        SetScene.dialog("Богдан","Ты сможешь, давай!"),
        SetScene.backgroundClearChar("artAssets/55.png"),
        SetScene.dialog("Богдан","(настоящее) Тогда и правда было тихо и пусто около той забегаловки, я подумал что это нормально, но когда мы зашли… Так вышло случайно, что мы стали свидетелями преступления, но, к счастью, владельца удалось спасти. Я поздно вернулся домой, всех очень долго допрашивали, я даже подумал, что пока дойдет очередь до нас, уже будет за полночь. И мы так и не смогли покушать, так жаль. Там вкусно пахло, я проголодался еще больше, а когда пришел домой, съел еду, даже не погрев ее. Настолько я был голоден."),
        SetScene.dialog("Друг","Не повезло тебе тогда. Испугался, когда увидел покалеченного владельца?"),
        SetScene.dialog("Богдан","Да, но не там сильно, чтоб прям в обморок, как в фильмах. "),
        SetScene.moveToRoute("end")
    ];

    Routes["Ночевка"] = [
        false,
        SetScene.newBGwithMusic("artAssets/17.png", "audioAssets/112316happybgm.wav"),
        SetScene.dialog("Кристина","Хорошо, тогда скажи,  что ты любишь есть, я постараюсь приготовить."),
        SetScene.dialog("Богдан","Тайяки, если из сладкого. И такояки  тоже люблю."),
        SetScene.dialog("Лена","Я тоже люблю тайяки! А с каким вкусом ты любишь?"),
        SetScene.dialog("Богдан","С кремом."),
        SetScene.dialog("Лена","Тут не совпали наши вкусы."),
        SetScene.dialog("Кристина","Приготовлю тогда и то и то. И тайяки и такояки."),
        SetScene.backgroundClearChar("asrAssets/72.png"),
        SetScene.dialog("","Среда, вечер, дома у Критины"),
        SetScene.showCharacter("Лена", "artAssets/Lena.png", "left", false),
        SetScene.showCharacter("Кристина","artAssets/Kris.png","right",false),
        SetScene.dialog("Лена","А давайте какой-нибудь фильм посмотрим? "),
        SetScene.dialog("Богдан","Ужастик. Так интересней."),
        SetScene.dialog("Кристина","О. я только за. У меня много фильмов есть на примете. "),
        SetScene.dialog("Лена","Богдан, ты сказал то, чего я боялась услышать…"),
        SetScene.dialog("Кристина","Она боится смотреть ужастики, особенно на ночь глядя. "),
        SetScene.dialog("Лена","Точно! Скоро ж салют будет, надеюсь его видно будет с окна."),
        SetScene.dialog("Богдан","Было бы очень круто, люблю салюты издалека смотреть. Вблизи слишком громко и ярко."),
        SetScene.dialog("Кристина","Может выйдем на улицу и посмотрим оттуда? Можно еще постелить там плед и съесть все вкусняшки там."),
        Screen.routeScreen("Улица", "пойти на улицу", "Дома", "остаться дома", "", "")
    ];

    Routes["Дома"] = [
        false,
        SetScene.dialog("Кристина","пойду тогда еду принесу."),
        SetScene.dialog("Лена","А давайте после фейерверков построим из одеял и подушек шалаш, Кас, у тебя осталась гирлянда же?"),
        SetScene.dialog("Кристина","Возьми в шкафу."),
        SetScene.dialog("Богдан","Уже начали салют запускать."),
        SetScene.dialog("Лена","Да? Где? Красивый! Красивей, чем в прошлом году!"),
        SetScene.dialog("Кристина","По мне, они все всегда одинаковые, только порядок цветов меняется."),
        SetScene.dialog("Лена","Не правда! Ты просто не замечаешь. "),
        SetScene.dialog("Богдан","Не знаю, какой был у вас тут в прошлом году фейерверк, но он в сто раз лучше, чем запускали в городе, где я жил раньше."),
        SetScene.dialog("","Среда, вечер, фейерверки закончились, шалаш уже был построен и обустроен"),
        SetScene.dialog("Лена","Давайте лучше посмотрим какую-нибудь комедию, а не ужастик?"),
        SetScene.dialog("Кристина","Нет, так неинтересно будет."),
        SetScene.dialog("Богдан","Поддерживаю. "),
        SetScene.dialog("Лена","Не поддерживай ее!"),
        SetScene.dialog("Богдан","Очень вкусная еда, кстати."),
        SetScene.dialog("Кристина","Спасибо, меня Лена учила готовить."),
        SetScene.dialog("Богдан","Круто. "),
        SetScene.backgroundClearChar("artAssets/55.png"),
        SetScene.dialog("Богдан","(настоящее) Кристина тогда уснула на середине фильма, а Лене удалось уговорить меня не досматривать фильм. За это Лена мне приготовила какао и после мы легли спать."),
        SetScene.dialog("Друг","А с Кристиной что было? Она так и осталась спать в домике?"),
        SetScene.dialog("Богдан","Да. Она так мило спала, что мы решили ее оставить как есть. Утром мы этот домик разобрались и разошлись по домам. "),
        SetScene.moveToRoute("end")
    ];

    Routes["Улица"] = [
        false,
        SetScene.dialog("Кристина","Тогда я пойду возьму еду. Лена, достанешь плед из шкафа?"),
        SetScene.dialog("Лена","Хорошо."),
        SetScene.newBGwithMusic("artAssets/10.png", "audioAssets/112316energeticbgm.wav"),
        SetScene.dialog("","Среда, вечер, перед домом Кристины "),
        SetScene.dialog("Богдан","Пахнет очень вкусно."),
        SetScene.dialog("Лена","Кристина вкусно готовит, потому что я ее учила."),
        SetScene.dialog("Богдан","(уже съев один тайяки): Очень вкусно!"),
        SetScene.dialog("Лена","Смотрите! Началось! "),
        SetScene.dialog("Богдан","Красиво. Завораживает, аж мурашки по коже пошли."),
        SetScene.backgroundClearChar("artAssets/55.png"),
        SetScene.dialog("Богдан","(настоящее) Мы просидели там часов до 11 вечера, а потом пошли в дом, холодно стало. "),
        SetScene.dialog("Друг","И что? Спать легли?"),
        SetScene.dialog("Богдан","Нет, спать мы легли уже под утро, мы и правда посмотрели ужастик, потом посмотрели аниме. Когда первый собрались спать, то все вышло в драку подушками, пока пытались постелить. Они меня уделали, но были бы они не девушками, я бы их закопал в подушках."),
        SetScene.dialog("Друг","Весело было в общем, да?"),
        SetScene.dialog("Богдан","Очень. После того, как побесились, Кристина предложила еще пойти поесть. В итоге, мы ели часа два и пошли спать. В этот раз мы и правда легли. Я быстро вырубился. "),
        SetScene.moveToRoute("end")
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
        SetScene.backgroundClearChar("artAssets/56.png"),
        SetScene.showCharacter("Лена", "artAssets/Lena.png", "left", false),
        SetScene.dialog("","Пока мы шли к палатке с яблоками в карамели, ленточка развязалась и Кристина потерялась. Лена, видимо, привыкла к тому, что она теряется, а потому лишь вздохнула. Фейерверки мы смотрели без Кристины."),
        SetScene.backgroundClearChar("artAssets/55.png"),
        SetScene.dialog("Друг","(настоящее) А нашли потом Кристину то? Или уже только в школе встретились?"),
        SetScene.dialog("Богдан","Нет, мы ее нашли, когда толпа разошлась уже. Она стояла у входа. "),
        SetScene.moveToRoute("end")
    ];

    Routes["end"] = [
        SetScene.backgroundClearChar("artAssets/fin.png"),
        SetScene.background("artAssets/thankyou.png")
    ];
}