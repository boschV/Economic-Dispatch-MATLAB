%main.m

%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%Programa para la resolucion del Despacho economico con perdidas

%Este programa consiste de 11 archivos distintos que tienen que estar dentro
%de la misma carpeta para que corra correctamente. Los archivos son:
%main.m, Input.m, Flujos_De_Potencia.m, Vpq.m, Qpv.m, Pik.m, Qik.m,
%GaussSiter.m, costo.m, costopen.m, Penalizacion.m

%El programa da como resultado la potencia entregada por cada generador en
%despacho económico junto con el costo total

%El ingreso de los datos se hace en el archivo Input.m
%--------------------------------------------------------------------------

%En este archivo se introduce el valor maximo de error y se corre el programa

clear %limpia las variables antes de iniciar el programa
options = optimoptions('fmincon','Display','none'); %Define las opciones de la funcion fmincon

epsConv = 0.1; %Valor en que decimos que la potencia converge

Input %Llama al input

GaussSiter %Encuentra los valores de voltaje y angulo

Penalizacion %Calcula los factores de penalización

%Datos de Entrada para el primer despacho con penalizacion
PotenciaTotalEntr = Pgentot;
PotenciasIniciales = DespEconSP;

%Se hace el primer despacho con penalizacion
fcostopen = @(x)costopen(x,gen);
[DespEconPen] = fmincon(fcostopen,PotenciasIniciales,A,b,Aeq,PotenciaTotalEntr,lb,ub,[],options);
    
kconv = 0;

kitera = 0;

while kconv < numgen %Mientras las potencias que convegen sean menor que el numero de generadores se itera
    kitera = kitera + 1;
    for i = 1:N_barras
    %Prepara a las variables de las barras para realizar un nuevo
    %Gauss-Seidel
        if vbarra(i).ID ~= 0
            vbarra(i).Conv = 0;
        end
    end
    
    %Se definen los nuevos valores de potencia de las barras PV para el
    %Gauss-Seidel
    
    for i=1:numgen
        if gen(i).ID == 1
            vbarra(gen(i).barra).Pgen = DespEconPen(i)/Sbase;
            vbarra(gen(i).barra).P = DespEconPen(i)/Sbase;
        end
    end
    
    GaussSiter
    Penalizacion %Se calculan los factores de penalizacion
    
    PotenciaTotalEntr = Pgentot; %Se define la nueva potencia total generada
    
    Xini = DespEconPen; %Se escoge como valor inicial de las potencias a
    %los valores obtenidos en la ultima iteracion
    
    %Se realiza el nuevo despacho penalizado
    fcostopen = @(x)costopen(x,gen);
    [DespEconPen] = fmincon(fcostopen,Xini,A,b,Aeq,PotenciaTotalEntr,lb,ub,[],options);
    
    %Se chequea convergencia
    for i = 1:size(DespEconPen)    
        if abs(DespEconPen(i)-Xini(i)) < epsConv
            kconv = kconv + 1;
        end
    end

end

CostoTotal1 = 0;
for i= 1:size(gen,2)
    CostoTotal1 = CostoTotal1 + polyval(gen(i).costo,DespEconPen(i));
end

%Se imprimen los resultados

fprintf('Para una demanda de: %4.5f MW \n \n',beq);
disp('El funcionamiento del sistema es mas economico cuando:')

for i= 1:size(gen,2)
    fprintf('\nGenerador en la barra %i entrega %4.5f MW\n',gen(i).barra,DespEconPen(i));
end


fprintf('\n Para un costo total de %4.5f Unidades/tiempo \n', CostoTotal1);

