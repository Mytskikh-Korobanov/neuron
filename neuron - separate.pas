program neuron_separate;

uses GraphABC;

const
  N_Max = 50; // количество итераций обучения
  n = 0.3; // коэффициент скорости обучения

var
  ans: real; // ответ
  input: array [1..3] of real; // входной вектор
  value: array [1..3] of real; // веса входов
  pr_value: array [1..3] of real; // предыдущие веса входов
  i, j, p: {integer} longint; // счётчики
  dvalue: array [1..3] of real; // вектор коррекции весов
  d: real; // ошибка обучения
  pr_d: real; // предыдущая ошибка обучения
  e0: real; // допустимая погрешность
  stop: boolean; // критерий остановки
  filout: text;

function sigmoid(x: real): real;
begin
  sigmoid := 1 / (1 + exp(-1 * x));
end;

procedure calculate;
{процедура получения решения нейрона}
var
  sum: real;
  i: integer;
begin
  sum := 0;
  for i := 1 to 3 do
    sum := sum + input[i] * value[i];
  ans := sigmoid(sum);
end;

begin
  assign(filout, 'log.out');
  rewrite(filout);
  
  // настройка графического окна
  SetWindowSize(400, 400); // размер графического окна 
  Pen.Color := clCoral; 
  SetPenStyle(psDash);
  Window.Title := 'Пример обучения искусственного нейрона';
  // вывод координатной сетки
  var count{счётчик}: integer := 10;
  while (count <= 400) do
  begin
    Line(count, 0, count, 400);
    Line(0, count, 400, count);
    count += 10;
  end;
  
  // ввод исходных данных
  var input_vector: array [1..20] of array of real; // вектор обучающих данных
  var res: array [1..20] of integer; // эталонные решения
  var x_1, y_1: integer; // координаты первой красной точки
  x_1 := random(21) - 10;
  y_1 := random(21) - 10;
  for var count2: integer := 1 to 10 do
  begin
    setlength(input_vector[count2], 2);
    input_vector[count2][0] := (x_1 + (random(5) - 2)) / 20;
    input_vector[count2][1] := (y_1 + (random(5) - 2)) / 20;
    res[count2] := 0;
    if (res[count2] = 0) then SetBrushColor(clRed) // 0 -> красный; 1 -> синий
      else SetBrushColor(clBlue);
    FillCircle((round(20*input_vector[count2][0])+20)*10, (round(20*input_vector[count2][1])+20)*10, 3);
  end;
  var x_2, y_2: integer; // координаты первой синей точки
  repeat
    x_2 := random(21) - 10;
    y_2 := random(21) - 10;
  until
    ((abs(x_2 - x_1)>7) and (abs(y_2 - y_1)>7));
  for var count2: integer := 11 to 20 do
  begin
    setlength(input_vector[count2], 2);
    input_vector[count2][0] := (x_2 + (random(5) - 2)) / 20;
    input_vector[count2][1] := (y_2 + (random(5) - 2)) / 20;
    res[count2] := 1;
    if (res[count2] = 0) then SetBrushColor(clRed) // 0 -> красный; 1 -> синий
      else SetBrushColor(clBlue);
    FillCircle((round(20*input_vector[count2][0])+20)*10, (round(20*input_vector[count2][1])+20)*10, 3);
  end;

  // инициализация весов
  for i := 1 to 3 do
    value[i] := random;
  // обучение
  p := 0;
  e0 := 0.02;
  stop := true;
  repeat
    for i := 1 to 3 do
      dvalue[i] := 0;
    for j := 1 to 20 do
    begin
      input[1] := 1;
      input[2] := input_vector[j][0];
      input[3] := input_vector[j][1];
      calculate;
      for i := 1 to 3 do
        dvalue[i] := dvalue[i] + n * ans * (1 - ans) * (res[j] - ans) * input[i];
    end;
    for i := 1 to 3 do
      pr_value[i] := value[i];
    for i := 1 to 3 do
      value[i] := value[i] + dvalue[i];
    pr_d := d;
    d := 0;
    for j := 1 to 20 do
    begin
      input[1] := 1;
      input[2] := input_vector[j][0];
      input[3] := input_vector[j][1];
      calculate;
      d := d + sqr(res[j] - ans);
    end;
    d := d / 2;
    p := p + 1;
    stop := (d <= e0) or (p >= N_Max);
    if p > 1 then stop := stop or (d >= pr_d);
    if not(stop) or (p = N_Max) then writeln(filout, d: 14: 10);
    if (d >= pr_d) and (p > 1)
      then
      begin
        for i := 1 to 3 do
        value[i] := pr_value[i];
      end; 
  until
    stop;
  
  // вывод результата
  var decision{коэффициенты веса входных значений}: array [1..3] of real;
  for i := 1 to 3 do
    decision[i] := value[i];
  var fst{найдена ли первая точка прямой}: boolean := false;
  var count5{счётчик}: integer := -20;
  var x1, y1, x2, y2: integer; // координаты крайних точек прямой
  var k, m: real; // коэффициенты уравнения прямой: y = k*x + m
  k := decision[2] / decision[3];
  m := decision[1] / decision[3];
  while (count5<=20) and (count5>=-20) and (not (fst)) do
  begin
    if ((20*((count5 / 20)*k + m) )>=-20) and ((20*((count5 / 20)*k + m) )<=20)
      then
      begin
        x1 := count5;
        y1 := round(20*((count5 / 20)*k + m));
        fst := true;
      end;
    inc(count5);
  end;
  while (count5<=20) do
  begin
    if ((20*((count5 / 20)*k + m))>=-20) and ((20*((count5 / 20)*k + m))<=20)
      then
      begin
        x2 := count5;
        y2 := round(20*((count5 / 20)*k + m));
      end;
    inc(count5);
  end;
  Pen.Color := clBlack;
  x1 := (x1 + 20)*10;
  x2 := (x2 + 20)*10;
  y1 := ((-1*y1) + 20)*10;
  y2 := ((-1*y2) + 20)*10;
  line(x1, y1, x2, y2);
  
  close(filout);
end.