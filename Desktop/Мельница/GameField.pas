unit GameField;

{-------------------------------}

interface

{$region Uses}

uses 
  GraphABC, 
  GamePoint, 
  GameNode, 
  GameBorders, 
  GameMill, 
  GameTurn, 
  BlockFileOfT, 
  GameFieldInfo, 
  System.Threading.Tasks;

  {$endRegion Uses}

const
  //condAmount = 2282280 * 8;//Количество состояний для игры 6*6
  thingsAmount = 12;//Количество фишек у игроков изначально

type
  Field = class
  
  public
    currentTurnNumber: Integer = 0;
    name: String;
  
  private
    nodes: NodeArr;
    borderPoints: Borders;
    mills: MillArr;   
    things: FieldInfo = new FieldInfo(0, 0);
  
  {$region Constructors}
  
  public
  
    
  
    constructor create();
    begin
      borderPoints := new Borders;
      name := 'default_name';
    end;
    
    constructor create(fileName: String);
    begin
      borderPoints := new Borders;
      readField(fileName);
      name := fileName;
    end;
    
    constructor create(fileName: String; nName: String);
    begin
      borderPoints := new Borders;
      read(fileName);
      name := nName;
    end;
    
    constructor create(nNodes: NodeArr; nName: String);
    begin
      borderPoints := new Borders;
      nodes := nNodes;
      name := nName;
    end;
  
  {$endRegion Constructors}
    
  public
    //Процедуры:
    procedure show();//Вывод поля на экран
    procedure readField(fileName: String);//Чтение поля из файла
    procedure readGame(path: String);//Чтение записи игры из текстового файла
    procedure setScale(var coeff: Double);//Ручное ремасштабирование
    procedure setScale();//Автоматическое ремасштабирование
    procedure makeTurn(t: Turn; team: Integer := 0);//Ход
    //Функции:
    function findTurn(turnsDepth: Integer): Turn;//Поиск лучшего хода
    function checkLoss: Boolean;//Проверка на поражение
    function checkWin: Boolean;//Проверка на выигрыш
  
  private
    //Процедуры:
    procedure unhashField(h: int64);//Считывание поля из кода
    procedure reverseTurn(t: Turn);//Отмена хода
    procedure occupy(idx, team: Integer);//Постановка фишки
    //Функции:
    function hashField: int64;//Уникальный код поля    
    function hashTurn(t: Turn; team: Integer): Word;//Уникальный код хода
    function unhashTurn(h: Word): Turn;//Считывание хода из кода    
    function leave(idx: Integer): Integer;//Снятие фишки с доски, возвращает команду
    function checkThreatens(var team: Integer): Integer;//Возвращает id клетки с мельницей за 1 ход
    function checkConnection(idx1, idx2: Integer): Boolean;//Проверка существования связи между узлами
    function has2pretendents(idx: Integer): Boolean;//Претендуют ли на клетку обе команды
    function has3pretendents(idx, millers: Integer): Boolean;//Претендуют ли на клетку обе команды, где у millers уже что-то строится
    function checkNearBuildMill(team: Integer; observeMill: Mill): Integer;//Проверяет, близка ли мельница team к завершению, и возвращает индекс пустой клетки или -1
    function canOccupy(team, idx: Integer): List<Integer>;//Проверяем, можем ли занять клетку следующим ходом, возвращаем стартовые индексы или пустой лист
    function getThings(var team: Integer): List<Integer>;//Возвращает количество фишек команды
    function whereToPlaceNewAll: List<Turn>;//Выставление на поле фишки всеми способами
    function whereToPlaceNew(var team: Integer): List<Turn>;//Выставление на поле фишки с умом
    function whereToMoveAll(team: Integer): List<Turn>;//Ход фишки всеми способами
    function whereToMove(team: Integer): List<Turn>;//Ход фишки с умом
    function getRate(var team: Integer): Real;//Оценка текущей позиции
    function paths4teamAdvantage(team, opponent: Integer): Integer;//Возвращает преимущество в путях для team над opponent (оценочная)
    function paths4team(team: Integer): Integer;//Возвращает свободные пути для team
    function longToBytes(c: int64): List<Integer>;//Конвертируем значения счетчика на лету в хеш поля
    function predictRate(turnsDepth: Integer): Real;//Оценка поля через n ходов
    function getThingsAmount(team: Integer): Integer;//Возвращает количество фишек команды
    function wayExists(team: Integer): Boolean;//Есть ли свобода передвижения?
    //function getObviousTurn: Turn//Возвращает очевидный ход, если такой найдется
  end;

  {-------------------------------}

