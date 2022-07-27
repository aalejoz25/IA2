clc;
clear all;
close all;

%filtros a utilizar
vertical = [-1 1]';
horizontal = [-1 1];
realce_bordes = [0 0 0; -1 1 0; 0 0 0];

fig1 = figure('Name', 'Filtros a Sonic');
sonic=imread('Imagenes/Sonic.jpg');
subplot(2,2,1);
imshow(sonic);
title('Sonic original') 

display('Tiempo sonic filtro horizontal')
tic
horizontalEdgeImageSonic = aplicarkernel(sonic,horizontal);
toc
display('Tiempo sonic filtro vertical')
tic
verticalEdgeImageSonic = aplicarkernel(sonic,vertical);
toc
display('Tiempo sonic filtro Realce Bordes')
tic
EnhanceEdgesImageSonic = aplicarkernel(sonic, realce_bordes);
toc

subplot(2,2,2);
imshow(horizontalEdgeImageSonic);
title('Sonic filtro horizontal');

subplot(2,2,3);
imshow(verticalEdgeImageSonic);
title('Sonic filtro vertical'); 

subplot(2,2,4);
imshow(EnhanceEdgesImageSonic);
title('Sonic Kernel realce de Bordes'); 
display('________________________________________________________________-')

fig2 = figure('Name', 'Filtros al grupo');

grupo = imread('Imagenes/Grupo.jpg');
subplot(2,2,1);
imshow(grupo);
title('Imagen original') 

display('Tiempo grupo filtro horizontal')
tic
horizontalEdgeImageGrupo = aplicarkernel(grupo,horizontal);
toc
display('Tiempo grupo filtro vertical')
tic
verticalEdgeImageGrupo = aplicarkernel(grupo,vertical);
toc
display('Tiempo grupo kernel Realce Bordes')
tic
EnhanceEdgesImageGrupo = aplicarkernel(grupo, realce_bordes);
toc

subplot(2,2,2);
imshow(horizontalEdgeImageGrupo);
title('Grupo filtro horizontal');

subplot(2,2,3);
imshow(verticalEdgeImageGrupo);
title('Grupo filtro vertical'); 

subplot(2,2,4);
imshow(EnhanceEdgesImageGrupo);
title('Grupo Kernel realce de Bordes');

display('_______________________________________________')

sonicbn_horizontal = rgb2gray(horizontalEdgeImageSonic);
display('Entropia sonic horizontal=')
display(entropy(sonicbn_horizontal))

sonicbn_vertical = rgb2gray(verticalEdgeImageSonic);
display('Entropia sonic vertical=')
display(entropy(sonicbn_vertical))

sonicbn_enhance = rgb2gray(EnhanceEdgesImageSonic);
display('Entropia sonic realce bordes=')
display(entropy(sonicbn_enhance))

display('_______________________________________________')


grupobn_horizontal = rgb2gray(horizontalEdgeImageGrupo);
display('Entropia grupo horizontal=')
display(entropy(grupobn_horizontal))

grupobn_vertical = rgb2gray(verticalEdgeImageGrupo);
display('Entropia grupo vertical=')
display(entropy(grupobn_vertical))

grupobn_enhance = rgb2gray(EnhanceEdgesImageGrupo);
display('Entropia grupo realce bordes=')
display(entropy(grupobn_enhance))

function f=aplicarkernel(image, kernel)
    rChannel = image(:, :, 1);
    gChannel = image(:, :, 2);
    bChannel = image(:, :, 3);
    
    rChannelNew = filter2(kernel, rChannel);
    gChannelNew = filter2(kernel, gChannel);
    bChannelNew = filter2(kernel, bChannel);
    
    outputImg = cat(3, rChannelNew, gChannelNew, bChannelNew);
    outputImg = mat2gray(outputImg);
    
    f=outputImg;
end

%Es posible observar, que para la imagen de sonic son mucho mas notables
%los bordes con el kernel de realce de bordes que con los otros dos filtros
%pero por otro lado, su entropia y su tiempo de ejecucion es algo mayor

%En cuanto a la imagen del grupo, el filtro vertical obtuvo muy buenos
%resultados, pues alli muchos bordes son evidentes, sin embargo, la
%entropia para este caso es mayor que para el kernel de realce de bordes.

%Con esto, concluimos que la aplicacion del filtro se debe bastante al
%contexto o entorno en el que vaya a estar, pues si en el entorno se
%encuentran mas caracteristicas horizontales, sera mejor aplicar el filtro
%vertical, lo contrario si hay mas caracteristicas verticales, y dichas 
%caracteristicas estan equilibradas, podria ser mejor aplicar el kernel de 
%realce de bordes, u otro que cumpla una funcion similar.
