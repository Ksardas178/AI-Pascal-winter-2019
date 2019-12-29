uses GraphABC;
uses GameField;
uses GameTurn;

var
  field_1: Field;
  t: Turn;
  team: byte = 1;
  a, b, c: shortint;

begin
  
  Window.Maximize;
  window.Caption := 'Мельница';
  LockDrawing;
  
  field_1 := new Field('field_3');
  field_1.setScale();
  
  {field_1.makeTurn(new Turn(-1,1,-1),1);
  field_1.makeTurn(new Turn(-1,2,-1),1);
  field_1.makeTurn(new Turn(-1,4,-1),1);
  field_1.makeTurn(new Turn(-1,6,-1),1);  
  field_1.makeTurn(new Turn(-1,7,-1),1); 
  field_1.makeTurn(new Turn(-1,8,-1),1);
  field_1.makeTurn(new Turn(-1,3,-1),2);
  field_1.makeTurn(new Turn(-1,5,-1),2);
  field_1.makeTurn(new Turn(-1,15,-1),2);
  
  t:=field_1.findTurn(0);
  field_1.makeTurn(t);}
  
  field_1.show;
  redraw;
  
  while (true) do
  begin
    if (team = 2) then 
    begin
      case (field_1.currentTurnNumber) of
        0, 1: t := field_1.findTurn(1);
        2, 3: t := field_1.findTurn(2);
        //4, 5: t := field_1.findTurn(2);
      else t := field_1.findTurn(2);
      end;
    end
      else
    begin
      try
        read(a, b, c);
        t := new Turn(a, b, c);
      except
        read(a, b, c);
        t := new Turn(a, b, c);
      end;
    end;
    //Ход
    field_1.makeTurn(t, team);
    field_1.show;
    
    textOut(100, 100, field_1.things.getElements(1));
    textOut(110, 100, field_1.things.getElements(2));
    Redraw;
    team := (team = 1 ? 2 : 1);//Меняем команду
  end;
end.