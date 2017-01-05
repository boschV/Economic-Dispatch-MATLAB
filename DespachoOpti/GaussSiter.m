%GaussSiter.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%Este archivo realiza el método de Gauss-Seidel para encontrar los voltajes
%y angulos de las barras, y luego llama a la función flujos de potencia
%para obtener los flujos de potencia (valga la redundancia)

barrasConv = 1; % 1 porque la barra slack ya converge
Nite= 0; %Numero de iteraciones
while barrasConv ~= N_barras %El programa corre hasta que todas las barras converjan
    Nite = Nite+1;
    for i = 1:N_barras
        if vbarra(i).ID == 0 %No hace nada cuando es slack
        elseif vbarra(i).ID == 1 %PV
            V1 = abs(vbarra(i).Vp); %Guarda el valor incicial para luego sacar el error
            A1 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).Q = Qpv(i, vbarra, Ybus); %Halla el Q aproximado
            
            %Se compara la Q calculada con la Qmax y la Qmin para
            %determinar si hay que transformar la barra a una PQ
            if (isnan(vbarra(i).Qmax) == 0) && (vbarra(i).Q > vbarra(i).Qmax)
                vbarra(i).Q = vbarra(i).Qmax;
                vbarra(i).ID = 3;
            elseif (isnan(vbarra(i).Qmin) == 0) && (vbarra(i).Q < vbarra(i).Qmin)
                vbarra(i).Q = vbarra(i).Qmin;
                vbarra(i).ID = 3;
            end
            
            vbarra(i).S = vbarra(i).P +1j* vbarra(i).Q; %Calula el Saprox
            vbarra(i).Vp = Vpq(i, vbarra, Ybus); %Calcula el voltaje
            vbarra(i).Vp = vbarra(i).V*exp(1j*angle(vbarra(i).Vp)); %Coloca el voltaje asignado en la barra pero con el angulo obtenido en la linea anterior
            V2 = abs(vbarra(i).Vp); %Guarda el valor final para conseguir el error
            A2 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).eV = abs(V1-V2); %Se obtiene el error
            vbarra(i).eA = abs(A1-A2);
            if (vbarra(i).eV <= ConV) && (vbarra(i).eA <= ConA) && (vbarra(i).Conv == 0) %Cuando el voltaje y el angulo convergen
                barrasConv = barrasConv+1; %Se le suma uno a la cantidad de barras que ya convergieron
                vbarra(i).Conv = 1; %Se cambia el estado de la barra de no convergente(0) a convergente(1)
            end
            
        elseif vbarra(i).ID == 2 %Para las barras PQ el proceso es similar solo que el voltaje obtenido
            V1 = abs(vbarra(i).Vp);     %por la funcion Vpq es directamente el resultado
            A1 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).Vp = Vpq(i, vbarra, Ybus);
            V2 = abs(vbarra(i).Vp);
            A2 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).eV = abs(V1-V2);
            vbarra(i).eA = abs(A1-A2);
            if (vbarra(i).eV <= ConV) && (vbarra(i).eA <= ConA) && (vbarra(i).Conv == 0)
                barrasConv = barrasConv+1;
                vbarra(i).Conv = 1;
            end
            
        elseif vbarra(i).ID == 3 %Para las barras PV que se cambian a PQ
            V1 = abs(vbarra(i).Vp); 
            A1 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).S = vbarra(i).P +1j* vbarra(i).Q;
            vbarra(i).Vp = Vpq(i, vbarra, Ybus); %Se calcula el voltaje nuevo
            V2 = abs(vbarra(i).Vp);
            A2 = 180*angle(vbarra(i).Vp)/pi;
            vbarra(i).Q = Qpv(i, vbarra, Ybus); %Se consigue la Q para compararla con la Qmax y la Qmin
            
            if (vbarra(i).Q < vbarra(i).Qmax) && (vbarra(i).Q > vbarra(i).Qmin) 
                %Cuando la Q se encuentra en el rango determinado se asigna
                %un nuevo V nominal a la barra y se transforma de nuevo en
                %una barra PV
                vbarra(i).V = abs(vbarra(i).Vp);
                vbarra(i).ID = 1;
            end
            
            vbarra(i).eV = abs(V1-V2);
            vbarra(i).eA = abs(A1-A2);

        end
    end

    if Nite >= limiteIter % Limite de iteraciones para que el programa no se quede trancado
        fprintf('\n Limite de iteraciones alcanzado, el sistema no logro converger en %i iteraciones \n',Nite);
        break;
    end

end

%Imprime los voltajes para cada barra
Voltajes = zeros(N_barras, 2);

for i=1:N_barras
    Voltajes(i,1)=abs(vbarra(i).Vp);
    Voltajes(i,2)=180*angle(vbarra(i).Vp)/pi;
    %fprintf('\n Barra: %i, V= %5.4f ang %5.4f \n',i,Voltajes(i,1),Voltajes(i,2));
end


Flujos_De_Potencia
