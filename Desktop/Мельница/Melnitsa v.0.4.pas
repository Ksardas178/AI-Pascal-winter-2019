{$region Uses}

uses 
  GraphABC,
  GameField,
  GameTurn;

{$endRegion Uses}

var
  field_1: Field;
  t: Turn;
  team: Integer = 1;
  startID, finishID, eatenID: Integer;

begin
  
  {$region Prepairing field}
  
  Window.Maximize;
  window.Caption := 'Мельница';
  LockDrawing;
  
  field_1 := new Field('field_3');
  field_1.setScale();
  
  field_1.show;
  redraw;
  
  {$endRegion Prepairing field}
  
  {$region Game Cycle}
  
  while (true) do
  begin
    if (team = 2) then 
    begin
      case (field_1.currentTurnNumber) of
        0, 1: t := field_1.findTurn(1);
      else t := field_1.findTurn(2);
      end;
    end
      else
    begin
      try
        read(startID, finishID, eatenID);
        t := new Turn(startID, finishID, eatenID);
      except
        read(startID, finishID, eatenID);
        t := new Turn(startID, finishID, eatenID);
      end;
    end;
    //Ход
    field_1.makeTurn(t, team);
    field_1.show;
    Redraw;
    team := (team = 1 ? 2 : 1);//Меняем команду
  end;
  
  {$endRegion Game Cycle}
  
end.