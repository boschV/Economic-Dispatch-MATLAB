%Input.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%En este archivo se ingresan los datos del sistema a resolver.

%Este programa rellena las distintas matrices y estructuras de parametros
%que se usan a lo largo del programa

%En esta matriz se ingresan los datos de las lineas:
%barra inicial, barra final, R, X, admitancia shunt en el lado de la barra
%inicial y admitancia shunt en el lado de la barra final

Sbase = 100; %Primero que nada se ingresa la potencia base del sistema
                %bini bfin   R      X    admshuntini admshuntfin
datoslineas = [  1    2   0.02     0.04      0.0        0.0;
                 2    3   0.0125    0.025       0        0;
                 1    3   0.01     0.03       0           0 ];

%En esta matriz se ingresan los datos iniciales de las barras:
%El numero de barra, el codigo de la barra, el voltaje inicial, el angulo
%inicial, la potencia activa y reactiva generada en la barra,
%la potencia activa y reactiva de las cargas en la barra, y la Qmin y Qmax

%Es MUY IMPORTANTE mantener a Qmin y Qmax como NaN cuando ese parametro no
%este definido (No he probado la funcion de Qmin y Qmax bien asi que
%probablemente no funcione correctamente cuando Qmin y Qmax sean distintas
%de NaN)

             %#barra Codigo Voltaje  Angulo  Pgen  Qgen  Pcar     Qcar  Qmin Qmax
datosbarras = [ 1     0       1.05     0     0       0     0        0   NaN  NaN;
                2     2       1        0     0       0     2       1.5  NaN  NaN;
                3     1       1.04     0     0       0     0        0   NaN  NaN];
 
%Codigos:
%0->Slack
%1->PV 
%2->PQ
%3->PV que se transformo a PQ para limitar el Q al rango [Qmin,Qmax]

%------------------Generadores----------------------
numgen = 2; %Numero de generadores en el sistema
inigen = cell([1 numgen]);
gen = struct('barra',inigen,'ID',inigen,'potmin',inigen,'potmax',inigen,'costo',inigen,'CI',inigen, 'lambd',inigen,'fpen',inigen);

gen(1).barra = 1;
gen(1).ID = 0;
gen(1).potmin = 32; %en MW
gen(1).potmax = 180; %en MW
gen(1).costo = [0.09 41 288]; %Son los coeficientes del polinomio
gen(1).CI = polyder(gen(1).costo); %Los coeficientes del polinomio dentro de la funcion polyder()
gen(1).fpen = 1; %El factor de penalizacion inicialmente se hace 1 (No se penaliza)

gen(2).barra = 3;
gen(2).ID = 1;
gen(2).potmin = 22;
gen(2).potmax = 130;
gen(2).costo = [0.18 32 325];
gen(2).CI = polyder(gen(2).costo);
gen(2).fpen = 1;


fcosto = @(x)costo(x,gen); % Se define la funcion de costo requerida por la funcion fmincon
                           % (Funcion a minimizar)

%Se preparan las distintas variables de entrada requeridas por fmincon 
Aeq = ones(1 , numgen);
beq=0;

A = [];
b = [];

%Se calcula la potencia demandada
for i = 1:size(datosbarras, 1)
    beq = beq + datosbarras(i,7);
end

 beq=beq*Sbase;

for i = 1:numgen
    lb(i)=gen(i).potmin;
    ub(i)=gen(i).potmax;
end
%valores iniciales

x0 = [100 100]; %Aqui se le ingresa un punto de partida a la funcion de optimizacion
                %es importante destacar que los valores proporcionados
                %tienen que estar dentro del rango de operacion

%Se realiza el despacho sin perdidas
[DespEconSP] = fmincon(fcosto,x0,A,b,Aeq,beq,lb,ub,[],options);

%------TRX--------
%En esta matriz se ingresan los datos de los transformadores.
%El nodo principal, el nodo secundario, la R, la X y el tap.

%Es MUY IMPORTANTE colocar el tap en el lado de alta tension, en el caso de
%que el tap no este en ese lado se tiene que colocar el valor 1/tap 
%(es decir, pasar el tap para el lado de alta tension) para
%que funcione el programa correctamente

%Los campos de admitancia de linea (AdL), admitancia de shunt en alta
%tension (AdshAT) y admitancia de shunt en baja tension (Adshbt) son
%llenados por el programa.
      %NP    ns    R     X      tap    AdL     AdshAT   Adshbt 
TRX = [0     0     0     0        0    0         0       0];


%------------------------------------------------------------------
%Conf Gauss Seidel

%error maximo permitido para voltajes y angulos
ConV = 10^(-3);
ConA = 10^(-3);

%Se establece un limite al numero de iteraciones para evitar que el programa
%se quede trancado
limiteIter = 5000;

%-----------------------------------------------------------------
   
   for i = 1:size(TRX,1)
       if TRX(i,1) > 0
       Z=TRX(i,3)+1j*TRX(i,4);
       TRX(i,6)=inv(Z)/TRX(i,5);
       TRX(i,7)= Z \ ((1/(TRX(i,5)^2))-((1/TRX(i,5))));
       TRX(i,8) = Z \ (1-(1/TRX(i,5)));
       end
   end

N_barras = size(datosbarras, 1);

