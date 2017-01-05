%Flujos_De_Potencia.m
%--------------------------------------------------------------------------
%Victor Bosch 13-10169
%En este archivo se consiguen todos los flujos de potencia y las perdidas
%tanto para las potencias activas y reactivas. Tambien se consigue el valor
%de las Pgen y la Qgen de la barra Slack y las Qgen de las barras PV

Pmat = zeros(N_barras);
Pgentotpu = 0;
Pgentot = 0;

for i= 1:N_barras
    for k = 1:N_barras
        %Con la funcion Pik se crea una matriz cuadrada con los distintos
        %flujos de potencia activa
        Pmat(i,k)= Pik(i,k,Ybus,vbarra);
    end
end

matP=[]; %Matriz de potencias activas ordenadas
matPperd = []; %matriz con las perdidas activas

%Con este loop se reescribe la matriz Pmat a un formato mas sencillo de
%presentar
for i= 1:N_barras
    for k = 1:N_barras
        if Pmat(i,k) ~= 0
            vec1 = [i k Pmat(i,k)];
            vec2 = [k i Pmat(k,i)];
            perd= [i k Pmat(i,k)+Pmat(k,i)];
            matP(end+1,:) = vec1;
            matP(end+1,:) = vec2;
            matPperd(end+1,:) = perd; %Se rellena la matriz de perdidas
            Pmat(k,i)=0;
        end
    end
end


Qmat = zeros(N_barras);

for i = 1:N_barras
    for k= 1:N_barras
        %Con la funcion Qik se crea una matriz cuadrada con los distintos
        %flujos de potencia reactiva
        Qmat(i,k) = Qik(i,k,BikShunt,Ybus,vbarra);
    end
end

matQ = []; %Matriz de potencias reactivas ordenadas
matQperd = []; %matriz con las perdidas reactivas

%Con este loop se reescribe la matriz Qmat a un formato mas sencillo de
%presentar
for i= 1:N_barras
    for k = 1:N_barras
        if Qmat(i,k) ~= 0
            vec1 = [i k Qmat(i,k)];
            vec2 = [k i Qmat(k,i)];
            Qperd= [i k Qmat(i,k)+Qmat(k,i)];
            matQ(end+1,:) = vec1;
            matQ(end+1,:) = vec2;
            matQperd(end+1,:) = Qperd; %Se rellena la matriz de perdidas
            Qmat(k,i)=0;
        end
    end
end

%Se calcula la Potencia activa y Reactiva de la Slack
for i = 1:N_barras
    if vbarra(i).ID == 0
        vbarra(i).P = 0;
        vbarra(i).Q = 0;
        for k= 1:size(matP,1)
            if matP(k,1) == i
                vbarra(i).P = vbarra(i).P + matP(k,3); %Sumatoria de los flujos que salen de la slack
            end
            
        end
        vbarra(i).Pgen = vbarra(i).P + vbarra(i).Pcar; %Se le suman las cargas en la barra slack
        for k= 1:size(matQ,1)
            if matQ(k,1) == i
                vbarra(i).Q = vbarra(i).Q + matQ(k,3); %Sumatoria de los flujos que salen de la slack
            end 
        end
        vbarra(i).Qgen = vbarra(i).Q + vbarra(i).Qcar; %Se le suman las cargas en la barra slack
        
%         fprintf('\nPotencia entregada por la barra slack: Barra=%i Pgen= %4.5f pu Qgen= %4.5f pu\n', i ,vbarra(i).Pgen, vbarra(i).Qgen);
        Pgentotpu = Pgentotpu + vbarra(i).Pgen;
    end
end

%Se calculan las potencias reactivas de las barras PV
for i = 1:N_barras
    if vbarra(i).ID == 1
        vbarra(i).Pgen = vbarra(i).P;
        vbarra(i).Qgen = vbarra(i).Q + vbarra(i).Qcar;
%         fprintf('\nPotencia entregada por la barra PV: Barra=%i Pgen= %4.5f pu Qgen= %4.5f pu \n', i ,vbarra(i).Pgen, vbarra(i).Qgen);
        Pgentotpu = Pgentotpu + vbarra(i).Pgen;
    end
end

Pgentot = Pgentotpu*Sbase;

%Se imprimen todos los flujos de potencia
% fprintf('\n');
% for i = 1:size(matP,1)
%     fprintf('Flujo de P de %i a %i: %4.5f pu \n \n', matP(i,1),matP(i,2),matP(i,3));
% end
% 
% for i = 1:size(matPperd,1)
%     fprintf('Perdidas de P entre %i y %i: %4.5f pu \n \n',matPperd(i,1),matPperd(i,2),matPperd(i,3));
% end
% 
% for i = 1:size(matQ,1)
%     fprintf('Flujo de Q de %i a %i: %4.5f pu\n \n', matQ(i,1),matQ(i,2),matQ(i,3));
% end
% 
% for i = 1:size(matQperd,1)
%     fprintf('Perdidas de Q entre %i y %i: %4.5f pu \n \n',matQperd(i,1),matQperd(i,2),matQperd(i,3));
% end
% 

