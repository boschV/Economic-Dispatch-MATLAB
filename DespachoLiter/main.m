%main.m

%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%Programa para la resolucion del Despacho economico con perdidas

%Este programa consiste de 10 archivos distintos que tienen que estar dentro
%de la misma carpeta para que corra correctamente. Los archivos son:
%main.m, Input.m, Flujos_De_Potencia.m, Vpq.m, Qpv.m, Pik.m, Qik.m,
%GaussSiter.m, lambdaiter.m, DespachoPen.m

%El programa da como resultado la potencia entregada por cada generador en
%despacho económico junto con el costo total

%El ingreso de los datos se hace en el archivo Input.m
%--------------------------------------------------------------------------

%En este archivo se introduce el valor maximo de error para la potencia y se corre el programa

clear %limpia las variables antes de iniciar el programa

convP = 0.1; %Valor en que decimos que la potencia converge

Input %Llama al input (En el input se realiza un despacho econ sin perdidas
       %y se le asignan los valores iniciales de potencia a los generadores)

GaussSiter %Encuentra los voltajes y angulos de las barras

DespachoPen %Calcula los factores de penalizacion y realiza un nuevo lambda
            %iterativo tomando en cuenta estos valores
            
geneconv=0;

%Se chequea inicialmente si hay convergencia
for i = 1:numgen
    if abs((vbarra(gen(i).barra).Pgen)*Sbase - DespEconPen(i)) < convP
       vbarra(gen(i).barra).convP = true;
       geneconv=geneconv+1;
    end
end

%Mientras no exista convergencia se realizan despachos y se verifica
%convergencia
while geneconv < numgen
    %Prepara a las variables de las barras para realizar un nuevo
    %Gauss-Seidel
    for i = 1:N_barras
        if vbarra(i).ID ~= 0
            vbarra(i).Conv = 0;
        end
    end
    %Se definen las potencias del las barras PV segun los valores obtenidos
    %en el despacho anterior
    for i=1:numgen
        if gen(i).ID == 1
            vbarra(gen(i).barra).Pgen = DespEconPen(i)/Sbase;
            vbarra(gen(i).barra).P = DespEconPen(i)/Sbase;
        end
    end
    
    %Se realiza un nuevo Gauss-Seidel y un nuevo despacho con penalizacion
    GaussSiter
    DespachoPen
    
    %Se chequea convergencia nuevamente
    geneconv=0;
    for i = 1:numgen
        if abs((vbarra(gen(i).barra).Pgen)*Sbase - DespEconPen(i)) < convP
           vbarra(gen(i).barra).convP = true;
           geneconv=geneconv+1;
        end
    end
end

%Se calcula el costo total
CostoTotal = 0;
for i= 1:size(gen,2)
    CostoTotal = CostoTotal + polyval(gen(i).costo,DespEconPen(i));
end

%Se imprimen los reslutados
fprintf('Para una demanda de: %4.5f MW \n \n',PotenciaDem);
disp('El funcionamiento del sistema es mas economico cuando:')

for i= 1:size(gen,2)
    fprintf('\nGenerador en la barra %i entrega %4.5f MW\n',gen(i).barra,DespEconPen(i));
end

fprintf('\n Para un costo total de %4.5f Unidades/tiempo \n', CostoTotal);
