%lambdaiter.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169

%Esta función realiza un lambda iterativo para resolver el despacho, es
%importante que el lambda inicial que se da sea mayor a los valores
%constantes (coeficiente de la variable de orden cero) del costo incremental
%para garantizar que la solución encontrada sea positivo

%Esta funcion tambien necesita del porcentaje del salto inicial para poder
%tener los primeros dos puntos y así realizar la interpolación

%-------------------------Lambda iterativo---------------------------------
function [Pgen1] = lambdaiter(gen, Ptotal ,lambini, porcSalto)

    numgen= size(gen,2); %Numero de generadores
    
    vecerror = zeros(3,1);

    Pgen1 = zeros(numgen+1,1); %Vector de las potencias resultantes
    for i = 1:numgen
        pol = gen(i).fpen*gen(i).CI;
        pol(1, end) = pol(1, end) - lambini;
        potobt = roots(pol); %Las raices de este polinomio corresponden al valor de la potencia
             for j = 1:size(potobt)
                if potobt(j) > 0 %Se escoge una potencia positiva en el caso de que hayan dos raices
                    Pgen1(i) = potobt(j);
                end
             end
        Pgen1(end) = Pgen1(end) +  Pgen1(i); %Se calcula la potencia total generada
    end

    vecerror = zeros(3,1);
    
    %Calculo del error
    vecerror(1) = Pgen1(end) - Ptotal;

    lambd2 = lambini - (porcSalto/100)*lambini; %Se calcula el nuevo lambda 
                                                %para luego poder hacer
                                                %interpolacion
    Pgen1(end) = 0;
    
    %Se repite el proceso anterior
    for i = 1:numgen
        pol = gen(i).fpen*gen(i).CI;
        pol(1, end) = pol(1, end) - lambd2;
        potobt = roots(pol);
             for j = 1:size(potobt)
                 if potobt(j) > 0
                         Pgen1(i) = potobt(j);
                 end
             end
        Pgen1(end) = Pgen1(end) +  Pgen1(i);
    end
    
    %Se calcula el nuevo error
    vecerror(2) = Pgen1(end) - Ptotal;
    %Se calcula el nuevo lambda por interpolacion
    vecerror(3) = vecerror(2) - vecerror(1);
    lambdak3 = (-vecerror(2)* ((lambd2-lambini)/vecerror(3)))+ lambd2;
    kite=0;
    kitemax = 10000;

    cond = false;
    %Se buscan nuevas potencias hasta que converge el resultado
    while cond == false
        Pgen1(end) = 0;
        lambini = lambd2; %Se preparan las variables para la proxima iteracion
        lambd2 = lambdak3;
        vecerror(1) = vecerror(2);
        for i = 1:numgen
            pol = gen(i).fpen*gen(i).CI;
            pol(1, end) = pol(1, end) - lambdak3;
            
            %Este if es para salir del loop cuando ya converge el resultado
            if isinf(lambdak3) || isinf(lambd2) || isinf(lambini) 
                break;
            elseif isnan(lambdak3) || isnan(lambd2) || isnan(lambini)
                break;
            end

            potobt = roots(pol);
            for j = 1:size(potobt)
                if potobt(j) > 0
                    %Aqui se toman en cuenta los limites operacionales de
                    %los generadores
                    if potobt(j) < gen(i).potmin
                        Pgen1(i) = gen(i).potmin;
                    elseif potobt(j) > gen(i).potmax
                        Pgen1(i) = gen(i).potmax;
                    else
                        Pgen1(i) = potobt(j);
                    end
                end
            end
            Pgen1(end) = Pgen1(end) +  Pgen1(i);

        end

    vecerror(2) = Pgen1(end) - Ptotal;
    vecerror(3) = vecerror(2) - vecerror(1);
    lambdak3 = (-vecerror(2)* ((lambd2-lambini)/vecerror(3)))+ lambd2;

        %Este conjunto de ifs son para salir del loop
        if isinf(lambdak3) || isinf(lambd2) || isinf(lambini) 
            cond = true;
        elseif isnan(lambdak3) || isnan(lambd2) || isnan(lambini)
            cond = true;
        elseif kite >= kitemax
            fprintf('El lambda iterativo no convergio luego de %i iteraciones', kite);
            cond = true;
        end
    end
end