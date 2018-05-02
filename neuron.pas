program neuron;

const
  N_Max = 100; // количество итераций обучения
  n = 0.45; // коэффициент скорости обучения

var
  ans: real; // ответ
  input: array [1..3] of real; // входной вектор
  value: array [1..3] of real; // веса входов
  i, j, p: integer; // счётчики
  dvalue: array [1..3] of real; // вектор коррекции весов
  // ввод исходных данных
  input_data: array [1..4, 1..3] of real := ((0, 0, 1), (1, 1, 1), (1, 0, 1), (0, 1, 1)); // обучающая выборка
  res: array [1..4] of real := (0, 1, 1, 1);
  d: real; // ошибка обучения
  dv: real; // изменение веса
  sig: real; // нейронная ошибка

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
  // инициализация весов
  for i := 1 to 3 do
    value[i] := random;
  writeln('Коэффициенты персептрона                       Ошибка');
  write(value[1]: 14: 10, ' ', value[2]: 14: 10, ' ', value[3]: 14: 10, ' ');
  // вычисление ошибки
  d := 0;
  for j := 1 to 4 do
  begin
    input[1] := input_data[j, 1];
    input[2] := input_data[j, 2];
    input[3] := input_data[j, 3];
    calculate;
    d := d + sqr(res[j] - ans);
  end;
  d := d / 2;
  writeln(d: 14: 10);
  // обучение (градиентный спуск)
  for p := 1 to N_Max do
  begin
    for i := 1 to 3 do
      dvalue[i] := 0;
    for j := 1 to 4 do
    begin
      input[1] := input_data[j, 1];
      input[2] := input_data[j, 2];
      input[3] := input_data[j, 3];
      calculate;
      for i := 1 to 3 do
      begin
        sig := ans * (1 - ans) * (res[j] - ans);
        dv := n * sig * input[i];
        dvalue[i] := dvalue[i] + dv;  
      end;
    end;
    for i := 1 to 3 do
      value[i] := value[i] + dvalue[i];
    write(value[1]: 14: 10, ' ', value[2]: 14: 10, ' ', value[3]: 14: 10, ' ');
    // вычисление ошибки
    d := 0;
    for j := 1 to 4 do
    begin
      input[1] := input_data[j, 1];
      input[2] := input_data[j, 2];
      input[3] := input_data[j, 3];
      calculate;
      d := d + sqr(res[j] - ans);
    end;
    d := d / 2;
    writeln(d: 14: 10);
  end;
end.