implementation

{$region ID/convert functions}

//private
function Field.longToBytes(c: int64): List<Integer>;//Конвертируем значения счетчика на лету в хеш поля
var
  bytes: Integer = nodes.Length div 5 + 1;
  d: int64 = power(256, bytes - 1).Round;
begin
  result := new List<Integer>;
  for var i := 0 to (bytes - 1) do
  begin
    result.Add(c div d);
    c := c mod d;
    d := d div 256;
  end;
end;

//private
function Field.hashField: int64;//Уникальный код поля
var
  nodeAmount: Integer := nodes.Length;
  multiplier: int64 = 1;
begin
  for var i := 0 to nodeAmount - 1 do//Каждый узел перекодируем
  begin
    var sum: int64 = 0;
    sum := nodes[i].team * multiplier;
    multiplier *= 3;
    result += sum;
  end;
end;

//private
procedure Field.unhashField(h: int64);//Считывание поля из кода
var
  nodeAmount: Integer := nodes.Length;
  multiplier: int64 = int64(BigInteger.Pow(3, nodeAmount - 1));
begin
  for var i := nodeAmount - 1 downto 0 do
  begin
    nodes[i].team := h div multiplier;
    h := h mod multiplier;
    multiplier := multiplier div 3;
  end;
end;

//private
function Field.hashTurn(t: Turn; team: Integer): Word;//Уникальный код хода
var
  nT: Turn := new Turn(-1);
  i: Integer;
  opponent: Integer = (team = 1 ? 2 : 1);
begin
  //15625 состояний -> 3400
  i := 0;
  while (i <= t.currentID) do
  begin
    if (nodes[i].team = team) then nT.currentID += 1;
    i += 1;
  end;
  
  i := 0;
  while (i <= t.takenID) do
  begin
    if (nodes[i].team = opponent) then nT.takenID += 1;
    i += 1;
  end;
  
  i := 0;
  while (true) do
  begin
    
  end;
  result := nT.currentID * nT.nextID * nT.takenID * team;
end;

//private
function Field.unhashTurn(h: Word): Turn;//Считывание хода из кода
var
  i: Integer;
begin
//  i := 0;
//  while (i <= t.currentID) do
//  begin
//  if (nodes[i].team = team) then nT.currentID += 1;
//  i+=1;
//  end;
//  
//  i := 0;
//  while (i <= t.takenID) do
//  begin
//  if (nodes[i].team = opponent) then nT.takenID += 1;
//  i+=1;
//  end;
//  
//  i := 0;
//  while (i <= t.nextID) do
//  begin
//  if (nodes[i].team = 0) then nT.nextID += 1;
//  i+=1;
//  end;
//  result:=nT;
end;

{$endRegion ID/convert functions}

{$region Turns}

//private
function Field.findTurn(turnsDepth: Integer): Turn;//Поиск хода для текущей команды
var
  turns: List<Turn>;
  newTurn: Turn;
  currTeam: Integer := currentTurnNumber mod 2 + 1;
  quality: Real := Real.MinValue;//Качество лучшего хода
  rate: Real;
begin
  if (currentTurnNumber < thingsAmount * 2) then
    turns := whereToPlaceNew(currTeam)
  else turns := whereToMove(currTeam);
  
  foreach var t in turns do
  begin
    makeTurn(t, currTeam);
    rate := predictRate(turnsDepth * 2 + 1);//Предсказываем последствия (для себя)
    if (rate > quality) then 
    begin
      quality := rate;
      result := new Turn(t);
    end;
    reverseTurn(t);
  end;
end;

//private
procedure Field.makeTurn(t: Turn; team: Integer);//Ход
var
  opponent := (team = 1 ? 2 : 1);
begin
  if (t.currentID <> -1) then team := leave(t.currentID) else things.add(team);
  if (t.takenID <> -1) then
  begin
    leave(t.takenID);
    things.remove(opponent);
  end;
  occupy(t.nextID, team);
  currentTurnNumber += 1;
end;

//private
procedure Field.reverseTurn(t: Turn);//Отмена хода
var
  team, opponent: Integer;
begin
  team := leave(t.nextID);
  opponent := (team = 1 ? 2 : 1);
  if (t.takenID <> -1) then 
  begin
    occupy(t.takenID, opponent);
    things.add(opponent);
  end;
  if (t.currentID <> -1) then occupy(t.currentID, team) else things.remove(team);
  currentTurnNumber -= 1;