Ybus=zeros(N_barras);
%Se rellena la Ybus
for i = 1:size(datoslineas,1)
    Ybus(datoslineas(i,1),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,1))+inv(datoslineas(i,3)+1j*datoslineas(i,4));
    Ybus(datoslineas(i,1),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,1))+ 1j*datoslineas(i,5);
    
    Ybus(datoslineas(i,2),datoslineas(i,2))=Ybus(datoslineas(i,2),datoslineas(i,2))+inv(datoslineas(i,3)+1j*datoslineas(i,4));
    Ybus(datoslineas(i,2),datoslineas(i,2))=Ybus(datoslineas(i,2),datoslineas(i,2))+ 1j*datoslineas(i,6);
    
    Ybus(datoslineas(i,1),datoslineas(i,2))=Ybus(datoslineas(i,1),datoslineas(i,2))-inv(datoslineas(i,3)+1j*datoslineas(i,4));
    Ybus(datoslineas(i,2),datoslineas(i,1))=Ybus(datoslineas(i,1),datoslineas(i,2));
end

for i = 1:size(TRX,1)
    if TRX(i,1) > 0
    Ybus(TRX(i,1),TRX(i,1)) = Ybus(TRX(i,1),TRX(i,1)) + TRX(i,6) + TRX(i,7);
    
    Ybus(TRX(i,2),TRX(i,2)) = Ybus(TRX(i,2),TRX(i,2)) + TRX(i,6) + TRX(i,8);
    
    Ybus(TRX(i,1),TRX(i,2)) = Ybus(TRX(i,1),TRX(i,2)) - TRX(i,6);
    Ybus(TRX(i,2),TRX(i,1)) = Ybus(TRX(i,1),TRX(i,2));
    end
end

%cell que se usa para inicializar las variables del struct
iniV = cell([1 N_barras]);

%Se hace una estructura para guardar toda la informacion necesaria para cada
%barra

%Codigo Voltaje Angulo VoltajePolar P Q S Pgen Qgen Pcar Qcar Qmin Qmax ErrorV ErrorA Convergencia(bool)
vbarra = struct('ID',iniV,'V',iniV,'A',iniV,'Vp',iniV,'P',iniV,'Q',iniV,'S',iniV, ...
    'Pgen', iniV, 'Qgen',iniV,'Pcar',iniV,'Qcar',iniV,'Qmin',iniV,'Qmax',iniV,...
    'eV',iniV,'eA',iniV,'Conv',iniV,'ConvP',iniV);

%Codigos: 0->Slack, 1->PV, 2->PQ

%Se rellena la estructura
for i = 1:N_barras
    vbarra(datosbarras(i,1)).ID = datosbarras(i,2);
    vbarra(datosbarras(i,1)).V = datosbarras(i,3);
    vbarra(datosbarras(i,1)).A = datosbarras(i,4);
    vbarra(datosbarras(i,1)).Vp = vbarra(datosbarras(i,1)).V*exp(1j*vbarra(datosbarras(i,1)).A*pi/180);
    
    vbarra(datosbarras(i,1)).Pgen = datosbarras(i,5);
    vbarra(datosbarras(i,1)).Pcar = datosbarras(i,7);
    vbarra(datosbarras(i,1)).P = datosbarras(i,5)-datosbarras(i,7);
    
    vbarra(datosbarras(i,1)).Qgen = datosbarras(i,6);
    vbarra(datosbarras(i,1)).Qcar = datosbarras(i,8);
    vbarra(datosbarras(i,1)).Q = datosbarras(i,6)-datosbarras(i,8);
    
    vbarra(datosbarras(i,1)).S = vbarra(datosbarras(i,1)).P +1j* vbarra(datosbarras(i,1)).Q;
    
    vbarra(datosbarras(i,1)).Qmin = datosbarras(i,9);
    vbarra(datosbarras(i,1)).Qmax = datosbarras(i,10);
end

%Se inicializan los distintos campos segun el tipo de barra (Slack,PV,PQ)
for i = 1:N_barras
    if vbarra(i).ID == 0
        vbarra(i).P = 0;
        vbarra(i).Q = 0;
        vbarra(i).S = 0;
        vbarra(i).Conv = 1;
        vbarra(i).eV = 0;
        vbarra(i).eA = 0;
    elseif vbarra(i).ID == 1
        vbarra(i).Q = [];
        vbarra(i).S = [];
        vbarra(i).A = 0;
        vbarra(i).Vp = vbarra(i).V*exp(1j*vbarra(i).A*pi/180);
        vbarra(i).Conv = 0;
    elseif vbarra(i).ID == 2
        vbarra(i).V = 1;
        vbarra(i).A = 0;
        vbarra(i).Vp = vbarra(i).V*exp(1j*vbarra(i).A*pi/180);
        vbarra(i).Conv = 0;
    end
end

for i=1:numgen
    if gen(i).ID == 1
        vbarra(gen(i).barra).Pgen = DespEconSP(i)/Sbase;
        vbarra(gen(i).barra).P = DespEconSP(i)/Sbase;
    end
end

%Se crea una matriz con las admitancias shunt que se va a usar para obtener
%el flujo de la potencia reactiva (En el archivo Flujos_De_Potencia)

BikShunt= zeros(N_barras);

for i = 1:size(datoslineas,1)
    BikShunt(datoslineas(i,1),datoslineas(i,2))= datoslineas(i,5);
    BikShunt(datoslineas(i,2),datoslineas(i,1))= datoslineas(i,6);
end

for i =1:size(TRX,1)
    if TRX(i,1) > 0
    BikShunt(TRX(i,1),TRX(i,2))= imag(TRX(i,7));
    BikShunt(TRX(i,2),TRX(i,1))= imag(TRX(i,8));
    end
end