end;

//private
procedure Field.occupy(idx, team: Integer);//Постановка фишки
begin
  nodes[idx].team := team;
end;

//private
function Field.leave(idx: Integer): Integer;//Снятие фишки с доски
begin
  result := nodes[idx].team;
  nodes[idx].team := 0;
end;

{$endRegion Turns}

{$region Graphics}

//public
procedure Field.setScale();//Автоматическое ремасштабирование
begin
  borderPoints.setScale();
end;

//public
procedure Field.setScale(var coeff: Double);//Ручное ремасштабирование
begin
  borderPoints.setScale(coeff);
end;

//public
procedure Field.show();//Вывод поля на экран
var
  currPoint, linkedPoint: Point;
begin
  Window.Clear;
  for var i := 0 to (nodes.Length - 1) do
  begin
    var node := nodes[i];
    currPoint := node.placement;
    foreach var linkedNode in node.linkedNodes do
    begin
      linkedPoint := nodes[linkedNode].placement;
      currPoint.line(linkedPoint, borderPoints.centerAlignOffset, borderPoints.minPoint, borderPoints.scale);
      if (node.team <> 0) then currPoint.markOccupied(borderPoints.centerAlignOffset, borderPoints.minPoint, borderPoints.scale, node.team);//Если клетка занята, отмечаем ее цветом команды на экране
      currPoint.subscribeIdx(i, borderPoints.centerAlignOffset, borderPoints.minPoint, borderPoints.scale);
    end;
  end;
end;

{$endRegion Graphics}

{$region IO}

//public
procedure Field.readField(fileName: String);//Чтение поля из файла
var
  t: text;
  i, x, y, snap: Integer;
  snaps: array of array of Integer;
  newPoint: Point;
  lines := ReadAllLines(fileName + '.txt');
begin
  var line := lines[0];
  repeat
    begin
      SetLength(snaps, i + 1);
      SetLength(nodes, i + 1);
      var info := line.RegexReplace('[a-z]+: *', '').Split(' ');
      {$omp parallel sections}
      begin
        i := info[0].ToInteger;
        x := info[1].ToInteger;
        y := info[2].ToInteger;
      end;
      setLength(snaps[i], info.Length - 3);
      for var j := 3 to (info.Length - 1) do//Перебираем индексы связанных с текущей точек
      begin
        snap := info[j].ToInteger;
        snaps[i][j - 3] := snap;//Заполняем массив связей
      end;
      newPoint := new Point(x, y);
      borderPoints.checkPoint(newPoint);//Ремасштабирование
      nodes[i] := new Node(newPoint);
      nodes[i].linkedNodes := snaps[i];
      writeln(snaps[i]);
      i += 1;
      line := lines[i];
    end;
  until (line = 'mills:');//Пока не доберемся до перечисления позиций для мельниц
  
  var length := Lines.Length;
  SetLength(mills, length - i - 1);
  for var j := i + 1 to length - 1 do
  begin
    line := lines[j];
    mills[j - i - 1] := new Mill(line);
  end;
end;

//public
procedure Field.readGame(path: String);//Чтение записи игры из текстового файла
begin
  
end;

{$endRegion IO}

{$region Field info}

//private
function Field.getThings(var team: Integer): List<Integer>;//Возвращает фишки команды
var
  i: Integer := 0;
  toFind: Integer = things.getElements(team);
begin
  result := new List<Integer>;
  while (result.Count < toFind) do
  begin
    if (nodes[i].team = team) then 
      result.Add(i);
    i += 1;
  end;
end;

//private
function Field.paths4teamAdvantage(team, opponent: Integer): Integer;//Возвращает преимущество в путях для team над opponent
begin
  foreach var n in nodes do//Для всех клеток команды
  begin
    if (n.team = 0) then
      foreach var p in n.linkedNodes do//Суммируем возможные ходы
      begin
        var t := nodes[p].team;
        if 
        (t = team) then result += 1
        else 
        if (t = opponent) then result -= 1;
      end
  end
end;

//private
function Field.whereToPlaceNewAll: List<Turn>;//Перебор простых ходов (напрямую не вызывать!)
begin
  result := new List<Turn>;
  for var j := 0 to (nodes.Length - 1) do
    if (nodes[j].team = 0) then 
      result.Add(new Turn(j)); 
end;

//private
function Field.whereToPlaceNew(var team: Integer): List<Turn>;//Выставление на поле фишки с умом
var
  check: Integer;
  thingsToGet: List<Integer>;
  opponent: Integer := ((team = 1) ? 2 : 1);
begin
  result := new List<Turn>;
  
  //Можем ли построить мельницу?
  foreach var m in mills do
  begin
    check := checkNearBuildMill(team, m);
    if (check <> -1) then
    begin
      thingsToGet := getThings(opponent);
      foreach var t in thingsToGet do//Какую белую фишку возьмем?
        result.Add(new Turn(-1, check, t));
    end;
  end;
  
  //Можем ли помешать построить мельницу?
  if (result.Count = 0) then
    foreach var m in mills do
    begin
      check := checkNearBuildMill(opponent, m);
      if (check <> -1) then
        result.add(new Turn(check));
    end;
  
  //Выбираем, куда вообще можем сходить, если все плохо
  if (result.Count = 0) then
    result := whereToPlaceNewAll;
end;

//private
function Field.whereToMoveAll(team: Integer): List<Turn>;//Все возможные ходы (напрямую не вызывать!)
var
  thingsToGet: List<Integer>;
  check: Integer;
  startNodes: List<Integer>;
begin
  startNodes := new List<Integer>;
  result := new List<Turn>;
  for var i := 0 to (nodes.Length - 1) do
    if (nodes[i].team = 0) then
    begin
      startNodes := (things.getElements(team) = 3 ? getThings(team) : canOccupy(team, i));//Откуда можем ходить?
      foreach var n in startNodes do
        result.Add(new Turn(n, i, -1)); 
    end;
end;

//private
function Field.whereToMove(team: Integer): List<Turn>;//Все умные ходы для team
var
  thingsToGet: List<Integer>;
  startNodes: List<Integer>;
  opponent: Integer := (team = 1 ? 2 : 1);
  things: Integer := things.getElements(team);
begin
  result := new List<Turn>;
  
  //Можем ли построить мельницу?
  foreach var m in mills do//Смотрим на все мельницы
  begin
    var check := checkNearBuildMill(team, m);
    if (check <> -1) then//Если мельница почти достроена
    begin
      startNodes := (things = 3 ? getThings(team) : canOccupy(team, check));//Смотрим, откуда можем достроить мельницу
      foreach var n in startNodes do//Для каждого хода постройки мельницы
        if (not m.hasElement(n)) then//Не ломаем мельницу для ее же постройки!
        begin
          thingsToGet := getThings(opponent);//Смотрим, какие фишки можем забрать
          foreach var t in thingsToGet do//Какую фишку возьмем?
            result.Add(new Turn(n, check, t));//Идем из старта строить мельницу, забираем фишку
        end;
    end;
  end;
  
  //Выбираем, куда вообще можем сходить, если все плохо
  if (result.Count = 0) then
    result := whereToMoveAll(team);
end;

//private
function Field.has2pretendents(idx: Integer): Boolean;//Проверяем, претендуют ли на клетку обе команды
var
  t1: Boolean = false;
  t2: Boolean = false;
begin
  foreach var n in nodes[idx].linkedNodes do//Обходим соседей и ищем претендентов
  begin
    if (nodes[n].team = 1) then t1 := true else
    if (nodes[n].team = 2) then t2 := true;
  end;
  result := (t1 and t2);
end;

//private
function Field.has3pretendents(idx, millers: Integer): Boolean;//Проверяем, претендуют ли на клетку обе команды, где у millers уже что-то строится
var
  t1: Boolean = false;
  t2: Integer;
begin
  foreach var n in nodes[idx].linkedNodes do//Обходим соседей и ищем претендентов
  begin
    if (nodes[n].team <> 0) then 
      if (nodes[n].team = millers) then t2 += 1 else t1 := true;
  end;
  result := t1 and (t2 >= 2);
end;

//private
function Field.canOccupy(team, idx: Integer): List<Integer>;//Проверяем, можем ли занять клетку следующим ходом, возвращаем стартовые индексы или пустой лист
begin
  result := new List<Integer>;
  foreach var n in nodes[idx].linkedNodes do
    if (nodes[n].team = team) then result.Add(n);
end;

//private
function Field.checkNearBuildMill(team: Integer; observeMill: Mill): Integer;//Проверяет, близка ли мельница team к завершению, и возвращает индекс пустой клетки или -1
var
  busy: Integer;
begin
  result := -1;
  foreach var m in observeMill.elements do
  begin
    if (nodes[m].team = team) then busy += 1 else
    if (nodes[m].team = 0) then result := m;
  end;
  if (busy <> 2) then result := -1;
end;

//private
function Field.checkThreatens(var team: Integer): Integer;//Возвращает id клетки с будущей мельницей team, которую можем заруинить, или -1
var
  i, idx, l: Integer;
begin
  l := mills.Length;
  result := -1;
  repeat
    begin
      idx := checkNearBuildMill(team, mills[i]);
      if (idx <> -1) and (has3pretendents(idx, team)) then result := idx;
      i += 1;
    end;
  until (i = l) or (result <> -1);//Ищем, пока не найдем или не обойдем все
end;

//private
function Field.getThingsAmount(team: Integer): Integer;//Возвращает количество фишек команды
begin
  result := 0;
  foreach var n in nodes do
    if (n.team = team) then result += 1;
end;

//public
function Field.checkWin: Boolean;
begin
  
end;

//private
function Field.paths4team(team: Integer): Integer;//Возвращает свободные пути для team
begin
  foreach var n in nodes do//Для всех клеток команды
    if (n.team = team) then
      foreach var p in n.linkedNodes do//Суммируем возможные ходы
        if (nodes[p].team = 0) then result += 1;
end;

//private
function Field.wayExists(team: Integer): Boolean;//Есть ли свобода передвижения?
var
  i, j: Integer;
begin
  result := false;
  while (not result) and (i < nodes.Length) do
  begin
    var n: Node := nodes[i];
    if (n.team = team) then 
      while (not result) and (j < n.linkedNodes.Length) do
      begin
        result := (n.team = 0);
        j += 1;
      end;
    i += 1;
  end;
end;

//public
function Field.checkLoss: Boolean :=
(getThingsAmount(1) = 2) 
or (getThingsAmount(2) = 2) 
or (not wayExists(1))
or (not wayExists(2));

//private
function Field.checkConnection(idx1, idx2: Integer): Boolean;//Проверка существования связи между узлами
begin
  result := false;
  foreach var i in nodes[idx1].linkedNodes do
    if (i = idx2) then result := true;
end;

{$endRegion Field info}

{$region MinMax}

//private
function Field.predictRate(turnsDepth: Integer): Real;//Вызывать только от нечетного количества ходов
var
  turns: List<Turn>;
  currTeam: Integer := currentTurnNumber mod 2 + 1;
  quality: Real := Real.MinValue;//Качество лучшего хода
  rate: Real;
  getLower: Boolean := turnsDepth mod 2 = 1;
begin
  if (currentTurnNumber < thingsAmount * 2) then
    turns := whereToPlaceNew(currTeam)
  else turns := whereToMove(currTeam);
  
  result := (getLower ? Real.MaxValue : Real.MinValue);//Рейтинг текущего хода. Минимакс
  
  if (turnsDepth = 0) then//Завершение рекурсии
    foreach var t in turns do//Для всех возможных ходов оцениваем последствия
    begin
      makeTurn(t, currTeam);
      rate := getRate(currTeam);
      if (result < rate) then result := getRate(currTeam);//И возвращаем лучший положительный результат
      reverseTurn(t);
    end
  else
  begin
    foreach var t in turns do//Для каждого возможного хода
    begin
      makeTurn(t, currTeam);
      if (things.getElements(currTeam mod 2 + 1) <= 2) and (currentTurnNumber > thingsAmount * 2)//Если фигур у оппонента не осталось, то выдаем максимальную оценку текущему игроку и не считаем дальше (опт.)
        then result := (getLower ? Real.MinValue : Real.MaxValue)
      else 
      begin
        quality := predictRate(turnsDepth - 1);//Предсказываем его последствия
        if ((getLower) ? (result > quality) : (result < quality)) 
          then result := quality;//И возвращаем лучший/худший результат
      end;
      reverseTurn(t);
    end;
  end;
end;

//private
function Field.getRate(var team: Integer): Real;//Оценка позиции
var
  difference: Integer;
  opponent: Integer := (team = 1 ? 2 : 1);
  ways: Integer := paths4teamAdvantage(team, opponent);
begin
  difference := things.getDifference(team, opponent);
  result := (difference + ways / 10) * 10 / (currentTurnNumber + 10);//Примерная оценка свободы хода. Для ранних ходов выше
  if (ways = 0) then result := Integer.MinValue;
end;

{$endRegion MinMax}

{---------------------------------}

begin
end. 